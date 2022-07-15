
class CBException implements Exception {

  /// An error code.
  final String code;

  /// A human-readable error message, possibly null.
  final String message;

  CBException({
    required this.code,
    required this.message
  });

  @override
  String toString() => 'CBException($code, $message)';
}
