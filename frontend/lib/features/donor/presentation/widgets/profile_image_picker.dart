import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/image_upload_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/donor_models.dart';
import '../../providers/donor_provider.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showPickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _deletePhoto();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _cropAndCompressImage(pickedFile.path);
      }
    } catch (e) {
      _showError('Failed to pick image: \$e');
    }
  }

  Future<void> _cropAndCompressImage(String path) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        // Compress image
        final dir = await getTemporaryDirectory();
        final targetPath = '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
          croppedFile.path, 
          targetPath,
          quality: 80,
          minWidth: 500,
          minHeight: 500,
        );

        if (compressedFile != null) {
          _uploadImage(File(compressedFile.path));
        }
      }
    } catch (e) {
      _showError('Failed to process image: \$e');
    }
  }

  Future<void> _uploadImage(File file) async {
    final profile = ref.read(donorProfileProvider).valueOrNull;
    if (profile == null) {
      _showError('You must create a profile first.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final uploadService = ref.read(imageUploadServiceProvider);
      final secureUrl = await uploadService.uploadImage(
        imageFile: file,
        onProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      await _updateProfileWithImageUrl(secureUrl, profile);
      _showSuccess('Profile picture updated successfully!');
    } catch (e) {
      _showError('Failed to upload image. Tap to retry.');
      // Optional: Store the file locally so the user can hit a retry button, 
      // but simpler to just let them select again or implement a retry prompt.
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deletePhoto() async {
    final profile = ref.read(donorProfileProvider).valueOrNull;
    if (profile == null || profile.profileImageUrl == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Send a request to remove the image URL from the profile
      final request = UpdateDonorProfileRequest(
        bloodGroup: profile.bloodGroup,
        dateOfBirth: profile.dateOfBirth,
        gender: profile.gender,
        weight: profile.weight,
        district: profile.district,
        city: profile.city,
        latitude: profile.latitude,
        longitude: profile.longitude,
        lastDonationDate: profile.lastDonationDate,
        medicalNotes: profile.medicalNotes,
        profileImageUrl: null, // explicitly clear it
      );

      final notifier = ref.read(donorProfileProvider.notifier);
      await notifier.createOrUpdateProfile(request);

      final state = ref.read(donorProfileProvider);
      if (state.hasError) throw state.error!;

      _showSuccess('Profile picture removed.');
    } catch (e) {
      _showError('Failed to remove photo.');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _updateProfileWithImageUrl(String url, DonorProfileDto profile) async {
    final request = UpdateDonorProfileRequest(
      bloodGroup: profile.bloodGroup,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      weight: profile.weight,
      district: profile.district,
      city: profile.city,
      latitude: profile.latitude,
      longitude: profile.longitude,
      lastDonationDate: profile.lastDonationDate,
      medicalNotes: profile.medicalNotes,
      profileImageUrl: url,
    );

    final notifier = ref.read(donorProfileProvider.notifier);
    await notifier.createOrUpdateProfile(request);
    
    final state = ref.read(donorProfileProvider);
    if (state.hasError) {
      throw state.error!;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(donorProfileProvider).valueOrNull;
    final imageUrl = profile?.profileImageUrl;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                    ),
                  )
                : imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey, // Assuming colorScheme fallback
                        semanticLabel: 'Default Profile Picture',
                      ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _isUploading ? null : _showPickerOptions,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                  semanticLabel: 'Edit Profile Picture',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
