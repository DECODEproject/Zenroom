import test from "ava";

import {zencode_exec, zenroom_exec,
  zenroom_hash_init, zenroom_hash_update, zenroom_hash_final
} from "./index";
import { TextEncoder } from 'util';
var enc = new TextEncoder();

test("does exists", (t) => {
  t.is(typeof zenroom_exec, "function");
  const p = zenroom_exec("print()").catch(() => {});
  t.true(p instanceof Promise);
});

test("does run hello world", async (t) => {
  const {result} = await zenroom_exec(`print('hello world!')`);
  t.is(result, "hello world!");
});

test("does parse data", async (t) => {
  const {result} = await zenroom_exec(`print(DATA)`, {data: "DATA INSIDE"});
  t.is(result, "DATA INSIDE");
});

test("does broke gracefully", async (t) => {
  try {
    await zenroom_exec(`broken sapokdao`);
  } catch (e) {
    t.true(
      e.logs.includes(
        `[!] [string "broken sapokdao"]:1: syntax error near 'sapokdao'`
      )
    );
  }
});

test("does handle empty zencode", async (t) => {
  try {
    await zencode_exec(null);
  } catch (e) {
    t.true(e.logs.includes("[!] NULL string as script argument"));
  }
  try {
    await zencode_exec(``);
  } catch (e) {
    t.true(e.logs.includes("[!] Empty string as script argument"));
  }
});

test("does handle empty lua", async (t) => {
  try {
    await zenroom_exec(null);
  } catch (e) {
    t.true(e.logs.includes("[!] NULL string as script argument"));
  }
  try {
    await zenroom_exec(``);
  } catch (e) {
    t.true(e.logs.includes("[!] Empty string as script argument"));
  }
});

test("does run zencode", async (t) => {
  const {result} = await zencode_exec(`scenario simple:
  given nothing
  Then print all data`);
  t.is(result, "[]");
});

test("error format contains newlines", async t => {
  try {
    await zencode_exec(`a`);
  } catch (e) {
    const lines = e.logs.split('\n');

    t.true(lines.includes('[W] Zencode text too short to parse'));
    t.true(lines.includes('[W] Zencode is missing version check, please add: rule check version N.N.N'));
    t.true(lines.includes('[!] Execution aborted'));
  }
})

test("handle broken zencode", async (t) => {
  try {
    await zencode_exec(`sapodksapodk`);
  } catch (e) {
    t.true(
      e.logs.includes(
        `Invalid Zencode line 1: 'sapodksapodk'`
      )
    );
  }
});

test("Executes a zencode correctly", async (t) => {
  const random_name = Math.random().toString(36).substring(7);
  const {
    result,
  } = await zencode_exec(`Scenario 'credential': credential keygen 
    Given that I am known as '${random_name}' 
    When I create the credential key
    and I create the issuer key
    Then print my 'keyring'`);
  t.is(typeof result, "string");
  const r = JSON.parse(result);
  t.is(typeof r[random_name], "object");
  t.is(typeof r[random_name]["keyring"]["credential"], "string");
  t.is(typeof r[random_name]["keyring"]["issuer"]["x"], "string");
  t.is(typeof r[random_name]["keyring"]["issuer"]["y"], "string");
});

test("Run hash api", async (t) => {
  let ctx = await zenroom_hash_init("sha512");
  t.is(ctx.result, '40000000000000000000000000000000008c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000');
  ctx = await zenroom_hash_update(ctx.result, enc.encode('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'));
  t.is(ctx.result, '4c001000000000000000000000000000008c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b6564636264636261676665646665646369686766686766656b6a69686a6968676d6c6b6a6c6b6a696f6e6d6c6e6d6c6b71706f6e706f6e6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000');
  ctx = await zenroom_hash_final(ctx.result);
  t.is(ctx.result, 'IEqPxt2oLwoM7XvrjgikFlfBbvRosiioJ5vjMacDwzWW/RXBOxsH+aodO+pXeJygMa2Fx6cd1wNU7GMSOMo0RQ==');
});
