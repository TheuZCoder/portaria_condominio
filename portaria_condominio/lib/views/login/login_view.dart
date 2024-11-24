import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';
import '../../localizations/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _hasCredentials = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSavedEmail();
    await _checkBiometricAvailability();
    await _loadBiometricPreference();
    await _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    setState(() {
      _hasCredentials = savedEmail != null && savedPassword != null;
    });
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    });
    
    if (_isBiometricEnabled && _isBiometricAvailable && _hasCredentials) {
      await _authenticateWithBiometrics();
    }
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _saveCredentials() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha email e senha antes de habilitar a biometria';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('password', _passwordController.text.trim());
    setState(() {
      _hasCredentials = true;
    });
  }

  Future<void> _toggleBiometric(bool? value) async {
    if (value == null) return;

    final prefs = await SharedPreferences.getInstance();
    
    if (value) {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Faça login primeiro antes de habilitar a biometria';
        });
        return;
      }
      await _saveCredentials();
    } else {
      await prefs.remove('password');
      setState(() {
        _hasCredentials = false;
      });
    }

    await prefs.setBool('isBiometricEnabled', value);
    setState(() {
      _isBiometricEnabled = value;
      _errorMessage = '';
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      if (!_isBiometricAvailable) {
        setState(() {
          _errorMessage = 'Biometria não disponível neste dispositivo';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');

      if (savedEmail == null || savedPassword == null) {
        setState(() {
          _errorMessage = 'Credenciais não encontradas. Faça login primeiro';
          _hasCredentials = false;
        });
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentique-se para acessar o aplicativo',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        await _handleLogin(savedEmail, savedPassword);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro na autenticação biométrica: $e';
      });
    }
  }

  Future<void> _handleLogin([String? email, String? password]) async {
    if (!_formKey.currentState!.validate() && email == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userEmail = email ?? _emailController.text.trim();
      final userPassword = password ?? _passwordController.text.trim();

      final role = await _authController.signIn(userEmail, userPassword);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', userEmail);
      
      if (_isBiometricEnabled) {
        await prefs.setString('password', userPassword);
        setState(() {
          _hasCredentials = true;
        });
      }

      if (role == 'morador' || role == 'portaria') {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Usuário não reconhecido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Center(
                        child: Image.asset(
                          'assets/img/logo.png',
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Bem-vindo',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Faça login para continuar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: appLocalizations.translate('username'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: appLocalizations.translate('password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      if (_isBiometricAvailable) ...[
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Habilitar login com biometria'),
                          value: _isBiometricEnabled,
                          onChanged: _toggleBiometric,
                          secondary: const Icon(Icons.fingerprint),
                        ),
                      ],
                      const Spacer(),
                      if (_isBiometricEnabled && _hasCredentials && !_isLoading)
                        Center(
                          child: IconButton.filled(
                            icon: const Icon(Icons.fingerprint, size: 32),
                            onPressed: _authenticateWithBiometrics,
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _isLoading ? null : () => _handleLogin(),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                appLocalizations.translate('login_button'),
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
