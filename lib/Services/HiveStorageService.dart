import 'dart:ui';

import 'package:hive_flutter/adapters.dart';
import 'package:may_be_too_basic/Common/GlobalAppConstants.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';
import 'package:may_be_too_basic/Services/LoggerService.dart';

class HiveStorageservice 
{
  LoggerService logger = GlobalObjectProvider.LoggerServiceSingleTonObject;

  //Singleton implementation
  static HiveStorageservice _myHiveStorageService = HiveStorageservice._internal();
  HiveStorageservice._internal();
  factory HiveStorageservice.SingleTonServiceObject() => _myHiveStorageService;

  //Public API
  List<HabitsModel> GetAllHabitsFromHiveBox()
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    return habitBox.values.toList().cast<HabitsModel>();
  }
  
  Future<void> AddHabitToHiveBox(HabitsModel habit) async
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    await habitBox.put(habit.habitUId, habit);
  }

  Future<void> DeleteHabitFromHiveBox(HabitsModel habit) async
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    var habitModelInHiveBox = await habitBox.values.firstWhere((element) => element.HabitUid() == habit.HabitUid());
    //The above habit is where we find the habit from the hive storage for habit models.
    await habitBox.deleteAt(habitBox.values.toList().indexOf(habitModelInHiveBox));
  }

  Future<void> UpdateHabitDescriptionInHiveStorage(HabitsModel habit, String habitDescription) async
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    var habitModelFromHiveStorage = await habitBox.values.firstWhere((habitModel) => habitModel.habitUId == habit.habitUId);
    if(habitModelFromHiveStorage == null)
    {
      logger.LogError("HiveStorageService: UpdateHabitDescriptionInHiveStorage: Habit not found in Hive Storage, cannot update the description");
      return;
    }
    habitModelFromHiveStorage.setHabitDescription = habitDescription;

    await habitBox.delete(  habitModelFromHiveStorage.habitUId);
    await habitBox.put(habit.habitUId, habitModelFromHiveStorage);
  }

  Future<void> UpdateHabitColor(HabitsModel habit, int colorForHabit) async
  {
    try 
    {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    var habitModelFromHiveStorage = await habitBox.values.firstWhere((habitModel) => habitModel.habitUId == habit.habitUId);
    if(habitModelFromHiveStorage == null)
    {
      logger.LogError("HiveStorageService: UpdateHabitDescriptionInHiveStorage: Habit not found in Hive Storage, cannot update the description");
      return;
    }
    habitModelFromHiveStorage.setHabitColor = Color(colorForHabit);

    await habitBox.delete(habitModelFromHiveStorage.habitUId);
    await habitBox.put(habit.habitUId, habitModelFromHiveStorage);  
    } catch (e) {
      logger.LogError("HiveStorageService: UpdateHabitColor: Exception occurred while updating habit color: $e");
      return;
    }
    
  }

  Future<void> UpdateHabitCompletionDateTime(HabitsModel habit, DateTime habitCompletionDateTime) async
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    var habitModelFromHiveStorage = await habitBox.values.firstWhere((habitModel) => habitModel.habitUId == habit.habitUId);
    if(habitModelFromHiveStorage == null)
    {
      logger.LogError("HiveStorageService: UpdateHabitDescriptionInHiveStorage: Habit not found in Hive Storage, cannot update the description");
      return;
    }
    habitModelFromHiveStorage.setHabitCompletionDateTime = habitCompletionDateTime;

    await habitBox.delete(habitModelFromHiveStorage.habitUId);
    await habitBox.put(habit.habitUId, habitModelFromHiveStorage);
  }

  Future<void> UpdateHabitNotificationHourMinuteList((int hourHand, int minuteHand, String habitUId,  bool isNotificationSentForTheDay) customNotificationHourMinuteOfHabitList) async
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);
    var habitModelFromHiveStorage = await habitBox.values.firstWhere((habitModel) => habitModel.habitUId == customNotificationHourMinuteOfHabitList.$3);
    if(habitModelFromHiveStorage == null)
    {
      logger.LogError("HiveStorageService: UpdateHabitDescriptionInHiveStorage: Habit not found in Hive Storage, cannot update the hour minute list for custom notifications");
      return;
    }
    habitModelFromHiveStorage.setCustomNotificationHourMinuteOfHabitList = customNotificationHourMinuteOfHabitList;

    await habitBox.delete(habitModelFromHiveStorage.habitUId);
    await habitBox.put(customNotificationHourMinuteOfHabitList.$3, habitModelFromHiveStorage);
  }

  Future<bool> RemoveAHabitNotificationFromFromCustomNotificationList((int hourHand, int minuteHand, String habitUId, bool isNotificationSentForTheDay) customNotificationHourMinuteOfHabitList) async
  {
    var habitBox = Hive.box<HabitsModel>(Globalappconstants.userHabitBox);

    var habitFromHiveStorage = await habitBox.values.firstWhere((habitModel) => habitModel.habitUId == customNotificationHourMinuteOfHabitList.$3);

    if(habitFromHiveStorage == null)
    {
      logger.LogError("No habit in Hivestorage associated to the habitUid: ${customNotificationHourMinuteOfHabitList.$3}");
      return false;
    }

    habitFromHiveStorage.DeleteACustomNotificationTimeFromHabitList((customNotificationHourMinuteOfHabitList.$1, customNotificationHourMinuteOfHabitList.$2, customNotificationHourMinuteOfHabitList.$3, customNotificationHourMinuteOfHabitList.$4));

    await habitBox.delete(customNotificationHourMinuteOfHabitList.$3);
    await habitBox.put(customNotificationHourMinuteOfHabitList.$3, habitFromHiveStorage);
    return true;
  }
}