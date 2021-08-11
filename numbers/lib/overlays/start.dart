import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';
import 'package:numbers/widgets/home.dart';

import 'all.dart';

class StartOverlay extends StatefulWidget {
  StartOverlay({Key? key}) : super(key: key);
  @override
  _StartOverlayState createState() => _StartOverlayState();
}

class _StartOverlayState extends State<StartOverlay> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Overlays.basic(context,
        height: 348.d,
        hasClose: false,
        title: "Select Boost Items",
        padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 14.d),
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Components.startButton(context,
                    "Start the game with black 512!", "512", _onUpdate),
                Components.startButton(context,
                    "Preview the next upcoming black!", "next", _onUpdate)
              ])),
          SizedBox(height: 10.d),
          Container(
              height: 76.d,
              child: BumpedButton(
                  colors: TColors.blue.value,
                  onTap: _onStart,
                  cornerRadius: 16.d,
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SVG.icon("4", theme),
                        SizedBox(width: 12.d),
                        Text("Start",
                            style: theme.textTheme.headline5,
                            textAlign: TextAlign.center)
                      ])))
        ]));
  }

  _onStart() async {
    _onUpdate();
  }

  _onUpdate() => setState(() {});
}
