import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final product = Product(
        id: '',
        name: _nameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_qtyController.text),
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      
      try {
        await provider.addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProductProvider, bool>((provider) => provider.isLoading);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid number';
                      if (double.parse(value) <= 0) return 'Must be greater than 0';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (int.tryParse(value!) == null) return 'Invalid number';
                      if (int.parse(value) < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Add Product'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }
}