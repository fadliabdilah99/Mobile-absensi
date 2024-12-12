import 'package:absensi_apps/data/model/user.dart';
import 'package:get/get.dart';

class Cuser extends GetxController{
  final _data = User().obs;
  User get data => _data.value;
  setData(n) => _data.value = n;
  // static void setData(User user) {}
}