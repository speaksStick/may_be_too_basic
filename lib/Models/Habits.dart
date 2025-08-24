class Habits 
{

  String HabitName () =>  habitName;
  String HabitDescription () =>  myHabitDescription;

  String habitName;
  String myHabitDescription = "";

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
}