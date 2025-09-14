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
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ); // Default color
        });
  }

  Widget CalculateHabitStreak(
      BuildContext context, double mediaQueryWidth, Habits currentHabit) {
    var streakLength = Provider.of<Habitviewmodel>(context, listen: true)
        .IsHabitStreakCompletionAchieved(currentHabit);

    if (streakLength.$1 == false || streakLength.$2 < 2) {
      return Text("");
    } else {
      return Text(
        "${streakLength.$2.toString()} days Streak..",
        style: TextStyle(
          fontSize: mediaQueryWidth * 0.035, // Responsive font size
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 179, 32, 22),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = Provider.of<Habitviewmodel>(context).myHabits;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final mediaQueryWidth = mediaQuery.size.width;
    final mediaQueryHeight = mediaQuery.size.height;

    print("Current habits length: ${habits.length}");
    print("Current habits: ${habits.toString()}");

    return Scaffold(
        appBar: AppBar(
          title: Center(child: new Text("...")),
          actions: [
            Positioned(
              left: mediaQueryWidth * 0.04,
              child: PopupMenuButton(
                icon: Icon(Icons.menu),
                onSelected: (value) {
                  // Handle menu item selection if needed
                  print("Selected hambergermenu item: $value");
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text('XX NOT IMPLEMENTED XX'),
                    ),
                  ];
                },
              ),
            )
          ],
        ),
        body: Row(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final currentHabit = habits[index];
                    print("current habit to display: " + currentHabit.habitName);

                    //GestureDetector to detect taps on the card    
                    return GestureDetector(
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
                                          style: TextStyle(fontSize: 15))),
                                  actions: [
                                    TextButton(
                                      child: Text("Close"),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),

                                    TextButton(onPressed: ()
                                    {
                                      showDialog(context: context, builder: (BuildContext buildContext){
                                        return AlertDialog(
                                          title: Text("Streak Calendar"),
                                          content: Expanded(
                                            child: Container(
                                              color: const Color.fromARGB(179, 174, 227, 231),
                                              child: SizedBox(
                                                  width: double.maxFinite,
                                                  child: Provider.of<Habitviewmodel>(context, listen: false).GenerateStreakCalendarView(currentHabit).$2),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text("Close"),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                          ]
                                        );
                                      });
                                    }, child: Text("Streak Calendar"))
                                  ]);
                            });
                      },
                      child: Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          color:
                              Provider.of<Habitviewmodel>(context, listen: true)
                                  .GetHabitColor(currentHabit),
                          child: Container(
                            height:
                                mediaQueryHeight * 0.15, // Responsive height
                            child: Stack(
                              children: [
                                // Habit Name (top-left)
                                Positioned(
                                  left: mediaQueryWidth * 0.045,
                                  top: mediaQueryHeight * 0.02,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentHabit.habitName,
                                        style: TextStyle(
                                          fontSize: mediaQueryWidth * 0.05,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 2.0,
                                              color: const Color.fromARGB(
                                                  255, 131, 180, 240),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: mediaQueryHeight *
                                              0.01), // Space between name and streak
                                      CalculateHabitStreak(context,
                                          mediaQueryWidth, currentHabit),
                                    ],
                                  ),
                                ),

                                // Popup Menu (top-right)
                                Positioned(
                                  right: mediaQueryWidth * 0.02,
                                  top: mediaQueryHeight * 0.01,
                                  child: PopupMenuButton(
                                    onSelected: (value) {
                                      // Handle menu item selection if needed
                                      print("Selected menu item: $value");

                                      switch (value) {
                                        case 'delete':
                                          Provider.of<Habitviewmodel>(context,
                                                  listen: false)
                                              .RemoveHabit(currentHabit);
                                          break;
                                        case 'edit':
                                          myUpdateHabitAttributes(
                                              context,
                                              "Edit Description for ${currentHabit.habitName}",
                                              currentHabit,
                                              HabitAttribute.HabitDescription);
                                          break;
                                        case 'color':
                                          OnColorChangeIconPressed(
                                              context, currentHabit);
                                          break;
                                        case 'mark_done':
                                          Provider.of<Habitviewmodel>(context,
                                                  listen: false)
                                              .SetHabitCompletionDateTime(
                                                  currentHabit, DateTime.now());
                                          break;
                                        default:
                                          print("Unknown menu item selected");
                                      }
                                    },
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'color',
                                          child: Text('Change Color'),
                                        ),
                                        PopupMenuItem(
                                          value: 'mark_done',
                                          child: Text("Mark as Done"),
                                        ),
                                      ];
                                    },
                                  ),
                                ),

                                // Habit Description (bottom-left)
                                Positioned(
                                  left: mediaQueryWidth * 0.04,
                                  bottom: mediaQueryHeight * 0.02,
                                  child: SizedBox(
                                    width: mediaQueryWidth * 0.5,
                                    child: Text(
                                      Provider.of<Habitviewmodel>(context,
                                              listen: true)
                                          .GeHabitDescription(currentHabit)
                                          .toString(),
                                      //To watch instead of depending on provider notification as it wont work in release mode
                                      // context.watch<Habitviewmodel>().myHabits[index].HabitDescription(),
                                      style: TextStyle(
                                          fontSize: mediaQueryWidth * 0.035),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // Status (bottom-right)
                                Positioned(
                                  right: mediaQueryWidth * 0.02,
                                  bottom: mediaQueryHeight * 0.02,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: mediaQueryWidth * 0.03,
                                      vertical: mediaQueryHeight * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context
                                              .watch<Habitviewmodel>()
                                              .GetTodaysHabitCompletionCertificate(
                                                  currentHabit)
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      context
                                              .watch<Habitviewmodel>()
                                              .GetTodaysHabitCompletionCertificate(
                                                  currentHabit)
                                          ? "Today's Goal achieved"
                                          : "Yet to achieve today's goal",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: mediaQueryWidth * 0.035,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )

                          // padding: EdgeInsets.symmetric(
                          //   horizontal: mediaQueryWidth * 0.05,
                          //   vertical: mediaQueryHeight * 0.01,
                          // ),
                          // child: ListTile(
                          //     minLeadingWidth: mediaQueryWidth * 0.05,
                          //     minTileHeight: mediaQueryHeight * 0.1,
                          //     mouseCursor: SystemMouseCursors.click,
                          //     hoverColor: Colors.blueGrey,
                          //     title: Text(currentHabit.habitName,
                          //         style: TextStyle(fontSize: 22, color: const Color.fromARGB(255, 22, 61, 92))),
                          //     contentPadding: EdgeInsets.all(10.0),
                          //     selected: Provider.of<Habitviewmodel>(context, listen: false)
                          //         .GetTodaysHabitCompletionCertificate(
                          //             currentHabit),
                          //     selectedTileColor: Colors.green.withOpacity(0.5),
                          //     subtitle: currentHabit.HabitDescription().isNotEmpty
                          //         ? Text(currentHabit.HabitDescription(),
                          //             maxLines: 2, style: TextStyle(fontSize: 15))
                          //         : Text(""),
                          //     onTap: () {
                          //       print("Tapped on ${currentHabit.habitName}");
                          //       showDialog(
                          //           context: context,
                          //           builder: (BuildContext context) {
                          //             return AlertDialog(
                          //                 title: Text(currentHabit.habitName),
                          //                 content: SizedBox(
                          //                     width: double.maxFinite,
                          //                     child: Text(
                          //                         currentHabit.HabitDescription(),
                          //                         maxLines: 10,
                          //                         style:
                          //                             TextStyle(fontSize: 15))),
                          //                 actions: [
                          //                   TextButton(
                          //                     child: Text("Close"),
                          //                     onPressed: () =>
                          //                         Navigator.of(context).pop(),
                          //                   ),
                          //                 ]);
                          //           });
                          //     },
                          //     trailing: Row(
                          //       // Takes only the necessary space in horizontal direction
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [

                          //         Container(
                          //                 padding: const EdgeInsets.symmetric(
                          //                     horizontal: 12, vertical: 6),
                          //                 decoration: BoxDecoration(
                          //                   color: Provider.of<Habitviewmodel>(
                          //                               context, listen: false)
                          //                           .GetTodaysHabitCompletionCertificate(
                          //                               currentHabit)
                          //                       ? Colors.green
                          //                       : Colors.red,
                          //                   borderRadius: BorderRadius.circular(12),
                          //                 ),
                          //                 child: Text(
                          //                   Provider.of<Habitviewmodel>(context, listen: false)
                          //                           .GetTodaysHabitCompletionCertificate(
                          //                               currentHabit)
                          //                       ? "Today's Goal achieved"
                          //                       : "Yet to achieve today's goal",
                          //                   style: const TextStyle(
                          //                       color: Colors.white,
                          //                       fontWeight: FontWeight.bold),
                          //                 )),

                          //         PopupMenuButton(
                          //           onSelected: (value) {
                          //             // Handle menu item selection if needed
                          //             print("Selected menu item: $value");

                          //             switch (value) {
                          //               case 'delete':
                          //                 Provider.of<Habitviewmodel>(context,
                          //                         listen: false)
                          //                     .RemoveHabit(currentHabit);
                          //                 break;
                          //               case 'edit':
                          //                 myUpdateHabitAttributes(
                          //                     context,
                          //                     "Edit Description for ${currentHabit.habitName}",
                          //                     currentHabit,
                          //                     HabitAttribute.HabitDescription);
                          //                 break;
                          //               case 'color':
                          //                 OnColorChangeIconPressed(context, currentHabit);
                          //                 break;
                          //               case 'mark_done':
                          //                 Provider.of<Habitviewmodel>(context, listen: false).SetHabitCompletionDateTime(currentHabit, DateTime.now());
                          //                 break;
                          //               default:
                          //                 print("Unknown menu item selected");
                          //             }
                          //           },
                          //           itemBuilder: (context) {
                          //             return [
                          //               PopupMenuItem(
                          //                 value: 'delete',
                          //                 child: Text('Delete'),
                          //               ),
                          //               PopupMenuItem(
                          //                 value: 'edit',
                          //                 child: Text('Edit'),
                          //               ),
                          //               PopupMenuItem(
                          //                 value: 'color',
                          //                 child: Text('Change Color'),
                          //               ),
                          //               PopupMenuItem(
                          //                 value: 'mark_done',
                          //                 child: Text("Mark as Done"),
                          //               ),
                          //             ];
                          //           },
                          //           ),
                          //           //children: [
                          //           //   PopupMenuItem(
                          //           //     child: IconButton(
                          //           //       icon: Icon(Icons.delete, color: Colors.red,),
                          //           //       tooltip: "Delete ${currentHabit.habitName}",

                          //           //       onPressed: () =>
                          //           //           Provider.of<Habitviewmodel>(context,
                          //           //                   listen: false)
                          //           //               .RemoveHabit(currentHabit),
                          //           //     ),
                          //           //   ),
                          //           //   IconButton(
                          //           //       icon: const Icon(
                          //           //         Icons.edit,
                          //           //         color: Colors.green,
                          //           //       ),
                          //           //       tooltip: "Edit ${currentHabit.habitName}",
                          //           //       onPressed: () {
                          //           //         // Implement edit functionality here
                          //           //         print(
                          //           //             "Edit button pressed for ${currentHabit.habitName}");
                          //           //         myUpdateHabitAttributes(
                          //           //             context,
                          //           //             "Edit Description for $currentHabit",
                          //           //             currentHabit,
                          //           //             HabitAttribute.HabitDescription);
                          //           //         // You can show a dialog similar to the add habit dialog to edit the habit name
                          //           //       }),

                          //           //       IconButton(onPressed: ()
                          //           //       {
                          //           //         OnColorChangeIconPressed(context, currentHabit);

                          //           //       } , icon: const Icon(Icons.color_lens),
                          //           //       tooltip: "Choose color for the habit!",),

                          //           //       IconButton(onPressed: ()
                          //           //       {
                          //           //         Provider.of<Habitviewmodel>(context, listen: false).SetHabitCompletionDateTime(currentHabit, DateTime.now());
                          //           //       }, icon: const Icon(Icons.check_circle, color: Colors.white), tooltip: "Mark as done!",),

                          //                  //Display thing

                          //           // ],

                          //       ],
                          //       // onPressed: () => print("Delete ${currentHabit.habitName}"
                          //     )),
                          ),
                    );
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
}
