import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String time;
  final String location;
  final String? geoQuery;
  final String imageUrl;
  final int capacity;
  final int registeredCount;
  final String organizer;
  final bool isCompleted;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    this.geoQuery,
    required this.imageUrl,
    this.capacity = 100,
    this.registeredCount = 0,
    this.organizer = 'Student Affairs Office',
    this.isCompleted = false,
  });

  bool get isPastEvent {
    if (isCompleted) return true;
    final now = DateTime.now();
    // Compare date; if event date was yesterday or earlier, consider it completed/past
    final endOfEventDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return now.isAfter(endOfEventDay);
  }

  bool get isFull => registeredCount >= capacity;

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return EventModel(
      id: doc.id,
      title: data['title'] ?? data['name'] ?? 'Untitled Event',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      date: parsedDate,
      time: data['time'] ?? 'TBA',
      location: data['location'] ?? 'Campus',
      geoQuery: data['geoQuery'] ?? data['location'],
      imageUrl: data['imageUrl'] ?? data['image'] ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 100,
      registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
      organizer: data['organizer'] ?? 'Campus Organization',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'geoQuery': geoQuery ?? location,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'organizer': organizer,
      'isCompleted': isCompleted,
    };
  }
}
