# Mac Xcode Setup

이 저장소는 MacBook Pro 2017의 Xcode 15.2에서 이미 생성된 iOS 프로젝트를 기준으로 합니다. Windows에서는 문서와 소스 구조를 정리하고 푸시하며, 실제 빌드와 테스트는 Mac에서 진행합니다.

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

- Deployment Target: iOS 17.0
- Signing Team: 본인 Apple ID 또는 팀
- Bundle Identifier: 현재 `yhb.d-day-app`

## 4. 첫 빌드

Mac에서만 실행합니다.

```bash
xcodebuild -scheme d-day-app -destination 'platform=iOS Simulator,name=iPhone 15' build
```

또는 Xcode에서 시뮬레이터를 선택하고 Run을 누릅니다.
