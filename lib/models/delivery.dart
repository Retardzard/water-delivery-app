class Delivery {
  final String id;
  final String customerId;
  final int bottlesDelivered;
  final DateTime deliveryDate;
  final String notes;
  
  Delivery({
    required this.id,
    required this.customerId,
    required this.bottlesDelivered,
    required this.deliveryDate,
    this.notes = '',
  });
  
  factory Delivery.fromMap(Map<String, dynamic> data, String id) {
    return Delivery(
      id: id,
      customerId: data['customerId'] ?? '',
      bottlesDelivered: data['bottlesDelivered'] ?? 0,
      deliveryDate: data['deliveryDate']?.toDate() ?? DateTime.now(),
      notes: data['notes'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'bottlesDelivered': bottlesDelivered,
      'deliveryDate': deliveryDate,
      'notes': notes,
    };
  }
}