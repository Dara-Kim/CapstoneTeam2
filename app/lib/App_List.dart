import 'package:flutter/material.dart';
import 'result.dart';
import 'package:external_path/external_path.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

var indexselectedfile;
var getpath;
bool modelload_check = false;
bool buttonselected = false;

class IsLoadingController extends GetxController {
  static IsLoadingController get to => Get.find();

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;
  void setIsLoading(bool value) => _isLoading.value = value;
}

// To get public storage directory path
// 다운로드 폴더 경로 가져오기
Future<String> getPath() async {
  var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
  getpath = path;
  return path;
  print(path);
  // /storage/emulated/0/Download
}

Future<List<File>> getExternalStorageApkFiles() async {
  final directoryPath = getpath;
  final directory = Directory(directoryPath);
  final List<FileSystemEntity> files = directory.listSync();
  final listapkfiles = files.where((file) => file.path.endsWith('.apk'));
  final List<File> apkFiles = listapkfiles.map((file) => File(file.path)).toList();
  return apkFiles;
}

Future<List<String>> getExternalStorageApkFileNames() async {
  final directoryPath = await getPath();
  final directory = Directory(directoryPath);
  final List<FileSystemEntity> files = directory.listSync();
  final apkFiles = files.where((file) => file.path.endsWith('.apk'));
  final apkFileNames = apkFiles.map((file) => path.basename(file.path)).toList();
  return apkFileNames;
}

class AppListScreen extends StatefulWidget {
  AppListScreen({Key? key}) : super(key: key);

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

Future<File> selectedapkfile() async {
  List<File> apkfiles;
  apkfiles = await getExternalStorageApkFiles();
  int selectedFileIndex = indexselectedfile as int;
  File apkfile = apkfiles[selectedFileIndex];
  return apkfile;
}

File changeFileExtension(File file, String newExtension) {
  String filePath = file.path;
  String newFilePath = filePath.substring(0, filePath.lastIndexOf('.')) + newExtension;
  return File(newFilePath);
}

Future<void> modelload() async {
  var url_model = Uri.parse('http://220.149.236.78:5000/model');
  var response = await http.post(url_model);

  if (response.statusCode == 200) {
    // 요청이 성공적으로 처리됨
    print('요청이 성공적으로 처리되었습니다.');
    modelload_check = true;
  } else {
    // 요청이 실패함
    print('요청이 실패했습니다. 상태 코드: ${response.statusCode}');
  }
}

void uploadApkFile(final apkFile, BuildContext context, List<String> data) async {
  var url = Uri.parse('http://220.149.236.78:5000/down');  // 업로드할 서버의 URL
  // http://220.149.236.78:5000/down
  var request = http.MultipartRequest('POST', url);
  String selectedapkfilename = data[indexselectedfile];
  request.files.add(await http.MultipartFile.fromPath("file", apkFile.path));

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      // 업로드가 성공적으로 완료되었을 때의 동작을 구현합니다.
      IsLoadingController.to.isLoading = false;
      print('업로드 성공');
      var responseBody = await response.stream.bytesToString();
      print('응답 데이터: $responseBody');
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(responseBody: responseBody, selectedapkfilename: selectedapkfilename)),);
    } else {
      // 업로드가 실패했을 때의 동작을 구현합니다.
      print('업로드 실패: ${response.statusCode}');
      IsLoadingController.to.isLoading = false;
    }
  } catch (e) {
    // 예외 처리를 수행합니다.
    print('업로드 오류: $e');
    IsLoadingController.to.isLoading = false;
  }
}

class _AppListScreenState extends State<AppListScreen> {
  late List<String> data;
  late final apkFile;
  late final bytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Text('선택'),
          onPressed: () async {
            IsLoadingController.to.isLoading = true;
            if(buttonselected) {
              final apkFile = await selectedapkfile();
              if(!modelload_check) {
                await modelload(); // Model Load
                }
              uploadApkFile(apkFile, context, data); // apk파일 전송
            }
            else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('파일을 선택하세요'),
                    content: Text('파일을 선택해야합니다.'),
                    actions: [
                      ElevatedButton(
                        child: Text('확인'),
                        onPressed: () {
                          IsLoadingController.to.isLoading = false;
                          Navigator.pop(context);
                         },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
        appBar: AppBar(
          title: Text('목록'),
          centerTitle: true,
        ),

        body: Stack(
          children: [
            FutureBuilder(
              future: appname(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                }
                else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                }
                else {
                  data = snapshot.data;
                  return AppList(data: data);
                }
                },
            ),
            Obx(//isLoading(obs)가 변경되면 다시 그림.
                  () => Offstage(
                    offstage: !IsLoadingController.to.isLoading,
                    child: Stack(children: const <Widget>[
                      Opacity(
                        opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black),//클릭 못하게~
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                  ),
                ]),
              ),
            ),
          ],
        ),
    );
  }
  Future<List<String>> appname() async {
    await Future.delayed(Duration(seconds: 2));
    List<String> appnames = await getExternalStorageApkFileNames();
    return appnames;
  }
  Future<String> readFileAsString(File file) async {
    final bytes = await file.readAsBytes();
    final contents = String.fromCharCodes(bytes);
    return contents;
  }
}

class AppList extends StatefulWidget {
  final List<String> data;
  const AppList({Key? key, required this.data}) : super(key: key);

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  late List<bool> _isChecked;
  int? selectedValue;

  void initState() {
    super.initState();
    _isChecked = List.generate(widget.data.length, (index) => false);
    selectedValue = null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (c  , i){
        return ListTile(
          title: Text(widget.data[i]),
          leading: Radio(
            value: i, // 각 버튼에 해당하는 고유한 값
            groupValue: selectedValue,    // 초기에 선택되지 않음
            onChanged: (int? value) {
              setState(() {
                selectedValue = value;
                indexselectedfile = value; // 전역변수에 선택된 파일의 번호 저장
                buttonselected = true;
              });
            },
          ),
        );
      },
    );
  }
}