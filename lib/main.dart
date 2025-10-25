import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
import 'package:may_be_too_basic/Enums/HabitAttribute.dart';
import 'package:may_be_too_basic/Models/HabitsModel.dart';
import 'package:may_be_too_basic/Routes/LoginUserView.dart';
import 'package:may_be_too_basic/Routes/RegisterUserView.dart';
import 'package:may_be_too_basic/Services/FireBaseService.dart';
import 'package:may_be_too_basic/ViewModel/LoginUserViewModel.dart';
import 'package:may_be_too_basic/ViewModel/RegisterUserViewModel.dart';
import 'package:may_be_too_basic/ViewModel/RoutesManagementViewModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:may_be_too_basic/ViewModel/HabitViewModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:may_be_too_basic/l10n/gen_l10n/app_localizations.dart';

void main() async{

  //The below line of code ensures the async works are completed before calling the runApp.
  WidgetsFlutterBinding.ensureInitialized();

  //The below class provides the global object access
  //The below initialization performs all the important async initializations,
  //before the app starts.
  await GlobalObjectProvider.InitializeAllServicesAndAssociates();

  runApp(
    MultiProvider(
      providers: 
      [
        //In the below code, there are currently 4 ChangeNotifierProviders classes are created and 
        //provided to the MyApp widget tree. So, any widget inside MyApp can access these providers
        ChangeNotifierProvider(
        create: (context) => Habitviewmodel.Product()),

        ChangeNotifierProvider(create: (context) => RegisterUserViewModel(GlobalObjectProvider.LoggerServiceSingleTonObject,
        GlobalObjectProvider.FirebaseServiceSingleTonObject,)),
      
        ChangeNotifierProvider(create: (context) => LoginUserViewModel(GlobalObjectProvider.LoggerServiceSingleTonObject,
        GlobalObjectProvider.FirebaseServiceSingleTonObject,)),
      
        ChangeNotifierProvider(create: (context) => RoutesManagementViewmodel(FireBaseService.singleTonServiceObject(),
        GlobalObjectProvider.LoggerServiceSingleTonObject,)),
      ]
      , child: MyApp()
      )
    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.of(context)?.mayBeTooBasic,
      color: Color.fromRGBO(22, 158, 140, 0),
      supportedLocales: [
        Locale('en'),
        Locale('kn'),
        Locale('hi'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      //locale decides which language arb files to use
      //So, changing locale will change the language of the app
      locale: Provider.of<Habitviewmodel>(context, listen: true)
          .GetPreferredLocale,
      routes: {
        '/': (context) => MyHabitView(),
        '/registerUserView': (context) => RegisterUserView(),
        '/loginUserView': (context) => LoginUserView(),
      },
      initialRoute: GetCurrentRouteBasedOnCurrentUserAuthStatus(context),
    );
  }

  // The below method provides the route info based on the current user authentication status -
  // Logged-in/ Logged-out/ Token in local storage to determine login status after app restart
  // CurrentUser -> null => Logged-out => Navigate to LoginUserView
  // CurrentUser -> non-null => Logged-in => Navigate to MyHabitView/ HomeView.
  String GetCurrentRouteBasedOnCurrentUserAuthStatus(BuildContext context) {
    var userAuthChange = context.watch<RoutesManagementViewmodel>().GetUserAuthStatus();
    String currentRoute;
    if(userAuthChange == null)
    {
      //GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("MyApp detected user is signed out, navigating to LoginUserView");
      //Future.microtask(() => Navigator.pushNamedAndRemoveUntil(context, '/loginUserView', (route) => false));
      currentRoute = '/loginUserView';
    }
    else
    {
      //GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("MyApp detected user is signed in, navigating to MyHabitView");
      //Future.microtask(() =>  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false));
      currentRoute = '/';
    }
    return currentRoute;
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
          title: Text(AppLocalizations.of(context)!.addHabit),
          content: TextField(
            controller: habitController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.habitName,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.save),
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
      HabitsModel habit, HabitAttribute habitAttributeToEdit) {
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
                labelText: AppLocalizations.of(context)!.habitDescription,
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 4,
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.save),
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

  void OnColorChangeIconPressed(BuildContext context, HabitsModel habit) {
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
            title: Text(AppLocalizations.of(context)!.pickColor),
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
      BuildContext context, double mediaQueryWidth, HabitsModel currentHabit) {
    var streakLength = Provider.of<Habitviewmodel>(context, listen: false)
        .GetHabitStreakLengthAndStreakCompletionCertificate(currentHabit);

    if (streakLength.$1 == false || streakLength.$2 < 2) {
      return Text("");
    } else {
      return Text(
        "${streakLength.$2.toString()} ${AppLocalizations.of(context)!.streakDays}",
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
    GlobalObjectProvider.LoggerServiceSingleTonObject
        .LogMessage("Building MyHabitView");
    final habits = context.watch<Habitviewmodel>().GetAllHabitsFromHiveStorage();
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final mediaQueryWidth = mediaQuery.size.width;
    final mediaQueryHeight = mediaQuery.size.height;
    final colorForStreakDays = Color.fromARGB(255, 229, 116, 64);

    print("Current habits length: ${habits.length}");
    print("Current habits: ${habits.toString()}");

    return Scaffold(
        drawer: 
        Drawer(
          child: ListView(
          padding: EdgeInsets.zero,

          children: [
            UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.grey),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                // ask for confirmation
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Confirm'),
                    content: Text('Do you want to log out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('No')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Yes')),
                    ],
                  ),
                );

                if (confirmed == true) {
                  // perform sign out. Replace with your LoginUserViewModel sign-out method if available:
                  await Provider.of<LoginUserViewModel>(context, listen: false).SignOutUserAsync();

                  // remove all routes and go to login screen
                  Navigator.pushNamedAndRemoveUntil(context, '/loginUserView', (route) => false);
                }
              },
            ),
            // add more menu items here
          ],
        ), ),  
        appBar: AppBar(
          title: Center(child: Text("...")),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: Provider.of<Habitviewmodel>(context, listen: true)
                      .GetPreferredLocale,
                  icon: Icon(Icons.language, color: Colors.white),
                  dropdownColor: Colors.white,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  items: [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: const Color.fromARGB(255, 30, 31, 31)),
                          SizedBox(width: 8),
                          Text('English'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: Locale('kn'),
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: const Color.fromARGB(255, 41, 45, 41)),
                          SizedBox(width: 8),
                          Text('Kannada'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: Locale('hi'),
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: const Color.fromARGB(255, 32, 31, 30)),
                          SizedBox(width: 8),
                          Text('Hindi'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      Provider.of<Habitviewmodel>(context, listen: true)
                          .SetPreferredLocale(newLocale);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: Row(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final currentHabit = habits[index];
                    print(
                        "current habit to display: " + currentHabit.habitName);

                    //GestureDetector to detect taps on the card
                    return GestureDetector(
                      onTap: () {
                        print("Tapped on ${currentHabit.habitName}");
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Row(
                                    children: [
                                      Text(currentHabit.habitName),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.notification_add_sharp),
                                        onPressed: () async
                                        {
                                            var _selectedTime = TimeOfDay.now();
                                            final TimeOfDay? pickedTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  _selectedTime, // Set the initial time
                                              initialEntryMode: TimePickerEntryMode
                                                  .input, // Optional: Choose dial or input mode
                                            );

                                            if (pickedTime != null &&
                                                pickedTime.minute >= _selectedTime.minute) 
                                                {
                                                Provider.of<Habitviewmodel>(context, listen: false)
                                                .AddNewNotificationTimeForHabitReminder(
                                                    currentHabit, pickedTime.hour, pickedTime.minute);
                                                }
                                          }
                                      ),
                                    ],
                                  ),
                                  content: SizedBox(
                                      width: double.maxFinite,
                                      child: Text(
                                          currentHabit.HabitDescription(),
                                          maxLines: 10,
                                          style: TextStyle(fontSize: 15))),
                                  actions: [
                                    TextButton(
                                      child: Text(AppLocalizations.of(context)!.cancel),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext buildContext) {
                                                //Use SingleChildScrollView to avoid overflow error when keyboard appears,
                                                //So, it can become scrollable
                                                return SingleChildScrollView(
                                                  child: AlertDialog(
                                                    title:
                                                        Text(AppLocalizations.of(context)!.streakCalendar),
                                                    content: Container(
                                                      color:
                                                          const Color.fromARGB(
                                                              179,
                                                              174,
                                                              227,
                                                              231),
                                                      child: SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          height:
                                                              mediaQueryHeight *
                                                                  0.5,
                                                          child: Provider.of<
                                                                      Habitviewmodel>(
                                                                  context,
                                                                  listen: false)
                                                              .GenerateStreakCalendarViewWidget(
                                                                  currentHabit,
                                                                  mediaQuery,
                                                                  colorForStreakDays)
                                                              .$2),
                                                    ),
                                                    actions: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.circle,
                                                            color:
                                                                colorForStreakDays,
                                                          ),
                                                          Text(AppLocalizations.of(context)!.streakDays),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          mediaQueryWidth *
                                                                              0.06)),
                                                          TextButton(
                                                            child:
                                                                Text(AppLocalizations.of(context)!.cancel),
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        child: Text(AppLocalizations.of(context)!.streakCalendar))
                                  ]);
                            });
                      },
                      child: Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          color:
                              context.watch<Habitviewmodel>()
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
                                                  listen: true)
                                              .RemoveHabit(currentHabit);
                                          break;
                                        case 'edit':
                                          myUpdateHabitAttributes(
                                              context,
                                              "${AppLocalizations.of(context)!.editDescriptionFor} ${currentHabit.habitName}",
                                              currentHabit,
                                              HabitAttribute.HabitDescription);
                                          break;
                                        case 'color':
                                          OnColorChangeIconPressed(
                                              context, currentHabit);
                                          break;
                                        case 'mark_done':
                                          Provider.of<Habitviewmodel>(context,
                                                  listen: true)
                                              .SetHabitCompletionDateTime(
                                                  currentHabit, DateTime.now());
                                          break;
                                        case 'show_notification_time':
                                          var notificationTimesAndStatusForAHabit = Provider.of<Habitviewmodel>(context, listen: false)
                                              .GetAllCustomNotificationTimesForAHabitAsMap(currentHabit);
                                          
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext buildContext) {
                                              return AlertDialog(
                                                title: Text("Configured Notification Times"),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Header row
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          25,
                                                                      vertical:
                                                                          8),
                                                              child: Row(
                                                                children: const [
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Time",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Notification sent status",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // List items
                                                            ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  notificationTimesAndStatusForAHabit.$1
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                var timeInfo =
                                                                    notificationTimesAndStatusForAHabit.$1
                                                                        .entries
                                                                        .elementAt(
                                                                            index)
                                                                        .key;
                                                                var timeInfoStringList = timeInfo.split(':');
                                                                var hourIndex = int.parse(timeInfoStringList[0]);
                                                                var minuteIndex = int.parse(timeInfoStringList[1]);
                                                                var isNotificationSentForDayBool = notificationTimesAndStatusForAHabit.$1.entries.elementAt(index).value;
                                                                var suitableIcon = notificationTimesAndStatusForAHabit.$1
                                                                        .entries
                                                                        .elementAt(
                                                                            index)
                                                                        .value
                                                                    ? Icons
                                                                        .check
                                                                    : Icons
                                                                        .close;
                                                                var iconColour = notificationTimesAndStatusForAHabit.$1
                                                                        .entries
                                                                        .elementAt(
                                                                            index)
                                                                        .value
                                                                    ? const Color(
                                                                        0xFF4CAF50)
                                                                    : const Color(
                                                                        0xFFD03335);
                                                                print("############################### TIMEINFO:- $timeInfo ");
                                                                return ListTile(
                                                                  //leading: Icon(Icons.lock_clock_outlined), 
                                                                  title: Row(
                                                                      // mainAxisAlignment:
                                                                      //   MainAxisAlignment
                                                                      //       .spaceBetween, // Proper spacing
                                                                    children: [
                                                                      
                                                                      Expanded(
                                                                        // Wrap Text in Expanded
                                                                        child:
                                                                            Text(
                                                                          timeInfo,
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              5), // Add some spacing
                                                                      Icon(
                                                                        suitableIcon,
                                                                        color:
                                                                            iconColour,
                                                                        size:
                                                                            50.0,
                                                                      ),
                                                                      
                                                                      
                                                                    ],
                                                                    
                                                                  ),
                                                                  trailing: IconButton(onPressed: ()async
                                                                  {
                                                                    Provider.of<Habitviewmodel>(context, listen: true).RemoveAHabitNotificationTimeFromCustomHabitNotificationList((hourIndex, minuteIndex, notificationTimesAndStatusForAHabit.$2, false));
                                                                    Navigator.of(context).pop();
                                                                  }, icon: Icon(Icons.delete),
                                                                  ),
                                                                  //subtitle: Text(timeInfo.IsEventRaisedForTheDay ? AppLocalizations.of(context)!.notificationSent : AppLocalizations.of(context)!.notificationPending),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      )  
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text(AppLocalizations.of(context)!.cancel),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ],
                                              );
                                            }
                                          );
                                          break;
                                        default:
                                          print("Unknown menu item selected");
                                      }
                                    },
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(AppLocalizations.of(context)!.delete),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text(AppLocalizations.of(context)!.edit),
                                        ),
                                        PopupMenuItem(
                                          value: 'color',
                                          child: Text(AppLocalizations.of(context)!.changeColor),
                                        ),
                                        PopupMenuItem(
                                          value: 'mark_done',
                                          child: Text(AppLocalizations.of(context)!.markDone),
                                        ),
                                        PopupMenuItem(
                                          value: 'show_notification_time',
                                          child: Text("Show configured notification times"),
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
                                      context
                                          .watch<Habitviewmodel>()
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

                                // Habit status (bottom-right)
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
                                          ? AppLocalizations.of(context)!.todayGoalAchieved
                                          : AppLocalizations.of(context)!.yetToAchieveTodaysGoal,
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
          tooltip: AppLocalizations.of(context)!.addHabit,
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
