// lib/models/customer.dart (if missing)
class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String salesRepId;
  final int bottlesRemaining;
  final int bottlesPurchased;
  final DateTime createdAt;
  final DateTime lastDelivery;
  
  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.salesRepId,
    required this.bottlesRemaining,
    required this.bottlesPurchased,
    required this.createdAt,
    required this.lastDelivery,
  });
  
  factory Customer.fromMap(Map<String, dynamic> data, String id) {
    return Customer(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      salesRepId: data['salesRepId'] ?? '',
      bottlesRemaining: data['bottlesRemaining'] ?? 0,
      bottlesPurchased: data['bottlesPurchased'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastDelivery: data['lastDelivery']?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'salesRepId': salesRepId,
      'bottlesRemaining': bottlesRemaining,
      'bottlesPurchased': bottlesPurchased,
      'createdAt': createdAt,
      'lastDelivery': lastDelivery,
    };
  }
  
  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    String? salesRepId,
    int? bottlesRemaining,
    int? bottlesPurchased,
    DateTime? lastDelivery,
  }) {
    return Customer(
      id: this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      salesRepId: salesRepId ?? this.salesRepId,
      bottlesRemaining: bottlesRemaining ?? this.bottlesRemaining,
      bottlesPurchased: bottlesPurchased ?? this.bottlesPurchased,
      createdAt: this.createdAt,
      lastDelivery: lastDelivery ?? this.lastDelivery,
    );
  }
}