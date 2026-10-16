import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isActionLoading = false;
  String? _actionError;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isActionLoading => _isActionLoading;
  String? get actionError => _actionError;

  static const List<String> categories = [
    'All',
    'Academic',
    'Sports',
    'Seminar',
    'Organization',
    'Entertainment',
    'Workshop',
  ];

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _actionError = null;
    notifyListeners();
  }

  /// Initialize database and check for seed data
  Future<void> initializeData() async {
    await _firestoreService.checkAndSeedInitialEvents();
  }

  /// Stream of upcoming events
  Stream<List<EventModel>> getEventsStream() {
    return _firestoreService.getEventsStream(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      includePast: false,
    );
  }

  /// Stream of past/completed events (Event History)
  Stream<List<EventModel>> getCompletedEventsStream() {
    return _firestoreService.getCompletedEventsStream();
  }

  /// Stream of user registrations (My Events)
  Stream<List<RegistrationModel>> getUserRegistrationsStream(String userId) {
    return _firestoreService.getUserRegistrationsStream(userId);
  }

  /// Check if user is registered for an event
  Future<bool> isUserRegistered(String eventId, String userId) {
    return _firestoreService.isUserRegistered(eventId, userId);
  }

  /// Register current student for an event
  Future<bool> registerForEvent(EventModel event, User user) async {
    _isActionLoading = true;
    _actionError = null;
    notifyListeners();

    try {
      await _firestoreService.registerForEvent(event: event, user: user);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel student registration
  Future<bool> cancelRegistration({
    required String registrationId,
    required String eventId,
    required String eventTitle,
  }) async {
    _isActionLoading = true;
    _actionError = null;
    notifyListeners();

    try {
      await _firestoreService.cancelRegistration(
        registrationId: registrationId,
        eventId: eventId,
        eventTitle: eventTitle,
      );
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
