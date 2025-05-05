import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/screens/customers/customer_form.dart';
import 'package:water_delivery_app/screens/customers/customer_detail.dart';
import 'package:water_delivery_app/shared/loading.dart';

class CustomersList extends StatefulWidget {
  const CustomersList({super.key});

  @override
  State<CustomersList> createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersList> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider to fetch customers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    return Scaffold(
      body: customerProvider.isLoading 
        ? const Loading() 
        : customerProvider.error != null
          ? _buildErrorMessage(customerProvider.error!)
          : _buildCustomersList(customerProvider.customers),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerForm(),
            ),
          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildErrorMessage(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading customers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<CustomerProvider>(context, listen: false).initialize();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCustomersList(List<Customer> customers) {
    if (customers.isEmpty) {
      return const Center(
        child: Text(
          'No customers found.\nClick the + button to add a new one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        
        // Color coding based on bottles remaining
        Color statusColor = Colors.green;
        if (customer.bottlesRemaining <= 5) {
          statusColor = Colors.red;
        } else if (customer.bottlesRemaining <= 10) {
          statusColor = Colors.orange;
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(customer.name),
            subtitle: Text(customer.address),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${customer.bottlesRemaining}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetail(customer: customer),
                ),
              );
            },
          ),
        );
      },
    );
  }
}