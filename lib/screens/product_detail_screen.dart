import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/product_provider.dart';
import 'package:frontend/screens/edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Future<void> _confirmDelete(BuildContext context, String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .deleteProduct(productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
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
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final product = provider.products.firstWhere(
      (prod) => prod.id == widget.productId,
      orElse: () => Product(
        id: '',
        name: 'Not Found',
        description: '',
        price: 0,
        quantity: 0,
      ),
    );

    if (product.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => EditProductScreen(product: product),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, product.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(product.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text('\$${product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(product.quantity.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}