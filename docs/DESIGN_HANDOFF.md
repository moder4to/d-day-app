# Design Handoff

## 현재 톤

앱은 감성 카피보다 날짜 확인이라는 기능을 먼저 보여주는 방향으로 정리했습니다. “우리의 날”, “둘만의”, “차곡차곡”, “감성적인”처럼 넓고 장식적인 표현은 빼고, `D-Day`, `일정`, `시작일`, `빠른 확인`처럼 화면에서 바로 이해되는 단어를 사용합니다.

## 카피 원칙

- 버튼은 행동을 말합니다: `일정 추가`, `저장`, `전체 보기`
- 빈 상태는 현재 상태와 다음 행동을 말합니다.
- 잠금화면과 제어센터 설명은 짧게 씁니다.
- 관계를 특정하는 문구는 최소화합니다. 필요한 경우 프로필 입력값으로 개인화합니다.
- App Store 문구도 과한 수식보다 기능과 개인정보 기준을 먼저 설명합니다.

## 현재 디자인 기준

- 기본 색상은 블루와 틸 중심의 중립 팔레트입니다.
- 하트/반짝이 아이콘은 기본 화면에서 제거했습니다.
- 카드는 8pt radius를 유지합니다.
- 위젯/제어센터 미리보기는 실제 iOS 표시 영역을 설명하는 내부 QA 용도입니다.
- 최종 브랜드 색상, 아이콘, 스크린샷 아트디렉션은 디자이너 확정이 필요합니다.

## 디자이너가 보면 좋은 파일

- `d-day-app/DesignSystem/AppTheme.swift`
- `d-day-app/Features/Home/HomeView.swift`
- `d-day-app/Features/EventEditor/EventEditorView.swift`
- `d-day-app/Features/Settings/SettingsView.swift`
- `d-day-appWidgets/DDayLockScreenWidget.swift`
- `d-day-appWidgets/DDayControlWidget.swift`
- `docs/APP_STORE_PREP.md`

## 남은 디자인 결정

- 앱 아이콘 최종안
- 브랜드 색상과 다크 모드 기준
- 빈 상태와 온보딩의 최종 문장
- 잠금화면 accessory별 정보 우선순위
- App Store 스크린샷 구성
