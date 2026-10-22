// review-gate 离线干跑测试 —— 不需要 Blender / ComfyUI / DSH，直接跑：
//
//   node tools/review-gate-selftest.mjs
//
// 覆盖：产物提取 · 交付门（无报告 / 报告过期 / 报告认账 / 豁免 / 越界不管）·
//       事实注入（新增 / 去重 / 重出 · 只认目标 MCP）· 畸形输入不抛异常（fail-safe）。
//
// 为什么要有它：门是**会拒绝用户操作**的东西，必须证明它"该拦的拦、不该拦的放"。
// study-gate 当年也是这么验的。

import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'

import {
  DEFAULTS, apply, evaluatePost, evaluatePresent, extractArtifactPaths, sha256File,
} from '../plugin/review-gate.js'

let pass = 0
let fail = 0

function ok(cond, label) {
  if (cond) { pass++; console.log(`  ✓ ${label}`) } else { fail++; console.log(`  ✗ ${label}`) }
}

async function throws(fn, label) {
  try { await fn(); ok(true, label) } catch (e) { ok(false, `${label} —— 抛了 ${e && e.message}`) }
}

const PNG = Buffer.concat([Buffer.from('89504e470d0a1a0a', 'hex'), Buffer.alloc(400, 7)])

const TMP = fs.mkdtempSync(path.join(os.tmpdir(), 'review-gate-selftest-'))
const ROOT = path.join(TMP, 'workroot')
const PROJECTS = path.join(ROOT, '01_projects')
const SHOT = path.join(PROJECTS, 'demo', '20_shots', 'ep01', 'sq010', 'sh0010')
const ART = path.join(SHOT, '30_key', 'k0010_v001.png')
const REPORT_DIR = path.join(SHOT, '60_review')

fs.mkdirSync(path.dirname(ART), { recursive: true })
fs.mkdirSync(path.join(ROOT, '00_assets'), { recursive: true })
fs.mkdirSync(path.join(ROOT, '02_env'), { recursive: true })
fs.writeFileSync(ART, PNG)

const cfg = { ...DEFAULTS, workRoots: [ROOT] }
const HASH = await sha256File(ART)

const present = (p) => ({ name: 'present', args: { files: [{ path: p, description: 'x' }] }, agent: { id: 't' } })
const comfyCall = (text) => ({ name: 'mcp__comfymcp__fetch_outputs', agent: { id: 't' } })

console.log(`fixture: ${TMP}`)
console.log(`产物 sha256 = ${HASH.slice(0, 12)}…\n`)

// ── 1. 产物提取 ──────────────────────────────────────────────────────────
console.log('1) 从工具结果里提取产物')
{
  const res = {
    content: [{
      type: 'text',
      text: JSON.stringify({ files: [ART, 'C:\\nope\\missing.png', 'notes.txt', 42] }),
    }],
  }
  const got = extractArtifactPaths(res, cfg)
  ok(got.length === 1 && got[0] === ART, '存在的媒体文件被提取，不存在的/非媒体被丢弃')

  const esc = { content: [{ type: 'text', text: JSON.stringify({ out: ART }) }] }
  const got2 = extractArtifactPaths(esc, cfg)
  ok(got2.length === 1 && got2[0] === ART,
    'JSON 里的转义路径与原文扫描到的是同一个文件（不被当成两个）')

  const raw = { content: [{ type: 'text', text: `输出在 ${ART} 里，另存 C:/also/nope.mp4` }] }
  ok(extractArtifactPaths(raw, cfg).length === 1, '非 JSON 文本里的裸路径也能扫到')

  ok(extractArtifactPaths({ content: [] }, cfg).length === 0, '空 content → 无产物')
  ok(extractArtifactPaths(null, cfg).length === 0, 'result 为 null → 无产物（不抛）')
}

// ── 2. 交付门：该拦的拦 ──────────────────────────────────────────────────
console.log('\n2) 交付门 —— 没有审查记录时必须拦')
{
  const d = await evaluatePresent(present(ART), cfg)
  ok(d && d.kind === 'deny', '没有 60_review 目录 → deny')
  ok(d && d.reason.includes('找不到审查报告目录'), '拒绝信息说清是"没报告目录"')
  ok(d && d.reason.includes(HASH.slice(0, 12)), '拒绝信息带上了源文件 sha256（告诉它要绑什么）')
  ok(d && d.reason.includes('review-exempt'), '拒绝信息给出豁免出路（不锁死）')
}

