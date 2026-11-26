import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';

class FakeTokenStorage implements TokenStorage {
  String? token;
  bool deleted = false;

  FakeTokenStorage(this.token);

  @override
  Future<void> saveAccessToken(String value) async {
    token = value;
  }

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async {
    token = null;
    deleted = true;
  }
}

class FakeAuthApiService extends AuthApiService {
  FakeAuthApiService() : super(Dio());
}

class FakeMemberApiService extends MemberApiService {
  FakeMemberApiService(this.error) : super(Dio());

  final DioException error;

  @override
  Future<MemberInfo> fetchMe() async {
    throw error;
  }
}

DioException fakeError({
  required int status,
  required String code,
}) {
  final options = RequestOptions(path: '/v7/members/me');
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: {
        'isSuccess': false,
        'code': code,
        'message': '테스트 오류',
        'result': null,
      },
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  test('만료된 JWT는 삭제하고 로그인 상태를 해제한다', () async {
    final storage = FakeTokenStorage('invalid-test-token');
    final auth = AuthViewModel(
      FakeAuthApiService(),
      FakeMemberApiService(
        fakeError(status: 401, code: 'AUTH401_3'),
      ),
      storage,
    );

    await auth.restoreSession();

    expect(auth.status, AuthStatus.signedOut);
    expect(auth.sessionExpired, isTrue);
    expect(storage.token, isNull);
    expect(storage.deleted, isTrue);
    auth.dispose();
  });

  test('네트워크 오류는 JWT를 삭제하지 않는다', () async {
    final storage = FakeTokenStorage('test-token');
    final auth = AuthViewModel(
      FakeAuthApiService(),
      FakeMemberApiService(
        DioException(
          requestOptions: RequestOptions(path: '/v7/members/me'),
          type: DioExceptionType.connectionError,
        ),
      ),
      storage,
    );

    await auth.restoreSession();

    expect(auth.status, AuthStatus.retryRequired);
    expect(storage.token, 'test-token');
    expect(storage.deleted, isFalse);
    auth.dispose();
  });

  test('저장된 JWT가 없으면 로그인 화면 상태가 된다', () async {
    final storage = FakeTokenStorage(null);
    final auth = AuthViewModel(
      FakeAuthApiService(),
      FakeMemberApiService(
        fakeError(status: 401, code: 'AUTH401_3'),
      ),
      storage,
    );

    await auth.restoreSession();

    expect(auth.status, AuthStatus.signedOut);
    expect(auth.sessionExpired, isFalse);
    expect(storage.deleted, isFalse);
    auth.dispose();
  });
}
