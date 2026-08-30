# Pomoc sąsiedzka — rozkmina i badanie rynku

Stan danych: sierpień 2026. Liczby oznaczone „szacunek" pochodzą z danych wtórnych, nieaudytowanych.

## 1. Koncept

Hiperlokalna tablica drobnych zadań: mieszkaniec wrzuca ogłoszenie („wyrzucę śmieci przy okazji?", „rozwiesić pranie", „wywiercić dziurę", „przynieść zakupy"), sąsiad je bierze — **za wynagrodzenie albo za darmo**, według uznania stron. Swobodniej niż Glovo/TaskRabbit: bez sztywnych kategorii, bez wymogu profesjonalizmu, zasięg osiedla/dzielnicy.

## 2. Krajobraz: kto robi coś podobnego

### 2.1 Płatne marketplace'y zadań (świat)

| Produkt | Rynek | Model | Skala / status 2026 |
|---|---|---|---|
| **Thumbtack** | USA | pay-per-lead dla fachowców | ~400 mln USD przychodu (2024, +33%), wycena 3,2 mld USD, kandydat do IPO |
| **Urban Company** | Indie | zarządzany marketplace (szkoli fachowców, standaryzuje ceny) | ~137 mln USD przychodu FY25 (+38%); IPO IX 2025: zapisy 103×, debiut +57,5% |
| **FlashEx/Shansong** (i Meituan Paotui, UU, Dada) | Chiny | errandy jako logistyka kurierska („paotui"), armia riderów | IPO NASDAQ X 2024, rentowny od 2016, ~3,1 mln riderów, 298 miast, dostawa śr. 23 min |
| **TaskRabbit** | USA + 7 krajów EU/NA | prowizja 15–30% + ~5% opłata klienta; płatność tylko in-app | ~200 tys. Taskerów, ~75 mln USD przychodu (2025, szacunek); żyje głównie dzięki IKEA (montaż przy kasie; 4,7× wyższy koszyk); zwolnienia 2023–24 |
| **Airtasker** | AU, UK, USA, NZ | **otwarta tablica: klient opisuje zadanie i budżet, wykonawcy licytują**; prowizja 10–20% degresywna (efektywnie ~21,6% GMV) + connection fee A$9,95–59,95 | FY25: GMV 208,7 mln AUD (+9,5%), przychód grupy 52,6 mln AUD, 2. rok dodatniego FCF; średnie zadanie **A$250** |
| **Angi/Handy** | USA | leady + pre-priced booking | przychód spada ~11–13% r/r (2025), fachowcy 118 tys. (spadek); model leadowy się kurczy |
| **Yoojo** | Francja | P2P usługi domowe, bez finansowania VC | żyje; brak danych o przychodach |
| **Helpling** | Niemcy | prowizja od sprzątania; 96,7 mln USD finansowania | żyje bez dynamiki; upadłość spółki NL (2023), wycofanie z Hiszpanii |

Najbliższy koncepcyjnie jest **Airtasker** (tablica + budżet + licytacja), ale jego średni koszyk to ~A$250 — to inna liga niż „wynieś śmieci za dychę".

### 2.2 Hiperlokalne / społecznościowe (darmowa pomoc)

| Produkt | Rynek | Model | Skala / status 2026 |
|---|---|---|---|
| **Nextdoor** | USA + 11 krajów (bez PL) | feed sąsiedzki, ~100% przychodu z reklam | 21 mln WAU (Q4 2025, −5% r/r), przychód 257,6 mln USD (+4%), **strata netto 54 mln USD**, kurs −80% od IPO |
| **nebenan.de** | Niemcy | freemium: płatne profile firm/NGO, umowy z gminami, dobrowolne wpłaty | 3,6–4,3 mln użytkowników, ~10 tys. dzielnic; 61% udziałów ma Hubert Burda Media; stabilna |
| **Olio** | UK/globalnie | darmowe oddawanie jedzenia/rzeczy; premium £1,99/mies. + B2B (Tesco/Pret płacą za odbiory) | kilka–9 mln użytkowników (różne źródła podają 4 mln aktywnych vs 9 mln+ zarejestrowanych); rośnie |
| **Peerby** | NL/BE | pożyczanie rzeczy od sąsiadów; opłaty transakcyjne + członkostwo | żyje; świeżych liczb brak |
| **Pumpipumpe** | CH/DE/AT/FR | non-profit, naklejki na skrzynkę „co pożyczam" | żyje, low-tech, nisza |
| **TimeRepublik / banki czasu** | globalnie / PL | timebanking (1 h = 1 h) | nisza; banki czasu w PL w większości martwe po odcięciu grantów |
| **Streetbank** | UK | darmowe dzielenie się | **zamknięty 1.03.2024** — nie znalazł modelu przychodowego |

### 2.3 Polska

| Produkt | Model | Status 2026 |
|---|---|---|
| **Fixly** (od XI 2025 wydzielona spółka, ex-OLX) | pay-per-lead; klient publikuje za darmo, wykonawca płaci za kontakt | lider: >558 tys. wykonawców, ~400 kategorii; celuje w profesjonalistów — koszt leada wypycha mikro-zadania |
| **OLX Usługi** | tablica ogłoszeń bez escrow/weryfikacji/transakcji | działa; brak strony popytowej dla mikro-zadań |
| **Oferteo / Oferia** | wykonawca płaci za kontakt | żyją; Oferia mniejsza, agresywny content porównawczy |
| **Useme** | warstwa rozliczeniowa dla freelancerów (prowizja od 7,8%, faktura bez firmy) | nie konkurent — ale ciekawy **wzorzec rozliczeń** (legalny zarobek bez działalności) |
| **Helpi — Pomoc sąsiedzka** | tablica „szukam pomocy / oferuję", czat, filtry; darmowa + kredyty 4,99–29,99 zł/mies. | **najbliższy odpowiednik konceptu** — i ~12 ocen w App Store, czyli praktycznie zero trakcji |
| **Po Sąsiedzku** | tylko darmowe oddawanie rzeczy, tylko Warszawa i okolice | żyje; pozycjonuje się jako alternatywa dla chaosu grup FB |
| **Sąsiedzi (sasiedzi.net)** | łączenie mieszkańców, ogłoszenia, pomoc | skala nieznana |
| **Dla sąsiadów / e-Osiedle / OsiedleApp** | B2B dla zarządców/wspólnot (usterki, głosowania, ogłoszenia) | żyją; pomoc sąsiedzka to funkcja poboczna |

Realna „infrastruktura" pomocy sąsiedzkiej w PL to **grupy FB osiedlowe** (chaos, spam, awantury, brak struktury zadań i płatności) oraz kartki na klatce. Nextdoor w Polsce nie działa. Popyt jest udokumentowany: wg SW Research (2026) **~80% Polaków korzysta z pomocy/wymiany sąsiedzkiej**, a wg raportu Otodom prawie połowa czeka, aż ktoś inny zainicjuje życie sąsiedzkie.

## 3. Ranking dojrzałości

Od najdojrzalszych (skala + rentowność/kapitał) do martwych:

1. **Thumbtack** — 3,2 mld USD wyceny, ~400 mln USD przychodu; ale to leady dla fachowców, nie sąsiedzkie mikro-zadania.
2. **Urban Company** — udane IPO 2025, rentowna kategoria usług domowych; sukces przez głęboką kontrolę podaży, nie luźną tablicę.
3. **FlashEx/Shansong (Chiny)** — errandy działają na skalę **tylko** jako logistyka kurierska z armią riderów.
4. **TaskRabbit** — dojrzały, ale zależny od IKEA jako taniego źródła popytu.
5. **Nextdoor** — największa sieć sąsiedzka świata i wciąż nierentowna; WAU spada.
6. **Angi/Handy** — duży, w odwrocie.
7. **Airtasker** — model „tablicy z budżetem" zwalidowany, dodatni cash flow po ~10 latach, ale to mała spółka (~150–200 mln AUD kapitalizacji).
8. **nebenan.de** — dowód, że darmowa pomoc sąsiedzka utrzymuje się na freemium+gminy, przy inwestorze strategicznym (Burda).
9. **Olio** — działa dzięki B2B (korporacje płacą za odbiory) i wolontariuszom.
10. **Fixly** — dojrzały lider PL, ale strukturalnie omija mikro-zadania.
11. **Peerby, Yoojo, Pumpipumpe, TimeRepublik** — żywe nisze bez skali.
12. **Polskie apki sąsiedzkie (Helpi, Po Sąsiedzku, Sąsiedzi)** — nisza istnieje, nikt jej nie zdobył; trakcja śladowa.
13. **Martwe**: Streetbank (2024), Takl (2020, spalił >37 mln USD), GoLife/Gojek (2020), Homejoy (2015), Exec (2013), Zaarly (pivot 2013, zgon 2021), polskie banki czasu, pandemiczne apki zakupowe.

**Wniosek strukturalny:** nikt — ani globalnie, ani w PL — nie połączył skutecznie „za darmo ALBO za pieniądze" w jednej tablicy. To biała plama, ale częściowo dlatego, że hybrydowa monetyzacja jest nierozwiązana.

## 4. Analiza biznesowa

### 4.1 Unit economics — fundamentalny problem kategorii

- Take rate branży: TaskRabbit ~20–30%, Airtasker ~21,6% (implikowany z FY25), Fixly/Thumbtack — opłata za lead.
- Średni koszyk Airtaskera: **A$250**. Koszyk „drobnicy" sąsiedzkiej: 20–60 zł (szacunek).
- Przy take rate 15–20% platforma zarabia na mikro-zadaniu **3–12 zł** — poniżej kosztu płatności, moderacji i supportu.
- Benchmark CAC w usługach lokalnych: 160–600 USD na zrealizowane zlecenie (Google Ads, USA); cel LTV:CAC 3–5:1.

**Prowizja od drobnicy nie może być rdzeniem modelu.** To nie szczegół wykonania — to powód, dla którego kategoria ma cmentarz.

### 4.2 Dlaczego poprzednicy padali (wzorce)

1. **Disintermediacja** — po pierwszej udanej transakcji strony wymieniają się numerami. Badania: zagrożone do ~18% transakcji; platformy szacują wyciek na 30–80% potencjalnego przychodu. W hyperlocal to **pewnik** — sąsiad mieszka 50 m dalej.
2. **Niska częstotliwość + mały koszyk** vs stałe koszty trust & safety (Zaarly: 1 mln USD GMV/mies. → 15 tys. USD przychodu).
3. **Słaba retencja popytu** (Homejoy: retencja <25% przy branżowych 70–80%; klienci z kuponów nie wracali).
4. **Ryzyko prawne statusu wykonawców** (pozwy o misklasyfikację zabiły finansowanie Homejoy; w UE — dyrektywa o pracy platformowej, wdrożenie do XII 2026).
5. **Paliwo VC wymuszające wzrost bez unit economics** (Takl: >37 mln USD w piach). TaskRabbit już w 2014 porzucił aukcyjny model errands po spadku realizacji.

Przetrwali ci, którzy mają: tani popyt od partnera (TaskRabbit–IKEA), dyscyplinę kosztową bez przepalania (Airtasker, Yoojo), albo głęboką kontrolę podaży (Urban Company).

### 4.3 Płatne vs darmowe w jednym produkcie — ryzyko centralne konceptu

Klasyka ekonomii behawioralnej (Gneezy & Rustichini, „A Fine is a Price"): wprowadzenie kary za spóźniony odbiór dziecka ze żłobka **zwiększyło** spóźnienia — i efekt nie cofnął się po zniesieniu kary. Pieniądz zamienia normę społeczną w transakcję; małe wynagrodzenie obniża wysiłek bardziej niż brak wynagrodzenia („Pay enough or don't pay at all").

Dla naszej tablicy: jeśli obok siebie wisi „wyprowadzę psa — 20 zł" i „wyprowadzę psa — za darmo", darmowa pomoc zaczyna wyglądać jak frajerstwo, a płatna jak wyzysk. Jak radzą sobie inni:

- **Separacja strumieni**: nebenan.de i Nextdoor trzymają pomoc wzajemną w feedzie społecznym, handel w osobnym marketplace.
- **Waluta niepieniężna** dla przysług: podziękowania, reputacja, timebanking.
- **Pieniądze tylko tam, gdzie norma rynkowa już istnieje** (wiercenie, złota rączka, sprzątanie); przysługi (śmieci, podlanie kwiatów) domyślnie bezpłatne.

Wniosek projektowy: „płatne albo darmowe" nie może być jednym suwakiem przy ogłoszeniu — potrzebna twarda separacja UX: **„Pomoc” (bez cen, reputacja/podziękowania) vs „Zlecenia” (budżet, escrow, weryfikacja)**.

### 4.4 Zimny start w hyperlocal

- **Nextdoor**: start od jednego osiedla (Menlo Park, 2011), obowiązkowa weryfikacja adresu, próg „founding members" zanim dzielnica ruszy, fizyczne pocztówki USPS jako growth hack (kohorty papierowe ~30% lepsza retencja — dane vendora). 10 tys. dzielnic w 2013, 50 tys. w 2015.
- **Favor (Teksas)**: rentowność dopiero po wycofaniu się ze wszystkich stanów poza Teksasem — **gęstość > zasięg**.
- Playbook: najmniejszy rynek zdolny do płynności, najpierw podaż (pomagający), metryką jest **fill rate i czas odpowiedzi**, nie liczba rejestracji. Heurystyka: kilkudziesięciu aktywnych na osiedle, żeby zadanie dostawało odpowiedź <1 h (szacunek własny).
- Grób Streetbanka i polskich banków czasu = dowód, że sama dobra wola bez gęstości i modelu przychodowego umiera.

### 4.5 Monetyzacja poza prowizją

| Model | Kto tak robi | Konkrety |
|---|---|---|
| Lokalna reklama | Nextdoor | 257,6 mln USD (2025), ARPU ~11,94 USD/rok — i mimo to strata netto |
| Płatne profile firm/NGO + umowy z gminami + wpłaty | nebenan.de | promowanie ogłoszenia €2,49/5 dni |
| Freemium + B2B | Olio | premium £1,99/mies.; Tesco/Pret płacą za odbiory (taniej niż wywóz odpadów) |
| **B2B2C: zarządcy/deweloperzy** | Livly, Amenify (USA multifamily) | SaaS dla zarządcy + revenue share; do 80% adopcji w budynku |
| Connection fee zamiast % | Airtasker | A$9,95–59,95 przy akceptacji oferty — odporniejsze na disintermediację |

Dla Polski naturalny kanał B2B2C to **spółdzielnie, wspólnoty i deweloperzy** (zarządca płaci abonament za moduł komunikacji z mieszkańcami; apka dostaje dystrybucję „budynek po budynku") — rozwiązuje jednocześnie monetyzację i zimny start. Konkurenci B2B (e-Osiedle, OsiedleApp, Dla sąsiadów) już sprzedają zarządcom, ale bez marketplace'u zadań.

### 4.6 Prawo (PL)

- **Działalność nierejestrowana**: od 2026 limit **kwartalny 10 813,50 zł** (225% płacy minimalnej). Naturalna „kieszeń prawna" dla wykonawców drobnych zadań; po przekroczeniu — 7 dni na wpis do CEIDG.
- **PIT**: dorywcze zlecenia między osobami prywatnymi = przychód z „innych źródeł", rozliczany raz do roku (PIT-36); zlecający nie jest płatnikiem. Uwaga: formalna umowa zlecenia między osobami fizycznymi może teoretycznie rodzić obowiązek ZUS po stronie zlecającego — do opinii prawnej.
- **DAC7** (w PL od 1.07.2024) — **kluczowe dla architektury**: przy usługach osobistych raportowaniu do KAS podlega **każdy sprzedawca od pierwszej płatnej transakcji** (wyłączenie „30 transakcji / 2000 EUR" dotyczy tylko towarów); platforma pośrednicząca w płatności musi zbierać PESEL/NIP; kary do 1 mln zł. **Zadania darmowe i model ogłoszeniowy bez pośrednictwa w płatności nie podlegają raportowaniu** → silny argument, by NA STARCIE nie procesować płatności.
- **OC**: standardowe OC w życiu prywatnym zwykle wyłącza czynności zarobkowe; darmowa przysługa co do zasady objęta. Luka = potencjalne partnerstwo z ubezpieczycielem.

## 5. Synteza

**Gdzie jest szansa.** Popyt realny (~80% Polaków korzysta z pomocy sąsiedzkiej), podaż rozwiązań fatalna: Fixly obsługuje „duże" usługi, grupy FB obsługują chaos, dedykowane apki mają zerową trakcję, Nextdoora w PL nie ma. Hybryda „za darmo albo za pieniądze" to biała plama w skali świata.

**Główne ryzyka (w kolejności zabójczości):**
1. Zimny start hyperlocal — grób większości poprzedników.
2. Ekonomia mikro-zadań — prowizja nie finansuje platformy.
3. Disintermediacja — w skali osiedla gwarantowana.
4. Crowding-out — pieniądze mogą zabić darmową warstwę.
5. DAC7 + status wykonawców — koszt regulacyjny od pierwszej płatnej transakcji przez platformę.

**Kierunek, który z tego wynika (rekomendacja, nie decyzja):**
- **Faza 1 — bez pieniędzy w platformie.** Tablica ogłoszeniowa: darmowa pomoc + zadania „umów się sam" (strony rozliczają się poza apką). Zero DAC7, zero PSP, zero escrow. Wartość: struktura zamiast chaosu grup FB (kategorie, geografia, reputacja, „załatwione").
- **Start na 1–3 osiedlach z partnerem** (wspólnota/zarządca/deweloper), próg aktywacji osiedla, metryki: fill rate i czas odpowiedzi.
- **Twarda separacja UX**: „Pomoc" (bez cen) vs „Zlecenia" (z budżetem).
- **Monetyzacja od B2B2C** (abonament zarządcy) i ewentualnie promowanie ogłoszeń; prowizja/connection fee dopiero dla kategorii o koszyku 150 zł+, gdzie wartością jest ubezpieczenie, płatność i arbitraż sporów — nie sam kontakt.

## 6. Czego nie ustalono (BRAK)

- BRAK: liczby pobrań polskich apek sąsiedzkich (poza śladowymi ocenami w sklepach).
- BRAK: przychody nebenan.de i Peerby za 2025/26.
- BRAK: rozstrzygnięcia, czy jakiekolwiek OC w życiu prywatnym w PL obejmuje odpłatne przysługi (do weryfikacji z ubezpieczycielem).
- BRAK: potwierdzenia istnienia jakiejkolwiek udanej hybrydy „płatne+darmowe" — wniosek „biała plama" oparty na nieznalezieniu kontrprzykładu.
- BRAK: nazwy aplikacji z badania SW Research/Next2 (2026) — do doszukania.

## 7. Źródła (wybór)

Globalne: [Airtasker FY25 (ASX)](https://announcements.asx.com.au/asxpdf/20250828/pdf/06nhm6dp7f5rfz.pdf) · [TaskRabbit×IKEA](https://www.taskrabbit.com/press/release/taskrabbit-scales-partnership-with-ikea-across-north-america-and-europe) · [TaskRabbit fees](https://support.taskrabbit.com/hc/en-us/articles/46260504648731) · [Thumbtack $3.2B](https://press.thumbtack.com/announcements/thumbtack-secures-275-million-investment-at-3-2-billion-valuation/) · [Angi Q3'25](https://www.tipranks.com/news/company-announcements/angi-reports-q2-2025-revenue-decline-and-growth) · [Urban Company IPO](https://www.indmoney.com/blog/ipo/urban-company-ipo-review) · [FlashEx](https://ir.ishansong.com/corporate-information/company-profile) · [Nextdoor FY2025](https://www.businesswire.com/news/home/20260218233855/en/Nextdoor-Reports-Fourth-Quarter-and-Full-Year-2025-Results) · [nebenan.de (heise)](https://www.heise.de/en/background/nebenan-de-Value-is-created-by-the-neighborhood-not-by-the-platform-11272382.html) · [Streetbank (Wikipedia)](https://en.wikipedia.org/wiki/Streetbank)

Porażki: [Zaarly](https://startlandnews.com/2021/04/zaarly/) · [Homejoy (Forbes)](https://www.forbes.com/sites/ellenhuet/2015/07/23/what-really-killed-homejoy-it-couldnt-hold-onto-its-customers/) · [Takl](https://techstartups.com/2021/02/13/gig-economy-app-takl-shuts-burning-37-million-investors-money/) · [Exec](https://techcrunch.com/2013/09/10/rip-lazy-times/) · [GoLife](https://www.thejakartapost.com/news/2019/12/17/gojek-to-shut-down-several-golife-services.html) · [TaskRabbit pivot 2014](https://techcrunch.com/2014/06/17/following-a-drop-in-completed-jobs-errands-marketplace-taskrabbit-shakes-up-its-business-model)

Polska: [Fixly — porównanie 2026](https://oferia.com.pl/pl/blog/fixly-opinie-prowizje-cennik-porownanie-oferia-2026) · [Helpi (App Store)](https://apps.apple.com/pl/app/helpi-pomoc-s%C4%85siedzka/id6757124093) · [Po Sąsiedzku](https://www.tabletowo.pl/po-sasiedzku-aplikacja-do-bezplatnych-ogloszen/) · [SW Research: 80% Polaków](https://www.wnp.pl/tech/wiekszosc-polakow-korzysta-z-pomocy-sasiedzkiej-powstala-aplikacja-wzmacniajaca-sasiedzkie-wiezi,1042579.html) · [Otodom o sąsiedztwie](https://media.otodom.pl/sasiedztwo-nie-dzieje-sie-samo-prawie-polowa-polakow-czeka-na-lidera)

Prawo: [Limit działalności nierejestrowanej 2026](https://www.infakt.pl/blog/dzialalnosc-nierejestrowana-nowe-zasady-limitu-w-2026-r/) · [DAC7 (podatki.gov.pl)](https://www.podatki.gov.pl/podatkowa-wspolpraca-miedzynarodowa/dpi-digital-platform-information/informacje-o-obowiazkach-operatorow-platform/) · [PIT od zleceń prywatnych](https://ksiegowosc.infor.pl/podatki/podatki-osobiste/pit/708960,Umowa-zlecenia-i-umowa-o-dzielo-zawarte-miedzy-osobami-fizycznymi-rozliczenie-PIT.html)

Ekonomia: [Gneezy & Rustichini — A Fine is a Price](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=180117) · [Disintermediacja (Management Science)](https://www.researchgate.net/publication/397808083_Platform_Disintermediation_with_Repeated_Transactions) · [Sharetribe o wycieku 30–80%](https://www.sharetribe.com/academy/how-to-discourage-people-from-going-around-your-payment-system/) · [Nextdoor growth (USPS)](https://www.startupgrind.com/blog/90000-neighborhoods-and-counting-how-nextdoor-hacked-growth-with-the-usps/) · [Favor/Teksas](https://www.texasmonthly.com/news/heb-favor-acquisition/) · [Benchmarki CAC home services](https://foundrycro.com/blog/home-services-marketing-benchmarks-by-trade/)
