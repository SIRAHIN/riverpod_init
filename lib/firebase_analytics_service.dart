import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: _analytics); 


  Future<void> logEvent({required String eventName, required Map<String, Object> params}) async{
    await _analytics.logEvent(name: eventName, parameters: params);
  }
}