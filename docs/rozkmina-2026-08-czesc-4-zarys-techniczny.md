# Pomoc sąsiedzka — rozkmina, część IV: techniczny zarys projektu

Stan: sierpień 2026. Zarys wyprowadzony z ustaleń [części I](rozkmina-2026-08-badanie-rynku.md)–[III](rozkmina-2026-08-czesc-3-sensownosc-solo.md) oraz dedykowanego researchu technicznego (sekcja 12 — źródła). To projekt fazy 1 (walidacja na 1–3 osiedlach, bez pieniędzy w platformie) z jawnie zostawionymi szwami pod fazę 2.

## 1. Zasady projektowe (z badań, nie z gustu)

1. **Boring tech, monolit.** Utrzymuje to jedna osoba + fabryka LLM; każda technologia ponad niezbędne minimum to koszt utrzymania bez przychodu. Zero mikroserwisów, zero Kubernetesa.
2. **Metryka płynności jako obywatel pierwszej kategorii.** Fill rate i czas pierwszej odpowiedzi per osiedle są liczone w rdzeniu domeny od pierwszego commita — to one decydują o kill/go (część III), nie liczba rejestracji.
3. **Separacja strumieni Pomoc/Zlecenia** (crowding-out, część I §4.3; wzorzec Karrot, część II §4.4) — na poziomie modelu danych i UI, nie flagi na ogłoszeniu.
4. **Brak pieniędzy w systemie = brak DAC7, PSP, KYC, escrow** (część I §4.6). Faza 1 nie przechowuje ani nie przekazuje żadnych kwot; pole „widełki" przy zleceniu to tekst informacyjny.
5. **Prywatność przez minimalizację**: pełny adres zna system, sąsiedzi widzą co najwyżej „ul. Kwiatowa, osiedle X". Dane adresowe + relacje sąsiedzkie ⇒ DPIA przed startem (obowiązkowa w praktyce — sekcja 9).
6. **Wszystko, co odróżnia od grupy FB, musi istnieć w MVP**: struktura zadania, stan „załatwione", reputacja, geografia. Wszystko inne — nie.

## 2. Zakres fazy 1

