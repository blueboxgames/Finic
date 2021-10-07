import 'package:confetti/confetti.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/core/cell.dart';
import 'package:numbers/core/cells.dart';
import 'package:numbers/core/game.dart';
import 'package:numbers/overlays/all.dart';
import 'package:numbers/overlays/pause.dart';
import 'package:numbers/overlays/shop.dart';
import 'package:numbers/overlays/stats.dart';
import 'package:numbers/utils/analytics.dart';
import 'package:numbers/utils/gemeservice.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';
import 'package:numbers/widgets/components.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  MyGame? _game;
  int loadingState = 0;

  Positioned? _coins;
  AnimationController? _rewardAnimation;
  AnimationController? _rewardLineAnimation;
  ConfettiController? _confettiController;

  void initState() {
    super.initState();
    _createGame();
    _rewardAnimation = AnimationController(vsync: this);
    _rewardAnimation!.addListener(() => setState(() {}));
    _rewardLineAnimation = AnimationController(
        vsync: this,
        upperBound: Cell.maxDailyCoins * 1.0,
        value: Pref.coinDaily.value * 1.0);
    _rewardLineAnimation!.addListener(() => setState(() {}));
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var rewardAvailble = Pref.coinDaily.value >= Cell.maxDailyCoins;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: Stack(children: [
          _game == null ? SizedBox() : GameWidget(game: _game!),
          Positioned(
              top: _game!.bounds.top - 69.d,
              right: 20.d,
              child: Components.scores(theme, onTap: () {
                _pause();
                PlayGames.showLeaderboard("CgkIw9yXzt4XEAIQAQ");
              })),
          Positioned(
              top: _game!.bounds.top - 45.d,
              right: 23.d,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(Prefs.score.format(),
                    style:
                        theme.textTheme.headline5!.copyWith(letterSpacing: -1)),
                SizedBox(width: 2.d),
                SVG.show("cup", 22.d)
              ])),
          Positioned(
              top: _game!.bounds.top - 70.d,
              left: 22.d,
              child: Components.stats(theme, onTap: () {
                _pause();
                Rout.push(context, StatsOverlay());
              })),
          _coins = Positioned(
              top: _game!.bounds.top - 70.d,
              left: 73.d,
              height: 52.d,
              child: Components.coins(context, onTap: () async {
                MyGame.isPlaying = false;
                await Rout.push(context, ShopOverlay());
                MyGame.isPlaying = true;
                setState(() {});
              })),
          Pref.tutorMode.value == 0
              ? Positioned(
                  top: _game!.bounds.top - 68.d,
                  right: 22.d,
                  left: 28.d,
                  child: Text("How to play?",
                      style: theme.textTheme.headline4,
                      textAlign: TextAlign.center))
              : SizedBox(),
          Pref.tutorMode.value == 0
              ? SizedBox()
              : Positioned(
                  top: _game!.bounds.bottom + 16.d,
                  right: 24.d,
                  left: 24.d,
                  height: 68.d,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                          icon: SVG.show("pause", 48.d),
                          iconSize: 56.d,
                          onPressed: _pause),
                      Expanded(child: SizedBox()),
                      Column(children: [
                        SizedBox(height: 5 * _rewardAnimation!.value),
                        Expanded(
                            child: _button(theme, 20.d, "piggy",
                                () => _boost(rewardAvailble ? "daily" : ""),
                                width: 96.d,
                                badge: _slider(
                                    theme,
                                    _rewardLineAnimation!.value.round(),
                                    Cell.maxDailyCoins),
                                colors: rewardAvailble
                                    ? TColors.orange.value
                                    : null))
                      ]),
                      SizedBox(width: 4.d),
                      _button(
                          theme, 96.d, "remove-color", () => _boost("color"),
                          badge: _badge(theme, Pref.removeColor.value)),
                      SizedBox(width: 4.d),
                      _button(theme, 20.d, "remove-one", () => _boost("one"),
                          badge: _badge(theme, Pref.removeOne.value)),
                    ],
                  )),
          _game!.removingMode == null
              ? SizedBox()
              : Positioned(
                  top: _game!.bounds.bottom + 10.d,
                  right: 4.d,
                  left: 4.d,
                  height: 86.d,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(32.d, 28.d, 32.d, 32.d),
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
                            Text("Select ${_game!.removingMode} to remove!"),
                            GestureDetector(
                                child: SVG.show("close", 32.d),
                                onTap: _onRemoveBlock)
                          ]))),
          Center(child: Components.confetty(_confettiController!))
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
                  bottom: 20.d,
                  left: 6.d,
                  top: 6.d,
                  right: 1.d,
                  child: SVG.show(icon, 12.d)),
              badge ?? SizedBox()
            ]),
            onTap: onPressed));
  }

  Widget _badge(ThemeData theme, int value) {
    return Positioned(
        height: 22.d,
        bottom: 2.d,
        left: 0,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.d),
            child: Text(value == 0 ? "free" : "$value",
                style: theme.textTheme.headline6),
            decoration: _badgeDecoration()));
  }

  Widget _slider(ThemeData theme, int value, int maxValue) {
    var label = value >= maxValue ? "Collect" : "$value / $maxValue";
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
              child: Text(label, style: TextStyle(fontSize: 12.d))),
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

  void _onGameEventHandler(GameEvent event, int value) async {
    Widget? _widget;
    switch (event) {
      case GameEvent.big:
        await Future.delayed(Duration(milliseconds: 250));
        _widget = Overlays.bigValue(context, value, _confettiController!);
        Prefs.increaseBig(value);
        break;
      case GameEvent.boost:
        await _boost("next");
        break;
      case GameEvent.celebrate:
        _confettiController!.play();
        return;
      case GameEvent.coinEarned:
        Pref.coinDaily.set(0);
        Pref.coin.increase(value, itemType: "game", itemId: "random");
        _rewardLineAnimation!
            .animateTo(0, duration: const Duration(milliseconds: 400));
        return;
      case GameEvent.completeTutorial:
        _widget = Overlays.endTutorial(context, _confettiController!);
        break;
      case GameEvent.lose:
        await Future.delayed(Duration(seconds: 1));
        _widget = Overlays.revive(context, _game!.numRevives);
        break;
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
        var dailyCoins = Pref.coinDaily.value + value;
        Pref.coinDaily.set(dailyCoins.clamp(0, Cell.maxDailyCoins));
        _rewardAnimation!.value = 1;
        _rewardAnimation!.animateTo(0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutSine);
        _rewardLineAnimation!.animateTo(Pref.coinDaily.value * 1.0,
            duration: const Duration(seconds: 1), curve: Curves.easeInOutSine);
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
            await Rout.push(
                context, Overlays.record(context, _confettiController!));
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

  void _pause({bool showMenu = true}) async {
    MyGame.isPlaying = false;
    if (!showMenu) return;
    var result = await Rout.push(context, PauseOverlay());
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

  _boost(String type) async {
    if (type == "") return;
    MyGame.isPlaying = false;

    if (type == "one" && Pref.removeOne.value > 0 ||
        type == "color" && Pref.removeColor.value > 0) {
      setState(() => _game!.removingMode = type);
      return;
    }
    var title = "";
    var hasCoinButton = true;
    EdgeInsets padding = EdgeInsets.only(right: 16, bottom: 80);
    switch (type) {
      case "next":
        title = "Show next upcomming block!";
        padding = EdgeInsets.only(left: 32, top: _game!.bounds.top + 68);
        break;
      case "one":
        title = "Remove one block!";
        break;
      case "color":
        title = "Select color for remove!";
        break;
      case "daily":
        hasCoinButton = false;
        title = "Collect your reward!";
        break;
    }
    var result = await Rout.push(
        context,
        Overlays.callout(context, title, type,
            padding: padding, hasCoinButton: hasCoinButton),
        barrierColor: Colors.transparent,
        barrierDismissible: true);
    if (result != null) {
      if (type == "next") {
        _game!.boostNext();
        return;
      }
      if (type == "daily") {
        MyGame.isPlaying = true;
        _game!.showReward(
            Cell.maxDailyCoins,
            Vector2(_coins!.top!, _coins!.left! + 8.d),
            GameEvent.coinEarned);
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
    var padding = 24.d + (Device.size.aspectRatio - 0.5) * 200.d;
    var width = Device.size.width - padding * 2;
    Cell.updateSizes(width / Cells.width);
    var t = (Device.size.height - ((Cells.height + 1) * Cell.diameter)) * 0.5;
    var bounds = Rect.fromLTRB(
        padding, t, Device.size.width - padding, t + Cell.diameter * 7);
    _game = MyGame(bounds: bounds, onGameEvent: _onGameEventHandler);
  }

  void _onRemoveBlock() {
    _game!.removingMode = null;
    MyGame.isPlaying = true;
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    _pause();
    return true;
  }

  @override
  void dispose() {
    _rewardAnimation!.dispose();
    _confettiController!.dispose();
    _rewardLineAnimation!.dispose();
    super.dispose();
  }
}
