import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'features/auth/data/auth_bloc.dart';
import 'features/auth/data/auth_event.dart';
import 'features/auth/data/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/home_screen.dart';
import 'features/despensas/data/services/despensas_service.dart';
import 'features/despensas/presentation/bloc/despensas_bloc.dart';
import 'features/despensas/presentation/screens/despensas_screen.dart';
import 'features/despensas/presentation/screens/despensa_detalhes_screen.dart';

void main() {
  runApp(const EstoqueMaxApp());
}

class EstoqueMaxApp extends StatelessWidget {
  const EstoqueMaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(create: (context) => ApiService()),
        RepositoryProvider<GoogleSignIn>(
          create: (context) {
            return GoogleSignIn(
              clientId: '265016365851-63o4nec9jujr8eelujrimjb4667ghobi.apps.googleusercontent.com',
              scopes: ['email', 'profile'],
            );
          },
        ),
        RepositoryProvider<DespensasService>(
          create: (context) => DespensasService(context.read<ApiService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              apiService: context.read<ApiService>(),
              googleSignIn: context.read<GoogleSignIn>(),
            )..add(AuthStarted()),
          ),
          BlocProvider<DespensasBloc>(
            create: (context) => DespensasBloc(context.read<DespensasService>()),
          ),
        ],
        child: MaterialApp(
          title: 'EstoqueMax',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/despensas': (context) => const DespensasScreen(),
            '/despensa-detalhes': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              
              if (args == null) {
                // Se não há argumentos, volta para a lista de despensas
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/despensas');
                });
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              final despensaId = args['despensaId'];
              if (despensaId == null || despensaId is! int) {
                // Se o ID é inválido, volta para a lista de despensas
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/despensas');
                });
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              return DespensaDetalhesScreen(
                despensaId: despensaId,
                despensaNome: args['despensaNome'] as String?,
              );
            },
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
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
          if (state is AuthLoading || state is AuthInitial) {
            return const SplashScreen();
          } else if (state is AuthAuthenticated) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.onPrimary,
                size: 50,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'EstoqueMax',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Carregando...',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
