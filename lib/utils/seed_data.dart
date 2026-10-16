import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static List<Map<String, dynamic>> getInitialEvents() {
    final now = DateTime.now();

    return [
      {
        'title': 'AI & Flutter Innovation Hackathon',
        'description':
            'Join fellow students for a 24-hour coding challenge! Build cutting-edge applications using Flutter, Firebase, and AI APIs. Mentors from top tech companies will be on-site to guide your team. Prizes, swag, and food provided.',
        'category': 'Academic',
        'date': Timestamp.fromDate(now.add(const Duration(days: 4, hours: 3))),
        'time': '9:00 AM - 5:00 PM',
        'location': 'University Innovation Lab, Building C',
        'geoQuery': 'University Innovation Lab',
        'imageUrl':
            'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=800&q=80',
        'capacity': 120,
        'registeredCount': 35,
        'organizer': 'Computer Science Student Society',
        'isCompleted': false,
      },
      {
        'title': 'Tech Careers & Industry Roadmap Seminar',
        'description':
            'A keynote seminar featuring senior engineers and tech alumni sharing insider strategies on landing internships, preparing portfolios, passing technical interviews, and navigating the future of software development.',
        'category': 'Seminar',
        'date': Timestamp.fromDate(now.add(const Duration(days: 8, hours: 2))),
        'time': '1:30 PM - 4:00 PM',
        'location': 'University Grand Auditorium',
        'geoQuery': 'University Grand Auditorium',
        'imageUrl':
            'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?auto=format&fit=crop&w=800&q=80',
        'capacity': 250,
        'registeredCount': 89,
        'organizer': 'Student Affairs & Career Placement',
        'isCompleted': false,
      },
      {
        'title': 'Inter-College Basketball Championship Finals',
        'description':
            'Cheer for your college in the most anticipated sporting event of the semester! Watch the Engineering Titans face off against the Business Wolves in a battle for the varsity championship trophy.',
        'category': 'Sports',
        'date': Timestamp.fromDate(now.add(const Duration(days: 12, hours: 5))),
        'time': '4:00 PM - 7:30 PM',
        'location': 'University Sports Complex Gymnasium',
        'geoQuery': 'University Sports Complex',
        'imageUrl':
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80',
        'capacity': 500,
        'registeredCount': 312,
        'organizer': 'Athletics & Recreation Council',
        'isCompleted': false,
      },
      {
        'title': 'Student Organization Leadership Summit',
        'description':
            'Empowering future campus leaders. Interactive workshops on project management, conflict resolution, budget handling, and student body advocacy. Open to all active officers and aspiring student leaders.',
        'category': 'Organization',
        'date': Timestamp.fromDate(now.add(const Duration(days: 15, hours: 1))),
        'time': '10:00 AM - 3:00 PM',
        'location': 'Student Activity Center, Hall 2',
        'geoQuery': 'Student Activity Center',
        'imageUrl':
            'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=800&q=80',
        'capacity': 80,
        'registeredCount': 22,
        'organizer': 'Federation of Student Organizations',
        'isCompleted': false,
      },
      {
        'title': 'Campus Beats Music & Arts Festival',
        'description':
            'Celebrate campus creativity with live performances by student bands, art exhibitions, street food stalls, and an evening acoustic jam. Bring your friends and picnic mats!',
        'category': 'Entertainment',
        'date': Timestamp.fromDate(now.add(const Duration(days: 20, hours: 6))),
        'time': '5:00 PM - 10:00 PM',
        'location': 'Open Field & Amphitheater',
        'geoQuery': 'University Amphitheater',
        'imageUrl':
            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80',
        'capacity': 600,
        'registeredCount': 190,
        'organizer': 'Cultural Arts Student Guild',
        'isCompleted': false,
      },
      {
        'title': 'UI/UX Design Masterclass & Prototyping',
        'description':
            'Hands-on design workshop covering design systems, Figma workflows, student portfolio building, and user research methodologies. Please bring your laptop with Figma installed.',
        'category': 'Workshop',
        'date': Timestamp.fromDate(now.add(const Duration(days: 25, hours: 4))),
        'time': '10:00 AM - 1:00 PM',
        'location': 'Media Arts Computer Lab 4B',
        'geoQuery': 'Media Arts Lab',
        'imageUrl':
            'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?auto=format&fit=crop&w=800&q=80',
        'capacity': 40,
        'registeredCount': 18,
        'organizer': 'Digital Media Design Society',
        'isCompleted': false,
      },
      // Completed Events (for Event History)
      {
        'title': 'Freshmen Welcome Rally & Campus Tour',
        'description':
            'Annual orientation event welcoming all newly admitted university students. Included university tradition briefings, department showcases, and campus tours.',
        'category': 'Seminar',
        'date': Timestamp.fromDate(now.subtract(const Duration(days: 14))),
        'time': '8:00 AM - 12:00 PM',
        'location': 'University Quadrangle',
        'geoQuery': 'University Quadrangle',
        'imageUrl':
            'https://images.unsplash.com/photo-1523580494863-6f3031224c94?auto=format&fit=crop&w=800&q=80',
        'capacity': 800,
        'registeredCount': 740,
        'organizer': 'Student Orientation Committee',
        'isCompleted': true,
      },
      {
        'title': 'Annual Inter-Department Chess Blitz',
        'description':
            'Fast-paced 5-minute blitz chess tournament among students across engineering, science, business, and humanities departments.',
        'category': 'Sports',
        'date': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'time': '1:00 PM - 5:00 PM',
        'location': 'Student Lounge, 3rd Floor',
        'geoQuery': 'Student Lounge',
        'imageUrl':
            'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?auto=format&fit=crop&w=800&q=80',
        'capacity': 64,
        'registeredCount': 64,
        'organizer': 'University Chess Club',
        'isCompleted': true,
      },
    ];
  }
}
