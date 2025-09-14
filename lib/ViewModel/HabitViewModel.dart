import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:may_be_too_basic/Models/Habits.dart';
 
class Habitviewmodel extends ChangeNotifier
{

  final List<Habits> myHabits = [];

  bool AddHabit(String habitName)
  {
    
    if(habitName == null || habitName.isEmpty)
    {
        print("Habit name is null or empty, cannot add into habit list");
        return false;
    }
    var newHabit = Habits(habitName: habitName);
    if(myHabits.any((habit) => habit.habitName == habitName || newHabit.habitUId == habit.habitUId))
    {
        print("$newHabit already exists, cannot add into habit list");
        return false;
    }
    myHabits.add( newHabit);
    print("Live time tracker initiated");
    LiveTimeTracker();
    print("Successfully added ${newHabit.habitName} into habit list");
    notifyListeners();
    return true;
  }

  bool RemoveHabit(Habits habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot remove into habit list");
        return false;
    }

    var removeResult = myHabits.remove( habit);
    print(  "Successfully removed $habit into habit list: $removeResult"  );
    notifyListeners();
    return removeResult;
  }

  bool EditHabitDescription(Habits habit, String newDescription)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot edit into habit list");
        return false;
    }
    if(newDescription == null || newDescription.isEmpty)
    {
        print("new description is null or empty, cannot edit into habit list");
        return false;
    }

    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot edit");
      return false;
    } 

    myHabits[habitIndex].setHabitDescription = newDescription;
    print("Successfully edited habit description to $newDescription");
    notifyListeners();
    return true;
  }


  bool EditHabitColor(Habits habit, Color newColor)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot edit into habit list");
        return false;
    }
    if(newColor == null)
    {
        print("new color is null, cannot edit into habit list");
        return false;
    }
    print("EditHabitColor called with color: $newColor for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot edit");
      return false;
    } 

    print("EditHabitColor: search successful habitIndex: ${habitIndex} habit: ${myHabits[habitIndex]} with Uid: ${myHabits[habitIndex].habitUId}");

    myHabits[habitIndex].setHabitColor = newColor;
    print("Successfully edited habit color to $newColor");
    notifyListeners();
    return true;
  }


  bool GetTodaysHabitCompletionCertificate(Habits habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot get today's completion certificate");
        return false;
    }

    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot get today's completion certificate");
      return false;
    } 
    return myHabits[habitIndex].GetTodaysHabitCompletionCertificate();
  }



  bool SetHabitCompletionDateTime(Habits habit, DateTime dateTime)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot set habit completion date");
        return false;
    }
    if(dateTime == null)
    {
        print("dateTime is null, cannot set habit completion date");
        return false;
    }

    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot set habit completion date");
      return false;
    } 

    myHabits[habitIndex].setHabitCompletionDateTime = dateTime;
    print("Successfully set habit completion date to $dateTime");
    notifyListeners();
    return true;
  }

  String GeHabitDescription(Habits habit)
  {
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot get habit description");
        return "";
    }
    print("GeHabitDescription called for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot get habit description");
      return "";
    } 
    print("GeHabitDescription: search successful habitIndex: ${habitIndex} habit: ${myHabits[habitIndex]} with Uid: ${myHabits[habitIndex].habitUId}");
    return myHabits[habitIndex].HabitDescription();
  }

  Color GetHabitColor(Habits habit)
  {
    //ToDo: Change default color based on gender preference
    if(habit == null || habit.habitName == null || habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot get habit color");
        return Colors.grey;
    }

    print("GetHabitColor called for habit: ${habit.habitName} with Uid: ${habit.habitUId}");
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot get habit color");
      return Colors.grey;
    } 
    print("GetHabitColor: search successful habitIndex: ${habitIndex} habit: ${myHabits[habitIndex]} with Uid: ${myHabits[habitIndex].habitUId}");
    return myHabits[habitIndex].HabitColor();
  }

  void LiveTimeTracker () async
  {
    while(true)
    {
     var timeNow = DateTime.timestamp();
     var midnight = DateTime(timeNow.year, timeNow.month, timeNow.day).add(Duration(days: 1));
    print(  "================LiveTimeTracker called at $timeNow======================="  );
    // Check if current time is after midnight
    if(timeNow.isAfter(midnight))
    {
      print("###It's a new day! Resetting daily habit completion statuses. timeNow: $timeNow, midnight: $midnight");
      for(var habit in myHabits)
      {
        habit.GetTodaysHabitCompletionCertificate();
      }
      notifyListeners();
    }
    await Future.delayed(Duration(seconds: 15));
    }
    
  }

  (bool, int) IsHabitStreakCompletionAchieved(Habits habit)
  {
  
    if(habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty, cannot get habit color");
        return (false, 0);
    }

    if(habit.myHabitCompletionDates.length >= 2)
    {
      print("IsHabitStreakCompletionAchieved called for habit: ${habit.habitName} with Uid: ${habit.habitUId}"  );
      return (true, habit.myHabitCompletionDates.length);
    }

    print("IsHabitStreakCompletionAchieved: habitIndex: habit: ${habit} with Uid: ${habit.habitUId} has less than 2 completion dates"  );
    return (false, habit.myHabitCompletionDates.length);
  }

  (bool, Widget) GenerateStreakCalendarView(Habits habit)
  {
    if(habit.habitName.isEmpty)
    {
        print("habit is null or habit name is null or empty,  cannot generate streak calendar view");
        return (false, Container());
    }
    var habitIndex = myHabits.indexWhere((h) => h.habitUId == habit.habitUId);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot generate streak calendar view");
      return (false, Container());
    }

    return (true, myHabits[habitIndex].GenerateStreakCalendarView());

  }

}