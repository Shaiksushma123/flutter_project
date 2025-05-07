import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _qtyController = TextEditingController(text: widget.product.quantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () => _updateProduct(context),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProduct(BuildContext context) async {
    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text,
      description: _descController.text,
      price: double.parse(_priceController.text),
      quantity: int.parse(_qtyController.text),
    );

    try {
      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(widget.product.id, updatedProduct);
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
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