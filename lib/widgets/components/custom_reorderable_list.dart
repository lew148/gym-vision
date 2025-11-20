import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';

class CustomReorderableList extends StatefulWidget {
  final void Function(int oldIndex, int newIndex) onReorder;
  final List<Widget> children;

  const CustomReorderableList({
    super.key,
    required this.onReorder,
    required this.children,
  });

  @override
  State<CustomReorderableList> createState() => _CustomReorderableListState();
}

class _CustomReorderableListState extends State<CustomReorderableList> {
  late List<Widget> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.children;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(clipRectRadius),
      child: ReorderableListView.builder(
        itemBuilder: (context, index) => _items[index],
        itemCount: _items.length,
        onReorder: (int currentIndex, int newIndex) {
          try {
            HapticFeedback.heavyImpact();
            if (newIndex > currentIndex) newIndex -= 1; // to fix issues in ReorderableListView
            setState(() {
              final item = _items.removeAt(currentIndex);
              _items.insert(newIndex, item);
            });

            widget.onReorder(currentIndex, newIndex);
          } catch (ex) {
            AppHelper.showSnackBar(context, 'Failed to reorder');
          }
        },
      ),
    );
  }
}
