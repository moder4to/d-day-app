# Git Workflow

## 역할 분리

현재 개발 환경은 다음처럼 나눕니다.

- Windows: 문서 작성, 소스 수정, 커밋, 푸시
- MacBook Pro 2017: pull, Xcode 프로젝트 관리, 빌드, 테스트

Windows에 Git이 설치되어 있지 않다면 먼저 Git for Windows를 설치하고 PowerShell을 새로 열어야 합니다.

```powershell
winget install --id Git.Git -e
```

설치 후 확인:

```powershell
git --version
```

## 초기 클론

Windows에서 이 폴더를 Git 저장소로 사용하려면:

```powershell
cd D:\Dev
git clone https://github.com/moder4to/d-day-app.git
cd d-day-app
```

이미 이 폴더에 파일이 있다면, 빈 임시 폴더에 클론한 뒤 파일을 옮기거나 Git 초기화를 별도로 진행합니다.

## 브랜치 이름

작업 브랜치는 Codex 기본 규칙에 맞춰 `codex/` 접두사를 사용합니다.

예시:

```bash
git switch -c codex/initial-app-structure
```

## 커밋 전 확인

Windows에서는 Xcode 빌드를 하지 않는 대신 다음을 확인합니다.

- 의도하지 않은 파일이 포함되지 않았는지
- 문서가 최신 흐름과 맞는지
- Xcode에서 생성되는 사용자별 파일이 커밋되지 않았는지

```bash
git status
git diff --stat
```

## Mac 테스트 흐름

Windows에서 푸시한 뒤 Mac에서:

```bash
git pull
open d-day-app.xcodeproj
```

이후 Xcode에서 빌드와 테스트를 진행합니다.
