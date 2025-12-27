import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/cj_product_model.dart';
import '../../../domain/models/product_model.dart';
import '../../providers/cart_provider.dart';

void addCJProductToCart(BuildContext context, CJProduct cjProduct) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  
  // Convertir CJProduct en ProductModel pour le panier
  final productModel = ProductModel(
    id: cjProduct.pid,
    name: cjProduct.productName,
    description: cjProduct.description,
    price: cjProduct.sellPrice,
    discountPrice: cjProduct.originalPrice > cjProduct.sellPrice ? cjProduct.sellPrice : null,
    category: cjProduct.categoryName,
    imageUrls: cjProduct.productImages,
    videoUrl: null,
    stockQuantity: 100,
    isAvailable: true,
    rating: cjProduct.rating,
    reviewsCount: cjProduct.reviewCount,
    sellerId: 'cj_dropshipping',
    sellerName: 'CJ Dropshipping',
    tags: [],
    specifications: cjProduct.specifications,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    viewsCount: 0,
    likesCount: 0,
    isFeatured: false,
  );
  
  cartProvider.addToCart(productModel, quantity: 1);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${cjProduct.productName} added to cart!'),
      backgroundColor: const Color(0xFF4CAF50),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'VIEW',
        textColor: Colors.white,
        onPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
      ),
    ),
  );
}
