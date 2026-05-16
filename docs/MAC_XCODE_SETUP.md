# Mac Xcode Setup

이 저장소는 최신 Xcode에서 iOS 18 이상을 대상으로 개발하는 프로젝트를 기준으로 합니다. Windows에서는 문서와 소스 구조를 정리하고 푸시하며, 실제 빌드와 테스트는 Mac에서 진행합니다.

## 1. 저장소 클론

Mac에서 실행합니다.

```bash
git clone https://github.com/moder4to/d-day-app.git
cd d-day-app
```

## 2. Xcode 프로젝트 열기

```bash
open d-day-app.xcodeproj
```

## 3. 빌드 설정 확인

- Deployment Target: iOS 18.0
- Signing Team: 본인 Apple ID 또는 팀
- Bundle Identifier: 현재 `yhb.d-day-app`
- Widget Extension Bundle Identifier: 현재 `yhb.d-day-app.widgets`
- App Group: `group.yhb.d-day-app`

잠금화면 위젯과 제어센터 컨트롤을 실기기에서 사용하려면 Apple Developer 계정에서 앱과 Widget Extension 양쪽에 같은 App Group capability를 등록해야 합니다.

## 4. 첫 빌드

Mac에서만 실행합니다.

```bash
xcodebuild -scheme d-day-app -destination 'platform=iOS Simulator,name=iPhone 17' build
```

또는 Xcode에서 시뮬레이터를 선택하고 Run을 누릅니다.
