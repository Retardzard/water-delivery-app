import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/payment.dart';
import 'package:water_delivery_app/providers/payment_provider.dart';
import 'package:water_delivery_app/shared/loading.dart';

class PaymentHistory extends StatefulWidget {
  final Customer? customer; // If null, shows all recent payments
  
  const PaymentHistory({super.key, this.customer});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      
      if (widget.customer != null) {
        // Load payments for specific customer
        paymentProvider.getPaymentsForCustomer(widget.customer!.id);
      } else {
        // Load recent payments for all customers
        paymentProvider.getRecentPayments(limit: 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(widget.customer != null 
            ? '${widget.customer!.name}\'s Payments' 
            : 'Recent Payments'),
      ),
      body: paymentProvider.isLoading
          ? const Loading()
          : _buildPaymentList(paymentProvider.payments),
    );
  }
  
  Widget _buildPaymentList(List<Payment> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.customer != null
                  ? 'No payments recorded for this customer yet'
                  : 'No recent payments found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    // Format currency
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final date = payment.paymentDate;
        
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
                          Icons.payment,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyFormatter.format(payment.amount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${payment.bottlesPurchased} bottle${payment.bottlesPurchased > 1 ? 's' : ''} purchased',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(date),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          payment.paymentMethod,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (payment.notes.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Notes: ${payment.notes}',
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