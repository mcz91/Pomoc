# Ustalenia rozkminy — dokument przekazania dla architekta produktu

Stan: 30.08.2026. Konsoliduje części [I](rozkmina-2026-08-badanie-rynku.md)–[VI](rozkmina-2026-08-czesc-6-sedno-i-wiral.md) rozkminy do postaci wejścia dla roli architekta produktu w tym repozytorium (specyfikacja kontraktów dla wykonawców Foundry).

**Jak czytać:** sekcje 1–3 są wiążące (decyzje operatora i twarde fakty z badań); sekcje 4–8 to wymagania do przełożenia na TaskSpeki; sekcja 9 — rekomendacje czekające na decyzję operatora; sekcja 10 — skonsolidowane `BRAK:`. Obowiązuje `CONSTITUTION.md` z repo `mcz91/foundry` (m.in. kryteria obserwowalne, minimalne diffy, `BRAK`/`OBJECTION` zamiast zgadywania). Szczegółowe uzasadnienia i źródła — wyłącznie w częściach I–VI; ten dokument ich nie powtarza.

## 1. Produkt

Hiperlokalna PWA „pomoc sąsiedzka": tablica drobnych zadań i wymiany na poziomie osiedla — za darmo albo (później) za pieniądze. Pilotaż: **Gdańsk Zaspa**, oś: **integracja emerytów ze studentami** — wymiana dwustronna („rosół za WiFi"), nie usługa opiekuńcza. Sedno komunikacyjne: samotność ma krzywą U (18–35 i 75+) — produkt łączy dwie samotne grupy mieszkające piętro od siebie.

## 2. Decyzje wiążące operatora (dziennik)

| # | Decyzja | Data | Źródło |
|---|---|---|---|
| D1 | Pilotaż: Gdańsk **Zaspa** (Młyniec + Rozstaje); wcześniejsza Starówka odrzucona po badaniu | 30.08 | cz. V |
| D2 | Oś pilotażu: **integracja emerytów ze studentami** | 30.08 | cz. V |
| D3 | Kierunek „personalizacja rekomendacji" — **wycofany** | 30.08 | cz. V |
| D4 | Faza 1 **bez pieniędzy w platformie** (zero PSP/escrow/DAC7); widełki przy zleceniu to tekst informacyjny | 30.08 | cz. I §4.6, IV §1.4 |
| D5 | Twarda separacja modułów **HELP** (bez pola kwoty w formularzu) i **GIG**; GIG **wyłączony na starcie pilotażu**, dołącza po 4–6 tyg. | 30.08 | cz. I §4.3, V §5 |
| D6 | Klient: **PWA** (bez aplikacji natywnych w fazie 1) | 30.08 | cz. IV §4 |
| D7 | Stack: **monolit Django + PostgreSQL/PostGIS**, jedna baza (dane+geo+kolejka), 1 VPS, server-rendered + htmx | 30.08 | cz. IV §3 |
| D8 | Regulaminowo **18+** | 30.08 | cz. IV §9 |
| D9 | Reputacja bez wymienialnej waluty; jeden poziom zaufania zasilany aktywnością HELP i GIG łącznie | 30.08 | cz. II §4.3 |
| D10 | Wiral kierowany na waitlisty: zgłoszenia spoza Zaspy budują mapę kolejek dzielnic, nie natychmiastową ekspansję | 30.08 | cz. VI §4.6 |

## 3. Twarde fakty z badań (ograniczenia projektowe)

