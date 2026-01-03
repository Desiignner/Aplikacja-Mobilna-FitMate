📋 Dokumentacja Projektu: FitMate
FitMate to nowoczesna aplikacja mobilna stworzona w frameworku Flutter, służąca do zarządzania treningami, śledzenia postępów sylwetkowych oraz interakcji społecznościowej między użytkownikami (dzielenie się planami treningowymi).

1. Architektura Projektu
Aplikacja została zaprojektowana w sposób modularny, co ułatwia jej rozwój i konserwację. Główne katalogi w folderze lib/:

📂 api/: Zawiera logikę komunikacji z backendem (api_client.dart). Obsługuje zapytania HTTP, autoryzację oraz pobieranie danych.
📂 models/: Definicje struktur danych (klasy Dart).
plan.dart
, 
exercise.dart
 – dane treningowe.
friend.dart
, 
friend_request.dart
 – system znajomych.
goal.dart
, 
shared_plan.dart
 – cele i współdzielenie.
📂 screens/: Logika i interfejs poszczególnych widoków aplikacji.
📂 services/: Serwisy pomocnicze, np. powiadomienia (notification_service.dart) czy zarządzanie danymi lokalnymi (app_data_service.dart).
📂 widgets/: Współdzielone komponenty UI (customowe przyciski, karty, wykresy).
📂 utils/: Funkcje pomocnicze i stałe.


2. Główne Funkcjonalności
💪 Treningi i Plany
Tworzenie Planów: Możliwość budowania własnych planów treningowych z listą ćwiczeń i serii.
Aktywny Trening: Widok 
active_workout_screen.dart
 pozwala na śledzenie bieżącego treningu w czasie rzeczywistym.
Współdzielenie: Funkcja wysyłania planów do znajomych i kopiowania ich do własnej biblioteki.

📈 Postępy i Statystyki
Pomiary Ciała: Moduł 
body_measurements_screen.dart
 do logowania wagi, obwodów i innych parametrów.
Wykresy: Wizualizacja postępów za pomocą biblioteki fl_chart.
Dashboard: Główne podsumowanie aktywności użytkownika.

📅 Kalendarz i Planowanie
Harmonogram: Widok kalendarza (
calendar_screen.dart
) zintegrowany z table_calendar, umożliwiający planowanie treningów na konkretne dni.

👥 System Społecznościowy
Znajomi: Wyszukiwanie użytkowników, wysyłanie zaproszeń i zarządzanie listą znajomych.
Interakcje: Przeglądanie aktywności i współdzielonych materiałów.


3. Stos Technologiczny
Framework: Flutter (Dart)
Komunikacja API: http (REST API)
Wykresy: fl_chart
Data i Czas: intl
Przechowywanie lokalne: shared_preferences
Powiadomienia: flutter_local_notifications
Kalendarz: table_calendar


4. Integracja z API
Aplikacja komunikuje się z zewnętrznym serwerem za pośrednictwem klasy ApiClient.

Autoryzacja: Obsługa logowania i rejestracji (JWT/Tokeny).
Endpointy:
/api/plans – zarządzenie planami.
/api/plans/shared-with-me – pobieranie planów udostępnionych przez innych.
/api/friends – zarządzanie relacjami.
/api/measurements – synchronizacja pomiarów ciała.


5. Instrukcja Uruchomienia (Setup)
Wymagania: Zainstalowany Flutter SDK oraz emulator (Android/iOS) lub podłączone urządzenie fizyczne.
Pobranie zależności:
bash
flutter pub get
Uruchomienie aplikacji:
bash
flutter run
