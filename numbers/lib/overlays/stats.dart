import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/utils/Analytics.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';
import 'package:numbers/widgets/widgets.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

import 'all.dart';

class StatsOverlay extends StatefulWidget {
  StatsOverlay({Key? key}) : super(key: key);
  @override
  _StatsOverlayState createState() => _StatsOverlayState();
}

class _StatsOverlayState extends State<StatsOverlay> {
  var _screenshotController = ScreenshotController();
  var shareMode = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Overlays.basic(context, "stats",
        title: "Stats",
        height: 300.d,
        statsButton: SizedBox(),
        padding: EdgeInsets.all(12.d),
        coinButton:
            Positioned(top: 32.d, left: 12.d, child: Components.coins(context)),
        content: Screenshot(
            controller: _screenshotController,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.show("record", 24.d),
                Text(" ${Pref.record.value.format()}",
                    style: theme.textTheme.headline5)
              ]),
              SizedBox(height: 4.d),
              Text("Games Played: ${Pref.playCount.value}",
                  style: theme.textTheme.headline6),
              SizedBox(
                width: 270.d,
                height: 164.d,
                child: GridView.count(
                    padding: EdgeInsets.only(top: 8.d, left: 8.d),
                    crossAxisCount: 3,
                    crossAxisSpacing: 3.d,
                    mainAxisSpacing: 2.d,
                    childAspectRatio: 1.7,
                    children:
                        List.generate(9, (i) => _bigRecordItem(theme, 9 + i))),
              ),
              SizedBox(height: 10.d),
              shareMode
                  ? Padding(
                      padding: EdgeInsets.all(4.d),
                      child: Text(
                          "This is my record. Are you ready to compete with me?",
                          style: theme.textTheme.headline6))
                  : BumpedButton(
                      onTap: _share,
                      colors: TColors.orange.value,
                      content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SVG.icon("8", theme),
                            Text("Share", style: theme.textTheme.headline5)
                          ]))
            ])));
  }

  Widget _bigRecordItem(ThemeData theme, int i) {
    var score = Cell.getScore(i).toString();
    return Row(children: [
      SizedBox(
          width: 44.d,
          height: 44.d,
          child: Widgets.cell(theme, i,
              textStyle: Themes.style(
                  TColors.white.value[3],
                  22.d *
                      Cell.scales[
                          score.length.clamp(0, Cell.scales.length - 1)]))),
      Text(" x ${Prefs.getBig(i)}", style: theme.textTheme.headline6)
    ]);
  }

  _share() async {
    shareMode = true;
    setState(() {});
    final directory = await getApplicationDocumentsDirectory();
    var imagePath = await _screenshotController.captureAndSave(directory.path);
    if (imagePath != null)
      await Share.shareFiles([imagePath],
          text:
              "https://play.google.com/apps/testing/game.block.puzzle.drop.the.number.merge",
          subject: "Drop Number 2048 - Merge Block Puzzle");
    shareMode = false;
    Analytics.share("image", "stats");
    setState(() {});
  }
}
