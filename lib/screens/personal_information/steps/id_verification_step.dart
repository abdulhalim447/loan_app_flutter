import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' show min;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;

class IdVerificationStepScreen extends StatefulWidget {
  const IdVerificationStepScreen({super.key});

  @override
  _IdVerificationStepScreenState createState() =>
      _IdVerificationStepScreenState();
}

class _IdVerificationStepScreenState extends State<IdVerificationStepScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nidNameController = TextEditingController();
  final TextEditingController _nidNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? validateNidName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name as per ID is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateNidNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID number is required';
    }
    if (value.length < 5) {
      return 'Please enter a valid ID number';
    }
    return null;
  }

  bool validateImages(BuildContext context, PersonalInfoProvider provider) {
    bool isValid = true;
    if (provider.frontIdImagePath == null ||
        provider.frontIdImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload front side of your NID'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (provider.backIdImagePath == null || provider.backIdImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload back side of your NID'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (provider.selfieWithIdImagePath == null ||
        provider.selfieWithIdImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please take a selfie with your ID'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    return isValid;
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider =
          Provider.of<PersonalInfoProvider>(context, listen: false);
      _nidNameController.text = provider.nidNameController.text;
      _nidNumberController.text = provider.idController.text;
    });
  }

  @override
  void dispose() {
    _nidNameController.dispose();
    _nidNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        bool isVerified = provider.isVerified;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context),
              SizedBox(height: 24),
              _buildTextField(
                context,
                'Name (as per ID)',
                provider.nidNameController,
                prefixIcon: Icons.badge_outlined,
                validator: validateNidName,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'ID Number',
                provider.idController,
                prefixIcon: Icons.credit_card_outlined,
                validator: validateNidNumber,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 24),

              // Front ID image
              _buildImageSection(
                context,
                'Front of ID',
                'Upload a clear photo of the front side of your ID card',
                provider.frontIdImagePath,
                imageUrl: provider.frontIdImageUrl,
                onUpload: isVerified
                    ? null
                    : () async {
                        final path = await _pickImage(context, 'front');
                        if (path != null) {
                          provider.saveImagePath('front', path);
                        }
                      },
              ),
              SizedBox(height: 16),

              // Back ID image
              _buildImageSection(
                context,
                'Back of ID',
                'Upload a clear photo of the back side of your ID card',
                provider.backIdImagePath,
                imageUrl: provider.backIdImageUrl,
                onUpload: isVerified
                    ? null
                    : () async {
                        final path = await _pickImage(context, 'back');
                        if (path != null) {
                          provider.saveImagePath('back', path);
                        }
                      },
              ),
              SizedBox(height: 16),

              // Selfie with ID
              _buildImageSection(
                context,
                'Selfie with ID',
                'Take a selfie while holding your ID card',
                provider.selfieWithIdImagePath,
                imageUrl: provider.selfieWithIdImageUrl,
                onUpload: isVerified
                    ? null
                    : () async {
                        final path = await _pickImage(context, 'selfie');
                        if (path != null) {
                          provider.saveImagePath('selfie', path);
                        }
                      },
              ),
              SizedBox(height: 16),

              // Signature will be here
              _buildSignatureSection(context, provider),

              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade700, Colors.cyan.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'ID Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'We need to verify your identity to process your loan application. Please provide clear photos of your ID card.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? prefixIcon,
    String? Function(String?)? validator,
    bool isReadOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        enabled: !isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffix: isReadOnly
              ? Icon(Icons.lock, size: 16, color: Colors.grey)
              : null,
        ),
        onChanged: (value) {
          if (!isReadOnly) {
            Provider.of<PersonalInfoProvider>(context, listen: false)
                .saveData();
          }
        },
        validator: isReadOnly ? null : validator,
        autovalidateMode: isReadOnly
            ? AutovalidateMode.disabled
            : AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    String title,
    String description,
    String? imagePath, {
    String? imageUrl,
    VoidCallback? onUpload,
  }) {
    final hasImage = imagePath != null || imageUrl != null;
    final isReadOnly = onUpload == null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: hasImage ? Colors.cyan : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                color: hasImage ? Colors.cyan : Colors.grey.shade600,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isReadOnly) ...[
                SizedBox(width: 8),
                Icon(Icons.lock, size: 16, color: Colors.grey),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          if (hasImage)
            _buildImagePreview(context, imagePath,
                imageUrl: imageUrl,
                onRemove: isReadOnly
                    ? null
                    : () {
                        if (title.contains('Front')) {
                          Provider.of<PersonalInfoProvider>(context,
                                  listen: false)
                              .saveImagePath('front', '');
                        } else if (title.contains('Back')) {
                          Provider.of<PersonalInfoProvider>(context,
                                  listen: false)
                              .saveImagePath('back', '');
                        } else if (title.contains('Selfie')) {
                          Provider.of<PersonalInfoProvider>(context,
                                  listen: false)
                              .saveImagePath('selfie', '');
                        }
                      })
          else
            _buildImageUploader(context, onUpload),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    String? imagePath, {
    String? imageUrl,
    VoidCallback? onRemove,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: _buildImage(imagePath, imageUrl),
          ),
          if (onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: onRemove,
                  tooltip: 'Remove Image',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imagePath, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.red),
              SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.red),
              ),
            ],
          );
        },
      );
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
  }

  Widget _buildSignatureSection(
      BuildContext context, PersonalInfoProvider provider,
      {bool isReadOnly = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: provider.hasSignature || provider.signatureImageUrl != null
              ? Colors.cyan
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.draw_outlined,
                color:
                    provider.hasSignature || provider.signatureImageUrl != null
                        ? Colors.cyan
                        : Colors.grey.shade600,
              ),
              SizedBox(width: 8),
              Text(
                'Signature',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isReadOnly) ...[
                SizedBox(width: 8),
                Icon(Icons.lock, size: 16, color: Colors.grey),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Draw your signature or upload from gallery',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          if (provider.hasSignature || provider.signatureImageUrl != null)
            _buildImagePreview(
              context,
              provider.signatureImagePath,
              imageUrl: provider.signatureImageUrl,
              onRemove: isReadOnly
                  ? null
                  : () {
                      provider.clearSignature();
                    },
            )
          else if (!isReadOnly)
            _buildSignatureUploader(context),
        ],
      ),
    );
  }

  Widget _buildImageUploader(
    BuildContext context,
    VoidCallback? onUpload,
  ) {
    if (onUpload == null) {
      return SizedBox(); // Return empty container if read-only
    }

    return InkWell(
      onTap: onUpload,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Tap to upload',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureUploader(BuildContext context) {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    return Column(
      children: [
        // Draw signature option
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Draw your signature here",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Expanded(
                child: SfSignaturePad(
                  key: _signaturePadKey,
                  backgroundColor: Colors.white,
                  strokeColor: Colors.black,
                  minimumStrokeWidth: 1.0,
                  maximumStrokeWidth: 4.0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveSignature(context),
                icon: Icon(Icons.save),
                label: Text('Save Signature'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _signaturePadKey.currentState?.clear();
                },
                icon: Icon(Icons.clear),
                label: Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        // Upload signature option
        InkWell(
          onTap: () async {
            final path = await _pickImage(context, 'signature');
            if (path != null) {
              provider.saveImagePath('signature', path);
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Upload from gallery',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSignature(BuildContext context) async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    try {
      // Get signature data as image
      final signatureData = await _signaturePadKey.currentState?.toImage();

      if (signatureData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please draw your signature first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Convert to byte data
      final byteData =
          await signatureData.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert signature to bytes');
      }

      // Create file path
      final tempDir = await getTemporaryDirectory();
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      // Save signature to file
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (await file.exists()) {
        // Clean up old file if it exists
        final oldPath = provider.signatureImagePath;
        if (oldPath != null && oldPath.isNotEmpty) {
          try {
            final oldFile = File(oldPath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } catch (e) {
            debugPrint('Error cleaning up old signature file: $e');
          }
        }

        // Save new signature path
        provider.saveImagePath('signature', filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signature saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving signature: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save signature: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _pickImage(BuildContext context, String type) async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    if (!mounted) return null;

    final ImagePicker picker = ImagePicker();
    Directory? tempDir;

    try {
      // First, check if we can access temporary directory
      try {
        tempDir = await getTemporaryDirectory();
        if (!await tempDir.exists()) {
          throw Exception('Temporary directory not available');
        }
      } catch (e) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage access error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      // Check permissions with timeout
      bool hasPermission = false;
      try {
        if (await Permission.camera.isGranted &&
            await Permission.storage.isGranted) {
          hasPermission = true;
        } else {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.camera,
            Permission.storage,
          ].request();

          hasPermission = statuses[Permission.camera]!.isGranted &&
              statuses[Permission.storage]!.isGranted;
        }
      } catch (e) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission check failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      if (!hasPermission) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera and storage permissions are required'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
        return null;
      }

      if (!mounted) return null;

      // Show image source selection
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      context,
                      Icons.camera_alt,
                      'Camera',
                      () => Navigator.pop(context, ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      context,
                      Icons.photo_library,
                      'Gallery',
                      () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );

      if (source == null || !mounted) return null;

      // Pick and process image
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 50,
          maxWidth: 1280,
          maxHeight: 720,
        );

        if (pickedFile == null || !mounted) return null;

        // Read file in chunks to avoid memory issues
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return null;

        final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);

        // Write file
        await file.writeAsBytes(bytes);

        if (await file.exists()) {
          if (!mounted) return null;
          // Clean up old file if it exists
          final oldPath = type == 'front'
              ? provider.frontIdImagePath
              : type == 'back'
                  ? provider.backIdImagePath
                  : provider.selfieWithIdImagePath;
          if (oldPath != null && oldPath.isNotEmpty) {
            try {
              final oldFile = File(oldPath);
              if (await oldFile.exists()) {
                await oldFile.delete();
              }
            } catch (e) {
              debugPrint('Error cleaning up old file: $e');
            }
          }

          provider.saveImagePath(type, filePath);
          return filePath;
        }
      } catch (pickError) {
        if (!mounted) return null;
        debugPrint('Image picker error: $pickError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Could not process the selected image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return null;
      debugPrint('Overall error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return null;
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.cyan.shade800,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
