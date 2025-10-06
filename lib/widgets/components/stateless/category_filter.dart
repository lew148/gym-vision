import 'package:flutter/material.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/forms/category_picker.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> filterCategories;
  final Function(List<Category>) onChange;

  const CategoryFilter({
    super.key,
    required this.filterCategories,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (filterCategories.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              children: filterCategories
                  .map((c) => PropDisplay(
                        text: c.displayName,
                        size: PropDisplaySize.small,
                      ))
                  .toList(),
            ),
          ),
          Button.x(onTap: () => onChange([])),
        ],
        Button(
          icon: Icons.category_rounded,
          onTap: () => showCloseableBottomSheet(
            context,
            CateogryPicker(selectedCategories: filterCategories, onChange: onChange, includeMiscCategories: false),
          ),
          style: ButtonCustomStyle(padding: const EdgeInsets.all(10)),
        ),
      ],
    );
  }
}
