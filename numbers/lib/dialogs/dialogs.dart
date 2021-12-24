import 'package:flutter/material.dart';
import 'package:numbers/dialogs/confirm.dart';
import 'package:numbers/dialogs/stats.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/components.dart';

// ignore: must_be_immutable
class AbstractDialog extends StatefulWidget {
  DialogMode mode;
  String? sfx;
  String? title;
  double? width;
  double? height;
  Widget? child;
  Widget? scoreButton;
  Widget? coinButton;
  Widget? closeButton;
  Widget? statsButton;
  Function? onWillPop;
  EdgeInsets? padding;
  bool? hasChrome;
  bool? showCloseButton;
  bool? closeOnBack;
  Map<String, dynamic>? args;

  AbstractDialog(this.mode,
      {this.sfx,
      this.title,
      this.width,
      this.height,
      this.child,
      this.scoreButton,
      this.coinButton,
      this.closeButton,
      this.statsButton,
      this.onWillPop,
      this.padding,
      this.hasChrome,
      this.showCloseButton,
      this.closeOnBack,
      this.args});
  @override
  AbstractDialogState createState() => AbstractDialogState();
}

class AbstractDialogState<T extends AbstractDialog> extends State<T> {
  List<Widget> stepChildren = <Widget>[];
  AdWaiting waiting = AdWaiting();
  @override
  void initState() {
    Ads.onUpdate = _onAdsUpdate;
    Sound.play(widget.sfx ?? "pop");
    Analytics.setScreen(widget.mode.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var width = widget.width ?? 300.d;

    var children = <Widget>[];
    children.add(rankButtonFactory(theme));
    children.add(statsButtonFactory(theme));
    children.add(coinsButtonFactory(theme));

    var rows = <Widget>[];
    rows.add(headerFactory(theme, width));
    rows.add(chromeFactory(theme, width));
    children.add(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: rows));
    children.add(Visibility(child: waiting, visible: waiting.visible));
    children.addAll(stepChildren);

    return WillPopScope(
        key: Key(widget.mode.name),
        onWillPop: () async {
          widget.onWillPop?.call();
          return widget.closeOnBack ?? true;
        },
        child: Stack(alignment: Alignment.center, children: children));
  }

  buttonsClick(BuildContext context, String type, int coin, bool showAd) async {
    if (coin < 0 && Pref.coin.value < -coin) {
      Rout.push(context, Toast("coin_notenough".l()));
      return;
    }
    if (showAd) {
      waiting.init(type, coin, _onWaitAdTap);
      setState(() {});
      Ads.showRewarded();
      return;
    } else if (coin > 0 && Ads.showSuicideInterstitial) {
      waiting.init(type, coin, _onWaitAdTap);
      setState(() {});
      Ads.showInterstitial(AdPlace.Interstitial);
      return;
    }
    Navigator.of(context).pop([type, coin]);
  }

  void _onWaitAdTap() {
    waiting.visible = false;
    setState(() {});
    if (Ads.hasReward) Navigator.of(context).pop([waiting.type, waiting.coin]);
  }

  Widget bannerAdsFactory(String type) {
    return SizedBox();
    /* if (!Ads.isReady(AdPlace.Banner)) return SizedBox();
    var ad = Ads.getBanner(type);
    return Positioned(
        bottom: 8.d,
        child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16.d)),
                child: AdWidget(ad: ad)))); */
  }

  Widget rankButtonFactory(ThemeData theme) {
    return widget.scoreButton ??
        Positioned(
            top: 46.d,
            right: 10.d,
            child: Components.scores(theme, onTap: () {
              Analytics.design('guiClick:record:${widget.mode.name}');
              // GamesServices.showLeaderboards();
            }));
  }

  Widget statsButtonFactory(ThemeData theme) {
    return widget.statsButton ??
        Positioned(
            top: 32.d,
            left: 12.d,
            child: Components.stats(theme, onTap: () {
              Analytics.design('guiClick:stats:${widget.mode.name}');
              Rout.push(context, StatsDialog());
            }));
  }

  Widget coinsButtonFactory(ThemeData theme) {
    return widget.coinButton ??
        Positioned(
            top: 32.d,
            left: 66.d,
            child: Components.coins(context, widget.mode.name));
  }

  Widget headerFactory(ThemeData theme, double width) {
    var hasClose = widget.showCloseButton ?? true;
    return SizedBox(
        width: width - 36.d,
        height: 72.d,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.title != null
                  ? Text(widget.title!, style: theme.textTheme.headline4)
                  : SizedBox(),
              if (hasClose)
                widget.closeButton ??
                    GestureDetector(
                        child: SVG.show("close", 28.d),
                        onTap: () {
                          widget.onWillPop?.call();
                          Navigator.of(context).pop();
                        })
            ]));
  }

  Widget chromeFactory(ThemeData theme, double width) {
    var hasChrome = widget.hasChrome ?? true;
    return Container(
        width: width,
        height: widget.height == null
            ? 340.d
            : (widget.height == 0 ? null : widget.height),
        padding: widget.padding ?? EdgeInsets.fromLTRB(18.d, 12.d, 18.d, 18.d),
        decoration: hasChrome
            ? BoxDecoration(
                color: theme.dialogTheme.backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24.d)))
            : null,
        child: widget.child ?? SizedBox());
  }

  _onAdsUpdate(AdPlace placement, AdState state) {
    if (placement == AdPlace.Rewarded && state != AdState.Closed)
      setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    Ads.onUpdate = null;
  }
}

// ignore: must_be_immutable
class AdWaiting extends StatelessWidget {
  int coin = 0;
  Function()? onTap;
  String type = "";
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
        onTap: _onTap,
        child: Container(
            alignment: Alignment.topCenter,
            color: theme.backgroundColor.withAlpha(220),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SVG.icon("E", theme, scale: 2),
              SizedBox(height: 12.d),
              Text("continue_l".l(), style: theme.textTheme.headline2)
            ])));
  }

  void init(String type, int coin, void Function() onTap) {
    this.type = type;
    this.coin = coin;
    this.onTap = onTap;
    this.visible = true;
  }

  void _onTap() {
    this.visible = false;
    this.onTap?.call();
  }
}

enum DialogMode {
  big,
  callout,
  confirm,
  confirmDialog,
  pause,
  piggy,
  quit,
  rating,
  record,
  review,
  revive,
  shop,
  start,
  stats,
  toast
}

extension DialogName on DialogMode {
  String get name {
    switch (this) {
      case DialogMode.big:
        return "big";
      case DialogMode.callout:
        return "callout";
      case DialogMode.confirmDialog:
        return "confirmDialog";
      case DialogMode.confirm:
        return "confirm";
      case DialogMode.pause:
        return "pause";
      case DialogMode.piggy:
        return "piggy";
      case DialogMode.quit:
        return "quit";
      case DialogMode.rating:
        return "record";
      case DialogMode.record:
        return "record";
      case DialogMode.review:
        return "review";
      case DialogMode.revive:
        return "revive";
      case DialogMode.shop:
        return "shop";
      case DialogMode.start:
        return "start";
      case DialogMode.stats:
        return "stats";
      case DialogMode.toast:
        return "toast";
    }
  }
}
