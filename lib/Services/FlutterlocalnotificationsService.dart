import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FlutterLocalNotificationsService {

  //The name _internal is a convention in Dart for private named constructors used in singleton patterns.
  //The underscore (_) makes the constructor private to the library.
  //internal is just a descriptive name, meaning "for internal use only".
  static final FlutterLocalNotificationsService _singleTonServiceObject = FlutterLocalNotificationsService._internal();
  factory FlutterLocalNotificationsService.singleTonServiceObject() => _singleTonServiceObject;
  FlutterLocalNotificationsService._internal();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get IsInitialized => _isInitialized;

//Public api, async api to return Future<void>
//Initialize the notification service
  Future<void> InitializeLocalNotificationsService() async {
    if (IsInitialized) return; //If already initialized, return

//Initialization settings for Android
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

//Initialization settings for iOS
    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

//Initialization settings for both platforms
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

//Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _isInitialized = true; //Set initialized to true
  }

//Public api, to get the notification details
  NotificationDetails GetNotificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'dummy_channel_id', // unique id
          'General Notifications', // name visible in settings
          channelDescription: 'This channel is used for general notifications',
          importance: Importance.max, // required
          priority: Priority.high, // required
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(subtitle: "Dummy sub title"));
  }

//Public api to Show the notification
  Future<void> ShowNotification(
      {int id = 0, String title = "TITLE", String body = "BODY"}) async {
    return await flutterLocalNotificationsPlugin.show(
        id, title, body, GetNotificationDetails());
  }

//Public api to get the permissions for the Local Notifications for android
  Future<void> GetFlutterLocalNotificationsPermissionForAndroid() async {
    //ToDo : need to rewrite the below code to a new api
    //to ask for the permissions at the beginning of the app or when the first habit is set.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}
