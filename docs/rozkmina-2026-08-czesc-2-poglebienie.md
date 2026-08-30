# Pomoc sąsiedzka — rozkmina, część II: pogłębienie

Stan danych: sierpień 2026. Kontynuacja [części I](rozkmina-2026-08-badanie-rynku.md). Cztery wątki: kanał B2B2C w Polsce, teardown zwycięzców (nebenan.de/Nextdoor), incumbenci (Meta/OLX/Glovo), domknięcie luk (ubezpieczenia, sizing, reputacja, hybrydy). Pozycje „szacunek"/„założenie" oznaczone.

**Najważniejsza korekta względem części I:** hybryda „płatne + darmowe" w jednym produkcie ISTNIEJE i działa na masową skalę — koreański **Karrot/Daangn** (~19 mln MAU, rentowny). Ale trzyma oba światy w **osobnych modułach**, nie na jednej tablicy — szczegóły w sekcji 4.4.

## 1. Kanał B2B2C w Polsce: zarządcy, spółdzielnie, wspólnoty, PRS

### 1.1 Struktura rynku

- ~16,0 mln mieszkań w PL (GUS, koniec 2024), z czego **8,61 mln w budynkach wielorodzinnych** (NSP 2021) w ~558 tys. budynków.
- **Spółdzielnie**: ~2 900 aktywnych, ~1,8 mln mieszkań, ~6 mln mieszkańców.
- **Wspólnoty**: ~194 tys. w bazach komercyjnych; ~90% obsługuje zewnętrzny zarządca.
- **Zarządcy**: zawód zderegulowany od 2014; ~165 tys. podmiotów w PKD 68.32, ale 98,9% to mikrofirmy — realnie adresowalnych jest kilka–kilkanaście tysięcy firm z portfelami (BRAK precyzyjnych danych o aktywnych).
- **Kto decyduje**: software za 1–3 zł/lokal/mies. mieści się w zwykłym zarządzie — **kupującym jest zarządca** (jedno narzędzie na cały portfel = jeden deal to setki–tysiące lokali). Spółdzielnie: zarząd + rada nadzorcza + przetargi = cykl kwartałów.

### 1.2 Gracze (skrót)

| Gracz | Co robi | Cena | Funkcje sąsiedzkie |
|---|---|---|---|
| e-Osiedle | komunikacja, usterki, głosowania | 1,60–2,40 zł/aktywny lokal/mies. | TAK (marketplace, pomoc sąsiedzka) — bez dowodów trakcji |
| OsiedleApp | j.w. + „rynek osiedla" | brak cennika | TAK — bez dowodów trakcji |
| Dla Sąsiadów | komunikacja + pomoc sąsiedzka jako core | **darmowy** (model monetyzacji: BRAK) | TAK |
| Osiedle360 | e-BOK + naliczenia + KSeF | **1,10–1,30 zł/aktywny lokal/mies.** — benchmark cenowy | NIE |
| Weles3, PROBIT, e-kartoteka/Mieszczanin, ADA, eMieszkaniec, MojaSpółdzielnia | ERP księgowy + panel mieszkańca | wyceny indywidualne | NIE — „konkurencja przez inercję" |
| Blisko/SISMS | broadcast dla samorządów (500+ gmin) | abonament nadawcy | NIE |
| Appartme (Murapol, Skanska), Blue Bolt (Archicom), Echo SMART | smart home / dostęp, instalowane przez dewelopera | w cenie mieszkania | NIE |

Apki deweloperów są **techniczne** (dostęp, media), nie społecznościowe. Case'u „zarządca/deweloper zbudował marketplace usług i osiągnął skalę" — nie znaleziono (BRAK). Sygnał ostrzegawczy i wolne pole naraz.

### 1.3 PRS — polski odpowiednik amerykańskiego multifamily

