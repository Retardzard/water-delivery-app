import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/models/delivery.dart';
import 'package:water_delivery_app/models/payment.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = Uuid();
  
  // Collection references
  final CollectionReference customersCollection = 
      FirebaseFirestore.instance.collection('customers');
  
  final CollectionReference salesRepsCollection = 
      FirebaseFirestore.instance.collection('salesReps');
  
  // SALES REP METHODS
  
  // Get all sales reps
  Stream<List<SalesRep>> get salesReps {
    return salesRepsCollection.snapshots().map(_salesRepListFromSnapshot);
  }
  
  // Get sales rep by ID
  Future<SalesRep?> getSalesRep(String id) async {
    DocumentSnapshot doc = await salesRepsCollection.doc(id).get();
    
    if (doc.exists) {
      return SalesRep.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    
    return null;
  }
  
  // Create sales rep
  Future<String> createSalesRep(SalesRep salesRep) async {
    String id = uuid.v4();
    
    await salesRepsCollection.doc(id).set({
      'name': salesRep.name,
      'phone': salesRep.phone,
      'email': salesRep.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return id;
  }
  
  // Update sales rep
  Future<void> updateSalesRep(SalesRep salesRep) async {
    await salesRepsCollection.doc(salesRep.id).update({
      'name': salesRep.name,
      'phone': salesRep.phone,
      'email': salesRep.email,
    });
  }
  
  // Delete sales rep
  Future<void> deleteSalesRep(String id) async {
    // First, update any customers assigned to this sales rep
    QuerySnapshot customers = await customersCollection
        .where('salesRepId', isEqualTo: id)
        .get();
    
    WriteBatch batch = _firestore.batch();
    
    for (var doc in customers.docs) {
      batch.update(doc.reference, {'salesRepId': ''});
    }
    
    // Then delete the sales rep
    batch.delete(salesRepsCollection.doc(id));
    
    await batch.commit();
  }
  
  // CUSTOMER METHODS
  
  // Get all customers
  Stream<List<Customer>> get customers {
    return customersCollection.snapshots().map(_customerListFromSnapshot);
  }
  
  // Get customers by sales rep
  Stream<List<Customer>> getCustomersBySalesRep(String salesRepId) {
    return customersCollection
        .where('salesRepId', isEqualTo: salesRepId)
        .snapshots()
        .map(_customerListFromSnapshot);
  }
  
  // Get customer by ID
  Future<Customer?> getCustomer(String id) async {
    DocumentSnapshot doc = await customersCollection.doc(id).get();
    
    if (doc.exists) {
      return Customer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    
    return null;
  }
  
  // Create customer
  Future<String> createCustomer(Customer customer) async {
    String id = uuid.v4();
    
    await customersCollection.doc(id).set({
      'name': customer.name,
      'phone': customer.phone,
      'address': customer.address,
      'salesRepId': customer.salesRepId,
      'bottlesRemaining': customer.bottlesRemaining,
      'bottlesPurchased': customer.bottlesPurchased,
      'createdAt': FieldValue.serverTimestamp(),
      'lastDelivery': FieldValue.serverTimestamp(),
    });
    
    return id;
  }
  
  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    await customersCollection.doc(customer.id).update({
      'name': customer.name,
      'phone': customer.phone,
      'address': customer.address,
      'salesRepId': customer.salesRepId,
      'bottlesRemaining': customer.bottlesRemaining,
      'bottlesPurchased': customer.bottlesPurchased,
    });
  }
  
  // Delete customer
  Future<void> deleteCustomer(String id) async {
    await customersCollection.doc(id).delete();
  }
  
  // DELIVERY METHODS

  // Record a new delivery
  Future<String> recordDelivery(Delivery delivery) async {
    String id = uuid.v4();
    
    // Create transaction to update both delivery and customer
    final WriteBatch batch = _firestore.batch();
    
    // Add the delivery document
    DocumentReference deliveryRef = _firestore.collection('deliveries').doc(id);
    batch.set(deliveryRef, {
      'customerId': delivery.customerId,
      'bottlesDelivered': delivery.bottlesDelivered,
      'deliveryDate': FieldValue.serverTimestamp(),
      'notes': delivery.notes,
    });
    
    // Update the customer's bottlesRemaining and lastDelivery
    DocumentReference customerRef = _firestore.collection('customers').doc(delivery.customerId);
    DocumentSnapshot customerDoc = await customerRef.get();
    
    if (customerDoc.exists) {
      Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;
      int currentBottles = customerData['bottlesRemaining'] ?? 0;
      int newBottles = currentBottles - delivery.bottlesDelivered;
      
      // Ensure bottles don't go negative
      newBottles = newBottles < 0 ? 0 : newBottles;
      
      batch.update(customerRef, {
        'bottlesRemaining': newBottles,
        'lastDelivery': FieldValue.serverTimestamp(),
      });
    }
    
    // Commit the transaction
    await batch.commit();
    
    return id;
  }

  // Get deliveries for a specific customer
  Stream<List<Delivery>> getDeliveriesForCustomer(String customerId) {
    return _firestore
        .collection('deliveries')
        .where('customerId', isEqualTo: customerId)
        .orderBy('deliveryDate', descending: true)
        .snapshots()
        .map(_deliveryListFromSnapshot);
  }

  // Get recent deliveries
  Stream<List<Delivery>> getRecentDeliveries({int limit = 10}) {
    return _firestore
        .collection('deliveries')
        .orderBy('deliveryDate', descending: true)
        .limit(limit)
        .snapshots()
        .map(_deliveryListFromSnapshot);
  }

  // PAYMENT METHODS

  // Record a new payment
  Future<String> recordPayment(Payment payment) async {
    String id = uuid.v4();
    
    // Create transaction to update both payment and customer
    final WriteBatch batch = _firestore.batch();
    
    // Add the payment document
    DocumentReference paymentRef = _firestore.collection('payments').doc(id);
    batch.set(paymentRef, {
      'customerId': payment.customerId,
      'amount': payment.amount,
      'bottlesPurchased': payment.bottlesPurchased,
      'paymentDate': FieldValue.serverTimestamp(),
      'paymentMethod': payment.paymentMethod,
      'notes': payment.notes,
    });
    
    // Update the customer's bottlesRemaining and bottlesPurchased
    DocumentReference customerRef = _firestore.collection('customers').doc(payment.customerId);
    DocumentSnapshot customerDoc = await customerRef.get();
    
    if (customerDoc.exists) {
      Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;
      int currentBottles = customerData['bottlesRemaining'] ?? 0;
      int totalPurchased = customerData['bottlesPurchased'] ?? 0;
      
      batch.update(customerRef, {
        'bottlesRemaining': currentBottles + payment.bottlesPurchased,
        'bottlesPurchased': totalPurchased + payment.bottlesPurchased,
      });
    }
    
    // Commit the transaction
    await batch.commit();
    
    return id;
  }

  // Get payments for a specific customer
  Stream<List<Payment>> getPaymentsForCustomer(String customerId) {
    return _firestore
        .collection('payments')
        .where('customerId', isEqualTo: customerId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(_paymentListFromSnapshot);
  }

  // Get recent payments
  Stream<List<Payment>> getRecentPayments({int limit = 10}) {
    return _firestore
        .collection('payments')
        .orderBy('paymentDate', descending: true)
        .limit(limit)
        .snapshots()
        .map(_paymentListFromSnapshot);
  }

  // REPORTING METHODS

  // Get monthly delivery stats
  Future<Map<String, dynamic>> getMonthlyDeliveryStats(DateTime month) async {
    // Get first and last day of the month
    final DateTime firstDay = DateTime(month.year, month.month, 1);
    final DateTime lastDay = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    
    final Timestamp startTimestamp = Timestamp.fromDate(firstDay);
    final Timestamp endTimestamp = Timestamp.fromDate(lastDay);
    
    // Get all deliveries for the month
    final QuerySnapshot deliverySnapshot = await _firestore
        .collection('deliveries')
        .where('deliveryDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('deliveryDate', isLessThan: endTimestamp)
        .get();
    
    // Calculate total bottles delivered
    int totalBottles = 0;
    Map<String, int> customerDeliveries = {};
    
    for (var doc in deliverySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      int bottles = data['bottlesDelivered'] ?? 0;
      String customerId = data['customerId'] ?? '';
      
      totalBottles += bottles;
      
      if (customerId.isNotEmpty) {
        customerDeliveries[customerId] = (customerDeliveries[customerId] ?? 0) + bottles;
      }
    }
    
    // Get total number of unique customers served
    int uniqueCustomers = customerDeliveries.keys.length;
    
    // Get top customers
    List<MapEntry<String, int>> sortedCustomers = customerDeliveries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    List<String> topCustomerIds = sortedCustomers.take(5).map((e) => e.key).toList();
    
    // Return statistics
    return {
      'totalBottlesDelivered': totalBottles,
      'uniqueCustomersServed': uniqueCustomers,
      'topCustomerIds': topCustomerIds,
    };
  }

  // Get monthly payment stats
  Future<Map<String, dynamic>> getMonthlyPaymentStats(DateTime month) async {
    // Get first and last day of the month
    final DateTime firstDay = DateTime(month.year, month.month, 1);
    final DateTime lastDay = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    
    final Timestamp startTimestamp = Timestamp.fromDate(firstDay);
    final Timestamp endTimestamp = Timestamp.fromDate(lastDay);
    
    // Get all payments for the month
    final QuerySnapshot paymentSnapshot = await _firestore
        .collection('payments')
        .where('paymentDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('paymentDate', isLessThan: endTimestamp)
        .get();
    
    // Calculate total revenue and bottles purchased
    double totalRevenue = 0;
    int totalBottlesPurchased = 0;
    Map<String, double> customerPayments = {};
    
    for (var doc in paymentSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      double amount = (data['amount'] ?? 0).toDouble();
      int bottles = data['bottlesPurchased'] ?? 0;
      String customerId = data['customerId'] ?? '';
      
      totalRevenue += amount;
      totalBottlesPurchased += bottles;
      
      if (customerId.isNotEmpty) {
        customerPayments[customerId] = (customerPayments[customerId] ?? 0) + amount;
      }
    }
    
    // Get top paying customers
    List<MapEntry<String, double>> sortedCustomers = customerPayments.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    List<String> topPayingCustomerIds = sortedCustomers.take(5).map((e) => e.key).toList();
    
    // Return statistics
    return {
      'totalRevenue': totalRevenue,
      'totalBottlesPurchased': totalBottlesPurchased,
      'topPayingCustomerIds': topPayingCustomerIds,
    };
  }

  // Get customers with low bottle count
  Stream<List<Customer>> getCustomersWithLowBottles(int threshold) {
    return _firestore
        .collection('customers')
        .where('bottlesRemaining', isLessThanOrEqualTo: threshold)
        .snapshots()
        .map(_customerListFromSnapshot);
  }

  // Helper methods to convert snapshots to objects
  List<SalesRep> _salesRepListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return SalesRep.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id
      );
    }).toList();
  }
  
  List<Customer> _customerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Customer.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id
      );
    }).toList();
  }
  
  // Helper method to convert snapshot to Delivery list
  List<Delivery> _deliveryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Delivery.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id
      );
    }).toList();
  }

  // Helper method to convert snapshot to Payment list
  List<Payment> _paymentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Payment.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id
      );
    }).toList();
  }
}