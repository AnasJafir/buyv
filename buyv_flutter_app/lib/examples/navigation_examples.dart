import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/deep_link_handler.dart';
import '../core/router/route_names.dart';
import 'package:share_plus/share_plus.dart';

/// Example widget showing how to use Go Router navigation and deep links
/// This serves as a reference for updating existing screens
class NavigationExamplesWidget extends StatelessWidget {
  const NavigationExamplesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Basic Navigation
          _buildSection(
            'Basic Navigation',
            [
              _buildNavigationButton(
                context,
                'Go to Home',
                () => context.go(RouteNames.home),
              ),
              _buildNavigationButton(
                context,
                'Go to Profile',
                () => context.go(RouteNames.profile),
              ),
              _buildNavigationButton(
                context,
                'Go to Shop',
                () => context.go(RouteNames.shop),
              ),
              _buildNavigationButton(
                context,
                'Go to Cart',
                () => context.go(RouteNames.cart),
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 2: Push Navigation (keeps history)
          _buildSection(
            'Push Navigation (with back button)',
            [
              _buildNavigationButton(
                context,
                'Push Settings',
                () => context.push(RouteNames.settings),
              ),
              _buildNavigationButton(
                context,
                'Push Notifications',
                () => context.push(RouteNames.notifications),
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 3: Deep Link Navigation
          _buildSection(
            'Deep Link Navigation',
            [
              _buildNavigationButton(
                context,
                'Open Post (via deep link)',
                () => context.go('/post/example-post-123'),
              ),
              _buildNavigationButton(
                context,
                'Open User Profile (via deep link)',
                () => context.go('/user/johndoe'),
              ),
              _buildNavigationButton(
                context,
                'Open Product (via deep link)',
                () => context.go('/product/prod456?name=T-Shirt&price=29.99'),
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 4: Create & Share Deep Links
          _buildSection(
            'Create & Share Deep Links',
            [
              _buildActionButton(
                context,
                'Share Post Link',
                () {
                  final link = DeepLinkHandler.createPostDeepLink('post-123');
                  Share.share('Check out this post: $link');
                  _showSnackbar(context, 'Post link: $link');
                },
              ),
              _buildActionButton(
                context,
                'Share User Profile Link',
                () {
                  final link = DeepLinkHandler.createUserDeepLink('johndoe');
                  Share.share('Follow @johndoe on BuyV: $link');
                  _showSnackbar(context, 'User link: $link');
                },
              ),
              _buildActionButton(
                context,
                'Share Product Link',
                () {
                  final link = DeepLinkHandler.createProductDeepLink(
                    'prod-789',
                    name: 'Cool T-Shirt',
                    price: 29.99,
                    category: 'Clothing',
                  );
                  Share.share('Check out this product: $link');
                  _showSnackbar(context, 'Product link: $link');
                },
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 5: Named Route Navigation
          _buildSection(
            'Named Route Navigation',
            [
              _buildNavigationButton(
                context,
                'Go to Home (named)',
                () => context.goNamed('home'),
              ),
              _buildNavigationButton(
                context,
                'Go to Post (named)',
                () => context.goNamed(
                  'post-detail',
                  pathParameters: {'uid': 'post-456'},
                ),
              ),
              _buildNavigationButton(
                context,
                'Go to User (named)',
                () => context.goNamed(
                  'user-detail',
                  pathParameters: {'uid': 'user-789'},
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 6: Back Navigation
          _buildSection(
            'Back Navigation',
            [
              _buildNavigationButton(
                context,
                'Go Back',
                () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    _showSnackbar(context, 'Cannot go back');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Text(label),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Example: How to update an existing PostCard widget to use deep links
class PostCardNavigationExample extends StatelessWidget {
  final String postId;
  final String userId;
  final String userName;

  const PostCardNavigationExample({
    super.key,
    required this.postId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // User header - tap to open profile
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(userName),
            onTap: () {
              // Navigate to user profile using deep link
              context.go('/user/$userId');
            },
          ),

          // Post content - tap to open post detail
          GestureDetector(
            onTap: () {
              // Navigate to post detail using deep link
              context.go('/post/$postId');
            },
            child: Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('Post Content')),
            ),
          ),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Like action
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {
                  // Open post detail for comments
                  context.push('/post/$postId');
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share post using deep link
                  final link = DeepLinkHandler.createPostDeepLink(postId);
                  Share.share('Check out this post: $link');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Example: How to navigate from notifications
class NotificationItemExample extends StatelessWidget {
  final String type;
  final String targetId;

  const NotificationItemExample({
    super.key,
    required this.type,
    required this.targetId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('You have a notification'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        // Navigate based on notification type
        switch (type) {
          case 'post_like':
          case 'post_comment':
            context.go('/post/$targetId');
            break;
          case 'new_follower':
          case 'user_mention':
            context.go('/user/$targetId');
            break;
          case 'order_update':
            context.go(RouteNames.ordersHistory);
            break;
          default:
            context.go(RouteNames.home);
        }
      },
    );
  }
}
