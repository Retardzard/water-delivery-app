// lib/screens/deliveries/delivery_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/delivery.dart';
import 'package:water_delivery_app/providers/delivery_provider.dart';
import 'package:water_delivery_app/shared/constants.dart';
import 'package:water_delivery_app/shared/loading.dart';

class DeliveryForm extends StatefulWidget {
  final Customer customer;
  
  const DeliveryForm({super.key, required this.customer});

  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  
  // Form values
  int _bottlesDelivered = 1;
  String _notes = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Record Delivery'),
      ),
      body: _isLoading 
        ? const Loading() 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info Card
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.customer.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(widget.customer.address),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Bottles',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${widget.customer.bottlesRemaining}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: _getBottleStatusColor(widget.customer.bottlesRemaining),
                                  ),
                                ),
                              ],
                            ),
                            _buildBottleIndicator(widget.customer.bottlesRemaining),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Delivery Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Bottles Delivered Field
                        Row(
                          children: [
                            const Text(
                              'Bottles to Deliver:',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: _bottlesDelivered > 1
                                        ? () => setState(() => _bottlesDelivered--)
                                        : null,
                                    color: Colors.red,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      '$_bottlesDelivered',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: _bottlesDelivered < widget.customer.bottlesRemaining
                                        ? () => setState(() => _bottlesDelivered++)
                                        : null,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16.0),
                        
                        // New Balance Preview
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'New Balance:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.customer.bottlesRemaining - _bottlesDelivered}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: _getBottleStatusColor(widget.customer.bottlesRemaining - _bottlesDelivered),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16.0),
                        
                        // Notes Field
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Notes (Optional)',
                            prefixIcon: Icon(Icons.note, color: Colors.blue[700]),
                          ),
                          maxLines: 3,
                          onChanged: (val) => setState(() => _notes = val),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24.0),
                
                // Low Bottle Warning
                if ((widget.customer.bottlesRemaining - _bottlesDelivered) <= 5)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700]),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Low bottle warning! Customer will have only ${widget.customer.bottlesRemaining - _bottlesDelivered} bottles left after this delivery.',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Error message if any
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                
                const SizedBox(height: 16.0),
                
                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Record Delivery',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
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
  
  Widget _buildBottleIndicator(int bottlesRemaining) {
    Color color = _getBottleStatusColor(bottlesRemaining);
    
    return Container(
      width: 100.0,
      height: 20.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: bottlesRemaining,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  bottomLeft: const Radius.circular(10.0),
                  topRight: bottlesRemaining >= 20 ? const Radius.circular(10.0) : Radius.zero,
                  bottomRight: bottlesRemaining >= 20 ? const Radius.circular(10.0) : Radius.zero,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 20 - bottlesRemaining,
            child: Container(),
          ),
        ],
      ),
    );
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_bottlesDelivered <= 0) {
        setState(() => _error = 'Please enter at least 1 bottle');
        return;
      }
      
      if (_bottlesDelivered > widget.customer.bottlesRemaining) {
        setState(() => _error = 'Cannot deliver more bottles than the customer has remaining');
        return;
      }
      
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
        
        final newDelivery = Delivery(
          id: '',  // Will be set by the database service
          customerId: widget.customer.id,
          bottlesDelivered: _bottlesDelivered,
          deliveryDate: DateTime.now(),
          notes: _notes,
        );
        
        final id = await deliveryProvider.recordDelivery(newDelivery);
        
        if (id != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Delivery recorded successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _isLoading = false;
            _error = 'Failed to record delivery';
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
}