// Firestore güvenlik kuralları testleri (Firebase emülatöründe çalışır).
import { readFileSync } from 'node:fs';
import { test, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment, assertSucceeds, assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, setDoc, getDoc, getDocs, addDoc, collection, query, where, orderBy, serverTimestamp,
} from 'firebase/firestore';

let env;
const A = 'aliceUid', B = 'bobUid', C = 'eveUid';
const T = 'tv-1399';
const chat = `${A}_${B}__${T}`;
const msgs = (db) => collection(db, 'chats', chat, 'messages');
const msg = (uid, s, e, text = 'selam') => ({
  authorId: uid, titleId: T, season: s, episode: e, epIndex: s * 1000 + e, text, sentAt: serverTimestamp(),
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-izleyelim',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8080 },
  });
});
after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [u, code] of [[A, 'AAAAAA'], [B, 'BBBBBB'], [C, 'CCCCCC']]) {
      await setDoc(doc(db, 'users', u), { name: u, friendCode: code, platforms: [] });
      await setDoc(doc(db, 'friendCodes', code), { uid: u });
    }
    await setDoc(doc(db, 'users', A, 'friends', B), { since: 1 });
    await setDoc(doc(db, 'users', B, 'friends', A), { since: 1 });
    // Alice S1B5'te, Bob S2B3'te.
    await setDoc(doc(db, 'users', A, 'progress', T), { season: 1, episode: 5, epIndex: 1005 });
    await setDoc(doc(db, 'users', B, 'progress', T), { season: 2, episode: 3, epIndex: 2003 });
    await setDoc(doc(db, 'chats', chat, 'messages', 'm1'), { ...msg(B, 1, 2), sentAt: new Date() });
    await setDoc(doc(db, 'chats', chat, 'messages', 'm2'), { ...msg(B, 2, 1, 'spoiler'), sentAt: new Date() });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

test('izlediğim bölüme kadar olan mesajları okuyabilirim', async () => {
  const q = query(msgs(as(A)), where('epIndex', '<=', 1005), orderBy('epIndex'));
  const snap = await assertSucceeds(getDocs(q));
  if (snap.size !== 1) throw new Error(`1 mesaj bekleniyordu, ${snap.size} geldi`);
});

test('izlemediğim bölümün mesajını okuyamam (sorguyla da, tek tek de)', async () => {
  await assertFails(getDocs(query(msgs(as(A)), where('epIndex', '<=', 2003))));
  await assertFails(getDocs(msgs(as(A))));
  await assertFails(getDoc(doc(as(A), 'chats', chat, 'messages', 'm2')));
});

test('sohbet üyesi olmayan okuyamaz', async () => {
  await assertFails(getDocs(query(msgs(as(C)), where('epIndex', '<=', 1))));
});

test('ikimizin de izlediği bölüme yazabilirim', async () => {
  await assertSucceeds(addDoc(msgs(as(A)), msg(A, 1, 5)));
  await assertSucceeds(addDoc(msgs(as(B)), msg(B, 1, 5)));
});

test('arkadaşımın izlemediği bölüme yazamam', async () => {
  await assertFails(addDoc(msgs(as(B)), msg(B, 2, 1)));
});

test('başkası adına ya da sahte bölümle yazamam', async () => {
  await assertFails(addDoc(msgs(as(A)), msg(B, 1, 1)));
  await assertFails(addDoc(msgs(as(A)), { ...msg(A, 1, 1), epIndex: 999 }));
});

test('başkasının ilerlemesini değiştiremem, arkadaş olmayan göremez', async () => {
  await assertFails(setDoc(doc(as(A), 'users', B, 'progress', T), { season: 1, episode: 1, epIndex: 1001 }));
  await assertSucceeds(getDoc(doc(as(A), 'users', B, 'progress', T)));
  await assertFails(getDoc(doc(as(C), 'users', B, 'progress', T)));
});

test('arkadaş ekleme yalnızca geçerli kodla olur', async () => {
  await assertFails(setDoc(doc(as(C), 'users', C, 'friends', A), { since: 1, code: 'BBBBBB' }));
  await assertFails(setDoc(doc(as(C), 'users', A, 'friends', C), { since: 1 }));
  await assertSucceeds(setDoc(doc(as(C), 'users', C, 'friends', A), { since: 1, code: 'AAAAAA' }));
  await assertSucceeds(setDoc(doc(as(C), 'users', A, 'friends', C), { since: 1 }));
});
