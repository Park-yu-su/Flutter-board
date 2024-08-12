//firebase 관련 기능을 수행하는 함수

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'board_content.dart';
import 'dart:io';

//firestore에 이미지를 선택하고 저장한 뒤 해당 이미지 주소를 리턴하는 함수
Future<String> pickAndUploadImage(String email) async {
  final ImagePicker picker = ImagePicker();
  //갤러리에서 이미지 선택
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    File imageFile = File(image.path);

    try {
      //이미지에 업로드할 이름 정하기
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';

      // firebase stoarge에 이미지 업로드
      Reference ref =
          FirebaseStorage.instance.ref().child('user_icon').child(fileName);
      await ref.putFile(imageFile);

      // 업로드한 이미지 URL 가져오기
      String downloadURL = await ref.getDownloadURL();

      // Firestore에 있는 유저의 정보에 URL 이미지 정보 업데이트
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('user')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'userIconImage': downloadURL,
          });
        }
      } else {
        print('No documents in database');
        return "";
      }

      return downloadURL;
    } catch (e) {
      return "";
    }
  }
  return "";
}

void addUserInfoToFirestore(String _username, String _email) async {
  await FirebaseFirestore.instance.collection('user').add({
    'username': _username,
    'email': _email,
  });
}

Future<Map<String, dynamic>?> getUserInfoFromFirestore(String email) async {
  Map<String, dynamic>? user;

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('user').get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    if (data['email'] == email) {
      user = data;
      break;
    }
  }

  return user;
}

Future<List<Map<String, dynamic>>> getBoardFromFirestore(int mode) async {
  List<Map<String, dynamic>> boardList;
  try {
    QuerySnapshot querySnapshot;

    switch (mode) {
      case 1:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .get();
        break;

      case 2:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .where('attribute', isEqualTo: "공지")
            .get();
        break;

      case 3:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .where('attribute', isEqualTo: "정보")
            .get();
        break;

      case 4:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .where('attribute', isEqualTo: "잡담")
            .get();
        break;

      default:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .get();
    }

    boardList = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  } catch (e) {
    print(e);
    return [];
  }

  return boardList;
}

void addContentToFirestore(BoardContent content) async {
  await FirebaseFirestore.instance.collection('board').add({
    'attribute': content.attribute,
    'author': content.author,
    'content': content.content,
    'title': content.title,
    'time': Timestamp.fromDate(content.time),
    'watch': content.watch,
    'comments': content.comments,
    'id': content.id,
  });

  print('add OK ${content.time}\n ${content.id}');
}

void updateContentToFirestore(BoardContent content) async {
  //class에 존재하는 필드값을 토대로 해당 문서를 찾고 이를 업데이트
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore
      .collection('board')
      .where('id', isEqualTo: content.id)
      .where('title', isEqualTo: content.title)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'attribute': content.attribute,
        'author': content.author,
        'content': content.content,
        'title': content.title,
        'time': Timestamp.fromDate(content.time),
        'watch': content.watch,
        'comments': content.comments,
        'id': content.id,
      });
    }
  } else {
    print('No documents in database');
  }
}
