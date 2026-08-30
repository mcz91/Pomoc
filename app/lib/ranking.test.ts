import assert from 'node:assert/strict';
import test from 'node:test';

import { answer, finalPosition, isSettled, pivotPosition, skip, startDuels } from './ranking.ts';

/** Symuluje serię pojedynków przeciwko kubełkowi o znanej, prawdziwej kolejności. */
function settle(bucketSize: number, betterThan: (rivalPosition: number) => boolean) {
  let duel = startDuels(bucketSize);
  let questions = 0;
  while (!isSettled(duel)) {
    duel = answer(duel, betterThan(pivotPosition(duel)));
    questions += 1;
    assert.ok(questions <= 20, 'seria pojedynków nie może się zapętlić');
  }
  return { position: finalPosition(duel), questions };
}

test('pierwsze miejsce w pustym kubełku nie wymaga ani jednego pojedynku', () => {
  const duel = startDuels(0);
  assert.equal(isSettled(duel), true);
  assert.equal(finalPosition(duel), 1);
});

test('miejsce lepsze od wszystkich ląduje na czele', () => {
  const { position } = settle(8, () => true);
  assert.equal(position, 1);
});

test('miejsce gorsze od wszystkich ląduje na końcu', () => {
  const { position } = settle(8, () => false);
  assert.equal(position, 9);
});

test('znajduje każdą pozycję w kubełku i nie przekracza log2 pytań', () => {
  const bucketSize = 40;
  for (let target = 1; target <= bucketSize + 1; target += 1) {
    // Oceniane miejsce jest lepsze dokładnie od tych, które stoją na pozycji >= target.
    const { position, questions } = settle(bucketSize, (rival) => rival >= target);
    assert.equal(position, target, `pozycja docelowa ${target}`);
    assert.ok(questions <= 6, `pozycja ${target}: ${questions} pytań to za dużo`);
  }
});

test('pominięcie kończy serię bez dalszych pytań', () => {
  const duel = skip(startDuels(40));
  assert.equal(isSettled(duel), true);
  assert.equal(finalPosition(duel), pivotPosition(startDuels(40)));
});
