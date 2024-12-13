class KeyValueFieldModel{
  final String fieldName;
  final String fieldValue;
  final bool isFile;
  final bool isEnabled;

  const KeyValueFieldModel({required this.fieldName, required this.fieldValue, this.isFile = false, required this.isEnabled});
}