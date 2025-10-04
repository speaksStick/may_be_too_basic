
import 'package:flutter/material.dart';
import 'package:may_be_too_basic/Common/DateTimeManager.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
class Habitviewmodel extends ChangeNotifier
{

  final List<HabitsModel> myHabits = [];
  final List<Locale> supportedLocales = [Locale('en'), Locale('kn'), Locale('hi')];
  Locale preferredLocale = Locale('en');

  Locale get GetPreferredLocale => preferredLocale;
  final dateTimeManager = DateTimeManager.DateTimeManagerSingleTonInstance;

  Habitviewmodel()
  {
    print("${DateTimeManager.GetCurrentLocalDateTime} HabitviewModel contsructor called");
    dateTimeManager.MidNightNotificationEvent.subscribe((notificationArgs){OnMidNightNotificationEvent(notificationArgs);}); 
    dateTimeManager.EveningNotificationEvent.subscribe((notificationArgs){OnEveningNotificationEvent(notificationArgs);});
    dateTimeManager.StartTimeTrackerAndSendLocalNotificationsAtDesignatedTimes();  
    print("${DateTimeManager.GetCurrentLocalDateTime} HabitviewModel contsructor ended");

  }

  bool AddHabit(String habitName)
  {
    
    if(habitName == null || habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("Habit name is null or empty, cannot add into habit list");
        return false;
    }
    var newHabit = HabitsModel(habitName: habitName);
    if(myHabits.any((habit) => habit.habitName == habitName || newHabit.habitUId == habit.habitUId))
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("$newHabit already exists, cannot add into habit list");
        return false;
    }
    myHabits.add( newHabit);
    print("Successfully added ${newHabit.habitName} into habit list");
    notifyListeners();
    return true;
  }

  bool RemoveHabit(HabitsModel habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot remove into habit list");
        return false;
    }

    var removeResult = myHabits.remove( habit);
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Successfully removed $habit into habit list: $removeResult"  );
    notifyListeners();
    return removeResult;
  }

  bool EditHabitDescription(HabitsModel habit, String newDescription)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot edit into habit list");
        return false;
    }
    if(newDescription == null || newDescription.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("new description is null or empty, cannot edit into habit list");
        return false;
    }

    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot edit");
      return false;
    } 

    myHabits[habitIndex].setHabitDescription = newDescription;
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Successfully edited habit description to $newDescription");
    notifyListeners();
    return true;
  }


  bool EditHabitColor(HabitsModel habit, Color newColor)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot edit into habit list");
        return false;
    }
    if(newColor == null)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("new color is null, cannot edit into habit list");
        return false;
    }
    print("EditHabitColor called with color: $newColor for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot edit");
      return false;
    } 

    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("EditHabitColor: search successful habitIndex: ${habitIndex} habit: ${myHabits[habitIndex]} with Uid: ${myHabits[habitIndex].habitUId}");

    myHabits[habitIndex].setHabitColor = newColor;
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Successfully edited habit color to $newColor");
    notifyListeners();
    return true;
  }


  bool GetTodaysHabitCompletionCertificate(HabitsModel habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot get today's completion certificate");
        return false;
    }

    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot get today's completion certificate");
      return false;
    } 
    return myHabits[habitIndex].GetTodaysHabitCompletionCertificate();
  }



  bool SetHabitCompletionDateTime(HabitsModel habit, DateTime dateTime)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot set habit completion date");
        return false;
    }
    if(dateTime == null)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("dateTime is null, cannot set habit completion date");
        return false;
    }

    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot set habit completion date");
      return false;
    } 

    myHabits[habitIndex].setHabitCompletionDateTime = dateTime;
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Successfully set habit completion date to $dateTime");
    notifyListeners();
    return true;
  }

  String GeHabitDescription(HabitsModel habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot get habit description");
        return "";
    }
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("GeHabitDescription called for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot get habit description");
      return "";
    } 
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("GeHabitDescription: search successful habitIndex: ${habitIndex} habit: ${myHabits[habitIndex]} with Uid: ${myHabits[habitIndex].habitUId}");
    return myHabits[habitIndex].HabitDescription();
  }

  Color GetHabitColor(HabitsModel habit)
  {
    //ToDo: Change default color based on gender preference
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot get habit color");
        return Colors.grey;
    }

    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("GetHabitColor called for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot get habit color");
      return Colors.grey;
    } 
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("GetHabitColor: search successful habitIndex: ${habitIndex} habit: ${myHabits[habitIndex]} with Uid: ${myHabits[habitIndex].habitUId}");
    return myHabits[habitIndex].HabitColor();
  }

  // void LiveTimeTracker (DateTime timeNow) async
  // {
  //   while(true)
  //   {
  //    var midnight = DateTime(timeNow.year, timeNow.month, timeNow.day).add(Duration(days: 1));
  //   print(  "================LiveTimeTracker called at $timeNow======================="  );
  //   // Check if current time is after midnight
  //   if(timeNow.isAfter(midnight))
  //   {
  //     print("###It's a new day! Resetting daily habit completion statuses. timeNow: $timeNow, midnight: $midnight");
  //     ;
  //   }
  //   await Future.delayed(Duration(seconds: 15));
  //   }
    
  // }

  (bool, int) GetHabitStreakLengthAndStreakCompletionCertificate(HabitsModel habit)
  {
  
    if(habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty, cannot get habit color");
        return (false, 0);
    }

    if(habit.HabitCompletionDates().length >= 2)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("IsHabitStreakCompletionAchieved called for habit: ${habit.habitName} with Uid: ${habit.habitUId}"  );
      return (true, habit.HabitCompletionDates().length);
    }

    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("IsHabitStreakCompletionAchieved: habitIndex: habit: ${habit} with Uid: ${habit.habitUId} has less than 2 completion dates"  );
    return (false, habit.HabitCompletionDates().length);
  }

  (bool, Widget) GenerateStreakCalendarViewWidget(HabitsModel habit, MediaQueryData mediaQuery, Color? colorForStreakDays)
  {
    if(habit.habitName.isEmpty)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("habit is null or habit name is null or empty,  cannot generate streak calendar view");
        return (false, Container());
    }
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("Habit not found in the list, cannot generate streak calendar view");
      return (false, Container());
    }

    return (true, myHabits[habitIndex].GenerateStreakCalendarViewWidget(mediaQuery, colorForStreakDays));

  }

  void SetPreferredLocale(Locale locale)
  {
    if(locale == null)
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogWarning("locale is null, cannot set preferred locale");
        return;
    }
    if(!supportedLocales.contains(locale))
    {
        GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("locale $locale is not supported, cannot set preferred locale");
        return;
    }
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("Setting preferred locale to $locale");
    preferredLocale = locale;
    notifyListeners();
  }
  
  void OnMidNightNotificationEvent(DateTimeEventArgs dateTimeEventArgs) 
  {
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("=============================Received the midnight notification with dateTime : ${dateTimeEventArgs.DateTimeEventArgsForEvents} ======================");
    for(var habit in myHabits)
      {
        habit.GetTodaysHabitCompletionCertificate();
        //GetHabitStreakLengthAndStreakCompletionCertificate(habit);
      }
      //notifyListeners to update UI, it will update all the listeners at main.dart and builds the respective widgets.
      notifyListeners();
  }

  void OnEveningNotificationEvent(DateTimeEventArgs dateTimeEventArgs) {
    GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage(
        "=============================Received the Evening notification with dateTime : ${dateTimeEventArgs.DateTimeEventArgsForEvents} ======================");
    var listOfUnFinishedHabits =
        myHabits.where((m) => m.GetTodaysHabitCompletionCertificate() == false);

    if (listOfUnFinishedHabits.length > 0) {
      GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage(
          "There are uncompleted habits today");
      GlobalObjectProvider.FlutterlocalnotificationsServiceSingleTonObject
          .ShowNotification(
              title: "You have an uncompleted habit today",
              body: "Try Completing asap to continue streak!");
    }
  }
}
