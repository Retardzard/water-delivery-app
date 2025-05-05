// lib/screens/home/dashboard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/customer.dart';
import 'package:water_delivery_app/models/delivery.dart';
import 'package:water_delivery_app/models/payment.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/providers/delivery_provider.dart';
import 'package:water_delivery_app/providers/payment_provider.dart';
import 'package:water_delivery_app/providers/report_provider.dart';
import 'package:water_delivery_app/screens/deliveries/delivery_history.dart';
import 'package:water_delivery_app/screens/payments/payment_history.dart';
import 'package:water_delivery_app/shared/loading.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize data for dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }
  
  void _initializeDashboard() async {
  try {
    // Get low bottle customers
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    reportProvider.getCustomersWithLowBottles(5);
    
    // Get recent deliveries
    final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
    deliveryProvider.getRecentDeliveries(limit: 5);
    
    // Get recent payments
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    paymentProvider.getRecentPayments(limit: 5);
    
    // Get current month stats
    await reportProvider.getMonthlyDeliveryStats(DateTime.now());
    await reportProvider.getMonthlyPaymentStats(DateTime.now());
    
    setState(() {
      _isLoading = false;
    });
  } catch (e) {
    print('Error initializing dashboard: $e');
    setState(() {
      _isLoading = false;
    });
  }
  
  Widget _buildSummaryCards() {
    final reportProvider = Provider.of<ReportProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    final deliveryStats = reportProvider.deliveryStats;
    final paymentStats = reportProvider.paymentStats;
    
    final totalBottlesDelivered = deliveryStats?['totalBottlesDelivered'] ?? 0;
    final totalRevenue = paymentStats?['totalRevenue'] ?? 0.0;
    final totalCustomers = customerProvider.customers.length;
    
    // Format currency
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Bottles Delivered',
            value: '$totalBottlesDelivered',
            icon: Icons.local_shipping,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'Revenue',
            value: currencyFormatter.format(totalRevenue),
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
          Expanded(
          child: _buildSummaryCard(
            title: 'Customers',
            value: '$totalCustomers',
            icon: Icons.people,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Text(
              'This Month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLowBottleAlerts() {
    final reportProvider = Provider.of<ReportProvider>(context);
    final lowBottleCustomers = reportProvider.lowBottleCustomers;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Low Bottle Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${lowBottleCustomers.length} customers',
              style: TextStyle(
                color: lowBottleCustomers.isEmpty ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (lowBottleCustomers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text(
                    'No customers are running low on bottles',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: lowBottleCustomers.map((customer) => 
              _buildLowBottleCustomerCard(customer)
            ).toList(),
          ),
      ],
    );
  }
  
  Widget _buildLowBottleCustomerCard(Customer customer) {
    Color statusColor = Colors.red;
    if (customer.bottlesRemaining > 2) {
      statusColor = Colors.orange;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            '${customer.bottlesRemaining}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(customer.name),
        subtitle: Text(customer.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.local_shipping, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryForm(customer: customer),
                 ),
               );
             },
              tooltip: 'Record Delivery',
            ),
            IconButton(
              icon: const Icon(Icons.payment, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentForm(customer: customer),
                  ),
                );
              },
              tooltip: 'Record Payment',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Recent Deliveries
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Recent Deliveries',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryHistory(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRecentDeliveriesList(deliveryProvider.deliveries),
        
        const SizedBox(height: 24),
        
        // Recent Payments
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Recent Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentHistory(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRecentPaymentsList(paymentProvider.payments),
      ],
    );
  }
  
  Widget _buildRecentDeliveriesList(List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No recent deliveries'),
          ),
        ),
      );
    }
    
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    return Column(
      children: deliveries.take(3).map((delivery) {
        // Find the customer for this delivery
        final customer = customerProvider.customers
            .firstWhere(
              (c) => c.id == delivery.customerId,
              orElse: () => Customer(
                id: '',
                name: 'Unknown Customer',
                phone: '',
                address: '',
                salesRepId: '',
                bottlesRemaining: 0,
                bottlesPurchased: 0,
                createdAt: DateTime.now(),
                lastDelivery: DateTime.now(),
              ),
            );
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.local_shipping, color: Colors.white),
            ),
            title: Text('${delivery.bottlesDelivered} bottles delivered'),
            subtitle: Text(
              '${customer.name} • ${DateFormat('MMM d').format(delivery.deliveryDate)}',
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecentPaymentsList(List<Payment> payments) {
    if (payments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No recent payments'),
          ),
        ),
      );
    }
    
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    // Format currency
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    return Column(
      children: payments.take(3).map((payment) {
        // Find the customer for this payment
        final customer = customerProvider.customers
            .firstWhere(
              (c) => c.id == payment.customerId,
              orElse: () => Customer(
                id: '',
                name: 'Unknown Customer',
                phone: '',
                address: '',
                salesRepId: '',
                bottlesRemaining: 0,
                bottlesPurchased: 0,
                createdAt: DateTime.now(),
                lastDelivery: DateTime.now(),
              ),
            );
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[700],
              child: const Icon(Icons.payment, color: Colors.white),
            ),
            title: Text(
              '${currencyFormatter.format(payment.amount)} • ${payment.bottlesPurchased} bottles',
            ),
            subtitle: Text(
              '${customer.name} • ${DateFormat('MMM d').format(payment.paymentDate)}',
            ),
          ),
        );
      }).toList(),
    );
  }
}