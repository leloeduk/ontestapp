import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static const String _realBannerAdUnitId =
      'ca-app-pub-3010995346645294/8251589755';
  static const String _realInterstitialAdUnitId =
      'ca-app-pub-3010995346645294/7357310486';
  static const String _realRewardedAdUnitId =
      'ca-app-pub-3010995346645294/6044228819';

  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static String get _bannerAdUnitId =>
      kDebugMode ? _testBannerAdUnitId : _realBannerAdUnitId;
  static String get _interstitialAdUnitId =>
      kDebugMode ? _testInterstitialAdUnitId : _realInterstitialAdUnitId;
  static String get _rewardedAdUnitId =>
      kDebugMode ? _testRewardedAdUnitId : _realRewardedAdUnitId;

  static String get bannerAdUnitId => _bannerAdUnitId;
  static String get interstitialAdUnitId => _interstitialAdUnitId;
  static String get rewardedAdUnitId => _rewardedAdUnitId;

  static Future<void> initialize() => MobileAds.instance.initialize();

  static BannerAd createBannerAd({
    required void Function(Ad ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
    AdSize? size,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (_, error) => onAdFailedToLoad(error),
      ),
    );
  }

  static Future<InterstitialAd?> loadInterstitialAd() async {
    final completer = Completer<InterstitialAd?>();
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );
    return completer.future;
  }

  static Future<RewardedAd?> loadRewardedAd() async {
    final completer = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );
    return completer.future;
  }
}
