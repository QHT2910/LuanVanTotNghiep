const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const dir = path.resolve(__dirname, '../../evidence-m2');
const events = JSON.parse(fs.readFileSync(path.join(dir, 'runtime-events.json'), 'utf8'));
for (let i = 1; i < events.length; i++) {
  assert(events[i].eventId > events[i - 1].eventId);
  assert(events[i].simTime >= events[i - 1].simTime);
}
const releases = events.filter(e => e.event === 'shot_release');
const scores = events.filter(e => e.event === 'score');
assert.equal(releases.length, 2);
assert.deepEqual(scores.map(e => [e.shotId, e.points, e.score]), [[1, 3, 3], [2, 3, 6]]);
assert.equal(new Set(scores.map(e => e.shotId)).size, scores.length);
assert(releases[0].feetX < -1 && releases[0].charge > 0.5 && releases[0].charge < 0.7);
const cancel = events.find(e => e.event === 'charge_cancel' && e.reason === 'pointer_cancel');
const paused = events.find(e => e.event === 'paused');
const resumed = events.find(e => e.event === 'resumed' && e.eventId > paused?.eventId);
assert(cancel && paused && resumed);
assert(cancel.eventId > releases[0].eventId && cancel.eventId < paused.eventId);
assert(releases[1].eventId > resumed.eventId && releases[1].simTime > resumed.simTime);
for (const release of releases) assert(events.some(e => e.event === 'round_reset' && e.eventId > release.eventId));
for (const name of ['multi', 'multi-resumed']) {
  const text = fs.readFileSync(path.join(dir, 'touch-' + name + '.txt'), 'utf8');
  assert(text.includes('BOTH_DOWN') && text.includes('SHOOT_UP_JOYSTICK_STILL_DOWN') && text.includes('JOYSTICK_UP'));
}
assert(fs.readFileSync(path.join(dir, 'touch-cancel.txt'), 'utf8').includes('BOTH_CANCELLED'));
const result = {pass: true, releases: releases.map(e => ({shotId: e.shotId, charge: e.charge, feetX: e.feetX, feetZ: e.feetZ})), scores: scores.map(e => [e.shotId, e.points, e.score]), cancel: true, resumeThenShot: true, limits: 'No per-pointer cancel runtime oracle; that independence is covered by widget tests. AVD is not a physical phone.'};
fs.writeFileSync(path.join(dir, 'runtime-assertions.json'), JSON.stringify(result, null, 2));
console.log('PASS 2 releases, unique scores 3+3, cancel, resume then shot; see runtime-assertions.json');
