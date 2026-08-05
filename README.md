# Inside the Circuit

Mobil cihazlar için Flutter ve Flame ile geliştirilen top-down survival / endless arcade mini oyunu.

Oyuncu, arızalanan bir devre üzerinde hareket eden elektrik sinyalini kontrol eder. Electron toplayarak puan kazanır, Capacitor ile geçici shield etkinleştirir ve gittikçe hızlanan elektrik tehlikelerinden kaçınır.

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
- `lib/services`: Kalıcı ayarlar ve sessiz çalışabilen audio servis arayüzü.
- `lib/game/gameplay_config.dart`: Bütün gameplay tuning değerlerinin tek kaynağı.

Gameplay zamanlaması Flame `update(dt)` döngüsünde yürütülür. Flutter `Timer` kullanılmaz. Görseller programatik hazırlanmıştır; component yapısı daha sonra sprite ve ses asset'leri eklenmesine uygundur. Lisanslı ses asset'leri eklenene kadar audio servisi güvenle sessiz çalışır ve ek bir audio dependency kullanılmaz.

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

Android ve iOS platform dosyaları mevcuttur. Android release build'i Gradle'ın loopback bağlantısına izin veren normal bir geliştirme ortamında; iOS build'i ise macOS/Xcode ortamında doğrulanmalıdır.
