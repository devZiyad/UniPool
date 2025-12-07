import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/user_settings.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/app_drawer.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoadingSettings = false;
  bool _isSavingSettings = false;
  final Map<String, bool> _uploadingStatus = {
    'university_card': false,
    'driving_license': false,
  };
  User? _user;
  UserSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadSettings();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        _user = user;
        _fullNameController = TextEditingController(text: user.fullName);
        _phoneNumberController = TextEditingController(
          text: user.phoneNumber ?? '',
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoadingSettings = true;
    });

    try {
      final settings = await UserService.getSettings();
      setState(() {
        _settings = settings;
        _isLoadingSettings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSettings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    }
  }

  Future<void> _updateAutoAcceptBookings(bool value) async {
    setState(() {
      _isSavingSettings = true;
    });

    try {
      final updatedSettings = await UserService.updateSettings(
        autoAcceptBookings: value,
      );
      setState(() {
        _settings = updatedSettings;
        _isSavingSettings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isSavingSettings = false;
        // Revert the toggle if update failed
        if (_settings != null) {
          _settings = _settings!.copyWith(autoAcceptBookings: !value);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating settings: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await UserService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
      );

      Provider.of<AuthProvider>(context, listen: false).setUser(updatedUser);

      if (mounted) {
        setState(() {
          _user = updatedUser;
          _isSaving = false;
        });
        // Update auth provider with new user data
        Provider.of<AuthProvider>(context, listen: false).setUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Visual cue for phone number if missing
                            if (_user != null &&
                                (_user!.phoneNumber == null ||
                                    _user!.phoneNumber!.isEmpty)) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  border: Border.all(
                                    color: Colors.orange[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Add your number to be able to book and be verified faster',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[900],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: _phoneNumberController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter your phone number',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: (_user?.phoneNumber == null ||
                                            _user!.phoneNumber!.isEmpty)
                                        ? Colors.orange
                                        : Colors.grey,
                                    width: (_user?.phoneNumber == null ||
                                            _user!.phoneNumber!.isEmpty)
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: (_user?.phoneNumber == null ||
                                            _user!.phoneNumber!.isEmpty)
                                        ? Colors.orange
                                        : Colors.grey,
                                    width: (_user?.phoneNumber == null ||
                                            _user!.phoneNumber!.isEmpty)
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: (_user?.phoneNumber == null ||
                                            _user!.phoneNumber!.isEmpty)
                                        ? Colors.orange
                                        : Colors.green,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: (_user?.phoneNumber == null ||
                                          _user!.phoneNumber!.isEmpty)
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Account Information Card
                    if (_user != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Email', _user!.email),
                              _buildInfoRow(
                                'University ID',
                                _user!.universityId,
                              ),
                              _buildInfoRow('Role', _user!.role),
                              // Change Role button (only if university ID is verified)
                              if (_user!.universityIdVerified &&
                                  _user!.role.toUpperCase() != 'ADMIN') ...[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/role-selection',
                                    );
                                  },
                                  icon: const Icon(Icons.swap_horiz),
                                  label: const Text('Change Role'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                              _buildInfoRow(
                                'Wallet Balance',
                                'BD ${_user!.walletBalance.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 8),
                              _buildVerificationStatus(
                                'University ID Verified',
                                _user!.universityIdVerified,
                                'Your university ID verification status',
                              ),
                              _buildVerificationStatus(
                                'Driver Verified',
                                _user!.verifiedDriver,
                                'Your driver verification status',
                              ),
                              if (_user!.avgRatingAsDriver != null)
                                _buildInfoRow(
                                  'Driver Rating',
                                  '${_user!.avgRatingAsDriver!.toStringAsFixed(1)} (${_user!.ratingCountAsDriver} reviews)',
                                ),
                              if (_user!.avgRatingAsRider != null)
                                _buildInfoRow(
                                  'Rider Rating',
                                  '${_user!.avgRatingAsRider!.toStringAsFixed(1)} (${_user!.ratingCountAsRider} reviews)',
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Document Uploads Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Document Uploads',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDocumentUploadCard(
                              'University Card',
                              'Upload your university ID or anything proving university student status',
                              'university_card',
                            ),
                            const SizedBox(height: 16),
                            _buildDocumentUploadCard(
                              'Driver\'s License',
                              'Upload your driver\'s license (optional)',
                              'driving_license',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Settings Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingSettings)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_settings != null)
                              SwitchListTile(
                                title: const Text('Auto-Accept Bookings'),
                                subtitle: const Text(
                                  'Automatically accept booking requests without manual approval',
                                ),
                                value: _settings!.autoAcceptBookings,
                                onChanged: _isSavingSettings
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _settings = _settings!.copyWith(
                                            autoAcceptBookings: value,
                                          );
                                        });
                                        _updateAutoAcceptBookings(value);
                                      },
                                secondary: const Icon(Icons.check_circle_outline),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(
    String label,
    bool isVerified,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.pending,
                      color: isVerified ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUploadOptions(String documentType) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select upload option',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera, documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery, documentType);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _uploadingStatus[documentType] = true;
        });

        try {
          User updatedUser;
          if (documentType == 'university_card') {
            updatedUser = await UserService.uploadUniversityId(image);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('University ID uploaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else if (documentType == 'driving_license') {
            updatedUser = await UserService.uploadDriversLicense(image);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Driver\'s license uploaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            return;
          }

          if (mounted) {
            setState(() {
              _user = updatedUser;
              _uploadingStatus[documentType] = false;
            });
            // Update auth provider with new user data
            Provider.of<AuthProvider>(context, listen: false)
                .setUser(updatedUser);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _uploadingStatus[documentType] = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadingStatus[documentType] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Widget _buildDocumentUploadCard(
    String title,
    String description,
    String documentType,
  ) {
    final hasImage = documentType == 'university_card'
        ? (_user?.universityIdImage != null &&
            _user!.universityIdImage!.isNotEmpty)
        : (_user?.driversLicenseImage != null &&
            _user!.driversLicenseImage!.isNotEmpty);
    final isUploading = _uploadingStatus[documentType] ?? false;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                ],
              ],
            ),
            if (hasImage && _user != null) ...[
              const SizedBox(height: 12),
              _buildImagePreview(
                documentType == 'university_card'
                    ? _user!.universityIdImage!
                    : _user!.driversLicenseImage!,
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isUploading ? null : () => _showUploadOptions(documentType),
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(hasImage ? Icons.refresh : Icons.upload),
              label: Text(hasImage ? 'Update' : 'Upload'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imageData) {
    Uint8List? imageBytes;
    try {
      // Handle base64 image data (with or without data URI prefix)
      String base64String = imageData;
      if (base64String.contains(',')) {
        base64String = base64String.split(',')[1];
      }
      imageBytes = base64Decode(base64String);
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error loading image'),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        imageBytes,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
