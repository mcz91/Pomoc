# Mapa Znajomych — zebrane ustalenia

Wersja 1 · 2026-08-30 · dokument wejściowy dla architekta produktu.

Zbiera w jednym miejscu wszystko, co ustalono w fazie rozkminy: pozycjonowanie, wnioski
z researchu rynkowego, decyzje techniczne, stan implementacji i otwarte pytania.
Szczegóły techniczne: [`PROJEKT_TECHNICZNY.md`](PROJEKT_TECHNICZNY.md).

---

## 1. Czym to jest w jednym zdaniu

Mapa miejsc, na której **każda liczba jest policzona dla patrzącego** — z jego własnych ocen
i z ocen jego znajomych ważonych zbieżnością gustu.

**Zasada babci** (formuła pozycjonująca): *chcesz iść gdzie indziej niż twoja babcia.*
Ocena 4,6 od tysiąca obcych jest informacją o wszystkich i o nikim. Produkt nie sprzedaje
„lepszych recenzji", tylko **personalizację**.

Konsekwencja jest twarda i obowiązuje w całym systemie: **nigdzie nie powstaje ani nie jest
pokazywana średnia globalna miejsca.** Miejsce bez sygnału zostaje bez liczby — nie
podstawiamy w to miejsce popularności. Reguła jest zapisana w migracji `0003_ranking.sql`
i pilnowana testem, nie tylko deklaracją w dokumencie.

---

## 2. Co ustalił research rynkowy

### Popyt udowodniony, biznes nie

Nowa fala rośnie wiralowo na dokładnie tej tezie, ale **nikt z niej nie ma przychodów**:

| Gracz | Trakcja | Kapitał | Mechanika |
|---|---|---|---|
| Beli (USA, 2021) | 75M+ ocen, 30 tys. miast, 80% wzrostu z referrali | ~$12M | ranking parowy (Elo), predykcje gustu, streaki, leaderboardy kampusowe |
| Corner (USA, 2022) | 250 tys. userów, ~425 miast | ~$7,5M | mapa 100% od userów, listy „gatekeep", AI vibe search |
| Zest (USA, 2024) | launch VI 2026 | $1,8M | auto-import wizyt z karty (Plaid) |
| Recomly (PL) | pre-launch, waitlista | brak śladu | znajomi + twórcy, „pay-for-visit" |

Szablon całej kategorii to Letterboxd: 1,7M → 17M członków w 5 lat na logowaniu i rankowaniu
jako tożsamości gustu.

### Dziesięć lekcji z cmentarza (wybór wiążący dla architektury)

1. **Gamifikacja to pożyczka, nie silnik** — odznaki dowiozły Foursquare do 10M userów, po czym
   mechanika wypaliła się i nie zostało nic wartego otwierania.
2. **Odkrywanie jest epizodyczne** — wygrywa mapa otwierana codziennie; potrzebna pętla częstsza
   niż samo szukanie.
3. **Kochany produkt bez modelu umiera** — Zenly: 40M MAU, zero przychodu, zamknięte przez Snapa.
4. **Nie rozdzielaj nawyku** — podział Foursquare na dwie aplikacje zabił obie strony pętli.
5. **Graf znajomych degeneruje się do ~6 osób** (mediana Swarm) → **projektuj dla N=0**.
6. **Cold start = gęstość miasto po mieście albo nic** — mapa z 2% pokrycia jest gorsza niż
   bezużyteczna.
7. **Wyścig o skalę zabija produkt** — Gowalla 2.0 ($14,4M, GV i Niantic) stanęła 6 tygodni po
   launchu. Kategoria wybacza tylko tani, cierpliwy start.
8. **Dane POI to kołowrotek** — nie budować bazy od zera, startować na otwartych zbiorach.
9. **Oceny obcych gniją w spam, gdy zaczynasz mieć znaczenie** — graf znajomych to jedyna
   odporna warstwa; warstwa publiczna dziedziczy problem Yelpa w dniu, w którym zacznie mieć
   wartość komercyjną.