1. **Prowizja od mikro-zadań nie utrzyma platformy** (3–12 zł/transakcję przy koszyku 20–60 zł vs CAC 160–600 USD) — monetyzacja tylko pośrednia: gmina jako płatnik usług sąsiedzkich (KWS/art. 50 u.p.s., wzorzec SeniorApp×MOPS), abonament spółdzielni, kafeterie. Senior nigdy nie płaci pełnej ceny. (cz. I §4.1, II §1, V §6)
2. **Pieniądze wypierają motywację społeczną** (crowding-out) — stąd D5; żadna funkcja nie może mieszać wyceny z przysługą. (cz. I §4.3)
3. **Disintermediacja jest pewnikiem** w skali osiedla; w warstwie darmowej jest nieszkodliwa („żywe pary" to sukces, nie wyciek); w płatnej wartością zatrzymującą będzie kiedyś ubezpieczenie/escrow, nie kontakt. (cz. II §3.4, V §3.4)
4. **DAC7**: platforma pośrednicząca w płatności za usługę raportuje każdego wykonawcę od pierwszej transakcji — dopóki obowiązuje D4, obowiązek nie powstaje. (cz. I §4.6)
5. **OC w życiu prywatnym nie pokrywa odpłatnych przysług** (wyłączenie „pracy zarobkowej" w OWU) — darmowa przysługa co do zasady objęta; ubezpieczenie grupowe à la Airtasker to przyszły wyróżnik płatnej ścieżki. (cz. II §4.1)
6. **Web Push na iOS działa wyłącznie dla PWA zainstalowanej na ekranie głównym** (także w UE) — onboarding instalacji i fallback e-mail/SMS digest są częścią rdzenia, nie dodatkiem. (cz. IV §4)
7. **Dane adresowe**: punkty PRG/GUGiK (darmowe) → PostGIS; poligony osiedli rysowane ręcznie; żadna metoda eID w PL nie potwierdza adresu zamieszkania — weryfikacja „mieszkasz tam" zawsze heurystyczna. (cz. IV §6)
8. **DSA (mikroprzedsiębiorca)**: punkt kontaktowy, regulamin prostym językiem, mechanizm notice&action z potwierdzeniem i uzasadnieniem decyzji, zgłaszanie poważnych przestępstw. **RODO**: DPIA przed startem; ekspozycja adresu innym użytkownikom najwyżej do poziomu ulicy/osiedla; retencja treści po zamknięciu (propozycja 12 mies.). (cz. IV §9)
9. **Zimny start**: aktywacja osiedla po progu waitlisty; metryką jest płynność (fill rate, czas pierwszej odpowiedzi), nie rejestracje. (cz. II §2.1, V §5)
10. **Bezpieczeństwo to rdzeń produktu** (lekcja Papa Inc.): jeden niezaopiekowany incydent kończy pilotaż w 24-tysięcznej dzielnicy. (cz. V §3.3, §8.3)

## 4. Zakres fazy 1

**Jest:** waitlista z progiem i referralem → aktywacja osiedla; rejestracja z weryfikacją warstwową; profil dwustronny „potrzebuję/oferuję"; tablica HELP (potem GIG); zgłoszenie→wybór→czat 1:1→„załatwione"→kudos; rejestr par; rola ambasadora + tworzenie zadań w imieniu seniora (proxy); powiadomienia (push + digest + SMS); moderacja DSA; LiquidityStat + dashboard operatora; tryb dostępności.

**Nie ma (non-goals fazy 1, wiążące):** płatności, escrow, ubezpieczenia, feed dyskusyjny, kategorie usług profesjonalnych, aplikacje natywne, panel zarządcy, wielojęzyczność, kalendarz, personalizacja/ML, integracje eID.

## 5. Wymagania produktowe (do przełożenia na kryteria obserwowalne)

**W1. Waitlista i aktywacja (cz. V §5, VI §4/§6):** landing dwustronny (ścieżki senior/„mieszkam na Zaspie" i student); licznik progu per grupa (**60 seniorów / 40 studentów** — parametr per osiedle); pozycja w kolejce + link polecający przesuwający w górę; trwały tytuł „Pierwszy Sąsiad Zaspy"; pole „co dam / czego szukam" już na waitliście; zgłoszenia spoza aktywnych osiedli zapisują się do kolejek dzielnic z publicznym licznikiem. Osiedle w statusie `waitlist` nie pokazuje treści; aktywacja jest aktem operatora.

**W2. Weryfikacja warstwowa (cz. IV §6, V §3.3):** L0 e-mail; L1 GPS-check w poligonie osiedla przy rejestracji (pierwszy plan, bez śledzenia w tle); L2 kod zaproszenia (sąsiad/ambasador/zarządca; dystrybucja także na plakacie); L3 ręczny (list/oświadczenie o niekaralności dla wchodzących do mieszkań). Bramki uprawnień: publikacja zadań od L1, branie zadań od L2 (parametry).

**W3. Profil dwustronny i pary (cz. V §3.1/§3.4):** każdy profil ma „oferuję" i „potrzebuję" (tagi + tekst); widoczność zgłoszeń warunkowana pełnym profilem (zdjęcie+bio); system rozpoznaje **parę** (ta sama dwójka, ≥3 zamknięte kontakty) i liczy żywe pary.

**W4. Proxy offline-to-online (cz. V §3.2):** ambasador/dyżurny może utworzyć konto-cień i zadanie **w imieniu** seniora (z audytem: kto, kiedy, za czyją zgodą); senior bez smartfona uczestniczy przez SMS/telefon; każdy materiał drukowany ma numer telefonu.

**W5. Cykl zadania:** publikacja (HELP: bez pola kwoty; GIG: widełki tekstowe) → zgłoszenia z wiadomością → wybór → czat 1:1 → „załatwione" → obustronne kudos. Stany: open→assigned→done|expired|cancelled.

**W6. Powiadomienia (cz. IV §7):** push tylko o sprawach użytkownika (odpowiedź, wybór, wiadomość); nowe zadania osiedla wyłącznie w digeście (domyślnie dziennym); kanał SMS dla profili senior/proxy.

**W7. Moderacja i DSA (cz. IV §6/§9):** „zgłoś" na każdej treści, dostępne bez logowania; kolejka w Django admin; automatyczne potwierdzenie przyjęcia i uzasadnienie decyzji z szablonu; triage LLM tylko jako podpowiedź — decyzja ludzka; rate-limity publikacji; AuditLog decyzji moderacyjnych i zmian poziomu zaufania; SLA wewnętrzne: każde zgłoszenie obsłużone <24 h.

**W8. Metryki (cz. V §5, VI §6):** dzienny `LiquidityStat` per osiedle: fill rate, mediana czasu pierwszej odpowiedzi, aktywni, zadania nowe/zamknięte, liczba żywych par, % seniorów ze skonsumowanym „oferuję", % zapisów z referrali, stan kolejek dzielnic; dashboard operatora czytelny bez SQL-a.

**W9. Dostępność:** WCAG 2.1 AA jako kryterium akceptacji tablicy (nie nice-to-have); tryb dużej czcionki/kontrastu; język bez żargonu; zdjęcia bez EXIF przy uploadzie.

## 6. Architektura zadana (cz. IV — wiążąca w zakresie D6/D7)

Django (admin = panel moderacji; server-rendered + htmx; DRF tylko dla potrzeb PWA), PostgreSQL+PostGIS (jedna baza: dane, geo, kolejka — procrastinate/django-q2), S3-compatible na zdjęcia, 1 VPS + Docker Compose, CI GitHub Actions (pytest+ruff jako bramka). Model danych rdzenia: Estate, Waitlist, User (typ uczestnictwa: senior/student/sąsiad), Membership (adres, trust_level, metoda), Task (HELP|GIG), Application, Thread/Message, Kudos, TrustScore, Pair, Report, AuditLog, LiquidityStat. Budżet infra: ~50–150 zł/mies. + SMS-y.

## 7. Sekwencja kontraktów (propozycja do specyfikacji przez architekta)

Kolejność z cz. IV §11 z deltami z cz. V–VI; każdy kontrakt: jeden problem, obserwowalne kryteria, minimalne allowed_paths, jedna komenda dowodowa.

| K | Zakres | Uwagi delty |
|---|---|---|
| K1 | szkielet: Django+Postgres+PostGIS w Compose, CI z bramką, health-check, deploy/staging | pierwszy kontrakt tworzy też `CLAUDE.md`/`AGENTS.md` repo (odesłanie do CONSTITUTION) |
| K2 | landing waitlisty | **rozszerzone o W1 w całości** (referral, pozycja, tytuł, „co dam/czego szukam", kolejki dzielnic); blokada: nazwa+domena (sekcja 9) |
| K3 | geografia: import PRG→PostGIS, autocomplete, poligony osiedli, point-in-polygon | poligon Zaspy rysuje operator (praca ludzka) |
| K4 | konta, magic-link, weryfikacja L0–L2, profil dwustronny, rola ambasadora+proxy | W2, W3 (profil), W4 |
| K5 | tablica HELP: cykl W5 + powiadomienia W6 + dostępność W9 | WCAG AA w kryteriach akceptacji |
| K6 | tablica GIG | **wdrażany dopiero po starcie pilotażu** (D5) |
| K7 | moderacja i DSA: W7 | wraz z retencją/anonimizacją |
| K8 | LiquidityStat + dashboard: W8 | progi kill/go z sekcji 8 jako konfiguracja, nie kod |

## 8. Metryki kill/go pilotażu (przegląd tydz. 13; cz. V §5)

- waitlista ≥60/40 przed aktywacją;
- ≥40% zadań z odpowiedzią <24 h; mediana pierwszej odpowiedzi <12 h;
- ≥15 żywych par; ≥30% seniorów ze skonsumowanym „oferuję";
- zero niezaopiekowanych incydentów (<24 h);
- (wiral) % zapisów z referrali raportowany, bez progu w pilocie.

Progi są założeniami własnymi do kalibracji — brak branżowych benchmarków dla tej skali.

## 9. Rekomendacje czekające na decyzję operatora

1. **Nazwa i domena** — rekomendacja: marka „Piętro Obok" (`pietroobok.pl`) + kampania „Pierogi za WiFi" (`pierogizawifi.pl`); wstępny test DNS wskazuje obie jako wolne — wymaga potwierdzenia i rejestracji. **Blokuje K2.**
2. Parametry: próg 60/40, bramki L1/L2, retencja 12 mies., moment włączenia GIG (4–6 tyg.) — przyjąć domyślne z rozkminy czy zmienić.
3. Harmonogram: start rekrutacji wrzesień–październik (sezonowość akademicka).

## 10. Praca ludzka poza fabryką (Faza 0; cz. V §5, VI §6)

DPIA + regulamin + polityka prywatności (drafty może dać LLM, decyzje operator); szablon zgody wizerunkowej „Duetów z Zaspy"; poligon Zaspy; partnerstwa (Plama GAK → rady dzielnic → SM „Młyniec"/„Rozstaje"; RCW/Caritas dla zaświadczeń studentów); wniosek do Gdańskiego Funduszu Sąsiedzkiego; rejestracja domen.

## 11. Skonsolidowane BRAK

- BRAK: decyzja o nazwie/domenie (sekcja 9.1).
- BRAK: liczba studentów mieszkających na Zaspie; liczba lokali SM „Młyniec"/„Rozstaje" (do rozmów Fazy 0).
- BRAK: potwierdzenie dostępności domen u rejestratora.
- BRAK: pełne OWU Warta/Allianz i stanowisko KNF ws. działalności nierejestrowanej vs „praca zarobkowa" (istotne dla fazy 2, nie dla pilotażu).
- BRAK: kontynuacja Złotej Rączki w Gdańsku po X 2026; szczegóły KWS 2026 dla Gdańska (faza przychodowa).
- BRAK: stanowisko uczelni ws. zaliczania wolontariatu (Faza 0).
- BRAK: benchmarki płynności dla mikro-skali (progi z sekcji 8 = założenia).

## 12. Indeks źródłowy

Cz. I — rynek, ranking dojrzałości, ekonomia, prawo (DAC7). Cz. II — B2B2C w PL, teardown nebenan/Nextdoor, incumbenci, ubezpieczenia, sizing, Karrot, zasady reputacji. Cz. III — wykonalność solo+LLM, kill-kryteria. Cz. IV — architektura, model danych, PWA/geo/prawo techniczne, K1–K8. Cz. V — teren Zaspy, wzorce międzypokoleniowe, plan 90 dni, ryzyka. Cz. VI — insight samotności, komunikaty per grupa, nazwa, mechaniki wiralowe.
