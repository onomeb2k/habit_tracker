import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double _age = 25; // Default age set to 25
  String _country = 'United States';
  List<String> _countries = [];
  List<String> selectedHabits = [];
  List<String> availableHabits = [
    'Wake Up Early',
    'Workout',
    'Drink Water',
    'Meditate',
    'Read a Book',
    'Practice Gratitude',
    'Sleep 8 Hours',
    'Eat Healthy',
    'Journal',
    'Walk 10,000 Steps'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    List<String> subsetCountries = [
      'United States',
      'Canada',
      'United Kingdom',
      'Australia',
      'India',
      'Germany',
      'France',
      'Japan',
      'China',
      'Brazil',
      'South Africa'
    ];

    setState(() {
      _countries = subsetCountries;
      _countries.sort();
      _country = _countries.isNotEmpty ? _countries[0] : 'United States';
    });
  }

  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      // If the form is not valid, do not proceed

      prefs.setString('username', _usernameController.text);
      prefs.setString('password', _passwordController.text);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
// create logic to get details
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(_nameController, 'Name', Icons.person),
                  const SizedBox(height: 10),
                  _buildInputField(
                      _usernameController, 'Username', Icons.alternate_email),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password_outlined,
                          color: Colors.blue.shade700),
                      hintText: 'Enter Password',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('Age: ${_age.round()}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18)),
                  Slider(
                    value: _age,
                    min: 21,
                    max: 100,
                    divisions: 79,
                    activeColor: Colors.blue.shade600,
                    inactiveColor: Colors.blue.shade300,
                    onChanged: (double value) {
                      setState(() {
                        _age = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCountryDropdown(),
                  const SizedBox(height: 10),
                  const Text('Select Your Habits',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: availableHabits.map((habit) {
                      final isSelected = selectedHabits.contains(habit);
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade600
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade700),
                          ),
                          child: Text(
                            habit,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 15),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter this field';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        value: _country,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
        isExpanded: true,
        underline: const SizedBox(),
        items: _countries.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _country = newValue!;
          });
        },
      ),
    );
  }
}
