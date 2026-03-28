import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/flavour_text_schedule.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';

class FlavourTextCard extends StatefulWidget {
  const FlavourTextCard({super.key});

  @override
  State<StatefulWidget> createState() => _FlavourTextCardState();
}

class _FlavourTextCardState extends State<FlavourTextCard> {
  Future<FlavourTextSchedule> flavourTextSchedule = FlavourTextScheduleModel.getTodaysFlavourTextSchedule();

  void onDismissTap(FlavourTextSchedule fts) async {
    try {
      await FlavourTextScheduleModel.setFlavourTextScheduleDismissed(fts);
      setState(() {
        flavourTextSchedule = FlavourTextScheduleModel.getTodaysFlavourTextSchedule();
      });
    } catch (ex) {
      if (!mounted) return;
      ToastHelper.showFailureToast(context, message: 'Failed to dismiss Flavour Text!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlavourTextSchedule>(
      future: flavourTextSchedule,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final fts = snapshot.data!;

        return AnimatedSize(
          onEnd: () => setState(() {
            flavourTextSchedule = FlavourTextScheduleModel.getTodaysFlavourTextSchedule();
          }),
          duration: const Duration(milliseconds: 300),
          reverseDuration: Duration.zero,
          curve: Curves.easeInOut,
          child: fts.dismissed
              ? SizedBox.shrink()
              : Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        customColor: Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  fts.getFlavourText()!.message,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.00,
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsetsGeometry.all(5)),
                              InkWell(
                                onTap: () => onDismissTap(fts),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  weight: 20,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
