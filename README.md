# SERS
Skin Efficacy Request System

3. 의뢰 상태 흐름 (requests.status)
================================================================

  [의뢰자 등록]
       ↓
  submitted       → 관리자 검토 대기 (의뢰자가 제출한 직후)
       ↓ 관리자 승인
  pending         → 실험자 접수 대기
       ↓ 실험자 접수 (claim)
  in_progress     → 실험 진행 중 (채팅 활성화)
       ↓ 실험 완료 처리
  documenting     → 자료 정리 중 (채팅 비활성화, 결과 입력 단계)
       ↓ 결과 완료 + Gmail 송부
  completed       → 완료 (연간 리스트 반영)

  rejected        → 관리자가 반려한 경우

  [전문 평가가 포함된 경우 추가 상태]
  approved_parent → 일반 효능은 pending 처리됐으나 전문 효능은 별도 관리
