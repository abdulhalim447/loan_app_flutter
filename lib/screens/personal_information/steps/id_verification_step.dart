import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
// Use dart:convert for base64Encode
// Add math import
// Add dart:typed_data for Uint8List

// Simple class for custom drawing canvas
class HandSignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;
  final double strokeWidth;

  HandSignaturePainter(this.points, this.strokeColor, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(HandSignaturePainter oldDelegate) => true;
}

// Widget for custom drawing canvas
class HandSignatureView extends StatefulWidget {
  final GlobalKey<HandSignatureViewState> signatureKey;
  final Color strokeColor;
  final Color backgroundColor;
  final double strokeWidth;

  const HandSignatureView({
    required this.signatureKey,
    this.strokeColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.strokeWidth = 3.0,
  }) : super(key: signatureKey);

  @override
  HandSignatureViewState createState() => HandSignatureViewState();
}

class HandSignatureViewState extends State<HandSignatureView> {
  final List<Offset?> _points = [];

  bool get isEmpty => _points.isEmpty;

  void clear() {
    setState(() {
      _points.clear();
    });
  }

  Future<ui.Image> toImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(300, 200);

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = widget.backgroundColor,
    );

    // Draw signature
    final paint = Paint()
      ..color = widget.strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = widget.strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      } else if (_points[i] != null && _points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [_points[i]!], paint);
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _points.add(details.localPosition);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _points.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _points.add(null); // Add null to break the line
          });
        },
        child: CustomPaint(
          painter: HandSignaturePainter(
              _points, widget.strokeColor, widget.strokeWidth),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class IdVerificationStepScreen extends StatefulWidget {
  const IdVerificationStepScreen({super.key});

  @override
  _IdVerificationStepScreenState createState() =>
      _IdVerificationStepScreenState();
}

class _IdVerificationStepScreenState extends State<IdVerificationStepScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final GlobalKey<HandSignatureViewState> _webSignatureKey = GlobalKey();
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

              // Signature section - different implementations for web vs mobile
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
              // Add change/replace button when an image is already selected
              if (hasImage && !isReadOnly) ...[
                Spacer(),
                TextButton.icon(
                  onPressed: onUpload,
                  icon: Icon(Icons.change_circle_outlined, size: 18),
                  label: Text(
                    'Change',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
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
            _buildImagePreview(
              context,
              imagePath,
              imageUrl: imageUrl,
              onRemove: isReadOnly
                  ? null
                  : () {
                      if (title.contains('Front')) {
                        Provider.of<PersonalInfoProvider>(context,
                                listen: false)
                            .saveImagePath('front', '');
                        Provider.of<PersonalInfoProvider>(context,
                                listen: false)
                            .frontIdImageBytes = null;
                      } else if (title.contains('Back')) {
                        Provider.of<PersonalInfoProvider>(context,
                                listen: false)
                            .saveImagePath('back', '');
                        Provider.of<PersonalInfoProvider>(context,
                                listen: false)
                            .backIdImageBytes = null;
                      } else if (title.contains('Selfie')) {
                        Provider.of<PersonalInfoProvider>(context,
                                listen: false)
                            .saveImagePath('selfie', '');
                        Provider.of<PersonalInfoProvider>(context,
                                listen: false)
                            .selfieWithIdImageBytes = null;
                      }
                      setState(() {}); // Refresh the UI
                    },
              onTap: isReadOnly
                  ? null
                  : onUpload, // Allow tapping on the image to replace it
            )
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // Handle taps to replace the image
      child: Container(
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
            if (onTap != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Tap to change',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath, String? imageUrl) {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    // 1. First check for API provided image URLs
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
    }
    // 2. For web platform, check binary data first
    else if (kIsWeb) {
      // Determine which binary data to display based on the image path
      Uint8List? imageBytes;
      if (imagePath == null) {
        return _buildNoImagePlaceholder();
      } else if (imagePath.contains('front') ||
          imagePath == 'image_selected' && provider.frontIdImageBytes != null) {
        imageBytes = provider.frontIdImageBytes;
      } else if (imagePath.contains('back') ||
          imagePath == 'image_selected' && provider.backIdImageBytes != null) {
        imageBytes = provider.backIdImageBytes;
      } else if (imagePath.contains('selfie') ||
          imagePath == 'image_selected' &&
              provider.selfieWithIdImageBytes != null) {
        imageBytes = provider.selfieWithIdImageBytes;
      } else if (imagePath.contains('signature') ||
          imagePath == 'image_selected' &&
              provider.signatureImageBytes != null) {
        imageBytes = provider.signatureImageBytes;
      }

      // Display image from bytes if available
      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error displaying image from bytes: $error');
            return _buildImageErrorWidget();
          },
        );
      }

      // Fallback for web if URL-like path is provided
      if (imagePath.startsWith('blob:') || imagePath.startsWith('data:')) {
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading web image URL: $error');
            return _buildImageErrorWidget();
          },
        );
      }

      // No valid image source found for web
      return _buildInvalidImageWidget();
    }
    // 3. For mobile/desktop platforms, handle file paths
    else if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (!file.existsSync()) {
          debugPrint('Image file does not exist: $imagePath');
          return _buildInvalidImageWidget();
        }

        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading file image: $error');
            return _buildImageErrorWidget();
          },
        );
      } catch (e) {
        debugPrint('Error processing image file: $e');
        return _buildInvalidImageWidget();
      }
    }
    // 4. No image available
    else {
      return _buildNoImagePlaceholder();
    }
  }

  // Helper widgets for image display
  Widget _buildNoImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'No image available',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildImageErrorWidget() {
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
  }

  Widget _buildInvalidImageWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 40, color: Colors.red),
        SizedBox(height: 8),
        Text(
          'Invalid image file',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(
      BuildContext context, PersonalInfoProvider provider,
      {bool isReadOnly = false}) {
    final hasSignature =
        provider.hasSignature || provider.signatureImageUrl != null;

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
          color: hasSignature ? Colors.cyan : Colors.grey.shade300,
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
                color: hasSignature ? Colors.cyan : Colors.grey.shade600,
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
              // Add change option for signature
              if (hasSignature && !isReadOnly) ...[
                Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Clear existing signature and show the uploader
                    provider.clearSignature();
                    setState(() {});
                  },
                  icon: Icon(Icons.change_circle_outlined, size: 18),
                  label: Text(
                    'Change',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
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
          if (hasSignature)
            _buildImagePreview(
              context,
              provider.signatureImagePath,
              imageUrl: provider.signatureImageUrl,
              onRemove: isReadOnly
                  ? null
                  : () {
                      provider.clearSignature();
                      setState(() {}); // Refresh UI
                    },
              onTap: isReadOnly
                  ? null
                  : () {
                      // Clear existing signature and show the uploader
                      provider.clearSignature();
                      setState(() {});
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
      onTap: () async {
        // Check and handle permissions before proceeding with image upload
        await _handleImageUpload(context, onUpload);
      },
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

  // New method to handle the permission flow when user taps to upload an image
  Future<void> _handleImageUpload(
      BuildContext context, VoidCallback onUpload) async {
    // On Android 14+, we need to use a different approach for photo picking
    if (Platform.isAndroid) {
      try {
        // Directly invoke the upload callback which will use the picker
        // The picker internally handles the new Android 14 photo picker API
        onUpload();
      } catch (e) {
        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Could not access media. Please check your app permissions in Settings.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
      }
    } else {
      // For iOS or other platforms, just invoke the callback directly
      onUpload();
    }
  }

  Widget _buildSignatureUploader(BuildContext context) {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    // For web, provide a drawing canvas using our custom implementation
    if (kIsWeb) {
      return Column(
        children: [
          // Web-friendly drawing canvas
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
                  child: HandSignatureView(
                    signatureKey: _webSignatureKey,
                    backgroundColor: Colors.white,
                    strokeColor: Colors.black,
                    strokeWidth: 3.0,
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
                  onPressed: () => _saveWebSignature(context),
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
                    _webSignatureKey.currentState?.clear();
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
                // For web, path will be a placeholder and bytes will be stored in provider
                setState(() {}); // Trigger rebuild to show the image
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

    // Original signature pad implementation for non-web platforms
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

  // Method to save web signature
  Future<void> _saveWebSignature(BuildContext context) async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    try {
      // Check if signature is empty
      if (_webSignatureKey.currentState?.isEmpty ?? true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please draw your signature first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get signature as image
      final signatureImage = await _webSignatureKey.currentState?.toImage();
      if (signatureImage == null) {
        throw Exception('Failed to capture signature');
      }

      // Convert to PNG byte data
      final byteData =
          await signatureImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert signature to bytes');
      }

      // Convert to bytes list for direct storage
      final bytes = byteData.buffer.asUint8List();

      // Save the raw image bytes for direct upload
      provider.saveImageBytes('signature', bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signature saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error saving web signature: $e');
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

    // Check if running on web platform
    if (kIsWeb) {
      try {
        // Web implementation for image picking
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery, // Only gallery works reliably on web
          imageQuality: 70,
        );

        if (pickedFile == null || !mounted) return null;

        if (kDebugMode) {
          print(
              'Web image picked: ${pickedFile.name}, path: ${pickedFile.path}');
        }

        // Read the file as bytes for direct upload
        try {
          // Read the file as bytes
          final bytes = await pickedFile.readAsBytes();
          if (kDebugMode) {
            print('Image bytes length: ${bytes.length}');
          }

          // Save the raw bytes directly for upload
          provider.saveImageBytes(type, bytes);

          // Return a placeholder path that indicates we have an image
          return 'image_selected';
        } catch (e) {
          if (kDebugMode) {
            print('Error processing web image: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return null;
        }
      } catch (e) {
        if (!mounted) return null;
        debugPrint('Web image picker error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not select image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }

    // Mobile implementation with improved Android 14 support
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

      // Show image source selection with proper error handling for Android 14
      ImageSource? source;
      try {
        source = await showModalBottomSheet<ImageSource>(
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
      } catch (e) {
        debugPrint('Error showing bottom sheet: $e');
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not show image picker. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      if (source == null || !mounted) return null;

      // Check camera permission only if camera is selected
      if (source == ImageSource.camera) {
        try {
          final cameraStatus = await Permission.camera.status;
          if (!cameraStatus.isGranted) {
            final result = await Permission.camera.request();
            if (!result.isGranted) {
              if (!mounted) return null;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Camera permission is required to take a photo'),
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
          }
        } catch (e) {
          debugPrint('Camera permission error: $e');
          if (!mounted) return null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not access camera. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return null;
        }
      }

      // Pick and process image with better error handling for Android 14
      XFile? pickedFile;
      try {
        pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 50,
          maxWidth: 1280,
          maxHeight: 720,
        );
      } on Exception catch (e) {
        debugPrint('Error picking image: $e');
        if (!mounted) return null;

        // Special handling for Android permission issues
        if (e.toString().contains('permission') ||
            e.toString().contains('Permission')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Permission denied. Please grant access in Settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () async {
                  await openAppSettings();
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not select image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      if (pickedFile == null || !mounted) return null;

      // Read file and create a copy in temp directory
      try {
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
                  : type == 'selfie'
                      ? provider.selfieWithIdImagePath
                      : provider.signatureImagePath;
          if (oldPath != null &&
              oldPath.isNotEmpty &&
              oldPath != 'image_selected') {
            try {
              final oldFile = File(oldPath);
              if (await oldFile.exists()) {
                await oldFile.delete();
              }
            } catch (e) {
              debugPrint('Error cleaning up old file: $e');
            }
          }

          // For mobile, we use file paths but also store the bytes for direct upload
          provider.saveImagePath(type, filePath);

          // Also save the bytes for potential direct upload
          provider.saveImageBytes(type, bytes);

          return filePath;
        } else {
          if (!mounted) return null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not save the image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return null;
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error processing the selected image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
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

  // Helper method to determine MIME type from filename
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png'; // Default to PNG
    }
  }
}
