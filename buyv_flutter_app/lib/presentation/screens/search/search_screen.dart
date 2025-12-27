import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api/search_api_service.dart';
import '../../../domain/models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _userResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _userResults.clear();
        _currentQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query.trim();
    });

    try {
      // Search only users
      final usersData = await SearchApiService.searchUsers(query: _currentQuery);
      setState(() {
        _userResults = usersData.map((data) => UserModel.fromJson(data)).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onSubmitted: _performSearch,
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _userResults.clear();
                  _currentQuery = '';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            const LinearProgressIndicator(),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_currentQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Start typing to search for users',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(user.displayName ?? user.username),
          subtitle: Text('@${user.username}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to user profile
            context.push('/user/${user.id}');
          },
        );
      },
    );
  }
}
