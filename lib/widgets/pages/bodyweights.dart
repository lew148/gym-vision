import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart' show DialogHelper;
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/scroll_bottom_padding.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/add_bodyweight_form.dart';

class Bodyweights extends StatefulWidget {
  final Function(int templateId)? onAddTap;

  const Bodyweights({
    super.key,
    this.onAddTap,
  });

  @override
  State<Bodyweights> createState() => _BodyweightsState();
}

class _BodyweightsState extends State<Bodyweights> {
  late Future<List<Bodyweight>> _bodyweightsFuture;

  @override
  void initState() {
    super.initState();
    _bodyweightsFuture = BodyweightModel.getBodyweights();
  }

  void reload() => setState(() {
        _bodyweightsFuture = BodyweightModel.getBodyweights();
      });

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      customAppBarTitle: Text('Bodyweights'),
      customAppBarActions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () async {
            await BottomSheetHelper.showCloseableBottomSheet(context, AddBodyWeightForm(date: DateTime.now()));
            reload();
          },
        ),
      ],
      body: FutureBuilder(
        future: _bodyweightsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SplashText.none(
              item: 'bodyweights',
              description: 'Record bodyweight by tapping the +',
            );
          }

          var bodyweights = snapshot.data!;
          bodyweights.sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(clipRectRadius),
                  child: ListView.builder(
                    key: GlobalKey(),
                    itemCount: bodyweights.length + 1, // + 1 for bottom padding
                    itemBuilder: (BuildContext context, int i) => i == bodyweights.length
                        ? const ScrollBottomPadding()
                        : Padding(
                            padding: const EdgeInsetsGeometry.only(bottom: 5),
                            child: CustomCard(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${bodyweights[i].weight} ${bodyweights[i].units}',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      StatDisplay.date(bodyweights[i].date),
                                      StatDisplay.time(bodyweights[i].date),
                                    ],
                                  ),
                                  OptionsMenu(buttons: [
                                    Button(
                                      text: 'Delete Bodyweight',
                                      icon: Icons.delete_rounded,
                                      style: ButtonCustomStyle.redIconOnly(),
                                      onTap: () {
                                        Navigator.pop(context);
                                        DialogHelper.showDeleteConfirm(
                                          context,
                                          'Bodyweight',
                                          () async {
                                            try {
                                              await BodyweightModel.delete(bodyweights[i].id!);
                                            } catch (ex) {
                                              if (!context.mounted) return;
                                              ToastHelper.showFailureToast(
                                                context,
                                                message: 'Failed to delete bodyweight!',
                                              );
                                            }

                                            reload();
                                          },
                                        );
                                      },
                                    ),
                                  ])
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
