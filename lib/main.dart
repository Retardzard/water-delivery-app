// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/providers/customer_provider.dart';
import 'package:water_delivery_app/providers/delivery_provider.dart';
import 'package:water_delivery_app/providers/payment_provider.dart';
import 'package:water_delivery_app/providers/report_provider.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';
import 'package:water_delivery_app/services/auth_service.dart';
import 'package:water_delivery_app/screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        
        // Phase 2 Providers
        ChangeNotifierProvider<CustomerProvider>(
          create: (_) => CustomerProvider(),
        ),
        ChangeNotifierProvider<SalesRepProvider>(
          create: (_) => SalesRepProvider(),
        ),
        
        // Phase 3 Providers
        ChangeNotifierProvider<DeliveryProvider>(
          create: (_) => DeliveryProvider(),
        ),
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (_) => ReportProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Water Delivery Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue[700],
            secondary: Colors.lightBlue,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
        home: const Wrapper(),
      ),
    );
  }
}