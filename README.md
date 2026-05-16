# D-Day App

시작일과 일정을 저장하고, 남은 날과 지난 날을 앱·잠금화면·제어센터에서 확인하는 iOS 18 D-Day 앱입니다.

## 개발 기준

- Platform: iOS 18+
- IDE: Xcode 26.x
- UI: SwiftUI
- Local data: SwiftData
- Repository: https://github.com/moder4to/d-day-app

## 현재 구현

이 저장소는 로컬 저장 기반 MVP 구현 단계입니다. Windows 환경에서는 문서와 소스 구조를 정리하고 GitHub로 푸시하는 용도로 사용하며, pull, 빌드, 테스트는 최신 Xcode가 설치된 Mac에서 진행합니다.

- 첫 실행 프로필 입력
- 시작일부터 지난 날 수 표시
- 일정 추가, 수정, 삭제
- 생일/기념일용 매년 반복 계산
- 고정 D-Day와 다가오는 날 목록
- WidgetKit 잠금화면 위젯
- iOS 18 제어센터 컨트롤
- D-Day 당일, 하루 전, 7일 전 알림 옵션
- App Group 기반 대표 D-Day 스냅샷 공유
- SwiftData 로컬 저장

## 폴더 구조

```text
d-day-app/
  App/               루트 탭 구조
  Core/              모델, 유틸리티, 공통 로직
    Shared/          앱/위젯 확장 공유 스냅샷
  DesignSystem/      색상, 간격, 공통 스타일
  Features/          화면 단위 기능
  Assets.xcassets/   앱 아이콘과 색상 에셋
  Preview Content/   프리뷰 전용 리소스
d-day-appWidgets/    잠금화면 위젯과 iOS 18 제어센터 컨트롤
d-day-app.xcodeproj/ Xcode 프로젝트
d-day-appTests/      단위 테스트
d-day-appUITests/    UI 테스트
docs/
  PRODUCT_BRIEF.md   제품 방향과 MVP 범위
  ARCHITECTURE.md    앱 구조와 기술 결정
  MAC_XCODE_SETUP.md 맥에서 Xcode 프로젝트를 연결하는 절차
  GIT_WORKFLOW.md    Windows/Mac 분리 작업 흐름
  ROADMAP.md         개발 마일스톤
  PRODUCTION_PLAN.md 프로덕션 레벨로 가기 위한 실행 계획
  APP_STORE_PREP.md  App Store 제출 준비 체크리스트
  DESIGN_HANDOFF.md  디자이너 인수인계용 카피/디자인 기준
```

## Mac에서 시작하기

자세한 절차는 [docs/MAC_XCODE_SETUP.md](docs/MAC_XCODE_SETUP.md)를 참고하세요.

요약:

```bash
git clone https://github.com/moder4to/d-day-app.git
cd d-day-app
```

그 다음 Xcode 26.x에서 `d-day-app.xcodeproj`를 열고 빌드합니다.

잠금화면 위젯과 제어센터 컨트롤은 `group.yhb.d-day-app` App Group을 사용합니다. 실제 기기 배포 전 Apple Developer 계정에서 동일한 App Group을 앱과 Widget Extension 양쪽에 등록해야 합니다.