**Jest:** waitlista osiedla → aktywacja po progu; rejestracja z weryfikacją warstwową; dwa moduły tablicy (Pomoc: bez cen / Zlecenia: z widełkami tekstowymi); zgłoszenie się do zadania + wybór wykonawcy; czat 1:1 w kontekście zadania; zamknięcie zadania („załatwione" + podziękowanie/ocena); profil z poziomem zaufania; powiadomienia (web push + e-mail digest); moderacja (panel + zgłoszenia notice&action); metryki płynności.

**Nie ma (twarde wykluczenia fazy 1):** płatności, escrow, ubezpieczeń, kalendarza, kategorii usług profesjonalnych, feedu dyskusyjnego (lekcja Nextdoor: dyskusje = toksyczność + koszt moderacji), aplikacji natywnych, panelu zarządcy, wielojęzyczności.

## 3. Architektura

```
[PWA (instalowana)  ]        [e-mail digest]
[Safari/Chrome      ]              ▲
        │ HTTPS                    │
        ▼                          │
┌─────────────────────────────────────────────┐
│  Django (monolit)                           │
│  - domena: osiedla, zadania, reputacja      │
│  - HTML server-rendered + htmx (tablica)    │
│  - DRF tylko tam, gdzie PWA musi (push,     │
│    geolokalizacja, service worker)          │
│  - Django admin = panel moderacji           │
│  - kolejka zadań na Postgresie (procrastinate/django-q2) │
└──────────────┬──────────────────────────────┘
               ▼
   PostgreSQL + PostGIS (jedna baza:
   dane + geo + kolejka + sesje)
   S3-compatible (zdjęcia zadań)
```

**Uzasadnienia:**
- **Django, nie FastAPI/Node**: (a) Foundry operatora to ekosystem Pythona — wykonawcy LLM pracują w jednym języku z fabryką; (b) **Django admin za darmo rozwiązuje moderację** — dla solo foundera to tygodnie pracy, których nie trzeba wykonać; (c) baterie: auth, sesje, ORM, migracje, formularze.
- **Server-rendered + htmx zamiast SPA**: tablica ogłoszeń to hipertekst; SPA podwaja powierzchnię kodu (API + klient) bez wartości dla użytkownika. PWA ≠ SPA — manifest, service worker i push działają na stronach renderowanych serwerowo.
- **Jedna baza do wszystkiego** (dane, geo, kolejka): eliminuje Redis/RabbitMQ z listy rzeczy, które mogą się zepsuć w nocy.

## 4. Klient: PWA (decyzja rozstrzygnięta researchem)

- Web Push na iOS działa od 16.4 **dla PWA zainstalowanej na ekranie głównym** — także w UE (Apple wycofało się z blokady web appek w III 2024); iOS 18 ustabilizował doręczenia, Safari 18.4 dodał Declarative Web Push, iOS 26 zmniejszył frykcję otwierania. Wniosek: **push bez wrappera jest osiągalny**; koszt przenosi się na UX instalacji.
- Projektujemy więc: (a) onboarding instalacji per przeglądarka (animowana instrukcja „Udostępnij → Do ekranu początkowego"), (b) **fallback e-mail digest** dla niezainstalowanych (nowe zadania z mojego osiedla raz dziennie), (c) Badge API dla nieprzeczytanych.
- Czego PWA nie da nigdy: geofencing w tle — i nie jest potrzebny (GPS używamy tylko w momencie rejestracji, na pierwszym planie).
- Capacitor/sklepy — dopiero faza 2, jeśli dystrybucja przez zarządców tego zażąda.

## 5. Model danych (rdzeń)

```
Estate        — osiedle: nazwa, poligon (PostGIS), status: waitlist|active, próg aktywacji
Waitlist      — e-mail + osiedle (przed aktywacją; RODO: tylko e-mail)
User          — konto: e-mail/tel, hasło/magic-link, 16+ (deklaracja)
Membership    — User×Estate: adres (pełny — widoczny tylko dla systemu),
                trust_level: L0..L3, metoda weryfikacji, data
Task          — autor, osiedle, moduł: HELP|GIG (rozłączne widoki),
                tytuł, opis, zdjęcia, widełki_tekst (tylko GIG),
                status: open→assigned→done|expired|cancelled, deadline
Application   — kandydat→Task (zgłoszenie + wiadomość)
Thread/Message— czat 1:1 w kontekście Task
Kudos         — podziękowanie/ocena po done (obustronne, krótkie)
TrustScore    — zdenormalizowany poziom: liczba done (HELP i GIG łącznie,
                zasada z części II §4.3: jeden poziom, oba typy aktywności)
Report        — zgłoszenie treści (DSA notice&action): zgłaszający (może być
                niezalogowany), powód, status, uzasadnienie decyzji
AuditLog      — decyzje moderacyjne i zmiany trust_level (dowód dla DSA/RODO)
LiquidityStat — dzienny snapshot per osiedle: fill_rate, mediana TTFR,
                aktywni, zadania nowe/zamknięte
```

Świadomie brak: Wallet, Payment, Contract, Booking — szwy fazy 2 (sekcja 10).

## 6. Kluczowe mechaniki → implementacja

- **Aktywacja osiedla (wzorzec nebenan „100 zapisanych")**: landing z mapą osiedla + licznik waitlisty; osiedle w statusie `waitlist` nie pokazuje treści. Aktywacja ręczna (decyzja operatora), próg konfigurowalny per osiedle (na pilocie własnym może być niższy). Landing waitlisty to **pierwszy deliverable w ogóle — przed apką** (test akwizycji za ~0 zł).
- **Weryfikacja warstwowa** („mieszkasz tam"): L0 = e-mail; L1 = GPS-check na pierwszym planie w poligonie osiedla przy rejestracji; L2 = kod zaproszenia od zweryfikowanego sąsiada/ambasadora/zarządcy (dystrybuowany też offline: plakat na klatce z kodem osiedla); L3 = list z kodem (ręcznie, tylko sporne przypadki). Publikowanie zadań od L1, branie zadań od L2 (założenie do kalibracji). eID (mojeID/mObywatel przez pośredników typu Authologic) — dopiero z pieniędzmi w fazie 2; i tak nie potwierdza adresu, tylko tożsamość.
- **Geografia**: punkty adresowe **PRG/GUGiK** (darmowe, ~7 mln punktów) załadowane do PostGIS → autocomplete adresu i walidacja „budynek istnieje"; poligony osiedli **rysowane ręcznie** przy onboardingu osiedla (na 1–3 osiedla to godziny, nie tygodnie); przypisanie point-in-polygon. Na sam start dopuszczalny skrót: darmowy tier Adresy.app (30 req/min) zamiast własnego importu.
- **Separacja Pomoc/Zlecenia**: dwa taby, osobne listy, osobne kolory/język UI („Poproś o pomoc" vs „Zleć drobną robotę"); zadanie nie zmienia modułu po publikacji. W module Pomoc pole kwoty **nie istnieje w formularzu** — to jedyna skuteczna implementacja zasady „nie monetyzuj warstwy darmowej".
- **Reputacja** (7 zasad z części II §4.3): poziomy nowicjusz→sąsiad→filar osiedla liczone z zamkniętych zadań obu typów; odznaki bez wymienialności; pełny profil (zdjęcie+bio) warunkiem widoczności zgłoszeń.
- **Moderacja**: przycisk „zgłoś" na każdej treści (dostępny bez logowania — wymóg DSA), kolejka w Django admin, potwierdzenie przyjęcia i uzasadnienie decyzji automatyczne z szablonów; triage LLM (klasyfikacja zgłoszeń: spam/konflikt/nielegalne) jako podpowiedź, **decyzja zawsze ludzka**. Rate-limity publikacji per użytkownik od pierwszego dnia.
- **Metryki płynności**: `LiquidityStat` liczony nocnym jobem + prosty dashboard operatora (fill rate, TTFR, retencja autorów) — implementuje kill/go z części III §5.

## 7. Powiadomienia

Web Push (VAPID, standardowe API — bez Firebase; Declarative Web Push tam, gdzie dostępny) + e-mail (Postmark/Resend, darmowe progi). Zasady anty-spam z lekcji Nextdoor (WAU pompowane notyfikacjami → churn): push tylko o **moich** sprawach (odpowiedź na moje zadanie, wybór mnie, wiadomość); nowe zadania osiedla — wyłącznie digest, domyślnie dzienny.

## 8. Infra i koszty

| Element | Wybór | Koszt/mies. (szacunek) |
|---|---|---|
| Serwer | 1 VPS (Hetzner CX32 lub odpowiednik), Docker Compose: Django+Postgres | ~30–60 zł |
| Backup | snapshoty + `pg_dump` do S3 | ~10 zł |
| Zdjęcia | Cloudflare R2 / Backblaze B2 | ~0–10 zł |
| E-mail | Postmark/Resend (free tier na starcie) | 0–40 zł |
| Błędy/analityka | Sentry free tier + Plausible self-host (bez cookies — mniej zgód) | 0 |
| Domena + TLS | Let's Encrypt | ~5 zł |
| **Razem** | | **~50–150 zł/mies.** |

CI: GitHub Actions (testy+lint na PR — bramka Foundry), deploy przez SSH/docker compose pull. Staging = drugi compose na tym samym VPS.

## 9. Prawo i bezpieczeństwo (obowiązki od pierwszego dnia)

- **DSA** (mikroprzedsiębiorca — zwolniony ze sprawozdawczości i obowiązków art. 19+, ale nie z podstaw): punkt kontaktowy na stronie; regulamin z zasadami moderacji prostym językiem; mechanizm notice&action z potwierdzeniem i uzasadnieniem decyzji (sekcja 6); zgłaszanie poważnych przestępstw organom. Krajowa ustawa (nadzór UKE) finalizowana latem 2026 — nie dodaje obowiązków materialnych, sprawdzić status przed startem.
- **RODO**: DPIA przed startem (dane lokalizacyjne + systematyczne zestawianie relacji sąsiedzkich = w praktyce obowiązek; 1–2 dni pracy szablonem); minimalizacja ekspozycji adresu (sekcja 1.5); retencja: zadania i czaty kasowane/anonimizowane po N miesiącach od zamknięcia (N do decyzji, propozycja 12); rejestr czynności; polityka prywatności.
- **Wiek**: regulaminowo **18+** (fizyczne spotkania z obcymi sąsiadami; unika też progu zgody rodzicielskiej 16 lat i „dziecięcej" DPIA).
- Bezpieczeństwo aplikacji: magic-link zamiast haseł (mniej powierzchni), rate-limity, CSP, brak publicznych profili poza osiedlem, zdjęcia bez EXIF/geotagów (strip przy uploadzie).

## 10. Szwy pod fazę 2 (projektowane, nieimplementowane)

- **Płatności/escrow**: osobny moduł `payments` od zera przy PSP z marketplace KYC (Stripe Connect / Mangopay / Adyen) — wtedy wchodzi DAC7 (raportowanie od pierwszej transakcji usługowej, zbieranie PESEL/NIP) i eID. Model `Task.GIG` już dziś ma stany zgodne z przyszłym escrow (assigned→done).
- **Ubezpieczenie grupowe wykonawców** (wzorzec Airtasker, część II §4.1): integracja typu embedded (Qover lub polski TU) zaczepiona o zdarzenie `assigned` w GIG.
- **Panel zarządcy (B2B2C)**: osobna rola + eksport statystyk osiedla („mniej telefonów" — materiał sprzedażowy); `Estate` już ma pole na przyszłego właściciela-partnera.
- **Capacitor/sklepy**: ta sama aplikacja webowa w wrapperze, gdy kanał B2B tego zażąda.

## 11. Realizacja w Foundry — kolejność kontraktów

Repo `Pomoc` jako repozytorium produktu pod reżimem CONSTITUTION (testy behawioralne obowiązkowe, minimalne diffy, evidence). Proponowana sekwencja kontraktów — każdy z osobnym kryterium i rollbackiem:

1. **K1 — szkielet**: Django+Postgres+PostGIS w Compose, CI z bramką (pytest, ruff), health-check, deploy na VPS. Kryterium: zielona bramka + działający staging.
2. **K2 — landing waitlisty**: mapa/nazwa osiedla, zapis e-mail, licznik, RODO-zgody. *To jedyny kontrakt, który musi być wcześnie — od niego zaczyna się test akwizycji w terenie.*
3. **K3 — geografia**: import PRG do PostGIS, autocomplete, poligony osiedli, point-in-polygon.
4. **K4 — konta i weryfikacja L0–L2** (magic-link, GPS-check, kody zaproszeń).
5. **K5 — tablica HELP** (publikacja→zgłoszenie→wybór→czat→załatwione→kudos) + push/digest.
6. **K6 — tablica GIG** (klon HELP + widełki tekstowe, rozdzielone widoki).
7. **K7 — moderacja i DSA** (report/notice&action, admin, rate-limity, audit log).
8. **K8 — LiquidityStat + dashboard operatora** (kill/go metryki).

Praca ludzka nierównoległa do fabryki: DPIA + regulamin + polityka prywatności (szablony może przygotować LLM, decyzje i podpis — operator), rysowanie poligonu pilotażowego osiedla, kampania waitlisty.

## 12. Otwarte decyzje i BRAKi

- ~~BRAK decyzji: miasto/osiedle pilotażowe~~ — rozstrzygnięte: Gdańsk Zaspa, z osią integracji emerytów ze studentami; delta zakresu w [części V](rozkmina-2026-08-czesc-5-plan-pilotazu-zaspa.md) §7.
- BRAK decyzji: nazwa produktu i domena (potrzebna do K2).
- Do kalibracji po pilocie: progi weryfikacji (publikacja od L1 / branie od L2), retencja danych (12 mies.?), próg aktywacji osiedla (<100 na pilocie własnym?).
- BRAK danych: cenniki eID (Authologic/mojeID — wyceny indywidualne) — nieblokujące, faza 2.
- Ryzyko techniczne do zwalidowania w K5: realna dostarczalność Web Push na iOS w polskiej populacji użytkowników 40+ (research potwierdza działanie mechanizmu, nie adopcję instalacji PWA) — jeśli instalowalność <30% aktywnych, fallback digest staje się kanałem głównym, a Capacitor przyspiesza.

## Źródła researchu technicznego (wybór)

[MobiLoud — PWA on iOS 2026](https://www.mobiloud.com/blog/progressive-web-apps-ios) · [MagicBell — PWA iOS limitations](https://www.magicbell.com/blog/pwa-ios-limitations-safari-support-complete-guide) · [TechCrunch — Apple cofa blokadę web appek w UE](https://techcrunch.com/2024/03/01/apple-reverses-decision-about-blocking-web-apps-on-iphones-in-the-eu/) · [GIS Support — dane adresowe PRG](https://gis-support.pl/baza-wiedzy-2/dane-do-pobrania/dane-adresowe/) · [Adresy.app API](https://adresy.app/api/) · [Certum — Węzeł Krajowy a sektor prywatny](https://www.certum.pl/pl/aktualnosci/krajowy-wezel-tozsamosci-a-sektor-prywatny-jak-firmy-moga-z-niego-korzystac/) · [Authologic — mObywatel API](https://mobywatel.authologic.com/pl/) · [KIR — mojeID](https://www.kir.pl/nasza-oferta/firmy-i-korporacje/identyfikacja-i-e-podpis/mojeid) · [ngo.pl — DSA dla hostingodawców](https://publicystyka.ngo.pl/dsa-juz-w-pelni-obowiazuje-co-sie-zmienia-dla-hostingodawcow-lista) · [rp.pl — wdrożenie DSA w PL](https://www.rp.pl/internet-i-prawo-autorskie/art44758661-sejm-wraca-do-wdrozenia-unijnego-aktu-o-uslugach-cyfrowych-rzad-podzielil-przepisy) · [EDPB — wykaz DPIA](https://edpb.europa.eu/sites/edpb/files/files/file1/2018-09-25-opinion_2018_art._64_pl_sas_dpia_list_pl.pdf)