10. **Zmęczenie check-inami i lęk o prywatność to realne sufity** — minimalizować wysiłek
    raportowania, domyślnie kameralna publiczność.

### Gdzie są pieniądze (na później, ale projektować pod to od początku)

Klasyczny model „recenzje + reklamy" zwija się nawet u gigantów: Yelp ($1,46B przychodu 2025)
rośnie na hydraulikach, a reklamy restauracyjne spadły o 3%; TripAdvisor trzyma się prowizjami
Viator i TheFork. Realne modele: **transakcje** (OpenTable bierze $1,00–1,50 od posadzonego
gościa), **karty i banki** (Chase kupił Infatuation, Amex kupił Resy i Tock za $400M), **dane
B2B** (Foursquare licencjonuje ~$100M/rok), **kuratela jako marka** (Michelin bierze $150K–2,7M
od regionów turystycznych). „Reklamy kiedyś" to nie plan.

### Dlaczego Polska i dlaczego teraz

Nisza jest pusta: Gastronauci martwi (redirect do Zomato), Beli i Corner nie ruszyły do CEE.
„Efekt Książulo" dowodzi popytu twardo — jedna naklejka MUALA to ~1300 kebabów dziennie i kolejki
przed otwarciem; wartość przechwytuje influencer, bo platformy nie ma. Jakdojade (~5M userów/mies.)
i Yanosik (3M+ MAU, płacący +18% r/r) dowodzą, że Polacy dokładają dane społecznościowe i płacą
za użyteczne aplikacje. Rynek: 76,7 mld zł przychodu gastronomii, 99,1 tys. lokali (+4,2% r/r).

---

## 3. Ustalenia o sposobie prowadzenia projektu

- **Solo + agent LLM wystarczy na produkt.** MVP to 4–8 tygodni pracy jednej osoby; infra
  ~$30–70/mies. nie wymaga inwestora.
- **Wąskim gardłem jest dystrybucja, nie kod.** Fosa Beli i Corner to społeczność. Pierwsza pętla
  produktu to własne życie towarzyskie founder(k)a; realny brak w układzie solo to „co-founder
  dystrybucji" albo scena, w której już się jest.
- **Produkt rozwija się poza reżimem Foundry do czasu kill-testu.** Foundry (v0.5.0, PROTOTYPE,
  autonomia wyłączona, zmierzony wysoki narzut operatora) optymalizuje dowodliwość — świetne dla
  systemu, który ma trwać, złe dla fazy, w której połowa feature'ów idzie do kosza po tygodniu.
  Sprint PĘTLA jedzie równolegle, pilotowany na EzyMacie; mapa wchodzi pod fabrykę **po**
  pozytywnym kill-teście, gdy pętla jest już przetestowana liczbami.
- **Od T6 kod jest podrzędny wobec terenu** — jawny podział budżetu godzin ok. 30% kod / 70%
  społeczność.

---

## 4. Zakres MVP

**Poligon:** Gdańsk, Starówka — Główne Miasto, Stare Miasto, Wyspa Spichrzów
(bbox `18.638, 54.340 → 18.672, 54.360`). Wybrany celowo: gęsta scena w promieniu spaceru, gdzie
„turystyczna pułapka obok miejsca dla swoich" jest codziennością — czyli tam, gdzie różnica między
moją oceną a średnią boli najbardziej.

**Kategoria-wabik:** gastro (`food`; `cafe` i `drinks` drugorzędne — porównania parowe mają sens
wyłącznie wewnątrz kategorii).

**Dostęp:** invite-only; kod zaproszenia jest jedyną drogą do konta i jedynym źródłem krawędzi grafu.

**Jawnie poza zakresem:** globalny rec score (CF na obcych), warstwa publiczna, wiele miast,
rezerwacje, czat, live-lokalizacja, web-app, widgety.

---

## 5. Architektura — decyzje i uzasadnienia

