import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

import 'all.dart';

class PauseOverlay extends StatefulWidget {
  PauseOverlay({Key? key}) : super(key: key);
  @override
  _PauseOverlayState createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Overlays.basic(context,
        title: "Pause",
        hasChrome: false,
        hasClose: false,
        padding: EdgeInsets.only(top: 10.d),
        height: 180.d,
        content: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
                height: 76.d,
                width: 146.d,
                top: 0,
                left: 0,
                child: Buttons.button(
                    onTap: () => Navigator.of(context).pop("reset"),
                    colors: Themes.swatch[TColors.green],
                    cornerRadius: 16.d,
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SVG.show("reset", 26),
                          Text("Restart", style: theme.textTheme.headline5)
                        ]))),
            Positioned(
                height: 76.d,
                width: 146.d,
                top: 0,
                right: 0,
                child: Buttons.button(
                    onTap: () => Navigator.of(context).pop("resume"),
                    colors: Themes.swatch[TColors.blue],
                    cornerRadius: 16.d,
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SVG.show("play", 26),
                          Text("Continue", style: theme.textTheme.headline5)
                        ]))),
            Positioned(
                height: 76.d,
                width: 76.d,
                top: 90.d,
                left: 66.d,
                child: Buttons.button(
                    onTap: () => Navigator.of(context).pop("resume"),
                    colors: Themes.swatch[TColors.orange],
                    cornerRadius: 16.d,
                    content: Center(
                    ))),
            Positioned(
                height: 76.d,
                width: 76.d,
                top: 90.d,
                right: 66.d,
                child: Buttons.button(
                    onTap: () {
                      Pref.isMute.set(Pref.isMute.value == 0 ? 1 : 0);
                      setState(() {});
                    },
                    colors: Themes.swatch[TColors.yellow],
                    cornerRadius: 16.d,
                    content: Center(
                        child: SVG.show("mute-${Pref.isMute.value}", 32)))),
          ],
        ));
  }
}
