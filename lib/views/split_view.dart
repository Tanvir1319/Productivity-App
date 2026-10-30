import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'goals_tab_view.dart';

class SplitView extends StatefulWidget {
  final StorageService store;
  final VoidCallback onExit;

  const SplitView({super.key, required this.store, required this.onExit});

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  GoalCategory _parseCategory(String key) {
    switch (key) {
      case 'daily':
        return GoalCategory.daily;
      case 'weekly':
        return GoalCategory.weekly;
      case 'monthly':
        return GoalCategory.monthly;
      case 'yearly':
        return GoalCategory.yearly;
      default:
        return GoalCategory.weekly;
    }
  }

  void _setLeft(String cat) {
    widget.store.saveSplitConfig(cat, widget.store.splitRight);
  }

  void _setRight(String cat) {
    widget.store.saveSplitConfig(widget.store.splitLeft, cat);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Split View Top Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.splitscreen_outlined, color: AppTheme.primary, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Split Screen Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '• View & manage side by side',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 12),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: BorderSide(color: AppTheme.danger.withOpacity(0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: widget.onExit,
                icon: const Icon(Icons.close, size: 15),
                label: const Text('Exit Split View', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Responsive 2-column or 1-column layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 900;

            final leftPane = _buildPane(
              title: 'Left Column',
              activeKey: widget.store.splitLeft,
              onSelect: _setLeft,
              category: _parseCategory(widget.store.splitLeft),
            );

            final rightPane = _buildPane(
              title: 'Right Column',
              activeKey: widget.store.splitRight,
              onSelect: _setRight,
              category: _parseCategory(widget.store.splitRight),
            );

            if (isNarrow) {
              return Column(
                children: [
                  leftPane,
                  const SizedBox(height: 16),
                  rightPane,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: leftPane),
                const SizedBox(width: 16),
                Expanded(child: rightPane),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Bottom Exit Button (as requested)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: BorderSide(color: AppTheme.danger.withOpacity(0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: widget.onExit,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Exit Split View', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPane({
    required String title,
    required String activeKey,
    required ValueChanged<String> onSelect,
    required GoalCategory category,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pane Header: Title + Pills
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPill('daily', '📅 Daily', activeKey == 'daily', () => onSelect('daily')),
                      _buildPill('weekly', '📆 Weekly', activeKey == 'weekly', () => onSelect('weekly')),
                      _buildPill('monthly', '🗓 Monthly', activeKey == 'monthly', () => onSelect('monthly')),
                      _buildPill('yearly', '🎯 Yearly', activeKey == 'yearly', () => onSelect('yearly')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x15FFFFFF)),

          // Embedded Category Goal Tab View
          GoalsTabView(
            category: category,
            store: widget.store,
            isSplitPane: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String key, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFC4B5FD) : AppTheme.textDim,
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

