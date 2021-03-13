
import 'package:shared_preferences/shared_preferences.dart';

class SPServices {
  Future<bool> saveCubeUserIdToSP(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(SPStrings.cubeUserId, id);
    return true;
  }

  Future<bool> logOut() async {
    SharedPreferences shaPre = await SharedPreferences.getInstance();
    if (shaPre.containsKey(SPStrings.cubeUserId)) {
      print('\nuser is now logged in, we can log out user');
      shaPre.remove(SPStrings.cubeUserId);
      clearDataProvider();
      print('\nlogout operation successful.');
      return true;
    }
    print('\nuser is not logged in, so we can not perform logout operation');
    return false;
  }

  Future<int> checkUserLogedin() async {
    SharedPreferences shaPre = await SharedPreferences.getInstance();
    if (shaPre.containsKey(SPStrings.cubeUserId)) {
      int cubeUserId = shaPre.getInt(SPStrings.cubeUserId);
      SPDataProvider.cubeUserId = cubeUserId;

      print('SPServices.checkUserLogedin : ' +
          'cube user id = ${SPDataProvider.cubeUserId}');
      return cubeUserId;
    } else {
      return null;
    }
  }

  void clearDataProvider() {
    SPDataProvider.cubeUserId = null;
  }
}

class SPDataProvider {
  static int cubeUserId;
}

class SPStrings{
  static final String cubeUserId= 'cube_user_id';
}
