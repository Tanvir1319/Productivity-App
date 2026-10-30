import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'year_progress_dialog.dart';

class SidebarWidget extends StatelessWidget {
  final String activeView;
  final ValueChanged<String> onSelectView;
  final StorageService store;

  const SidebarWidget({
    super.key,
    required this.activeView,
    required this.onSelectView,
    required this.store,
  });

  void _openYearModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => YearProgressDialog(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yearStats = store.yearStats;
    final yearPct = yearStats['yearPct'] as int;
    final leftDays = yearStats['leftDays'] as int;

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.sidebar,
        border: Border(right: BorderSide(color: Color(0x0FFFFFFF), width: 1)),
      ),
      child: Column(
        children: [
          // App Logo
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 18),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FocusFlow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Focus. Plan. Achieve.',
                        style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 9.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Navigation and Progress Lists
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(
                  id: 'tasks',
                  label: 'Tasks',
                  icon: Icons.check_circle_outline,
                  badge: '${store.tasks.where((t) => !t.done).length}/${store.tasks.length}',
                ),
                _buildNavItem(
                  id: 'notes',
                  label: 'Notes',
                  icon: Icons.description_outlined,
                  badge: '${store.notes.length}',
                ),
                _buildNavItem(
                  id: 'daily',
                  label: 'Daily Goals',
                  icon: Icons.today_outlined,
                ),
                _buildNavItem(
                  id: 'weekly',
                  label: 'Weekly Goals',
                  icon: Icons.date_range_outlined,
                ),
                _buildNavItem(
                  id: 'monthly',
                  label: 'Monthly Goals',
                  icon: Icons.calendar_month_outlined,
                ),
                _buildNavItem(
                  id: 'yearly',
                  label: 'Yearly Goals',
                  icon: Icons.flag_outlined,
                ),
                _buildNavItem(
                  id: 'split',
                  label: 'Split Screen',
                  icon: Icons.splitscreen_outlined,
                ),
                _buildNavItem(
                  id: 'namaz',
                  label: 'Namaz Timetable',
                  icon: Icons.access_time_outlined,
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0x10FFFFFF)),
                const SizedBox(height: 12),

                // Progress trackers in sidebar
                _buildProgressBar(
                  label: 'DAILY GOALS',
                  progress: store.dailyProgress,
                  text: '${(store.dailyProgress * 100).round()}%',
                ),
                _buildProgressBar(
                  label: 'WEEKLY GOALS',
                  progress: store.weeklyProgress,
                  text: '${(store.weeklyProgress * 100).round()}%',
                ),
                _buildProgressBar(
                  label: 'MONTHLY GOALS',
                  progress: store.monthlyProgress,
                  text: '${(store.monthlyProgress * 100).round()}%',
                ),
                _buildProgressBar(
                  label: 'YEARLY GOALS',
                  progress: store.yearlyProgress,
                  text: '${(store.yearlyProgress * 100).round()}%',
                ),

                // Year Progress Card (Clickable)
                InkWell(
                  onTap: () => _openYearModal(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.insights, size: 13, color: AppTheme.accent),
                                SizedBox(width: 5),
                                Text(
                                  'YEAR PROGRESS',
                                  style: TextStyle(
                                    color: AppTheme.textDim,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$yearPct%',
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (yearPct / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.07),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '$leftDays days left',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
                              ),
                            ),
                            const Text(
                              'View Stats ↗',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Notes count card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL NOTES',
                        style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${store.notes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String id,
    required String label,
    required IconData icon,
    String? badge,
  }) {
    final isActive = activeView == id;

    return InkWell(
      onTap: () => onSelectView(id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: isActive ? const Color(0xFFC4B5FD) : AppTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 10.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double progress,
    required String text,
  }) {
    final pct = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct == 100 ? AppTheme.runningGreen : AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

