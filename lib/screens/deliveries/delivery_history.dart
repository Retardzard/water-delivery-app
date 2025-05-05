import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/delivery.dart';
import 'package:water_delivery_app/providers/delivery_provider.dart';
import 'package:water_delivery_app/shared/loading.dart';

class DeliveryHistory extends StatefulWidget {
  final Customer? customer; // If null, shows all recent deliveries
  
  const DeliveryHistory({super.key, this.customer});

  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
      
      if (widget.customer != null) {
        // Load deliveries for specific customer
        deliveryProvider.getDeliveriesForCustomer(widget.customer!.id);
      } else {
        // Load recent deliveries for all customers
        deliveryProvider.getRecentDeliveries(limit: 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(widget.customer != null 
            ? '${widget.customer!.name}\'s Deliveries' 
            : 'Recent Deliveries'),
      ),
      body: deliveryProvider.isLoading
          ? const Loading()
          : _buildDeliveryList(deliveryProvider.deliveries),
    );
  }
  
  Widget _buildDeliveryList(List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.customer != null
                  ? 'No deliveries recorded for this customer yet'
                  : 'No recent deliveries found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        final date = delivery.deliveryDate;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delivered ${delivery.bottlesDelivered} bottle${delivery.bottlesDelivered > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(date),
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (delivery.notes.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Notes: ${delivery.notes}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}