# Pomoc sąsiedzka — rozkmina, część III: sensowność przedsięwzięcia solo (founder + fabryka LLM)

Pytanie: czy budowa tego produktu ma sens w układzie „jedna osoba + Foundry (fabryka wykonawców LLM)". Analiza oparta o ustalenia z [części I](rozkmina-2026-08-badanie-rynku.md) i [II](rozkmina-2026-08-czesc-2-poglebienie.md).

Założenia (do potwierdzenia): BRAK danych o wymiarze czasu (full-time vs wieczory), budżecie gotówkowym i mieście startu. Poniżej wariantowo; tam gdzie założenie wpływa na wniosek — zaznaczone.

## 1. Kluczowa asymetria: software to mniejszość problemu

Z części I–II wynika, że w tej kategorii **kod nigdy nie był wąskim gardłem**. Zaarly, Takl, Homejoy miały dobre produkty i dziesiątki milionów dolarów — padły na dystrybucji, retencji i ekonomice. Helpi (PL) istnieje i działa — ma ~12 ocen w App Store. To, co decyduje o wyniku:

| Praca | Udział w sukcesie (ocena jakościowa) | Czy LLM-fabryka to robi? |
|---|---|---|
| Produkt/kod/infra | ~20% | **TAK — niemal w całości** |
| Zimny start: fizyczna akwizycja osiedle-po-osiedlu (ambasadorzy, plakaty, spotkania, „100 zapisanych") | ~35% | NIE (może wspierać: materiały, CRM, analityka) |
| Sprzedaż B2B2C do zarządców/PRS (cykle kwartalne, relacje) | ~25% | NIE (może wspierać: prospecting, oferty, follow-upy) |
| Trust & safety, moderacja, spory, incydenty | ~10% | CZĘŚCIOWO (triage automatyczny; decyzje i odpowiedzialność — nie) |
| Prawo/ubezpieczenia (umowy z TU, DAC7 w fazie płatności) | ~10% | CZĘŚCIOWO (research, drafty; negocjacje i podpisy — nie) |

**Wniosek nr 1: Foundry obniża koszt najtańszej strategicznie części przedsięwzięcia.** To nie unieważnia pomysłu — ale znaczy, że pytanie „czy dam radę solo" nie dotyczy kodu, tylko tego, czy chcesz i możesz robić robotę nietechniczną: chodzić po osiedlu, rozmawiać z zarządcami, gasić pierwszą awanturę między sąsiadami o 22:00.

## 2. Gdzie układ solo + LLM jest realną przewagą

1. **Burn ≈ 0 pasuje do jedynego działającego wzorca przetrwania.** Kategoria nie znosi tempa VC (Takl: −37 mln USD; Homejoy; GoLife). Przeżyli cierpliwi: Airtasker (~10 lat do dodatniego cash flow), Yoojo (bez VC), Karrot (rentowny po ~8 latach, z reklam). Solo founder bez pensji do wypłacenia i z fabryką LLM zamiast zespołu inżynierów może czekać latami — to strukturalnie **lepsze dopasowanie do kategorii niż startup z rundą**.
2. **Koszt iteracji bliski zeru.** Wnioski z części II (separacja modułów à la Karrot, mechaniki reputacji, waitlista „100 zapisanych") można testować i wyrzucać tanio; pivotowanie nie boli.
3. **Faza 1 zaprojektowana w części I jest operacyjnie „mała":** bez płatności (zero DAC7, zero PSP, zero KYC), bez ubezpieczeń, 1–3 osiedla. To jest zakres, który jedna osoba faktycznie ogarnia.
4. **Brak wspólników = brak sporów o kierunek** w fazie, w której produkt i tak trzeba przedefiniować kilka razy.

## 3. Gdzie solo boli — i na czym się to zwykle łamie

1. **Zimny start jest pracą nóg, nierównoległą.** Nextdoor wysyłał fizyczne pocztówki; nebenan aktywuje dzielnicę po 100 zapisanych; Favor wygrał gęstością, nie zasięgiem. Jedna osoba jest w jednym miejscu — realny sufit to **1–3 osiedla równolegle** (założenie: praca w wolnym czasie → raczej 1). SOM z części II (90–180 tys. MAU w 3 lata) jest **poza zasięgiem układu solo** — i to jest OK, o ile cel to walidacja, nie skala.
2. **Sprzedaż B2B2C nie automatyzuje się.** Zarządcy: cykl kwartalny, decyzje relacyjne, lokalny BD; spółdzielnie: zarząd + rada + przetarg. LLM przygotuje pipeline i ofertę, ale spotkania odbywa człowiek. Solo founder robiący jednocześnie produkt, ops osiedlowy i sprzedaż B2B to trzy pełne etaty — **tu jest strukturalny brak mocy**, nie w kodzie.
3. **Trust & safety na żywym organizmie.** Incydent (kradzież przy przysłudze, molestowanie, oszustwo) wymaga reakcji człowieka w godzinach, nie dniach — single point of failure: urlop/choroba foundera = platforma bez opieki. Przy małej skali ryzyko niskie, ale rośnie liniowo z gęstością, którą sam budujesz.
4. **Bus factor 1 dotyczy też zaufania B2B**: zarządca podpisujący umowę na moduł dla 5 tys. lokali pyta, co się stanie, gdy „firma" (jedna osoba) zniknie. To realna bariera sprzedażowa fazy 2.
5. **Obowiązki platformy istnieją nawet w fazie 1**: DSA (punkt kontaktowy, regulamin, mechanizm zgłoszeń — dla mikroplatform obowiązki okrojone, ale niezerowe), RODO (dane adresowe sąsiadów!), moderacja treści. Do udźwignięcia solo przy małej skali, ale trzeba to policzyć jako stałą godzinową, nie jednorazowy task.

## 4. Werdykt scenariuszowy

**A. Walidacja / side project (faza 1 z części I): SENSOWNE — i to mocno.**
Koszt gotówkowy bliski zeru (infra + LLM), Foundry buduje produkt, Ty robisz jedno osiedle — najlepiej **własne** (mieszkasz tam = jesteś ambasadorem, znasz zarządcę, widzisz tablicę ogłoszeń na klatce). Warunek sensowności: traktować to jako eksperyment z kill-kryteriami, nie jako firmę. To jest scenariusz o najlepszym stosunku informacji do ryzyka w całej tej rozkminie.

**B. Bootstrap-biznes (B2B2C do zarządców/PRS): GRANICZNE solo.**
Możliwe dopiero po walidacji z A i realnie wymaga drugiej pary rąk do sprzedaży (wspólnik handlowy, prowizyjny agent, albo „house account": jeden zarządca-partner zdobyty osobiście, na którym buduje się referencję). Bez tego faza 2 utknie nie z braku produktu, tylko z braku spotkań.

**C. Skala à la Karrot-PL: NIE solo.**
Reklama hiperlokalna jako model wymaga gęstości w wielu miastach = zespół ops + kapitał. To scenariusz na później i tylko jeśli A i B dowiozą metryki; wtedy zresztą pozycja negocjacyjna (działający produkt, zerowy burn) jest nieporównanie lepsza niż pitch z deckiem.

## 5. Warunki brzegowe eksperymentu (propozycja kill/go)

- **Przed startem**: waitlista na 1 osiedle; próg aktywacji ~100 zapisanych gospodarstw (wzorzec nebenan). Nie osiągnięty w 8–12 tygodni kampanii lokalnej → sygnał, że akwizycja jest droższa niż zakładana.
- **Po starcie (metryki płynności, nie rejestracji)**: fill rate zadań i mediana czasu pierwszej odpowiedzi. Propozycja progów: ≥40% zadań z odpowiedzią <24 h po 8 tygodniach; retencja autorów zadań (wracają z drugim zadaniem) ≥30% (progi = założenia własne, do kalibracji — BRAK branżowych benchmarków dla tej mikro-skali).
- **Go do fazy B** dopiero, gdy: (1) metryki płynności trzymają się ≥3 miesiące, (2) zarządca osiedla pilotażowego sam potwierdza wartość („mniej telefonów") — to jest materiał sprzedażowy na kolejnych.
- **Higiena solo**: limit godzinowy tygodniowy na ops/moderację zapisany z góry; przekraczany systematycznie → to sygnał do automatyzacji albo stopu, nie do heroizmu.

## 6. Ryzyka specyficzne układu founder + LLM-fabryka

1. **Iluzja postępu**: fabryka produkuje kod szybciej, niż osiedle produkuje popyt — łatwo mierzyć się commitami zamiast fill rate. Mitygacja: metryką tygodnia jest wyłącznie płynność osiedla; roadmapa produktu podporządkowana temu, czego brakuje w terenie.
2. **Nadprodukcja funkcji**: przy koszcie kodu ~0 pokusa budowy escrow/ubezpieczeń/reputacji przed pierwszym sąsiadem. Część I–II mówią jasno: faza 1 = tablica + profil + „załatwione". Nic więcej.
3. **Jakość bez człowieka-recenzenta**: bramki Foundry (testy, evidence, konstytucja) częściowo to adresują; ryzyko rezydualne w UX i copy po polsku — tu przegląd ludzki (Twój) pozostaje obowiązkowy, bo apka sąsiedzka żyje z tonu komunikacji.
4. **Ciągłość**: plan awaryjny na niedostępność foundera (choćby: auto-komunikat + zamrożenie rejestracji) powinien istnieć zanim pojawi się pierwszych 100 użytkowników — to godzina pracy, a chroni zaufanie, które jest jedynym aktywem.

## 7. Sedno

Solo + Foundry **nie jest kompromisem — jest poprawnym doborem narzędzia do fazy**: kategoria wybacza powolność, a karze przepalanie; jedyna tania część (produkt) jest u Ciebie najtańsza na rynku. Przedsięwzięcie jest sensowne pod trzema warunkami: (1) cel fazy 1 to walidacja płynności na 1 osiedlu (najlepiej własnym), nie „aplikacja dla Polski"; (2) akceptujesz, że większość Twojego — ludzkiego — czasu pójdzie na robotę nietechniczną; (3) z góry ustawione kill-kryteria faktycznie zatrzymują projekt, jeśli osiedle nie odpowie. Największe ryzyko całości nie jest rynkowe ani techniczne — jest nim founder budujący w nieskończoność produkt, którego nikt nie ciągnie, bo budowanie stało się darmowe.
