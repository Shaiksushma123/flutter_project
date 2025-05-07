import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/product_provider.dart';
import 'package:frontend/screens/add_product_screen.dart';
import 'package:frontend/screens/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: provider.fetchProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchProducts,
            child: ListView.builder(
              itemCount: provider.products.length,
              itemBuilder: (ctx, index) {
                final product = provider.products[index];
                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
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
                  },
                  onDismissed: (direction) async {
                    try {
                      await provider.deleteProduct(product.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product deleted successfully')),
                        );
                      }
                    } catch (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${error.toString()}')),
                        );
                        provider.fetchProducts();
                      }
                    }
                  },
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: Text('Qty: ${product.quantity}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: product.id),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}