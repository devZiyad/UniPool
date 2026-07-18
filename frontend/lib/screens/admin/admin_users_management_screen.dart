import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/admin_service.dart';
import '../../widgets/app_drawer.dart';

class AdminUsersManagementScreen extends StatefulWidget {
  const AdminUsersManagementScreen({super.key});

  @override
  State<AdminUsersManagementScreen> createState() =>
      _AdminUsersManagementScreenState();
}

class _AdminUsersManagementScreenState
    extends State<AdminUsersManagementScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  int _currentUserIndex = 0;
  Map<int, bool> _updatingStatus = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await AdminService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
          if (_currentUserIndex >= _users.length) {
            _currentUserIndex = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUniversityIdVerified(int userId, bool value) async {
    setState(() {
      _updatingStatus[userId] = true;
    });

    try {
      final updatedUser = await AdminService.verifyUniversityId(userId, value);
      if (mounted) {
        setState(() {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
          }
          _updatingStatus[userId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'University ID verified'
                  : 'University ID verification removed',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _updatingStatus[userId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateVerifiedDriver(int userId, bool value) async {
    setState(() {
      _updatingStatus[userId] = true;
    });

    try {
      final updatedUser = await AdminService.verifyDriver(userId, value);
      if (mounted) {
        setState(() {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
          }
          _updatingStatus[userId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Driver verified' : 'Driver verification removed',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _updatingStatus[userId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateEnabled(int userId, bool value) async {
    setState(() {
      _updatingStatus[userId] = true;
    });

    try {
      final updatedUser = await AdminService.setUserEnabled(userId, value);
      if (mounted) {
        setState(() {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
          }
          _updatingStatus[userId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'User enabled' : 'User disabled',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _updatingStatus[userId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImageWidget(String? imageData, String label) {
    if (imageData == null || imageData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                '$label not uploaded',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    Uint8List? imageBytes;
    try {
      // Handle base64 image data (with or without data URI prefix)
      String base64String = imageData;
      if (base64String.contains(',')) {
        base64String = base64String.split(',')[1];
      }
      imageBytes = base64Decode(base64String);
    } catch (e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Error loading $label',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Error displaying $label',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        drawer: AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_users.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        drawer: AppDrawer(),
        body: const Center(
          child: Text(
            'No users found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final currentUser = _users[_currentUserIndex];
    final isUpdating = _updatingStatus[currentUser.id] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User counter
                    Center(
                      child: Text(
                        'User ${_currentUserIndex + 1} of ${_users.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User information card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    currentUser.fullName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser.fullName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentUser.email,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${currentUser.universityId}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoChip('Role', currentUser.role),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoChip(
                                    'Balance',
                                    'BD ${currentUser.walletBalance.toStringAsFixed(2)}',
                                  ),
                                ),
                              ],
                            ),
                            if (currentUser.phoneNumber != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Phone: ${currentUser.phoneNumber}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status switches
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('University ID Verified'),
                              subtitle: Text(
                                currentUser.universityIdVerified
                                    ? 'Verified'
                                    : 'Not verified',
                              ),
                              value: currentUser.universityIdVerified,
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      _updateUniversityIdVerified(
                                        currentUser.id,
                                        value,
                                      );
                                    },
                              secondary: Icon(
                                currentUser.universityIdVerified
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: currentUser.universityIdVerified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            SwitchListTile(
                              title: const Text('Driver Verified'),
                              subtitle: Text(
                                currentUser.verifiedDriver
                                    ? 'Verified'
                                    : 'Not verified',
                              ),
                              value: currentUser.verifiedDriver,
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      _updateVerifiedDriver(
                                        currentUser.id,
                                        value,
                                      );
                                    },
                              secondary: Icon(
                                currentUser.verifiedDriver
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: currentUser.verifiedDriver
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            SwitchListTile(
                              title: const Text('Account Enabled'),
                              subtitle: Text(
                                currentUser.enabled
                                    ? 'Account is active'
                                    : 'Account is disabled',
                              ),
                              value: currentUser.enabled,
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      _updateEnabled(currentUser.id, value);
                                    },
                              secondary: Icon(
                                currentUser.enabled
                                    ? Icons.check_circle
                                    : Icons.block,
                                color: currentUser.enabled
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Images section
                    const Text(
                      'Uploaded Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildImageWidget(
                      currentUser.universityIdImage,
                      'University ID',
                    ),
                    const SizedBox(height: 16),
                    _buildImageWidget(
                      currentUser.driversLicenseImage,
                      'Driver\'s License',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentUserIndex > 0
                      ? () {
                          setState(() {
                            _currentUserIndex--;
                          });
                        }
                      : null,
                  tooltip: 'Previous user',
                ),
                Text(
                  '${_currentUserIndex + 1} / ${_users.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentUserIndex < _users.length - 1
                      ? () {
                          setState(() {
                            _currentUserIndex++;
                          });
                        }
                      : null,
                  tooltip: 'Next user',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

