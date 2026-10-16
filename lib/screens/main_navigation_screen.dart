import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_theme.dart';
import 'home/event_list_screen.dart';
import 'my_events/my_events_screen.dart';
import 'history/event_history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    EventListScreen(),
    MyEventsScreen(),
    EventHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize seed events if database is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).initializeData();
    });
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of EventHub?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<UserAuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<UserAuthProvider>(context);
    final userEmail = auth.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_activity_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'EventHub',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // User profile & Sign out button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'logout') {
                  _confirmSignOut();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.user?.displayName ?? 'Student',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 18, color: AppTheme.error),
                      SizedBox(width: 8),
                      Text('Log Out',
                          style: TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        (auth.user?.displayName?.isNotEmpty ?? false)
                            ? auth.user!.displayName![0].toUpperCase()
                            : (userEmail.isNotEmpty
                                ? userEmail[0].toUpperCase()
                                : 'U'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: AppTheme.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon:
                  Icon(Icons.explore_rounded, color: AppTheme.primary),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon:
                  Icon(Icons.bookmark_rounded, color: AppTheme.primary),
              label: 'My Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon:
                  Icon(Icons.history_rounded, color: AppTheme.primary),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
