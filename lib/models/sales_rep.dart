class SalesRep {
  final String id;
  final String name;
  final String phone;
  final String email;
  final DateTime createdAt;
  
  SalesRep({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.createdAt,
  });
  
  factory SalesRep.fromMap(Map<String, dynamic> data, String id) {
    return SalesRep(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': createdAt,
    };
  }
}