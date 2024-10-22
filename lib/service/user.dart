import 'package:flutter/foundation.dart';
import 'package:insee_builder/service/service.dart';

// class UserService extends ValueNotifier<UserDto?>{
//   UserService(super.value);
//
//   setValue(UserDto? value){
//     this.value = value;
//   }
// }

class BuilderService extends ValueNotifier<BuilderDto?>{
  BuilderService(super.value);

  setValue(BuilderDto? value){
    this.value = value;
  }
}