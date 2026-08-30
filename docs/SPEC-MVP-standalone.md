# SPECYFIKACJA MVP — „Piętro Obok” (robocza nazwa): hiperlokalna aplikacja pomocy sąsiedzkiej

Wersja 1.0 · 30.08.2026 · Dokument samodzielny — zawiera wszystko, co potrzebne do implementacji, bez zewnętrznego kontekstu.

## 0. Produkt w trzech zdaniach

Aplikacja webowa (PWA) dla jednego osiedla: mieszkańcy wrzucają drobne zadania („wnieś pranie”, „napraw WiFi”, „zrób zakupy”), sąsiedzi je biorą — **za darmo** (moduł „Pomoc”) albo, w późniejszej fazie, za pieniądze umawiane poza aplikacją (moduł „Zlecenia”). Pilotaż: osiedle Zaspa w Gdańsku, z naciskiem na wymianę między seniorami a studentami (senior też **oferuje**: obiad, przepis, doświadczenie — to wymiana, nie opieka). Aplikacja nie przetwarza żadnych płatności.

## 1. Stack (wymagany)

- **Backend:** Python 3.12+, **Django 5.x**, PostgreSQL 16 + **PostGIS** (geografia), kolejka zadań na Postgresie (`procrastinate` albo `django-q2` — bez Redisa).
- **Frontend:** szablony Django (server-rendered) + **htmx** dla interaktywności; bez SPA/Reacta. Mobile-first.
- **PWA:** manifest, service worker, **Web Push (VAPID, bez Firebase)**; instrukcja instalacji na iOS („Udostępnij → Do ekranu początkowego”) pokazywana użytkownikom Safari.
- **E-mail:** dowolny SMTP (konfiguracja przez zmienne środowiskowe); wysyłka przez kolejkę.
- **SMS:** interfejs `SmsProvider` z implementacją `ConsoleSmsProvider` (log do konsoli) — realny provider podpinany później.
- **Deploy:** `docker-compose.yml` (app + postgres), `Dockerfile`, komenda seedująca dane demo. CI: pytest + ruff.
- Cała aplikacja i UI **po polsku**.

## 2. Model danych

Wszystkie modele z `created_at`/`updated_at`. Pola kluczowe (dopuszczalne rozsądne rozszerzenia):

- **Estate** — osiedle: `name`, `slug`, `polygon` (PostGIS MultiPolygon), `status` (`waitlist`|`active`), `threshold_seniors` (domyślnie 60), `threshold_students` (domyślnie 40).
- **WaitlistEntry** — `estate`, `email`, `group` (`senior`|`student`|`other`), `offers_text`, `needs_text`, `referral_code` (unikalny), `referred_by` (FK na WaitlistEntry, opcjonalne), `position` (wyliczana), `is_founding` (bool).
- **User** (rozszerzenie AbstractUser) — logowanie **magic-linkiem e-mail** (bez haseł w MVP), `phone` (opcjonalny), `participant_type` (`senior`|`student`|`neighbor`), `display_name`, `photo`, `bio`, `accessibility_mode` (bool — duża czcionka/kontrast), `is_shadow` (bool — konto-cień zakładane przez ambasadora dla osoby bez internetu; taki użytkownik jest obsługiwany przez SMS/telefon i nie loguje się).
- **Membership** — `user`, `estate`, `address_full` (widoczny wyłącznie dla moderacji — nigdy dla innych użytkowników), `address_public` (ulica bez numeru mieszkania), `trust_level` (`L0`|`L1`|`L2`|`L3`), `verification_method`, `is_ambassador` (bool).
- **InviteCode** — `code`, `estate`, `issued_by`, `max_uses`, `used_count`, `expires_at`. Użycie kodu przy rejestracji ⇒ trust_level L2.
- **Task** — `author`, `estate`, `module` (`HELP`|`GIG`), `title`, `description`, `photos` (0–3), `status` (`open`|`assigned`|`done`|`expired`|`cancelled`), `deadline` (opcjonalny), `pay_range_text` (tekst, **tylko** GIG; formularz HELP w ogóle nie zawiera tego pola), `created_via_proxy_by` (FK User, opcjonalne — audyt: kto dodał w czyimś imieniu).
- **Application** — `task`, `applicant`, `message`, `status` (`pending`|`chosen`|`rejected`).
- **Message** — `task`, `sender`, `recipient`, `body` (czat 1:1 wyłącznie autor↔wybrany/zgłoszony w kontekście zadania).
- **Kudos** — `task`, `from_user`, `to_user`, `text` (≤200 znaków); możliwe dopiero po `done`, obustronne.
- **Pair** — wyliczany rekord: `user_a`, `user_b`, `estate`, `completed_count`; para jest „żywa”, gdy `completed_count ≥ 3`.
- **Report** — zgłoszenie treści: `content_type`+`object_id`, `reporter_email` (zgłosić może **osoba niezalogowana**), `reason`, `status` (`new`|`resolved`|`dismissed`), `decision_note` (uzasadnienie wysyłane zgłaszającemu i autorowi treści).
- **AuditLog** — akcje moderacyjne, zmiany trust_level, akcje proxy: `actor`, `action`, `target`, `timestamp`, `note`.
- **LiquidityStat** — dzienny snapshot per osiedle: `date`, `estate`, `fill_rate` (odsetek zadań z ≥1 zgłoszeniem w 24 h), `median_first_response_minutes`, `active_users_7d`, `tasks_opened`, `tasks_done`, `live_pairs`, `seniors_with_consumed_offer_pct`, `referral_signup_pct`.

