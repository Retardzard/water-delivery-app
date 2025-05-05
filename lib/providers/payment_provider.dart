import 'package:flutter/material.dart';
import 'package:water_delivery_app/models/payment.dart';
import 'package:water_delivery_app/services/database_service.dart';

class PaymentProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;
  
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get recent payments
  void getRecentPayments({int limit = 10}) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getRecentPayments(limit: limit).listen((paymentList) {
      _payments = paymentList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Get payments for a specific customer
  void getPaymentsForCustomer(String customerId) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getPaymentsForCustomer(customerId).listen((paymentList) {
      _payments = paymentList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Record a new payment
  Future<String?> recordPayment(Payment payment) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final id = await _databaseService.recordPayment(payment);
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}