import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/sales_rep.dart';
import 'package:water_delivery_app/providers/sales_rep_provider.dart';
import 'package:water_delivery_app/shared/constants.dart';
import 'package:water_delivery_app/shared/loading.dart';

class SalesRepForm extends StatefulWidget {
  final SalesRep? salesRep; // Null for new sales rep, non-null for editing
  
  const SalesRepForm({super.key, this.salesRep});

  @override
  State<SalesRepForm> createState() => _SalesRepFormState();
}

class _SalesRepFormState extends State<SalesRepForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  
  // Form values
  String _name = '';
  String _phone = '';
  String _email = '';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form values if editing an existing sales rep
    if (widget.salesRep != null) {
      _name = widget.salesRep!.name;
      _phone = widget.salesRep!.phone;
      _email = widget.salesRep!.email;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          widget.salesRep == null ? 'Add Sales Representative' : 'Edit Sales Representative'
        ),
      ),
      body: _isLoading 
        ? const Loading() 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  initialValue: _name,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a name' : null,
                  onChanged: (val) => setState(() => _name = val),
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextFormField(
                  initialValue: _phone,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a phone number' : null,
                  onChanged: (val) => setState(() => _phone = val),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Email Field
                TextFormField(
                  initialValue: _email,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) => setState(() => _email = val),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                
                // Error message if any
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    widget.salesRep == null ? 'Add Sales Rep' : 'Update Sales Rep',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final salesRepProvider = Provider.of<SalesRepProvider>(context, listen: false);
        
        if (widget.salesRep == null) {
          // Creating a new sales rep
          final newSalesRep = SalesRep(
            id: '',  // Will be set by the database service
            name: _name,
            phone: _phone,
            email: _email,
            createdAt: DateTime.now(),
          );
          
          await salesRepProvider.addSalesRep(newSalesRep);
        } else {
          // Updating an existing sales rep
          final updatedSalesRep = SalesRep(
            id: widget.salesRep!.id,
            name: _name,
            phone: _phone,
            email: _email,
            createdAt: widget.salesRep!.createdAt,
          );
          
          await salesRepProvider.updateSalesRep(updatedSalesRep);
        }
        
        // Return to the sales reps list
        if (mounted) {
          Navigator.pop(context);
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