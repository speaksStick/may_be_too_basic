import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';
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

  //Branch coverage wold be less, need to cover the negative usecases.
  void main() {
  group('Habitviewmodel', () {
    late HabitViewModel_test myHabitViewModel;
    late HabitsModel myHabit;

    //Setup before each test
    setUp(() {
      myHabitViewModel = new HabitViewModel_test();
      myHabit = HabitsModel(habitName: 'Test Habit');
      myHabitViewModel.myHabits.clear();
      myHabitViewModel.myHabits.add(myHabit);
      
    });

    test('AddHabit adds a habit', () {
      var habitName = "Exercise";

      bool result = myHabitViewModel.AddHabit(habitName);
      
      expect(result, true);
      expect(myHabitViewModel.myHabits.length, 2);
      expect(myHabitViewModel.myHabits[1].habitName, habitName);
      expect(myHabitViewModel.notifyListenersCalled, true);
      expect(myHabitViewModel.notifyListenersCalledCount, 1);
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

    test('RemoveHabit removes a habit', () {
      bool result = myHabitViewModel.RemoveHabit(myHabit);
      expect(result, true);
      expect(myHabitViewModel.myHabits.contains(myHabit), false);
    });

     test('RemoveHabit returns false when habit name is empty', () {
      final vm = HabitViewModel_test();
      final habit = HabitsModel(habitName: '');
      final result = vm.RemoveHabit(habit);

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });

    test('EditHabitDescription updates description', () {
      bool result = myHabitViewModel.EditHabitDescription(myHabit, 'Updated Description');
      expect(result, true);
      expect(myHabitViewModel.GeHabitDescription(myHabit), 'Updated Description');
    });

    test('EditHabitDescription returns false when description is empty', () {
      final vm = HabitViewModel_test();
      final habit = HabitsModel(habitName: 'Run');
      vm.myHabits.add(habit);

      final result = vm.EditHabitDescription(habit, '');

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });

    test('returns false when habit not in list', () {
      final vm = HabitViewModel_test();
      final habit = HabitsModel(habitName: 'Run');

      final result = vm.EditHabitDescription(habit, 'desc');

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });
  

    test('EditHabitColor updates color', () {
      bool result = myHabitViewModel.EditHabitColor(myHabit, Colors.green);
      expect(result, true);
      expect(myHabitViewModel.GetHabitColor(myHabit), Colors.green);
    });

    test('EditHabitColor returns false when habit not in list', () {
      final vm = HabitViewModel_test();
      final habit = HabitsModel(habitName: 'Swim');

      final result = vm.EditHabitColor(habit, Colors.green);

      expect(result, false);
      expect(vm.notifyListenersCalled, false);
    });

    test('GetTodaysHabitCompletionCertificate returns false if not completed today', () {
      myHabit.setHabitCompletionDateTime = DateTime(2020, 1, 1);
      bool result = myHabitViewModel.GetTodaysHabitCompletionCertificate(myHabit);
      expect(result, false);
    });

    test('GetTodaysHabitCompletionCertificate returns true if completed today', () {
      myHabit.setHabitCompletionDateTime = DateTime.now();
      bool result = myHabitViewModel.GetTodaysHabitCompletionCertificate(myHabit);
      expect(result, true);
    });

    test('SetHabitCompletionDateTime sets completion date', () {
      DateTime date = DateTime.now();
      bool result = myHabitViewModel.SetHabitCompletionDateTime(myHabit, date);
      expect(result, true);
      expect(myHabit.HabitCompletionDateTime(), date);
    });

    test('GeHabitDescription returns empty string for null habit', () {
      String desc = myHabitViewModel.GeHabitDescription(HabitsModel(habitName: ''));
      expect(desc, '');
    });

    test('GetHabitColor returns default color for null habit', () {
      Color color = myHabitViewModel.GetHabitColor(HabitsModel(habitName: ''));
      expect(color, Colors.grey);
    });

    test('SupportedLocales contains en, kn, hi', () {
      expect(myHabitViewModel.supportedLocales.any((l) => l.languageCode == 'en'), true);
      expect(myHabitViewModel.supportedLocales.any((l) => l.languageCode == 'kn'), true);
      expect(myHabitViewModel.supportedLocales.any((l) => l.languageCode == 'hi'), true);
    });

    test('GetPreferredLocale returns preferred locale', () {
      expect(myHabitViewModel.GetPreferredLocale, myHabitViewModel.preferredLocale);
    });

    test('LiveTimeTracker runs without error', () async {
      expect(() => myHabitViewModel.LiveTimeTracker(DateTime.now()), returnsNormally);
    });

    // Add more tests for edge cases
    test('RemoveHabit returns false if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      bool result = myHabitViewModel.RemoveHabit(fakeHabit);
      expect(result, false);
    });

    test('EditHabitDescription returns false if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      bool result = myHabitViewModel.EditHabitDescription(fakeHabit, 'desc');
      expect(result, false);
    });

    test('EditHabitColor returns false if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      bool result = myHabitViewModel.EditHabitColor(fakeHabit, Colors.red);
      expect(result, false);
    });

    test('SetHabitCompletionDateTime returns false if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      bool result = myHabitViewModel.SetHabitCompletionDateTime(fakeHabit, DateTime.now());
      expect(result, false);
    });

    test('GetTodaysHabitCompletionCertificate returns false if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      bool result = myHabitViewModel.GetTodaysHabitCompletionCertificate(fakeHabit);
      expect(result, false);
    });

    test('GeHabitDescription returns empty string if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      String desc = myHabitViewModel.GeHabitDescription(fakeHabit);
      expect(desc, '');
    });

    test('GetHabitColor returns default color if habit not found', () {
      HabitsModel fakeHabit = HabitsModel(habitName: 'Fake');
      Color color = myHabitViewModel.GetHabitColor(fakeHabit);
      expect(color, Colors.grey);
    });
  });
}
  
