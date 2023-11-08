import 'package:flutter/material.dart';
import 'App_List.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Text('Hello World'),
      ),
    );
  }
}

void main() {
  Get.put(IsLoadingController());
  runApp(
      MaterialApp(
          home: DetectionApp()
      )
  );
}

class DetectionApp extends StatelessWidget {
  const DetectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 400,
              height: 300,
              child: Center(
                child: Text('Z-tecting', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 80),),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppListScreen()),
                );
              },
              child: Text("시작하기",
                  style: TextStyle(fontSize: 30)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
                children:[
                  Text('50% 이상: Malware 앱으로 탐지'),
                  Text('50% 미만: Benign 앱으로 탐지')
                ],
            ),
          ],
        ),
      ),
    );
  }
}

