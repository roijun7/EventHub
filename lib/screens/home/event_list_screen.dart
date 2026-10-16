import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_theme.dart';
import 'widgets/category_chip.dart';
import 'widgets/event_card.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<UserAuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final userName = auth.user?.displayName ??
        (auth.user?.email != null ? auth.user!.email!.split('@')[0] : 'Student');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Profile Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $userName 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Discover campus events & register',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Search events, topics, or venues...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.textMuted),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18, color: AppTheme.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category horizontal list
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: EventProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = EventProvider.categories[index];
                          final isSelected =
                              eventProvider.selectedCategory == category;
                          return CategoryFilterChip(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              eventProvider.setCategory(category);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: StreamBuilder<List<EventModel>>(
            stream: eventProvider.getEventsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppTheme.error),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load events',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var events = snapshot.data ?? [];

              // Apply search filter if typed
              final query = _searchController.text.trim().toLowerCase();
              if (query.isNotEmpty) {
                events = events.where((e) {
                  return e.title.toLowerCase().contains(query) ||
                      e.description.toLowerCase().contains(query) ||
                      e.location.toLowerCase().contains(query) ||
                      e.category.toLowerCase().contains(query);
                }).toList();
              }

              if (events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_busy_rounded,
                              size: 48, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          query.isNotEmpty
                              ? 'No events match "$query"'
                              : 'No events found in this category',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Check back soon or try selecting another category.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return EventCard(event: events[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
