class EmergencyException implements Exception {
  final String message;
  final String? code;

  const EmergencyException(this.message, {this.code});

  @override
  String toString() => 'EmergencyException: $message ${code != null ? '($code)' : ''}';
}

class EmergencyNotFoundException extends EmergencyException {
  const EmergencyNotFoundException([super.message = 'Emergency request not found']) 
      : super(code: 'NOT_FOUND');
}

class InvalidTransitionException extends EmergencyException {
  const InvalidTransitionException([super.message = 'Invalid state transition for emergency request']) 
      : super(code: 'INVALID_TRANSITION');
}

class RequestExpiredException extends EmergencyException {
  const RequestExpiredException([super.message = 'The emergency request has expired or was cancelled']) 
      : super(code: 'REQUEST_EXPIRED');
}

class AuthorizationException extends EmergencyException {
  const AuthorizationException([super.message = 'You are not authorized to perform this action']) 
      : super(code: 'UNAUTHORIZED');
}
