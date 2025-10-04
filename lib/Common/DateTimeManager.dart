import 'package:event/event.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';

class DateTimeManager
{
  final Event<DateTimeEventArgs> MidNightNotificationEvent = Event();  
  final Event<DateTimeEventArgs> EveningNotificationEvent = Event();  

  static DateTime get GetCurrentLocalDateTime => DateTime.now();
  bool _myIsMidNightNotificationSentOnceForTheDay = false;
  bool _myIsEveningNotificationSentOnceForTheDay = false;

  //ToDo: Implmentation to stream line to be able to raise multiple notifications
  List<int> _myListOfTimesWhereEventsNeedToBeRaised = List.empty();
  set ListOfTimesWhereEventsNeedToBeHeard(int aTimeIWantAnEvent)
  {
    _myListOfTimesWhereEventsNeedToBeRaised.add(aTimeIWantAnEvent);
  }
  
  //Follows the singleton pattern by providing the singleton instance
  static DateTimeManager _myDateTimeManagerSingleTonInstance = DateTimeManager._internal();
  DateTimeManager._internal();
  static DateTimeManager get DateTimeManagerSingleTonInstance => _myDateTimeManagerSingleTonInstance;

  //Testability constructor
  DateTimeManager.TestRelatedConstructor();

  //Public API
  //Async method to be started. This sends the midnight notification exactly after 12 AM in the night
  //The client needs to subscribe to MidNightNotification event.
  void StartTimeTrackerAndSendLocalNotificationsAtDesignatedTimes() async
  {
    print("${GetCurrentLocalDateTime} StartTimeTrackerAndSendLocalMidNightNotifications called");

    while(true)
    {
      print("${GetCurrentLocalDateTime} =============StartTimeTrackerAndSendLocalMidNightNotifications loop started============");

      //ToDo: Need to stream line event raising in an efficient manner (eg: channels)
      //Logic for raising the Midnight event
      if(_CheckIfNotificationFlagCanBeReset(GetCurrentLocalDateTime, hourHandWhenCannotResetFlag: 0))
      {
        _myIsMidNightNotificationSentOnceForTheDay = false;
      }
      if(_CheckLocalTargetTimeHasComeToRaiseEvents(GetCurrentLocalDateTime, 0, 0 ,hourHandValueToRaiseEvent: 0) && !_myIsMidNightNotificationSentOnceForTheDay)
      {
        MidNightNotificationEvent.broadcast(DateTimeEventArgs(dateTimeEventArgs: GetCurrentLocalDateTime));
        _myIsMidNightNotificationSentOnceForTheDay = true;
      }

      //Logic for raising the Evening event
      if(_CheckIfNotificationFlagCanBeReset(GetCurrentLocalDateTime, hourHandWhenCannotResetFlag: 20))
      {
        _myIsEveningNotificationSentOnceForTheDay = false;
      }
      if(_CheckLocalTargetTimeHasComeToRaiseEvents(GetCurrentLocalDateTime, 0, 0, hourHandValueToRaiseEvent: 20) && !_myIsEveningNotificationSentOnceForTheDay)
      {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Raising evening event, time ${GetCurrentLocalDateTime}");

        EveningNotificationEvent.broadcast(DateTimeEventArgs(dateTimeEventArgs: GetCurrentLocalDateTime));
        _myIsEveningNotificationSentOnceForTheDay = true;
      }

      await Future.delayed(const Duration(seconds: 10));
      print("${GetCurrentLocalDateTime} =============StartTimeTrackerAndSendLocalMidNightNotifications loop ended============");
    }
    
  }

  

//Private methods
//Checks wether the local time has crossed the designated hour, min, sec hands.
bool _CheckLocalTargetTimeHasComeToRaiseEvents(DateTime currentLocalDateTime, int minuteHand, int secondHand, {required int hourHandValueToRaiseEvent}) 
{
  if(currentLocalDateTime.hour == hourHandValueToRaiseEvent && currentLocalDateTime.minute > minuteHand && currentLocalDateTime.second > secondHand )
  {
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Entered _CheckLocalTargetTimeHasComeToRaiseEvents (Time has come) with currentTime, ${currentLocalDateTime}");

    return true;
  }
  GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Entered _CheckLocalTargetTimeHasComeToRaiseEvents (Time yet to come) with hourHand: ${hourHandValueToRaiseEvent}, currentTime, ${currentLocalDateTime}");

  return false;
}

//Private methods
//Checks if the Midnight notification flag could be reset,
//Returns true if hour hand is not at 12 AM otherwise false.
bool _CheckIfNotificationFlagCanBeReset(DateTime currentLocalDateTime, {required hourHandWhenCannotResetFlag})
{
  if(currentLocalDateTime.hour != hourHandWhenCannotResetFlag)
  {
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Entered _CheckIfNotificationFlagCanBeReset (Flag reset) with hourHand: ${hourHandWhenCannotResetFlag}, ${currentLocalDateTime}");
    return true;
  }
  GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Entered _CheckIfNotificationFlagCanBeReset (Flag Noreset) with hourHand: ${hourHandWhenCannotResetFlag}, ${currentLocalDateTime}");
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