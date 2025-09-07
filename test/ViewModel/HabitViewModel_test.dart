import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:may_be_too_basic/Models/Habits.dart';
import 'package:may_be_too_basic/ViewModel/HabitViewModel.dart';
  
class HabitViewModel_test extends Habitviewmodel {
  
  bool notifyListenersCalled = false;
  int notifyListenersCalledCount = 0;

  @override
  void notifyListeners() {
    notifyListenersCalledCount++;
    notifyListenersCalled = true;
    super.notifyListeners();
  }
}
  void main() {
    test("AddHabit_ValidHabitName_HabitIsAddedTomyHabitsList", () {
      // Arrange
      var habitViewModel = HabitViewModel_test();
      var habitName = "Exercise";

      // Act
      var result = habitViewModel.AddHabit(habitName);

      // Assert
      expect(result, true);
      expect(habitViewModel.myHabits.length, 1);
      expect(habitViewModel.myHabits[0].habitName, habitName);
      expect(habitViewModel.notifyListenersCalled, true);
      expect(habitViewModel.notifyListenersCalledCount, 1);
    });

    test("AddHabit_HabitNameIsEmpty_HabitIsNotAddedTomyHabitsList", () {
      // Arrange
      var habitViewModel = HabitViewModel_test();
      var habitName = "";

      // Act
      var result = habitViewModel.AddHabit(habitName);

      // Assert
      expect(result, false);
      expect(habitViewModel.myHabits.length, 0);
      expect(habitViewModel.notifyListenersCalled, false);
      expect(habitViewModel.notifyListenersCalledCount, 0);
    });

    test("AddHabit_DuplicateHabitName_HabitIsNotAddedTomyHabitsList", () {
      // Arrange
      var habitViewModel = HabitViewModel_test();
      var habitNameOne = "Exercise";

      // Act
      var resultOne = habitViewModel.AddHabit(habitNameOne);
      var resultTwo = habitViewModel.AddHabit(habitNameOne);

      // Assert
      expect(resultOne, true);
      expect(habitViewModel.myHabits.length, 1);
      expect(habitViewModel.myHabits[0].habitName, habitNameOne);
      expect(habitViewModel.notifyListenersCalledCount, 1);

      expect(resultTwo, false);
      expect(habitViewModel.myHabits.length, 1);
      expect(habitViewModel.myHabits[0].habitName, habitNameOne);
      expect(habitViewModel.notifyListenersCalledCount, 1);
    });

    test('removes habit when valid', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: 'Read');
      vm.myHabits.add(habit);

      final result = vm.RemoveHabit(habit);

      expect(result, true);
      expect(vm.myHabits.length, 0);
      expect(vm.notifyListenersCalled, true);
      expect(vm.notifyListenersCalledCount, 1);
    });


    test('returns false when habit name is empty', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: '');
      final result = vm.RemoveHabit(habit);

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });
  

    test('edits description when valid', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: 'Run');
      vm.myHabits.add(habit);

      final result = vm.EditHabitDescription(habit, 'Morning run');

      expect(result, true);
      expect(vm.notifyListenersCalled, true);
      expect(vm.notifyListenersCalledCount, 1);
    });

    test('returns false when description is empty', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: 'Run');
      vm.myHabits.add(habit);

      final result = vm.EditHabitDescription(habit, '');

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });

    test('returns false when habit not in list', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: 'Run');

      final result = vm.EditHabitDescription(habit, 'desc');

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });
  

    test('edits color when valid', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: 'Swim');
      vm.myHabits.add(habit);

      final result = vm.EditHabitColor(habit, Colors.blue);

      expect(result, true);
      expect(vm.notifyListenersCalled, true);
      expect(vm.notifyListenersCalledCount, 1);
    });

    test('returns false when habit not in list', () {
      final vm = HabitViewModel_test();
      final habit = Habits(habitName: 'Swim');

      final result = vm.EditHabitColor(habit, Colors.green);

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });

    // ToDo: Need to refactor TimeTracker and write robust tests
     group('Habitviewmodel', () {
    late Habitviewmodel viewModel;
    late Habits habit;

    setUp(() {
      viewModel = Habitviewmodel();
      habit = Habits(habitName: 'Test Habit');
    });

    test('IsHabitStreakCompletionAchieved returns false and 0 for empty streak', () {
      final result = viewModel.IsHabitStreakCompletionAchieved(habit);
      expect(result.$1, false);
      expect(result.$2, 0);
    });

    test('IsHabitStreakCompletionAchieved returns true and streak length for streak >= 2', () {
      habit.myHabitCompletionDates.addAll([
        DateTime.now().subtract(Duration(days: 2)),
        DateTime.now().subtract(Duration(days: 1)),
      ]);
      final result = viewModel.IsHabitStreakCompletionAchieved(habit);
      expect(result.$1, true);
      expect(result.$2, 2);
    });

    test('IsHabitStreakCompletionAchieved returns false and streak length for streak < 2', () {
      habit.myHabitCompletionDates.add(DateTime.now());
      final result = viewModel.IsHabitStreakCompletionAchieved(habit);
      expect(result.$1, false);
      expect(result.$2, 1);
    });

    test('LiveTimeTracker triggers notifyListeners after midnight', () async {
      // This test only checks that the method runs and does not throw.
      // You may want to mock DateTime and ChangeNotifier for more advanced testing.
      expect(() => viewModel.LiveTimeTracker(), returnsNormally);
    });
  });
  }
