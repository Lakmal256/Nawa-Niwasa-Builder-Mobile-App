import 'package:flutter/foundation.dart';

import 'dto.dart';

abstract class DataFilter<T> {
  List<T> filter(List<T> data);
}

class GlobalJobTypes extends ValueNotifier<List<JobTypeDto>> {
  GlobalJobTypes(super.value);

  setTypes(List<JobTypeDto> values){
    value = values;
  }

  JobTypeDto getJobTypeByName(String? v0){
    return value.singleWhere((type) => type.jobTypeName == v0, orElse: JobTypeDto.empty);
  }
}