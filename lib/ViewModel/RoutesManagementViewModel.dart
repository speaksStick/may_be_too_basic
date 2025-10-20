import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:may_be_too_basic/Services/FireBaseService.dart';
import 'package:may_be_too_basic/Services/LoggerService.dart';
import 'package:provider/provider.dart';

class RoutesManagementViewmodel extends ChangeNotifier
{
  late final LoggerService _loggerService;
  late User? _authStateUseStatus = null;
  late final FireBaseService _firebaseService;

  RoutesManagementViewmodel(FireBaseService firebaseService, LoggerService loggerService) 
  {
    _loggerService = loggerService;
    _firebaseService = firebaseService;
    _authStateUseStatus = _firebaseService.GetUserAuthStateFromTheAppRestartTime();
    firebaseService.UserAuthChangeNotificationEvent.subscribe((userEventArgs){
    OnUserAuthChangeNotificationEvent(this, userEventArgs);
    });
  }


  void OnUserAuthChangeNotificationEvent(Object? sender, UserEventArgs userEventArgs)
  {
    _loggerService.LogMessage("RoutesManagementViewmodel received User Auth Change Notification Event. User is: ${userEventArgs.user?.uid ?? 'null'}");
    _authStateUseStatus = userEventArgs.user;
    notifyListeners();
  }

  User? GetUserAuthStatus()
  {
    return _authStateUseStatus;
  }
}