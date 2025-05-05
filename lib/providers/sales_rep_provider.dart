import 'package:flutter/material.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/services/database_service.dart';

class SalesRepProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<SalesRep> _salesReps = [];
  bool _isLoading = false;
  String? _error;
  
  List<SalesRep> get salesReps => _salesReps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize the provider by listening to the sales reps stream
  void initialize() {
    _isLoading = true;
    notifyListeners();
    
    _databaseService.salesReps.listen((salesRepsList) {
      _salesReps = salesRepsList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    });
  }
  
  // Get a specific sales rep
  Future<SalesRep?> getSalesRep(String id) async {
    try {
      return await _databaseService.getSalesRep(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Add a new sales rep
  Future<String?> addSalesRep(SalesRep salesRep) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final id = await _databaseService.createSalesRep(salesRep);
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
  
  // Update an existing sales rep
  Future<bool> updateSalesRep(SalesRep salesRep) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.updateSalesRep(salesRep);
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
  
  // Delete a sales rep
  Future<bool> deleteSalesRep(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.deleteSalesRep(id);
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