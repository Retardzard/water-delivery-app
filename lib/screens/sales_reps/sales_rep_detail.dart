import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';
import 'package:water_delivery_app/screens/sales_reps/sales_rep_form.dart';  // Added this import
import 'package:water_delivery_app/shared/loading.dart';
import 'package:intl/intl.dart';

class SalesRepDetail extends StatefulWidget {
  final SalesRep salesRep;
  
  const SalesRepDetail({super.key, required this.salesRep});

  @override
  State<SalesRepDetail> createState() => _SalesRepDetailState();
}

class _SalesRepDetailState extends State<SalesRepDetail> {
  bool _isLoading = false;
  bool _isLoadingCustomers = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    // Load customers for this sales rep
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }
  
  void _loadCustomers() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.getCustomersBySalesRep(widget.salesRep.id);
    setState(() {
      _isLoadingCustomers = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Sales Rep Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSalesRep(context),
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
              // Sales Rep Info Card
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
                          widget.salesRep.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.phone, 'Phone', widget.salesRep.phone),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email, 'Email', widget.salesRep.email),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.calendar_today, 
                        'Joined', 
                        DateFormat('MMM d, yyyy').format(widget.salesRep.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Customers Heading
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Customers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${customerProvider.customers.length} total',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Customers List
              _isLoadingCustomers 
                ? const Center(child: CircularProgressIndicator())
                : customerProvider.customers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No customers assigned to this sales rep yet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customerProvider.customers.length,
                      itemBuilder: (context, index) {
                        final customer = customerProvider.customers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[700],
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(customer.name),
                            subtitle: Text('Bottles remaining: ${customer.bottlesRemaining}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Navigate to customer detail (will add in next step)
                            },
                          ),
                        );
                      },
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
  
  void _editSalesRep(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesRepForm(salesRep: widget.salesRep),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sales Rep'),
        content: Text('Are you sure you want to delete ${widget.salesRep.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => _deleteSalesRep(context),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _deleteSalesRep(BuildContext context) async {
    Navigator.pop(context); // Close the dialog
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final salesRepProvider = Provider.of<SalesRepProvider>(context, listen: false);
      final success = await salesRepProvider.deleteSalesRep(widget.salesRep.id);
      
      if (success) {
        // Return to the sales reps list
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to delete sales rep';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
}