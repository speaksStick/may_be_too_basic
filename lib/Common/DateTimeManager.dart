import 'package:event/event.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
import 'package:may_be_too_basic/Common/StringSerializerAndDeserializer.dart';
import 'package:may_be_too_basic/Services/HiveStorageService.dart';

class DateTimeManager
{
  final Event<DateTimeEventArgs> MidNightNotificationEvent = Event();  
  final Event<DateTimeEventArgs> EveningNotificationEvent = Event(); 
  final Event<CustomEventTimeEventArgs> CustomTimeNotificationEvent = Event();
  late final HiveStorageservice _myHiveStorageService;

  static DateTime get GetCurrentLocalDateTime => DateTime.now();
  bool _myIsMidNightNotificationSentOnceForTheDay = false;
  bool _myIsEveningNotificationSentOnceForTheDay = false;

  //ToDo: Implmentation to stream line to be able to raise multiple notifications
  Map<String, List<CustomTimeEventInfoStruct>> _myCustomMapWhereEventsNeedToBeRaised = {};

  //Follows the singleton pattern by providing the singleton instance
  static DateTimeManager _myDateTimeManagerSingleTonInstance = DateTimeManager._internal(GlobalObjectProvider.HiveStorageServiceSingleTonObject);
  DateTimeManager._internal(HiveStorageservice hiveStorageService)
  {
    _myHiveStorageService = hiveStorageService;
  }

  static DateTimeManager get DateTimeManagerSingleTonInstance => _myDateTimeManagerSingleTonInstance;

  //Testability constructor
  DateTimeManager.TestRelatedConstructor();


  //Private method to add custom time when an event needs to be heard
  //Clients need to add the custom time in 24 hour format
  //An event at the custom time will be raised once in a day.
  //It's the client's responsibility to subscribe to the CustomTimeNotificationEvent event
  //And handle the event when raised accordingly
  void _AddMyCustomTimeWhenIWantEventToBeHeard({required int hourHand, required int minuteHand, required String habitUIdWhichRequestedEvent, required bool isEventRaisedForTheDay})
  {
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("AddMyCustomTimeWhenIWantEventToBeHeard called for habitUId: ${habitUIdWhichRequestedEvent}, hourHand: ${hourHand}, minuteHand: ${minuteHand}");

    if(_myCustomMapWhereEventsNeedToBeRaised.containsKey(habitUIdWhichRequestedEvent))
    {
      //When the key already exists, add the new custom time event info struct to the existing map entry.
      var listOfCustomTimeEventInfoStruct = _myCustomMapWhereEventsNeedToBeRaised[habitUIdWhichRequestedEvent];
      listOfCustomTimeEventInfoStruct?.add(
        CustomTimeEventInfoStruct(hourWhenEventNeedsToBeRaised: hourHand, minuteWhenEventNeedsToBeRaised: minuteHand, isEventRaisedForTheDay: isEventRaisedForTheDay)
      );
      _myCustomMapWhereEventsNeedToBeRaised[habitUIdWhichRequestedEvent] = listOfCustomTimeEventInfoStruct!;
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Added new custom time event for existing habitUId: ${habitUIdWhichRequestedEvent}");
    }
    else
    {
      //When the key does not exist, create a new list and add the custom time event info struct to map.
      var listOfCustomTimeEventInfoStruct = List<CustomTimeEventInfoStruct>.empty(growable: true);
      listOfCustomTimeEventInfoStruct.add(
        CustomTimeEventInfoStruct(hourWhenEventNeedsToBeRaised: hourHand, minuteWhenEventNeedsToBeRaised: minuteHand, isEventRaisedForTheDay: isEventRaisedForTheDay)
      );
      _myCustomMapWhereEventsNeedToBeRaised[habitUIdWhichRequestedEvent] = listOfCustomTimeEventInfoStruct;
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("New entry created in custom time event map for habitUId: ${habitUIdWhichRequestedEvent}");
    }
  }

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

      //Logic for raising the Custom time event
      CheckAndRaiseTheCustomTimeEvents();