~28,5 tys. aktywnych lokali (XII 2025), prognoza >36 tys. do 2027–28. Konsolidacja: Resi4Rent→Vantage (TAG), 5 322 lokale za ~2,44 mld zł (V 2026). Operatorzy (Vantage Rent, Resi4Rent, Heimstaden, LifeSpot) mają **e-BOKi najemcy**, nie apki społecznościowe — polskiego odpowiednika Livly/Amenify BRAK. Mały kanał (30 tys. vs 8,6 mln lokali), ale **3–4 centralnych decydentów** i najbardziej „amerykański" profil zakupowy.

### 1.4 Wnioski kanałowe

1. **„Moduł komunikacji” to red ocean** — e-BOK sprzedają ERP-y zintegrowane z naliczeniami za 1–2,5 zł/lokal. Wejście czystą komunikacją = wojna cenowa z incumbentami.
2. Wyróżnik do sprzedania zarządcy to nie kolejny e-BOK, tylko **adopcja**: pomoc sąsiedzka/marketplace jako powód, dla którego mieszkańcy faktycznie otwierają apkę („mniej telefonów do administracji”).
3. Najkrótsza ścieżka: (a) zarządcy z portfelami 3–10 tys. lokali, (b) **PRS jako beachhead premium**; spółdzielnie na później.
4. Zarządcy są silnie wrażliwi cenowo (marże ~0,5–1 zł/m²/mies., opłaty wspólnot rosną do 20% r/r) — nowy koszt musi wypierać istniejący (papier, poczta, telefony).

## 2. Teardown zwycięzców: nebenan.de i Nextdoor

### 2.1 nebenan.de — bliski wzorzec, brutalna ekonomia

