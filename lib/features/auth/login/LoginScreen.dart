import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itkalem_sign/features/auth/register/RegisterScreen.dart';
import 'package:itkalem_sign/features/main_layout/mainLayout.dart';

class LoginScreen extends StatefulWidget {
  final String? preEmail;
  final String? prePassword;

  const LoginScreen({super.key, this.preEmail, this.prePassword});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.preEmail != null) _emailController.text = widget.preEmail!;
    if (widget.prePassword != null) _passwordController.text = widget.prePassword!;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final url = Uri.parse('https://itkalemsign.runasp.net/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim(), 'password': _passwordController.text}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = responseData['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', userData['name']?.toString() ?? "User");
        await prefs.setString('userEmail', userData['email']?.toString() ?? _emailController.text);
        await prefs.setString('userPhone', userData['phoneNumber']?.toString() ?? "لا يوجد رقم");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(
                userName: userData['name']?.toString() ?? "User",
                userEmail: userData['email']?.toString() ?? _emailController.text,
                userPhone: userData['phoneNumber']?.toString() ?? "لا يوجد رقم",
              ),
            ),
          );
        }
      } else {
        _showSnackBar(responseData['message'] ?? 'بيانات الدخول غير صحيحة');
      }
    } catch (e) {
      _showSnackBar('حدث خطأ في الاتصال بالسيرفر');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              blurRadius: 60,
                              spreadRadius: 10
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/img_3.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 120,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.24)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                        'أهلاً بك مجدداً',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    const SizedBox(height: 40),
                    _buildField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        isPass: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'بريد إلكتروني غير صحيح';
                          return null;
                        }
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                        label: 'كلمة المرور',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        isPass: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                          if (value.length < 6) return 'كلمة المرور قصيرة جداً';
                          return null;
                        }
                    ),
                    const SizedBox(height: 40),
                    _buildLoginButton(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'ليس لديك حساب؟ ',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                          child: Text(
                              'سجل الآن',
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isPass,
    required String? Function(String?)? validator
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14
            )
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass ? _isPasswordObscured : false,
          validator: validator,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54)),
            suffixIcon: isPass
                ? IconButton(
                icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54)
                ),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured)
            )
                : null,
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).dividerColor)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).primaryColor)
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.redAccent)
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
        ),
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
            'تسجيل الدخول',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}