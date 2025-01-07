import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gas_detector_app/auth.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final Auth _auth = Auth();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final users = await _auth.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch users: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _deleteUser(String email) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _auth.deleteUser(email);
      _fetchUsers(); // Refresh the list
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete user: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _updateUser(
      String oldEmail, String newEmail, String newPassword) async {
    if (!_validateEmail(newEmail) || !_validatePassword(newPassword)) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _auth.updateUser(oldEmail, newEmail, newPassword);
      _fetchUsers(); // Refresh the list
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update user: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _addUser(String email, String password) async {
    if (!_validateEmail(email) || !_validatePassword(password)) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _fetchUsers(); // Refresh the list
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add user: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _showSnackBar('Email cannot be empty');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Invalid email format');
      return false;
    }
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _showSnackBar('Password cannot be empty');
      return false;
    }
    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorMessage = null; // Clear previous error
                });
                await _addUser(emailController.text, passwordController.text);
                if (_errorMessage == null) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateUserDialog(Map<String, dynamic> user) {
    final TextEditingController emailController =
        TextEditingController(text: user['email']);
    final TextEditingController passwordController =
        TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorMessage = null; // Clear previous error
                });
                await _updateUser(user['email'], emailController.text,
                    passwordController.text);
                if (_errorMessage == null) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: ModalRoute.of(context)!.animation!,
                            curve: Curves.easeInOut,
                          )),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                user['email'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showUpdateUserDialog(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteUser(user['email']),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
