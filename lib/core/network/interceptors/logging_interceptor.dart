import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' show log;

/// Interceptor for logging requests, responses, and errors
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final method = options.method.toUpperCase();
      final url = options.uri.toString();

      log('\n--> $method $url');

      if (options.headers.isNotEmpty) {
        log('Headers:');
        options.headers.forEach((key, value) => log('$key: $value'));
      }

      if (options.data != null) {
        log('Request Body:');
        _prettyPrintJson(options.data);
      }

      if (options.queryParameters.isNotEmpty) {
        log('Query Parameters:');
        options.queryParameters.forEach((key, value) => log('$key: $value'));
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final statusCode = response.statusCode;
      final method = response.requestOptions.method.toUpperCase();
      final url = response.requestOptions.uri.toString();

      log('\n<-- $statusCode $method $url');

      if (response.headers.map.isNotEmpty) {
        log('Headers:');
        response.headers
            .forEach((name, values) => log('$name: ${values.join(',')}'));
      }

      log('Response Body:');
      _prettyPrintJson(response.data);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final statusCode = err.response?.statusCode;
      final method = err.requestOptions.method.toUpperCase();
      final url = err.requestOptions.uri.toString();

      log('\n<-- Error $statusCode $method $url');
      log('Error: ${err.error}');

      if (err.response != null) {
        log('Response Body:');
        _prettyPrintJson(err.response!.data);
      }
    }

    super.onError(err, handler);
  }

  /// Helper method to pretty print JSON data
  void _prettyPrintJson(dynamic data) {
    if (data == null) {
      log('null');
      return;
    }

    if (data is Map || data is List) {
      try {
        // Try to use json.encode for nice formatting
        // but this might not work for all data types
        log(data.toString());
      } catch (e) {
        log(data.toString());
      }
    } else {
      log(data.toString());
    }
  }
}
