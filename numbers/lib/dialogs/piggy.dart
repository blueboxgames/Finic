import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/punchbutton.dart';

import 'dialogs.dart';
import 'toast.dart';

// ignore: must_be_immutable
class PiggyDialog extends AbstractDialog {
  static int capacity = 20;
  static int autoAppearance = 0;
  PiggyDialog()
      : super(DialogMode.piggy,
            height: 272.d, title: "piggy_l".l(), padding: EdgeInsets.all(18.d));
  @override
  _PiggyDialogState createState() => _PiggyDialogState();
}

class _PiggyDialogState extends AbstractDialogState<PiggyDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    widget.closeButton = GestureDetector(
        child:
            Column(children: [SVG.show("close", 14.d), SizedBox(height: 8.d)]),
        onTap: () {
          widget.onWillPop?.call();
          Navigator.of(context).pop();
        });
    widget.child = Stack(alignment: Alignment.topCenter, children: [
      SVG.show("piggy", 144.d),
      Positioned(
          top: 112.d,
          child: Text("piggy_message".l(), style: theme.textTheme.caption)),
      _slider(theme, Pref.coinPiggy.value, PiggyDialog.capacity)
    ]);
    return super.build(context);
  }

  Widget _slider(ThemeData theme, int value, int maxValue) {
    var rewardAvailble = value >= maxValue;
    if (rewardAvailble) {
      return PunchButton(
          height: 76.d,
          width: 160.d,
          bottom: 4.d,
          // right: 4.d,
          cornerRadius: 16.d,
          padding: EdgeInsets.fromLTRB(12.d, 4.d, 12.d, 12.d),
          isEnable: rewardAvailble && Ads.isReady(),
          colors: TColors.orange.value,
          errorMessage: Toast("ads_unavailable".l(), monoIcon: "0"),
          onTap: () {
            PiggyDialog.autoAppearance = 0;
            buttonsClick(context, "piggy", 0, adId: AdPlace.Rewarded);
          },
          content:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            SVG.icon("0", theme),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("free_l".l(), style: theme.textTheme.headline5),
                  Row(children: [
                    SVG.show("coin", 28.d),
                    Text("+100", style: theme.textTheme.headline6)
                  ])
                ])
          ]));
    }
    var label = "$value / $maxValue";
    return Positioned(
        height: 32.d,
        bottom: 12.d,
        width: 200.d,
        child: Stack(alignment: Alignment.centerLeft, children: [
          Positioned(
              height: 20.d,
              left: 26.d,
              right: 0,
              child: Container(
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12.d),
                          bottomRight: Radius.circular(12.d)),
                      child: LinearProgressIndicator(value: value / maxValue)),
                  decoration: _badgeDecoration())),
          SVG.show("coin", 32.d),
          Positioned(
              left: 32.d,
              right: 4.d,
              child: Text(label,
                  style: TextStyle(fontSize: 12.d, color: Colors.black),
                  textAlign: TextAlign.center)),
        ]));
  }

  Decoration _badgeDecoration({double? cornerRadius}) {
    return BoxDecoration(
        boxShadow: [
          BoxShadow(
              blurRadius: 3.d, color: Colors.black, offset: Offset(0.5.d, 1.d))
        ],
        color: Colors.pink[700],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(cornerRadius ?? 12.d)));
  }
}