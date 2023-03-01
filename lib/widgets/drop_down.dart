import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/providers/models_provider.dart';
import 'package:chat_gpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ModelsDropDownWidget extends StatefulWidget {
  const ModelsDropDownWidget({Key? key}) : super(key: key);

  @override
  State<ModelsDropDownWidget> createState() => _ModelsDropDownWidgetState();
}

class _ModelsDropDownWidgetState extends State<ModelsDropDownWidget> {
  String? currentModels;
  late final modelsProvider;
  late final models;
  
  @override
  void didChangeDependencies() {
    modelsProvider = Provider.of<ModelsProvider>(context, listen: false);
    models = modelsProvider.getAllModels();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final modelsProvider = Provider.of<ModelsProvider>(context, listen: false);
    currentModels = modelsProvider.getCurrentModel;
    //final models = modelsProvider.getAllModels();
    return FutureBuilder(
        future: models,
        builder:
            (BuildContext context, AsyncSnapshot<List<ModelsModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 24.0,
              width: 28.0,
              child: SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: TextWidget(
                  label: snapshot.error.toString(),
                ),
              );
            }
            return snapshot.data == null || snapshot.data!.isEmpty
                ? const SizedBox.shrink()
                : FittedBox(
                    child: DropdownButton<String>(
                      dropdownColor: scaffoldBackgroundColor,
                      iconEnabledColor: Colors.white,
                      items: List<DropdownMenuItem<String>>.generate(
                          snapshot.data!.length,
                          (index) => DropdownMenuItem(
                                value: snapshot.data![index].id,
                                child: TextWidget(
                                  label: snapshot.data![index].id,
                                  fontSize: 15,
                                ),
                              )),
                      value: currentModels,
                      onChanged: (value) {
                        setState(() {
                          currentModels = value.toString();
                        });
                        modelsProvider.setCurrentModel(value.toString());
                      },
                    ),
                  );
          }
        });
  }
}
