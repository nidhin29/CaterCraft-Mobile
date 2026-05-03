import 'dart:io';
import 'package:catering/Application/signin/signin_cubit.dart';
import 'package:catering/Presentation/Auth/otp_verification.dart';
import 'package:catering/Presentation/Auth/signin.dart';
import 'package:catering/Presentation/common/snack.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _licenseFile;
  File? _logoFile;

  Future<void> _handleGoogleAuth(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        if (mounted) {
          context.read<SigninCubit>().googleLogin(idToken);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to get Google ID Token")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In Error: $e")),
        );
      }
    }
  }

  Future<void> _pickLicense() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => _licenseFile = File(picked.path));
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppTheme.premiumGradient),
          ),
          BlocListener<SigninCubit, SigninState>(
            listener: (context, state) {
              state.isFailureOrSuccess.fold(
                () => null,
                (either) => either.fold(
                  (failure) => displaySnackBar(context: context, text: "Registration Failed"),
                  (success) {
                    // Navigate to OTP Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OtpVerificationPage(email: emailController.text.trim()),
                      ),
                    );
                  },
                ),
              );
            },
            child: const SizedBox.shrink(),
          ),
          BlocBuilder<SigninCubit, SigninState>(
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 40,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        Text(
                          "JOIN CATERCRAFT",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: isSmallScreen ? 4 : 8,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                        decoration: AppTheme.glassDecoration(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _textField(controller: nameController, label: "Business Name", icon: Icons.business),
                              const SizedBox(height: 20),
                              _textField(controller: emailController, label: "Email", icon: Icons.email_outlined),
                              const SizedBox(height: 20),
                              _textField(controller: passwordController, label: "Password", icon: Icons.lock_outline, isPassword: true),
                              const SizedBox(height: 30),
                              
                              // License Upload
                              InkWell(
                                onTap: state.isLoading ? null : _pickLicense,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.upload_file, color: _licenseFile != null ? Colors.greenAccent : Colors.white54),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _licenseFile != null ? _licenseFile!.path.split('/').last : "Upload Business License (PDF/Image)",
                                          style: TextStyle(color: _licenseFile != null ? Colors.white : Colors.white30),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Logo Upload
                              InkWell(
                                onTap: state.isLoading ? null : _pickLogo,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, color: _logoFile != null ? AppTheme.ownerAccent : Colors.white54),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _logoFile != null ? _logoFile!.path.split('/').last : "Official Company Logo",
                                          style: TextStyle(color: _logoFile != null ? Colors.white : Colors.white30),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: state.isLoading 
                                      ? null 
                                      : () {
                                          if (_formKey.currentState!.validate() && _licenseFile != null && _logoFile != null) {
                                            context.read<SigninCubit>().registerOwner(
                                                  name: nameController.text.trim(),
                                                  email: emailController.text.trim(),
                                                  password: passwordController.text.trim(),
                                                  license: _licenseFile!,
                                                  logo: _logoFile!,
                                                );
                                          } else if (_licenseFile == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Please upload your business license")),
                                            );
                                          } else if (_logoFile == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Please upload your official company logo")),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ownerAccent),
                                  child: state.isLoading 
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text("REGISTER AS OWNER", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
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
                                    : const Text("REGISTER WITH GOOGLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: state.isLoading ? null : () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                ),
                                child: const Text("Already have an account? Sign In", style: TextStyle(color: Colors.white54)),
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
            },
          ),
        ],
      ),
    );
  }

  Widget _textField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
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
