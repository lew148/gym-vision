import 'package:flutter/material.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoad extends StatelessWidget {
  final Widget? child;
  final bool? loading;
  final double? height;

  const ShimmerLoad({
    super.key,
    this.child,
    this.loading,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget getShimmerLoad() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
          child: Shimmer.fromColors(
            baseColor: AppHelper.isDarkMode(context) ? Theme.of(context).colorScheme.surface : Colors.grey.shade300,
            highlightColor: AppHelper.isDarkMode(context)
                ? Theme.of(context).colorScheme.shadow
                : Theme.of(context).colorScheme.surface,
            child: CustomCard(
              child: Container(
                height: height ?? 15,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        );

    return child == null
        ? getShimmerLoad()
        : AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: getShimmerLoad(),
            secondChild: child!,
            crossFadeState: loading ?? true ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          );
  }
}
