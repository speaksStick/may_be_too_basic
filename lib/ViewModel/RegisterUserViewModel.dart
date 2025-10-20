import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:may_be_too_basic/Services/FireBaseService.dart';
import 'package:may_be_too_basic/Services/LoggerService.dart';


class RegisterUserViewModel extends ChangeNotifier
{
  late LoggerService _loggerService;
  late FireBaseService _firebaseService;
  UserRegisterationErrorStatus _myErrorCondition = UserRegisterationErrorStatus.none;

  RegisterUserViewModel(LoggerService loggerService, FireBaseService firebaseService)
  {
    _loggerService = loggerService;
    _firebaseService = firebaseService;
  }

  Future<bool> RegisterUserAsync(UserData userData) async
  {
    try
    {
      UserCredential userCredential = await _firebaseService.CreateUserWithEmalilAndPasswordAsync(userData.userEmail, userData.userPassword);
      if(userCredential.user != null)
      {
        _loggerService.LogMessage("User registered successfully: ${userCredential.toString()}"); 
        return true;
      }
      else
      {
        _myErrorCondition = UserRegisterationErrorStatus.unknownError;
        _loggerService.LogMessage(_myErrorCondition.toString());
        notifyListeners();
        return false;
      }
    }
    catch(e)
    {
      _ConvertFirebaseAuthExceptionStringToErrorStatus(e);
      _loggerService.LogError("User registration failed with status: ${_myErrorCondition.toString()}");
      _loggerService.LogError("User registration failed with error: ${e.toString()}");

      return false;
    }
  }

   UserRegisterationErrorStatus GetUserRegsitrationErrorStatus()
  {
    var returnableErrorStatus = _myErrorCondition;
    //Setting back the error condition to none after reading it, so that UI is cleared for next attempt
    _myErrorCondition = UserRegisterationErrorStatus.none;
    return returnableErrorStatus;
  } 

  void _ConvertFirebaseAuthExceptionStringToErrorStatus(Object e) {
    switch(e)
    {
      case FirebaseAuthException firebaseAuthException:
          if(firebaseAuthException.code == 'email-already-in-use')
          {
            _myErrorCondition = UserRegisterationErrorStatus.emailAlreadyInUse;
          }
          else if(firebaseAuthException.code == 'weak-password')
          {
            _myErrorCondition = UserRegisterationErrorStatus.weakPassword;
          }
          else if(firebaseAuthException.code == 'invalid-email')
          {
            _myErrorCondition = UserRegisterationErrorStatus.invalidEmail;
          }
          else
          {
            _myErrorCondition =  UserRegisterationErrorStatus.unknownError;
          }
          notifyListeners();
          break; 
        default:
        {
          _myErrorCondition = UserRegisterationErrorStatus.unknownError;
        }
        notifyListeners();
    }
  }

}


class UserData
{
  late String userEmail;
  late String userPassword;
  String? userCity;
  int? userProfession;

  UserData(this.userEmail, this.userPassword, {this.userCity, this.userProfession});
}

class UserAuthenticationResults
{
  late bool isUserAuthenticated;
  String? errorMessage;

  UserAuthenticationResults(this.isUserAuthenticated, {this.errorMessage});
}

enum UserRegisterationErrorStatus
{
  none,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  unknownError
}