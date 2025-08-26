import 'package:flutter/material.dart';

class Habits 
{

  String HabitName () =>  habitName;
  String HabitDescription () =>  myHabitDescription;
  Color HabitColor () => habitColor;

  String habitName;
  String myHabitDescription = "";
  Color habitColor = Colors.grey; // Default color

  Habits({required this.habitName});

  set setHabitDescription(String habitDescription) 
  {
    if(habitDescription == null || habitDescription.isEmpty)
    {
        print("Habit name is null or empty, cannot set habit name");
        return;
    }
    myHabitDescription = habitDescription;
    print("Successfully set habit name to $habitName");
  }

  set setHabitColor(Color color)
  {
    if(color == null)
    {
        print("Color is null, cannot set habit color");
        return;
    }
    habitColor = color;
    print("Successfully set habit color to $habitColor");
  }
}