import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/app_user.dart';
import 'package:water_delivery_app/screens/auth/sign_in.dart';
import 'package:water_delivery_app/screens/home/home.dart';
import 'package:water_delivery_app/services/auth_service.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<AppUser?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final AppUser? user = snapshot.data;
          
          // Return either Home or SignIn widget
          if (user == null) {
            return const SignIn();
          } else {
            return const Home();
          }
        }
        
        // Show loading indicator while getting auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}