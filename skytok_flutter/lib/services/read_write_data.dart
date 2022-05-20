import 'package:shared_preferences/shared_preferences.dart';
import 'package:skytok_flutter/services/api_requests.dart';

class ReadWriteData {
  writeData(String token, String username, String mail, int userId) async {
    //Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('username', username);
    prefs.setString('mail', mail);
    prefs.setInt('userId', userId);
    Api().setData(token, userId, username);
  }

  Future<bool> readData() async {
    //Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? username = prefs.getString('username');
    String? mail = prefs.getString('mail');
    int? userId = prefs.getInt('userId');
    if (token == null || username == null || mail == null || userId == null) {
      print("Token $token Username $username Mail $mail UserId $userId");
      return false;
    }
    Api().setData(token, userId, username);
    return true;
  }
}
