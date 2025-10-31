import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/common_functions.dart';

class CustomReorderableList extends StatefulWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;

  const CustomReorderableList({
    super.key,
    required this.children,
    required this.onReorder,
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
      child: ReorderableListView(
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
            showSnackBar(context, 'Failed to reorder');
          }
        },
        children: _items,
      ),
    );
  }
}
