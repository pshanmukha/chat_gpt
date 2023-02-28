import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/services/api_service.dart';
import 'package:flutter/material.dart';

class ModelsProvider with ChangeNotifier {
  List<ModelsModel> _modelsLIst = [];
  List<ModelsModel> get getModelsList => _modelsLIst;

  String currentModel = "text-davinci-003";
  String get getCurrentModel => currentModel;

  void setCurrentModel(String newModel) {
    currentModel = newModel;
    ChangeNotifier();
  }

  Future<List<ModelsModel>> getAllModels() async {
    _modelsLIst = await ApiServices.getModels();
    return _modelsLIst;
  }
}
