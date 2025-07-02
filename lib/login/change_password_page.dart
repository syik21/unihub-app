import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/pages/user-profile/profile.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import '../pages/user-profile/auth_user.dart';

class ChangePasswordPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const ChangePasswordPage({super.key, required this.toggleTheme});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _currentPasswordFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _confirmPasswordFieldKey =
      GlobalKey<FormFieldState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String _passwordStrength = '';
  Color _strengthColor = Colors.red;

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.red;
      });
      return;
    }
    final bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    final bool hasLower = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'[0-9]'));
    final bool hasSpecial = password.contains(RegExp(r'[!@#\$&*~]'));
    if (password.length >= 8 &&
        hasUpper &&
        hasLower &&
        hasDigit &&
        hasSpecial) {
      setState(() {
        _passwordStrength = 'Strong';
        _strengthColor = Colors.green;
      });
    } else if (password.length >= 6 &&
        ((hasUpper && hasLower) || (hasLower && hasDigit))) {
      setState(() {
        _passwordStrength = 'Medium';
        _strengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrength = 'Weak';
        _strengthColor = Colors.red;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(Icons.info_outline, size: 40, color: Colors.redAccent),
            backgroundColor: Colors.white,
            title: Text(
              title,
              style: TextStyle(
                color: Color(0xFF15151E),
                fontWeight: FontWeight.w700,
              ),
            ),
            titlePadding: EdgeInsets.symmetric(horizontal: 24),
            content: Text(
              message,
              style: TextStyle(color: Color(0xFF15151E)),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: Color(0xFF15151E))),
              ),
            ],
          ),
    );
  }

  Future<void> _changePassword() async {
    await checkingConnect();
    if (!isConnected) {
      _showErrorDialog("Connection Error", 'Please connect to a real wifi');
      return;
    }
    setState(() {
      _check = true;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentPassword = _currentPasswordController.text;
        final newPassword = _newPasswordController.text;

        // Check if userId exists
        if (userProvider.userId == null) {
          throw Exception('User ID not found');
        }

        // Verify current password
        final currentUser =
            await Supabase.instance.client
                .from('user')
                .select('password')
                .eq('id', userProvider.userId!)
                .single();

        if (currentUser['password'] != currentPassword) {
          _showErrorDialog(
            "Password Change Failed",
            'Current password is incorrect.',
          );
          setState(() {
            _isLoading = false;
            _check = false;
          });
          return;
        }

        // Update password in Supabase
        final updatePassword =
            await Supabase.instance.client
                .from('user')
                .update({'password': newPassword})
                .eq('id', userProvider.userId!)
                .select()
                .single();

        if (updatePassword.isNotEmpty) {
          setState(() {
            _isLoading = false;
            _check = false;
          });
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ProfilePage(toggleTheme: widget.toggleTheme),
            ),
          );
          _showSuccessMessage('Password changed successfully!');
        } else {
          throw Exception('Failed to update password in database');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _check = false;
        });
        _showErrorDialog(
          'Error',
          'Failed to change password. Please try again.',
        );
      }
    }
  }

  void _showSuccessMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.lightGreen,
      icon: Icons.check_circle,
      iconColor: Colors.white,
    );
  }

  Future<dynamic> getUserPassword(String? managerId) async {
    final response =
        await Supabase.instance.client
            .from('user')
            .select('password')
            .eq('id', managerId!)
            .single();

    final storedPassword = response['password'];

    // 🔐 If you store hashed passwords (recommended):
    //final inputHashed = sha256.convert(utf8.encode(inputPassword)).toString();

    return storedPassword;
  }

  Future<void> gettingUserPassword(String userId) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final isConnect = await getUserPassword(userId);
    setState(() {
      userPassword = isConnect;
    });
  }

  bool isConnected = true;
  void checkingconnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  Future<void> checkingConnect() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkingconnection();
  }

  dynamic userPassword;
  bool _initialized = false;
  bool _check = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        gettingUserPassword(userId);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProfilePage(toggleTheme: widget.toggleTheme),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Change Password",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: AppDecorations.cardDecoration(context),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Information',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 30),

                      // Current Password
                      Text(
                        'CURRENT PASSWORD',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: TextStyle(fontFamily: 'Poppins'),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        key: _currentPasswordFieldKey,
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        onChanged: (val) {
                          _currentPasswordFieldKey.currentState?.validate();
                          setState(() {
                            _check = false;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          } else if (_check && value != userPassword) {
                            return 'It is not match to your current password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[200]
                                  : Color(0xFF14141E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _obscureCurrentPassword =
                                          !_obscureCurrentPassword,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // New Password
                      Row(
                        children: [
                          Text(
                            'NEW PASSWORD',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(width: 16),
                          if (_passwordStrength.isNotEmpty)
                            Text(
                              '(Strength: $_passwordStrength)',
                              style: TextStyle(
                                color: _strengthColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: TextStyle(fontFamily: 'Poppins'),
                        key: _passwordFieldKey,
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onChanged: (value) {
                          _checkPasswordStrength(value);
                          _passwordFieldKey.currentState?.validate();
                          setState(() {
                            _check = false;
                          });
                        },
                        validator: (value) {
                          if (_check && (value == null || value.isEmpty)) {
                            return 'Please enter a new password';
                          }
                          if (_check && _passwordStrength != 'Strong') {
                            return 'Password is not strong enough';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[200]
                                  : Color(0xFF14141E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _obscureNewPassword =
                                          !_obscureNewPassword,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Text(
                        'CONFIRM NEW PASSWORD',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: TextStyle(fontFamily: 'Poppins'),
                        key: _confirmPasswordFieldKey,
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onChanged: (_) {
                          _confirmPasswordFieldKey.currentState?.validate();
                          setState(() {
                            _check = false;
                          });
                        },
                        validator: (value) {
                          if (_check && (value == null || value.isEmpty)) {
                            return 'Please confirm your new password';
                          }
                          if (_check && value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[200]
                                  : Color(0xFF14141E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : _changePassword,
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'CHANGE PASSWORD',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
