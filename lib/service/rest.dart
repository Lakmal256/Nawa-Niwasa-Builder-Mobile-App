import 'dart:convert';
import 'dart:io';
import 'auth.dart';
import 'dto.dart';

import 'package:http/http.dart' as http;

class UserNotFoundException implements Exception {}

class UnauthorizedException implements Exception {}

class BlockedUserException implements Exception {}

class ConflictedUserException implements Exception {}

class PendingApprovalException implements Exception {
  final String message;

  PendingApprovalException(this.message);
}

enum OtpMethod { email, mobile }

class RestServiceConfig {
  RestServiceConfig({
    required this.authority,
    String? pathPrefix,
  }) : pathPrefix = pathPrefix ?? '';

  final String authority;

  final String? pathPrefix;
}

class RestService {
  RestService({required this.config, required this.authService});

  RestServiceConfig config;

  AuthService authService;

  Future<bool> applyRegistration({
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNo,
    String? geoLocation,
    String? language,
    bool socialUser = false,
    String? socialLogin = "",
    String? socialToken,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    // if (socialToken != null) headers.addAll({'socialToken': socialToken});

    final body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobileNo": mobileNo,
      "geoLocation": geoLocation,
      "language": language,
      "socialUser": socialUser,
      "socialLogin": socialLogin,
    });

    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/external/register/apply"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    throw Exception();
  }

  /// Check if user already exist or not
  Future<bool> checkUserRegistrationStatus(String mobile) async {
    final response =
        await http.get(Uri.https(config.authority, "${config.pathPrefix}/identity/user/mobile/$mobile/exists"));
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson;
    }
    return false;
  }

  Future<bool> sendOtp(OtpMethod method, String value, {String type = "rp"}) async {
    switch (method) {
      case OtpMethod.email:
        {
          String email0 = value.toLowerCase();
          final response =
              await http.post(Uri.https(config.authority, "${config.pathPrefix}/utility/sendotp/$email0/$type"));
          return response.statusCode == HttpStatus.accepted;
        }
      case OtpMethod.mobile:
        {
          final response =
              await http.post(Uri.https(config.authority, "${config.pathPrefix}/utility/login/sendotp/$value"));
          return response.statusCode == HttpStatus.accepted;
        }
    }
  }

  Future<String> verifyOtp(String mobile, String otp) async {
    String mobile0 = mobile;
    final response =
        await http.post(Uri.https(config.authority, "${config.pathPrefix}/utility/login/verifyotp/$mobile0/$otp"));
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      var result = decodedJson["result"];
      return result ?? (throw Exception());
    }

    throw Exception();
  }

  Future<TokenResponse?> loginWithAuthorizationCode({required String authorizationCode}) async {
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/otp/login/$authorizationCode"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return TokenResponse.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<bool> deactivateUser() async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/${authData.identityId}/deactivate"),
      headers: {
        'Authorization': authData.bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return true;
    }

    throw Exception();
  }

  Future<bool> updateDeviceToken(String token) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/device-token/$token"),
      headers: {
        'Content-Type': 'application/json',
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// [id] builder id
  Future<bool> updateDeviceLocation({required double latitude, required double longitude}) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/builder/location"),
      body: json.encode({"latitude": latitude, "longitude": longitude}),
      headers: {
        'Content-Type': 'application/json',
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    return response.statusCode == HttpStatus.accepted;
  }

  Future<bool> createBuilderProfileChangeRequest(BuilderDto data) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/builder/change-request"),
      headers: {'Content-Type': 'application/json', 'Authorization': authData.bearerToken},
      body: json.encode({...data.toJson(), "identityId": authData.identityId}),
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    } else if (response.statusCode == HttpStatus.badRequest) {
      final decodedJson = json.decode(response.body);
      throw PendingApprovalException(decodedJson['result']);
    }

    throw Exception();
  }

  Future<UserDto?> getUserByMobile(String value) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/mobile/$value"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<UserResponseDto?> getUserByIamId(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/iam/$id"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<UserResponseDto?> getUserById(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/$id"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  /// Builder

  Future<BuilderDto?> getBuilderByMobile(String value) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/builder/mobile/$value"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return BuilderDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  /// Contractor

  /// [id] Builder / Contractor id
  Future<List<CrewMemberDto>> getAllCrewMembers(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/builder/contractor/$id/builder"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => CrewMemberDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  Future<bool> createCrewMember(int id, CrewMemberDto data) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/builder/contractor/$id/builder"),
      headers: {
        'Content-Type': ContentType.json.mimeType,
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    throw Exception();
  }

  Future<bool> updateCrewMember(int id, CrewMemberDto data) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/builder/contractor/$id/builder"),
      headers: {
        'Content-Type': ContentType.json.mimeType,
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    throw Exception();
  }

  Future<bool> deleteCrewMember(int id) async {
    final authData = await authService.getData();
    final response = await http.delete(
      Uri.https(config.authority, "${config.pathPrefix}/builder/contractor/builder/$id"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    }

    throw Exception();
  }

  /// Notification

  Future<List<NotificationDto>> getAllNotifications({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/notification/push", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return (decodedJson as List).map((data) => NotificationDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<bool> markNotificationAsRead({required int id}) async {
    final authData = await authService.getData();
    final response = await http.patch(
      Uri.https(config.authority, ""),
      headers: {
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );
    return response.statusCode == HttpStatus.ok;
  }

  /// Job

  /// [id] Builder id
  Future<List<JobDto>> getAllPublicJobs(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/jobs/builder/available/$id"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => JobDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  Future<List<JobDto>> getAllPrivateJobs(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/jobs/builder/$id"),
      headers: {'Authorization': authData.bearerToken},
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((data) => JobDto.fromJson(data)).toList();
    }

    throw Exception();
  }

  /// [id] Builder id
  /// [email] Customer email
  Future<JobDto?> getLastJobRequestFromCustomer(int id, String email) async {
    final authData = await authService.getData();
    final response = await http.get(
        Uri.https(config.authority, "${config.pathPrefix}/jobs/builder/latest", {
          "builderId": id.toString(),
          "customerEmail": email,
        }),
        headers: {
          'Content-Type': ContentType.json.mimeType,
          "user-iam-id": authData.identityId,
          'Authorization': authData.bearerToken,
        });

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return JobDto.fromJson(decodedJson);
    }

    return null;
  }

  Future<bool> applyForJob(int myId, int jobId) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/builder/request",
        {"builderId": myId.toString(), "jobId": jobId.toString()},
      ),
      headers: {'Authorization': authData.bearerToken},
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<bool> acceptJob(int jobId) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/builder/decide",
        {"decision": "ACCEPT", "jobId": jobId.toString()},
      ),
      headers: {'Authorization': authData.bearerToken},
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<bool> rejectJob(int jobId) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/builder/decide",
        {"decision": "REJECT", "jobId": jobId.toString()},
      ),
      headers: {'Authorization': authData.bearerToken},
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// [id] Builder id
  /// [jobId] Job id
  Future<bool> dismissPublicJob(int id, int jobId) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/jobs/builder/$id/dismiss",
        {"jobId": jobId.toString()},
      ),
      headers: {'Authorization': authData.bearerToken},
    );

    return response.statusCode == HttpStatus.ok;
  }

  /// DM

  Future<List<ConversationDto>> getConversations() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/message/builder"),
      headers: {
        'Content-Type': "application/json",
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((message) => ConversationDto.fromJson(message)).toList();
    }

    return [];
  }

  /// [id] Customer id
  Future<List<MessageDto>> getChatMessages(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/message/builder/customer/$id"),
      headers: {
        'Content-Type': "application/json",
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((message) => MessageDto.fromJson(message)).toList();
    }

    return [];
  }

  /// [id] Customer id
  /// [message] Message body
  Future<bool> sendMessage(int id, String message) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/message/builder/send/$id"),
      headers: {
        'Content-Type': ContentType.json.mimeType,
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
      body: json.encode({"message": message}),
    );
    return response.statusCode == HttpStatus.accepted;
  }

  /// [id] Customer id
  Future<bool> markAllAsRead(int id) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/message/builder/read/$id"),
      headers: {
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );
    return response.statusCode == HttpStatus.ok;
  }

  /// [id] Message id
  Future<bool> markAsRead(int id) async {
    /// Not implemented yet from BE
    return false;
  }

  /// Master data

  Future<List<JobTypeDto>?> getAllJobTypes() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/mdm/jobtype"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((item) => JobTypeDto.fromJson(item)).toList();
    }

    return [];
  }

  Future<List<NvqLevelDto>?> getAllNvqLevels() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/mdm/nvqlevel"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((item) => NvqLevelDto.fromJson(item)).toList();
    }

    return [];
  }

  Future<List<SkillDto>?> getAllSkills() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/mdm/skill"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return (decodedJson as List).map((item) => SkillDto.fromJson(item)).toList();
    }

    return [];
  }

  Future<String?> uploadAsync(String name, List<int> bytes) async {
    final authData = await authService.getData();
    Uri uri = Uri.https(config.authority, "${config.pathPrefix}/utility/files/upload");
    http.MultipartRequest multipartRequest = http.MultipartRequest("POST", uri)
      ..headers.addAll({'Authorization': authData.bearerToken})
      ..files.add(http.MultipartFile.fromBytes("file", bytes, filename: name));

    final response = await http.Response.fromStream(await multipartRequest.send());

    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    }

    throw Exception();
  }

  @Deprecated("No longer using the public bucket")
  Future<String?> uploadBase64EncodeAsyncPublic(String value) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/utility/files/upload/public"),
      headers: {
        'Content-Type': "text/plain",
        'Authorization': authData.bearerToken,
      },
      body: value,
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson["result"];
    }

    throw Exception();
  }

  Future<String?> getFullFilePath(String fileName) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/utility/files/$fileName"),
      headers: {
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson['result'];
    }

    throw Exception();
  }

  Future<String?> uploadBase64EncodeAsync(String value) async {
    final authData = await authService.getData();
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/utility/files/upload"),
      headers: {
        'Content-Type': "text/plain",
        'Authorization': authData.bearerToken,
      },
      body: value,
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson["result"];
    }

    throw Exception();
  }
}
