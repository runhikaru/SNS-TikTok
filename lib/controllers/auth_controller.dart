import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_tiktok_clone/constants.dart';
import 'package:firebase_tiktok_clone/models/user.dart' as model;
import 'package:firebase_tiktok_clone/views/screens/auth/login_screen.dart';
import 'package:firebase_tiktok_clone/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  late Rx<File?> _pickedImage;

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    // ユーザーデータを関連付ける
    _user.bindStream(firebaseAuth.authStateChanges());
    // 第1引数の変数が変更されるたびに第2引数の関数が実行される
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar('プロフィール写真を設定しました。', '');
    }
    // Rx（変更の監視を可能にする）
    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }

  // プロフィール画像を返すことができるかも？？？？
  // Future<XFile> pickImage() async {
  //   final pickedImage =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedImage != null) {
  //     Get.snackbar('プロフィール写真を設定しました。', '');
  //   }
  //   // Rx（変更の監視可能にする）
  //   _pickedImage = Rx<File?>(File(pickedImage!.path));

  //   return pickedImage;
  // }

  // upload to firebase storage
  Future<String> _uploadToStorage(File image) async {
    // 保存先とフォルダ＆ファイル名を指定
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  // registering the user
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // save out user to our auth and firebase firestore
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );
        // FireStoreに保存
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            // Map文字列をJson化
            .set(user.toJson());
      } else {
        Get.snackbar(
          'アカウントを作成できませんでした。',
          '再度、お試しください。',
        );
      }
    } catch (e) {
      Get.snackbar(
        'アカウントの作成中にエラーが発生しました。',
        e.toString(),
      );
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        Get.snackbar(
          'ログインエラー',
          '再度、お試しください。',
        );
      }
    } catch (e) {
      Get.snackbar(
        'ログインエラー',
        e.toString(),
      );
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
