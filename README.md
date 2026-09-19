# UltraTools 🏝️

iOS-приложение **UltraTools** — сертификаты и установка приложений, скрытые функции iPhone и Dynamic Island. Сделано на SwiftUI + ActivityKit (Live Activities), требуется **iOS 16.2+**.

## Что внутри

| Вкладка | Что умеет |
|---|---|
| 🏠 **Главная** | Информация об устройстве, статус Live Activities, быстрый доступ к инструментам |
| 📥 **Установка** | Выбор и настоящий разбор IPA (имя, bundle ID, версия), экспорт в AltStore/ESign и трекер подписи «7 дней» с напоминаниями — как цикл AltStore |
| ✅ **Сертификаты** | Честный разбор способов подписи и установки любых IPA (AltStore, Sideloadly, Apple Developer), пошаговая инструкция |
| 🙈 **Секреты** | По-настоящему скрытые штуки, которых нет в Настройках: IMEI `*#06#`, антипрослушка `*#21#` / `##002#`, sysdiagnose, запись экрана со звуком, клавиатура-трекпад и др. |
| 🔓 **Джейл** | Честный подбор настоящего джейлбрейка под ваше устройство: palera1n (A11 и старше, навсегда, checkm8) и Dopamine (A12+, iOS 15–16.5) + правила «без потери файлов» |
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

### 📥 Скачать готовый IPA

Прямая ссылка (всегда актуальная версия): **https://github.com/kulikoff-ad/Ultra/releases/latest/download/UltraTools-unsigned.ipa**

Или в разделе **[Releases](https://github.com/kulikoff-ad/Ultra/releases/latest)** — файл **UltraTools-unsigned.ipa**. При каждом обновлении кода CI пересобирает и обновляет файл автоматически.

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
