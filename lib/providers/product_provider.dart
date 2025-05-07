import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _baseUrl = 'http://192.168.0.107:3000/products';

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl))
        .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
      } else {
        _error = 'Failed to load: ${response.statusCode}';
      }
    } on TimeoutException {
      _error = 'Connection timeout';
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> addProduct(Product product) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 201) {
      // Add the new product to local list immediately
      final newProduct = Product.fromJson(json.decode(response.body));
      _products.add(newProduct);
      notifyListeners();
    } else {
      _error = 'Failed to add product: ${response.statusCode}';
    }
  } on TimeoutException {
    _error = 'Connection timeout';
  } catch (error) {
    _error = 'Failed to add product: $error';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  
  Future<void> updateProduct(String id, Product product) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      // Update local product immediately
      final updatedProduct = Product.fromJson(json.decode(response.body));
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
    } else {
      _error = 'Failed to update product: ${response.statusCode}';
    }
  } on TimeoutException {
    _error = 'Connection timeout';
  } catch (error) {
    _error = 'Failed to update product: $error';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        _products.removeWhere((prod) => prod.id == id);
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }
}