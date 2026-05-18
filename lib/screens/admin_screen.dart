// ECOTRACK NAMIBIA — ADMIN SCREEN
// lib/screens/admin_screen.dart
// Purpose: Protected admin panel showing all users and their profiles
// Only accessible if role == 'admin' (checked server-side by AdminGuard)
// Date: 2026-05-17

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/admin_guard.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Map<String, dynamic>>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    _profilesFuture = _fetchAllProfiles();
  }

  Future<List<Map<String, dynamic>>> _fetchAllProfiles() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadProfiles();
            });
            await _profilesFuture;
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _profilesFuture,
            builder: (context, snapshot) {
              // LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // ERROR
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('Failed to load profiles'),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadProfiles();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // SUCCESS
              final profiles = snapshot.data ?? [];

              if (profiles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      const Text('No users found'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final role = profile['role'] ?? 'user';
                  final isAdmin = role == 'admin';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isAdmin ? Colors.orange[100] : Colors.blue[100],
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: isAdmin ? Colors.orange : Colors.blue,
                        ),
                      ),
                      title: Text(
                        profile['full_name'] ?? 'No name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile['email'] ?? 'No email'),
                          const SizedBox(height: 4),
                          Text(
                            'Created: ${DateTime.parse(profile['created_at']).toString().split('.')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          isAdmin ? 'Admin' : 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isAdmin ? Colors.orange : Colors.grey,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('User Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${profile['id']}'),
                                const SizedBox(height: 8),
                                Text('Email: ${profile['email']}'),
                                const SizedBox(height: 8),
                                Text('Name: ${profile['full_name'] ?? 'N/A'}'),
                                const SizedBox(height: 8),
                                Text('Role: ${profile['role']}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Created: ${profile['created_at']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
