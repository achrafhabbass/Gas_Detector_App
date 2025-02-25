import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gas_detector_app/auth.dart';
import 'package:gas_detector_app/pages/home_page.dart';

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
      print('Fetched users: $users');
      setState(() {
        _users = users ?? [];
        _isLoading = false;
      });
      print('Users list length: ${_users.length}');
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
    });
    try {
      await _auth.deleteUser(email);
      _fetchUsers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de supprimer l utilisateur: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _updateUser(
      String oldEmail, String newEmail, String newPassword) async {
    if (!_validateEmail(newEmail) || !_validatePassword(newPassword)) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.updateUser(oldEmail, newEmail, newPassword);
      _fetchUsers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Échec de la mise à jour de l utilisateur: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  Future<void> _addUser(String email, String password) async {
    if (!_validateEmail(email) || !_validatePassword(password)) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _fetchUsers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible d ajouter l utilisateur: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
    }
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _showSnackBar('Le-mail ne peut pas être vide');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Format d email invalide');
      return false;
    }
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _showSnackBar('Le mot de passe ne peut pas être vide');
      return false;
    }
    if (password.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final isUpdate = user != null;
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final passwordController =
        TextEditingController(text: user?['Mot de passe'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true; // State for password visibility

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUpdate ? 'Update User' : 'Add New User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    ),
                    validator: (value) =>
                        _validateEmail(value ?? '') ? null : 'Email invalide',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword =
                                !obscurePassword; // Toggle visibility
                          });
                        },
                      ),
                    ),
                    obscureText: obscurePassword, // Controlled by state
                    validator: (value) => _validatePassword(value ?? '')
                        ? null
                        : 'Mot de passe invalide',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Annuler',
                            style: GoogleFonts.poppins(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (isUpdate) {
                              await _updateUser(
                                  user['email'],
                                  emailController.text,
                                  passwordController.text);
                            } else {
                              await _addUser(emailController.text,
                                  passwordController.text);
                            }
                            if (_errorMessage == null) Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isUpdate ? 'Mise à jour' : 'Ajouter',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Utilisateurs',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _users.isEmpty
              ? Center(
                  child: Text(
                    'Aucun utilisateur trouvé',
                    style:
                        GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final firstName = user['email'].split('@')[0];
                      print('Rendu utilisateur: $firstName');
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              firstName[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            firstName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showUserDialog(user: user),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(user['email']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Colors.blue.shade800,
        tooltip: 'Ajouter un utilisateur',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
