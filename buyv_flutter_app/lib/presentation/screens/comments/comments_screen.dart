import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../services/api/comment_api_service.dart';
import '../../../domain/models/comment_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Screen to display and add comments for a specific post
class CommentsScreen extends StatefulWidget {
  final String postId;
  final String? postUsername;

  const CommentsScreen({
    super.key,
    required this.postId,
    this.postUsername,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSending = false;
  String? _errorMessage;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreComments();
      }
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final commentsData = await CommentApiService.getComments(
        widget.postId,
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _comments = commentsData.map((json) => CommentModel.fromJson(json)).toList();
        _isLoading = false;
        _currentPage = 0;
        _hasMore = commentsData.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load comments: $e';
      });
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newCommentsData = await CommentApiService.getComments(
        widget.postId,
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );
      
      setState(() {
        _comments.addAll(newCommentsData.map((json) => CommentModel.fromJson(json)).toList());
        _currentPage++;
        _isLoadingMore = false;
        _hasMore = newCommentsData.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more comments: $e')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final newCommentData = await CommentApiService.addComment(
        widget.postId,
        text,
      );
      
      setState(() {
        _comments.insert(0, CommentModel.fromJson(newCommentData));
        _commentController.clear();
        _isSending = false;
      });

      // Hide keyboard
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    // Fermer le clavier
    FocusScope.of(context).unfocus();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await CommentApiService.deleteComment(commentId.toString());
      
      setState(() {
        _comments.removeWhere((c) => c.id == commentId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Fermer le clavier si ouvert
            FocusScope.of(context).unfocus();
            // Retour arrière
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.postUsername != null)
              Text(
                '${widget.postUsername}\'s post',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _loadComments,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: _buildCommentsList(),
          ),

          // Divider
          const Divider(height: 1),

          // Comment Input
          _buildCommentInput(currentUserId),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _comments.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final comment = _comments[index];
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isOwnComment = comment.userId == authProvider.currentUser?.id;

        return _buildCommentItem(comment, isOwnComment);
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment, bool isOwnComment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          GestureDetector(
            onTap: () {
              // Navigate to user profile
              context.go('/user/${comment.userId}');
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: comment.userProfileImage != null &&
                      comment.userProfileImage!.isNotEmpty
                  ? NetworkImage(comment.userProfileImage!)
                  : null,
              child: comment.userProfileImage == null ||
                      comment.userProfileImage!.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and Time
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go('/user/${comment.userId}');
                      },
                      child: Text(
                        comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment Text
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Delete Button (only for own comments)
          if (isOwnComment)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.grey[600],
              onPressed: () => _deleteComment(comment.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(String? currentUserId) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 16,
              backgroundImage: Provider.of<AuthProvider>(context)
                          .currentUser
                          ?.profileImageUrl !=
                      null
                  ? NetworkImage(
                      Provider.of<AuthProvider>(context)
                          .currentUser!
                          .profileImageUrl!,
                    )
                  : null,
              child: Provider.of<AuthProvider>(context)
                          .currentUser
                          ?.profileImageUrl ==
                      null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),

            // Text Field
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: !_isSending,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
            const SizedBox(width: 8),

            // Send Button
            _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _commentController.text.trim().isEmpty
                          ? Colors.grey
                          : AppTheme.primaryColor,
                    ),
                    onPressed: _commentController.text.trim().isEmpty
                        ? null
                        : _addComment,
                  ),
          ],
        ),
      ),
    );
  }
}
