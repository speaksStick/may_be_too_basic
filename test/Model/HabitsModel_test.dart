import 'package:flutter_test/flutter_test.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';

void main() {
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
