import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool showSignUp = false;
  bool _showForm = false;
  bool _isSplashPhase = true;
  String _displayedText = '';
  final String _fullText = 'UNIHUB';

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _loginEmailFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _loginPasswordFieldKey =
      GlobalKey<FormFieldState>();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  bool _loginObscurePassword = true;

  // Signup controllers
  final _signupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _signupNameFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _signupEmailFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _signupPasswordFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _signupConfirmPasswordFieldKey =
      GlobalKey<FormFieldState>();
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _signupConfirmPasswordController =
      TextEditingController();
  bool _signupObscurePassword = true;
  bool _signupObscureConfirmPassword = true;
  String _passwordStrength = '';
  Color _strengthColor = Colors.red;
  bool isConnect = true;
  bool _loginCheck = false;
  bool _signupCheck = false;

  @override
  void initState() {
    super.initState();
    _startTextAnimation();
  }

  Future<void> checkingConnect() async {
    final isConnecting = await checkConnection();
    setState(() {
      isConnect = isConnecting;
    });
  }

  Future<void> _startTextAnimation() async {
    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _displayedText = _fullText.substring(0, i + 1);
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _showForm = true;
      _isSplashPhase = false;
    });
  }

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

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        color: _isSplashPhase ? Colors.white : const Color(0xFF15151E),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment:
                  _showForm ? const Alignment(0, -0.7) : Alignment.center,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              child: Padding(
                padding: EdgeInsets.only(
                  top:
                      _showForm ? MediaQuery.of(context).size.height * 0.15 : 0,
                ),
                child: Text(
                  _displayedText,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color:
                        _isSplashPhase ? const Color(0xFF15151E) : Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            if (_showForm)
              AnimatedSlide(
                offset: showSignUp ? const Offset(0, 1) : Offset.zero,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "WHAT'S UP",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF14141E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'EMAIL',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Color(0xFF14141E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      // <-- Highlight background color
                                      cursorColor: Color(
                                        0xFF14141E,
                                      ), // <-- Cursor color
                                      selectionHandleColor: Color(
                                        0xFF14141E,
                                      ), // <-- Handle color
                                    ),
                              ),
                              child: TextFormField(
                                key: _loginEmailFieldKey,
                                onChanged: (val) {
                                  _loginEmailFieldKey.currentState?.validate();
                                  setState(() {
                                    _loginCheck = false;
                                  });
                                },
                                style: TextStyle(
                                  color: Color(0xFF14141E),
                                  fontFamily: 'Poppins',
                                ),
                                cursorColor: Color(0xFF14141E),
                                controller: _loginEmailController,
                                validator: (value) {
                                  if (_loginCheck) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return 'Enter a valid email';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Color(0xFF14141E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      // <-- Highlight background color
                                      cursorColor: Color(
                                        0xFF14141E,
                                      ), // <-- Cursor color
                                      selectionHandleColor: Color(
                                        0xFF14141E,
                                      ), // <-- Handle color
                                    ),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF14141E),
                                  fontFamily: 'Poppins',
                                ),
                                controller: _loginPasswordController,
                                obscureText: _loginObscurePassword,

                                key: _loginPasswordFieldKey,
                                onChanged: (_) {
                                  _loginPasswordFieldKey.currentState
                                      ?.validate();
                                  setState(() {
                                    _loginCheck = false;
                                  });
                                },
                                validator: (value) {
                                  if (_loginCheck) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your password';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _loginObscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _loginObscurePassword =
                                                  !_loginObscurePassword,
                                        ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'FORGOT PASSWORD?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF14141E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),*/
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF15151E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () async {
                                  await handleLogin(context);
                                },
                                child: const Text(
                                  'LOG IN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  _loginFormKey.currentState?.reset();
                                  _loginPasswordFieldKey.currentState
                                      ?.validate();
                                  setState(() {
                                    _loginEmailController.clear();
                                    _loginPasswordController.clear();
                                    showSignUp = true;
                                  });
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    text: 'DO U HAVE AN ACCOUNT? ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color:
                                          Colors
                                              .grey, // or Colors.blueAccent if you want same color
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'SIGN UP here',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.blueAccent,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
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
              ),
            if (_showForm)
              AnimatedSlide(
                offset: showSignUp ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _signupFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Create account',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Color(0xFF14141E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Color(0xFF14141E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      // <-- Highlight background color
                                      cursorColor: Color(
                                        0xFF14141E,
                                      ), // <-- Cursor color
                                      selectionHandleColor: Color(
                                        0xFF14141E,
                                      ), // <-- Handle color
                                    ),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF14141E),
                                  fontFamily: 'Poppins',
                                ),
                                key: _signupNameFieldKey,
                                onChanged: (val) {
                                  _signupNameFieldKey.currentState?.validate();
                                  setState(() {
                                    _signupCheck = false;
                                  });
                                },
                                cursorColor: Color(0xFF14141E),
                                controller: _signupNameController,
                                validator: (value) {
                                  if (_signupCheck) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your name';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'EMAIL',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Color(0xFF14141E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      // <-- Highlight background color
                                      cursorColor: Color(
                                        0xFF14141E,
                                      ), // <-- Cursor color
                                      selectionHandleColor: Color(
                                        0xFF14141E,
                                      ), // <-- Handle color
                                    ),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF14141E),
                                  fontFamily: 'Poppins',
                                ),
                                key: _signupEmailFieldKey,
                                onChanged: (val) {
                                  _signupEmailFieldKey.currentState?.validate();
                                  setState(() {
                                    _signupCheck = false;
                                  });
                                },
                                cursorColor: Color(0xFF14141E),
                                controller: _signupEmailController,
                                validator: (value) {
                                  if (_signupCheck) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return 'Enter a valid email';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'PASSWORD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: Color(0xFF14141E),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (_passwordStrength.isNotEmpty)
                                  Text(
                                    '(Strength: $_passwordStrength)',
                                    style: TextStyle(
                                      color: _strengthColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      // <-- Highlight background color
                                      cursorColor: Color(
                                        0xFF14141E,
                                      ), // <-- Cursor color
                                      selectionHandleColor: Color(
                                        0xFF14141E,
                                      ), // <-- Handle color
                                    ),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF14141E),
                                  fontFamily: 'Poppins',
                                ),
                                key: _signupPasswordFieldKey,
                                onChanged: (val) {
                                  _signupPasswordFieldKey.currentState
                                      ?.validate();
                                  _checkPasswordStrength(val);
                                  setState(() {
                                    _signupCheck = false;
                                  });
                                },
                                cursorColor: Color(0xFF14141E),
                                controller: _signupPasswordController,
                                obscureText: _signupObscurePassword,
                                validator: (value) {
                                  if (_signupCheck) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter a password';
                                    }
                                    if (_passwordStrength != 'Strong') {
                                      return 'Password is not strong enough';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _signupObscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _signupObscurePassword =
                                                  !_signupObscurePassword,
                                        ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              'CONFIRM PASSWORD',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Color(0xFF14141E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                      // <-- Highlight background color
                                      cursorColor: Color(
                                        0xFF14141E,
                                      ), // <-- Cursor color
                                      selectionHandleColor: Color(
                                        0xFF14141E,
                                      ), // <-- Handle color
                                    ),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                  color: Color(0xFF14141E),
                                  fontFamily: 'Poppins',
                                ),
                                key: _signupConfirmPasswordFieldKey,
                                onChanged: (val) {
                                  _signupConfirmPasswordFieldKey.currentState
                                      ?.validate();
                                  setState(() {
                                    _signupCheck = false;
                                  });
                                },
                                cursorColor: Color(0xFF14141E),
                                controller: _signupConfirmPasswordController,
                                obscureText: _signupObscureConfirmPassword,
                                validator: (value) {
                                  if (_signupCheck) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirm your password';
                                    }
                                    if (value !=
                                        _signupPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _signupObscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _signupObscureConfirmPassword =
                                                  !_signupObscureConfirmPassword,
                                        ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF15151E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () => handleSignUp(context),
                                child: const Text(
                                  'CREATE ACCOUNT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  _signupFormKey.currentState?.reset();
                                  _signupNameFieldKey.currentState?.validate();
                                  _signupPasswordFieldKey.currentState
                                      ?.validate();
                                  setState(() {
                                    _signupConfirmPasswordController.clear();
                                    _signupPasswordController.clear();
                                    _signupNameController.clear();
                                    _signupEmailController.clear();
                                    showSignUp = false;
                                  });
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    text: 'ALREADY HAVE AN ACCOUNT? ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color:
                                          Colors
                                              .grey, // or Colors.blueAccent if you want same color
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Log in here',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.blueAccent,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
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
              ),
          ],
        ),
      ),
    );
  }

  void showErrorDialog(String title, String message) {
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
            content: Text(
              message,
              style: TextStyle(color: Color(0xFF15151E)),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF15151E)),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> handleLogin(BuildContext context) async {
    final navigator = Navigator.of(
      context,
    ); // store context-dependent items early

    await checkingConnect();
    if (!isConnect) {
      if (!context.mounted) return;
      showErrorDialog("Connection error", 'Please check your lovely Wi-Fi.');
      return;
    }
    setState(() {
      _loginCheck = true;
    });

    if (_loginFormKey.currentState!.validate()) {
      if (!context.mounted) return;
      AppDecorations.showLoadingDialog(context, message: "Logging in...");

      final email = _loginEmailController.text.trim().toLowerCase();
      final password = _loginPasswordController.text;

      try {
        final response =
            await Supabase.instance.client
                .from('user')
                .select()
                .eq('email', email)
                .eq('password', password)
                .maybeSingle();

        if (!context.mounted) return;

        if (response != null) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.saveUserData(
            id: response['id'],
            type: response['type'],
            name: response['name'],
            email: response['email'],
          );

          navigator.pop(); // Close loading dialog
          navigator.pushReplacementNamed('/main');
          setState(() {
            _loginCheck = true;
          });
        } else {
          navigator.pop(); // Close loading dialog
          showErrorDialog(
            "Login failed",
            "Incorrect email or password. Please try again.",
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        navigator.pop(); // Close loading dialog
        showErrorDialog("Error", "Something went wrong: $e");
      }
    }
  }

  Future<void> handleSignUp(BuildContext context) async {
    final navigator = Navigator.of(context);
    await checkingConnect();
    if (!isConnect) {
      showErrorDialog("Connection error", 'Please check your lovely wifi.');
      return;
    }

    if (!mounted) return;
    setState(() {
      _signupCheck = true;
    });

    if (_signupFormKey.currentState!.validate()) {
      final name = _signupNameController.text.trim().toLowerCase();
      final email = _signupEmailController.text.trim().toLowerCase();
      final password = _signupPasswordController.text;

      try {
        // Check if email already exists
        final existingUser =
            await Supabase.instance.client
                .from('user')
                .select()
                .eq('email', email)
                .maybeSingle();

        if (existingUser != null) {
          showErrorDialog(
            "Sign up failed",
            'Email already exists. Please use a different email.',
          );
          return;
        }

        // Insert new user
        final response =
            await Supabase.instance.client
                .from('user')
                .insert({
                  'name': name,
                  'email': email,
                  'password': password, // ⚠️ Hash this in real apps
                  'type': 'user',
                })
                .select()
                .single();

        if (response.isNotEmpty) {
          if (!context.mounted) return;
          AppDecorations.showLoadingDialog(context, message: "Logging in...");

          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.saveUserData(
            id: response['id'],
            type: response['type'],
            name: response['name'],
            email: response['email'],
          );
          if (!context.mounted) return;
          navigator.pop();
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } catch (e) {
        showErrorDialog(
          "Sign up failed",
          'Something went wrong. Please try again.',
        );
      } finally {
        if (mounted) {
          setState(() {
            _signupCheck = false;
          });
        }
      }
    }
  }
}
