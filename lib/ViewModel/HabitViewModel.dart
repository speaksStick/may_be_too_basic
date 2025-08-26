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
    var habit = Habits(habitName: habitName);
    if(myHabits.contains( habit))
    {
        print("$habit already exists, cannot add into habit list");
        return false;
    }
    myHabits.add( habit);
    print("Successfully added ${habit.habitName} into habit list");
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

    var habitIndex = myHabits.indexOf(habit);

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

    var habitIndex = myHabits.indexOf(habit);

    if(habitIndex == -1)
    {
      print("Habit not found in the list, cannot edit");
      return false;
    } 

    myHabits[habitIndex].setHabitColor = newColor;
    print("Successfully edited habit color to $newColor");
    notifyListeners();
    return true;
  }
  
}