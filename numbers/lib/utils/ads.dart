import 'dart:io';

import 'package:app_tutti/apptutti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/prefs.dart';

class Ads {
  static Map<AdPlace, AdState> _placements = Map();

  static Function(AdPlace, AdState)? onUpdate;
  static String platform = Platform.isAndroid ? "Android" : "iOS";
  static final rewardCoef = 10;
  static final isSupportAdMob = true;
  static final isSupportUnity = false;

  static bool showSuicideInterstitial = false;

  static var prefix;

  static bool isReady = false;
  // static RewardItem? reward;

  static init() async {
    Apptutti.init(listener: (map) {
      _isReady();
    });
  }

  /* static BannerAd getBanner(String type, {AdSize? size}) {
    var place = AdPlace.Banner;
    var name = place.name + "_" + type;
    if (_ads.containsKey(name)) return _ads[name]! as BannerAd;
    var _listener = BannerAdListener(
        onAdLoaded: (ad) => _updateState(place, AdState.Loaded, ad),
        onAdFailedToLoad: (ad, error) {
          _updateState(place, AdState.FailedLoad, ad, error);
          ad.dispose();
        },
        onAdOpened: (ad) => _updateState(place, AdState.Clicked, ad),
        onAdClosed: (ad) => _updateState(place, AdState.Closed, ad),
        onAdImpression: (ad) => _updateState(place, AdState.Show, ad));
    _updateState(place, AdState.Request);
    return _ads[name] = BannerAd(
        size: size ?? AdSize.largeBanner,
        adUnitId: place.id,
        listener: _listener,
        request: _request)
      ..load();
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
    return isReady;
    // _placements.containsKey(_place) &&
    //     _placements[_place] == AdState.Loaded;
  }

  static showInterstitial(AdPlace place) async {
    if (Pref.noAds.value > 0) return;
    if (!isReady) return;
    Apptutti.showAd(Apptutti.ADTYPE_INTERSTITIAL, listener: _listener);
  }

  static Future<dynamic> showRewarded() async {
    if (!isReady) return;
    Apptutti.showAd(Apptutti.ADTYPE_REWARDED, listener: _listener);
  }

  static void _listener(Map<dynamic, dynamic> args) {
    print("_tuttiAdsListener => $args");
  }

  static void _updateState(AdPlace place, AdState state,
      [dynamic ad, Error? error]) {
    _placements[place] = state;
    onUpdate?.call(place, state);
    if (state.order > 0)
      Analytics.ad(state.order, 1 /* place.type */, place.name, "admob");
    debugPrint("Ads ==> $place ${state.toString()} ${error ?? ''}");
  }

  static void pausedApp() {
    _placements.forEach((key, value) {
      if (key != AdPlace.Banner &&
          (value == AdState.Show || value == AdState.RewardReceived))
        _updateState(key, AdState.Clicked);
    });
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
