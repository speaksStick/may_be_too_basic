import 'package:event/event.dart';

class DateTimeManager
{
  final Event<DateTimeEventArgs> MidNightNotificationEvent = Event();  
  DateTime get GetCurrentLocalDateTime => DateTime.now();
  bool _myIsMidNightNotificationSentOnceForTheDay = false;

  //Follows the singleton pattern by providing the singleton instance
  static DateTimeManager _myDateTimeManagerSingleTonInstance = DateTimeManager._internal();
  DateTimeManager._internal();
  static DateTimeManager get DateTimeManagerSingleTonInstance => _myDateTimeManagerSingleTonInstance;


  //Public API
  //Async method to be started. This sends the midnight notification exactly after 12 AM in the night
  //The client needs to subscribe to MidNightNotification event.
  void StartTimeTrackerAndSendLocalMidNightNotifications() async
  {
    print("${GetCurrentLocalDateTime} StartTimeTrackerAndSendLocalMidNightNotifications called");

    while(true)
    {
      print("${GetCurrentLocalDateTime} =============StartTimeTrackerAndSendLocalMidNightNotifications loop started============");

      if(_CheckIfMidNightNotificationFlagCanBeReset(GetCurrentLocalDateTime))
      {
        _myIsMidNightNotificationSentOnceForTheDay = false;
      }
      if(_CheckLocalMidNightTimeCrossed(GetCurrentLocalDateTime) && !_myIsMidNightNotificationSentOnceForTheDay)
      {
        MidNightNotificationEvent.broadcast(DateTimeEventArgs(dateTimeEventArgs: GetCurrentLocalDateTime));
      }
      await Future.delayed(const Duration(seconds: 10));
      print("${GetCurrentLocalDateTime} =============StartTimeTrackerAndSendLocalMidNightNotifications loop ended============");
    }
    
  }

  //  bool IsNewDayStartedToResetHabitCompletionCertificate({required habitCompletionDateTime, required midNightDateTimeAsPerMidNightNotificationEvent})
  //  {

  //  }

//Private methods
//Checks wether the local time has crossed the midnight by checking the hour hand
bool _CheckLocalMidNightTimeCrossed(DateTime currentLocalDateTime) 
{
  if(currentLocalDateTime.hour == 0 && currentLocalDateTime.minute > 0 )
  {
    return true;
  }
  return false;
}

//Private methods
//Checks if the Midnight notification flag could be reset,
//Returns true if hour hand is not at 12 AM otherwise false.
bool _CheckIfMidNightNotificationFlagCanBeReset(DateTime currentLocalDateTime)
{
  if(currentLocalDateTime.hour != 0)
  {
    return true;
  }
  return false;
}

}

//Class to hold the eventArgs extending from the EventArgs class
class DateTimeEventArgs extends EventArgs
{
  DateTime? _myDateTimeEventArgs = null;
  
  DateTimeEventArgs({required DateTime? dateTimeEventArgs}) : _myDateTimeEventArgs = dateTimeEventArgs;

  get DateTimeEventArgsForEvents => _myDateTimeEventArgs;
}