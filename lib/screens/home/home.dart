import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/services/auth_service.dart';
import 'package:water_delivery_app/screens/home/dashboard.dart';
import 'package:water_delivery_app/screens/customers/customers_list.dart';
import 'package:water_delivery_app/screens/sales_reps/sales_reps_list.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _initialized = false;
  
  // The list of screens to display in the bottom navigation
  late final List<Widget> _widgetOptions;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize screens
    _widgetOptions = [
      const Dashboard(),
      const CustomersList(),
      const SalesRepsList(),
    ];
    
    // Delay initialization until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }
  
  // Initialize data providers
  void _initializeProviders() {
    print('Initializing providers in Home');
    if (!_initialized) {
      try {
        // Pre-load the data for faster access
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        final salesRepProvider = Provider.of<SalesRepProvider>(context, listen: false);
        
        customerProvider.initialize();
        salesRepProvider.initialize();
        
        setState(() {
          _initialized = true;
        });
        print('Providers initialized successfully');
      } catch (e) {
        print('Error initializing providers: $e');
      }
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Delivery Manager'),
        backgroundColor: Colors.blue[700],
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              print('Logout button pressed');
              await authService.signOut();
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Sales Reps',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        onTap: _onItemTapped,
      ),
    );
  }
}