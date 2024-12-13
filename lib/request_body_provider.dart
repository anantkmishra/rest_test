import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_test/models/key_value_field_model.dart';

final formReqBodyProvider = StateNotifierProvider<FormReqBodyNotifier, List<KeyValueFieldModel>>((ref) {
  return FormReqBodyNotifier();
});

class FormReqBodyNotifier extends StateNotifier<List<KeyValueFieldModel>>{
  FormReqBodyNotifier() : super(<KeyValueFieldModel>[]);

  void updateField(int field, {bool toggle = true, String? key, String? value, bool isFile = false}){
    KeyValueFieldModel newField = KeyValueFieldModel(
      fieldName: toggle ? state[field].fieldName : key!,
      fieldValue: toggle ? state[field].fieldValue : value!,
      isEnabled: toggle ? !state[field].isEnabled : true,
      isFile: toggle ? state[field].isFile : isFile,
    );

    List<KeyValueFieldModel> fields = <KeyValueFieldModel>[];

    for (KeyValueFieldModel h in state){
      if (h != state[field]){
        fields.add(h);
      } else {
        fields.add(newField);
      }
    }

    state = fields;
  }

  void addField({required String key,required String value, required bool isFile}){
    KeyValueFieldModel field = KeyValueFieldModel(
      fieldName: key,
      fieldValue: value,
      isFile: isFile,
      isEnabled: true,
    );
    state = [...state, field];
  }

  void removeField(int field){
    if (field != 0 && field != state.length - 1){
      state = state.sublist(0,field) + state.sublist(field+1);
    } else if (field == 0){
      state = state.sublist(1);
    } else if (field == state.length - 1){
      state = state.sublist(0, state.length-1);
    }
  }

  Map<String,String> getFields(){
    Map<String,String> fields = {};
    for (KeyValueFieldModel field in state){
      if (field.isEnabled && !field.isFile){
        fields[field.fieldName] = field.fieldValue;
      }
    }
    return fields;
  }

  Map<String,String> getFiles(){
    Map<String,String> files = {};
    for (KeyValueFieldModel field in state){
      if (field.isEnabled && field.isFile){
        files[field.fieldName] = field.fieldValue;
      }
    }
    return files;
  }
}