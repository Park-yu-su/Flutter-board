import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'toast_dialog.dart';
import 'firestore.dart';
import 'package:provider/provider.dart';
import 'user_status.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSU게더',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MypageScreen(),
    );
  }
}

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  _MypageScreenState createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final _auth = FirebaseAuth.instance;

  bool loginCheck = false;

  String email = '';
  String password = '';
  String username = '';

  String userImageUrl = '';
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    username = '';
    loginCheck = false;
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    var userStatus = Provider.of<UserStatus>(context);
    loginCheck = userStatus.loginCheck;
    username = userStatus.username;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              //로그인 체크
              loginCheck
                  ? Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: null,
                          child: Icon(
                            Icons.person_4_outlined,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          username,
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontFamily: "MaplestoryBold"),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            logout();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.5, 25),
                          ),
                          child: const Text(
                            '로그아웃',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontFamily: "MaplestoryLight"),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: null,
                          child: Icon(
                            Icons.person_4_outlined,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '로그인이 필요합니다',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: "MaplestoryBold"),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            showLoginDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.5, 25),
                          ),
                          child: const Text(
                            '로그인 / 회원가입',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontFamily: "MaplestoryLight"),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('회원가입이 성공했습니다');
      showContextDialog(context, "회원가입 성공", "$username님 회원가입이 완료되었습니다.");
      addUserInfoToFirestore(username, email);

      setState(() {
        //초기화
        username = '';
        email = '';
        password = '';
      });
    } catch (e) {
      showErrorDialog(context, '회원가입 실패', e);
    }
  }

  void login() async {
    try {
      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //로그인 성공 시 해당 유저의 정보를 firestore에서 가져오기
      Map<String, dynamic>? _user = await getUserInfoFromFirestore(email);
      username = _user!['username'];
      setState(() {
        loginCheck = true;
        var userStatus = Provider.of<UserStatus>(context, listen: false);
        userStatus.updateUsername(username);
        userStatus.updateLoginStatus(loginCheck);
      });
      context.pop();
    } catch (e) {
      showErrorDialog(context, '로그인 실패', e);
    }
  }

  void logout() {
    setState(() {
      loginCheck = false;
      username = '';
      email = '';
      password = '';
      var userStatus = Provider.of<UserStatus>(context, listen: false);
      userStatus.updateUsername(username);
      userStatus.updateLoginStatus(loginCheck);
    });
  }

  void showRegisterDialog() {
    double dialogWidth = MediaQuery.of(context).size.width * 0.5;
    double dialogHeight = MediaQuery.of(context).size.height * 0.5;

    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmController = TextEditingController();

    int passwordStatus = 0;
    bool fillInfoStatus = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            void verifyConfirmPassword() {
              setState(() {
                if (_confirmController.text.isEmpty) {
                  passwordStatus = 0; //null 상태
                } else if (_passwordController.text ==
                    _confirmController.text) {
                  passwordStatus = 1; //correct 상태
                } else if (_passwordController.text !=
                    _confirmController.text) {
                  passwordStatus = -1; //incorrect 상태
                } else {
                  passwordStatus = 0; //그 외는 null
                }

                if (_usernameController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty) {
                  fillInfoStatus = true;
                } else {
                  fillInfoStatus = false;
                }
              });
            }

            return AlertDialog(
              content: Container(
                width: dialogWidth,
                height: dialogHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: Text('회원가입',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      //입력창(유저 이름)
                      TextField(
                        onChanged: (value) {
                          username = value;
                        },
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: '닉네임'),
                      ),
                      const SizedBox(height: 10),
                      //입력창(이메일)
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          email = value;
                        },
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: '이메일 주소'),
                      ),
                      const SizedBox(height: 10),
                      //입력창(비밀번호)
                      TextField(
                        obscureText: true,
                        onChanged: (value) {
                          password = value;
                        },
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: '비밀번호'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        obscureText: true,
                        onChanged: (value) {
                          verifyConfirmPassword();
                        },
                        controller: _confirmController,
                        decoration: InputDecoration(
                          labelText: '비밀번호 확인',
                          suffixIcon: passwordStatus != 0
                              ? Icon(
                                  passwordStatus == 1
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: passwordStatus == 1
                                      ? Colors.green
                                      : Colors.red,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Opacity(
                        opacity: (passwordStatus == 1 && fillInfoStatus == true)
                            ? 1.0
                            : 0.5,
                        child: TextButton(
                          onPressed:
                              (passwordStatus == 1 && fillInfoStatus == true)
                                  ? () {
                                      register();
                                      context.pop();
                                    }
                                  : null,
                          child: const Text('가입'),
                        )),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        passwordStatus = 0;
                        showLoginDialog();
                      },
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }

  void showLoginDialog() {
    double dialogWidth = MediaQuery.of(context).size.width * 0.5;
    double dialogHeight = MediaQuery.of(context).size.height * 0.5;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: Container(
                width: dialogWidth,
                height: dialogHeight,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              fixedSize: const Size(20, 20),
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.grey[200],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Center(
                          child: Text('로그인',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      height: 50,
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: '이메일 주소',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 50,
                      child: Center(
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '비밀번호',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(MediaQuery.of(context).size.width * 0.5, 25),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontFamily: "MaplestoryLight"),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '아직 회원이 아니신가요? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          InkWell(
                            onTap: () {
                              context.pop();
                              showRegisterDialog();
                            },
                            child: const Text(
                              '회원가입 하기',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
