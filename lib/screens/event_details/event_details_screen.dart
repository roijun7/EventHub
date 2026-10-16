import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/event_provider.dart';

import '../../../services/notification_service.dart';
import '../../../utils/app_theme.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isCheckingStatus = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final auth = Provider.of<UserAuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (auth.user != null) {
      final registered =
          await eventProvider.isUserRegistered(widget.event.id, auth.user!.uid);
      if (mounted) {
        setState(() {
          _isRegistered = registered;
          _isCheckingStatus = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    final auth = Provider.of<UserAuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to register for events.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final success =
        await eventProvider.registerForEvent(widget.event, auth.user!);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isRegistered = true;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 28),
              SizedBox(width: 8),
              Text('Registration Confirmed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are registered for "${widget.event.title}".',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: AppTheme.success, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A confirmation notification has been sent and an event reminder was scheduled.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Awesome'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventProvider.actionError ?? 'Registration failed.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = dateFormat.format(widget.event.date);
    final categoryColor = AppTheme.getCategoryColor(widget.event.category);
    final eventProvider = Provider.of<EventProvider>(context);
    final spotsLeft = widget.event.capacity - widget.event.registeredCount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              // Test Notification Device Feature button
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(Icons.notifications_active_outlined,
                      color: Colors.white, size: 20),
                  tooltip: 'Test Event Notification',
                  onPressed: () async {
                    await NotificationService().showRegistrationConfirmation(
                      eventTitle: widget.event.title,
                      eventDate: widget.event.date,
                      eventLocation: widget.event.location,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔔 Notification triggered on device!'),
                          backgroundColor: AppTheme.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'event-img-${widget.event.id}',
                child: widget.event.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.event.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    : Container(
                        color: categoryColor.withValues(alpha: 0.2),
                        child: Center(
                          child: Icon(
                            AppTheme.getCategoryIcon(widget.event.category),
                            size: 64,
                            color: categoryColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Capacity badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppTheme.getCategoryIcon(widget.event.category),
                              size: 16,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.event.category,
                              style: TextStyle(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.event.isPastEvent
                              ? const Color(0xFFF1F5F9)
                              : (widget.event.isFull
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFF0FDF4)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.event.isPastEvent
                                ? AppTheme.divider
                                : (widget.event.isFull
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFFBBF7D0)),
                          ),
                        ),
                        child: Text(
                          widget.event.isPastEvent
                              ? 'Event Completed'
                              : (widget.event.isFull
                                  ? 'Event Full'
                                  : '$spotsLeft spots remaining'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.event.isPastEvent
                                ? AppTheme.textSecondary
                                : (widget.event.isFull
                                    ? AppTheme.error
                                    : AppTheme.success),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Event Title
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Organizer
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Organized by ${widget.event.organizer}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date & Time Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.calendar_today_rounded,
                                  color: AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.divider),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.access_time_filled_rounded,
                                  color: AppTheme.secondary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    widget.event.time,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Card with interactive Map button (Device Feature)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  color: AppTheme.error, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Event Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.event.location,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // About Event (Description)
                  const Text(
                    'About this Event',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 100), // spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Registration Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppTheme.divider)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: _isCheckingStatus
              ? const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _isRegistered
                  ? Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppTheme.success),
                          SizedBox(width: 8),
                          Text(
                            'You Are Registered',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : widget.event.isPastEvent
                      ? Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Event Ended',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : widget.event.isFull
                          ? Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Event is Full',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: eventProvider.isActionLoading
                                  ? null
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: eventProvider.isActionLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Register for Event',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
        ),
      ),
    );
  }
}

