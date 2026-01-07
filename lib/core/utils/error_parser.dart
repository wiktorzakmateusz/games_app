import 'package:http/http.dart' as http;
import 'dart:convert';

class ErrorParser {
  static String parseErrorMessage(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return 'Unknown error occurred';
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      
      if (jsonData.containsKey('message')) {
        final message = jsonData['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
      
      if (jsonData.containsKey('error')) {
        final error = jsonData['error'];
        if (error is String && error.isNotEmpty) {
          return error;
        }
        if (error is Map && error.containsKey('message')) {
          final errorMessage = error['message'];
          if (errorMessage is String && errorMessage.isNotEmpty) {
            return errorMessage;
          }
        }
      }
    } catch (e) {
    }
    
    return response.body.isNotEmpty ? response.body : 'Unknown error occurred';
  }
}

