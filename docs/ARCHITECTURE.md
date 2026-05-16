# Architecture

## 기술 선택

- SwiftUI: iOS 18 기준의 기본 UI 프레임워크
- SwiftData: MVP의 로컬 저장소
- MVVM-lite: 화면 상태가 커지는 시점부터 ViewModel을 도입
- Foundation Calendar: D-Day 계산의 기준 API

## 앱 구조

```text
d-day-app/
  d_day_appApp.swift
  ContentView.swift
  App/
    AppRootView.swift
  Core/
    Models/
      AnniversaryKind.swift
      CoupleProfile.swift
      DayEvent.swift
    Shared/
      DaySurfaceConstants.swift
      DaySurfaceSnapshot.swift
      OpenDdayAppIntent.swift
    Utilities/
      DayCounter.swift
  DesignSystem/
    AppTheme.swift
  Features/
    Home/
      HomeView.swift
    EventEditor/
      EventEditorView.swift
    Settings/
      SettingsView.swift
  Assets.xcassets/
  Preview Content/
d-day-appWidgets/
  d_day_appWidgetsBundle.swift
  DDayLockScreenWidget.swift
  DDayControlWidget.swift
```

## 데이터 모델

### CoupleProfile

기준 프로필 정보를 저장합니다.

- 내 이름
- 상대 이름
- 시작일
- 메모

### DayEvent

개별 D-Day 항목입니다.

- 제목
- 날짜
- 종류
- 반복 규칙
- 고정 여부
- 메모
- 색상

## 날짜 계산 기준

- 미래 날짜: `D-n`
- 오늘: `D-Day`
- 지난 날짜: `D+n`
- 시작일을 세는 경우에는 첫날을 1일로 계산합니다.
- 매년 반복 일정은 다음 발생일 기준으로 계산합니다.
- 2월 29일 반복 일정은 비윤년에 2월 28일로 계산합니다.

날짜 계산은 `DayCounter`에 모아두어 화면마다 계산 기준이 달라지지 않게 합니다.

## Xcode 프로젝트

`d-day-app.xcodeproj`는 이미 저장소에 포함되어 있습니다. 새 Swift 파일을 추가할 때는 Xcode에서 타깃 멤버십을 확인하거나 `project.pbxproj`의 Sources 빌드 단계에 포함되어 있는지 확인합니다.

## 저장소 전략

MVP에서는 SwiftData 로컬 저장을 사용합니다. 공유나 기기 간 동기화가 필요해지는 시점에 CloudKit 전환을 검토합니다.

## 빠른 확인 전략

iOS 18 기준으로 잠금화면 위젯과 제어센터 컨트롤을 제품 표면에 포함합니다. 앱 본체는 SwiftData 모델에서 대표 D-Day 스냅샷을 만들고, `group.yhb.d-day-app` App Group의 UserDefaults에 JSON으로 저장합니다. Widget Extension은 이 스냅샷을 읽어 잠금화면 accessory 위젯과 제어센터 `ControlWidget`을 렌더링합니다.

앱에서 데이터가 바뀌면 `SystemSurfaceSync`가 `WidgetCenter`와 `ControlCenter`에 reload를 요청합니다. 실제 기기 배포 전에는 Apple Developer 계정에서 앱 타깃과 `d-day-appWidgets` 타깃 모두에 동일한 App Group capability를 등록해야 합니다.

## ViewModel 도입 기준

초기 화면은 SwiftUI View와 SwiftData `@Query`로 단순하게 시작합니다. 다음 조건 중 하나가 생기면 ViewModel을 분리합니다.

- 화면 상태가 3개 이상 얽힌다.
- 비동기 작업이 들어간다.
- 날짜 계산 외의 비즈니스 로직이 화면에 길게 들어간다.
- 테스트해야 할 상태 전이가 생긴다.
