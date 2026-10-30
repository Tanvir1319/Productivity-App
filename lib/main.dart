import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/quran_carousel.dart';
import 'widgets/sidebar_widget.dart';
import 'widgets/timer_widget.dart';
import 'views/tasks_view.dart';
import 'views/notes_view.dart';
import 'views/goals_tab_view.dart';
import 'views/split_view.dart';
import 'views/namaz_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

  runApp(FocusFlowApp(storageService: storageService));
}

class FocusFlowApp extends StatelessWidget {
  final StorageService storageService;

  const FocusFlowApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FocusFlowHomePage(store: storageService),
    );
  }
}

class FocusFlowHomePage extends StatefulWidget {
  final StorageService store;

  const FocusFlowHomePage({super.key, required this.store});

  @override
  State<FocusFlowHomePage> createState() => _FocusFlowHomePageState();
}

class _FocusFlowHomePageState extends State<FocusFlowHomePage> {
  String _activeView = 'tasks';
  String _previousViewBeforeSplit = 'weekly';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _onSelectView(String view) {
    if (view == 'split') {
      _openSplitView();
      return;
    }
    _previousViewBeforeSplit = view;
    setState(() => _activeView = view);
  }

  void _openSplitView([String? initialView]) {
    if (initialView != null) {
      _previousViewBeforeSplit = initialView;
      if (initialView == 'yearly') {
        widget.store.saveSplitConfig('yearly', 'weekly');
      } else if (initialView == 'monthly') {
        widget.store.saveSplitConfig('monthly', 'weekly');
      } else if (initialView == 'weekly') {
        widget.store.saveSplitConfig('weekly', 'monthly');
      } else if (initialView == 'daily') {
        widget.store.saveSplitConfig('daily', 'weekly');
      }
    }
    setState(() => _activeView = 'split');
  }

  void _exitSplitView() {
    setState(() => _activeView = _previousViewBeforeSplit);
  }

  Widget _buildActiveView() {
    switch (_activeView) {
      case 'tasks':
        return TasksView(store: widget.store);
      case 'notes':
        return NotesView(store: widget.store);
      case 'daily':
        return GoalsTabView(
          category: GoalCategory.daily,
          store: widget.store,
          onOpenSplit: () => _openSplitView('daily'),
        );
      case 'weekly':
        return GoalsTabView(
          category: GoalCategory.weekly,
          store: widget.store,
          onOpenSplit: () => _openSplitView('weekly'),
        );
      case 'monthly':
        return GoalsTabView(
          category: GoalCategory.monthly,
          store: widget.store,
          onOpenSplit: () => _openSplitView('monthly'),
        );
      case 'yearly':
        return GoalsTabView(
          category: GoalCategory.yearly,
          store: widget.store,
          onOpenSplit: () => _openSplitView('yearly'),
        );
      case 'split':
        return SplitView(
          store: widget.store,
          onExit: _exitSplitView,
        );
      case 'namaz':
        return NamazView(store: widget.store);
      default:
        return TasksView(store: widget.store);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 768;

              final sidebar = SidebarWidget(
                activeView: _activeView,
                onSelectView: (view) {
                  _onSelectView(view);
                  if (isSmallScreen && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                store: widget.store,
              );

              final mainContent = SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Greeting Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Ready to conquer today’s goals?',
                                  style: TextStyle(color: AppTheme.textDim, fontSize: 13),
                                ),
                              ],
                            ),
                            if (isSmallScreen)
                              Builder(
                                builder: (ctx) => IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white),
                                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Persistent Quran Carousel (Global on every view)
                        const QuranCarouselWidget(),

                        // Focus Pomodoro Timer
                        const TimerWidget(),

                        // Dynamic View
                        _buildActiveView(),
                      ],
                    ),
                  ),
                ),
              );

              if (isSmallScreen) {
                return Scaffold(
                  drawer: Drawer(child: sidebar),
                  body: SafeArea(child: mainContent),
                );
              }

              return Row(
                children: [
                  sidebar,
                  Expanded(child: SafeArea(child: mainContent)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
