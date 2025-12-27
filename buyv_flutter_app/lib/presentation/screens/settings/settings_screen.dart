import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsItem(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: 'Orders Track',
                    onTap: () => context.go('/orders-track'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.history,
                    title: 'Orders history',
                    onTap: () => context.go('/orders-history'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.visibility_outlined,
                    title: 'Recently viewed',
                    onTap: () => context.go('/recently-viewed'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.credit_card_outlined,
                    title: 'Payment Methods',
                    onTap: () => context.go('/payment'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    onTap: () => context.go('/location-settings'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    onTap: () => context.go('/language-settings'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => context.go('/change-password'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ask Help',
                    onTap: () => context.go('/help'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6F00).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout 
                ? Colors.red.withValues(alpha: 0.1)
                : const Color(0xFFFF6F00).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : const Color(0xFFFF6F00),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.blue,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isLogout ? Colors.red : Colors.blue,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}