import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TasksView extends StatefulWidget {
  final StorageService store;

  const TasksView({super.key, required this.store});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final text = _taskController.text.trim();
    if (text.isNotEmpty) {
      widget.store.addTask(text);
      _taskController.clear();
    }
  }

  void _showEditTaskDialog(int id, String initialText) {
    final controller = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Task description'),
          onSubmitted: (val) {
            widget.store.editTask(id, val);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.store.editTask(id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = widget.store.tasks.where((t) => !t.done).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750;

        final tasksBoard = _buildTasksBoard(activeCount);
        final notesBoard = _buildNotesBoard();

        if (isNarrow) {
          return Column(
            children: [
              tasksBoard,
              const SizedBox(height: 16),
              notesBoard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: tasksBoard),
            const SizedBox(width: 16),
            Expanded(child: notesBoard),
          ],
        );
      },
    );
  }

  Widget _buildTasksBoard(int activeCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Board Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  color: Color(0xFFC4B5FD),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeCount/${widget.store.tasks.length}',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tasks List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: widget.store.tasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No tasks yet. Add one below!',
                        style: TextStyle(color: AppTheme.textDim, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.store.tasks.length,
                    itemBuilder: (context, index) {
                      final task = widget.store.tasks[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 3.5),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => widget.store.toggleTask(task.id),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: task.done ? const Color(0xFFA78BFA) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: task.done ? const Color(0xFFA78BFA) : Colors.white30,
                                    width: 1.5,
                                  ),
                                ),
                                child: task.done
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                task.text,
                                style: TextStyle(
                                  color: task.done ? AppTheme.textDim : AppTheme.textMain,
                                  fontSize: 13.5,
                                  decoration: task.done ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textDim),
                              onPressed: () => _showEditTaskDialog(task.id, task.text),
                              tooltip: 'Edit',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppTheme.textDim),
                              onPressed: () => widget.store.deleteTask(task.id),
                              tooltip: 'Delete',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 12),
          // Add Task Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Add task...'),
                  onSubmitted: (_) => _submitTask(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Board Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notes',
                style: TextStyle(
                  color: Color(0xFF7DD3FC),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.store.notes.length}',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Notes List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: widget.store.notes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No notes yet. Click "+ New Note" below!',
                        style: TextStyle(color: AppTheme.textDim, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.store.notes.length,
                    itemBuilder: (context, index) {
                      final note = widget.store.notes[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Note #${note.id}',
                                  style: const TextStyle(color: AppTheme.textDim, fontSize: 10.5, fontWeight: FontWeight.w600),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 14, color: AppTheme.textDim),
                                  onPressed: () => widget.store.deleteNote(note.id),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            TextField(
                              controller: TextEditingController(text: note.text)
                                ..selection = TextSelection.fromPosition(TextPosition(offset: note.text.length)),
                              maxLines: null,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Write note...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) => widget.store.updateNote(note.id, val),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 12),
          // Add Note Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.store.addNote(''),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Note'),
            ),
          ),
        ],
      ),
    );
  }
}

