
import 'package:flutter/material.dart';
import 'package:may_be_too_basic/Common/DateTimeManager.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
import 'package:may_be_too_basic/Services/HiveStorageService.dart';
import 'package:may_be_too_basic/Services/LoggerService.dart';
class Habitviewmodel extends ChangeNotifier
{

  bool _myStateChanged = false;
  final List<Locale> supportedLocales = [Locale('en'), Locale('kn'), Locale('hi')];
  Locale preferredLocale = Locale('en');

  Locale get GetPreferredLocale => preferredLocale;
  late LoggerService _myLoggerService;
  late HiveStorageservice _myHiveStorageService;

  Habitviewmodel(DateTimeManager dateTimeManager, LoggerService loggerService, HiveStorageservice hiveStorageService)
  {
    print("${DateTimeManager.GetCurrentLocalDateTime} HabitviewModel contsructor called");
    _myLoggerService = loggerService;
    _myHiveStorageService = hiveStorageService;
    dateTimeManager.MidNightNotificationEvent.subscribe((notificationArgs){OnMidNightNotificationEvent(notificationArgs);}); 
    dateTimeManager.EveningNotificationEvent.subscribe((notificationArgs){OnEveningNotificationEvent(notificationArgs);});
    dateTimeManager.StartTimeTrackerAndSendLocalNotificationsAtDesignatedTimes();  
    print("${DateTimeManager.GetCurrentLocalDateTime} HabitviewModel contsructor ended");
  }

  Habitviewmodel.Product(): this(DateTimeManager.DateTimeManagerSingleTonInstance, GlobalObjectProvider.LoggerServiceSingleTonObject, GlobalObjectProvider.HiveStorageServiceSingleTonObject);
  

  Future<bool> AddHabit(String habitName) async
  {
    
    if(habitName == null || habitName.isEmpty)
    {
        _myLoggerService.LogWarning("Habit name is null or empty, cannot add into habit list");
        return false;
    }
    var newHabit = HabitsModel(habitName: habitName);
    
    //myHabits.add( newHabit);
    _myStateChanged = !_myStateChanged;
    await _myHiveStorageService.AddHabitToHiveBox(newHabit);
    print("Successfully added ${newHabit.habitName} into habit list");
    notifyListeners();
    return true;
  }

