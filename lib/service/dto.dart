import 'package:intl/intl.dart';

class TokenResponse {
  String? token;
  String? refreshToken;
  String? identityId;
  UserResponseDto? user;

  TokenResponse.fromJson(Map<String, dynamic> value)
      : identityId = value["loggedUser"]["identityId"],
        token = value["accessToken"],
        user = UserResponseDto.fromJson(value["loggedUser"]),
        refreshToken = value["refreshToken"];
}

class UserResponseDto {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  bool? internal;
  bool? status;
  String? expiryDate;
  String? defaultLanguage;
  String? lastModifiedDate;
  String? sapEmployeeCode;
  String? geoLocation;
  String? profileImageUrl;
  String? profileImage;

  UserResponseDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        internal = value["internal"],
        status = value["status"],
        expiryDate = value["expiryDate"],
        defaultLanguage = value["defaultLanguage"],
        lastModifiedDate = value["lastModifiedDate"],
        sapEmployeeCode = value["sapEmployeeCode"],
        geoLocation = value["geoLocation"],
        profileImage = value["profileImage"],
        // profileImageUrl = value["profileImageUrl"] ??
        profileImageUrl = value["displayProfileImageUrl"] ??

            /// Service currently not supporting any default image
            /// this is a public image service that provides a name based
            /// profile image
            "https://ui-avatars.com/api/?background=random&name=${value["firstName"]}+${value["lastName"]}";

  String get displayName => "$firstName $lastName".replaceAll(RegExp('\\s+'), ' ');
}

/// End Complaint
/// Job

enum JobAccessibility {
  private,
  public,
}

enum JobStatus {
  open,
  pending,
  inProgress,
  rejected,
  completed,
  unknown,
}

class JobDto {
  int? id;
  String? title;
  String? jobType;
  String? location;
  String? jobDescription;
  List<String> images;
  // String? jobTypeImage;
  String? customerEmail;
  String? customerName;
  int? customerId;
  String? sStatus;
  JobStatus status;
  String? lastModifiedDate;
  bool isPrivate;
  bool isDeleted;
  DateTime? dLastModifiedDate;

  JobDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        title = value['jobTitle'],
        jobType = value['jobType'],
        location = value['location'],
        jobDescription = value['jobDescription'],
        // images = _separateConcatImageString(value['image']),
        images = _separateConcatImageString(value['displayImageUrl']),
        // jobTypeImage = value['jobTypeImage'],
        // jobTypeImage = value['displayJobTypeImage'],
        customerEmail = value['customerEmail'],
        customerName = _getCustomerName(value['user']),
        customerId = value['user']['id'],
        lastModifiedDate = value['lastModifiedDate'],
        dLastModifiedDate = DateTime.parse(value['lastModifiedDate']),
        isPrivate = value['isPrivate'],
        isDeleted = value['isDeleted'],
        status = _stringToJobStatus(value['status']),
        sStatus = value['status'];

  ///[value] user/customer data
  static String _getCustomerName(Map<String, dynamic> value) {
    return '${value["firstName"]} ${value["lastName"]}';
  }

  static JobStatus _stringToJobStatus(String? value) {
    switch (value) {
      case "OPEN":
        return JobStatus.open;
      case "PENDING":
        return JobStatus.pending;
      case "IN_PROGRESS":
        return JobStatus.inProgress;
      case "REJECTED":
        return JobStatus.rejected;
      case "COMPLETED":
        return JobStatus.completed;
      default:
        return JobStatus.unknown;
    }
  }

  static List<String> _separateConcatImageString(String? value) {
    if (value == null) return [];

    return value.split("\n");
  }

  String get justDate => DateFormat("d/MM/yyyy").format(dLastModifiedDate!);
  JobAccessibility get accessibility => isPrivate ? JobAccessibility.private : JobAccessibility.public;
}

class JobTypeDto {
  int? id;
  String? jobTypeName;
  String? description;
  String? jobTypeImage;

  JobTypeDto.empty();

  JobTypeDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        jobTypeName = value['jobTypeName'],
        description = value['description'],
        // jobTypeImage = value['jobTypeImage'],
        jobTypeImage = value['displayJobTypeImageUrl'];
}

class JobRequestDto {
  int? id;
  BuilderDto? builder;

  JobRequestDto.empty();

  JobRequestDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        builder = BuilderDto.fromJson(value["builder"]);
}

/// End Job

///
///  Old
///

class UserDto {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  bool? internal;
  String? status;
  String? expiryDate;
  String? defaultLanguage;
  String? lastModifiedDate;
  String? sapEmployeeCode;

  UserDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        internal = value["internal"],
        status = value["status"],
        expiryDate = value["expiryDate"],
        defaultLanguage = value["defaultLanguage"],
        lastModifiedDate = value["lastModifiedDate"],
        sapEmployeeCode = value["sapEmployeeCode"];
}

enum BuilderType { regular, contractor }

class BuilderDto {
  int? id;
  String? firstName;
  String? secondName;
  String? lastName;
  String? nicNumber;
  String? contactNumber;
  String? availability;
  String? preferredLocation;
  String? status;
  String? jobType;
  String? jobDescription;
  String? profileImage;
  String? profileImageUrl;
  double? rating;
  int jobCount;
  BuilderType type = BuilderType.regular;
  List<String> primarySkills = [];
  List<String> qualitiesTags = [];
  List<String> nvqQualifications = [];
  List<String> otherSkills = [];
  List<String> builderWorkImageUrls = [];
  List<String> displayBuilderWorkImageUrls = [];

  BuilderDto()
      : rating = 0.0,
        jobCount = 0;

  BuilderDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        rating = value["rating"],
        jobCount = value["noOfJobs"] ?? 0,
        firstName = value["firstName"] ?? "",
        secondName = value["secondName"] ?? "",
        lastName = value["lastName"] ?? "",
        nicNumber = value["nicNumber"],
        contactNumber = value["contactNumber"],
        availability = value["availability"],
        preferredLocation = value["preferredLocation"],
        status = value["status"],
        jobType = value["jobType"],
        jobDescription = value["jobDescription"],
        profileImage = value["profileImage"],
        // profileImageUrl = value["profileImageUrl"],
        profileImageUrl = value["displayProfileImageUrl"],
        primarySkills = _toStringList(value["primarySkills"]),
        qualitiesTags = _toStringList(value["qualitiesTags"]),
        nvqQualifications = _toStringList(value["nvqQualifications"]),
        builderWorkImageUrls = _toStringList(value["builderWorkImageUrls"]),
        displayBuilderWorkImageUrls = _toStringList(value["displayBuilderWorkImageUrls"] ?? []),
        type = switch (value["builderType"]) {
          "CONTRACTOR" => BuilderType.contractor,
          _ => BuilderType.regular,
        },
        otherSkills = _toStringList(value["otherSkills"]);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstName": firstName ?? "",
      "secondName": secondName ?? "",
      "lastName": lastName ?? "",
      "nicNumber": nicNumber,
      "contactNumber": contactNumber,
      "availability": availability,
      "preferredLocation": preferredLocation,
      "status": status,
      "jobType": jobType,
      "jobDescription": jobDescription,
      "profileImage": profileImage,
      "profileImageUrl": profileImageUrl,
      "primarySkills": primarySkills,
      "qualitiesTags": qualitiesTags,
      "nvqQualifications": nvqQualifications,
      "builderWorkImageUrls": builderWorkImageUrls,
      "otherSkills": otherSkills,
    };
  }

  BuilderDto copyWith({
    int? id,
    String? firstName,
    String? secondName,
    String? lastName,
    String? nicNumber,
    String? contactNumber,
    String? availability,
    String? preferredLocation,
    String? status,
    String? jobType,
    String? jobDescription,
    String? profileImage,
    String? profileImageUrl,
    String? builderType,
    List<String>? primarySkills,
    List<String>? qualitiesTags,
    List<String>? nvqQualifications,
    List<String>? otherSkills,
    List<String>? builderWorkImageUrls,
  }) {
    return BuilderDto()
      ..id = id ?? this.id
      ..firstName = firstName ?? this.firstName ?? ""
      ..secondName = secondName ?? this.secondName ?? ""
      ..lastName = lastName ?? this.lastName ?? ""
      ..nicNumber = nicNumber ?? this.nicNumber
      ..contactNumber = contactNumber ?? this.contactNumber
      ..availability = availability ?? this.availability
      ..preferredLocation = preferredLocation ?? this.preferredLocation
      ..status = status ?? this.status
      ..jobType = jobType ?? this.jobType
      ..jobDescription = jobDescription ?? this.jobDescription
      ..profileImage = profileImage ?? this.profileImage
      ..profileImageUrl = profileImageUrl ?? this.profileImageUrl
      ..primarySkills = primarySkills ?? this.primarySkills
      ..qualitiesTags = qualitiesTags ?? this.qualitiesTags
      ..nvqQualifications = nvqQualifications ?? this.nvqQualifications
      ..otherSkills = otherSkills ?? this.otherSkills
      ..builderWorkImageUrls = builderWorkImageUrls ?? this.builderWorkImageUrls;
  }

  get fullNameLong => "$firstName $secondName $lastName";
  get fullNameShort => "$firstName $lastName";

  static List<String> _toStringList(List list) => List<String>.from(list);
  static List<String> filterNull(List list) => List<String>.from(list.where((e) => e != null));
}

