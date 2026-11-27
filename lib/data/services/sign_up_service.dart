import 'package:dio/dio.dart';

import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_models.dart';

/// 6주차 MemberCheckService → 7주차 SignUpService
/// 중복 확인 GET(v5 → v6)은 유지하고 회원가입 POST를 추가합니다.
class SignUpService {
  SignUpService(this._dio);

  final Dio _dio;

  /// 성공 응답은 기존 직접 객체 { "available": true } 형식을 유지합니다.
  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('/v6/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>)
        .available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v6/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>)
        .available;
  }

  /// 201 + 공통 응답 { result: { memberId, email, nickname } }
  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post(
      '/v6/members',
      data: request.toJson(),
    );

    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}

/// 400(비밀번호 형식)·409(중복) 모두 서버 message를 그대로 보여줍니다.
String writeSignUpErrorMessage(DioException error) {
  final common = tryParseCommonError(error.response?.data);
  return common?.message ?? '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}
