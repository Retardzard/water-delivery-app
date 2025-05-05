import 'package:flutter/material.dart';
import 'package:water_delivery_app/models/delivery.dart';
import 'package:water_delivery_app/services/database_service.dart';

class DeliveryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Delivery> _deliveries = [];
  bool _isLoading = false;
  String? _error;
  
  List<Delivery> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get recent deliveries
  void getRecentDeliveries({int limit = 10}) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getRecentDeliveries(limit: limit).listen((deliveryList) {
      _deliveries = deliveryList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Get deliveries for a specific customer
  void getDeliveriesForCustomer(String customerId) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getDeliveriesForCustomer(customerId).listen((deliveryList) {
      _deliveries = deliveryList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Record a new delivery
  Future<String?> recordDelivery(Delivery delivery) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final id = await _databaseService.recordDelivery(delivery);
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