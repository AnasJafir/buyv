import 'package:flutter/material.dart';
import '../../../services/post_api_service.dart';
import '../../../data/models/post_model.dart';
import '../../../presentation/widgets/post_card_widget.dart';

/// Screen to display a single post (for deep linking)
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final postData = await PostApiService.getPost(widget.postId);
      setState(() {
        _post = PostModel.fromJson(postData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load post: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
              final shareUrl = 'buyv://post/${widget.postId}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share URL: $shareUrl')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPost,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _post == null
                  ? const Center(
                      child: Text(
                        'Post not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Display the post
                          PostCardWidget(post: _post!),
                          const SizedBox(height: 16),
                          
                          // Additional post info
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Post ID: ${widget.postId}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Created: ${_post!.createdAt}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
