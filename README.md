<<<<<<< HEAD
# 📋 FitMate - Kompleksowa Dokumentacja

**FitMate** to nowoczesna aplikacja mobilna stworzona w frameworku **Flutter**, służąca do kompleksowego zarządzania treningami, śledzenia postępów sylwetkowych oraz interakcji społecznościowej.

---

## 🚀 Główne Funkcjonalności

### 💪 Treningi i Plany
*   **Tworzenie Planów:** Budowanie własnych planów treningowych z listą ćwiczeń, serii i powtórzeń.
*   **Aktywny Trening:** Widok `active_workout_screen.dart` pozwala na śledzenie bieżącego treningu w czasie rzeczywistym.
*   **Współdzielenie:** Wysyłanie planów do znajomych i kopiowanie ich do własnej biblioteki.

### 📈 Postępy i Statystyki
*   **Pomiary Ciała:** Moduł `body_measurements_screen.dart` do logowania wagi, obwodów i innych parametrów biometrycznych.
*   **Wykresy:** Profesjonalna wizualizacja postępów za pomocą biblioteki `fl_chart`.
*   **Dashboard:** Szybki podgląd statystyk, celów dziennych oraz ostatniego treningu.

### 📅 Kalendarz i Planowanie
*   **Harmonogram:** Widok kalendarza (`calendar_screen.dart`) zintegrowany z `table_calendar`, umożliwiający planowanie treningów.
*   **Powiadomienia:** System przypomnień o zaplanowanych aktywnościach.

### 👥 System Społecznościowy
*   **Znajomi:** Wyszukiwanie użytkowników, wysyłanie zaproszeń i zarządzanie listą znajomych.
*   **Dzielenie się:** Możliwość wzajemnego inspirowania się planami treningowymi.

---

## 🛠️ Architektura Techniczna

### Zarządzanie Stanem (State Management)
Aplikacja wykorzystuje reaktywny model zarządzania stanem:
*   **AppDataService (Singleton):** Centralny punkt zarządzania danymi. Gwarantuje dostęp do tych samych informacji z każdego miejsca w aplikacji.
*   **ValueNotifier & ValueListenableBuilder:** Zapewniają wysoką wydajność poprzez odświeżanie tylko tych fragmentów UI, które faktycznie uległy zmianie.

### Caching i Offline Support
*   **SharedPreferences:** Wykorzystywane do przechowywania sesji użytkownika, parametrów biometrycznych oraz celów (`Goal`).
*   **Tryb Offline:** Aplikacja cache'uje najważniejsze dane, umożliwiając podgląd planów i ostatniego treningu nawet bez dostępu do sieci.

### Bezpieczeństwo i Uprawnienia
*   **Powiadomienia:** Wymagane uprawnienie `POST_NOTIFICATIONS` (Android 13+) do przypomnień.
*   **Autoryzacja:** Zabezpieczona komunikacja z API przy użyciu tokenów JWT (Bearer).
*   **Internet:** Wymagany dostęp do sieci dla synchronizacji danych z backendem.

---

## 📂 Struktura Projektu

*   📂 `api/`: Klasa `ApiClient` obsługująca całą komunikację HTTP REST.
*   📂 `models/`: Obiekty Dart (np. `Plan`, `Exercise`, `Friend`) z mapowaniem JSON.
*   📂 `screens/`: Widoki UI posegregowane według funkcjonalności.
*   📂 `services/`: Serwisy pomocnicze (logika powiadomień, obsługa danych).
*   📂 `widgets/`: Współdzielone, customowe komponenty interfejsu.
*   📂 `utils/`: Stałe, kolory (`app_colors.dart`) i style.

---

## ⚙️ Konfiguracja Deweloperska

### Stos Technologiczny
*   **Flutter SDK:** `>= 3.2.3`
*   **Biblioteki:** `fl_chart`, `intl`, `table_calendar`, `flutter_local_notifications`.

### Ustawienia Globalne
*   **Base URL:** Adres serwera API znajduje się w `lib/api/api_client.dart`.
*   **Stylizacja:** Główne kolory systemu (np. `mainBackgroundColor`, `accentColor`) zdefiniowane w `lib/utils/app_colors.dart`.
*   **Typografia:** Projekt wykorzystuje czcionkę `SFProDisplay`.

### Instalacja
1. Pobierz zależności: `flutter pub get`
2. Uruchom: `flutter run`

---

> [!NOTE]
> Przy dodawaniu nowych funkcjonalności, zawsze aktualizuj serwisy w `lib/services/`, aby zachować spójność stanu aplikacji w Dashboardzie i Profile Screenie.

*Projekt stworzony z pasją do sportu i technologii.*