| Obszar | Wybór | Dlaczego | Odrzucone |
|---|---|---|---|
| Aplikacja | Expo (RN) + TS | EAS Update = poprawki OTA w godziny podczas bety | PWA (tarcie iOS), natywny Swift (podwójna praca solo) |
| Backend | Supabase (PG16 + PostGIS, Auth, RLS, Edge Functions), region EU | zero-ops dla solo; RLS jako model prywatności | własny serwer — więcej opsu przed walidacją |
| Mapa | MapLibre + OpenFreeMap | $0, bez klucza; fallback self-host PMTiles | Google SDK (ToS wiąże z Places), Mapbox (vendor) |
| Dane POI | OSM/Overpass; docelowo FSQ OS Places + Overture | otwarte licencje, wolno cache'ować | Google Places (zakaz wyświetlania poza Google Maps), Yelp (od $229/mies.) |
| Szukanie | pg_trgm + unaccent | kilka tys. wierszy na miasto | Typesense/Meilisearch — osobny serwis bez potrzeby |
| Analityka | PostHog Cloud EU | eventy i retencja bez własnej infry | własny stack, Amplitude |
| LLM | batch (Claude API) | dedup POI, kategorie, triage — nocne joby, $5–20/mies. | LLM w ścieżce online (koszt, latencja) |
| Prywatność | domyślnie dla znajomych, zero live-lokalizacji | lekcja 10; PII = e-mail + handle | publiczne profile na starcie |

