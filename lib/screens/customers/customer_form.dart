import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';
import 'package:water_delivery_app/shared/constants.dart';
import 'package:water_delivery_app/shared/loading.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer; // Null for new customer, non-null for editing
  
  const CustomerForm({super.key, this.customer});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  
  // Form values
  String _name = '';
  String _phone = '';
  String _address = '';
  String _salesRepId = '';
  int _bottlesRemaining = 0;
  int _bottlesPurchased = 0;
  
  // List of sales reps for dropdown
  List<SalesRep> _salesReps = [];
  bool _loadingSalesReps = true;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form values if editing an existing customer
    if (widget.customer != null) {
      _name = widget.customer!.name;
      _phone = widget.customer!.phone;
      _address = widget.customer!.address;
      _salesRepId = widget.customer!.salesRepId;
      _bottlesRemaining = widget.customer!.bottlesRemaining;
      _bottlesPurchased = widget.customer!.bottlesPurchased;
    }
    
    // Load sales reps for dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesReps();
    });
  }
  
  void _loadSalesReps() async {
    final salesRepProvider = Provider.of<SalesRepProvider>(context, listen: false);
    salesRepProvider.initialize();
    setState(() {
      _loadingSalesReps = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final salesRepProvider = Provider.of<SalesRepProvider>(context);
    _salesReps = salesRepProvider.salesReps;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          widget.customer == null ? 'Add Customer' : 'Edit Customer'
        ),
      ),
      body: (_isLoading || _loadingSalesReps) 
        ? const Loading() 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  initialValue: _name,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a name' : null,
                  onChanged: (val) => setState(() => _name = val),
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextFormField(
                  initialValue: _phone,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a phone number' : null,
                  onChanged: (val) => setState(() => _phone = val),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Address Field
                TextFormField(
                  initialValue: _address,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home, color: Colors.blue[700]),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an address' : null,
                  onChanged: (val) => setState(() => _address = val),
                ),
                const SizedBox(height: 16),
                
                // Sales Rep Dropdown
                DropdownButtonFormField<String>(
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Sales Representative',
                    prefixIcon: Icon(Icons.business_center, color: Colors.blue[700]),
                  ),
                  value: _salesRepId.isNotEmpty ? _salesRepId : null,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('-- None --'),
                    ),
                    ..._salesReps.map((rep) {
                      return DropdownMenuItem<String>(
                        value: rep.id,
                        child: Text(rep.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (val) => setState(() => _salesRepId = val ?? ''),
                ),
                const SizedBox(height: 16),
                
                // Bottles Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bottle Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Bottles Remaining Field
                      TextFormField(
                        initialValue: _bottlesRemaining.toString(),
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Bottles Remaining',
                          prefixIcon: Icon(Icons.water_drop, color: Colors.blue[700]),
                        ),
                        validator: (val) {
                          if (val!.isEmpty) return 'Enter bottles remaining';
                          
                          int? bottles = int.tryParse(val);
                          if (bottles == null || bottles < 0) {
                            return 'Enter a valid number';
                          }
                          
                          return null;
                        },
                        onChanged: (val) {
                          int? bottles = int.tryParse(val);
                          if (bottles != null) {
                            setState(() => _bottlesRemaining = bottles);
                          }
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      // Bottles Purchased Field
                      TextFormField(
                        initialValue: _bottlesPurchased.toString(),
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Total Bottles Purchased',
                          prefixIcon: Icon(Icons.shopping_cart, color: Colors.blue[700]),
                        ),
                        validator: (val) {
                          if (val!.isEmpty) return 'Enter bottles purchased';
                          
                          int? bottles = int.tryParse(val);
                          if (bottles == null || bottles < 0) {
                            return 'Enter a valid number';
                          }
                          
                          return null;
                        },
                        onChanged: (val) {
                          int? bottles = int.tryParse(val);
                          if (bottles != null) {
                            setState(() => _bottlesPurchased = bottles);
                          }
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Error message if any
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    widget.customer == null ? 'Add Customer' : 'Update Customer',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        
        if (widget.customer == null) {
          // Creating a new customer
          final newCustomer = Customer(
            id: '',  // Will be set by the database service
            name: _name,
            phone: _phone,
            address: _address,
            salesRepId: _salesRepId,
            bottlesRemaining: _bottlesRemaining,
            bottlesPurchased: _bottlesPurchased,
            createdAt: DateTime.now(),
            lastDelivery: DateTime.now(),
          );
          
          await customerProvider.addCustomer(newCustomer);
        } else {
          // Updating an existing customer
          final updatedCustomer = Customer(
            id: widget.customer!.id,
            name: _name,
            phone: _phone,
            address: _address,
            salesRepId: _salesRepId,
            bottlesRemaining: _bottlesRemaining,
            bottlesPurchased: _bottlesPurchased,
            createdAt: widget.customer!.createdAt,
            lastDelivery: widget.customer!.lastDelivery,
          );
          
          await customerProvider.updateCustomer(updatedCustomer);
        }
        
        // Return to the customers list
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
}