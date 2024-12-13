import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_test/main.dart';
import 'package:rest_test/service.dart';
import 'package:http/http.dart' as http;
import 'header_provider.dart';
import 'request_body_provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/services.dart';

class Home extends ConsumerWidget {
  Home({Key? key}) : super(key: key);

  final TextEditingController url = TextEditingController();
  final TextEditingController fieldVal = TextEditingController();
  final TextEditingController fieldName = TextEditingController();
  final TextEditingController jsonBody = TextEditingController();
  final TextEditingController textBody = TextEditingController();

  final TextStyle ts = const TextStyle(fontSize: 20, fontWeight: FontWeight.w300, letterSpacing: 0.5);

  final ValueNotifier<RequestType> requestMethod = ValueNotifier<RequestType>(RequestType.get);
  
  final ValueNotifier<RequestBodyType> reqBodyType = ValueNotifier<RequestBodyType>(RequestBodyType.json) ;

  final ValueNotifier<http.Response?> response = ValueNotifier<http.Response?>(null);

  final ValueNotifier<ResponseType> resType = ValueNotifier<ResponseType>(ResponseType.text);
  
  Future<bool> sendRequest({
    required Map<String, String>? headers,
    required BuildContext context,
    required Map<String, String> formDataBody,
    required Map<String, String> files,
  }) async{
    if (readyToSendRequest(context)){
      try{

        Map<String, dynamic>? reqBody;
        if (jsonBody.text.trim().isNotEmpty){
          reqBody = jsonDecode(jsonBody.text.trim());
        }
        
        Service service;
        if (reqBodyType.value == RequestBodyType.json){
          service = Service(
            reqMethod: requestMethod.value,
            url: url.text.trim(),
            headers: headers,
            jsonBody: reqBody
          );
        }
        else if(reqBodyType.value == RequestBodyType.formData){
          service = Service(
            reqMethod: requestMethod.value,
            url: url.text.trim(),
            headers: headers,
            jsonBody: formDataBody,
            files: files,
          );
        }
        else {  // i.e. body type = text
          service = Service(
            reqMethod: requestMethod.value,
            url: url.text.trim(),
            headers: headers,
            textBody: textBody.text
          );
        }

        switch (requestMethod.value){

          case RequestType.get:
            response.value = await service.getRequest();
            return true;

          case RequestType.post:
            if (reqBodyType.value == RequestBodyType.json){
              response.value = await service.postRequest();
            }
            else if (reqBodyType.value == RequestBodyType.formData){
              response.value = await service.formDataRequest();
            }
            else {
              response.value = await service.postRequestTextBody();
            }
            return true;

          case RequestType.put:
            if (reqBodyType.value == RequestBodyType.json){
              response.value = await service.putRequest();
            }
            else if (reqBodyType.value == RequestBodyType.formData){
              response.value = await service.formDataRequest();
            }
            else {
              response.value = await service.putRequestTextBody();
            }
            return true;

          case RequestType.head:
            response.value = await service.headRequest();
            return true;

          case RequestType.delete:
            if (reqBodyType.value == RequestBodyType.json){
              response.value = await service.deleteRequest();
            }
            else if (reqBodyType.value == RequestBodyType.formData){
              response.value = await service.formDataRequest();
            }
            else {
              response.value = await service.deleteRequestTextBody();
            }
            return true;

          case RequestType.patch:
            if (reqBodyType.value == RequestBodyType.json){
              response.value = await service.patchRequest();
            }
            else if (reqBodyType.value == RequestBodyType.formData){
              response.value = await service.formDataRequest();
            }
            else {
              response.value = await service.patchRequestTextBody();
            }
            return true;
        }
      }catch(e){
        // log('ERROR: sending Request: ');
        log('home.dart > sendRequest(${requestMethod.value}): $e');
        response.value = null;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: Colors.red,
        ));
      }

    }
    return false;
  }

  bool readyToSendRequest(context) {
    if (url.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL is Required!!!'),
          backgroundColor: Colors.red,
        )
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Scrollbar(
          thumbVisibility: true,
          thickness: 20,
          trackVisibility: true,
          interactive: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left :10, right: 30, bottom: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        ValueListenableBuilder<RequestType>(
                            valueListenable: requestMethod,
                            builder: (context, request, _) {
                              return ColoredBox(
                                color: colors[request.index],//Theme.of(context).primaryColorLight,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: DropdownButton<RequestType>(
                                    value: request,
                                    onChanged: (val){
                                      if (val!= null){
                                        requestMethod.value = val;
                                      }
                                    },
                                    items: RequestType.values.map((e){
                                      return DropdownMenuItem<RequestType>(
                                        value: e,
                                        child: Text(requestMethods[e.index], style: ts),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }
                        ),

                        ElevatedButton.icon(
                          onPressed: ()async{
                            // SystemChannels.textInput.invokeMethod('TextInput.hide');

                            FocusScope.of(context).unfocus();

                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context){
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                            );

                            await sendRequest(
                              headers: ref.read(headersProvider.notifier).getHeader(),
                              context: context,
                              formDataBody: ref.read(formReqBodyProvider.notifier).getFields(),
                              files: ref.read(formReqBodyProvider.notifier).getFiles(),
                            ).whenComplete(() => navKey.currentState!.pop());

                            // if (response.value != null){
                            //   if (response.value!.statusCode != null){
                            //     log('STATUS CODE: ${response.value!.statusCode}');
                            //   }
                            //   if (response.value!.headers != null){
                            //     log('HEADER: ${response.value!.headers}');
                            //   }
                            //   if (response.value!.bodyBytes != null){
                            //     log('BODY SIZE: ${response.value!.bodyBytes.reduce((value, element) => value+element)}');
                            //   }
                            //   else {
                            //     log('BODY SIZE: 0');
                            //   }
                            //   if(response.value!.contentLength != null) {
                            //     log('CONTENT LENGTH : ${response.value!.contentLength}');
                            //   } else {
                            //     log('CONTENT LENGTH: 0');
                            //   }
                            //   if (response.value!.body != null) {
                            //     log('BODY: ${response.value!.body}');
                            //   }
                            // }
                          },
                          icon: const Icon(Icons.send,),
                          label: Text('SEND', style: ts),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: url,
                    style: ts,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'URL'
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 20,),
                  headerWidget(),
                  const SizedBox(height: 20,),
                  ValueListenableBuilder<RequestBodyType>(
                      valueListenable: reqBodyType,
                      builder:(context, rbt, _){
                        return Column(
                          children: [
                            Row(
                              children: [
                                Radio<RequestBodyType>(
                                  value: RequestBodyType.json,
                                  groupValue: rbt,
                                  onChanged: (val){
                                    if (val != null && reqBodyType.value != val){
                                      reqBodyType.value = val;
                                    }
                                  },
                                ),
                                Text(requestBodyTypes[RequestBodyType.json.index]),
                                const Spacer(),
                                Radio<RequestBodyType>(
                                  value: RequestBodyType.text,
                                  groupValue: rbt,
                                  onChanged: (val){
                                    if (val != null && reqBodyType.value != val){
                                      reqBodyType.value = val;
                                    }
                                  },
                                ),
                                Text(requestBodyTypes[RequestBodyType.text.index]),
                                const Spacer(),
                                Radio<RequestBodyType>(
                                  value: RequestBodyType.formData,
                                  groupValue: rbt,
                                  onChanged: (val){
                                    if (val != null && reqBodyType.value != val){
                                      reqBodyType.value = val;
                                    }
                                  },
                                ),
                                Text(requestBodyTypes[RequestBodyType.formData.index])
                              ],
                            ),
                            getReqBodyWidget(),
                          ],
                        );
                      }
                  ),

                  // jsonBodyWidget(),

                  responseWidget(),
                  const SizedBox(height: 100,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerWidget(){
    return Consumer(
        builder: (context, ref, _){
          final headers = ref.watch(headersProvider);
          return ColoredBox(
            color: Theme.of(context).primaryColorLight,//Colors.yellow,
            child: ExpandablePanel(
              header: ElevatedButton(
                onPressed: ()async{
                  fieldName.text = '';
                  fieldVal.text = '';
                  await keyValueDialog(context: context).then((kv){
                    if (kv.isNotEmpty){
                      ref.read(headersProvider.notifier).addField(
                          key: kv[0],
                          value: kv[1]
                      );
                    }
                  });
                },
                child: Text('ADD HEADER', style: ts),
              ),
              collapsed: const SizedBox.shrink(),
              expanded: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0 : FixedColumnWidth(30),
                  1 : FlexColumnWidth(),
                  2 : FixedColumnWidth(40),
                  3 : FixedColumnWidth(40)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: List.generate(
                  headers.length,
                      (index) {
                    return TableRow(
                        children: [
                          TableCell(
                            child: Checkbox(
                              value: headers[index].isEnabled,
                              activeColor: Colors.green,
                              onChanged: (b){
                                if (b!=null){
                                  ref.read(headersProvider.notifier).updateField(index);
                                }
                              },
                            ),
                          ),

                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText('KEY: ${headers[index].fieldName}', style: ts, ),
                                  SelectableText('VALUE: ${headers[index].fieldValue}', style: ts, ),
                                ],
                              ),
                            ),
                          ),

                          TableCell(
                            child: IconButton(
                              icon: const Icon(Icons.edit_note),
                              onPressed: ()async{
                                fieldName.text = headers[index].fieldName;
                                fieldVal.text = headers[index].fieldValue;
                                await keyValueDialog(context : context).then((kv){
                                  if (kv.isNotEmpty){
                                    ref.read(headersProvider.notifier).updateField(
                                        index,
                                        toggle: false,
                                        key: kv[0],
                                        value: kv[1]
                                    );
                                  }
                                });
                              },
                            ),
                          ),

                          TableCell(
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red,),
                                onPressed: (){
                                  ref.read(headersProvider.notifier).removeField(index);
                                },
                              )
                          )
                        ]
                    );
                  }),
              ),
            ),
          );
        }
    );
  }

  Widget getReqBodyWidget(){
    switch (reqBodyType.value){
      case RequestBodyType.json:
        return jsonBodyWidget();
      case RequestBodyType.text:
        return textBodyWidget();
      case RequestBodyType.formData:
        return formBodyWidget();
    }
  }

  Widget jsonBodyWidget(){
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 500.0,
      ),
      child: TextField(
        controller: jsonBody,
        style: ts,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'REQUEST BODY (JSON)'
        ),
        maxLines: null,
      ),
    );
  }
  
  Widget textBodyWidget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 500.0,
      ),
      child: TextField(
        controller: textBody,
        style: ts,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'REQUEST BODY (TEXT)',
          counter: ValueListenableBuilder(
            valueListenable: textBody,
            builder: (context, tb, _){
              return Text('BODY LENGTH: ${tb.text.length.toString()}');
            }
          ),
        ),
        maxLines: null,
      ),
    );
  }

  Widget formBodyWidget() {
    return Consumer(
        builder: (context, ref, _){
          final reqFormData = ref.watch(formReqBodyProvider);
          return ColoredBox(
            color: Theme.of(context).primaryColorLight,//Colors.yellow,
            child: ExpandablePanel(
              header: ElevatedButton(
                onPressed: ()async{
                  fieldName.text = '';
                  fieldVal.text = '';
                  await keyValueDialog(context: context, forFormDataBody: true).then((kv){
                    if (kv.isNotEmpty){
                      ref.read(formReqBodyProvider.notifier).addField(
                        key: kv[0],
                        value: kv[1],
                        isFile: kv[2] == 'FILE'
                      );
                    }
                  });
                },
                child: Text('ADD FIELDS', style: ts),
              ),
              collapsed: const SizedBox.shrink(),
              expanded: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0 : FixedColumnWidth(30),
                  1 : FlexColumnWidth(),
                  2 : FixedColumnWidth(40),
                  3 : FixedColumnWidth(40)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                children: List.generate(
                    reqFormData.length,
                        (index) {
                      return TableRow(
                          children: [
                            TableCell(
                              child: Checkbox(
                                value: reqFormData[index].isEnabled,
                                activeColor: Colors.green,
                                onChanged: (b){
                                  if (b!=null){
                                    ref.read(formReqBodyProvider.notifier).updateField(index);
                                  }
                                },
                              ),
                            ),

                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(reqFormData[index].isFile ? 'TYPE : FILE' : 'TYPE: TEXT', style: ts),
                                    SelectableText('KEY: ${reqFormData[index].fieldName}', style: ts, ),
                                    SelectableText('VALUE: ${reqFormData[index].fieldValue}', style: ts, ),
                                  ],
                                ),
                              ),
                            ),

                            TableCell(
                              child: IconButton(
                                icon: const Icon(Icons.edit_note),
                                onPressed: ()async{
                                  fieldName.text = reqFormData[index].fieldName;
                                  fieldVal.text = reqFormData[index].fieldValue;
                                  await keyValueDialog(
                                      context: context, 
                                      forFormDataBody: true,
                                      isFile: reqFormData[index].isFile
                                  ).then((kv){
                                    if (kv.isNotEmpty){
                                      ref.read(formReqBodyProvider.notifier).updateField(
                                          index,
                                          toggle: false,
                                          key: kv[0],
                                          value: kv[1]
                                      );
                                    }
                                  });
                                },
                              ),
                            ),

                            TableCell(
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red,),
                                  onPressed: (){
                                    ref.read(formReqBodyProvider.notifier).removeField(index);
                                  },
                                )
                            )
                          ]
                      );
                    }),
              ),
            ),
          );
        }
    );
  }

  Widget responseWidget() {
    return ValueListenableBuilder<http.Response?>(
        valueListenable: response,
        builder: (context, res, child){
          if (res == null){
            return const SizedBox.shrink();
          }
          return Container(
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESPONSE',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18,
                  ),
                ),
                  Text(
                  'STATUS CODE: ${response.value!.statusCode}',
                  style: ts,
                ),
                const Divider(color: Color(0xFF000000),),
                ExpandablePanel(
                  header: ColoredBox(
                    color: colors[4],
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'HEADERS',
                        style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  collapsed: Text(
                    response.value!.headers.toString(),
                    style: ts,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  expanded: Text(response.value!.headers.toString(), style: ts),
                ),
                const Divider(color: Color(0xFF000000),),
                if (response.value!.contentLength != null
                    && response.value!.contentLength != 0
                )
                  Text(
                    'BODY SIZE: ${response.value!.bodyBytes.reduce((value, element) => value+element)}',
                    style: ts,
                  ),
                const Divider(color: Color(0xFF000000),),
                if(response.value!.contentLength != null)
                  Text('CONTENT LENGTH : ${response.value!.contentLength}', style: ts)
                else
                  Text('CONTENT LENGTH : NULL)', style: ts)
                ,
                const Divider(color: Color(0xFF000000),),
                ExpandablePanel(
                  header: ColoredBox(
                    color: colors[3],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BODY',
                            style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.copy),
                            label: const Text('COPY'),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: resType.value == ResponseType.json
                                    ? makePrettyJSON(context: context, jsonString: response.value!.body)
                                    : response.value!.body
                                )
                              ).whenComplete(() {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Response body text copied'),)
                                );
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  collapsed: Text(
                    response.value!.body,
                    style: ts,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  expanded: ValueListenableBuilder<ResponseType>(
                      valueListenable: resType,
                      builder : (context, resTp , _){
                        return Column(
                            children:[
                              ColoredBox(
                                color: const Color(0x66BB8844),
                                child: Row(
                                  children: [
                                    Radio(
                                      value: ResponseType.text,
                                      groupValue: resTp,
                                      onChanged: (t){
                                        if (t != null){
                                          resType.value = t;
                                        }
                                      },
                                    ),
                                    const Text('TEXT'),
                                    const Spacer(),
                                    Radio(
                                      value: ResponseType.json,
                                      groupValue: resTp,
                                      onChanged: (t){
                                        if (t != null){
                                          resType.value = t;
                                        }
                                      },
                                    ),
                                    const Text('JSON'),
                                    const Spacer(),
                                    Radio(
                                      value: ResponseType.html,
                                      groupValue: resTp,
                                      onChanged: (t){
                                        if (t != null){
                                          resType.value = t;
                                        }
                                      },
                                    ),
                                    const Text('HTML'),
                                    const Spacer(),
                                  ],
                                ),

                              ),

                              if (resTp == ResponseType.text)
                                SelectableText(
                                  response.value!.body,
                                  style : ts,
                                  selectionHeightStyle: BoxHeightStyle.max,
                                  selectionWidthStyle: BoxWidthStyle.tight,
                                ),

                              if (resTp == ResponseType.html)
                                HtmlWidget(response.value!.body),

                              if (resTp == ResponseType.json)
                                SelectableText(
                                  makePrettyJSON(context: context, jsonString: response.value!.body),
                                  style: ts,
                                  selectionWidthStyle: BoxWidthStyle.tight,
                                  selectionHeightStyle: BoxHeightStyle.max,
                                )

                            ]
                        );
                      }
                  ),
                ),

              ]
            ),
          );
        }
    );
  }

  Future<List<String>> keyValueDialog({
    required BuildContext context,
    bool forFormDataBody = false,
    bool isFile = false,
  })async{

    /*
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
    } else {
      // User canceled the picker
    }
    *

     */
    

    List<String> keyValue = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(forFormDataBody ? 'ADD FIELD' : 'ADD HEADER'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (forFormDataBody)
                      Row(
                        children: [
                          Text('Input Type: ', style : ts),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: (){
                              setDialogState((){
                                isFile = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: !isFile ? const Color(0xFF000000) : const Color(0xFF888888)
                            ),
                            child: Text('TEXT', style: isFile ? ts : ts.copyWith(color: const Color(0xFFFFFFFF))),
                          ),
                          ElevatedButton(
                            onPressed: (){
                              setDialogState((){
                                fieldVal.text = '';
                                isFile = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFile ? const Color(0xFF000000) : const Color(0xFF888888)
                            ),
                            child: Text('FILE', style: isFile ? ts.copyWith(color: const Color(0xFFFFFFFF)) : ts ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20,),
                    TextField(
                      controller: fieldName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'KEY'
                      ),
                      style: ts,
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      readOnly: forFormDataBody && isFile,
                      onTap: ()async{

                        if (forFormDataBody && isFile) {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            fieldVal.text = result.files.single.path!;
                            // file = File(result.files.single.path!);
                          } else {
                            // User canceled the picker
                          }
                        }
                      },
                      controller: fieldVal,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'VALUE'
                      ),
                      style: ts,
                      maxLines: null,
                    ),
                  ],
                ),
              );
            }
          ),
          actions: [
            ElevatedButton(
              onPressed: (){
                navKey.currentState!.pop();
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: (){
                if (fieldName.text.trim().isNotEmpty && fieldVal.text.trim().isNotEmpty){
                  navKey.currentState!.pop([
                    fieldName.text.trim(),
                    fieldVal.text.trim(),
                    forFormDataBody && isFile ? 'FILE': 'TEXT'
                  ]);
                } else {
                  navKey.currentState!.pop();
                }
              },
              child: const Text('CONFIRM'),
            ),
          ],
        );
      }
    )??<String>[];
    return keyValue;
  }

  String makePrettyJSON({required BuildContext context, required String jsonString}){
    String err = '';
    try{
      var encoder = const JsonEncoder.withIndent("     ");
      return encoder.convert(jsonDecode(jsonString));
    } catch(e){
      err = e.toString();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor : Colors.red,
            )
        );
      });

    }
    return 'Body could not be converted to JSON due to Improper Formatting.\nError : $err';

  }
}