**Zasady przekrojowe:** logika rankingu wyłącznie po stronie serwera (klient nie liczy pozycji ani
score'ów); RLS jako jedyny model dostępu; kafle i zdjęcia poza ścieżką API.

**Biblioteki zamiast własnych implementacji** (ustalenie procesowe): pgTAP + pg_prove do testów
bazy, overpy do Overpass, natywne klastrowanie MapLibre zamiast markera na lokal, zod do walidacji
odpowiedzi RPC. Nasze zostaje to, co jest domeną produktu — mechanika rankingu i transformacja
danych.

---

## 6. Mechanika — rdzeń produktu

### Ranking parowy

Bez gwiazdek. Kubełek (`liked` / `fine` / `disliked`) → seria pojedynków wyszukiwaniem binarnym
w obrębie kubełka (~log₂(n) pytań; 40 miejsc ⇒ ≤6 pytań) → pozycja. **Score 0–10 jest pochodną
pozycji**, nie deklaracją:

```
liked → [6.7, 10.0]   fine → [3.4, 6.6]   disliked → [0.0, 3.3]
score = hi − (hi − lo) · (pozycja − 1) / max(1, n_kubełka − 1)
```

Dlaczego to bije gwiazdki: rozkład zamiast kompresji (na Google wszystko ma 4,3★), niski koszt
poznawczy przy bogatszym sygnale, a wynik jest **tożsamością gustu** — rosnącym sunk costem
i materiałem na status.

### Ocena ważona zaufaniem

```
friend_score(v, p) = Σ w(v,r) · score_r(p) / Σ w(v,r)
w(v,r)   = 0.5 + 0.5 · sim(v,r)
sim(v,r) = (τ_Kendalla + 1) / 2   na wspólnie zrankowanych; 0.5 przy < 5 wspólnych
```

Znajomy o zbieżnym guście waży do 2× więcej niż o przeciwnym; **nikt nie waży zera** — sama
znajomość jest sygnałem. Podobieństwo liczone nocnym jobem, nigdy w ścieżce zapytania.

### Trzy warstwy sygnału

1. **mój ranking** — wartość przy zerze znajomych (odpowiedź na lekcję nr 5),
2. **wynik znajomych** — wartość przy 3–6 znajomych,
3. **predykcja z podobieństwa gustu** na obcych — skala, poza MVP.

---

## 7. Stan implementacji (zweryfikowany, nie zadeklarowany)

Repo: `mcz91/Pomoc`, gałąź `claude/user-rated-points-map-05v57j`.

**Baza — 35 testów pgTAP na żywym Postgresie 16 + PostGIS:**
- przeliczanie score z pozycji, przenoszenie między kubełkami z domknięciem luki w numeracji;
- τ Kendalla (zgodny gust `1.0`, przeciwny `-1.0`), wagi głosów (`1.0` / `0.5`, nigdy zero);
- **test dowodzący zasady babci wprost: ten sam lokal ma `8.9` u wnuka i `10.0` u babci**;
- brak wyniku przy braku sygnału (żadnej średniej w zastępstwie);
- odmowa zapisu bez sesji;
- osobny zestaw RLS: co widzi znajomy, czego nie widzi obcy, prywatność listy „chcę spróbować"
  i śladów pojedynków, oraz strażnik wymagający RLS na każdej nowej tabeli.

**Aplikacja — 12 testów:** pętla pojedynków (każda pozycja w kubełku 40 miejsc w ≤6 pytaniach,
pominięcie kończy serię, brak zapętleń), warstwa prezentacji sygnału, walidacja odpowiedzi RPC.

**Pipeline POI — 6 testów:** transformacja OSM → SQL na prawdziwym parserze overpy (odsiewanie
bezimiennych i obcych kategorii, zwijanie duplikatów node/way, składanie adresu, escapowanie,
idempotentny upsert).

Pełny przebieg: `tools/run_all_tests.sh`.

**Czego jeszcze nie ma:** ekran miejsca i dodawanie lokalu przez usera, wyszukiwarka, zaproszenia
w UI, feed, import Takeout, push. Seed Starówki **nie został uruchomiony na prawdziwych danych** —
Overpass jest zablokowany w środowisku, w którym powstawał kod; skrypt czeka na przebieg u operatora.

---

## 8. Kill-test — progi decyzyjne (T12)

| Metryka | Próg |
|---|---|
| W4 retencja zaproszonych | ≥ 30% |
| Aktywni tygodniowo logujący ≥1 miejsce bez pusha | ≥ 50% WAU |
| Zaakceptowane zaproszenia na aktywnego usera | ≥ 0,5 |
| Sesje z obejrzeniem wyniku znajomych | ≥ 40% |

**Reguła:** poniżej progów — wnioski i stop albo pivot, **bez dosypywania feature'ów**. Powyżej —
decyzje: wejście pod Foundry, partner od dystrybucji, druga kategoria.

Plan 12 tygodni: T1 szkielet i seed (zrobione), T2 ekran miejsca i wyszukiwarka, T3 log wizyty
i ranking w UI, T4 zaproszenia i feed, T5 import i push, T6 start bety (15–30 osób z własnej ekipy),
T7–T11 tygodniowa pętla feedback → OTA, T12 odczyt metryk.

---

## 9. Otwarte pytania do architekta

1. **Kategorie drugorzędne od kiedy.** `cafe` i `drinks` istnieją w schemacie, ale osobny ranking
   per kategoria rozrzedza dane w guście. Czy wpuszczać je w becie, czy trzymać czysty `food`
   do T12?
2. **Próg 5 wspólnych miejsc** dla wagi gustu jest przyjęty, nie zmierzony. Po becie warto go
   skalibrować na realnym rozkładzie.
3. **Moment wejścia warstwy publicznej.** Dziś odroczona — dziedziczy problem spamu (lekcja 9).
   Potrzebny projekt proof-of-visit, zanim to ruszy.
4. **Ścieżka transakcyjna.** Rezerwacje to najlepsza jednostkowa ekonomia w kategorii, ale wymagają
   integracji po stronie lokalu. Kiedy zacząć rozmowy — po kill-teście czy równolegle?
5. **Co z twórcami.** „Efekt Książulo" pokazuje, gdzie jest energia. Mapy kuratorskie to potencjalny
   akcelerator gęstości, ale też ryzyko przesunięcia produktu z „gust znajomych" na „gust
   influencera" — czyli z powrotem w stronę jednej wspólnej średniej.
