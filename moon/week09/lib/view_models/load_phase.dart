enum LoadPhase {
  idle, // 아직 요청하지 않은 상태
  loading, // 첫 번째 조회 중
  ready, // 조회 성공, 표시할 데이터 있음
  empty, // 조회 성공, 결과 없음
  error, // 첫 번째 조회 실패
}