      await Future.delayed(const Duration(seconds: 10));
      print("${GetCurrentLocalDateTime} =============StartTimeTrackerAndSendLocalMidNightNotifications loop ended============");
    }
    
  }

  void CheckAndRaiseTheCustomTimeEvents() {

    //Refresh the custom notification times from hive storage
    _GetCustomNotificationTimesForHabitFromHiveStorageAndInformDateTimeManager();


    for(var habitUId in _myCustomMapWhereEventsNeedToBeRaised.keys)
    {
      //Raise the events based on the custom time added by the client
      var listOfCustomTimeEventInfoStruct = _myCustomMapWhereEventsNeedToBeRaised[habitUId];

      if(listOfCustomTimeEventInfoStruct!= null)
      {
        for(var customTimeEventInfoStruct in listOfCustomTimeEventInfoStruct)
        {
          if(customTimeEventInfoStruct._myIsEventRaisedForTheDay == false)
          {
            if(_CheckLocalTargetTimeHasComeToRaiseEvents(GetCurrentLocalDateTime, customTimeEventInfoStruct._myMinuteWhenEventNeedsToBeRaised, 0, hourHandValueToRaiseEvent: customTimeEventInfoStruct._myHourWhenEventNeedsToBeRaised))
            {
                CustomTimeNotificationEvent.broadcast
                (
                  CustomEventTimeEventArgs(
                    hourWhenEventNeedsToBeRaised: customTimeEventInfoStruct._myHourWhenEventNeedsToBeRaised, 
                    minuteWhenEventNeedsToBeRaised: customTimeEventInfoStruct._myMinuteWhenEventNeedsToBeRaised,
                    habitUIdWhichRequestedEvent: habitUId
                  )
                );
                //customTimeEventInfoStruct._myIsEventRaisedForTheDay = true;
                _myHiveStorageService.UpdateHabitNotificationHourMinuteList((customTimeEventInfoStruct.HourWhenEventNeedsToBeRaised, customTimeEventInfoStruct.MinuteWhenEventNeedsToBeRaised, habitUId, true));
                GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Custom time event raised for habitUId: ${habitUId}, hourHand: ${customTimeEventInfoStruct._myHourWhenEventNeedsToBeRaised}, minuteHand: ${customTimeEventInfoStruct._myMinuteWhenEventNeedsToBeRaised}");
            }
          }
          if(customTimeEventInfoStruct._myIsEventRaisedForTheDay == true)
          {
            if(_CheckIfNotificationFlagCanBeReset(GetCurrentLocalDateTime, hourHandWhenCannotResetFlag: customTimeEventInfoStruct._myHourWhenEventNeedsToBeRaised))
            {
                _myHiveStorageService.UpdateHabitNotificationHourMinuteList((customTimeEventInfoStruct.HourWhenEventNeedsToBeRaised, customTimeEventInfoStruct.MinuteWhenEventNeedsToBeRaised, habitUId, false));
              GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Custom time event flag reset for habitUId: ${habitUId}, hourHand: ${customTimeEventInfoStruct._myHourWhenEventNeedsToBeRaised}, minuteHand: ${customTimeEventInfoStruct._myMinuteWhenEventNeedsToBeRaised}");
            }
          }
        }
      }
      
    }
  }

  Map GetReadOnlyCustomNotificationTimesForAllHabits()
  {
    _GetCustomNotificationTimesForHabitFromHiveStorageAndInformDateTimeManager();
    var readOnlyMap = Map.unmodifiable(_myCustomMapWhereEventsNeedToBeRaised);
    return  readOnlyMap;
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

void _GetCustomNotificationTimesForHabitFromHiveStorageAndInformDateTimeManager() 
  {
    var allHabitsFromHiveStorage = _myHiveStorageService.GetAllHabitsFromHiveBox();

    //Clean up the map by removing entries where all custom notification time is present.
    //Freshly add the custom notification time info struct to the map from the hive storage.
    _myCustomMapWhereEventsNeedToBeRaised.clear();

    for(var habit in allHabitsFromHiveStorage) 
    {
      for(var hourMinuteTupleString in habit.myCustomNotificationHourMinuteStringOfHabitList)
      {
        // var hourMinuteParts = hourMinuteTupleString.split('-');
        // var hourHand = int.parse( hourMinuteParts[0]);
        // var minuteHand = int.parse( hourMinuteParts[1]);
        // var isNotificationSentForTheDay = hourMinuteParts[3].toLowerCase() == 'true' ? true : false;

        var deserializedMap = StringSerializerAndDeserializer.DeserializeHifenSeperatedStringForHabitNotificationTime(hifenSeperatedHabitNotificationString: hourMinuteTupleString);
        var hourHand = deserializedMap['hourHand'] as int;
        var minuteHand = deserializedMap['minuteHand'] as int;
        var isNotificationSentForTheDay = deserializedMap['isNotificationSentForTheDay'] as bool;
        
        _AddMyCustomTimeWhenIWantEventToBeHeard(
          hourHand: hourHand, 
          minuteHand: minuteHand, 
          habitUIdWhichRequestedEvent: habit.habitUId,
          isEventRaisedForTheDay: isNotificationSentForTheDay
        );
      }
    }
  }

}

//Class to hold the eventArgs extending from the EventArgs class
class DateTimeEventArgs extends EventArgs
{
  DateTime? _myDateTimeEventArgs = null;
  
  DateTimeEventArgs({required DateTime? dateTimeEventArgs}) : _myDateTimeEventArgs = dateTimeEventArgs;

  get DateTimeEventArgsForEvents => _myDateTimeEventArgs;
}

class CustomEventTimeEventArgs extends EventArgs
{
  late int _myHourWhenEventNeedsToBeRaised;
  late int _myMinuteWhenEventNeedsToBeRaised;
  String _myHabitUIdWhichRequestedEvent = "";

  get HabitUidWhichRequestedEvent => _myHabitUIdWhichRequestedEvent;

  CustomEventTimeEventArgs({required int hourWhenEventNeedsToBeRaised, required int minuteWhenEventNeedsToBeRaised, required String habitUIdWhichRequestedEvent}) 
  {
      _myHourWhenEventNeedsToBeRaised = hourWhenEventNeedsToBeRaised;
      _myMinuteWhenEventNeedsToBeRaised = minuteWhenEventNeedsToBeRaised;
      _myHabitUIdWhichRequestedEvent = habitUIdWhichRequestedEvent;
  } 
}

class CustomTimeEventInfoStruct
{
  late int _myHourWhenEventNeedsToBeRaised;
  late int _myMinuteWhenEventNeedsToBeRaised;
  late bool _myIsEventRaisedForTheDay;

  //Getter
  int get HourWhenEventNeedsToBeRaised => _myHourWhenEventNeedsToBeRaised;
  int get MinuteWhenEventNeedsToBeRaised => _myMinuteWhenEventNeedsToBeRaised;
  bool get IsEventRaisedForTheDay => _myIsEventRaisedForTheDay;

  CustomTimeEventInfoStruct({required int hourWhenEventNeedsToBeRaised, required int minuteWhenEventNeedsToBeRaised,  required bool isEventRaisedForTheDay})
  {
    _myHourWhenEventNeedsToBeRaised = hourWhenEventNeedsToBeRaised;
    _myMinuteWhenEventNeedsToBeRaised = minuteWhenEventNeedsToBeRaised;
    _myIsEventRaisedForTheDay = isEventRaisedForTheDay;
  }
  
}