## 3. Funkcje i kryteria akceptacji

### F1. Landing + waitlista (dla osiedla w statusie `waitlist`)
- Strona główna osiedla pokazuje: opis produktu, **dwa liczniki progu** („Seniorzy i sąsiedzi z doświadczeniem: X/60”, „Studenci: Y/40”) i formularz zapisu (e-mail, grupa, „co mogę dać”, „czego szukam”, zgoda RODO — checkbox z linkiem do polityki).
- Po zapisie użytkownik widzi **swoją pozycję w kolejce** i **link polecający**; każdy skuteczny zapis z linku przesuwa polecającego w górę kolejki; pierwsze 100 zapisów dostaje trwałą odznakę „Pierwszy Sąsiad”.
- Zapis z adresem/geolokalizacją spoza aktywnych osiedli trafia do **kolejki dzielnic**: publiczna podstrona z listą osiedli oczekujących i licznikami („Przymorze: 34/100”).
- Kryterium: osiedle `waitlist` nie ujawnia żadnych treści tablicy; przełączenie na `active` wykonuje wyłącznie admin.

### F2. Rejestracja i weryfikacja warstwowa (osiedle `active`)
- Logowanie magic-linkiem (e-mail). Poziomy zaufania:
  - **L0**: potwierdzony e-mail;
  - **L1**: geolokalizacja przeglądarki w momencie rejestracji wypada wewnątrz poligonu osiedla (jednorazowy check, bez śledzenia) **oraz** podany adres (autouzupełnianie po tabeli adresów — patrz F8);
  - **L2**: użycie ważnego `InviteCode` (od ambasadora/sąsiada L2+);
  - **L3**: nadawany ręcznie przez admina.
- Bramki uprawnień (parametry w ustawieniach): publikowanie zadań od **L1**; zgłaszanie się do zadań od **L2**.
- Profil wymaga zdjęcia i bio oraz wypełnienia „oferuję”/„potrzebuję” (min. po 1 pozycji) zanim zgłoszenia użytkownika staną się widoczne dla autorów zadań.
- Innym użytkownikom nigdy nie pokazuje się pełny adres — najwyżej `address_public`.

### F3. Tablica zadań — moduł HELP (bez cen)
- Lista zadań osiedla (filtr: otwarte/wszystkie; sort: najnowsze), karta zadania, formularz dodania (tytuł ≤80 znaków, opis, do 3 zdjęć — **EXIF usuwany przy uploadzie**, deadline opcjonalny). Formularz HELP **nie zawiera** żadnego pola kwoty/wynagrodzenia.
- Cykl: `open` → zgłoszenia z wiadomością → autor wybiera jedną osobę (`assigned`) → czat 1:1 → autor oznacza `done` → obie strony mogą zostawić Kudos. Autor może anulować; zadanie bez aktywności 30 dni ⇒ `expired` (job w kolejce).
- Moduł **GIG** (z `pay_range_text`) jest zaimplementowany, ale **wyłączony flagą funkcji** (`GIG_ENABLED=false` domyślnie); przy włączonym GIG tablice HELP i GIG to **osobne zakładki** o odrębnym nagłówku i kolorze — nigdy jedna wspólna lista.

### F4. Proxy / ambasador (offline-to-online)
- Użytkownik z `is_ambassador` może: założyć konto-cień seniora (imię, telefon, adres, zgoda odnotowana checkboxem) i dodać zadanie **w jego imieniu**; każda taka akcja zapisuje się w AuditLog.
- Konto-cień otrzymuje powiadomienia SMS-em (przez `SmsProvider`); odpowiedzi zgłaszających ambasador przekazuje telefonicznie i odnotowuje wybór w aplikacji.

