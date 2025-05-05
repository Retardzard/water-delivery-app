import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';
import 'package:water_delivery_app/screens/sales_reps/sales_rep_form.dart';  // Added this import
import 'package:water_delivery_app/screens/sales_reps/sales_rep_detail.dart';
import 'package:water_delivery_app/shared/loading.dart';

class SalesRepsList extends StatefulWidget {
  const SalesRepsList({super.key});

  @override
  State<SalesRepsList> createState() => _SalesRepsListState();
}

class _SalesRepsListState extends State<SalesRepsList> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider to fetch sales reps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesRepProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesRepProvider = Provider.of<SalesRepProvider>(context);
    
    return Scaffold(
      body: salesRepProvider.isLoading 
        ? const Loading() 
        : salesRepProvider.error != null
          ? _buildErrorMessage(salesRepProvider.error!)
          : _buildSalesRepsList(salesRepProvider.salesReps),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SalesRepForm(),
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
            'Error loading sales representatives',
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
              Provider.of<SalesRepProvider>(context, listen: false).initialize();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesRepsList(List<SalesRep> salesReps) {
    if (salesReps.isEmpty) {
      return const Center(
        child: Text(
          'No sales representatives found.\nClick the + button to add a new one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: salesReps.length,
      itemBuilder: (context, index) {
        final salesRep = salesReps[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(salesRep.name),
            subtitle: Text(salesRep.phone),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesRepDetail(salesRep: salesRep),
                ),
              );
            },
          ),
        );
      },
    );
  }
}