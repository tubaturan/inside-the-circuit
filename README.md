# Inside the Circuit

Mobil cihazlar için Flutter ve Flame ile geliştirilen top-down survival / endless arcade mini oyunu.

Oyuncu, arızalanan bir devre üzerinde hareket eden elektrik sinyalini kontrol eder. Electron toplayarak puan kazanır, Capacitor ile geçici shield etkinleştirir ve gittikçe hızlanan elektrik tehlikelerinden kaçınır.

`START SYSTEM` sonrasında açılan Mission Briefing, çökmekte olan sistemin hikâyesini, devre haritasını ve oyuncunun görevlerini tanıtır.

## Kontroller

- Ekranda herhangi bir noktaya dokunup sürükleyerek sinyali hareket ettirin.
- Pause düğmesi oyunu, skor ve bütün gameplay sayaçları dahil olmak üzere durdurur.
- Shield ilk tehlike çarpışmasını engeller veya beş saniye sonunda kapanır.

## Skor

```text
floor(survivalSeconds) + electronCount * 10
```

## Mimari

- `lib/game`: Flame oyunu, component'ler, session, spawn ve difficulty mantığı.
- `lib/presentation`: Flutter overlay'leri ve Riverpod controller'ları.
- `lib/services`: Kalıcı ayarlar ve Flame Audio tabanlı ses servisi.
- `lib/game/gameplay_config.dart`: Bütün gameplay tuning değerlerinin tek kaynağı.

Gameplay zamanlaması Flame `update(dt)` döngüsünde yürütülür. Flutter `Timer` kullanılmaz. Görseller programatik hazırlanmıştır. Kısa ses efektleri ve döngüsel arka plan müziği proje için özgün olarak sentezlenmiş ve Flame Audio ile preload edilmiştir; desteklenmeyen bir audio backend gameplay'i durdurmaz.

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Kalite kontrolleri

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
```

## Platformlar

Android, iOS ve web platform dosyaları mevcuttur.

- Web release build'i başarıyla doğrulandı: `flutter build web --release`
- Android release build'i yerel Windows ortamında başarıyla doğrulandı: `flutter build apk --release`
- Doğrulanan sesli Android APK çıktısı: `build/app/outputs/flutter-apk/app-release.apk` (20.9 MB)
- iOS build'i Windows ortamında alınmadı; macOS ve Xcode ile doğrulanmalıdır.
