import 'package:flutter/material.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoad extends StatelessWidget {
  final double? height;

  const ShimmerLoad({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppHelper.isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: AppHelper.isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade100,
      child: CustomCard(
        child: Container(
          height: height ?? 15,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
