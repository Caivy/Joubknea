import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:joubknea/data/db/entity/chat.dart';
import 'package:joubknea/data/db/remote/firebase_auth_source.dart';
import 'package:joubknea/data/db/remote/firebase_database_source.dart';
import 'package:joubknea/data/db/remote/firebase_storage_source.dart';
import 'package:joubknea/data/db/remote/response.dart';
import 'package:joubknea/data/model/chat_with_user.dart';
import 'package:joubknea/data/model/user_registration.dart';
import 'package:joubknea/util/shared_preferences_utils.dart';
import 'package:joubknea/data/db/entity/app_user.dart';
import 'package:joubknea/util/utils.dart';
import 'package:joubknea/data/db/entity/match.dart';

class UserProvider extends ChangeNotifier {
  FirebaseAuthSource _authSource = FirebaseAuthSource();
  FirebaseStorageSource _storageSource = FirebaseStorageSource();
  FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoading = false;
  AppUser _user;
  String _verificationID = "";
  bool _success = false;

  Future<AppUser> get user => _getUser();
  String get verificationID => _verificationID;
  bool get success => _success;

  veriID(String v){
    _verificationID = v;
    notifyListeners();
  }

  Future<Response> loginUser(String email, String password,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.signIn(email, password);
    if (response is Success<UserCredential>) {
      String id = response.value.user.uid;
      SharedPreferencesUtil.setUserId(id);
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    return response;
  }

  Future<Response> registerUser(UserRegistration userRegistration,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.register(
        userRegistration.email, userRegistration.password);
    if (response is Success<UserCredential>) {
      String id = (response as Success<UserCredential>).value.user.uid;
      response = await _storageSource.uploadUserProfilePhoto(
          userRegistration.localProfilePhotoPath, id);

      if (response is Success<String>) {
        String profilePhotoUrl = response.value;
        AppUser user = AppUser(
            id: id,
            name: userRegistration.name,
            age: userRegistration.age,
            profilePhotoPath: profilePhotoUrl);
        _databaseSource.addUser(user);
        SharedPreferencesUtil.setUserId(id);
        _user = _user;
        return Response.success(user);
      }
    }
    if (response is Error) showSnackBar(errorScaffoldKey, response.message);
    return response;
  }

  Future signUp(BuildContext context, UserRegistration _userRegistration, GlobalKey<ScaffoldState> errorScaffoldKey) async {
    await _authSource.verifyNumber(context, _userRegistration.email);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: _userRegistration.veriInput);
    try {
      await auth.signInWithCredential(credential).then((value) async {
       String profilePath = await _storageSource.UserProfilePhoto(
          _userRegistration.localProfilePhotoPath, value.user.uid);
      AppUser user = AppUser(
            id: value.user.uid,
            name: _userRegistration.name,
            age: _userRegistration.age,
            profilePhotoPath: profilePath);
        _databaseSource.addUser(user);
        SharedPreferencesUtil.setUserId(value.user.uid);
        _success = true;
        notifyListeners();
        
    });
    } catch (e) {
      return showSnackBar(errorScaffoldKey, e.message);
    }
}

  Future<AppUser> _getUser() async {
    if (_user != null) return _user;
    String id = await SharedPreferencesUtil.getUserId();
    _user = AppUser.fromSnapshot(await _databaseSource.getUser(id));
    return _user;
  }

  void updateUserProfilePhoto(
      String localFilePath, GlobalKey<ScaffoldState> errorScaffoldKey) async {
    isLoading = true;
    notifyListeners();
    Response<dynamic> response =
        await _storageSource.uploadUserProfilePhoto(localFilePath, _user.id);
    isLoading = false;
    if (response is Success<String>) {
      _user.profilePhotoPath = response.value;
      _databaseSource.updateUser(_user);
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    notifyListeners();
  }

  void updateUserBio(String newBio) {
    _user.bio = newBio;
    _databaseSource.updateUser(_user);
    notifyListeners();
  }

  Future<void> logoutUser() async {
    _user = null;
    await SharedPreferencesUtil.removeUserId();
  }

  Future<List<ChatWithUser>> getChatsWithUser(String userId) async {
    var matches = await _databaseSource.getMatches(userId);
    List<ChatWithUser> chatWithUserList = [];

    for (var i = 0; i < matches.size; i++) {
      Match match = Match.fromSnapshot(matches.docs[i]);
      AppUser matchedUser =
          AppUser.fromSnapshot(await _databaseSource.getUser(match.id));

      String chatId = compareAndCombineIds(match.id, userId);

      Chat chat = Chat.fromSnapshot(await _databaseSource.getChat(chatId));
      ChatWithUser chatWithUser = ChatWithUser(chat, matchedUser);
      chatWithUserList.add(chatWithUser);
    }
    return chatWithUserList;
  }
}
