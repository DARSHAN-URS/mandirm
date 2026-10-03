class DevoteeDataService {
  static final DevoteeDataService _instance = DevoteeDataService._internal();
  factory DevoteeDataService() => _instance;
  DevoteeDataService._internal();

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'MND-8941',
      'title': 'Maha Rudrabhishek with 108 Bilva Patra',
      'mandir': 'Kashi Vishwanath Mandir, Varanasi',
      'date': 'Tomorrow, 08:00 AM',
      'amount': '₹ 1,100',
      'status': 'Confirmed',
      'gotra': 'Kashyap',
      'devoteeName': 'Sunil Kumar',
      'pandit': 'Pt. Ramakant Shastri',
      'prasadTracking': 'IP89341209IN',
      'prasadStatus': 'Dispatched',
    },
    {
      'id': 'MND-7822',
      'title': 'Sankat Mochan Hanuman Chalisa Path',
      'mandir': 'Hanuman Garhi, Ayodhya',
      'date': '12 Sep 2026',
      'amount': '₹ 501',
      'status': 'Completed',
      'gotra': 'Bharadwaja',
      'devoteeName': 'Sunil Kumar',
      'pandit': 'Pt. Keshav Das',
      'prasadTracking': 'IP77123901IN',
      'prasadStatus': 'Delivered',
      'hasRecording': true,
    },
  ];

  final List<Map<String, dynamic>> _consultations = [
    {
      'id': 'CNS-3021',
      'astrologerName': 'Pt. Devendra Shastri',
      'specialty': 'Vedic • Kundali • Vastu',
      'date': 'Yesterday, 04:15 PM',
      'duration': '12 mins',
      'amount': '₹ 300',
      'remedy': 'Chant Om Namah Shivaya 108 times daily; donate black sesame on Saturdays.',
      'rating': 5.0,
    },
  ];

  final List<Map<String, dynamic>> _prasadOrders = [
    {
      'id': 'PRS-9012',
      'title': 'Mahakaleshwar Bhasma & Dry Fruit Prasad Box',
      'mandir': 'Mahakaleshwar Jyotirlinga, Ujjain',
      'orderDate': '24 Sep 2026',
      'status': 'In Transit',
      'currentStep': 2, // 0: Packed, 1: Dispatched, 2: In Transit, 3: Delivered
      'trackingNumber': 'BLUEDART-8891230',
      'carrier': 'BlueDart Express',
      'expectedDelivery': 'Tomorrow, by 05:00 PM',
      'address': 'Flat 402, Shanti Vihar, Mumbai, Maharashtra 400050',
    },
    {
      'id': 'PRS-8109',
      'title': 'Tirupati Laddu Prasadam & Raksha Sutra',
      'mandir': 'Tirupati Balaji Mandir, AP',
      'orderDate': '15 Sep 2026',
      'status': 'Delivered',
      'currentStep': 3,
      'trackingNumber': 'IP77123901IN',
      'carrier': 'India Post SpeedPost',
      'expectedDelivery': 'Delivered on 18 Sep 2026',
      'address': 'Flat 402, Shanti Vihar, Mumbai, Maharashtra 400050',
    },
  ];

  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);
  List<Map<String, dynamic>> get consultations => List.unmodifiable(_consultations);
  List<Map<String, dynamic>> get prasadOrders => List.unmodifiable(_prasadOrders);

  void addBooking(Map<String, dynamic> booking) {
    // Avoid duplicate booking ID
    _bookings.removeWhere((b) => b['id'] == booking['id']);
    _bookings.insert(0, booking);
  }

  void addConsultation(Map<String, dynamic> consultation) {
    _consultations.removeWhere((c) => c['id'] == consultation['id']);
    _consultations.insert(0, consultation);
  }

  void addPrasadOrder(Map<String, dynamic> order) {
    _prasadOrders.removeWhere((o) => o['id'] == order['id']);
    _prasadOrders.insert(0, order);
  }

  void syncBackendBookings(List<Map<String, dynamic>> backendList) {
    for (final b in backendList) {
      final id = b['id']?.toString() ?? 'BK-${b.hashCode}';
      if (!_bookings.any((item) => item['id'] == id)) {
        _bookings.add({
          'id': id,
          'title': b['puja_name'] ?? b['title'] ?? 'Vedic Puja Ritual',
          'mandir': b['temple_name'] ?? b['mandir'] ?? 'Sacred Temple Sanctum',
          'date': b['date'] ?? 'Scheduled',
          'amount': '₹${b['amount'] ?? 1100}',
          'status': b['status'] ?? 'Confirmed',
          'gotra': b['gotra'] ?? 'Devotee Gotra',
          'devoteeName': b['devotee_name'] ?? 'Devotee',
          'pandit': b['pandit_name'] ?? 'Verified Mandirm Acharya',
          'prasadTracking': b['tracking_id'] ?? 'IN${DateTime.now().millisecondsSinceEpoch % 10000000}POST',
          'prasadStatus': b['prasad_status'] ?? 'In Preparation',
        });
      }
    }
  }

  void syncBackendConsultations(List<Map<String, dynamic>> backendList) {
    for (final c in backendList) {
      final id = c['id']?.toString() ?? 'CNS-${c.hashCode}';
      if (!_consultations.any((item) => item['id'] == id)) {
        _consultations.add({
          'id': id,
          'astrologerName': c['astrologer_name'] ?? 'Vedic Astrologer',
          'specialty': c['specialty'] ?? 'Vedic • Kundali',
          'date': c['date'] ?? 'Recent Session',
          'duration': '${c['duration_minutes'] ?? 15} mins',
          'amount': '₹${c['amount'] ?? 300}',
          'remedy': c['notes'] ?? c['remedy'] ?? 'Chant Gayatri Mantra daily for peace and clarity.',
          'rating': (c['rating'] as num?)?.toDouble() ?? 5.0,
        });
      }
    }
  }

  void syncBackendOrders(List<Map<String, dynamic>> backendList) {
    for (final o in backendList) {
      final id = o['id']?.toString() ?? 'ORD-${o.hashCode}';
      if (!_prasadOrders.any((item) => item['id'] == id)) {
        _prasadOrders.add({
          'id': id,
          'title': o['item_name'] ?? o['title'] ?? 'Sacred Item',
          'mandir': o['source_temple'] ?? o['mandir'] ?? 'Mandirm Divine Store',
          'orderDate': o['order_date'] ?? 'Recent',
          'status': o['status'] ?? 'In Transit',
          'currentStep': (o['step'] as int?) ?? 1,
          'trackingNumber': o['tracking_no'] ?? 'BLUEDART-${DateTime.now().millisecondsSinceEpoch % 1000000}',
          'carrier': o['carrier'] ?? 'BlueDart Express',
          'expectedDelivery': o['delivery_eta'] ?? 'In 2-3 Days',
          'address': o['address'] ?? 'Home Address',
        });
      }
    }
  }
}
