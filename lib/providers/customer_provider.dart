import 'package:flutter/material.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/services/database_service.dart';

class CustomerProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize the provider by listening to the customers stream
  void initialize() {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.customers.listen((customersList) {
      _customers = customersList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Get customers by sales rep
  void getCustomersBySalesRep(String salesRepId) {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.getCustomersBySalesRep(salesRepId).listen((customersList) {
      _customers = customersList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Get a specific customer
  Future<Customer?> getCustomer(String id) async {
    try {
      return await _databaseService.getCustomer(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Add a new customer
  Future<String?> addCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final id = await _databaseService.createCustomer(customer);
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
  
  // Update an existing customer
  Future<bool> updateCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.updateCustomer(customer);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Delete a customer
  Future<bool> deleteCustomer(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.deleteCustomer(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}