// ── 3. 交付门：报告过期（这是"重出即失效"的核心）─────────────────────────
console.log('\n3) 交付门 —— 报告绑的是别的哈希时必须拦')
{
  fs.mkdirSync(REPORT_DIR, { recursive: true })
  fs.writeFileSync(path.join(REPORT_DIR, 'k0010_v001-review-v001.md'),
    '# 旧报告\n- 产物 sha256 前 12 位：deadbeefcafe\n- 判定：PASS\n')
  const d = await evaluatePresent(present(ART), cfg)
  ok(d && d.kind === 'deny', '报告存在但哈希对不上 → deny（哈希过期即失效）')
  ok(d && d.reason.includes('已过期'), '拒绝信息说明是"已过期"而不是"没审过"')
}

// ── 4. 交付门：报告认账即放行 ────────────────────────────────────────────
console.log('\n4) 交付门 —— 报告绑定了当前哈希时放行')
{
  fs.writeFileSync(path.join(REPORT_DIR, 'k0010_v001-review-v002.md'),
    `# 审查报告\n- 产物：k0010_v001.png\n- sha256 前 12 位：${HASH.slice(0, 12)}\n- 判定：PASS\n`)
  ok((await evaluatePresent(present(ART), cfg)) === null, '12 位短哈希命中 → 放行')

  fs.writeFileSync(path.join(REPORT_DIR, 'k0010_v001-review-v003.md'),
    `# 审查报告\n- sha256：${HASH}\n- 判定：PASS_WITH_NOTES\n`)
  ok((await evaluatePresent(present(ART), cfg)) === null, '完整 64 位哈希命中 → 放行')
}

// ── 5. 交付门：两条豁免出路 ─────────────────────────────────────────────
console.log('\n5) 交付门 —— 豁免出路')
{
  fs.rmSync(REPORT_DIR, { recursive: true, force: true })
  ok((await evaluatePresent(present(ART), cfg)) !== null, '先确认删掉报告后又会拦')

  const ex1 = path.join(SHOT, '30_key', DEFAULTS.exemptPrefix)
  fs.writeFileSync(ex1, '本次只是排版示意，不需要视觉审查\n')
  ok((await evaluatePresent(present(ART), cfg)) === null, '产物同目录写豁免文件 → 放行')
  fs.rmSync(ex1, { force: true })

  const ex2 = path.join(ROOT, '02_env', DEFAULTS.globalExempt)
  fs.writeFileSync(ex2, '临时整门关闭\n')
  ok((await evaluatePresent(present(ART), cfg)) === null, '工作根 02_env 写全局豁免 → 放行')
  fs.rmSync(ex2, { force: true })
  ok((await evaluatePresent(present(ART), cfg)) !== null, '移除豁免后又恢复拦截')
}

// ── 6. 交付门：不该管的绝不能管 ─────────────────────────────────────────
console.log('\n6) 交付门 —— 越界/无关的一律放行（宁可漏拦，不可误伤）')
{
  const envPng = path.join(ROOT, '02_env', 'tmp.png')
  fs.writeFileSync(envPng, PNG)
  ok((await evaluatePresent(present(envPng), cfg)) === null, '02_env 里的图 → 不管')

  const doc = path.join(SHOT, 'notes.md')
  fs.writeFileSync(doc, 'not media\n')
  ok((await evaluatePresent(present(doc), cfg)) === null, '非媒体文件 → 不管')

  const outside = path.join(TMP, 'outside', 'free.png')
  fs.mkdirSync(path.dirname(outside), { recursive: true })
  fs.writeFileSync(outside, PNG)
  ok((await evaluatePresent(present(outside), cfg)) === null, '工作根之外 → 不管')

  ok((await evaluatePresent({ name: 'present', args: {} }, cfg)) === null, 'present 不带 files → 放行')
  ok((await evaluatePresent({ name: 'read_image', args: { path: ART } }, cfg)) === null, '别的工具 → 不管')
  ok((await evaluatePresent(present(ART), { ...cfg, workRoots: [path.join(TMP, 'nope')] })) === null,
    '工作根不存在 → 放行（配置错了不会锁死用户）')
}

