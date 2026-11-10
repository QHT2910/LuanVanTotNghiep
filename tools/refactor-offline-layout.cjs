'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const app = path.join(root, 'game', 'offline-practice');
const args = process.argv.slice(2);
if (args.some(x => x !== '--apply') || args.length > 1) {
  throw Error('Usage: node tools/refactor-offline-layout.cjs [--apply]');
}
const apply = args.includes('--apply');
const hash = value =>
  crypto.createHash('sha256').update(value).digest('hex');

function checked(relative) {
  const full = path.resolve(app, relative);
  const rel = path.relative(app, full);
  if (!rel || rel.startsWith('..') || path.isAbsolute(rel)) {
    throw Error('Path outside app: ' + relative);
  }
  let current = full;
  while (current !== path.dirname(current)) {
    if (fs.existsSync(current) && fs.lstatSync(current).isSymbolicLink()) {
      throw Error('Symlink/junction rejected: ' + relative);
    }
    if (current === app) break;
    current = path.dirname(current);
  }
  return full;
}
function read(relative) {
  const full = checked(relative);
  if (!fs.statSync(full).isFile()) throw Error('Expected file: ' + relative);
  return fs.readFileSync(full, 'utf8');
}
function dartFiles(relative) {
  const directory = checked(relative);
  if (!fs.existsSync(directory)) return [];
  const out = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    if (entry.isSymbolicLink()) throw Error('Unexpected linked entry');
    const item = relative + '/' + entry.name;
    if (entry.isDirectory()) out.push(...dartFiles(item));
    else if (entry.isFile() && entry.name.endsWith('.dart')) out.push(item);
  }
  return out.sort();
}
const move = new Map([
  ['lib/config.dart', 'lib/src/simulation/config.dart'],
  ['lib/practice.dart', 'lib/src/simulation/practice.dart'],
  ['lib/joystick.dart', 'lib/src/input/joystick.dart'],
  ['lib/jump_button.dart', 'lib/src/input/jump_button.dart'],
]);
const imports = new Map([
  ['config.dart', 'src/simulation/config.dart'],
  ['practice.dart', 'src/simulation/practice.dart'],
  ['joystick.dart', 'src/input/joystick.dart'],
  ['jump_button.dart', 'src/input/jump_button.dart'],
]);
assert.deepEqual(dartFiles('lib'), ['lib/main.dart', ...move.keys()].sort(),
  'Expected unrefactored five-file lib');
assert.match(read('pubspec.yaml'), /^name:\s*offline_practice\s*$/m);
const original = read('lib/main.dart');
const entryMarker = 'Future<void> main() async {';
const pageMarker = 'class PracticePage extends StatefulWidget {';
const entryIndex = original.indexOf(entryMarker);
const pageIndex = original.indexOf(pageMarker);
assert(entryIndex >= 0 && pageIndex > entryIndex);
assert.equal(original.indexOf(entryMarker, entryIndex + 1), -1);
assert.equal(original.indexOf(pageMarker, pageIndex + 1), -1);
const originalBody = original.slice(pageIndex);
const bootstrapBody = original.slice(entryIndex, pageIndex).trim();
assert(bootstrapBody.includes(
  'runApp(const MaterialApp(home: PracticePage()));'));
const bootstrap =
  "import 'package:flutter/material.dart';\n" +
  "import 'package:flutter/services.dart';\n" +
  "import 'src/presentation/practice_page.dart';\n\n" +
  bootstrapBody + '\n';

let pageHeader = original.slice(0, entryIndex);
assert.equal((pageHeader.match(
  /^import 'package:flutter\/services\.dart';\r?$/gm) || []).length, 1);
pageHeader = pageHeader.replace(
  /^import 'package:flutter\/services\.dart';\r?\n/m, '');
for (const [oldName, newName] of imports) {
  const oldLine = "import '" + oldName + "';";
  assert.equal(pageHeader.split(oldLine).length - 1, 1);
  pageHeader = pageHeader.replace(oldLine,
    "import 'package:offline_practice/" + newName + "';");
}
const page = pageHeader.trimEnd() + '\n\n' + originalBody;
assert.equal(page.slice(page.indexOf(pageMarker)), originalBody);

const creates = new Map();
for (const [from, to] of move) creates.set(to, read(from));
creates.set('lib/src/presentation/practice_page.dart', page);
for (const file of creates.keys()) {
  if (fs.existsSync(checked(file))) throw Error('Destination exists: ' + file);
}
const updates = new Map([['lib/main.dart', bootstrap]]);
const originals = new Map([['lib/main.dart', original]]);
let importChanges = 0;
for (const file of [...dartFiles('test'), ...dartFiles('tool')]) {
  const before = read(file);
  let after = before;
  for (const [oldName, newName] of imports) {
    const from = 'package:offline_practice/' + oldName;
    const to = 'package:offline_practice/' + newName;
    // The known import names contain no regexp metacharacters except dots.
    const escaped = from.replaceAll('.', '\\.');
    const pattern = new RegExp(
      "^(import\\s+['\"])" + escaped + "(['\"][^\\r\\n]*)$", 'gm');
    after = after.replace(pattern, (_, a, b) => {
      importChanges++;
      return a + to + b;
    });
    if (after.includes(from)) {
      throw Error('Unhandled old path outside import directive: ' + file);
    }
  }
  if (after !== before) {
    updates.set(file, after);
    originals.set(file, before);
  }
}
assert(importChanges > 0);
console.log(JSON.stringify({
  mode: apply ? 'apply' : 'plan',
  create: [...creates.keys()],
  update: [...updates.keys()],
  removeFiles: [...move.keys()],
  changedImportDirectives: importChanges,
  practicePageBodySha256: hash(originalBody),
  unchangedMovedSourceHashes: Object.fromEntries(
    [...move].map(([from, to]) => [to, hash(read(from))])),
}, null, 2));

if (apply) {
  for (const [file, content] of originals) {
    assert.equal(read(file), content, 'Changed after preflight: ' + file);
  }
  for (const [file, content] of creates) {
    const full = checked(file);
    fs.mkdirSync(path.dirname(full), {recursive: true});
    fs.writeFileSync(full, content, {encoding: 'utf8', flag: 'wx'});
  }
  for (const [file, content] of updates) {
    fs.writeFileSync(checked(file), content, 'utf8');
  }
  // Individual file removal only, after destination copies are written.
  for (const from of move.keys()) fs.unlinkSync(checked(from));
  console.log('Source/import layout applied; no Git/build/test executed.');
} else {
  console.log('Plan only; review before --apply.');
}
