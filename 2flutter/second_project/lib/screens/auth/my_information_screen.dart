import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/user_service.dart';

class MyInformationScreen extends StatefulWidget {
  const MyInformationScreen({super.key});

  @override
  State<MyInformationScreen> createState() => _MyInformationScreenState();
}

class _MyInformationScreenState extends State<MyInformationScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, XFile?> _uploadedDocuments = {'university_card': null};
  final Map<String, bool> _uploadingStatus = {'university_card': false};

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
        // Store the XFile directly (works on both mobile and web)
        setState(() {
          _uploadedDocuments[documentType] = image;
          _uploadingStatus[documentType] = true;
        });

        try {
          // Upload to backend - only university card is required
          if (documentType == 'university_card') {
            await UserService.uploadUniversityId(image);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('University ID uploaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading image: $e'),
                backgroundColor: Colors.red,
              ),
            );
            // Remove the file if upload failed
            setState(() {
              _uploadedDocuments[documentType] = null;
            });
          }
        } finally {
          if (mounted) {
            setState(() {
              _uploadingStatus[documentType] = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  bool get _allRequiredUploaded {
    return _uploadedDocuments['university_card'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Information'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Open drawer
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDocumentCard(
              'University Card*',
              'Upload your university ID or anything proving university student status',
              'university_card',
              required: true,
            ),
            const SizedBox(height: 16),
            const Text(
              '* This field is required',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _allRequiredUploaded
                  ? () {
                      Navigator.pushNamed(context, '/role-selection');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    String title,
    String description,
    String documentType, {
    required bool required,
  }) {
    final isUploaded = _uploadedDocuments[documentType] != null;
    final isUploading = _uploadingStatus[documentType] ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: GestureDetector(
          onTap: isUploading ? null : () => _showUploadOptions(documentType),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUploading
                  ? Colors.blue
                  : isUploaded
                  ? Colors.green
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isUploaded ? Icons.check : Icons.upload,
                    color: isUploaded ? Colors.white : Colors.grey[600],
                  ),
          ),
        ),
      ),
    );
  }
}
