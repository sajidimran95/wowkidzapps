enum AuthStatus { success, needsVerification, error }

class AuthResult {
  const AuthResult({
    required this.status,
    this.message,
    this.contact,
  });

  const AuthResult.success() : this(status: AuthStatus.success);
  const AuthResult.needsVerification(String contact)
      : this(status: AuthStatus.needsVerification, contact: contact);
  const AuthResult.error(String message)
      : this(status: AuthStatus.error, message: message);

  final AuthStatus status;
  final String? message;
  final String? contact;

  bool get isSuccess => status == AuthStatus.success;
  bool get needsVerification => status == AuthStatus.needsVerification;
}
