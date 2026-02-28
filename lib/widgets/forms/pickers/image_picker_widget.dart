import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/image_preview.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final bool multiple;
  final Function(List<File>) onImagesSelected;
  final bool skipConfirm;

  const ImagePickerWidget({
    super.key,
    required this.multiple,
    required this.onImagesSelected,
    this.skipConfirm = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  void _addImages(List<XFile> images) {
    final newImages = images.map((xfile) => File(xfile.path)).toList();

    if (widget.skipConfirm) {
      widget.onImagesSelected(newImages);
      Navigator.pop(context);
      return;
    }

    setState(() {
      if (_images.isEmpty) {
        _images.addAll(newImages);
      } else {
        _images = newImages;
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) throw 'No image captured';
      _addImages([image]);
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) throw 'No image selected';
      _addImages([image]);
    } catch (e) {
      _showError('Failed to get images: $e');
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isEmpty) throw 'No images selected';
      _addImages(images);
    } catch (e) {
      _showError('Failed to get images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _getImagePreview(int index) => ImagePreview(image: _images[index], onDelete: () => _removeImage(index));

  Widget _getDisplay() => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(largeBorderRadius)),
        child: _images.isEmpty
            ? SplashText(
                icon: Icons.image_outlined,
                title: 'No image${widget.multiple ? 's' : ''} selected yet',
                description: 'Choose an option above to get started',
              )
            : _images.length > 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Selected Images (${_images.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) => _getImagePreview(index),
                      ),
                    ],
                  )
                : Center(child: _getImagePreview(0)),
      );

  Future<void> _onImagesSelected() async {
    Navigator.pop(context);
    widget.onImagesSelected(_images);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              title: 'Import Images',
            ),
            const CustomDivider(shadow: true),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Button.elevated(
                      text: 'Camera',
                      icon: Icons.photo_camera_rounded,
                      onTap: _pickImageFromCamera,
                    ),
                  ),
                  const Padding(padding: EdgeInsetsGeometry.all(10)),
                  Expanded(
                    child: Button.elevated(
                      text: 'Gallery',
                      icon: Icons.photo_library_rounded,
                      onTap: widget.multiple ? _pickImagesFromGallery : _pickImageFromGallery,
                    ),
                  ),
                ],
              ),
            ),
            _getDisplay(),
            if (_images.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button.submit(onTap: _onImagesSelected),
                ],
              ),
          ],
        ),
      ),
    );
  }
}