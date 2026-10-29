import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itkalem_sign/features/auth/login/LoginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPassObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final url = Uri.parse('https://itkalemsign.runasp.net/api/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
          "name": _nameController.text.trim(),
          "phoneNumber": _phoneController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                preEmail: _emailController.text.trim(),
                prePassword: _passwordController.text,
              ),
            ),
          );
        }
      } else {
        String errorMessage = 'حدث خطأ ما';

        if (responseData['errors'] != null) {
          if (responseData['errors'] is Map) {
            errorMessage = (responseData['errors'] as Map).values.first[0];
          } else if (responseData['errors'] is List) {
            errorMessage = responseData['errors'][0];
          }
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        _showSnackBar(errorMessage, Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar('تعذر الاتصال بالسيرفر، تأكد من الإنترنت', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.4),
                              blurRadius: 50,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/img_2.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 90,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildField(
                      label: 'الاسم الكامل',
                      hint: 'أدخل اسمك',
                      ctrl: _nameController,
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      label: 'البريد الإلكتروني',
                      hint: 'mail@example.com',
                      ctrl: _emailController,
                      icon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'إيميل غير صحيح' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      label: 'رقم الهاتف',
                      hint: '01xxxxxxxxx',
                      ctrl: _phoneController,
                      icon: Icons.phone_android_outlined,
                      type: TextInputType.phone,
                      validator: (v) => v == null || v.length < 11 ? 'رقم غير صحيح' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildPassField(
                      label: 'كلمة المرور',
                      ctrl: _passwordController,
                      obs: _isPassObscured,
                      toggle: (v) => setState(() => _isPassObscured = v),
                      validator: (v) => v == null || v.length < 6 ? 'كلمة المرور ضعيفة' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildPassField(
                      label: 'تأكيد كلمة المرور',
                      ctrl: _confirmPasswordController,
                      obs: _isConfirmObscured,
                      toggle: (v) => setState(() => _isConfirmObscured = v),
                      validator: (v) => v != _passwordController.text ? 'لا تطابق' : null,
                    ),
                    const SizedBox(height: 35),
                    _buildButton(),
                    const SizedBox(height: 25),
                    _buildLoginLink(),
                    const SizedBox(height: 50),
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
    required String hint,
    required TextEditingController ctrl,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          validator: validator,
          keyboardType: type,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.24),
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassField({
    required String label,
    required TextEditingController ctrl,
    required bool obs,
    required Function(bool) toggle,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obs,
          validator: validator,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: '********',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.24),
              fontSize: 13,
            ),
            prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54)),
            suffixIcon: IconButton(
              icon: Icon(
                obs ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
              ),
              onPressed: () => toggle(!obs),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Text(
          'تسجيل حساب جديد',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟ ',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: Text(
            'تسجيل دخول',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}