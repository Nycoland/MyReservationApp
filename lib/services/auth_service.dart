import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_reservation_app/models/user.dart';

class AuthService {
  static const String _usersKey = 'users_database';
  static const String _currentUserKey = 'current_user_id';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ============================================================================
  // USER REGISTRATION
  // ============================================================================

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await _initPrefs();

    try {
      // Validate inputs
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Por favor, preencha todos os campos',
        };
      }

      if (!email.contains('@')) {
        return {
          'success': false,
          'message': 'Email inválido. Por favor, insira um email válido',
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'A senha deve ter pelo menos 6 caracteres',
        };
      }

      // Check if email already exists
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        return {
          'success': false,
          'message':
              'Este e-mail já está cadastrado. Por favor, faça login ou use outro e-mail',
        };
      }

      // Create new user
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final functionalId =
          'EMP${DateTime.now().millisecondsSinceEpoch % 10000}';

      final newUser = User(
        id: userId,
        name: name,
        email: email,
        phone: '',
        department: 'Tecnologia & Inovação',
        functionalId: functionalId,
        status: 'Ativo',
        passwordHash: password, // In production, use proper hashing
      );

      // Save user to database
      await _saveUser(newUser);

      return {
        'success': true,
        'message': 'Conta criada com sucesso!',
        'user': newUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao criar conta. Tente novamente.',
      };
    }
  }

  // ============================================================================
  // USER LOGIN
  // ============================================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await _initPrefs();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Por favor, preencha todos os campos',
        };
      }

      if (!email.contains('@')) {
        return {
          'success': false,
          'message': 'Email inválido. Por favor, insira um email válido',
        };
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user by email
      final user = await _getUserByEmail(email);

      if (user == null) {
        return {
          'success': false,
          'message':
              'E-mail não cadastrado. Por favor, crie uma conta primeiro.',
        };
      }

      // Verify password
      if (user.passwordHash != password) {
        return {
          'success': false,
          'message':
              'Senha incorreta. Por favor, verifique sua senha e tente novamente.',
        };
      }

      // Save current user session
      await _prefs!.setString(_currentUserKey, user.id);

      return {'success': true, 'message': 'Login bem-sucedido!', 'user': user};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão. Verifique sua internet e tente novamente',
      };
    }
  }

  // ============================================================================
  // USER LOGOUT
  // ============================================================================

  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.remove(_currentUserKey);
  }

  // ============================================================================
  // GET CURRENT USER
  // ============================================================================

  Future<User?> getCurrentUser() async {
    await _initPrefs();
    final userId = _prefs!.getString(_currentUserKey);

    if (userId == null) return null;

    return await _getUserById(userId);
  }

  // ============================================================================
  // CHECK IF USER IS LOGGED IN
  // ============================================================================

  Future<bool> isLoggedIn() async {
    await _initPrefs();
    return _prefs!.containsKey(_currentUserKey);
  }

  // ============================================================================
  // PASSWORD RESET
  // ============================================================================

  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    await _initPrefs();

    try {
      if (email.isEmpty) {
        return {
          'success': false,
          'message': 'Por favor, digite seu e-mail no campo acima',
        };
      }

      if (!email.contains('@')) {
        return {
          'success': false,
          'message': 'Email inválido. Por favor, insira um email válido',
        };
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Check if user exists (for demo, we'll say it worked either way)
      final user = await _getUserByEmail(email);

      return {
        'success': true,
        'message':
            'Se o e-mail for válido e estiver cadastrado na instituição, você receberá um código para redefinição de senha',
        'userExists': user != null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao processar solicitação. Tente novamente.',
      };
    }
  }

  // ============================================================================
  // UPDATE USER
  // ============================================================================

  Future<bool> updateUser(User updatedUser) async {
    await _initPrefs();

    try {
      final users = await _getAllUsers();

      // Check if user exists
      if (!users.containsKey(updatedUser.id)) {
        return false;
      }

      // Update user in database
      users[updatedUser.id] = updatedUser.toJson();

      final usersJson = jsonEncode(users);
      await _prefs!.setString(_usersKey, usersJson);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  Future<void> _saveUser(User user) async {
    final users = await _getAllUsers();
    users[user.id] = user.toJson();

    final usersJson = jsonEncode(users);
    await _prefs!.setString(_usersKey, usersJson);
  }

  Future<Map<String, dynamic>> _getAllUsers() async {
    final usersJson = _prefs!.getString(_usersKey);
    if (usersJson == null) return {};

    return Map<String, dynamic>.from(jsonDecode(usersJson));
  }

  Future<User?> _getUserById(String id) async {
    final users = await _getAllUsers();
    final userData = users[id];

    if (userData == null) return null;

    return User.fromJson(Map<String, dynamic>.from(userData));
  }

  Future<User?> _getUserByEmail(String email) async {
    final users = await _getAllUsers();

    for (final userData in users.values) {
      final user = User.fromJson(Map<String, dynamic>.from(userData));
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }

    return null;
  }

  // ============================================================================
  // CLEAR ALL DATA (for testing/demo reset)
  // ============================================================================

  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs!.remove(_usersKey);
    await _prefs!.remove(_currentUserKey);
  }
}
