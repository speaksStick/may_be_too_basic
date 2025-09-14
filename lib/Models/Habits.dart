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
  List<DateTime> myTotalHabitCompletionDatesForStreakCalendar = [];

  //Getter methods
  String HabitName() => habitName;
  String HabitDescription() => myHabitDescription;
  Color HabitColor() => habitColor;
  DateTime HabitCompletionDateTime() => myHabitCompletionDateTime;
  String HabitUid() => habitUId;
  List<DateTime> HabitCompletionDates() => myHabitCompletionDates;
  List<DateTime> TotalHabitCompletionDatesForStreakCalendar() => myTotalHabitCompletionDatesForStreakCalendar;

  Habits({required this.habitName});

  set setHabitCompletionDateTime(DateTime dateTime) {
    if (dateTime == null) {
      print("DateTime is null, cannot set habit completion date");
      return;
    }
    myHabitCompletionDateTime = dateTime;
    print(
        "Successfully set habit completion date to $myHabitCompletionDateTime");

    var habitCompletionDate = DateTime(
      myHabitCompletionDateTime.year,
      myHabitCompletionDateTime.month,
      myHabitCompletionDateTime.day,
    );

    //Check if the previous date exists in the list. If so, then add today's date to count the streak
    // ToDo: Need to store all the dates in future to
    // show for user all the dates he completed the habit
    //In the below if block we are subtratcting one day from the current date to check if the previous date exists in the list
    //, it says yesterday exists in the list, then we can add today to the list to continue the streak
    if (myHabitCompletionDates
        .contains(habitCompletionDate.subtract(Duration(days: 1)))) {
      print(
          "Habit streak continues, adding today's date to habit completion dates");

      if (!myHabitCompletionDates.contains(habitCompletionDate)) {
        myHabitCompletionDates.add(habitCompletionDate);
        print("Added $habitCompletionDate to habit completion dates");
      } else {
        print("$habitCompletionDate already exists in habit completion dates");
      }
    } else {
      print(
          "Habit streak broken, resetting habit completion dates to today's date only");
      myHabitCompletionDates.clear();
      myHabitCompletionDates.add(habitCompletionDate);
      print("Reset habit completion dates to $myHabitCompletionDates");
    }

    // Add to total habit completion dates for streak calendar
    if(!myTotalHabitCompletionDatesForStreakCalendar.contains(habitCompletionDate))
    {
      myTotalHabitCompletionDatesForStreakCalendar.add(habitCompletionDate);
      print("Added $habitCompletionDate to total habit completion dates for streak calendar");
    }
    else
    {
      print("$habitCompletionDate already exists in total habit completion dates for streak calendar");
    }
  }


  //Sets the habit description
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

    if (myHabitCompletionDateTime != null &&
        habitCompletionDate.isBefore(dateTimeToday)) {
      myHabitCompletionDateTime = DateTime(1970, 1, 1);
      print("Resetting habit completion date to $myHabitCompletionDateTime");
      return false;
    }
    if (myHabitCompletionDateTime != null &&
        myHabitCompletionDateTime.isAfter(dateTimeToday)) {
      print(
          "Habit completion date $myHabitCompletionDateTime is after today's date $dateTimeToday");
      return true;
    }
    print(
        "Habit completion date $myHabitCompletionDateTime is not after today's date $dateTimeToday");
    return false;
  }

  Widget GenerateStreakCalendarViewWidget(MediaQueryData mediaQuery, Color? colorForStreakDays) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${_StreakStringBuilder()}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 12),
          Container(
            child: SizedBox(
              child: CleanCalendar(
                //ToDo: Need to provide the week view and month view toggle button
                datePickerCalendarView: DatePickerCalendarView.monthView,
                streakDatesProperties: DatesProperties(
                    datesDecoration: DatesDecoration(
                  datesBackgroundColor: colorForStreakDays, // Light blue background for streak dates
                  datesTextColor: Colors.white,
              
                  datesTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
              
                  datesBorderColor: Colors.blueGrey,
              
                  datesBorderRadius: 8.0,
                )),
                enableDenseSplashForDates: true,
                //myTotalHabitCompletionDatesForStreakCalendar is used to show all the dates the habit was completed
                //, this is different from myHabitCompletionDates which is used to show the current streak
                datesForStreaks: [...myTotalHabitCompletionDatesForStreakCalendar],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Private methods
  String _StreakStringBuilder() {
    if (myHabitCompletionDates.isEmpty) {
      return "";
    }
    if (myHabitCompletionDates.length == 1) {
      return "  1 day streak 🔥\n" "   Longest streak ";
    } else {
      return "  ${myHabitCompletionDates.length} days streak 🔥\n" "   Longest streak";
    }
  }
}
