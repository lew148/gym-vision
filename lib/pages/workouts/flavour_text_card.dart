import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/flavour_text_schedule.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/pages/common_ui.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to dismiss Flavour Text')));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlavourTextSchedule>(
      future: flavourTextSchedule,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.dismissed) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Expanded(
                child: CommonUi.getCard(
                  color: Theme.of(context).colorScheme.primary,
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            snapshot.data!.flavourText!.message,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => onDismissTap(snapshot.data!),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSecondary,
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
