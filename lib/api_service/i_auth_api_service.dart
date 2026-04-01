import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_practice/models/error_response.dart';
import 'package:riverpod_practice/models/login_response.dart';


abstract class AuthApiService {
  AuthApiService() {
    client.interceptors.add(
      // Logging interceptor //
      AwesomeDioInterceptor(
        // Disabling headers and timeout would minimize the logging output.
        // Optional, defaults to true
        logRequestTimeout: false,
        logRequestHeaders: true,
        logResponseHeaders: true,

        // Optional, defaults to the 'log' function in the 'dart:developer' package.
        logger: debugPrint,
      ),
    );
  }
  Dio client = Dio(BaseOptions(
      baseUrl: "https://dummyjson.com",
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      responseType: ResponseType.json,
      contentType: "application/json"));

  Future<Either<ErrorResponse, LoginResponse>> login(
      {required String userName, required String password});
}
