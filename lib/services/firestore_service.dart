import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../utils/seed_data.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  CollectionReference get _eventsCollection => _firestore.collection('events');
  CollectionReference get _registrationsCollection =>
      _firestore.collection('registrations');

  /// Seeds initial events if the database has no events
  Future<void> checkAndSeedInitialEvents() async {
    try {
      final snapshot = await _eventsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('Events collection is empty. Seeding sample events...');
        final batch = _firestore.batch();
        final seedEvents = SeedData.getInitialEvents();

        for (final eventData in seedEvents) {
          final docRef = _eventsCollection.doc();
          batch.set(docRef, eventData);
        }

        await batch.commit();
        debugPrint('Seeded ${seedEvents.length} events successfully.');
      }
    } catch (e) {
      debugPrint('Error seeding events: $e');
    }
  }

  /// Real-time stream of all events or filtered by category
  Stream<List<EventModel>> getEventsStream({
    String? category,
    bool includePast = false,
  }) {
    Query query = _eventsCollection;

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final events =
          snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();

      // Sort by date ascending (upcoming first)
      events.sort((a, b) => a.date.compareTo(b.date));

      if (!includePast) {
        // Filter out completed / past events
        return events.where((e) => !e.isPastEvent).toList();
      }

      return events;
    });
  }

  /// Real-time stream of completed / past events (Event History)
  Stream<List<EventModel>> getCompletedEventsStream() {
    return _eventsCollection.snapshots().map((snapshot) {
      final events =
          snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();

      // Filter only past or completed events
      final pastEvents = events.where((e) => e.isPastEvent).toList();

      // Sort most recent past event first
      pastEvents.sort((a, b) => b.date.compareTo(a.date));
      return pastEvents;
    });
  }

  /// Stream of user registrations
  Stream<List<RegistrationModel>> getUserRegistrationsStream(String userId) {
    return _registrationsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => RegistrationModel.fromFirestore(doc))
          .toList();

      // Sort by event date
      list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return list;
    });
  }

  /// Check if student is already registered for an event
  Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      final query = await _registrationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking user registration: $e');
      return false;
    }
  }

  /// Register student for an event
  Future<void> registerForEvent({
    required EventModel event,
    required User user,
  }) async {
    // 1. Check if event is in the past
    if (event.isPastEvent) {
      throw 'This event has already ended.';
    }

    // 2. Check if event is full
    if (event.isFull) {
      throw 'Sorry, this event is already at full capacity.';
    }

    // 3. Check if already registered
    final alreadyRegistered = await isUserRegistered(event.id, user.uid);
    if (alreadyRegistered) {
      throw 'You are already registered for this event!';
    }

    // 4. Create registration record in Firestore
    final regRef = _registrationsCollection.doc();
    final registration = RegistrationModel(
      id: regRef.id,
      userId: user.uid,
      userEmail: user.email ?? '',
      userName: user.displayName ??
          (user.email != null ? user.email!.split('@')[0] : 'Student'),
      eventId: event.id,
      eventTitle: event.title,
      eventDate: event.date,
      eventTime: event.time,
      eventLocation: event.location,
      eventCategory: event.category,
      eventImageUrl: event.imageUrl,
      registeredAt: DateTime.now(),
      status: 'confirmed',
    );

    await regRef.set(registration.toMap());

    // 5. Increment registered count in event doc
    await _eventsCollection.doc(event.id).update({
      'registeredCount': FieldValue.increment(1),
    });

    // 6. Trigger device notifications: instant confirmation & scheduled reminder
    await _notificationService.showRegistrationConfirmation(
      eventTitle: event.title,
      eventDate: event.date,
      eventLocation: event.location,
    );

    await _notificationService.scheduleEventReminder(
      notificationId: event.id.hashCode,
      eventTitle: event.title,
      eventDate: event.date,
      eventLocation: event.location,
    );
  }

  /// Cancel an existing registration
  Future<void> cancelRegistration({
    required String registrationId,
    required String eventId,
    required String eventTitle,
  }) async {
    // 1. Update registration status in Firestore
    await _registrationsCollection.doc(registrationId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    // 2. Decrement registered count
    await _eventsCollection.doc(eventId).update({
      'registeredCount': FieldValue.increment(-1),
    });

    // 3. Cancel scheduled notification reminder
    await _notificationService.cancelNotification(eventId.hashCode);

    // 4. Send cancellation alert notification
    await _notificationService.showCancellationNotice(eventTitle: eventTitle);
  }
}
