import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/auth_requests.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn;

  AuthBloc({required ApiService apiService, required GoogleSignIn googleSignIn})
    : _apiService = apiService,
      _googleSignIn = googleSignIn,
      super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthTokenValidationRequested>(_onAuthTokenValidationRequested);
    on<AuthErrorReset>(_onAuthErrorReset);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _apiService.isLoggedIn();

      if (isLoggedIn) {
        final isValidToken = await _apiService.validateToken();

        if (isValidToken) {
          // Como não temos endpoint /auth/profile, consideramos autenticado apenas com token
          emit(AuthAuthenticated(null)); // Sem dados do usuário por enquanto
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final loginRequest = LoginRequest(
        email: event.email,
        senha: event.password,
      );

      final response = await _apiService.login(loginRequest);
      // Login tradicional não retorna user, só token
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final registerRequest = RegisterRequest(
        nome: event.name,
        email: event.email,
        senha: event.password,
      );

      final response = await _apiService.register(registerRequest);
      emit(AuthRegistrationSuccess(response.user));

      // Após sucesso no registro, autentica automaticamente
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGoogleSignInProgress());

    try {
      // Primeiro, faz logout de qualquer conta Google anterior
      await _googleSignIn.signOut();

      // Inicia o processo de login com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuario cancelou o login
        emit(AuthUnauthenticated());
        return;
      }

      // Obtém o token de autenticação - removendo await desnecessário
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Não foi possível obter o token do Google');
      }

      // Faz login no nosso backend
      final googleLoginRequest = GoogleLoginRequest(
        idToken: googleAuth.idToken!,
      );

      final response = await _apiService.googleLogin(googleLoginRequest);
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Logout do Google se estiver logado
      await _googleSignIn.signOut();

      // Logout do nosso backend
      await _apiService.logout();

      emit(AuthUnauthenticated());
    } catch (e) {
      // Mesmo se der erro, considera como logout bem sucedido
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthTokenValidationRequested(
    AuthTokenValidationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isValid = await _apiService.validateToken();

      if (!isValid) {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthErrorReset(
    AuthErrorReset event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }
}
