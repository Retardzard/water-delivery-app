import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';
import 'package:water_delivery_app/screens/customers/customer_form.dart';
import 'package:water_delivery_app/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:water_delivery_app/screens/deliveries/delivery_form.dart';
import 'package:water_delivery_app/screens/payments/payment_form.dart';
import 'package:water_delivery_app/screens/deliveries/delivery_history.dart';
import 'package:water_delivery_app/screens/payments/payment_history.dart';


class CustomerDetail extends StatefulWidget {
  final Customer customer;
  
  const CustomerDetail({super.key, required this.customer});

  @override
  State<CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
  bool _isLoading = false;
  bool _loadingSalesRep = true;
  String? _error;
  SalesRep? _salesRep;
  
  @override
  void initState() {
    super.initState();
    
    // Load sales rep data if assigned
    if (widget.customer.salesRepId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSalesRep();
      });
    } else {
      _loadingSalesRep = false;
    }
  }
  
  void _loadSalesRep() async {
    try {
      final salesRepProvider = Provider.of<SalesRepProvider>(context, listen: false);
      _salesRep = await salesRepProvider.getSalesRep(widget.customer.salesRepId);
    } catch (e) {
      // Handle error but don't show - not critical
      print('Error loading sales rep: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingSalesRep = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping),
            tooltip: 'Record Delivery',
            onPressed: () => _recordDelivery(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCustomer(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: _isLoading 
        ? const Loading() 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info Card
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          widget.customer.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.phone, 'Phone', widget.customer.phone),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.home, 'Address', widget.customer.address),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.calendar_today, 
                        'Customer Since', 
                        DateFormat('MMM d, yyyy').format(widget.customer.createdAt),
                      ),
                      if (_loadingSalesRep)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else if (_salesRep != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildInfoRow(Icons.business_center, 'Sales Rep', _salesRep!.name),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottle Status Card
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bottle Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildBottleStatusItem(
                            'Remaining',
                            widget.customer.bottlesRemaining.toString(),
                            _getBottleStatusColor(widget.customer.bottlesRemaining),
                          ),
                          _buildBottleStatusItem(
                            'Purchased',
                            widget.customer.bottlesPurchased.toString(),
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Last Delivery: ${DateFormat('MMM d, yyyy').format(widget.customer.lastDelivery)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions Card
              Card(
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              TextButton.icon(
               onPressed: () => viewDeliveryHistory(context),
                icon: Icon(Icons.history, color: Colors.blue),
      label: const Text('Delivery History'),
    ),
    TextButton.icon(
      onPressed: () => viewPaymentHistory(context),
      icon: Icon(Icons.history, color: Colors.green),
      label: const Text('Payment History'),
    ),
  ],
                

                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            'Deliver',
                            Icons.local_shipping,
                            Colors.green,
                            () => _recordDelivery(context),
                          ),
                          _buildActionButton(
                            'Payment',
                            Icons.payment,
                            Colors.orange,
                            () => _recordPayment(context),
                          ),
                          _buildActionButton(
                            'Call',
                            Icons.phone,
                            Colors.blue,
                            () {/* Add calling functionality later */},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Error message if any
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottleStatusItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
  
  Color _getBottleStatusColor(int bottlesRemaining) {
    if (bottlesRemaining <= 5) {
      return Colors.red;
    } else if (bottlesRemaining <= 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  void _editCustomer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerForm(customer: widget.customer),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${widget.customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => _deleteCustomer(context),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _deleteCustomer(BuildContext context) async {
    Navigator.pop(context); // Close the dialog
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final success = await customerProvider.deleteCustomer(widget.customer.id);
      
      if (success) {
        // Return to the customers list
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to delete customer';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // These methods will be implemented in Phase 3
void _recordDelivery(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DeliveryForm(customer: widget.customer),
    ),
  );
}

void _recordPayment(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentForm(customer: widget.customer),
    ),
  );
}

  void viewDeliveryHistory(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DeliveryHistory(customer: widget.customer),
    ),
  );
}

void viewPaymentHistory(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentHistory(customer: widget.customer),
    ),
  );
}