class Payment {
  final String id;
  final String customerId;
  final double amount;
  final int bottlesPurchased;
  final DateTime paymentDate;
  final String paymentMethod;
  final String notes;
  
  Payment({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.bottlesPurchased,
    required this.paymentDate,
    required this.paymentMethod,
    this.notes = '',
  });
  
  factory Payment.fromMap(Map<String, dynamic> data, String id) {
    return Payment(
      id: id,
      customerId: data['customerId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      bottlesPurchased: data['bottlesPurchased'] ?? 0,
      paymentDate: data['paymentDate']?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      notes: data['notes'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'amount': amount,
      'bottlesPurchased': bottlesPurchased,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }
}