import 'dart:io';
import 'package:catering/Application/signin/signin_cubit.dart';
import 'package:catering/Domain/Failure/failure.dart';
import 'package:catering/Presentation/Home/owner_home.dart';
import 'package:catering/Presentation/Home/staff_home.dart';
import 'package:catering/Presentation/Auth/register.dart';
import 'package:catering/Presentation/common/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _selectedRole = 1; // 1 for Owner, 2 for Staff

  void _showGoogleRegisterDialog(BuildContext context, String tokenID) {
    final TextEditingController companyController = TextEditingController();
    File? licenseFile;
    File? logoFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.1))),
          title: Text("Complete Registration", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please provide your business details to continue.", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: companyController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Company Name",
                  labelStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setDialogState(() => licenseFile = File(pickedFile.path));
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: licenseFile != null ? Colors.cyan : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(licenseFile != null ? Icons.check_circle : Icons.upload_file, color: licenseFile != null ? Colors.cyan : Colors.white38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          licenseFile != null ? "License Uploaded" : "Upload Business License",
                          style: TextStyle(color: licenseFile != null ? Colors.cyan : Colors.white38, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (pickedFile != null) {
                    setDialogState(() => logoFile = File(pickedFile.path));
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: logoFile != null ? Colors.cyan : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(logoFile != null ? Icons.photo_size_select_actual_outlined : Icons.add_photo_alternate_outlined, color: logoFile != null ? Colors.cyan : Colors.white38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          logoFile != null ? "Logo Selected" : "Upload Company Logo",
                          style: TextStyle(color: logoFile != null ? Colors.cyan : Colors.white38, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (companyController.text.isNotEmpty && licenseFile != null && logoFile != null) {
                  context.read<SigninCubit>().googleRegister(
                    companyName: companyController.text.trim(),
                    tokenID: tokenID,
                    license: licenseFile!,
                    logo: logoFile!,
                  );
                  Navigator.pop(context);
                } else {
                  displaySnackBar(context: context, text: licenseFile == null ? "License required" : (logoFile == null ? "Company logo required" : "Fill all details"));
                }
              },
              child: const Text("FINISH", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _handleGoogleAuth(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        if (mounted) {
          context.read<SigninCubit>().googleLogin(idToken);
        }
      } else {
        if (mounted) {
          displaySnackBar(context: context, text: "Failed to get Google ID Token");
        }
      }
    } catch (e) {
      if (mounted) {
        displaySnackBar(context: context, text: "Google Sign-In Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SigninCubit, SigninState>(
        listener: (context, state) {
          if (state.isGoogleRegistrationRequired) {
            _showGoogleRegisterDialog(context, state.googleTokenID!);
          }
          state.isFailureOrSuccess.fold(
            () => null,
            (either) => either.fold(
              (failure) {
                if (!state.isLoading) {
                  String message = "Something unexpected happened";
                  if (failure == const MainFailure.serverFailure()) {
                    message = "Server is down";
                  } else if (failure == const MainFailure.authFailure()) {
                    message = "Please check the email address";
                  } else if (failure == const MainFailure.authNotFound()) {
                     // Handled by registration dialog
                  } else if (failure == const MainFailure.incorrectCredential()) {
                    message = "Incorrect Password";
                  } else if (failure == const MainFailure.clientFailure()) {
                    message = "Something wrong with your network";
                  }
                  if (failure != const MainFailure.authNotFound()) {
                    displaySnackBar(context: context, text: message);
                  }
                }
              },
              (success) {
                final role = _selectedRole;
                if (role == 1) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OwnerHomeScreen()),
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const StaffHomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          );
        },
        builder: (context, state) {
          final double screenWidth = MediaQuery.of(context).size.width;
          final bool isSmallScreen = screenWidth < 600;

          return Stack(
            children: [
              // Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      // Header (Logo)
                      Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "CATERCRAFT",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "PREMIUM CATERING SOLUTIONS",
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 8,
                          letterSpacing: 2,
                        ),
                      ),

                      // Glassmorph Card
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sign in to continue managing your events",
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Role Selection
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    _roleTab("Owner", 1),
                                    _roleTab("Staff", 2),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Fields
                              _textField(
                                controller: emailController,
                                label: "Email Address",
                                icon: Icons.alternate_email,
                              ),
                              const SizedBox(height: 20),
                              _textField(
                                controller: passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 40),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!.validate()) {
                                            context.read<SigninCubit>().signIn(
                                                  emailController.text.trim(),
                                                  passwordController.text.trim(),
                                                  _selectedRole,
                                                );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedRole == 1 
                                        ? Colors.blueAccent 
                                        : Colors.orangeAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          "SIGN IN",
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                ),
                              ),
                              if (_selectedRole == 1) ...[ // Only show for Owner
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Text("OR", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                                    ),
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                              if (_selectedRole == 1) // Only show for Owner
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: state.isLoading 
                                        ? null 
                                        : () => _handleGoogleAuth(context),
                                    icon: state.isLoading
                                        ? const SizedBox.shrink()
                                        : Image.network(
                                            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                                            height: 20,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                                          ),
                                    label: state.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Text("CONTINUE WITH GOOGLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (_selectedRole == 1) // Only show for Owner
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                                    ),
                                    child: Text(
                                      "NEW OWNER? REGISTER HERE",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white30,
                                        fontSize: 10,
                                        letterSpacing: 2,
                                      ),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _roleTab(String label, int role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (role == 1 ? Colors.blueAccent : Colors.orangeAccent) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: (role == 1 ? Colors.blueAccent : Colors.orangeAccent).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white30),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }
}
