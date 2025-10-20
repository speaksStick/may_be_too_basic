import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:may_be_too_basic/Services/FireBaseService.dart';
import 'package:may_be_too_basic/Services/LoggerService.dart';
import 'package:may_be_too_basic/ViewModel/RegisterUserViewModel.dart';

class LoginUserViewModel extends ChangeNotifier
{

  late LoggerService _loggerService;
  late FireBaseService _firebaseService;
  UserLoginErrorStatus _myErrorCondition = UserLoginErrorStatus.none;

  LoginUserViewModel(LoggerService loggerService, FireBaseService firebaseService)
  {
    _loggerService = loggerService;
    _firebaseService = firebaseService;
  }

  Future<bool> LoginUserWithEmailAndPasswordAsync(UserData userData) async
  {
    try
    {
      UserCredential userCredential = await _firebaseService.SignInUserWithEmailAndPasswordAsync(userData.userEmail, userData.userPassword);
      if(userCredential.user != null)
      {
        _loggerService.LogMessage("User logged in successfully: ${userCredential.toString()}"); 
        return true;
      }
      else
      {
        _myErrorCondition = UserLoginErrorStatus.unknownError;
        _loggerService.LogMessage(_myErrorCondition.toString());
        notifyListeners();
        return false;
      }
    }
    catch(e)
    {
      _ConvertFirebaseAuthExceptionStringToErrorStatus(e);
      _loggerService.LogError("User logging in failed with status: ${_myErrorCondition.toString()}");
      _loggerService.LogError("User logging in failed with error: ${e.toString()}");

      return false;
    }
  }

  Future<bool> SignOutUserAsync() async
  {
    return await _firebaseService.SignOutUserAsync();
  }

  UserLoginErrorStatus GetUserLoginErrorStatus()
  {
    var returnableErrorStatus = _myErrorCondition;
    //Setting back the error condition to none after reading it, so that UI is cleared for next attempt
    _myErrorCondition = UserLoginErrorStatus.none;
    return returnableErrorStatus;
  } 

  void _ConvertFirebaseAuthExceptionStringToErrorStatus(Object e) {
    switch(e)
    {
      case FirebaseAuthException firebaseAuthException:
          if(firebaseAuthException.code == 'email-already-in-use')
          {
            _myErrorCondition = UserLoginErrorStatus.emailAlreadyInUse;
          }
          else if(firebaseAuthException.code == 'weak-password')
          {
            _myErrorCondition = UserLoginErrorStatus.weakPassword;
          }
          else if(firebaseAuthException.code == 'invalid-email')
          {
            _myErrorCondition = UserLoginErrorStatus.invalidEmail;
          }
          else
          {
            _myErrorCondition =  UserLoginErrorStatus.unknownError;
          }
          notifyListeners();
          break; 
        default:
        {
          _myErrorCondition = UserLoginErrorStatus.unknownError;
        }
        notifyListeners();
    }
  }
}

enum UserLoginErrorStatus
{
  none,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  unknownError
}