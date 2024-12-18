import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final User? user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.avatar != null
                    ? NetworkImage(user.avatar!)
                    : null,
                child: user.avatar == null
                    ? Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                title: 'Username',
                value: user.username,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Email',
                value: user.email,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Member Since',
                value: _formatDate(user.createdAt),
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement edit profile
                },
                child: const Text('Edit Profile'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
