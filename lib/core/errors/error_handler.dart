import 'package:supabase_flutter/supabase_flutter.dart';

/// Nunca renderizar `e.toString()` cru na UI — traduz erros conhecidos do
/// Supabase Auth para mensagens em pt-BR, com fallback genérico.
class ErrorHandler {
  ErrorHandler._();

  static String parse(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login credentials')) {
        return 'E-mail ou senha incorretos.';
      }
      if (message.contains('user already registered')) {
        return 'Já existe uma conta com esse e-mail.';
      }
      if (message.contains('password should be at least')) {
        return 'A senha precisa ter pelo menos 6 caracteres.';
      }
      if (message.contains('unable to validate email')) {
        return 'E-mail inválido.';
      }
      return 'Não foi possível concluir. Tente novamente.';
    }
    return 'Algo deu errado. Verifique sua conexão e tente novamente.';
  }
}
