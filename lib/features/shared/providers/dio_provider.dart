import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/constants/dio.dart';
import 'package:dio/dio.dart';

final dioProvider = Provider<Dio>((ref) {
  // Enable logging only in debug/profile modes, disabled in release for performance and security.
  return DioFactory.create(enableLogging: !kReleaseMode);
});
