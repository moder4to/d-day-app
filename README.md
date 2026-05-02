# D-Day App

커플이 함께 기념일, 만난 날, 생일, 여행일 같은 중요한 날짜를 예쁘고 가볍게 관리하는 iOS 17 D-Day 앱입니다.

## 개발 기준

- Platform: iOS 17+
- IDE: Xcode 15.2
- UI: SwiftUI
- Local data: SwiftData
- Repository: https://github.com/moder4to/d-day-app

## 현재 구현

이 저장소는 로컬 저장 기반 MVP 구현 단계입니다. Windows 환경에서는 문서와 소스 구조를 정리하고 GitHub로 푸시하는 용도로 사용하며, pull, 빌드, 테스트는 MacBook Pro 2017에서 진행합니다.

- 첫 실행 커플 프로필 입력
- 함께한 날 수 표시
- D-Day 추가, 수정, 삭제
- 생일/기념일용 매년 반복 계산
- 고정 D-Day와 다가오는 날 목록
- SwiftData 로컬 저장

## 폴더 구조

```text
d-day-app/
  App/               루트 탭 구조
  Core/              모델, 유틸리티, 공통 로직
  DesignSystem/      색상, 간격, 공통 스타일
  Features/          화면 단위 기능
  Assets.xcassets/   앱 아이콘과 색상 에셋
  Preview Content/   프리뷰 전용 리소스
d-day-app.xcodeproj/ Xcode 프로젝트
d-day-appTests/      단위 테스트
d-day-appUITests/    UI 테스트
docs/
  PRODUCT_BRIEF.md   제품 방향과 MVP 범위
  ARCHITECTURE.md    앱 구조와 기술 결정
  MAC_XCODE_SETUP.md 맥에서 Xcode 프로젝트를 연결하는 절차
  GIT_WORKFLOW.md    Windows/Mac 분리 작업 흐름
  ROADMAP.md         개발 마일스톤
```

## Mac에서 시작하기

자세한 절차는 [docs/MAC_XCODE_SETUP.md](docs/MAC_XCODE_SETUP.md)를 참고하세요.

요약:

```bash
git clone https://github.com/moder4to/d-day-app.git
cd d-day-app
```

그 다음 Xcode 15.2에서 `d-day-app.xcodeproj`를 열고 빌드합니다.
