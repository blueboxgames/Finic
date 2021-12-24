import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/dialogs/rating.dart';
import 'package:numbers/dialogs/toast.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/home.dart';

import 'dialogs.dart';

// ignore: must_be_immutable
class StartDialog extends AbstractDialog {
  StartDialog()
      : super(DialogMode.start,
            height: 330.d,
            showCloseButton: false,
            title: "start_title".l(),
            padding: EdgeInsets.fromLTRB(12.d, 12.d, 12.d, 14.d));
  @override
  _StartDialogState createState() => _StartDialogState();
}

class _StartDialogState extends AbstractDialogState<StartDialog> {
  String _startButtonLabel = "start_l".l();

  @override
  void initState() {
    super.initState();
    if (Pref.tutorMode.value == 0)
      Timer(const Duration(milliseconds: 100), _onStart);
  }

  @override
  Widget build(BuildContext context) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    var theme = Theme.of(context);
    stepChildren.clear();
    stepChildren.add(bannerAdsFactory("start"));
    widget.child =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _boostButton("start_big".l(), "512"),
        SizedBox(width: 2.d),
        _boostButton("start_next".l(), "next")
      ])),
      SizedBox(height: 10.d),
      Container(
          height: 80.d,
          child: BumpedButton(
              colors: TColors.blue.value,
              isEnable: _startButtonLabel == "start_l".l(),
              onTap: _onStart,
              cornerRadius: 16.d,
              content:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.icon("E", theme),
                SizedBox(width: 12.d),
                Text(_startButtonLabel,
                    style: theme.textTheme.headline5,
                    textAlign: TextAlign.center)
              ])))
    ]);
    return super.build(context);
  }

  Widget _boostButton(String title, String boost) {
    var theme = Theme.of(context);
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8.d),
            decoration: ButtonDecor(TColors.whiteFlat.value, 12.d, true, false),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SVG.show(boost, 58.d),
                _has(boost) ? SVG.show("accept", 22.d) : SizedBox()
              ]),
              SizedBox(height: 6.d),
              Text(title,
                  style: theme.textTheme.subtitle2,
                  textAlign: TextAlign.center),
              SizedBox(height: 6.d),
              SizedBox(
                  width: 92.d,
                  height: 39.d,
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
                      onTap: () => _onBoostTap(context, boost, 100))),
              SizedBox(height: 4.d),
              SizedBox(
                  width: 92.d,
                  height: 39.d,
                  child: BumpedButton(
                      cornerRadius: 8.d,
                      errorMessage: Toast("ads_unavailable".l(), monoIcon: "A"),
                      isEnable: !_has(boost) && Ads.isReady,
                      colors: TColors.orange.value,
                      content: Row(children: [
                        SVG.icon("A", theme, scale: 0.7),
                        Expanded(
                            child: Text("free_l".l(),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headline5))
                      ]),
                      onTap: () => _onBoostTap(context, boost, 0))),
              SizedBox(height: 6.d)
            ])));
  }

  void _onBoostTap(context, String boost, int cost) async {
    if (cost > 0) {
      if (Pref.coin.value < cost) {
        Rout.push(context, Toast("coin_notenough".l(), icon: "coin"));
        return;
      }
    } else {
      waiting.init(boost, cost, _onBoostAdFinish);
      _onUpdate();
      Ads.showRewarded();
    }
  }

  _onBoostAdFinish() {
    if (Ads.hasReward) {
      Pref.coin
          .increase(-waiting.coin, itemType: "start", itemId: waiting.type);
      if (waiting.type == "next") MyGame.boostNextMode = 1;
      if (waiting.type == "512") MyGame.boostBig = true;
    }
    _onUpdate();
  }

  bool _has(String boost) {
    return (boost == "next") ? MyGame.boostNextMode > 0 : MyGame.boostBig;
  }

  _onStart() async {
    _startButtonLabel = "wait_l".l();
    _onUpdate();
    if (Pref.playCount.value > AdPlace.InterstitialVideo.threshold) {
      waiting.init("start", 0, _startGame);
      _onUpdate();
      await Ads.showInterstitial(AdPlace.InterstitialVideo);
    }
  }

  _onUpdate() => setState(() {});

  _startGame() async {
    await Rout.push(context, HomePage());
    Cell.maxRandomValue = 4;
    MyGame.boostNextMode = 0;
    MyGame.boostBig = false;
    _startButtonLabel = "start_l".l();
    _onUpdate();
    await RatingDialog.showRating(context);
  }
}
