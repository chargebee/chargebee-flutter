import 'package:flutter/services.dart';

class CBException {
  String errorCode;
  String? message;
  String details;

  CBException(this.errorCode, this.message, this.details);

  @override
  String toString() => 'CBException($errorCode, $message, $details)';
}
