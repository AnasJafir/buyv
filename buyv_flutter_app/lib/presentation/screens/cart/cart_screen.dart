import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/cart_model.dart';
import '../../../domain/models/order_model.dart';
import '../../../data/services/order_service.dart';
import '../../../services/stripe_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

import '../../widgets/require_login_prompt.dart';
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  String? _error;
  double _discount = 0.0;
  String? _appliedPromoCode;
  final TextEditingController _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadCartData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load cart from CartProvider
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.loadCart();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, double> _calculateTotals(List<CartItem> items) {
    final subtotal = items.fold(0.0, (sum, item) => 
        sum + ((item.product.discountPrice ?? item.product.price) * item.quantity));
    final shipping = items.isEmpty ? 0.0 : 5.0;
    final tax = subtotal * 0.08; // 8% tax
    final total = subtotal + shipping + tax - _discount;
    return {'subtotal': subtotal, 'shipping': shipping, 'tax': tax, 'total': total};
  }

  void _updateQuantity(String itemId, int newQuantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (newQuantity > 0) {
      cartProvider.updateQuantity(itemId, newQuantity);
    } else {
      cartProvider.removeFromCart(itemId);
    }
  }

  void _applyPromoCode(double subtotal) {
    final code = _promoCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a promo code')),
      );
      return;
    }

    // Simulate promo code validation
    Map<String, double> validCodes = {
      'SAVE10': 0.10, // 10% discount
      'SAVE20': 0.20, // 20% discount
      'WELCOME': 0.15, // 15% discount
      'FIRST': 0.25, // 25% discount for first-time users
    };

    if (validCodes.containsKey(code)) {
      setState(() {
        _discount = subtotal * validCodes[code]!;
        _appliedPromoCode = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code applied! You saved \$${_discount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePromoCode() {
    setState(() {
      _discount = 0.0;
      _appliedPromoCode = null;
      _promoCodeController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Promo code removed')),
    );
  }

  Future<void> _processCheckout(List<CartItem> cartItems, double total) async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if running on desktop (Windows/Linux/macOS) or web
      final isDesktopOrWeb = kIsWeb || (!Platform.isAndroid && !Platform.isIOS);
      
      if (isDesktopOrWeb) {
        // Desktop/Web: Skip Stripe and create order directly with mock payment
        await _showMockPaymentDialog(cartItems, total);
      } else {
        // Mobile: Use Stripe payment
        debugPrint('📱 Starting mobile Stripe payment...');
        await StripeService.instance.makePayment(
          context: context,
          amount: total,
          currency: 'usd',
          onSuccess: () async {
            // Payment successful, create order
            debugPrint('✅ Payment successful callback received, creating order...');
            await _createOrder(cartItems, total);
            debugPrint('✅ Order creation completed');
          },
          onError: (error) {
            debugPrint('❌ Payment error callback: $error');
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
        debugPrint('📱 Stripe payment flow completed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createOrder(List<CartItem> cartItems, double total) async {
    try {
      debugPrint('📦 Starting order creation...');
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('📦 User authenticated: ${currentUser.id}');

      // Calculate totals
      final totals = _calculateTotals(cartItems);
      final subtotal = totals['subtotal']!;
      final shipping = totals['shipping']!;
      final tax = totals['tax']!;
      
      debugPrint('📦 Totals calculated - Subtotal: $subtotal, Shipping: $shipping, Tax: $tax, Total: $total');

      // Prepare order items
      final orderItems = cartItems.map((item) => OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: item.product.id,
        productName: item.product.name,
        productImage: item.product.imageUrls.isNotEmpty ? item.product.imageUrls.first : '',
        price: item.product.price,
        quantity: item.quantity,
        size: item.selectedSize,
        color: item.selectedColor,
        attributes: item.selectedAttributes?.map((key, value) => MapEntry(key, value.toString())) ?? {},
        isPromotedProduct: item.promoterId != null,
        promoterId: item.promoterId,
      )).toList();

      debugPrint('📦 Order items prepared: ${orderItems.length} items');

      // Create order model
      final order = OrderModel(
        id: '', // Backend will generate
        userId: currentUser.id,
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: orderItems,
        status: OrderStatus.pending,
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        total: total,
        paymentMethod: 'stripe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: 'Order from BuyV app',
      );

      debugPrint('📦 Calling OrderService to create order...');
      // Create order via API
      final orderId = await OrderService().createOrder(order);

      debugPrint('📦 Order created with ID: $orderId');

      if (orderId == null) {
        throw Exception('Failed to create order');
      }

      // Clear cart
      debugPrint('🛒 Clearing cart...');
      cartProvider.clearCart();
      debugPrint('🛒 Cart cleared');

      setState(() {
        _isLoading = false;
      });

      debugPrint('✅ Order creation complete, showing success message');

      // Show success and navigate to orders
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      debugPrint('🚀 Navigating to orders history...');
      // Navigate to orders history (push instead of go to maintain navigation stack)
      context.push('/orders-history');
    } catch (e) {
      debugPrint('❌ Order creation error: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showMockPaymentDialog(List<CartItem> cartItems, double total) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, size: 64, color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stripe is not available on desktop.\nThis is a test payment for development.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Confirm Payment', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _createOrder(cartItems, total);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveCart() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate saving cart to storage
      await Future.delayed(Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _clearError() {
    setState(() {
      _error = null;
    });
  }

  void _refreshCart() {
    _loadCartData();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthProvider>(context).currentUser;

    if (authUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: RequireLoginPrompt(
          onLogin: () {
            context.go('/login');
          },
          onSignUp: () {
            context.go('/signup');
          },
          onDismiss: () {},
          showCloseButton: false,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 48,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'Cart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF0066CC),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final cartItems = cartProvider.items;
                  final totals = _calculateTotals(cartItems);
                  final subtotal = totals['subtotal']!;
                  final shipping = totals['shipping']!;
                  final tax = totals['tax']!;
                  final total = totals['total']!;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (_isLoading)
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0066CC),
                            ),
                          )
                        else if (_error != null)
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  'Error: $_error',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _clearError();
                                    _refreshCart();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0066CC),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (cartItems.isEmpty)
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else ...[
                          // Cart Items
                          ...(cartItems.map((item) => _buildCartProductCard(item))),
                          
                          const SizedBox(height: 16),
                          
                          // Cost Summary
                          _buildCostSummary(subtotal, shipping, tax, total),
                          
                          const SizedBox(height: 12),
                          
                          // Promo Code Field
                          _buildPromoCodeField(subtotal),
                          
                          const SizedBox(height: 16),
                          
                          // Checkout Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _processCheckout(cartItems, total),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 6,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Pay \$${total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 86),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartProductCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: item.product.imageUrls.isNotEmpty
                    ? Image.network(
                        item.product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.selectedSize != null || item.selectedColor != null) ...[
                     const SizedBox(height: 4),
                     Text(
                       [
                         if (item.selectedSize != null) 'Size: ${item.selectedSize}',
                         if (item.selectedColor != null) 'Color: ${item.selectedColor}',
                       ].join('  •  '),
                       style: TextStyle(
                         color: Colors.grey,
                         fontSize: 12,
                       ),
                     ),
                   ],
                  const SizedBox(height: 8),
                  Text(
                    '\$${(item.product.discountPrice ?? item.product.price).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Color(0xFFFF5722),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Row(
              children: [
                GestureDetector(
                   onTap: () {
                     if (item.quantity > 1) {
                       _updateQuantity(item.id, item.quantity - 1);
                     }
                   },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                
                GestureDetector(
                   onTap: () {
                     _updateQuantity(item.id, item.quantity + 1);
                   },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummary(double subtotal, double shipping, double tax, double total) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Subtotal',
                style: TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('\$${subtotal.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Shipping',
                style: TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('\$${shipping.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Tax',
                style: TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('\$${tax.toStringAsFixed(2)}'),
          ],
        ),
        if (_discount > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Discount ($_appliedPromoCode)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '-\$${_discount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Divider(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromoCodeField(double subtotal) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter your code',
                  suffixIcon: Icon(
                    Icons.percent,
                    color: Color(0xFF0B74DA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _appliedPromoCode == null ? () => _applyPromoCode(subtotal) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0B74DA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Apply',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        if (_appliedPromoCode != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Promo code "$_appliedPromoCode" applied!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _removePromoCode,
                  child: Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveCart,
                icon: Icon(Icons.save),
                label: Text('Save Cart'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Extension is not needed as CartItem already has copyWith method