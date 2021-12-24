import 'dart:io';

import 'package:app_tutti/apptutti.dart';
import 'package:numbers/utils/prefs.dart';

class Ads {
  static Function(AdPlace, AdState)? onUpdate;
  static String platform = Platform.isAndroid ? "Android" : "iOS";
  static final rewardCoef = 10;
  static final isSupportAdMob = true;
  static final isSupportUnity = false;

  static bool showSuicideInterstitial = false;

  static var prefix;

  static bool isReady = false;
  static bool hasReward = false;

  static init() async {
    Apptutti.init(listener: (map) {
      _isReady();
    });
  }

  /* static BannerAd getBanner(String type, {AdSize? size}) {
    var place = AdPlace.Banner;
    var name = place.name + "_" + type;
  }
 */

  static Future<bool?> _isReady([AdPlace? place]) async {
    var _place = place ?? AdPlace.Rewarded;
    if (_place != AdPlace.Rewarded) {
      if (Pref.playCount.value < _place.threshold) return false;
      if (Pref.noAds.value > 0) return false;
    }
    var r = await Apptutti.isAdReady();
    isReady = r ?? false;
    onUpdate?.call(AdPlace.Rewarded, AdState.Loaded);
    return isReady;
  }

  static showInterstitial(AdPlace place) {
    if (Pref.noAds.value > 0) return;
    if (!isReady) return;
    Apptutti.showAd(Apptutti.ADTYPE_INTERSTITIAL, listener: _listener);
  }

  static showRewarded() async {
    hasReward = false;
    if (!isReady) return;
    Apptutti.showAd(Apptutti.ADTYPE_REWARDED, listener: _listener);
  }

  static void _listener(Map<dynamic, dynamic> args) {
    if (args[Apptutti.ADTYPE] == Apptutti.ADTYPE_REWARDED &&
        args[Apptutti.ADEVENT] == Apptutti.ADEVENT_COMPLETE) hasReward = true;
    print("Ads => $args   $hasReward");
  }
}

enum AdState {
  Closed,
  Clicked,
  Show,
  FailedShow,
  RewardReceived,
  Request,
  Loaded,
  FailedLoad
}

extension AdExt on AdState {
  int get order {
    if (this == AdState.FailedLoad) return -1;
    return index;
  }
}

enum AdPlace { Rewarded, Interstitial, InterstitialVideo, Banner }

extension AdPlaceExt on AdPlace {
  int get threshold {
    if (this == AdPlace.InterstitialVideo) return 4;
    if (this == AdPlace.Banner) return 10;
    return 0;
  }
}
