import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_test/models/key_value_field_model.dart';

final headersProvider = StateNotifierProvider<HeadersNotifier, List<KeyValueFieldModel>>((ref) {
  return HeadersNotifier();
});

class HeadersNotifier extends StateNotifier<List<KeyValueFieldModel>>{
  HeadersNotifier() : super(<KeyValueFieldModel>[]);

  void updateField(int field, {bool toggle = true, String? key, String? value}){
    KeyValueFieldModel newField = KeyValueFieldModel(
        fieldName: toggle ? state[field].fieldName : key!,
        fieldValue: toggle ? state[field].fieldValue : value!,
        isEnabled: toggle ? !state[field].isEnabled : true
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

  void addField({required String key,required String value}){
    KeyValueFieldModel field = KeyValueFieldModel(
      fieldName: key,
      fieldValue: value,
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

  Map<String,String> getHeader(){
    Map<String,String> headers = {};
    for (KeyValueFieldModel field in state){
      if (field.isEnabled){
        headers[field.fieldName] = field.fieldValue;
      }
    }
    return headers;
  }
}