import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:may_be_too_basic/ViewModel/HabitViewModel.dart';

void main() {
  runApp(
    ChangeNotifierProvider
    (
      create: (context) => Habitviewmodel(),
      child: MyApp()    
    ),
    );
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      title: "May be too basic for you!",
      color: Color.fromRGBO(22, 158, 140, 0),
      home: MyHabitView()
    );
     
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
                  Provider.of<Habitviewmodel>(context, listen: false).AddHabit(habitName); 
                  Navigator.of(context).pop(); // close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
  final habits =  Provider.of<Habitviewmodel>(context).myHabits;
  print("Current habits length: ${habits.length}");
  print("Current habits: ${habits.toString()}");

    return Scaffold
    (
    
    appBar: AppBar
    (
      title: Center( child: new Text("...")),
    ),

    body: Row
    (
      children: 
      [
        Expanded
        (
        child: ListView.builder
        (
        itemCount:habits.length, 
        itemBuilder: (context, index) 
        {
          final currentHabit = habits[index];
          print("current habit to display: "+ currentHabit.habitName);
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(currentHabit.habitName, style: TextStyle(fontSize: 20)),
              trailing: 
              Expanded(
                child:
               Row(
                // Takes only the necessary space in horizontal direction
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => Provider.of<Habitviewmodel>(context, listen: false).RemoveHabit(currentHabit),
                  ),

                  IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () 
                {
                  // Implement edit functionality here
                  print("Edit button pressed for ${currentHabit.habitName}");
                  // You can show a dialog similar to the add habit dialog to edit the habit name
                }     
              ),
                ],  
                // onPressed: () => print("Delete ${currentHabit.habitName}"
              
              ),
               )
              
            ));
        }
          
        )),
      ]
    ),
    floatingActionButton: FloatingActionButton
    ( 
      onPressed: () 
      {
        myShowAddHabitForm(context);
      } ,
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


