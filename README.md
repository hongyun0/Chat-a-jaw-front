# chatajaw

## Getting Started

1. SDK 설치

```bash
$ cd ~/development
$ wget https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_v1.12.13+hotfix.8-stable.zip
$ unzip ./flutter_macos_v1.12.13+hotfix.8-stable.zip
```

2. path 에 추가

```bash
$ export PATH="$PATH:`pwd`/flutter/bin"
```

3. 바이너리 설치

```bash
$ flutter precache
```

4. Xcode 설치

```bash
$ sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
$ sudo xcodebuild -runFirstLaunch
```

5. iOS 시뮬레이터 실행

```bash
$ open -a Simulator
```

6. 플루터 실행

```bash
$ flutter run
```
