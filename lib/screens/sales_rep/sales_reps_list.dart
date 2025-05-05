import 'package:flutter/material.dart';
import 'package:water_delivery_app/shared/loading.dart';

class SalesRepsList extends StatefulWidget {
  const SalesRepsList({super.key});

  @override
  State<SalesRepsList> createState() => _SalesRepsListState();
}

class _SalesRepsListState extends State<SalesRepsList> {
  bool loading = false;
  
  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'Sales Representatives',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text('Sales Rep list will be implemented in Phase 2'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add sales rep screen - will implement in Phase 2
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Sales Rep feature coming in Phase 2'),
            ),
          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}