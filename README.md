# UltraTools 🏝️

iOS-приложение **UltraTools** — сертификаты и установка приложений, скрытые функции iPhone и Dynamic Island. Сделано на SwiftUI + ActivityKit (Live Activities), требуется **iOS 16.2+**.

## Что внутри

| Вкладка | Что умеет |
|---|---|
| 🏠 **Главная** | Информация об устройстве, статус Live Activities, быстрый доступ к инструментам |
| ✅ **Сертификаты** | Честный разбор способов подписи и установки любых IPA (AltStore, Sideloadly, Apple Developer), пошаговая инструкция |
| 🙈 **Секреты** | Реальные скрытые функции iOS: Back Tap, Field Test `*3001#12345#*`, клавиатура-трекпад, Live Text и др. Кнопка «Открыть» ведёт прямо в нужный раздел Настроек |
| ⚫ **Остров** | Таймер на Dynamic Island: настоящий остров через Live Activities (iPhone 14 Pro и новее), баннер на экране блокировки и плавающая капсула внутри приложения на любом iPhone |

## Честное предупреждение

Приложение на iOS **физически не может** «установить сертификат разработчика навсегда для любых приложений» — так обещают только фейковые приложения из роликов. Сертификаты выдаёт только Apple:

- бесплатный Apple ID — подпись на **7 дней** (продлевается автоматически через AltStore);
- Apple Developer Program ($99/год) — подпись до **1 года**;
- «вечные» корпоративные сертификаты — неофициальные, Apple их отзывает.

Реальный способ ставить любые IPA описан во вкладке «Сертификаты» внутри приложения.

## Сборка

### В Xcode (Mac)

```bash
open UltraTools.xcodeproj
```

1. Выбрать таргет **UltraTools** → Signing & Capabilities → свою команду (Team).
2. Run (⌘R) на устройстве или симуляторе.

### Готовый IPA через GitHub Actions

При каждом пуше в репозиторий воркфлоу [`build-ipa.yml`](.github/workflows/build-ipa.yml) собирает архив на macOS и выкладывает артефакт **UltraTools-unsigned-ipa** (вкладка Actions → последний запуск → Artifacts).

### Установка IPA на iPhone

Так как приложение не из App Store, его нужно подписать своим аккаунтом:

1. Скачайте [AltStore](https://altstore.io) или [Sideloadly](https://sideloadly.io) на компьютер.
2. Войдите под своим Apple ID.
3. Перетащите `UltraTools-unsigned.ipa` в окно программы.
4. Готово — приложение появится на iPhone. AltStore сам продлевает подпись каждые 7 дней по Wi-Fi.

После установки включите **Настройки → UltraTools → Live Activities**, чтобы заработал настоящий Dynamic Island.

## Структура проекта

```
UltraTools.xcodeproj/          — проект Xcode
UltraTools/                    — приложение (таргет UltraTools)
├── UltraToolsApp.swift        — точка входа, вкладки
├── Features/                  — экраны: Главная, Сертификаты, Секреты, Остров, оверлей-капсула
├── Shared/                    — IslandManager + атрибуты Live Activity (общие с виджетом)
└── Resources/                 — Assets.xcassets
IslandWidget/                  — виджет-расширение (таргет IslandWidget):
└── IslandLiveActivity.swift   — разметка Dynamic Island / экрана блокировки
.github/workflows/build-ipa.yml — CI-сборка IPA
```