### F5. Powiadomienia
- **Web Push**: wyłącznie o sprawach użytkownika — nowe zgłoszenie do mojego zadania, wybrano mnie, nowa wiadomość. Nic więcej.
- **Digest e-mail** (domyślnie dzienny, wyłączalny): nowe zadania z mojego osiedla.
- **SMS**: dla kont-cieni i użytkowników bez push — zdarzenia jak w Web Push.

### F6. Moderacja + zgodność z DSA
- Przycisk „Zgłoś” przy każdym zadaniu, wiadomości, profilu i kudos — **działa także dla niezalogowanych** (formularz z e-mailem).
- Zgłaszający dostaje automatyczne potwierdzenie przyjęcia; po decyzji moderatora — e-mail z rozstrzygnięciem i uzasadnieniem (szablon); autor usuniętej treści dostaje uzasadnienie.
- Panel moderacji = Django admin: kolejka zgłoszeń, ukrywanie treści, blokada użytkownika, zmiana trust_level; wszystko logowane w AuditLog.
- Rate-limity: maks. 5 zadań/dobę i 20 wiadomości/godz. na użytkownika.
- Strony statyczne: regulamin, polityka prywatności, **punkt kontaktowy** (e-mail) — linkowane w stopce.
- Retencja: job kolejki anonimizuje treść zadań i czatów 12 miesięcy po zamknięciu.

### F7. Metryki i dashboard operatora
- Nocny job liczy `LiquidityStat` (definicje pól w §2).
- Widok `/panel/` (tylko staff): tabela + proste wykresy ostatnich 30 dni per osiedle: fill rate, mediana czasu pierwszej odpowiedzi, żywe pary, % seniorów, których „oferuję” zostało skonsumowane (ktoś wziął ich zadanie odwrotne lub zostawił im Kudos za ofertę), % zapisów z referrali, stan kolejek dzielnic.

### F8. Geografia
- Model `AddressPoint` (ulica, numer, punkt geo) + komenda importu z pliku CSV/GML (format punktów adresowych PRG/GUGiK; w repo **plik przykładowy** z ~50 adresami Zaspy do developmentu).
- Autouzupełnianie adresu w rejestracji (trigram/ILIKE po ulicy+numerze, ograniczone do osiedli w bazie).
- Poligon osiedla wprowadzany w adminie (pole mapowe lub wklejany GeoJSON); przypisanie adresu/geolokacji do osiedla przez point-in-polygon.

### F9. Dostępność i UX
- WCAG 2.1 AA: kontrasty, focus, etykiety formularzy, nawigacja klawiaturą.
- Przełącznik „duża czcionka” (zapamiętywany na koncie), język interfejsu prosty, bez anglicyzmów; każdy ekran ma w stopce numer telefonu pomocy (konfigurowalny).
- Wiek: przy rejestracji checkbox „mam ukończone 18 lat” (wymagany).

## 4. Dane demo (komenda `seed_demo`)

Tworzy: osiedle „Zaspa-Młyniec” (status `active`, przykładowy poligon), osiedle „Przymorze” (`waitlist`), 12 użytkowników (4 seniorów, 4 studentów, 2 ambasadorów, 2 zwykłych, różne trust_level), 10 zadań HELP w różnych stanach, 2 pary z historią, 3 zgłoszenia moderacyjne, 30 dni wygenerowanych LiquidityStat.

## 5. Testy (wymagane, pytest)

Minimum: bramki uprawnień L0–L3 (kto może publikować/zgłaszać się); cykl zadania ze wszystkimi przejściami stanów; brak pola kwoty w formularzu HELP i obecność w GIG (przy włączonej fladze); mechanika referrali i pozycji w kolejce; point-in-polygon (adres w/poza poligonem); zgłoszenie treści przez niezalogowanego + wysyłka potwierdzenia; anonimizacja po retencji; wyliczanie fill_rate i median_first_response na danych syntetycznych; niewidoczność pełnego adresu dla innych użytkowników.

## 6. Definition of Done

`docker compose up` + `migrate` + `seed_demo` daje działającą aplikację z danymi demo; wszystkie testy zielone; ruff bez błędów; landing waitlisty i tablica działają na mobile (viewport 390px); README z instrukcją uruchomienia i listą zmiennych środowiskowych.

## 7. Poza zakresem (nie implementować)

Płatności/escrow/portfele; jakiekolwiek kwoty w HELP; aplikacje natywne; feed dyskusyjny/komentarze poza czatem zadania; ML/personalizacja; panel dla zarządców; wielojęzyczność; integracje eID; geofencing w tle; publiczne API.
