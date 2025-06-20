import 'package:flutter/material.dart';
import 'package:habit_tracker/login_screen.dart';
import 'add_habit_screen.dart';
import 'detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'personal_info_screen.dart';
import 'package:habit_tracker/notifications_screen.dart';
import 'reports_screen.dart';

class HabitTrackerScreen extends StatefulWidget {
  final String username;

  const HabitTrackerScreen({super.key, required this.username});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // country_list.dart

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? widget.username;
      selectedHabitsMap = Map<String, String>.from(
          jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'));
      completedHabitsMap = Map<String, String>.from(
          jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'));
    });
  }

  Future<void> _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
    await prefs.setString('completedHabitsMap', jsonEncode(completedHabitsMap));
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }

  Color _getHabitColor(String habit, Map<String, String> habitsMap) {
    String? colorHex = habitsMap[habit];
    if (colorHex != null) {
      try {
        return _getColorFromHex(colorHex);
      } catch (e) {
        print('Error parsing color for $habit: $e');
      }
    }
    return Colors.blue; // Default color in case of error.
  }

  void _signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              child: Text(
                name.isNotEmpty ? name : 'Loading...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configure'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                ).then((updatedHabits) {
                  _loadUserData(); // Reload data after returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen()),
                ).then((_) {
                  _loadUserData(); // Reload data after returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                _signOut(context);
                // Handle logout
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(
              Icons.menu,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        title: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 40),
          child: Text(
            name.isNotEmpty ? name : 'Loading...',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _loadUserData();
        },
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'To Do 📝',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            selectedHabitsMap.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        'Use the + button to create some habits!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: selectedHabitsMap.length,
                      itemBuilder: (context, index) {
                        String habit = selectedHabitsMap.keys.elementAt(index);
                        Color habitColor =
                            _getHabitColor(habit, selectedHabitsMap);
                        return Dismissible(
                          key: Key(habit),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              String color = selectedHabitsMap.remove(habit)!;
                              completedHabitsMap[habit] = color;
                              _saveHabits();
                            });
                          },
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Swipe to Complete',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.check, color: Colors.white),
                              ],
                            ),
                          ),
                          child: _buildHabitCard(habit, habitColor),
                        );
                      },
                    ),
                  ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Done ✅🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            completedHabitsMap.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Swipe right on an activity to mark as done.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: completedHabitsMap.length,
                      itemBuilder: (context, index) {
                        String habit = completedHabitsMap.keys.elementAt(index);
                        Color habitColor =
                            _getHabitColor(habit, completedHabitsMap);
                        return Dismissible(
                          key: Key(habit),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              String color = completedHabitsMap.remove(habit)!;
                              selectedHabitsMap[habit] = color;
                              _saveHabits();
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              children: [
                                Icon(Icons.undo, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Swipe to Undo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          child: _buildHabitCard(habit, habitColor,
                              isCompleted: true),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: selectedHabitsMap.isEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddHabitScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue.shade700,
              tooltip: 'Add Habits',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHabitCard(String title, Color color,
      {bool isCompleted = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      child: SizedBox(
        height: 60, // Adjust the height for thicker cards.
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  item: {
                    'title': title,
                    'description': isCompleted
                        ? 'This habit has been completed.'
                        : 'This habit is still pending.',
                  },
                ),
              ),
            );
          },
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : null,
        ),
      ),
    );
  }
}
