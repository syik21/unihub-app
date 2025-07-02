import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/pages/user-profile/profile.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:io';
import '../pages/user-profile/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSettingsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const AccountSettingsPage({super.key, required this.toggleTheme});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  Map<String, dynamic>? userDetail;
  bool isConnected = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    checkingconnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        loadUser(userId);
      }
      _initialized = true;
    }
  }

  Future<void> loadUser(String? user) async {
    try {
      final userId = Provider.of<UserProvider>(context).userId;
      final result = await searchUserById(
        userId, //! user id here ------------------------------------------------------------------------------------------------------------
      );
      if (mounted) {
        setState(() {
          userDetail = result;
        });
      }
    } catch (e) {
      // Handle error here
    }
  }

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

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.userName ?? '';
    _emailController.text = userProvider.userEmail ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image', 'Please try again.');
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Select Image Source',
            style: TextStyle(
              color: Color(0xFF15151E),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF15151E)),
                title: Text(
                  'Camera',
                  style: TextStyle(color: Color(0xFF15151E)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF15151E)),
                title: Text(
                  'Gallery',
                  style: TextStyle(color: Color(0xFF15151E)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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
            titlePadding: EdgeInsets.only(bottom: 16),
            content: Text(message, style: TextStyle(color: Color(0xFF15151E)),textAlign: TextAlign.center,),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: Color(0xFF15151E))),
              ),
            ],
          ),
    );
  }

  void _showQuestionMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      icon: Icons.info_outline,
      iconColor: Colors.white,
    );
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

  Future<void> _saveChanges() async {
    await checkingConnect();
    if (!isConnected) {
      _showErrorDialog("Connection Error", 'Please connect to a real wifi');
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if(!mounted)return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final newName = _nameController.text.trim().toLowerCase();
        final newEmail = _emailController.text.trim().toLowerCase();
        if (userProvider.userName == newName &&
            userProvider.userEmail == newEmail &&
            _selectedImage == null) {
          _showQuestionMessage("no changes. :)");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Check if userId exists
        if (userProvider.userId == null) {
          throw Exception('User ID not found');
        }

        // Update name in Supabase database
        if (userProvider.userName != newName) {
          try {
            final updateName =
                await Supabase.instance.client
                    .from('user')
                    .update({'name': newName})
                    .eq('id', userProvider.userId!)
                    .select()
                    .single();

            // Check if update was successful
            if (updateName.isEmpty) {
              throw Exception('Failed to update name in database');
            }
          } catch (e) {
            _showErrorDialog(
              "Name Update Failed",
              'Failed to update name. Please try again.',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
        if (userProvider.userEmail != newEmail) {
          // Check if email already exists for another user
          final existingUser =
              await Supabase.instance.client
                  .from('user')
                  .select()
                  .eq('email', newEmail)
                  .neq('id', userProvider.userId!)
                  .maybeSingle();

          if (existingUser != null) {
            _showErrorDialog(
              "Email Update Failed",
              'Email already exists. Please use a different email.',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          try {
            final updateEmail =
                await Supabase.instance.client
                    .from('user')
                    .update({'email': newEmail})
                    .eq('id', userProvider.userId!)
                    .select()
                    .single();

            // Check if update was successful
            if (updateEmail.isEmpty) {
              throw Exception('Failed to update email in database');
            }
          } catch (e) {
            _showErrorDialog(
              "Email Update Failed",
              'Failed to update email. Please try again.',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
        if (_selectedImage != null) {
          await updateUserPicture(_selectedImage, userProvider.userId);
          setState(() {
            _isLoading = false;
          });
        }

        setState(() {
          _isLoading = false;
        });

        if (userProvider.userName != newName ||
            userProvider.userEmail != newEmail ||
            _selectedImage != null) {
          await userProvider.updateUserName(newName);
          await userProvider.updateUserEmail(newEmail);
          _showSuccessMessage('Profile updated successfully!');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(
          'Error',
          'Failed to update profile. Please try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userImageUrl = userDetail?['image_url'];
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
                  "Account setting",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 20),
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child:
                              _selectedImage != null
                                  ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : userImageUrl != null &&
                                      userImageUrl.isNotEmpty
                                  ? Image.network(
                                    userImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // If image fails to load (e.g. no connection), fallback
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showImagePickerDialog,
                      child: Text(
                        'Change picture',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Settings Form
              Container(
                decoration: AppDecorations.cardDecoration(context),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'NAME',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'EMAIL',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email';
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
                          onPressed: _isLoading ? null : _saveChanges,
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'SAVE CHANGES',
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
