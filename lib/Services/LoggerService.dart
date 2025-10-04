import 'dart:io';

import 'package:logger/logger.dart';
import 'package:may_be_too_basic/Common/DateTimeManager.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService {

  static Directory? _myApplicationDocDirectory = Directory("");
  static File _myLogFile = File("");
  static final LoggerService _singleTonLoggingServiceObject =
      LoggerService._internal();
  static late Logger myLoggerService;

  //Private Constructor
  LoggerService._internal();

  //Testability constructor
  LoggerService.TestRelatedConstructor();

  //Async Initializer method to get a singleton object of LoggerService class
  static Future<LoggerService> InitializeSingleTonLoggingService() async {

    //Important info on below code:
    //await, it will wait for the async operation to finish before continuing to the next line in that function.
    //Other async operations in your app (in other functions or isolates) can still run in parallel, but inside the same async function, execution will pause at each await until the awaited Future completes.
    await _createLoggingDirectory();

    myLoggerService = Logger(
        printer: PrettyPrinter(
            methodCount: 0, // Number of method calls to be displayed
            errorMethodCount:
                8, // Number of method calls if stacktrace is provided
            lineLength: 120, // Width of the output
            colors: true, // Colorful log messages
            printEmojis: false, // Print emojis
            //printTime: false, // Should each log print a timestamp
            noBoxingByDefault: true,
          ),
        filter: ProductionFilter(),
        output: LogOutPutDesignator(
            myFileToStoreLogs:
                _myLogFile) // Or DevelopmentFilter() for more verbose logs in debug
        );
    await _initializeLoggerService();

    return _singleTonLoggingServiceObject;
  }

  //Private methods
  static Future<void> _createLoggingDirectory() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _myApplicationDocDirectory = await getApplicationDocumentsDirectory();
      _myLogFile = File(
          '${_myApplicationDocDirectory?.path}/may_be_too_basic_app_logs.log');
      print("path to log is: ${_myLogFile.path}");
    }
    // } else {
    //   // For desktop (Windows, macOS, Linux)
    //   final directory = await getDownloadsDirectory();
    //   if (!await directory!.exists()) {
    //     await directory.create(recursive: true);
    //   }
    //   _myLogFile = File('${directory.path}/FlutterLogs.log');
    // }
    await _myLogFile!.create();
  }

  static Future<void> _initializeLoggerService() async {
    if (_myLogFile != null) {
      if (!await _myLogFile!.exists()) {
        await _myLogFile!.create();
      } else {
      await _myLogFile!.writeAsString(''); //Remove all old log contents
      }
    }
    await myLoggerService.init;
  }


  //Public api for logging
  void LogMessage(String message) {
    myLoggerService.i("${DateTimeManager.GetCurrentLocalDateTime}  - ${message}");
  }

  void LogError(String message) {
    myLoggerService.e("${DateTimeManager.GetCurrentLocalDateTime}  - ${message}");
  }

  void LogWarning(String message) {
    myLoggerService.w("${DateTimeManager.GetCurrentLocalDateTime}  - ${message}");
  }
}

//The class to hold the overriden output method to Log based on our wish.
class LogOutPutDesignator extends LogOutput {
  final File myFileToStoreLogs;

  LogOutPutDesignator({required this.myFileToStoreLogs});

  @override
  void output(OutputEvent event) async {
    var isLoggingInSameLine = false;
    for (var individualLines in event.lines) {
      var logString = individualLines.trim();
      await myFileToStoreLogs.writeAsString("\n${individualLines}",  mode: FileMode.append);
      // if (!isLoggingInSameLine) {
      //   await myFileToStoreLogs.writeAsString("\n${individualLines}",
      //       mode: FileMode.append);
      // } else {
      //   await myFileToStoreLogs.writeAsString("\t${individualLines}",
      //       mode: FileMode.append);
      // }
      isLoggingInSameLine = true;
    }
  }
}
