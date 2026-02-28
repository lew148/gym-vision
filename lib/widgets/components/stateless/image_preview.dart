import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';

class ImagePreview extends StatelessWidget {
  final File image;
  final Function()? onDelete;

  const ImagePreview({
    super.key,
    required this.image,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: EdgeInsets.zero,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.file(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(smallBorderRadius),
              child: Image.file(image, fit: BoxFit.cover),
            ),
            if (onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onDelete!(),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.shadow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
