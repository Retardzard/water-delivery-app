import 'package:flutter/material.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/services/database_service.dart';

class ReportProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, dynamic>? _deliveryStats;
  Map<String, dynamic>? _paymentStats;
  List<Customer> _lowBottleCustomers = [];
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? get deliveryStats => _deliveryStats;
  Map<String, dynamic>? get paymentStats => _paymentStats;
  List<Customer> get lowBottleCustomers => _lowBottleCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get monthly delivery stats
  Future<void> getMonthlyDeliveryStats(DateTime month) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _deliveryStats = await _databaseService.getMonthlyDeliveryStats(month);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Get monthly payment stats
  Future<void> getMonthlyPaymentStats(DateTime month) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _paymentStats = await _databaseService.getMonthlyPaymentStats(month);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Get customers with low bottle count
  void getCustomersWithLowBottles(int threshold) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getCustomersWithLowBottles(threshold).listen((customers) {
      _lowBottleCustomers = customers;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
}