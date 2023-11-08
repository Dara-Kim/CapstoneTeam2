import 'package:flutter/material.dart';
import 'dart:convert';

class ResultScreen extends StatelessWidget {
  final String responseBody;
  final String selectedapkfilename;
  ResultScreen({Key? key, required this.responseBody, required this.selectedapkfilename}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String result = extractProbability(responseBody);

    return Scaffold(
        appBar: AppBar(
          title: Text('결과화면'),
          centerTitle: true,
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      width: 370,
                      height: 370,
                      child: Center(
                        child: Text("$result%", style: TextStyle(fontSize: 90),),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(900),
                          border: Border.all(color: Colors.black12, width: 3))
                    ),
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(10.0),
                    width: 380,
                    height: 200,
                    decoration: BoxDecoration(
                      border:Border.all(),
                    ),
                    child: Column(
                        children: [
                          Text('선택한 파일', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('$selectedapkfilename', style: TextStyle(fontSize: 20)),
                          Text(''),
                          Text('*유의사항*', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('악성 앱을 분류하는 과정에서 ±5%의 오차범위를 고려하여 탐지 결과 확률이 45%이상일 때 ', style: TextStyle(
                              fontSize: 13))
                        ]
                    ),
                  ),
                ]
            )
        )
    );
  }

  String extractProbability(String responseBody) {
    final Map<String, dynamic> json = jsonDecode(responseBody);
    final String probabilityString = json['probability'].toString();
    final String probability = double.parse(probabilityString).toStringAsFixed(0);
    return probability;
  }
}
