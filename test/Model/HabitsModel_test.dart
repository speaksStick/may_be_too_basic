import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';

void main() {
  group('HabitsModel', () {
    late HabitsModel habitModel;

    setUp(() {
      habitModel = HabitsModel(habitName: 'Test Habit');
    });

    test('Constructor sets habit name', () {
      expect(habitModel.HabitName(), 'Test Habit');
    });

    test('Set and get habit description', () {
      habitModel.setHabitDescription = 'New Description';
      expect(habitModel.HabitDescription(), 'New Description');
    });

    test('Set and get habit color', () {
      habitModel.setHabitColor = Colors.red;
      expect(habitModel.HabitColor(), Colors.red);
    });

    test('Set and get habit completion date', () {
      final date = DateTime(2023, 9, 17);
      habitModel.setHabitCompletionDateTime = date;
      expect(habitModel.HabitCompletionDateTime(), date);
    });

    test('Set habit completion date adds to streak and total dates', () {
      final date = DateTime(2023, 9, 17);
      habitModel.setHabitCompletionDateTime = date;
      expect(habitModel.HabitCompletionDates().contains(DateTime(2023, 9, 17)), true);
      expect(habitModel.TotalHabitCompletionDatesForStreakCalendar().contains(DateTime(2023, 9, 17)), true);
    });

    test('Set habit completion date resets streak if not consecutive', () {
      final date1 = DateTime(2023, 9, 15);
      final date2 = DateTime(2023, 9, 17);
      habitModel.setHabitCompletionDateTime = date1;
      habitModel.setHabitCompletionDateTime = date2;
      expect(habitModel.HabitCompletionDates().length, 1);
      expect(habitModel.HabitCompletionDates().first, date2);
    });

    test('Set habit completion date continues streak if consecutive', () {
      final date1 = DateTime(2023, 9, 15);
      final date2 = DateTime(2023, 9, 16);
      habitModel.setHabitCompletionDateTime = date1;
      habitModel.setHabitCompletionDateTime = date2;
      expect(habitModel.HabitCompletionDates().length, 2);
      expect(habitModel.HabitCompletionDates()[0], date1);
      expect(habitModel.HabitCompletionDates()[1], date2);
    });

    test('GetTodaysHabitCompletionCertificate returns false if not completed today', () {
      habitModel.setHabitCompletionDateTime = DateTime(2023, 1, 1);
      expect(habitModel.GetTodaysHabitCompletionCertificate(), false);
    });

    test('GetTodaysHabitCompletionCertificate returns true if completed today', () {
      final today = DateTime.now();
      habitModel.setHabitCompletionDateTime = today;
      expect(habitModel.GetTodaysHabitCompletionCertificate(), true);
    });

    test('GetLongestStreakLength returns correct streak', () {
      habitModel.myTotalHabitCompletionDatesForStreakCalendar.clear();
      habitModel.myTotalHabitCompletionDatesForStreakCalendar.addAll([
        DateTime(2023, 9, 15),
        DateTime(2023, 9, 16),
        DateTime(2023, 9, 17),
        DateTime(2023, 9, 19),
        DateTime(2023, 9, 20),
      ]);
      expect(habitModel.GetLongestStreakLength(habitModel.myTotalHabitCompletionDatesForStreakCalendar), 3);
    });

    test('_StreakStringBuilder returns correct string for empty streak', () {
      habitModel.myHabitCompletionDates.clear();
      expect(habitModel.myStreakStringBuilder(), "");
    });

    test('_StreakStringBuilder returns correct string for 1 day streak', () {
      habitModel.myHabitCompletionDates.clear();
      habitModel.myHabitCompletionDates.add(DateTime(2023, 9, 17));
      expect(habitModel.myStreakStringBuilder().contains("1 day streak"), true);
    });

    test('_StreakStringBuilder returns correct string for multiple day streak', () {
      habitModel.myHabitCompletionDates.clear();
      habitModel.myHabitCompletionDates.addAll([
        DateTime(2023, 9, 15),
        DateTime(2023, 9, 16),
      ]);
      expect(habitModel.myStreakStringBuilder().contains("2 days streak"), true);
    });

    test('HabitUid returns a non-empty string', () {
      expect(habitModel.HabitUid().isNotEmpty, true);
    });

    test('GenerateStreakCalendarViewWidget returns a Widget', () {
      final widget = habitModel.GenerateStreakCalendarViewWidget(
        MediaQueryData(),
        Colors.blue,
      );
      expect(widget, isA<Widget>());
    });
  });

    test("GetLongestStreakLength_HabitCompletionDates_LongestStreakIsCalculated", () {
      // Arrange
      var habitName = "Exercise";
      var habitModel = HabitsModel(habitName: habitName);
      List<DateTime> completionDates = [
        DateTime(2023, 10, 1),
        DateTime(2023, 10, 2),
        DateTime(2023, 10, 3),
        DateTime(2023, 10, 4),
        DateTime(2023, 10, 6),
        DateTime(2023, 10, 7),
        DateTime(2023, 10, 8),
        DateTime(2023, 10, 9),
        DateTime(2023, 10, 10),
        DateTime(2023, 10, 11),
      ];

      // Act
      var result = habitModel.GetLongestStreakLength(completionDates);

      // Assert
      expect(result, 6);
    
    });
    
    test("GetLongestStreakLength_HabitCompletionDatesAreInMonthEnd_LongestStreakIsCalculatedProperly", () {
      // Arrange
      var habitName = "Exercise";
      var habitModel = HabitsModel(habitName: habitName);
      List<DateTime> completionDates = [
        DateTime(2023, 10, 1),
        DateTime(2023, 10, 2),
        DateTime(2023, 10, 3),
        DateTime(2023, 10, 4),
        DateTime(2023, 10, 6),
        DateTime(2023, 10, 7),
        DateTime(2023, 10, 8),
        DateTime(2023, 10, 9),
        DateTime(2023, 10, 10),
        DateTime(2023, 10, 11),
        DateTime(2023, 10, 31),
        DateTime(2023, 11, 1),
        DateTime(2023, 11, 2),
        DateTime(2023, 11, 3),
        DateTime(2023, 11, 4),
        DateTime(2023, 11, 5),
        DateTime(2023, 11, 6),
        DateTime(2023, 11, 7),
        DateTime(2023, 11, 8),
        DateTime(2023, 11, 9),
      ];

      // Act
      var result = habitModel.GetLongestStreakLength(completionDates);

      // Assert
      expect(result, 10);
    
    });
}
