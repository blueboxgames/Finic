import 'dart:async';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/cells.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/dialogs/big.dart';
import 'package:numbers/dialogs/callout.dart';
import 'package:numbers/dialogs/confirms.dart';
import 'package:numbers/dialogs/freecoins.dart';
import 'package:numbers/dialogs/piggy.dart';
import 'package:numbers/dialogs/record.dart';
import 'package:numbers/dialogs/revive.dart';
import 'package:numbers/dialogs/pause.dart';
import 'package:numbers/dialogs/shop.dart';
import 'package:numbers/dialogs/stats.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';
import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  MyGame? _game;
  int loadingState = 0;

  AnimationController? _rewardAnimation;
  AnimationController? _rewardLineAnimation;
  ConfettiController? _confettiController;

  bool _animationTime = false;
  Timer? _timer;

  void initState() {
    super.initState();
    _createGame();
    _rewardAnimation = AnimationController(vsync: this);
    _rewardAnimation!.addListener(() => setState(() {}));
    _rewardLineAnimation = AnimationController(
        vsync: this,
        upperBound: PiggyDialog.capacity * 1.0,
        value: Pref.coinPiggy.value * 1.0);
    _rewardLineAnimation!.addListener(() => setState(() {}));
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: Stack(alignment: Alignment.bottomCenter, children: [
          _game == null ? SizedBox() : GameWidget(game: _game!),
          Positioned(
              top: _game!.bounds.top - 69.d,
              left: _game!.bounds.left,
              right: _game!.bounds.left,
              child: _getHeader(theme)),
          Positioned(
              top: _game!.bounds.bottom + 10.d,
              left: _game!.bounds.left - 22.d,
              right: _game!.bounds.left,
              child: _getFooter(theme)),
          _underFooter(),
          Center(child: Components.confetty(_confettiController!))
        ])));
  }

  Widget _getHeader(ThemeData theme) {
    if (Pref.tutorMode.value == 0) {
      return Center(
          child: Text("home_tutor".l(), style: theme.textTheme.headline4));
    }
    return SizedBox(
        height: 56.d,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Components.stats(theme, onTap: () {
            _pause("stats");
            Analytics.design('guiClick:stats:home');
            Rout.push(context, StatsDialog());
          }),
          Components.coins(context, "home", onTap: () async {
            MyGame.isPlaying = false;
            await Rout.push(context, ShopDialog());
            MyGame.isPlaying = true;
            setState(() {});
          }),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SizedBox(height: 4.d),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(Prefs.score.format(),
                  style:
                      theme.textTheme.headline5!.copyWith(letterSpacing: -1)),
              SizedBox(width: 2.d),
              SVG.show("cup", 22.d)
            ]),
            Components.scores(theme, onTap: () {
              _pause("record");
              Analytics.design('guiClick:record:home');
              GamesServices.showLeaderboards();
            })
          ]))
        ]));
  }

  Widget _getFooter(ThemeData theme) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    if (_game!.removingMode != null) {
      return Padding(
          padding: EdgeInsets.only(left: 22.d),
          child: Container(
              padding: EdgeInsets.fromLTRB(24.d, 18.d, 24.d, 20.d),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 3.d,
                        color: Colors.black,
                        offset: Offset(0.5.d, 2.d))
                  ],
                  color: theme.cardColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("home_rm_${_game!.removingMode!}".l()),
                    GestureDetector(
                        child: SVG.show("close", 32.d), onTap: _onRemoveBlock)
                  ])));
    }
    return SizedBox(
        height: 68.d,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
                icon: SVG.show("pause", 48.d),
                iconSize: 72.d,
                onPressed: () => _pause("tap")),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  SizedBox(height: 5 * _rewardAnimation!.value),
                  Expanded(
                      child: _button(
                          theme, 20.d, "piggy", () => _boost("piggy"),
                          // width: 96.d,
                          badge: _slider(
                              theme,
                              _rewardLineAnimation!.value.round(),
                              PiggyDialog.capacity),
                          colors: Pref.coinPiggy.value >= PiggyDialog.capacity
                              ? TColors.orange.value
                              : null))
                ])),
            SizedBox(width: 4.d),
            _button(theme, 96.d, "remove-color", () => _boost("color"),
                badge: _badge(theme, Pref.removeColor.value)),
            SizedBox(width: 4.d),
            _button(theme, 20.d, "remove-one", () => _boost("one"),
                badge: _badge(theme, Pref.removeOne.value)),
          ],
        ));
  }

  _underFooter() {
    var isAdsReady = Ads.isReady();
    if (isAdsReady && _timer == null) {
      var duration = Duration(
          milliseconds:
              _animationTime ? 2500 : 30000 + Random().nextInt(30000));
      _timer = Timer(duration, () {
        _animationTime = !_animationTime;
        _timer = null;
        setState(() {});
      });
    }

    if (!_animationTime)
      return Positioned(
          bottom: 2.d,
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.d)),
              child: Ads.getBanner(size: AdmobBannerSize.BANNER)));
    return Positioned(
        left: 0,
        bottom: 0.d,
        height: 120.d,
        child: GestureDetector(
            onTap: () async {
              MyGame.isPlaying = false;
              var result = await Rout.push(context, FreeCoinsDialog());
              if (result != null && result != "") {
                MyGame.isPlaying = true;
                _game!.showReward(
                    FreeCoinsDialog.reward,
                    Vector2(_game!.bounds.top, Device.size.width * 0.5),
                    GameEvent.freeCoins);
              }
              MyGame.isPlaying = true;
            },
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(
                  width: 80.d,
                  child: RiveAnimation.asset('anims/nums-character.riv',
                      stateMachines: ["runState"])),
              Container(
                  height: 44.d,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 12.d),
                  child: Text("freecoins_catch".l()),
                  decoration: _badgeDecoration(color: Colors.white)),
            ])));
  }

  Widget _button(
      ThemeData theme, double right, String icon, Function() onPressed,
      {double? width, Widget? badge, List<Color>? colors}) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    return SizedBox(
        width: width ?? 64.d,
        child: BumpedButton(
            colors: colors ?? TColors.whiteFlat.value,
            padding: EdgeInsets.fromLTRB(4.d, 0, 0, 4.d),
            content: Stack(children: [
              Positioned(
                  height: 46.d,
                  top: 4.d,
                  right: 2.d,
                  child: SVG.show(icon, 48.d)),
              badge ?? SizedBox()
            ]),
            onTap: () {
              Analytics.design('guiClick:$icon:game');
              onPressed();
            }));
  }

  Widget _badge(ThemeData theme, int value) {
    return Positioned(
        height: 22.d,
        bottom: 2.d,
        left: 0,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.d),
            child: Text(value == 0 ? "free_l".l() : "$value",
                style: theme.textTheme.headline6),
            decoration: _badgeDecoration()));
  }

  Widget _slider(ThemeData theme, int value, int maxValue) {
    var label = value >= maxValue ? "collect_l".l() : "$value / $maxValue";
    return Positioned(
        height: 32.d,
        bottom: 0,
        left: 0,
        right: 6.d,
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
                  style: TextStyle(fontSize: 10.d),
                  textAlign: TextAlign.center)),
        ]));
  }

  Decoration _badgeDecoration({double? cornerRadius, Color? color}) {
    return BoxDecoration(
        boxShadow: [
          BoxShadow(
              blurRadius: 3.d, color: Colors.black, offset: Offset(0.5.d, 1.d))
        ],
        color: color ?? Colors.pink[700],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(cornerRadius ?? 12.d)));
  }

  void _onGameEventHandler(GameEvent event, int value) async {
    Widget? _widget;
    switch (event) {
      case GameEvent.big:
        await Future.delayed(Duration(milliseconds: 250));
        _widget = BigBlockDialog(value, _confettiController!);
        Prefs.increaseBig(value);
        break;
      case GameEvent.boost:
        await _boost("next");
        break;
      case GameEvent.celebrate:
        _confettiController!.play();
        return;
      case GameEvent.completeTutorial:
        _widget = ConfirmDialog(_confettiController!);
        break;
      case GameEvent.lose:
        await Future.delayed(Duration(seconds: 1));
        _widget = ReviveDialog(_game!.numRevives);
        break;
      case GameEvent.openPiggy:
      case GameEvent.freeCoins:
        if (event == GameEvent.openPiggy) {
          Pref.coinPiggy.set(0);
          _rewardLineAnimation!
              .animateTo(0, duration: const Duration(milliseconds: 400));
        }
        Pref.coin.increase(value, itemType: "game", itemId: "random");
        Sound.play("win");
        setState(() {});
        return;
      case GameEvent.remove:
        _onRemoveBlock();
        break;
      case GameEvent.reward:
        _game!.showReward(
            value,
            Vector2(_game!.bounds.center.dx, _game!.bounds.bottom + 8.d),
            GameEvent.rewarded);
        return;
      case GameEvent.rewarded:
        var dailyCoins = Pref.coinPiggy.value + value;
        Pref.coinPiggy.set(dailyCoins.clamp(0, PiggyDialog.capacity));
        _rewardAnimation!.value = 1;
        _rewardAnimation!.animateTo(0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutSine);
        _rewardLineAnimation!.animateTo(Pref.coinPiggy.value * 1.0,
            duration: const Duration(seconds: 1), curve: Curves.easeInOutSine);
        if (dailyCoins >= PiggyDialog.capacity) {
          ++PiggyDialog.autoAppearance;
          if (Ads.isReady() && PiggyDialog.autoAppearance % 4 == 0)
            await _boost("piggy", playApplaud: true);
        }
        return;
      case GameEvent.score:
        setState(() {});
        return;
    }

    if (_widget != null) {
      var result = await Rout.push(context, _widget);
      if (event == GameEvent.lose) {
        if (result == null) {
          if (value > 0) {
            await Rout.push(context, RecordDialog(_confettiController!));
            await Future.delayed(Duration(milliseconds: 150));
          }

          Analytics.endProgress("main", Pref.playCount.value, Pref.record.value,
              _game!.numRevives);

          Navigator.of(context).pop();
          return;
        }
        _game!.revive();
        setState(() {});
        return;
      }
      if (event == GameEvent.completeTutorial) {
        if (result == "tutorFinish") Pref.tutorMode.set(1);
        MyGame.boostNextMode = 1;
        _createGame();
      }
    }
    _onPauseButtonsClick("resume");
  }

  void _pause(String source, {bool showMenu = true}) async {
    MyGame.isPlaying = false;
    Analytics.design('guiClick:pause:$source');
    if (!showMenu) return;
    var result = await Rout.push(context, PauseDialog());
    _onPauseButtonsClick(result ?? "resume");
  }

  void _onPauseButtonsClick(String type) {
    switch (type) {
      case "reset":
        Navigator.of(context).pop();
        break;
      case "resume":
        MyGame.isPlaying = true;
        setState(() {});
        break;
    }
  }

  _boost(String type, {bool? playApplaud}) async {
    MyGame.isPlaying = false;
    if (type == "piggy") {
      var result =
          await Rout.push(context, PiggyDialog(playApplaud: playApplaud));
      if (result != null && result != "") {
        MyGame.isPlaying = true;
        _game!.showReward(
            PiggyDialog.capacity,
            Vector2(_game!.bounds.top, Device.size.width * 0.5),
            GameEvent.openPiggy);
      }
      MyGame.isPlaying = true;
      return;
    }

    if (type == "one" && Pref.removeOne.value > 0 ||
        type == "color" && Pref.removeColor.value > 0) {
      setState(() => _game!.removingMode = type);
      return;
    }
    EdgeInsets padding = EdgeInsets.only(
        right: _game!.bounds.left, top: _game!.bounds.bottom - 78.d);
    if (type == "next")
      padding = EdgeInsets.only(
          left: (Device.size.width - Callout.chromeWidth) * 0.5,
          top: _game!.bounds.top + 68.d);
    var result = await Rout.push(
        context, Callout("clt_${type}_text".l(), type, padding: padding),
        barrierColor: Colors.transparent, barrierDismissible: true);
    if (result != null) {
      if (type == "next") {
        _game!.boostNext();
        return;
      }
      if (type == "one") Pref.removeOne.set(1);
      if (type == "color") Pref.removeColor.set(1);
      setState(() => _game!.removingMode = type);
      return;
    }
    MyGame.isPlaying = true;
  }

  void _createGame() {
    Analytics.setScreen("game");
    var top = 140.d;
    var bottom = 180.d;
    Cell.updateSizes((Device.size.height - top - bottom) / (Cells.height + 1));
    var padding = (Device.size.width - (Cells.width * Cell.diameter)) * 0.5;
    var bounds = Rect.fromLTRB(
        padding, top, Device.size.width - padding, Device.size.height - bottom);
    _game = MyGame(bounds: bounds, onGameEvent: _onGameEventHandler);
  }

  void _onRemoveBlock() {
    _game!.removingMode = null;
    MyGame.isPlaying = true;
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    _pause("back");
    return true;
  }

  @override
  void dispose() {
    _timer!.cancel();
    _rewardAnimation!.dispose();
    _confettiController!.dispose();
    _rewardLineAnimation!.dispose();
    super.dispose();
  }
}
