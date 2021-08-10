import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/overlays/shop.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

class Components {
  static Widget scores(ThemeData theme, {Function()? onTap}) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    return Hero(
        tag: "score",
        child: GestureDetector(
            onTap: onTap,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [
                    Text(Prefs.score.format(),
                        style: theme.textTheme.headline4),
                    SizedBox(width: 4.d),
                    SVG.show("cup", 24.d)
                  ]),
                  SizedBox(width: 4.d),
                  Row(children: [
                    Text("${Pref.record.value.format()}",
                        style: theme.textTheme.headline5),
                    SizedBox(width: 3.d),
                    SVG.show("record", 20.d),
                    SizedBox(width: 4.d),
                  ])
                ])));
  }

  static Widget stats(ThemeData theme, {Function()? onTap}) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    return Hero(
        tag: "stats",
        child: SizedBox(
            width: 50,
            child: BumpedButton(
                padding: EdgeInsets.fromLTRB(6, 4, 6, 9),
                content: GestureDetector(
                    onTap: onTap, child: SVG.show("profile", 48.d)))));
  }

  static Widget coins(BuildContext context,
      {Function()? onTap, bool clickable = true}) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    var theme = Theme.of(context);
    var text = "${Pref.coin.value.format()}";
    return Hero(
        tag: "coin",
        child: BumpedButton(
            content: Row(children: [
              SVG.show("coin", 32.d),
              Expanded(
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText2!
                          .copyWith(fontSize: text.length > 5 ? 17 : 22))),
              clickable
                  ? Text("+  ",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.button)
                  : SizedBox()
            ]),
            onTap: onTap ??
                () {
                  if (clickable) Rout.push(context, ShopOverlay());
                }));
  }

  static Widget startButton(
      BuildContext context, String title, String boost, Function? onSelect) {
    var theme = Theme.of(context);
    return Expanded(
        child: Container(
            padding: EdgeInsets.fromLTRB(10.d, 6.d, 10.d, 12.d),
            decoration: ButtonDecor(TColors.whiteFlat.value, 12.d, true, false),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.show(boost, 72.d),
                _has(boost) ? SVG.show("accept", 24.d) : SizedBox()
              ]),
              Text(title,
                  style: theme.textTheme.subtitle2,
                  textAlign: TextAlign.center),
              SizedBox(height: 12.d),
              SizedBox(
                  width: 92.d,
                  height: 40.d,
                  child: BumpedButton(
                      cornerRadius: 8.d,
                      isEnable: !_has(boost),
                      content: Row(children: [
                        SVG.show("coin", 24.d),
                        Expanded(
                            child: Text("100",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyText2))
                      ]),
                      onTap: () => _onStartTap(context, boost, 100, onSelect))),
              SizedBox(height: 8.d),
              SizedBox(
                  width: 92.d,
                  height: 40.d,
                  child: BumpedButton(
                      cornerRadius: 8.d,
                      errorMessage: Ads.errorMessage(theme),
                      isEnable: !_has(boost) && Ads.isReady(),
                      colors: TColors.orange.value,
                      content: Row(children: [
                        SVG.icon("0", theme, scale: 0.7),
                        Expanded(
                            child: Text("Free",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headline5))
                      ]),
                      onTap: () => _onStartTap(context, boost, 0, onSelect))),
              SizedBox(height: 4.d)
            ])));
  }

  static void _onStartTap(
      context, String boost, int cost, Function? onSelect) async {
    if (cost > 0) {
      if (Pref.coin.value < cost) {
        Rout.push(context, ShopOverlay());
        return;
      }
    } else {
      var complete = await Ads.show();
      if (!complete) return;
    }
    Pref.coin.increase(-cost);

    if (boost == "next") MyGame.boostNextMode = 1;
    if (boost == "512") MyGame.boostBig = true;
    onSelect?.call();
  }

  static bool _has(String boost) {
    return (boost == "next") ? MyGame.boostNextMode > 0 : MyGame.boostBig;
  }
}
