import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:may_be_too_basic/Enums/HabitAttribute.dart';
import 'package:may_be_too_basic/Models/Habits.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:may_be_too_basic/ViewModel/HabitViewModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => Habitviewmodel(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "May be too basic for you!",
        color: Color.fromRGBO(22, 158, 140, 0),
        home: MyHabitView());
  }
}

class MyHabitView extends StatelessWidget {
  MyHabitView({super.key});

  void myShowAddHabitForm(BuildContext context) {
    final TextEditingController habitController = TextEditingController();
    var habitName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a Habit"),
          content: TextField(
            controller: habitController,
            decoration: InputDecoration(
              labelText: "Habit Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                if (habitController.text.isNotEmpty) {
                  habitName = habitController.text;
                  Provider.of<Habitviewmodel>(context, listen: false)
                      .AddHabit(habitName);
                  Navigator.of(context).pop(); // close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

//Requires the info of habit to edit, the attribute to edit, and the new value for that attribute
  void myUpdateHabitAttributes(BuildContext context, String dialogTitle,
      Habits habit, HabitAttribute habitAttributeToEdit) {
    final TextEditingController habitController = TextEditingController();
    var habitAttributeValue;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: habitController,
              decoration: InputDecoration(
                labelText: "Habit description",
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 4,
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                if (habitController.text.isNotEmpty) {
                  habitAttributeValue = habitController.text;
                  Provider.of<Habitviewmodel>(context, listen: false)
                      .EditHabitDescription(habit, habitAttributeValue);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

void OnColorChangeIconPressed(BuildContext context, Habits habit) {
    Color pickerColor = habit.HabitColor(); // Default color

    void onColorChanged(Color color) {
      pickerColor = color;
      print("Color changed to $pickerColor");
      Provider.of<Habitviewmodel>(context, listen: false)
          .EditHabitColor(habit, pickerColor);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: ColorPicker(
                    pickerColor: pickerColor, onColorChanged: onColorChanged),
                    
              ),
              actions: 
              [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],); // Default color
        });
  }


  @override
  Widget build(BuildContext context) {
    final habits = Provider.of<Habitviewmodel>(context).myHabits;
    print("Current habits length: ${habits.length}");
    print("Current habits: ${habits.toString()}");
    
    return Scaffold(
        appBar: AppBar(
          title: Center(child: new Text("...")),
        ),
        body: Row(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final currentHabit = habits[index];
                    print(
                        "current habit to display: " + currentHabit.habitName);
                    return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        color: currentHabit.HabitColor(),    
                        child: ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            hoverColor: Colors.blueGrey,
                            title: Text(currentHabit.habitName,
                                style: TextStyle(fontSize: 22, color: const Color.fromARGB(255, 22, 61, 92))),
                            contentPadding: EdgeInsets.all(10.0),
                            subtitle: currentHabit.HabitDescription().isNotEmpty
                                ? Text(currentHabit.HabitDescription(),
                                    maxLines: 2, style: TextStyle(fontSize: 15))
                                : Text(""),
                            onTap: () {
                              print("Tapped on ${currentHabit.habitName}");
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text(currentHabit.habitName),
                                        content: SizedBox(
                                            width: double.maxFinite,
                                            child: Text(
                                                currentHabit.HabitDescription(),
                                                maxLines: 10,
                                                style:
                                                    TextStyle(fontSize: 15))),
                                        actions: [
                                          TextButton(
                                            child: Text("Close"),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ]);
                                  });
                            },
                            trailing: Expanded(
                              child: Row(
                                // Takes only the necessary space in horizontal direction
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red,),
                                    tooltip: "Delete ${currentHabit.habitName}",
                  
                                    onPressed: () =>
                                        Provider.of<Habitviewmodel>(context,
                                                listen: false)
                                            .RemoveHabit(currentHabit),
                                  ),
                                  IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.green,
                                      ),
                                      tooltip: "Edit ${currentHabit.habitName}",
                                      onPressed: () {
                                        // Implement edit functionality here
                                        print(
                                            "Edit button pressed for ${currentHabit.habitName}");
                                        myUpdateHabitAttributes(
                                            context,
                                            "Edit Description for $currentHabit",
                                            currentHabit,
                                            HabitAttribute.HabitDescription);
                                        // You can show a dialog similar to the add habit dialog to edit the habit name
                                      }),

                                      IconButton(onPressed: () 
                                      {
                                        OnColorChangeIconPressed(context, currentHabit);

                                      } , icon: const Icon(Icons.color_lens)),  

                                ],
                                // onPressed: () => print("Delete ${currentHabit.habitName}"
                              ),
                            )));
                  })),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            myShowAddHabitForm(context);
          },
          tooltip: "Add a Habit!",
          child: Icon(Icons.add),
        ));
  }
}

// class MyTextWidget extends StatelessWidget {
//   const MyTextWidget({super.key, required this.habitName});
//   final String habitName;

//   void deleteHabit() {
//     // Logic to delete the habit
    
//   }

//   @override
//   Widget build(BuildContext context) {

//         final theme = Theme.of(context);       // ← Add this.
//         final style = theme.textTheme.displayMedium!.copyWith(
//       color: theme.colorScheme.onPrimary,
//     );    
//     print(habitName);
//     return 
//     Expanded(child: 
//     Card(
//       elevation: 20.0,
//       color: theme.colorScheme.primary, // ← Use the theme color.  
//       child: Padding(padding: const EdgeInsets.all(20.0),
//       child: Text(habitName, style: style, textAlign: TextAlign.center, semanticsLabel: "${habitName} ",),
      
//       ),
//     )
//     );
    
//   }
// }


