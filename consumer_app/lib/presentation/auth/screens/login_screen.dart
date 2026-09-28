import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Phone controllers
  final _phoneController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();

  // Email controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSendPhoneOtp() {
    if (_phoneFormKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      final fullNumber = '${AppConstants.defaultCountryCode}$phone';
      context.read<AuthBloc>().add(SendPhoneOtpEvent(fullNumber));
    }
  }

  void _onEmailAuthSubmit() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isSignUpMode) {
        context.read<AuthBloc>().add(SignUpWithEmailEvent(
              email: email,
              password: password,
            ));
      } else {
        context.read<AuthBloc>().add(SignInWithPasswordEvent(
              email: email,
              password: password,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push(
            '/otp-verify',
            extra: {
              'target': state.target,
              'isPhone': state.isPhone,
            },
          );
        } else if (state is AuthProfileRequired) {
          context.go('/profile-setup');
        } else if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.sacredCrimson,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Devotional Banner
                _buildHeader(context),

                // Auth Form Body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Auth Method Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: AppColors.saffronPrimary,
                          unselectedLabelColor: AppColors.textSecondaryLight,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(
                              iconMargin: EdgeInsets.zero,
                              text: '📱 Phone OTP',
                            ),
                            Tab(
                              iconMargin: EdgeInsets.zero,
                              text: '✉️ Email Login',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tab View Content
                      SizedBox(
                        height: 330,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // 1. Phone OTP Form
                            _buildPhoneOtpTab(isLoading),

                            // 2. Email Login/Signup Form
                            _buildEmailTab(isLoading),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Divider "OR"
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Instant Guest / Devotee Preview Button
                      OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                context
                                    .read<AuthBloc>()
                                    .add(const SignInAsGuestEvent());
                              },
                        icon: const Icon(
                          Icons.explore_rounded,
                          color: AppColors.saffronPrimary,
                          size: 20,
                        ),
                        label: Text(
                          'Explore as Devotee Guest',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.saffronPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: AppColors.saffronLight,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dev / Supabase Info Badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warmCream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.marigoldGold.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: AppColors.deepAmber,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Powered by Supabase Auth with secure encrypted sessions & OTP verification.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Terms and Privacy
                      Center(
                        child: Text(
                          'By proceeding, you agree to Mandiram\'s Terms of Service & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A1005),
            Color(0xFF8B2510),
            Color(0xFFFF6B35),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Ornamental Mandir Logo
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                AppConstants.logoAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.temple_hindu_rounded,
                  size: 40,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppConstants.appName,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign In to access Mandirs, Pujas & Astrologers',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFDE68A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneOtpTab(bool isLoading) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Mobile Number',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter 10-digit mobile number',
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      AppConstants.defaultCountryCode,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your mobile number';
              }
              if (value.trim().length != 10) {
                return 'Enter a valid 10-digit number';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'A 6-digit sacred verification OTP will be sent via SMS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: isLoading ? null : _onSendPhoneOtp,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Sacred OTP',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _useEmailOtp = true;

  void _onSendEmailOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.sacredCrimson,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(SendEmailOtpEvent(email));
  }

  Widget _buildEmailTab(bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.saffronPrimary),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          if (_useEmailOtp) ...[
            Text(
              'A 6-digit sacred verification OTP will be sent to your email via Resend',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _useEmailOtp = false),
                child: const Text(
                  'Or use Password login',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : _onSendEmailOtp,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Get Sacred Email OTP',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.saffronPrimary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMutedLight,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _useEmailOtp = true),
                  child: const Text(
                    'Use Email OTP instead',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _isSignUpMode = !_isSignUpMode);
                  },
                  child: Text(
                    _isSignUpMode
                        ? 'Sign In with Password'
                        : 'New Devotee? Register',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : _onEmailAuthSubmit,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isSignUpMode ? 'Register Devotee' : 'Sign In with Password',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