- Historia: Berlin 2015 (Good Hood GmbH), ~25,7 mln USD finansowania; **2020: Burda przejmuje 61%**. Wzrost: 1 mln (2018) → 4,3 mln członków (2026), ~10 tys. sąsiedztw.
- Model przychodowy: płatne profile firm (Gewerbeprofil), płatne profile organizacji/urzędów (~500), **dobrowolne wpłaty od 1 €/mies. bez benefitów** („Spendenmodell"), wyróżnienie ogłoszenia 2,49 €/5 dni. Konwersja wpłat: BRAK danych.
- **Kluczowy fakt: nierentowni od 10 lat.** Strata −4,9 mln € (2023), −7,2 mln € (2024); żyją z kroplówki Burdy. Ekspansja FR/ES/IT **zamknięta w 2023** — masa krytyczna musi powstać osobno w każdej dzielnicy, koszt akwizycji nie przenosi się między krajami.
- Mechaniki warte skopiowania: weryfikacja adresu (kod listem / dowód / GPS); **sąsiedztwo aktywuje się dopiero po zebraniu 100 zapisanych** (waitlista buduje masę krytyczną przed startem); rytm ~1 wizyta/tydzień zamiast doomscrollingu; impact: **80% użytkowników w ciągu roku udzieliło lub otrzymało pomoc**.

### 2.2 Nextdoor — skala bez nawyku

- FY2025: przychód 258 mln USD (+4%), strata netto 54 mln USD (pierwsza dodatnia skoryg. EBITDA), **WAU 21 mln i spada** (−5% r/r); kurs −80% od IPO.
- Diagnozy: toksyczność feedu skargowego; moderacja wolontariuszami („Leads") niewydolna; WAU pompowane notyfikacjami, nie potrzebą; „milszy feed = mniej reklam".
- Pivot „NEXT" (2024, powrót foundera): lokalne newsy (3 500+ wydawców), alerty kryzysowe, asystent AI „Faves". Działa połowicznie: przychody rekordowe, użytkownicy dalej ubywają.
- Funkcje pomocowe (Help Map z COVID, Sell for Good) nigdy nie stały się rdzeniem; **płatnych transakcji P2P brak**.

### 2.3 Lekcje przekrojowe

- **Motorem retencji jest użyteczność (transakcja pomocowa, ogłoszenia, rekomendacje), nie dyskusje** — dyskusje generują toksyczność i koszt moderacji.
- Samorządy/instytucje: świetny **kanał dystrybucji i wiarygodności, słaby płatnik** (nebenan mimo opłat od urzędów notuje miliony straty).
- Żaden z nich nie procesuje płatności P2P — świadomie: KYC/PSD2, odpowiedzialność, prowizja od drobnych kwot nie uniesie biznesu. To luka i ostrzeżenie jednocześnie.
- Czego unikać: ekspansja przed rentownością jednego rynku; moderacja wolontariacka; „bez reklam" bez policzonego modelu.

## 3. Incumbenci: czemu nikt tego nie zjadł i czy zje

### 3.1 Meta

- **Facebook Neighborhoods** (klon Nextdoora) zamknięty 1.10.2022 — redundancja z Grupami, cięcia „year of efficiency", zwrot ku Reels/AI.
- **Grupy są wygaszane**: spadki organicznego zasięgu 30–60% (2023→2025), schowane w UI, algorytm premiuje Reels; w VI 2025 automoderacja AI masowo skasowała legalne grupy bez ostrzeżenia — mocny argument sprzedażowy przeciw „mieszkaniu" społeczności na FB.
- Marketplace w PL: silny w **rzeczach**, kategorii usług/przysług brak. Nowe lokalne ruchy Mety (zakładka Local, Local Jobs X 2025) — tylko USA.
- Żeby zjeść niszę, Meta musiałaby zbudować płatności/escrow za usługi, weryfikację adresu, reputację wykonawcy i strukturę „osiedle" — czyli reaktywować produkt, z którego się wycofała. **Ryzyko krótkoterminowe: niskie.** Realne zagrożenie to inercja użytkowników w degradujących się grupach.

### 3.2 OLX / Allegro / logistyka

- OLX: Fixly **wydzielone** ze struktur (XI 2025) — kierunkowo zdejmowanie usług z core'u, nie ekspansja; priorytety FY2025: AI, praca, moto. Allegro Lokalnie: usługi wprost **niedopuszczalne** regulaminem.
- Najbardziej prawdopodobny ruch incumbenta to **akwizycja działającego gracza**, nie budowa in-house. Ryzyko średnioterminowe: umiarkowane.
- Glovo „Cokolwiek" / Uber Connect: czysta logistyka punkt-punkt (przynieś/odbierz), nie praca u klienta.

### 3.3 Nisza już zagospodarowywana bokiem: assistance i benefity

- Home assistance w polisach (~10 TU, PZU Pomoc, Orange Dom Assistance): ślusarz/hydraulik w abonamencie, ~2,5 mln Polaków rocznie korzysta.
- Kafeterie benefitowe (Worksmile/Motivizer) już przyjmują apki „pomocowe": **Stepapp** (sprzątanie), **SeniorApp** (opieka/pomoc seniorom) — **SeniorApp jest funkcjonalnie najbliżej naszego modelu**. Kanał benefitowy = otwarta droga dystrybucji.

### 3.4 Defensywność

1. **Hiperlokalne efekty sieciowe**: wartość powstaje osiedle po osiedlu; globalny graf FB nie daje przewagi bez lokalnej gęstości płynności. Metryka obronna: czas do dopasowania i fill rate per osiedle, nie krajowe MAU.
2. **Reputacja transakcyjna jako switching cost** — FB ma tożsamość, nie ma reputacji w usługach; broni dopiero reputacja sprzężona z płatnością i sporami.
3. **Fragmentacja obu stron** zwiększa defensywność, ale powtarzalne pary sąsiad–sąsiad uciekają z platformy — wartość musi być po-matchingowa (płatność, ubezpieczenie, kalendarz).
4. **Kontrakty B2B** (zarządcy, kafeterie) to fosa wymagająca lokalnego BD, nie kodu — incumbent jej szybko nie skopiuje.

## 4. Domknięcie luk z części I

### 4.1 OC i ubezpieczenia — potwierdzona luka produktowa

- Polskie OWU „OC w życiu prywatnym": ochrona obejmuje „czynności życia prywatnego" definiowane przez wykluczenie zarobku. **PZU** wyłącza pracę zarobkową i… **wolontariat sformalizowany**; Ergo Hestia i Link4 analogicznie (Hestia sprzedaje zarobkowe OC jako osobny produkt dla JDG). Wniosek: **darmowa przysługa grzecznościowa — co do zasady objęta; odpłatne zadanie — poza ochroną**, niezależnie od tego, że działalność nierejestrowana nie jest działalnością gospodarczą. (Warta/Allianz: pełne OWU do doczytania — BRAK.)
- Wzorce rozwiązań: **Airtasker** — grupowa polisa OC, w której ubezpieczonymi są wykonawcy podczas zadania (platforma jest ubezpieczającym); TaskRabbit — polisa chroni spółkę, „Happiness Pledge" to gwarancja handlowa, nie ubezpieczenie. Embedded insurance dla gig-workerów w EU robi **Qover** (Glovo, Deliveroo — NNW+OC) i Zego (UK, włączane godzinowo).
- **Implikacja produktowa**: grupowa polisa à la Airtasker (z Qover lub polskim TU) to realny wyróżnik płatnej ścieżki — dokładnie ta wartość po-matchingowa, która broni przed disintermediacją.

### 4.2 Sizing rynku PL

- TAM: dorośli w zabudowie wielorodzinnej ≈ **15–16 mln osób** (8,61 mln mieszkań × ~2,3 os. × ~80% dorosłych; smartfony ~97% — nie ograniczają).
- SAM: miasta 100 tys.+ (34 miasta, ~10,7 mln), ~70% w zabudowie wielorodzinnej (założenie) → **~6 mln dorosłych**.
- SOM (3 lata): benchmark nebenan (~4,3% populacji po 10 latach); realistyczne 1,5–3% SAM = **90–180 tys. MAU** — pod warunkiem zdobywania osiedle-po-osiedlu (szacunek własny).
- Zagadka z części I rozwiązana połowicznie: **Next2** to marka dwóch twórczyń 50+ (apka szybkiego kontaktu z sąsiadami; filozofia „wyprowadzać do świata realnego"); nazwa w sklepach i trakcja — BRAK danych. Walidacja tematu bez dowodu skali; nie ma modułu płatnych zadań.

### 4.3 Mechaniki reputacji — 7 zasad projektowych

Z analizy BlaBlaCar (88% ufa pełnemu profilowi — framework D.R.E.A.M.S.), Couchsurfingu (komercjalizacja rozmyła normy wzajemności), Vinted (Polacy ufają escrow, nie ludziom), timebankingu (systemowo więdnie) i karmy (Wykop/Reddit):

1. Weryfikuj **adres**, nie tylko tożsamość — „z mojego osiedla" to nośnik zaufania.
2. Pełny profil (zdjęcie+bio+weryfikacja) jako warunek widoczności.
3. Jeden poziom zaufania zasilany **oboma** typami aktywności (przysługi budują status, nie walutę).
4. **Escrow na płatnych od pierwszego dnia** (wzorzec Vinted — środki mrożone do potwierdzenia).
5. Żadnych wymienialnych punktów za przysługi — karma = status/odznaki/pierwszeństwo, nigdy środek płatniczy (grób timebankingu).
6. **Nigdy nie monetyzuj warstwy darmowej** (lekcja Couchsurfingu).
7. Gęstość przed zasięgiem: osiedla otwierane falami, z lokalnym ambasadorem.

### 4.4 Hybrydy „płatne + darmowe" — korekta wniosku z części I

- **Karrot / Daangn (Korea)** — największa hyperlocal apka świata i **działająca hybryda**: ~19 mln MAU, przychód 189,1 mld KRW (2024, +48%), **rentowna od 2023**, wycena ~2,7 mld USD (2021). Ma darmowe oddawanie rzeczy, życie lokalne ORAZ **Daangn Alba** — tablicę drobnych płatnych fuch sąsiedzkich. Monetyzacja: niemal wyłącznie **hiperlokalna reklama, bez prowizji C2C**. Kluczowy niuans: płatne fuchy i darmowa pomoc żyją w **osobnych zakładkach**. Ekspansja zagraniczna idzie opornie (Kanada: 90 mld KRW bez monetyzacji).
- **QuickFavor (USA)** — dokładnie nasz mechanizm (jedna tablica, przy każdej przysłudze wybór: gotówka albo za darmo) — **bez śladu trakcji**.
- ANYTIMES (Japonia) — płatna pomoc sąsiedzka C2C w jednym feedzie, skala mała; TokyoHelp — tylko darmowa.
- **Werdykt**: teza „jedna wspólna tablica płatne+darmowe" pozostaje niesfalsyfikowana na dużą skalę; Karrot sugeruje **wyraźny rozdział modułów wewnątrz jednej apki** zamiast jednego feedu — i pokazuje, że monetyzacją hybrydy jest reklama lokalna + ogłoszenia, nie prowizja.

## 5. Synteza strategiczna po części II

Co się zmieniło względem części I:

1. **Karrot staje się wzorcem nadrzędnym** (zamiast „białej plamy"): hyperlocal z darmową wymianą jako silnikiem gęstości + osobny moduł płatnych fuch + monetyzacja reklamą lokalną/ogłoszeniami, zero prowizji C2C. To spina wszystkie wcześniejsze wnioski (ekonomia drobnicy, crowding-out, disintermediacja).
2. **Kanał B2B2C potwierdzony, ale z korektą**: nie sprzedajemy „komunikacji" (red ocean ERP-ów za 1–2,5 zł/lokal), sprzedajemy **adopcję i odciążenie administracji**; wejście przez zarządców z dużymi portfelami + PRS jako beachhead; kafeterie benefitowe (Worksmile/Motivizer) jako drugi, już przetarty kanał.
3. **Ubezpieczenie grupowe wykonawców (wzorzec Airtasker + Qover)** awansuje do rangi kluczowego wyróżnika płatnej ścieżki — bo OC w życiu prywatnym potwierdzenie NIE pokrywa odpłatnych przysług, a to jedyna wartość, której sąsiedzi nie załatwią SMS-em po pierwszym kontakcie.
4. **Okno konkurencyjne jest otwarte**: Meta wygasza Grupy (i masowo kasuje je automoderacją — argument sprzedażowy), OLX wydziela usługi, Allegro ich zakazuje, polskie apki osiedlowe mają marketplace „na slajdach". Najbliższy realny gracz: SeniorApp (wąska nisza seniorów).
5. **Skala celu urealniona**: SOM ~90–180 tys. MAU w 3 lata przy dyscyplinie osiedle-po-osiedlu; nebenan przypomina, że nawet 4,3 mln członków nie gwarantuje rentowności bez modelu — Karrot, że reklama lokalna przy dużej gęstości już tak.

## 6. Otwarte BRAKi (po części II)

- BRAK: pełne OWU Warty i Allianza (brzmienie wyłączeń zarobkowych); stanowisko KNF/orzecznictwo o działalności nierejestrowanej vs „praca zarobkowa" w OC.
- BRAK: liczba aktywnych firm zarządczych; metryki trakcji e-Osiedle/OsiedleApp/Dla Sąsiadów; cenniki ERP-ów (Weles3, PROBIT).
- BRAK: konwersja „Spendenmodell" nebenan; stawki gmin za profile organizacji.
- BRAK: nazwa sklepowa i trakcja apki Next2; skala Marketplace FB w PL.
- BRAK: warunki finansowe wydzielenia Fixly z OLX (sprzedaż vs spin-off).

## 7. Źródła (wybór, ponad część I)

B2B2C PL: [GUS — Gospodarka mieszkaniowa 2024](https://stat.gov.pl/files/gfx/portalinformacyjny/pl/defaultaktualnosci/5492/14/8/1/gospodarka_mieszkaniowa_w_2024_r.pdf) · [IRMiR o spółdzielniach](https://irmir.pl/wp-content/uploads/2023/12/Dzialalnosc-i-znaczenie-spoldzielni-mieszkaniowych-w-Polsce-1.pdf) · [Osiedle360 — cennik](https://osiedle360.pl/cennik/) · [e-Osiedle](https://www.eosiedle.pl/) · [PRS 2026 (egospodarka)](https://www.egospodarka.pl/196854,Najem-instytucjonalny-w-Polsce-dynamiczny-wzrost-rynku-PRS-i-perspektywy-na-2026-2027,1,39,1.html) · [transakcja Resi4Rent→Vantage](https://tabelaofert.pl/blog/rynek-mieszkaniowy/najwieksza-umowa-na-rynku-najmu-instytucjonalnego-w-polsce-analiza-skutkow-transakcji-resi4rent-i-vantage-rent)

nebenan/Nextdoor: [Tech.eu — Burda przejmuje Good Hood](https://tech.eu/2020/09/01/burda-acquires-good-hood/) · [Companyhouse — straty Good Hood](https://www.companyhouse.de/Good-Hood-GmbH-Berlin) · [heise — wywiad CEO 2026](https://www.heise.de/en/background/nebenan-de-Value-is-created-by-the-neighborhood-not-by-the-platform-11272382.html) · [Vollmann o monetyzacji](https://medium.com/@vollmann/how-to-monetize-a-social-network-the-european-way-3b9acfd53fec) · [Nextdoor FY2025](https://about.nextdoor.com/press-releases/nextdoor-reportsfourth-quarter-and-full-year2025-results) · [WFAA — pivot NEXT](https://www.wfaa.com/article/money/dallas-nirav-tolia-nextdoor-app-changes-local-news-notifications/287-a173e30b-7639-4055-9ec8-42003e914733)

Incumbenci: [TechCrunch — zamknięcie FB Neighborhoods](https://techcrunch.com/2022/09/01/facebook-is-shutting-down-its-nextdoor-clone-next-month-following-tests-in-the-u-s-and-canada) · [Meta — Local Jobs](https://about.fb.com/news/2025/10/introducing-local-jobs-facebook/) · [OLX FY2025](https://www.isbtech.pl/2025/06/grupa-olx-oglasza-bardzo-dobre-wyniki-finansowe-za-rok-obrotowy-2025/) · [regulamin Fixly](https://fixly.pl/tos) · [a16z — network effects](https://a16z.com/16-ways-to-measure-network-effects/) · [SeniorApp × Worksmile](https://seniorapp.pl/seniorapp-worksmile-benefity-pracownicze)

Luki: [definicje OWU PZU](https://lawinsider.com/pl/contracts/jLEQEf8Bego) · [Ergo Hestia — OC JDG](https://www.ergohestia.pl/dla-firmy/jdg/ubezpieczenia-oc-w-zyciu-prywatnym-i-zawodowym/ogolne-informacje/) · [Airtasker — insurance](https://www.airtasker.com/us/insurance/) · [Qover × Glovo](https://www.qover.com/press/glovo-couriers-pledge-qover-insurance) · [NSP 2021 — mieszkania (Bankier)](https://www.bankier.pl/wiadomosc/Spis-powszechny-GUS-podal-dane-na-temat-liczby-mieszkan-w-Polsce-8341959.html) · [BlaBlaCar — Entering the Trust Age](https://blog.blablacar.com/wp-content/uploads/2016/05/entering-the-trust-age.pdf) · [Quartz — upadek Couchsurfingu](https://qz.com/96041/couchsurfings-downfall-is-a-stark-lesson-in-choosing-profits-over-a-do-gooder-customer-base) · [Springer — Time Banks as Transient Civic Organizations](https://link.springer.com/chapter/10.1007/978-3-030-71147-4_7) · [Businesskorea — wyniki Daangn 2024](https://www.businesskorea.co.kr/news/articleView.html?idxno=214069) · [Daangn Jobs](https://www.daangn.com/kr/jobs/about/) · [QuickFavor](https://www.quick-favor.com/) · [wnp.pl — Next2/SW Research](https://www.wnp.pl/tech/wiekszosc-polakow-korzysta-z-pomocy-sasiedzkiej-powstala-aplikacja-wzmacniajaca-sasiedzkie-wiezi,1042579.html)
