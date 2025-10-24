import 'package:flutter/material.dart';
import 'package:may_be_too_basic/Common/StringSerializerAndDeserializer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streak_calendar/streak_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'HabitsModel.g.dart';

///This class represents the Model in the MVVM pattern
///This class is used to store the data for a habit
///This class is used by the ViewModel to update the data
@HiveType(typeId: 0)
class HabitsModel {

  //Member variables
  @HiveField(0)
  String habitName;
  @HiveField(1)
  String myHabitDescription = "";
  @HiveField(2)
  int habitColorInt = Colors.grey.value ; // Default color
  @HiveField(3)
  DateTime myHabitCompletionDateTime = new DateTime(1970, 1, 1);
  @HiveField(4)
  String habitUId = Uuid().v1();
  @HiveField(5)
  List<DateTime> myHabitCompletionDates = [];
  @HiveField(6)
  List<DateTime> myTotalHabitCompletionDatesForStreakCalendar = [];
  @HiveField(7)
  List<String> myCustomNotificationHourMinuteStringOfHabitList = [];

  //Getter methods
  String HabitName() => habitName;
  String HabitDescription() => myHabitDescription;
  Color HabitColor() => Color(habitColorInt);
  DateTime HabitCompletionDateTime() => myHabitCompletionDateTime;
  String HabitUid() => habitUId;
  List<DateTime> HabitCompletionDates() => myHabitCompletionDates;
  List<DateTime> TotalHabitCompletionDatesForStreakCalendar() =>
      myTotalHabitCompletionDatesForStreakCalendar;

  //Constructor with required parameters as Habit name
  HabitsModel({required this.habitName});

  set setCustomNotificationHourMinuteOfHabitList((int hourHand, int minuteHand, String habitUid, bool isNotificationSentForTheDay) customNotificationHourMinuteOfHabitList) 
  {
    String finalStringOfHourAndMinuteHand = _GetSerializedString(customNotificationHourMinuteOfHabitList);

    for(var existingString in myCustomNotificationHourMinuteStringOfHabitList)
    {
      var deserializedMap = StringSerializerAndDeserializer.DeserializeHifenSeperatedStringForHabitNotificationTime(
        hifenSeperatedHabitNotificationString: existingString,
      );
      if(_IsSameNotificationTimeEntryExists(deserializedMap, customNotificationHourMinuteOfHabitList))
      {
        print("Custom notification hour minute list is same as existing, not updating");

        _UpdateIsNotificationSentForDayValueIfDifferent(deserializedMap, customNotificationHourMinuteOfHabitList, existingString, finalStringOfHourAndMinuteHand);
        return;
      }
    }
        print("Custom notification hour minute list is different, updating");
        AddNewNotificationTimeToList(finalStringOfHourAndMinuteHand);
        print("Successfully set custom notification hour minute list to $myCustomNotificationHourMinuteStringOfHabitList");
  }

  bool DeleteACustomNotificationTimeFromHabitList((int hourHand, int minuteHand, String habitUid, bool isNotificationSentForTheDay) customNotificationHourMinuteOfHabitList) 
  {
    for(var existingString in myCustomNotificationHourMinuteStringOfHabitList)
    {
      var deserializedMap = StringSerializerAndDeserializer.DeserializeHifenSeperatedStringForHabitNotificationTime(
        hifenSeperatedHabitNotificationString: existingString,
      );
      if(_IsSameNotificationTimeEntryExists(deserializedMap, customNotificationHourMinuteOfHabitList))
      {
        print("Custom notification hour minute listfound, hence deleting");
        myCustomNotificationHourMinuteStringOfHabitList.remove(existingString);
        return true;
      }
    }
        print("Custom notification hour minute list was not found in habit list");
        return false;
  }

  void AddNewNotificationTimeToList(String finalStringOfHourAndMinuteHand) {
    myCustomNotificationHourMinuteStringOfHabitList.add(finalStringOfHourAndMinuteHand);
  }

  bool _IsSameNotificationTimeEntryExists(Map<String, dynamic> deserializedMap, (int, int, String, bool) customNotificationHourMinuteOfHabitList) {
    return deserializedMap['hourHand'] == customNotificationHourMinuteOfHabitList.$1 &&
       deserializedMap['minuteHand'] == customNotificationHourMinuteOfHabitList.$2 &&
       deserializedMap['habitUid'] == customNotificationHourMinuteOfHabitList.$3;
  }

  void _UpdateIsNotificationSentForDayValueIfDifferent(Map<String, dynamic> deserializedMap, (int, int, String, bool) customNotificationHourMinuteOfHabitList, String existingString, String finalStringOfHourAndMinuteHand) {
    if(deserializedMap['isNotificationSentForTheDay'] != customNotificationHourMinuteOfHabitList.$4)
    {
      print("Notification sent for the day value is different, updating");
      myCustomNotificationHourMinuteStringOfHabitList.remove(existingString);
      myCustomNotificationHourMinuteStringOfHabitList.add(finalStringOfHourAndMinuteHand);
      print("Successfully set custom notification hour minute list to $myCustomNotificationHourMinuteStringOfHabitList");
    }
  }

