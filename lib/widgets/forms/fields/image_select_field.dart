import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/helpers/functions/image_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/image_preview.dart';
import 'package:gymvision/widgets/forms/fields/custom_field.dart';

class ImageSelectField extends StatelessWidget {
  final String label;
  final List<File>? images;
  final Function(List<File>? newImages) onChange;

  const ImageSelectField({
    super.key,
    required this.label,
    this.images,
    required this.onChange,
  });

  final double _materialFieldPadding = 2.5;
  final double _materialIconToValuePadding = 8.0;

  @override
  Widget build(BuildContext context) {
    Future<void> onOpenPicker() => ImageHelper.openImagePicker(context, onChange, skipConfirm: true);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: _materialFieldPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: images == null || images!.isEmpty
                ? CustomField(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onOpenPicker,
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: _materialFieldPadding),
                        child: Row(children: [
                          Icon(Icons.image_rounded, color: Theme.of(context).colorScheme.secondary),
                          Padding(padding: EdgeInsetsGeometry.all(_materialIconToValuePadding)),
                          Text(
                            'Select $label',
                            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                          ),
                        ]),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images!.length,
                      separatorBuilder: (_, __) => const Padding(padding: EdgeInsetsGeometry.all(5)),
                      itemBuilder: (context, index) => ImagePreview(
                        image: images![index],
                        onDelete: () {
                          final newImages = List<File>.from(images!);
                          newImages.removeAt(index);
                          onChange(newImages.isEmpty ? null : newImages);
                        },
                      ),
                    ),
                  ),
          ),
          if (images != null && images!.isNotEmpty)
            Padding(
              padding: const EdgeInsetsGeometry.only(left: 15, right: 5),
              child: Row(children: [
                Button.edit(onTap: onOpenPicker),
                Button.clear(useIcon: true, onTap: () => onChange(null)),
              ]),
            )
        ],
      ),
    );
  }
}
