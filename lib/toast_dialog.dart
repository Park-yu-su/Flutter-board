import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//toast message 출력(중앙 하단)
//fToast : FToast 객체 / content : toastmessage에 출력할 내용
void showToastmessage(FToast fToast, String content) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey,
    ),
    child: Text(
      content,
      style: const TextStyle(
          fontSize: 15, color: Colors.black, fontFamily: "MaplestoryLight"),
    ),
  );

  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 1),
  );
}

void showContextDialog(
    BuildContext context, String titleMessage, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titleMessage),
        content: Text(message),
        actions: <Widget>[
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ),
        ],
      );
    },
  );
}

//에러 dialog 창 출력
//context: build시 사용한 BuildContext context / message: 출력할 메시지 / e : 에러 내용
void showErrorDialog(BuildContext context, String message, Object e) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Fail : $message'),
        content: const Text('Sorry!'),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$e',
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