  String _GetSerializedString((int, int, String, bool) customNotificationHourMinuteOfHabitList) {
    var finalStringOfHourAndMinuteHand = StringSerializerAndDeserializer.StringifyWithHifenSeperatedForHabitNotificationTime(
      hourHand: customNotificationHourMinuteOfHabitList.$1,
      minuteHand: customNotificationHourMinuteOfHabitList.$2,
      habitUid: customNotificationHourMinuteOfHabitList.$3,
      isNotificationSentForTheDay: customNotificationHourMinuteOfHabitList.$4,
    );
    return finalStringOfHourAndMinuteHand;
  }

  //Setter methods

  ///Sets the completion date for the habit
  ///Also updates the habit completion dates list to maintain the streak
  set setHabitCompletionDateTime(DateTime dateTime) {

    if (dateTime == null) 
    {
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
    //In the below if block we are subtratcting one day from the current date to check if the previous date exists in the list
    //, it says yesterday exists in the list, then we can add today to the list to continue the streak
    if (myHabitCompletionDates.contains(habitCompletionDate.subtract(Duration(days: 1)))) 
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
      print(
          "Habit streak broken, resetting habit completion dates to today's date only");
      myHabitCompletionDates.clear();
      myHabitCompletionDates.add(habitCompletionDate);
      print("Reset habit completion dates to $myHabitCompletionDates");
    }

    // Add to total habit completion dates for streak calendar
    if (!myTotalHabitCompletionDatesForStreakCalendar
        .contains(habitCompletionDate)) 
  {
      myTotalHabitCompletionDatesForStreakCalendar.add(habitCompletionDate);
      print(
          "Added $habitCompletionDate to total habit completion dates for streak calendar");
    } else {
      print(
          "$habitCompletionDate already exists in total habit completion dates for streak calendar");
    }
  }

  //?Sets the habit description for the habit
  set setHabitDescription(String habitDescription) {
    if (habitDescription == null || habitDescription.isEmpty) {
      print("Habit name is null or empty, cannot set habit name");
      return;
    }
    myHabitDescription = habitDescription;
    print("Successfully set habit name to $habitName");
  }

  ///Sets the habit color for the habit
  ///Default color is grey
  set setHabitColor(Color color) {
    if (color == null) {
      print("Color is null, cannot set habit color");
      return;
    }
    habitColorInt = color.value;
    print("Successfully set habit color to $habitColorInt");
  }

  ///Generates the streak calendar view widget
  ///Takes in the media query data and the color for the streak days
  Widget GenerateStreakCalendarViewWidget(
      MediaQueryData mediaQuery, Color? colorForStreakDays) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Shimmer.fromColors(
            child: Text(
              "${myStreakStringBuilder()}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            baseColor: const Color.fromARGB(255, 198, 136, 37),
            highlightColor: Colors.lightBlueAccent,
            period: Duration(seconds: 2),
          ),
          SizedBox(height: 12),
          Container(
            child: SizedBox(
              child: CleanCalendar(
                //ToDo: Need to provide the week view and month view toggle button
                datePickerCalendarView: DatePickerCalendarView.monthView,
                streakDatesProperties: DatesProperties(
                    datesDecoration: DatesDecoration(
                  datesBackgroundColor:
                      colorForStreakDays, // Light blue background for streak dates
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
                datesForStreaks: [
                  ...myTotalHabitCompletionDatesForStreakCalendar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///Calculates the longest streak length from the list of habit completion dates
  ///Takes in the list of habit completion dates
  int GetLongestStreakLength(
      List<DateTime> totalHabitCompletionDatesForStreakCalendar) {
    int longestStreakLength = 0;
    var streakRestart = true;
    List<int> streakLengthList = List<int>.empty(growable: true);
    DateTime? expectedNextDayDate = null;
    for (int streakDates = 0;
        streakDates < totalHabitCompletionDatesForStreakCalendar.length;
        streakDates++) {
      final currentDayDate =
          totalHabitCompletionDatesForStreakCalendar[streakDates];
      if ((expectedNextDayDate != null &&
              currentDayDate == expectedNextDayDate) ||
          streakDates == 0 ||
          streakRestart == true) {
        longestStreakLength++;
        print("Current streak length increased: $longestStreakLength");
        expectedNextDayDate = currentDayDate.add(Duration(days: 1));
        streakRestart = false;
      } else {
        streakLengthList.add(longestStreakLength);
        print("Streak broken, current streak length: $longestStreakLength");
        longestStreakLength = 0;
        //expectedNextDayDate = currentDayDate.add(Duration(days: 1));
        expectedNextDayDate = null;
        streakRestart = true;
        streakDates--;
      }
    }
    streakLengthList.add(longestStreakLength);
    streakLengthList.sort();
    var finalLongestStreakLength =
        streakLengthList.isNotEmpty ? streakLengthList.last : 0;
    print(
        "###################Longest streak calculated as: ${finalLongestStreakLength}");
    return finalLongestStreakLength;
  }

  // Private methods
  String myStreakStringBuilder() {
    if (myHabitCompletionDates.isEmpty) {
      return "";
    }
    if (myHabitCompletionDates.length == 1) {
      return "  1 day streak 🔥\n"
          " Longest streak days:  ${GetLongestStreakLength(myTotalHabitCompletionDatesForStreakCalendar)}";
    } else {
      return " ${myHabitCompletionDates.length} days streak 🔥\n"
          " Longest streak days:  ${GetLongestStreakLength(myTotalHabitCompletionDatesForStreakCalendar)}";
    }
  }
}
