import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/payment.dart';
import 'package:water_delivery_app/providers/payment_provider.dart';
import 'package:water_delivery_app/shared/constants.dart';
import 'package:water_delivery_app/shared/loading.dart';

class PaymentForm extends StatefulWidget {
  final Customer customer;
  
  const PaymentForm({super.key, required this.customer});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  
  // Form values
  double _amount = 0.0;
  int _bottlesPurchased = 0;
  String _paymentMethod = 'Cash';
  String _notes = '';
  
  // Payment method options
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer', 'Other'];
  
  // Price per bottle (in a real app, this would come from settings)
  final double _pricePerBottle = 10.0;
  
  @override
  void initState() {
    super.initState();
    // Set default values
    _bottlesPurchased = 20; // Default to 20 bottles
    _amount = _bottlesPurchased * _pricePerBottle;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Record Payment'),
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
                
                // Payment Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Bottles Purchased Field
                        Row(
                          children: [
                            const Text(
                              'Bottles Purchased:',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: _bottlesPurchased > 1
                                        ? () => _updateBottles(_bottlesPurchased - 1)
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
                                      '$_bottlesPurchased',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _updateBottles(_bottlesPurchased + 1),
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16.0),
                        
                        // Amount Field
                        TextFormField(
                          initialValue: _amount.toString(),
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Amount',
                            prefixIcon: Icon(Icons.attach_money, color: Colors.blue[700]),
                            hintText: 'Enter payment amount',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) => val!.isEmpty || double.tryParse(val) == null || double.parse(val) <= 0
                              ? 'Please enter a valid amount'
                              : null,
                          onChanged: (val) {
                            if (val.isNotEmpty && double.tryParse(val) != null) {
                              setState(() {
                                _amount = double.parse(val);
                                // Optionally adjust bottle count based on amount
                                if (_pricePerBottle > 0) {
                                  _bottlesPurchased = (_amount / _pricePerBottle).round();
                                }
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16.0),
                        
                        // Payment Method Dropdown
                        DropdownButtonFormField<String>(
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Payment Method',
                            prefixIcon: Icon(Icons.payment, color: Colors.blue[700]),
                          ),
                          value: _paymentMethod,
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _paymentMethod = val!),
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
                                '${widget.customer.bottlesRemaining + _bottlesPurchased}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: _getBottleStatusColor(widget.customer.bottlesRemaining + _bottlesPurchased),
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
                    'Record Payment',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  
  void _updateBottles(int newCount) {
    setState(() {
      _bottlesPurchased = newCount;
      _amount = _bottlesPurchased * _pricePerBottle;
    });
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
      if (_bottlesPurchased <= 0) {
        setState(() => _error = 'Please enter at least 1 bottle');
        return;
      }
      
      if (_amount <= 0) {
        setState(() => _error = 'Please enter a valid payment amount');
        return;
      }
      
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
        
        final newPayment = Payment(
          id: '',  // Will be set by the database service
          customerId: widget.customer.id,
          amount: _amount,
          bottlesPurchased: _bottlesPurchased,
          paymentDate: DateTime.now(),
          paymentMethod: _paymentMethod,
          notes: _notes,
        );
        
        final id = await paymentProvider.recordPayment(newPayment);
        
        if (id != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment recorded successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _isLoading = false;
            _error = 'Failed to record payment';
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