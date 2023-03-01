import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/services/api_consts.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      List temp = [];
      for (var value in jsonResponse['data']) {
        temp.add(value);
      }

      return ModelsModel.modelsFromSnapshot(temp);
    } catch (err) {
      rethrow;
    }
  }

  static Future<List<ChatModel>> getMessage(
      {required String message, required String modelId}) async {
    try {
      var response = await http.post(
        Uri.parse("$BASE_URL/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "model": modelId,
          "prompt": message,
          "max_tokens": 100,
        }),
      );
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
       chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
              msg: jsonResponse["choices"][index]["text"], chatIndex: 1),
        );
      }
      return chatList;
    } catch (err) {
      rethrow;
    }
  }
}
