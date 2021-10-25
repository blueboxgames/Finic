import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numbers/dialogs/shop.dart';
import 'package:numbers/dialogs/stats.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/gemeservice.dart';
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
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var width = widget.width ?? 300.d;
    var hasChrome = widget.hasChrome ?? true;
    var hasClose = widget.showCloseButton ?? true;

    Sound.play(widget.sfx ?? "pop");
    Analytics.setScreen(widget.mode.name);
    return WillPopScope(
        key: Key(widget.mode.name),
        onWillPop: () async {
          widget.onWillPop?.call();
          return widget.closeOnBack ?? true;
        },
        child: Stack(alignment: Alignment.center, children: [
          widget.scoreButton ??
              Positioned(
                  top: 46.d,
                  right: 10.d,
                  child: Components.scores(theme, onTap: () {
                    Analytics.design('guiClick:record:${widget.mode.name}');
                    PlayGames.showLeaderboard("CgkIw9yXzt4XEAIQAQ");
                  })),
          widget.statsButton ??
              Positioned(
                  top: 32.d,
                  left: 12.d,
                  child: Components.stats(theme, onTap: () {
                    Analytics.design('guiClick:stats:${widget.mode.name}');
                    Rout.push(context, StatsDialog());
                  })),
          widget.coinButton ??
              Positioned(
                  top: 32.d,
                  left: 66.d,
                  child: Components.coins(context, widget.mode.name)),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                width: width - 36.d,
                height: 72.d,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.title != null
                          ? Text(widget.title!,
                              style: theme.textTheme.headline4)
                          : SizedBox(),
                      if (hasClose)
                        widget.closeButton ??
                            GestureDetector(
                                child: SVG.show("close", 28.d),
                                onTap: () {
                                  widget.onWillPop?.call();
                                  Navigator.of(context).pop();
                                })
                    ])),
            Container(
                width: width,
                height: widget.height == null
                    ? 340.d
                    : (widget.height == 0 ? null : widget.height),
                padding: widget.padding ??
                    EdgeInsets.fromLTRB(18.d, 12.d, 18.d, 18.d),
                decoration: hasChrome
                    ? BoxDecoration(
                        color: theme.dialogTheme.backgroundColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(24.d)))
                    : null,
                child: widget.child ?? SizedBox())
          ])
        ]));
  }

  buttonsClick(BuildContext context, String type, int coin,
      {AdPlace? adId}) async {
    if (coin < 0 && Pref.coin.value < -coin) {
      Rout.push(context, ShopDialog());
      return;
    }
    if (adId != null) {
      var complete = await Ads.show(adId);
      if (!complete) {
        // Navigator.of(context).pop(null);
        return;
      }
    }
    if (coin != 0) Pref.coin.increase(coin, itemType: "confirm", itemId: type);
    Navigator.of(context).pop(type);
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

// class DialogBuilder {
//   DialogMode mode;
//   String? sfx;
//   String? title;
//   double? width;
//   double? height;
//   Widget? child;
//   Widget? scoreButton;
//   Widget? coinButton;
//   Widget? closeButton;
//   Widget? statsButton;
//   Function? onWillPop;
//   EdgeInsets? padding;
//   bool? hasChrome;
//   bool? showCloseButton;
//   bool? closeOnBack;
//   Map<String, dynamic>? args;

//   DialogBuilder(
//     this.mode, {
//     this.sfx,
//     this.title,
//     this.width,
//     this.height,
//     this.child,
//     this.scoreButton,
//     this.coinButton,
//     this.closeButton,
//     this.statsButton,
//     this.onWillPop,
//     this.padding,
//     this.hasChrome,
//     this.showCloseButton,
//     this.closeOnBack,
//     this.args,
//   });
// }