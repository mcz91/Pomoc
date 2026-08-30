/**
 * Stan serii pojedynków: wyszukiwanie binarne pozycji nowego miejsca w kubełku.
 *
 * Baza podaje wyłącznie rywala do porównania (rank_pivot) i zapisuje wynik
 * (rank_place). Stan przedziału żyje tutaj, w kliencie — dzięki temu pominięcie
 * porównania czy cofnięcie się o krok nie wymaga rundy po serwerze.
 */

export type Bucket = 'liked' | 'fine' | 'disliked';

export type Duel = {
  /** Przedział pozycji, w którym może wylądować oceniane miejsce (włącznie). */
  lo: number;
  hi: number;
};

export function startDuels(bucketSize: number): Duel {
  return { lo: 1, hi: bucketSize + 1 };
}

export function isSettled(duel: Duel): boolean {
  return duel.lo >= duel.hi;
}

/** Pozycja rywala, o którego pytamy — środek bieżącego przedziału. */
export function pivotPosition(duel: Duel): number {
  return Math.floor((duel.lo + duel.hi) / 2);
}

/**
 * `subjectWon` = oceniane miejsce jest lepsze od rywala, więc trafia wyżej
 * (na mniejszą pozycję) i przedział zwęża się do górnej połowy.
 */
export function answer(duel: Duel, subjectWon: boolean): Duel {
  const pivot = pivotPosition(duel);
  return subjectWon ? { lo: duel.lo, hi: pivot } : { lo: pivot + 1, hi: duel.hi };
}

/** Pominięcie: miejsce ląduje tam, gdzie stoi pytanie — bez dalszych pojedynków. */
export function skip(duel: Duel): Duel {
  const pivot = pivotPosition(duel);
  return { lo: pivot, hi: pivot };
}

export function finalPosition(duel: Duel): number {
  return duel.lo;
}

/** Ile pytań zostało w najgorszym razie — do paska postępu. */
export function remainingDuels(duel: Duel): number {
  return Math.max(0, Math.ceil(Math.log2(Math.max(1, duel.hi - duel.lo + 1))));
}