// ── 7. 事实注入 ─────────────────────────────────────────────────────────
console.log('\n7) 事实注入（post-execute）')
{
  const seen = new Map()
  const res = { content: [{ type: 'text', text: JSON.stringify({ files: [ART] }) }] }

  const b1 = await evaluatePost(comfyCall(), res, cfg, seen)
  ok(typeof b1 === 'string' && b1.includes('先审再交'), '第一次调用 → 注入审查提示')
  ok(b1 && b1.includes(HASH.slice(0, 12)), '注入块带源文件 sha256')
  ok(b1 && b1.includes('本轮新增'), '标注"本轮新增"')
  ok(b1 && b1.includes('review.py'), '给出可直接照做的 L0 命令')
  ok(b1 && b1.includes('有图像输入'), '明确 L1 要派给有图像输入的模型')

  ok((await evaluatePost(comfyCall(), res, cfg, seen)) === null,
    '同一产物、内容未变 → 不再重复注入（省 token）')

  fs.writeFileSync(ART, Buffer.concat([PNG, Buffer.from([0, 1, 2, 3])]))
  const b3 = await evaluatePost(comfyCall(), res, cfg, seen)
  ok(typeof b3 === 'string' && b3.includes('内容已变化'), '内容变了（重出）→ 重新注入并标注')
  ok(b3 && !b3.includes(HASH.slice(0, 12)), '重出后给的是**新的**哈希')

  ok((await evaluatePost({ name: 'mcp__other__x' }, res, cfg, seen)) === null, '别的 MCP server → 不注入')
  ok((await evaluatePost({ name: 'read_image' }, res, cfg, seen)) === null, '非 MCP 工具 → 不注入')
  ok((await evaluatePost(comfyCall(), { content: [] }, cfg, seen)) === null, '结果里没有产物 → 不注入')
}

// ── 8. 畸形输入不得抛异常（fail-safe）───────────────────────────────────
console.log('\n8) 畸形输入（门不能因为输入奇怪就崩）')
{
  await throws(() => evaluatePresent(null, cfg), 'exec = null 不抛')
  await throws(() => evaluatePresent({ name: 'present', args: 'not json' }, cfg), 'args 是坏字符串不抛')
  await throws(() => evaluatePresent({ name: 'present', args: { files: 'x' } }, cfg), 'files 不是数组不抛')
  await throws(() => evaluatePresent(present(12345), cfg), 'path 不是字符串不抛')
  await throws(() => evaluatePost(null, null, cfg, new Map()), 'post: exec/result 为 null 不抛')
  await throws(() => evaluatePost({ name: 'mcp__comfymcp__x' },
    { content: [{ type: 'text', text: '{{{' }] }, cfg, new Map()), 'post: 坏 JSON 文本不抛')
  await throws(() => sha256File(path.join(TMP, 'nope.png')).catch(() => { }),
    '不存在的文件算哈希（调用方自己 catch）')
}

// ── 9. apply() 挂载：事件接线本身也要验（纯函数过了≠挂上了）───────────────
console.log('\n9) apply() 挂载与事件接线')
{
  const handlers = new Map()
  apply({ on: (ev, fn) => handlers.set(ev, fn) }, cfg)
  ok(handlers.has('tools/pre-execute') && handlers.has('tools/post-execute'),
    '两个事件都挂上了')

  let nextCalled = false
  const d = await handlers.get('tools/pre-execute')(
    present(ART), () => { nextCalled = true; return { kind: 'accept' } })
  ok(d && d.kind === 'deny' && !nextCalled, 'pre-execute：未审的产物在 next 之前就被拦下')

  const res = { content: [{ type: 'text', text: JSON.stringify({ files: [ART] }) }] }
  const out = await handlers.get('tools/post-execute')(
    { name: 'mcp__comfymcp__fetch_outputs' }, res,
    async () => ({ kind: 'accept', content: [...res.content] }))
  ok(out && Array.isArray(out.content) && out.content.length === 2
    && String(out.content[1].text).includes('先审再交'),
    'post-execute：事实注入块被追加进工具结果')

  const h2 = new Map()
  apply({ on: (ev, fn) => h2.set(ev, fn) }, { ...cfg, enabled: false })
  ok(h2.size === 0, 'enabled:false → 一个事件都不挂（整门可关）')

  await throws(() => { apply({}, cfg) }, 'ctx 不可用时静默失效、不抛')
}

fs.rmSync(TMP, { recursive: true, force: true })

console.log(`\n${'─'.repeat(56)}`)
console.log(`review-gate 离线干跑：${pass} 通过 / ${fail} 失败（共 ${pass + fail} 项）`)
process.exit(fail === 0 ? 0 : 1)
