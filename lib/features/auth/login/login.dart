import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indo_mobile/core/di/sl.dart';
import 'package:indo_mobile/core/theme/color_conts.dart';
import 'package:indo_mobile/core/util/toast.dart';
import 'package:indo_mobile/features/home/app.dart';
import 'package:indo_mobile/features/auth/bloc/auth_bloc.dart';

class IndoGripLoginView extends StatefulWidget {
  IndoGripLoginView({super.key});
  static const String routeName = '/login';

  @override
  State<IndoGripLoginView> createState() => _IndoGripLoginViewState();
}

class _IndoGripLoginViewState extends State<IndoGripLoginView> {
  late final AuthBloc authBloc;

  bool isHide = true;

  @override
  void initState() {
    super.initState();
    authBloc = sl<AuthBloc>();
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController uEmailController = TextEditingController();

  final TextEditingController uPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: secondaryColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo or App Name
                  const Text(
                    'IndoGrip',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  Container(
                    // height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: uEmailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: kButtonColor,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: kButtonColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, color: kButtonColor),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  Container(
                    // height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: uPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Password',

                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: kButtonColor,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: kButtonColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isHide ? Icons.visibility_off : Icons.visibility,
                            color: kButtonColor,
                          ),
                          onPressed: () {
                            setState(() {
                              isHide = !isHide;
                            });
                          },
                        ),

                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, color: kButtonColor),
                      obscureText: isHide,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  buildLoginButton,
                  // Login Button
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get buildLoginButton => BlocConsumer(
    bloc: authBloc,
    listener: (context, state) {
      if (state is AuthIndoGripMobileLoginLoadedSuccessStatus) {
        if (state.model.status == 1) {
          showToast(
            context,
            state.model.message.toString(),
            backgroundColor: Colors.green,
          );
          context.goNamed(AppHome.routeName);
        } else {
          showToast(
            context,
            state.model.message.toString(),
            backgroundColor: Colors.red,
          );
        }
      }
      if (state is AuthIndoGripLoginFailedErrorStatus) {
        showToast(context, state.error, backgroundColor: Colors.red);
      }
    },
    builder: (context, state) {
      if (state is AuthLoadingStatus) {
        return const Center(child: CircularProgressIndicator());
      }

      return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            authBloc.add(
              AuthIndoGripMobileLoginEvent(
                uEmail: uEmailController.text,
                uPassword: uPasswordController.text,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    },
  );
}
