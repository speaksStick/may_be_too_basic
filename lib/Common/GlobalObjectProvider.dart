import 'package:may_be_too_basic/Services/FlutterlocalnotificationsService.dart';
import 'package:may_be_too_basic/Services/LoggerService.dart';

class GlobalObjectProvider 
{
  static Future<void> InitializeAllServicesAndAssociates() async
  {
    //Below code first creates the singleton object using the factory constructor of FlutterLocalNotificationsService,
    // then fills the member variable : _myFlutterlocalnotificationsService to be used by other clients.
    // After creating of singleton instance, calls the service initialization.
    //ToDo: The permission to be obtained only after the app starts and logged on.
    // Now its asking before the app even starts
    _myFlutterlocalnotificationsService = FlutterLocalNotificationsService.singleTonServiceObject();
    await _myFlutterlocalnotificationsService.InitializeLocalNotificationsService();
    await _myFlutterlocalnotificationsService.GetFlutterLocalNotificationsPermissionForAndroid();

    //The below code creates the LogginService Singleton initilization object
    _myLoggerServiceSingleTonObject = await LoggerService.InitializeSingleTonLoggingService();
  }

  //LoggerService object initialization
  static late LoggerService _myLoggerServiceSingleTonObject;
  static LoggerService get LoggerServiceSingleTonObject => _myLoggerServiceSingleTonObject;

  //FlutterlocalnotificationsService object initialization
  static late FlutterLocalNotificationsService _myFlutterlocalnotificationsService;
  static FlutterLocalNotificationsService get FlutterlocalnotificationsServiceSingleTonObject => _myFlutterlocalnotificationsService;
}