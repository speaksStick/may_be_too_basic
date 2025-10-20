import 'package:event/event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
import 'package:may_be_too_basic/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireBaseService {

  //Singleton pattern implementation
  static FireBaseService _myFireBaseServiceSingleTonObject = FireBaseService._internal();
  factory FireBaseService.singleTonServiceObject() {
    return _myFireBaseServiceSingleTonObject;
  }
  FireBaseService._internal();

  final Event<UserEventArgs> UserAuthChangeNotificationEvent = Event();  
  late User? _CurrentUserAuthStatus;

  //The below api is to initialize the Firebase App globally
  Future<void> initializeFireBaseAppAsync() async {
    // Initialization code for Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //Listening to auth state changes, each time auth state changes, we raise an event.
    //If user is null, it means user is signed out. Then need to login again.
    //If user is non-null, it means user is signed in. Then no need of login again.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Firebase Auth State Changed. User is: ${user?.uid ?? 'null'}");
      _CurrentUserAuthStatus = user;
      UserAuthChangeNotificationEvent.broadcast(UserEventArgs(user));
    });

    //Getting the current user auth status at the time of app initialization
    //The userChanges() is a superset of authStateChanges() and idTokenChanges().
    //userChanges() notifies about all changes to the user, including profile updates.
    //So, the userChanges() is more comprehensive to get the current user status about sign-in/sign-out as well as profile updates.
    _CurrentUserAuthStatus = await FirebaseAuth.instance.userChanges().first;
  }

  Future<UserCredential> CreateUserWithEmalilAndPasswordAsync(String email, String password) async {
    // Implementation for creating user with email and password
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> SignInUserWithEmailAndPasswordAsync(String email, String password) async {
    // Implementation for signing in user with email and password
    var user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return user;
  }

  Future<bool> SignOutUserAsync() async
  {
    await FirebaseAuth.instance.signOut();
    return true;
  }

  User? GetUserAuthStateFromTheAppRestartTime()
  { 
    return _CurrentUserAuthStatus;
  }
}


class UserEventArgs extends EventArgs {
  User? user;
  UserEventArgs(this.user);
}