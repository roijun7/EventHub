import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String eventId;
  final String eventTitle;
  final DateTime eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventCategory;
  final String eventImageUrl;
  final DateTime registeredAt;
  final String status; // 'confirmed' or 'cancelled'

  RegistrationModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.eventCategory,
    required this.eventImageUrl,
    required this.registeredAt,
    this.status = 'confirmed',
  });

  bool get isCancelled => status == 'cancelled';

  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseDate(dynamic field) {
      if (field is Timestamp) return field.toDate();
      if (field is String) return DateTime.tryParse(field) ?? DateTime.now();
      return DateTime.now();
    }

    return RegistrationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? 'Student',
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? 'Event',
      eventDate: parseDate(data['eventDate']),
      eventTime: data['eventTime'] ?? '',
      eventLocation: data['eventLocation'] ?? '',
      eventCategory: data['eventCategory'] ?? 'General',
      eventImageUrl: data['eventImageUrl'] ?? '',
      registeredAt: parseDate(data['registeredAt']),
      status: data['status'] ?? 'confirmed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'eventLocation': eventLocation,
      'eventCategory': eventCategory,
      'eventImageUrl': eventImageUrl,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'status': status,
    };
  }
}
