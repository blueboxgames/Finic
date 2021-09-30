import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'dart:async';

class Analytics {
  static late FirebaseAnalytics _firebaseAnalytics;
  static late FirebaseAnalyticsObserver _observer;

  static Future<void> init(
      FirebaseAnalytics analytics, FirebaseAnalyticsObserver observer) async {
    _firebaseAnalytics = analytics;
    _observer = observer;

    GameAnalytics.setEnabledInfoLog(false);
    GameAnalytics.setEnabledVerboseLog(false);

    // GameAnalytics.configureAvailableCustomDimensions01(["ninja", "samurai"]);
    // GameAnalytics.configureAvailableCustomDimensions02(["whale", "dolphin"]);
    // GameAnalytics.configureAvailableCustomDimensions03(["horde", "alliance"]);
    GameAnalytics.configureAvailableResourceCurrencies(["coin"]);
    GameAnalytics.configureAvailableResourceItemTypes(
        ["game", "confirm", "shop", "start"]);

    GameAnalytics.configureAutoDetectAppVersion(true);
    GameAnalytics.initialize("2c9380c96ef57f01f353906b341a21cc",
        "275843fe2b762882e938a16d6b095d7661670ee9");
  }

  static Future<void> purchase(String currency, double amount, String itemId,
      String itemType, String receipt, String signature) async {
    // if (iOS) {
    //   await _firebaseAnalytics.logEcommercePurchase(
    //       currency: currency,
    //       value: amount,
    //       transactionId: signature,
    //       origin: itemId,
    //       coupon: receipt);
    // }

    GameAnalytics.addBusinessEvent({
      "currency": currency,
      "amount": (amount * 100),
      "itemType": itemType,
      "itemId": itemId,
      "cartType": "end_of_level",
      "receipt": receipt,
      "signature": signature,
    });
  }

  static Future<void> ad(int action, int adType, String placementID,
      [String sdkName = "unityads"]) async {
    _firebaseAnalytics.logEvent(
      name: 'ad_${action.toString()}',
      parameters: <String, dynamic>{
        'adType': adType.toString(),
        'placementID': placementID,
        'sdkName': sdkName,
      },
    );

    GameAnalytics.addAdEvent({
      "adAction": action,
      "adType": adType,
      "adSdkName": sdkName,
      "adPlacement": placementID
    });
  }

  }