/// A member working under a contractor.
class CrewMemberDto {
  int? id;
  String? firstName;
  String? secondName;
  String? lastName;
  String? nicNumber;
  String? contactNumber;

  CrewMemberDto();

  CrewMemberDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        firstName = value["firstName"] ?? "",
        secondName = value["secondName"] ?? "",
        lastName = value["lastName"] ?? "",
        nicNumber = value["nicNumber"],
        contactNumber = value["contactNumber"];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstName": firstName ?? "",
      "secondName": secondName ?? "",
      "lastName": lastName ?? "",
      "nicNumber": nicNumber,
      "contactNumber": contactNumber,
    };
  }

  CrewMemberDto copyWith({
    int? id,
    String? firstName,
    String? secondName,
    String? lastName,
    String? nicNumber,
    String? contactNumber,
  }) {
    return CrewMemberDto()
      ..id = id ?? this.id
      ..firstName = firstName ?? this.firstName ?? ""
      ..secondName = secondName ?? this.secondName ?? ""
      ..lastName = lastName ?? this.lastName ?? ""
      ..nicNumber = nicNumber ?? this.nicNumber
      ..contactNumber = contactNumber ?? this.contactNumber;
  }

  String get displayName => "$firstName $secondName $lastName";
}

class NvqLevelDto {
  int? id;
  String? name;

  NvqLevelDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        name = value["nvqLevelName"];
}

class SkillDto {
  int? id;
  String? name;
  String? type;

  SkillDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        name = value["skillName"],
        type = value["skillType"];

  @Deprecated('[skillType] is no longer being used')
  bool get isPrimary => type == "PRIMARY";
  bool get isSecondary => type == "SECONDARY";
}

class MessageAuthor {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? profileImageUrl;

  MessageAuthor.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        // profileImageUrl = value["profileImageUrl"];
        profileImageUrl = value["displayProfileImageUrl"];

  String get fullName => "$firstName $lastName";
}

class MessageDto {
  int? id;
  String? message;
  DateTime? dateTime;
  bool isSeen;
  bool isFromACustomer;

  /// Other end of the conversation
  MessageAuthor? interlocutor;

  MessageDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        message = value["message"],
        dateTime = DateTime.parse(value["dataTime"]),
        isSeen = value["seenMessage"] ?? false,
        interlocutor = value['customer'] != null ? MessageAuthor.fromJson(value['customer']) : null,
        isFromACustomer = value["fromCustomer"];

  static final dateFormat = DateFormat("d/MM/yyyy");
  String get sDate => dateFormat.format(dateTime!);
  Duration get timeDifference => DateTime.now().difference(dateTime!);
  String get relativeTime => DateFormat.Hm().format(DateTime.now().subtract(timeDifference));
}

/// Not related to [MessageDto]
class ConversationMessageDto {
  int? id;
  String? message;
  DateTime? dateTime;
  int? interlocutorId;
  String? interlocutorName;
  String? interlocutorImageUrl;

  ConversationMessageDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        message = value["message"],
        dateTime = DateTime.tryParse(value["lastModifiedDate"]),
        interlocutorId = value["customer"]["id"],
        interlocutorName = "${value["customer"]["firstName"]} ${value["customer"]["lastName"]}",
        // interlocutorImageUrl = value["customer"]["profileImageUrl"];
        interlocutorImageUrl = value["customer"]["displayProfileImageUrl"];

  static final dateFormat = DateFormat("d/MM/yyyy");
  String get sDate => dateFormat.format(dateTime!);
  Duration get timeDifference => DateTime.now().difference(dateTime!);
  String? get relativeTime => DateFormat.Hm().format(DateTime.now().subtract(timeDifference));
}

class ConversationDto {
  int? id;
  ConversationMessageDto? lastMessage;
  int unseenMessageCount;

  ConversationDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        lastMessage = ConversationMessageDto.fromJson(value["latestMessage"]),
        unseenMessageCount = value["noOfUnreadMessages"] ?? 0;
}

class NotificationDto {
  int id;
  String? status;
  String? topic;
  String? title;
  String? body;
  bool read;

  NotificationDto.fromJson(Map<String, dynamic> value)
      : id = 0,
        status = value["main"],
        topic = value["topic"],
        title = value["title"],
        body = value["body"],
        read = value["read"];
}
