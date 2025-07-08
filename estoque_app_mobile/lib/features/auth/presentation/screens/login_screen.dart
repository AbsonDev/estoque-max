import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/auth_bloc.dart';
import '../../data/auth_event.dart';
import '../../data/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(AuthGoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            _isLoading = state is AuthLoading || state is AuthGoogleSignInProgress;

            return LoadingOverlay(
              isLoading: _isLoading,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth > 800;
                    final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 800;
                    
                    return Center(
                        child: SingleChildScrollView(
                        padding: EdgeInsets.all(isWideScreen ? 40 : 24),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isWideScreen ? 1000 : double.infinity,
                          ),
                          child: isWideScreen
                              ? _buildWideScreenLayout(context, isWideScreen)
                              : _buildMobileLayout(context, isTablet),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout(BuildContext context, bool isWideScreen) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Row(
                                  children: [
          // Lado esquerdo - Informações visuais
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(48),
                                      decoration: BoxDecoration(
                gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor,
                                            AppTheme.primaryVariant,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'EstoqueMax',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Transforme a gestão do seu estoque doméstico com inteligência artificial',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureItem('🤖 Previsão inteligente de consumo'),
                  _buildFeatureItem('📊 Analytics detalhados'),
                  _buildFeatureItem('👨‍👩‍👧‍👦 Compartilhamento familiar'),
                  _buildFeatureItem('📱 Sincronização em tempo real'),
                ],
              ),
            ),
          ),
          // Lado direito - Formulário de login
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(48),
              child: _buildLoginForm(context, true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isTablet) {
    return Card(
      elevation: isTablet ? 8 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 0),
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          children: [
            _buildHeader(context, isTablet),
            SizedBox(height: isTablet ? 40 : 32),
            _buildLoginForm(context, false),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Column(
      children: [
        Container(
          width: isTablet ? 100 : 80,
          height: isTablet ? 100 : 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                                        boxShadow: [
                                          BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
          child: Icon(
                                        Icons.inventory_2_rounded,
                                        color: AppTheme.onPrimary,
            size: isTablet ? 50 : 40,
                                      ),
                                    ),
        SizedBox(height: isTablet ? 32 : 24),
                                    Text(
                                      'EstoqueMax',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
            fontSize: isTablet ? 36 : 32,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gerencie seu estoque doméstico\ncom inteligência',
                                      textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: AppTheme.textSecondary,
                                            height: 1.5,
            fontSize: isTablet ? 18 : 16,
                                          ),
                                    ),
                                  ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isWideScreen) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWideScreen) ...[
            Text(
              'Entrar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acesse sua conta para continuar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
          ],

                                AuthTextField(
                                  controller: _emailController,
                                  label: 'E-mail',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite seu e-mail';
                                    }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Por favor, digite um e-mail válido';
                                    }
                                    return null;
                                  },
                                ),

          const SizedBox(height: 20),

                                AuthTextField(
                                  controller: _passwordController,
                                  label: 'Senha',
                                  obscureText: !_isPasswordVisible,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: AppTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite sua senha';
                                    }
                                    if (value.length < 6) {
                                      return 'A senha deve ter pelo menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),

          const SizedBox(height: 32),

                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: AppTheme.onPrimary,
                elevation: 2,
                shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
              child: Text(
                                            'Entrar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimary,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  children: [
              Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3))),
                                    Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'ou',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ),
              Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3))),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                GoogleSignInButton(
            onPressed: _isLoading ? null : _handleGoogleLogin,
            isLoading: _isLoading,
                                ),

                                const SizedBox(height: 32),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Não tem uma conta? ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                    TextButton(
                                      onPressed: _isLoading
                                          ? null
                    : () => Navigator.of(context).pushNamed('/register'),
                                      child: Text(
                                        'Cadastre-se',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
      ),
    );
  }
}
