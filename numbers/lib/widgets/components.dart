import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/utils.dart';
import 'package:numbers/widgets/buttons.dart';

class Components {
  static Widget scores(ThemeData theme, {Function()? onTap}) {
    if (Pref.tutorMode.value == 0) return SizedBox();
    return Hero(
        tag: "score",
        child: GestureDetector(
            onTap: onTap,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text("${Pref.record.value.format()}",
                    style:
                        theme.textTheme.headline5!.copyWith(letterSpacing: -1)),
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
            width: 50.d,
            child: BumpedButton(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 10),
                content: GestureDetector(
                    onTap: onTap, child: SVG.show("profile", 48.d)))));
  }

  static Widget coins(BuildContext context, String source,
      {Function()? onTap, bool clickable = false}) {
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
                          .copyWith(fontSize: text.length > 5 ? 17.d : 22.d))),
              clickable
                  ? Text("+  ",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.button)
                  : SizedBox()
            ]),
            onTap: () {
              if (clickable) {
                Analytics.design('guiClick:shop:$source');
                if (onTap != null) onTap();
                // else
                //   Rout.push(context, ShopOverlay());
              }
            }));
  }

  static Widget confetty(ConfettiController controller) {
    return ConfettiWidget(
        gravity: 0.5,
        maxBlastForce: 50,
        numberOfParticles: 20,
        emissionFrequency: 0.05,
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ],
        createParticlePath: drawStar);
  }

  /// A custom Path to paint stars.
  static Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
