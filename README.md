# TopMemo

<p align="center">
  <img src="image/TopMemo_app_ic.png" alt="TopMemo icon" width="120">
</p>

> 아이디어, 누르고 바로 타이핑.
<br/>
<div align="center">
  TopMemo는 macOS 메뉴 막대에서 팝오버로 사용하는 메모 앱입니다.<br/>
상단 아이콘을 클릭하거나 단축키를 누르면 팝오버가 열리고, 바로 타이핑을 시작할 수 있습니다.<br/>
무거운 문서 앱을 열지 않고도 아이디어, 할 일, 임시 메모를 빠르게 남기고 다시 꺼내 쓰는 흐름에 집중했습니다.
</div>

## 최근 업데이트

### 2026-03-24 · v1.0.3

- 전역 단축키 기능 추가
- 설정 화면 개편

## 주요 기능

- 메뉴 막대 상주형 메모 UI/UX
- 어디서나 바로 작성, 메모 리스트, 빠른 재편집, 원클릭 복사
- 5가지 색상 팔레트(검정, 빨강, 파랑, 초록, 노랑)
- 전역 단축키 `⌘ + ⇧ + M`, 설정에서 재지정 가능
- 마크다운 스타일 목록 입력 시 다음 줄 번호/불릿 자동 이어쓰기
- 로컬 저장: `~/Library/Application Support/TopMemo/notes.json` (내보내기 및 복원 지원)

## 이런 분들을 위해

- 떠오르는 아이디어를 잊기 전에 남기고 싶은 당신
- 회의 중 짧게 끄적일 메모가 필요한 당신
- 텍스트를 빠르게 정리하고 다시 복사해 쓰는 흐름이 중요한 당신

## 단축키

- 전역 실행: 기본 `⌘ + ⇧ + M`
- 전역 단축키 규칙: `커맨드`, `옵션`, `컨트롤` 중 하나 + `Shift` + 영문 1자
- 새 메모: `Cmd+N`
- 팝오버 닫기: `Esc`

## 설치

### GitHub Releases에서 설치

1. 저장소 `Releases`에서 최신 `TopMemo.dmg`를 다운로드합니다.
2. `TopMemo.app`을 `Applications` 폴더로 드래그합니다.
3. 앱을 실행하면 메뉴 막대에 TopMemo 아이콘이 나타납니다.

## 로컬에서 빌드하기

이 저장소는 Xcode 프로젝트 대신 셸 스크립트로 직접 앱 번들을 생성합니다.

### 요구 사항

- macOS 13 이상
- `xcrun`, `swiftc`, `swift-stdlib-tool`, `codesign`, `sips` 사용 가능 환경
- 아이콘/DMG 리소스 생성을 위한 Apple 개발 도구: `DeRez`, `Rez`, `SetFile`

실제 사용에서는 Xcode가 설치된 환경이 가장 안전합니다.

### 앱 빌드

```sh
zsh Distribution/build-app.sh
open build/TopMemo.app
```

### DMG 생성

```sh
zsh Distribution/make-dmg.sh
open build/TopMemo.dmg
```

### 생성 결과물

- 앱 번들: `build/TopMemo.app`
- 디스크 이미지: `build/TopMemo.dmg`

## 기술 스택

- SwiftUI
- AppKit

## 참고

- TopMemo는 macOS 전용 앱입니다.
