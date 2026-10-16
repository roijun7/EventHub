import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/event_model.dart';
import '../../../utils/app_theme.dart';
import '../../event_details/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(event.date);
    final categoryColor = AppTheme.getCategoryColor(event.category);
    final spotsLeft = event.capacity - event.registeredCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailsScreen(event: event),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image Banner with Category Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Hero(
                      tag: 'event-img-${event.id}',
                      child: event.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: event.imageUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 160,
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 160,
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: Icon(Icons.broken_image_rounded,
                                      size: 40, color: AppTheme.textMuted),
                                ),
                              ),
                            )
                          : Container(
                              height: 160,
                              color: categoryColor.withValues(alpha: 0.1),
                              child: Center(
                                child: Icon(
                                  AppTheme.getCategoryIcon(event.category),
                                  size: 48,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Category Badge Overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppTheme.getCategoryIcon(event.category),
                            size: 14,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.category,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status / Capacity Badge Overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.isPastEvent
                            ? Colors.black.withValues(alpha: 0.75)
                            : (event.isFull
                                ? AppTheme.error.withValues(alpha: 0.9)
                                : Colors.black.withValues(alpha: 0.65)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.isPastEvent
                            ? 'Completed'
                            : (event.isFull
                                ? 'Full'
                                : '$spotsLeft spots left'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Event Information
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.time,
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
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Description snippet
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    const Divider(height: 1, color: AppTheme.divider),
                    const SizedBox(height: 10),

                    // Location row
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 15, color: AppTheme.error),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: AppTheme.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
