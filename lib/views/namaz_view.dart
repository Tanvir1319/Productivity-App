import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class NamazView extends StatefulWidget {
  final StorageService store;

  const NamazView({super.key, required this.store});

  @override
  State<NamazView> createState() => _NamazViewState();
}

class _NamazViewState extends State<NamazView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitNamaz(String activeTabId) {
    final name = _nameController.text.trim();
    final time = _timeController.text.trim();
    final note = _noteController.text.trim();

    if (name.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter prayer name and time.')),
      );
      return;
    }

    widget.store.addNamazItem(activeTabId, name, time, note);
    _nameController.clear();
    _timeController.clear();
    _noteController.clear();
  }

  void _showRenameTabDialog(String tabId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Timetable Tab'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new tab name'),
          onSubmitted: (val) {
            widget.store.renameNamazTab(tabId, val);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.store.renameNamazTab(tabId, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(String tabId, NamazItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final timeCtrl = TextEditingController(text: item.time);
    final noteCtrl = TextEditingController(text: item.note);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Prayer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Prayer Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(labelText: 'Time (e.g. 05:15)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Notes / Sunnah'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.store.editNamazItem(
                tabId,
                item.id,
                nameCtrl.text,
                timeCtrl.text,
                noteCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: Color(0xFF101424),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() => _timeController.text = '$h:$m');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeId = widget.store.activeNamazTab ??
        (widget.store.namazTabs.isNotEmpty ? widget.store.namazTabs.first.tabId : 'tab_main');
    final activeTab = widget.store.namazTabs.firstWhere(
      (t) => t.tabId == activeId,
      orElse: () => NamazTab(tabId: 'tab_main', name: 'Main Schedule', items: []),
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 780),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Namaz Timetable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.store.namazTabs.length}/12 tabs)',
                    style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeTab.items.length}',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tabs Row (Horizontal scrollable, max 12 tabs)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...widget.store.namazTabs.map((t) {
                  final isActive = t.tabId == activeId;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => widget.store.selectNamazTab(t.tabId),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? AppTheme.primary.withOpacity(0.5) : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.name,
                              style: TextStyle(
                                color: isActive ? const Color(0xFFC4B5FD) : AppTheme.textMuted,
                                fontSize: 12.5,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _showRenameTabDialog(t.tabId, t.name),
                              child: const Icon(Icons.edit_outlined, size: 13, color: AppTheme.textDim),
                            ),
                            if (widget.store.namazTabs.length > 1) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => widget.store.deleteNamazTab(t.tabId),
                                child: const Icon(Icons.close, size: 13, color: AppTheme.textDim),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // Add tab button if under 12
                if (widget.store.namazTabs.length < 12)
                  Tooltip(
                    message: 'Add new timetable tab (max 12)',
                    child: InkWell(
                      onTap: () => widget.store.addNewNamazTab(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.add, size: 16, color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Max (12)', style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Items List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: activeTab.items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No prayer times added yet to this timetable.',
                        style: TextStyle(color: AppTheme.textDim, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: activeTab.items.length,
                    itemBuilder: (context, index) {
                      final item = activeTab.items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.access_time, color: Color(0xFFC4B5FD), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.time,
                                        style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.note.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      item.note,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textDim),
                              onPressed: () => _showEditItemDialog(activeId, item),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppTheme.textDim),
                              onPressed: () => widget.store.deleteNamazItem(activeId, item.id),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 14),

          // Add Prayer Form
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Prayer Name (e.g. Fajr)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _timeController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  readOnly: true,
                  onTap: _pickTime,
                  decoration: const InputDecoration(
                    hintText: 'Time (HH:MM)',
                    suffixIcon: Icon(Icons.schedule, size: 16, color: AppTheme.textDim),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Optional notes, Sunnah, or Dhikr...'),
                  onSubmitted: (_) => _submitNamaz(activeId),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _submitNamaz(activeId),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5BDB)),
                child: const Text('Add Prayer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

