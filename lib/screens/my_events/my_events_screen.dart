import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/registration_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';

import '../../utils/app_theme.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  void _confirmCancel(
    BuildContext context,
    RegistrationModel registration,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Registration?'),
        content: Text(
          'Are you sure you want to cancel your registration for "${registration.eventTitle}"? Your spot will be released to other students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Registration'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final eventProvider =
                  Provider.of<EventProvider>(context, listen: false);

              final success = await eventProvider.cancelRegistration(
                registrationId: registration.id,
                eventId: registration.eventId,
                eventTitle: registration.eventTitle,
              );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration cancelled successfully.'),
                      backgroundColor: AppTheme.textPrimary,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          eventProvider.actionError ?? 'Cancellation failed.'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<UserAuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    if (auth.user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your registrations.')),
      );
    }

    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Registered Events'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.divider),
        ),
      ),
      body: StreamBuilder<List<RegistrationModel>>(
        stream: eventProvider.getUserRegistrationsStream(auth.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading registrations: ${snapshot.error}'),
            );
          }

          final registrations = snapshot.data ?? [];

          if (registrations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_border_rounded,
                          size: 48, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Registered Events Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse upcoming campus events and register to see them listed here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final reg = registrations[index];
              final categoryColor = AppTheme.getCategoryColor(reg.eventCategory);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Category badge & Registered badge
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reg.eventCategory,
                              style: TextStyle(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 13, color: AppTheme.success),
                                SizedBox(width: 4),
                                Text(
                                  'Confirmed',
                                  style: TextStyle(
                                    color: Color(0xFF166534),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main info: Image thumbnail + title + date
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: reg.eventImageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: reg.eventImageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorWidget: (c, u, e) => Container(
                                      width: 72,
                                      height: 72,
                                      color: const Color(0xFFE2E8F0),
                                      child: const Icon(Icons.event),
                                    ),
                                  )
                                : Container(
                                    width: 72,
                                    height: 72,
                                    color: categoryColor.withValues(alpha: 0.15),
                                    child: Icon(
                                      AppTheme.getCategoryIcon(reg.eventCategory),
                                      color: categoryColor,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reg.eventTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 13, color: AppTheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateFormat.format(reg.eventDate),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 13, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      reg.eventTime,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Venue row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppTheme.error),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reg.eventLocation,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Divider(height: 1, color: AppTheme.divider),
                    ),

                    // Actions: Cancel Registration
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _confirmCancel(context, reg),
                            icon: const Icon(Icons.cancel_outlined,
                                size: 16, color: AppTheme.error),
                            label: const Text(
                              'Cancel Registration',
                              style: TextStyle(color: AppTheme.error),
                            ),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