  Future<bool> RemoveHabit(HabitsModel habit) async
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot remove into habit list");
        return false;
    }

    //var removeResult = myHabits.remove( habit);
    _myStateChanged = !_myStateChanged;
    await _myHiveStorageService.DeleteHabitFromHiveBox(habit);
    _myLoggerService.LogMessage("Successfully removed $habit from hive storage habit"  );
    notifyListeners();
    return true;
  }

  Future<bool> EditHabitDescription(HabitsModel habit, String newDescription) async
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot edit into habit list");
        return false;
    }
    if(newDescription == null || newDescription.isEmpty)
    {
        _myLoggerService.LogWarning("new description is null or empty, cannot edit into habit list");
        return false;
    }

    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);
    _myStateChanged = !_myStateChanged;
    await _myHiveStorageService.UpdateHabitDescriptionInHiveStorage(habit, newDescription);

    _myLoggerService.LogMessage("Successfully edited habit description to $newDescription");
    notifyListeners();
    return true;
  }


  Future<bool> EditHabitColor(HabitsModel habit, Color newColor) async
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot edit into habit list");
        return false;
    }
    if(newColor == null)
    {
        _myLoggerService.LogWarning("new color is null, cannot edit into habit list");
        return false;
    }
    print("EditHabitColor called with color: $newColor for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);
    _myStateChanged = !_myStateChanged;

    await _myHiveStorageService.UpdateHabitColor(habit, newColor.value);
    _myLoggerService.LogMessage("Successfully edited habit color to $newColor");
    notifyListeners();
    return true;
  }


  bool GetTodaysHabitCompletionCertificate(HabitsModel habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot get today's completion certificate");
        return false;
    }

    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    return GetTodaysHabitCompletionCertificateUsingHabitDateTime(habit.HabitCompletionDateTime());
  }



  Future<bool> SetHabitCompletionDateTime(HabitsModel habit, DateTime dateTime) async
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot set habit completion date");
        return false;
    }
    if(dateTime == null)
    {
        _myLoggerService.LogWarning("dateTime is null, cannot set habit completion date");
        return false;
    }

    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);
    _myStateChanged = !_myStateChanged;

    await _myHiveStorageService.UpdateHabitCompletionDateTime(habit, dateTime);
    _myLoggerService.LogMessage("Successfully set habit completion date to $dateTime");
    notifyListeners();
    return true;
  }

  String GeHabitDescription(HabitsModel habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot get habit description");
        return "";
    }
    _myLoggerService.LogMessage("GeHabitDescription called for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    return GetAllHabitsFromHiveStorage().firstWhere((m) => m.habitUId == habit.habitUId).HabitDescription();
  }

  Color GetHabitColor(HabitsModel habit)
  {
    //ToDo: Change default color based on gender preference
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot get habit color");
        return Colors.grey;
    }

    _myLoggerService.LogMessage("GetHabitColor called for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    return GetAllHabitsFromHiveStorage().firstWhere((m) => m.habitUId == habit.habitUId).HabitColor();
  }

  (bool, int) GetHabitStreakLengthAndStreakCompletionCertificate(HabitsModel habit)
  {
  
    if(habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty, cannot get habit color");
        return (false, 0);
    }

    if(habit.HabitCompletionDates().length >= 2)
    {
      _myLoggerService.LogMessage("IsHabitStreakCompletionAchieved called for habit: ${habit.habitName} with Uid: ${habit.habitUId}"  );
      return (true, habit.HabitCompletionDates().length);
    }

    _myLoggerService.LogMessage("IsHabitStreakCompletionAchieved: habitIndex: habit: ${habit} with Uid: ${habit.habitUId} has less than 2 completion dates"  );
    return (false, habit.HabitCompletionDates().length);
  }

  (bool, Widget) GenerateStreakCalendarViewWidget(HabitsModel habit, MediaQueryData mediaQuery, Color? colorForStreakDays)
  {
    if(habit.habitName.isEmpty)
    {
        _myLoggerService.LogWarning("habit is null or habit name is null or empty,  cannot generate streak calendar view");
        return (false, Container());
    }
    //var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    return (true, GetAllHabitsFromHiveStorage().firstWhere((m) => m.habitUId == habit.habitUId).GenerateStreakCalendarViewWidget(mediaQuery, colorForStreakDays));

  }

  void SetPreferredLocale(Locale locale)
  {
    if(locale == null)
    {
        _myLoggerService.LogWarning("locale is null, cannot set preferred locale");
        return;
    }
    if(!supportedLocales.contains(locale))
    {
        _myLoggerService.LogError("locale $locale is not supported, cannot set preferred locale");
        return;
    }
    _myStateChanged = !_myStateChanged;

    _myLoggerService.LogMessage("Setting preferred locale to $locale");
    preferredLocale = locale;
    notifyListeners();
  }
  
  void OnMidNightNotificationEvent(DateTimeEventArgs dateTimeEventArgs) 
  {
    _myLoggerService.LogMessage("=============================Received the midnight notification with dateTime : ${dateTimeEventArgs.DateTimeEventArgsForEvents} ======================");
    for(var habit in GetAllHabitsFromHiveStorage())
      {
        GetTodaysHabitCompletionCertificateUsingHabitDateTime(habit.HabitCompletionDateTime());
        //GetHabitStreakLengthAndStreakCompletionCertificate(habit);
      }
      //notifyListeners to update UI, it will update all the listeners at main.dart and builds the respective widgets.
      notifyListeners();
  }

  void OnEveningNotificationEvent(DateTimeEventArgs dateTimeEventArgs) {
    _myLoggerService.LogMessage(
        "=============================Received the Evening notification with dateTime : ${dateTimeEventArgs.DateTimeEventArgsForEvents} ======================");
    var listOfUnFinishedHabits =
        GetAllHabitsFromHiveStorage().where((m) => GetTodaysHabitCompletionCertificateUsingHabitDateTime(m.HabitCompletionDateTime()) == false);

    if (listOfUnFinishedHabits.length > 0) {
      _myLoggerService.LogMessage(
          "There are uncompleted habits today");
      GlobalObjectProvider.FlutterlocalnotificationsServiceSingleTonObject
          .ShowNotification(
              title: "You have an uncompleted habit today",
              body: "Try Completing asap to continue streak!");
    }
  }

  List<HabitsModel> GetAllHabitsFromHiveStorage()
  {
    //notifyListeners();
    return _myHiveStorageService.GetAllHabitsFromHiveBox();
  }

  ///Public methods
  ///Returns true if the habit is marked as completed for today, 
  ///false otherwise
  bool GetTodaysHabitCompletionCertificateUsingHabitDateTime(DateTime habitCompletionDateTime) {
    DateTime dateTimeNow = DateTime.now();
    DateTime dateTimeToday = DateTime(
      dateTimeNow.year,
      dateTimeNow.month,
      dateTimeNow.day,
      0,
      0,
      0,
    );

    DateTime habitCompletionDate = DateTime(
      habitCompletionDateTime.year,
      habitCompletionDateTime.month,
      habitCompletionDateTime.day,
    );

    if (habitCompletionDateTime != null &&
        habitCompletionDate.isBefore(dateTimeToday)) {
      habitCompletionDateTime = DateTime(1970, 1, 1);
      print("Resetting habit completion date to $habitCompletionDateTime");
      return false;
    }
    if (habitCompletionDateTime != null &&
        habitCompletionDateTime.isAfter(dateTimeToday)) {
      print(
          "Habit completion date $habitCompletionDateTime is after today's date $dateTimeToday");
      return true;
    }
    print(
        "Habit completion date $habitCompletionDateTime is not after today's date $dateTimeToday");
    return false;
  }
}
