import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/flavour_text_schedule.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/common/common_ui.dart';

class FlavourTextCard extends StatefulWidget {
  const FlavourTextCard({super.key});

  @override
  State<StatefulWidget> createState() => _FlavourTextCardState();
}

class _FlavourTextCardState extends State<FlavourTextCard> {
  final Future<FlavourTextSchedule> flavourTextSchedule = FlavourTextScheduleModel.getTodaysFlavourTextSchedule();

  void onDismissTap(FlavourTextSchedule fts) async {
    try {
      await FlavourTextScheduleModel.setFlavourTextScheduleDismissed(fts);
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to dismiss Flavour Text');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlavourTextSchedule>(
      future: flavourTextSchedule,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.dismissed) return const SizedBox.shrink();

        return Row(
          children: [
            Expanded(
              child: CommonUI.getCard(
                context,
                color: Theme.of(context).colorScheme.primary,
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          snapshot.data!.flavourText!.message,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      const Padding(padding: EdgeInsetsGeometry.all(5)),
                      InkWell(
                        onTap: () => onDismissTap(snapshot.data!),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
