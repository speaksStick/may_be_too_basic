import 'package:flutter/material.dart';
import 'package:streak_calendar/streak_calendar.dart';
import 'package:uuid/uuid.dart';

class Habits {
  //Member variables
  String habitName;
  String myHabitDescription = "";
  Color habitColor = Colors.grey; // Default color
  DateTime myHabitCompletionDateTime = new DateTime(1970, 1, 1);
  String habitUId = Uuid().v1();
  List<DateTime> myHabitCompletionDates = [];
  

  //Getter methods
  String HabitName() => habitName;
  String HabitDescription() => myHabitDescription;
  Color HabitColor() => habitColor;
  DateTime HabitCompletionDateTime() => myHabitCompletionDateTime;
  String HabitUid() => habitUId;
  List<DateTime> HabitCompletionDates() => myHabitCompletionDates;

  Habits({required this.habitName});

 set setHabitCompletionDateTime(DateTime dateTime) {
    if (dateTime == null) {
      print("DateTime is null, cannot set habit completion date");
      return;
    }
    myHabitCompletionDateTime = dateTime;
    print("Successfully set habit completion date to $myHabitCompletionDateTime");

    var habitCompletionDate = DateTime(
      myHabitCompletionDateTime.year,
      myHabitCompletionDateTime.month,
      myHabitCompletionDateTime.day,
    );

    //Check if the previous date exists in the list. If so, then add today's date to count the streak
    // ToDo: Need to store all the dates in future to 
    // show for user all the dates he completed the habit
    if(myHabitCompletionDates.contains(habitCompletionDate.subtract(Duration(days: 1))))
    {
      print("Habit streak continues, adding today's date to habit completion dates");

      if (!myHabitCompletionDates.contains(habitCompletionDate)) {
      myHabitCompletionDates.add(habitCompletionDate);
      print("Added $habitCompletionDate to habit completion dates");
    } else {
      print("$habitCompletionDate already exists in habit completion dates");
    }
    }
    else
    {
      print("Habit streak broken, resetting habit completion dates to today's date only");
      myHabitCompletionDates.clear();
      myHabitCompletionDates.add(habitCompletionDate);
      print("Reset habit completion dates to $myHabitCompletionDates");
    }
  

    
  }

  set setHabitDescription(String habitDescription) {
    if (habitDescription == null || habitDescription.isEmpty) {
      print("Habit name is null or empty, cannot set habit name");
      return;
    }
    myHabitDescription = habitDescription;
    print("Successfully set habit name to $habitName");
  }

  set setHabitColor(Color color) {
    if (color == null) {
      print("Color is null, cannot set habit color");
      return;
    }
    habitColor = color;
    print("Successfully set habit color to $habitColor");
  }


  bool GetTodaysHabitCompletionCertificate() {
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
      myHabitCompletionDateTime.year,
      myHabitCompletionDateTime.month,
      myHabitCompletionDateTime.day,
    );

    if(myHabitCompletionDateTime!=null && habitCompletionDate.isBefore( dateTimeToday))
    {
      myHabitCompletionDateTime = DateTime(1970, 1, 1);
      print("Resetting habit completion date to $myHabitCompletionDateTime");
      return false;
    }
    if(myHabitCompletionDateTime!=null && myHabitCompletionDateTime.isAfter(dateTimeToday))
    {
      print(
          "Habit completion date $myHabitCompletionDateTime is after today's date $dateTimeToday"     
      );
      return true;
    }
    print("Habit completion date $myHabitCompletionDateTime is not after today's date $dateTimeToday");
    return false;
  }

  Widget GenerateStreakCalendarView() 
  {
    return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row
        (
          children: 
          [
            Text("${StreakStringBuilder()}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        Icon( Icons.star_border_purple500,
          color: const Color.fromARGB(255, 207, 25, 70),
        ),
          ],
        )
        
        ,SizedBox(height: 12),
        Container(
          child: CleanCalendar(
            //ToDo: Need to provide the week view and month view toggle button
            datePickerCalendarView: DatePickerCalendarView.monthView ,
            streakDatesProperties: DatesProperties
            (
                  datesDecoration: DatesDecoration(
                datesBackgroundColor:
                    Color.fromARGB(255, 229, 116, 64), // Light blue background for streak dates

                /// - datesTextColor, changes the dates text color.
                datesTextColor:
                    Colors.white, // White text color for streak dates

                ///datesTextStyle, changes the dates text style.
                datesTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),

                //   /// - datesBorderColor, changes the dates border color.
                datesBorderColor: Colors.blueGrey,

                //   /// - datesBorderRadius, changes the dates border radius.
                datesBorderRadius: 8.0,
              )),
              enableDenseSplashForDates: true,
              datesForStreaks: [...myHabitCompletionDates],
            ),
          ),
        ],
      ),
    );
  }

  String StreakStringBuilder()
  {
    if(myHabitCompletionDates.isEmpty){
      return "";
    }
    if(myHabitCompletionDates.length == 1)
    {
      return "1 day streak";
    }
    else
    {
      return "${myHabitCompletionDates.length} days streak";
    }
  }
}
