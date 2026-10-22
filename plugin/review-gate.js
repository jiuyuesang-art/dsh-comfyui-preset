// review-gate —— 产物视觉审查的**机械门**（两道）。
//
// 为什么存在：skills/comfyui-review/SKILL.md 写得很硬（四条红线：不许自我批准、
// 结论必须指向画面证据、必须真看图、视频必须声明抽样），但它们全是**文字约束** ——
// 没有任何东西能证明"看过了"，也没有任何东西拦得住"没看就交"。
//
// 本 preset 对这个坑已有过一次答案：study-gate（"规则靠自觉是不够的"）。
// review-gate 是同一个范式的第二例，只是拦的位置不同：
//
//   A) tools/post-execute  —— **把观测变成动作的副作用**。
//      对应 blender 那位 up 主的 do{see:true}：生成完不是"记得去审"，而是
//      事实（路径 + 源文件 sha256 + 新旧）**自动出现在眼前**。
//      同时天然防"没生效"：同一个路径内容变了 = 重出过，旧审查不再算数。
//
//   B) tools/pre-execute   —— **拦 present**。
//      对应他的 doctor 必须 kind=ok / destructive_guard：
//      交付的媒体产物必须有一份**绑定了源文件 sha256** 的审查报告，否则拒绝。
//      🔴 绑定哈希 = 重出即过期。只写"必须审"是拦不住"审完 v001 交 v002"的。
//
// 🔴 四条设计纪律（与 study-gate 一致）：
//   ① **fail-safe**：任何异常一律放行 —— 宁可漏拦，不可误伤。
//   ② **不锁死**：deny 信息必须给出可执行的出路 + 显式豁免文件。
//   ③ **只管该管的**：只拦"媒体产物 + 在项目目录内（00_assets / 01_projects）"。
//      工作区外的图、临时文件、文档一律放行。
//   ④ **哈希必须算源文件**：不要用 read_image 报的哈希 —— 那是 DSH 归一化后的
//      JPEG 副本的哈希（实测：源 1.7MB/A91E8BD5… vs 副本 128KB/32BC744F…）。

import crypto from 'node:crypto'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

export const name = 'review-gate'

// 事件签名是 'tools/pre-execute' / 'tools/post-execute'(this: Scoped<ToolRuntime>, ...)
export const inject = ['tools']

// bundle 根 = 本文件所在目录的上一级（<bundle>/plugin/review-gate.js）
const BUNDLE_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const REVIEW_PY = path.join(BUNDLE_ROOT, 'skills', 'comfyui-review', 'scripts', 'review.py')
const RUN_PY = path.join(BUNDLE_ROOT, 'tools', 'run-python.ps1')

export const DEFAULTS = {
  enabled: true,
  // 只认这些 MCP server 的产物（mcp__<server>__*）。名字对不上就别列。
  servers: ['comfymcp'],
  mediaExt: [
    '.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp', '.tif', '.tiff',
    '.mp4', '.mov', '.webm', '.mkv', '.avi', '.wav', '.mp3', '.flac', '.m4a',
  ],
  // 交付门只管工作根下这两个目录里的媒体产物（其余一律放行）
  gatedRoots: ['00_assets', '01_projects'],
  // 审查报告目录名（报告的落点，见 comfyui-review §7）
  reviewDirNames: ['60_review', 'review'],
  // 注入阶段算哈希的大小上限（超过只报大小/时间，交付门仍会算）
  maxHashBytes: 512 * 1024 * 1024,
  injectMaxFiles: 6,
  injectMaxChars: 2800,
  // 豁免：<产物同目录或上层>/.review-exempt（写一行理由）· <工作根>/02_env/.review-gate-exempt（整门）
  exemptPrefix: '.review-exempt',
  globalExempt: '.review-gate-exempt',
  // 扫报告的上限，防止在大目录里扫爆
  maxReportFiles: 40,
  maxReportBytes: 262144,
  // 工作根候选（含 00_assets / 01_projects / 02_env 的那层）。
  //
  // 空 = **跟随当前会话的项目目录**：先取 Session 的 workingDirectory（DSH 记录的真实
  // 项目路径），再向上探测 00_assets / 01_projects / 02_env。这是默认行为 ——
  // 不需要为每个工作区手写绝对路径。
  //
  // 显式写绝对路径 = 只认这些路径。写相对路径 = 相对**当前项目目录**解析。
  workRoots: [],
}

// ── 工具函数（全部防御式）────────────────────────────────────────────────

function safe(fn, fallback) {
  try { return fn() } catch { return fallback }
}

function isUnder(child, parent) {
  const rel = safe(() => path.relative(parent, child), null)
  if (!rel) return false
  return !!rel && !rel.startsWith('..') && !path.isAbsolute(rel)
}

/** 归一化路径：折叠重复分隔符（JSON 文本里的 `C:\\a\\b` 与解析后的 `C:\a\b` 是同一个文件） */
function canon(p) {
  return safe(() => path.normalize(String(p)), String(p))
}

function isFile(p) {
  return safe(() => fs.statSync(p).isFile(), false)
}

function isDir(p) {
  return safe(() => fs.statSync(p).isDirectory(), false)
}

function findWorkRootFrom(start) {
  let d = start
  for (let i = 0; i < 8; i++) {
    for (const m of ['00_assets', '01_projects', '02_env']) {
      if (fs.existsSync(path.join(d, m))) return d
    }
    const p = path.dirname(d)
    if (!p || p === d) break
    d = p
  }
  return null
}

/**
 * 当前会话的项目目录。
 *
 * 优先级：Session 的 workingDirectory（DSH 为每个会话记录的真实项目路径）
 *        → 进程 cwd → 空。
 *
 * 为什么不能只用 process.cwd()：gate 跑在宿主进程里，那个 cwd 是**宿主自己的**
 * 启动目录，不是用户当前打开的项目。
 */
function sessionDir(ctx, exec) {
  const dir = safe(() => {
    const svc = ctx.get('workingDirectory')
    if (!svc) return null
    const session = exec?.agent?.session
    if (!session) return null
    const d = svc.get(session)
    return typeof d === 'string' && d ? d : null
  }, null)
  if (dir) return dir

  return safe(() => process.cwd(), '') || ''
}

/**
 * 把一条配置解析成绝对工作根（相对路径相对**当前项目目录**）。
 * @returns 绝对路径，无法解析时 null
 */
function toAbsolute(entry, base) {
  const r = String(entry ?? '').trim()
  if (!r) return null
  if (path.isAbsolute(r)) return r
  if (!base) return null
  return safe(() => path.resolve(base, r), null)
}

/**
 * 解析工作根列表。
 *
 * - 配置为空 → **跟随当前项目**：项目里已有 00_assets/01_projects/02_env 就用
 *   那个根；一个都没有就用项目目录本身。
 * - 配置相对路径 → 相对当前项目目录解析。
 * - 配置绝对路径 → 原样。
 *
 * 显式配置时只返回真实存在的工作根 —— 配了不存在的路径时无法检查任何东西，必须放行。
 */
function resolveWorkRoots(cfg, base) {
  const entries = Array.isArray(cfg.workRoots) ? cfg.workRoots.filter(Boolean) : []

  if (!entries.length) {
    const found = safe(() => findWorkRootFrom(base || process.cwd()), null)
    const root = found || base
    return root ? [root] : []
  }

  const out = []
  for (const entry of entries) {
    const abs = toAbsolute(entry, base)
    if (abs && safe(() => fs.existsSync(abs), false) && !out.includes(abs)) out.push(abs)
  }
  return out
}

function isMedia(p, cfg) {
  return cfg.mediaExt.includes(path.extname(String(p)).toLowerCase())
}

function isUnderGatedRoots(abs, cfg, roots) {
  for (const root of roots) {
    for (const sub of cfg.gatedRoots) {
      if (isUnder(abs, path.join(root, sub))) return true
    }
  }
  return false
}

export function sha256File(p) {
  return new Promise((resolve, reject) => {
    const h = crypto.createHash('sha256')
    const s = fs.createReadStream(p)
    s.on('error', reject)
    s.on('data', (d) => h.update(d))
    s.on('end', () => resolve(h.digest('hex')))
  })
}

function mtimeText(st) {
  return safe(() => new Date(st.mtimeMs).toLocaleString('sv-SE'), '')
}

// ── 从工具结果里捞产物路径 ────────────────────────────────────────────────

const PATH_RE = /[A-Za-z]:[\\/][^\s"'<>|*?\r\n]+|\/(?:[\w.\-@]+(?:\/[\w.\-@]+)+)/g

function walkStrings(node, out, depth = 0) {
  if (depth > 8 || node == null) return
  if (typeof node === 'string') { out.push(node); return }
  if (Array.isArray(node)) { for (const x of node) walkStrings(x, out, depth + 1); return }
  if (typeof node === 'object') { for (const v of Object.values(node)) walkStrings(v, out, depth + 1) }
}

function normalizeCandidate(s, cfg) {
  let t = String(s == null ? '' : s).trim()
  t = t.replace(/^["'`(\[]+/, '').replace(/["'`)\],;]+$/, '')
  if (t.startsWith('file:///')) t = t.slice(8)
  else if (t.startsWith('file://')) t = t.slice(7)
  if (!t || t.length > 1024) return null
  if (!isMedia(t, cfg)) return null
  const abs = path.isAbsolute(t) ? t : safe(() => path.resolve(process.cwd(), t), null)
  return abs ? canon(abs) : null
}

/** 从 post-execute 的 result 里收集"真实存在"的媒体产物（去重、保序） */
export function extractArtifactPaths(result, cfg) {
  const content = result && result.content
  if (!Array.isArray(content)) return []
  const raw = []
  for (const c of content) {
    if (!c || typeof c !== 'object') continue
    if (c.type === 'text' && typeof c.text === 'string') {
      let parsed = null
      try { parsed = JSON.parse(c.text) } catch { /* 非 JSON，按纯文本扫 */ }
      if (parsed) walkStrings(parsed, raw)
      const m = c.text.match(PATH_RE)
      if (m) raw.push(...m)
    }
  }
  const out = []
  const seen = new Set()
  for (const s of raw) {
    const abs = normalizeCandidate(s, cfg)
    if (!abs || seen.has(abs.toLowerCase())) continue
    if (!isFile(abs)) continue
    seen.add(abs.toLowerCase())
    out.push(abs)
  }
  return out
}

// ── 审查证据：报告里有没有**当前**这串哈希 ───────────────────────────────

function exempted(abs, cfg, base) {
  let d = path.dirname(abs)
  for (let i = 0; i < 6; i++) {
    if (fs.existsSync(path.join(d, cfg.exemptPrefix))) return true
    const up = path.dirname(d)
    if (!up || up === d) break
    d = up
  }
  for (const r of resolveWorkRoots(cfg, base)) {
    if (fs.existsSync(path.join(r, '02_env', cfg.globalExempt))) return true
  }
  return false
}

/**
 * 找一份"认账"的审查报告：产物目录及其上层（≤6 级）的 60_review / review 目录下，
 * 任一 .md 里出现该产物的 **源文件 sha256**（完整 64 位或前 12 位）。
 */
export function reviewEvidenceFor(abs, hash, cfg, base) {
  const short = String(hash).slice(0, 12).toLowerCase()
  const full = String(hash).toLowerCase()
  const roots = resolveWorkRoots(cfg, base)
  const dirs = []
  let d = path.dirname(abs)
  for (let i = 0; i < 6; i++) {
    for (const rn of cfg.reviewDirNames) dirs.push(path.join(d, rn))
    if (roots.some((r) => d.toLowerCase() === String(r).toLowerCase())) break
    const up = path.dirname(d)
    if (!up || up === d) break
    d = up
  }
  for (const dir of dirs) {
    if (!isDir(dir)) continue
    const files = safe(() => fs.readdirSync(dir).filter((f) => f.toLowerCase().endsWith('.md')), [])
    for (const f of files.slice(0, cfg.maxReportFiles)) {
      const p = path.join(dir, f)
      const txt = safe(() => {
        const st = fs.statSync(p)
        if (st.size > cfg.maxReportBytes) return ''
        return fs.readFileSync(p, 'utf8')
      }, '')
      if (!txt) continue
      const low = txt.toLowerCase()
      if (low.includes(full) || low.includes(short)) return { ok: true, report: p }
    }
  }
  return { ok: false, why: dirs.some(isDir) ? 'stale' : 'no-report-dir' }
}

function normalizeArgs(args) {
  if (!args) return {}
  if (typeof args === 'string') return safe(() => JSON.parse(args), {})
  return typeof args === 'object' ? args : {}
}

// ── 门 A：交付门（pre-execute，拦 present）───────────────────────────────

function buildDeny(offenders, cfg) {
  const dir0 = path.dirname(offenders[0].abs)
  const lines = [
    '🔴 交付门：以下产物**没有绑定当前内容的审查记录**，`present` 被拦下。',
    '',
  ]
  for (const o of offenders) {
    lines.push(`  · ${o.abs}`)
    lines.push(`      ${(o.bytes / 1024).toFixed(0)} KB · sha256 ${o.hash.slice(0, 12)}… · `
      + (o.why === 'stale' ? '报告目录里有报告，但没有一份绑定这串哈希（= 已过期）' : '找不到审查报告目录'))
  }
  lines.push(
    '',
    '出路（三选一）：',
    '  ① 先审（推荐）：',
    `     & "${RUN_PY}" "${REVIEW_PY}" audit "<产物路径>" --baseline "<基准：上一版 / 输入参考图>"`,
    `     再按 skills/comfyui-review §7 写报告 → <产物同目录或镜头目录>/60_review/<名称>-review-v<NNN>.md`,
    '     🔴 报告里**必须出现该产物的源文件 sha256**（上面那一串）—— 门就是靠它认账的。',
    '     🔴 别用 read_image 报的哈希：那是归一化 JPEG 副本的哈希，不是源文件的。',
    `  ② 本次确实不需要审（中间过程 / 排版示意）→ 在 ${dir0}\\${cfg.exemptPrefix} 写一行理由，重试`,
    `  ③ 整门临时关掉 → cordis.patch.yml 里 review-gate 的 enabled 改 false，`
    + '或写 <工作根>/02_env/' + cfg.globalExempt,
  )
  return lines.join('\n')
}

/** 返回 {kind:'deny', reason} 或 null（放行）。导出以便离线干跑。 */
export async function evaluatePresent(exec, cfg, base) {
  if (String(exec?.name || '') !== 'present') return null
  const args = normalizeArgs(exec?.args)
  const files = Array.isArray(args.files) ? args.files : []
  if (!files.length) return null

  const roots = resolveWorkRoots(cfg, base)
  if (!roots.length) return null // 找不到工作根 → 放行（fail-safe）

  const offenders = []
  for (const f of files) {
    const raw0 = typeof f === 'string' ? f : (f && f.path)
    if (!raw0 || typeof raw0 !== 'string') continue
    // 相对路径相对**当前项目目录**（present 的路径本来就是相对会话 cwd 的）
    const abs0 = path.isAbsolute(raw0)
      ? raw0
      : safe(() => path.resolve(base || process.cwd(), raw0), null)
    if (!abs0) continue
    const abs = canon(abs0)
    if (!isFile(abs)) continue
    if (!isMedia(abs, cfg)) continue
    if (!isUnderGatedRoots(abs, cfg, roots)) continue
    if (exempted(abs, cfg, base)) continue

    const st = safe(() => fs.statSync(abs), null)
    if (!st) continue
    const hash = await sha256File(abs)
    const ev = reviewEvidenceFor(abs, hash, cfg, base)
    if (!ev.ok) offenders.push({ abs, hash, bytes: st.size, why: ev.why })
  }
  if (!offenders.length) return null
  return { kind: 'deny', reason: buildDeny(offenders, cfg) }
}

// ── 门 B：事实注入（post-execute，把观测变成动作的副作用）────────────────

/** 返回要追加的文本块，或 null。导出以便离线干跑。 */
export async function evaluatePost(exec, result, cfg, seen) {
  const toolName = String(exec?.name || '')
  if (!toolName.startsWith('mcp__')) return null
  const server = toolName.split('__')[1]
  if (!Array.isArray(cfg.servers) || !cfg.servers.includes(server)) return null

  const paths = extractArtifactPaths(result, cfg)
  if (!paths.length) return null

  const fresh = []
  for (const abs of paths.slice(0, cfg.injectMaxFiles)) {
    const st = safe(() => fs.statSync(abs), null)
    if (!st) continue
    const key = abs.toLowerCase()
    let hash = ''
    if (st.size <= cfg.maxHashBytes) {
      try { hash = await sha256File(abs) } catch { hash = '' } // 算不动就当没算过（放行优先）
    }
    if (hash && seen.get(key) === hash) continue // 同一个东西、没变 → 不再灌（省 token）
    if (hash) seen.set(key, hash)
    const prev = seen.get(key + '#prev')
    fresh.push({ abs, bytes: st.size, hash, mtime: mtimeText(st), tag: prev ? '内容已变化（重出过）' : '本轮新增' })
    if (hash) seen.set(key + '#prev', true)
  }
  if (!fresh.length) return null

  const lines = [
    '🔴 产物已产生 —— **先审再交**（review-gate 自动注入的 L0 事实）',
  ]
  fresh.forEach((f, i) => {
    lines.push(`  ${i + 1}) ${f.abs}`)
    lines.push(`     ${(f.bytes / 1024).toFixed(0)} KB · `
      + (f.hash ? `sha256 ${f.hash.slice(0, 12)}…` : '文件较大，注入阶段未算哈希（交付门仍会算）')
      + ` · ${f.mtime} · ${f.tag}`)
  })
  lines.push(
    '下一步：',
    `  ① L0 事实（零点几秒，零模型轮次）：`,
    `     & "${RUN_PY}" "${REVIEW_PY}" audit "<产物路径>" --baseline "<基准：上一版 / 输入参考图>"`,
    '  ② L1 视觉：把 **产物 + 基准 + 上面的数字** 派给**有图像输入**的子智能体',
    '     （任务包模板见 skills/comfyui-review/SKILL.md §1.5；主模型若无图像输入，不要自己"看"）',
    '  ③ 报告落盘 60_review/<名称>-review-v<NNN>.md，**必须含上面那串源文件 sha256**',
    '  ④ present 交付时会被门检查：报告哈希 ≠ 源文件哈希 = 视为没审（重出即过期）',
  )
  return lines.join('\n').slice(0, cfg.injectMaxChars)
}

// ── 挂载 ─────────────────────────────────────────────────────────────────

export function apply(ctx, config) {
  // 🔴 整段包在 try 里：本插件坏掉也绝不能影响 preset 其余部分
  try {
    const cfg = { ...DEFAULTS, ...(config || {}) }
    if (!cfg.enabled) return

    const seen = new Map()

    ctx.on('tools/pre-execute', async (exec, next) => {
      try {
        const decision = await evaluatePresent(exec, cfg, sessionDir(ctx, exec))
        if (decision) return decision
      } catch {
        // 任何异常 → 放行。宁可漏拦，不可误伤。
      }
      return next()
    })

    ctx.on('tools/post-execute', async (exec, result, next) => {
      const decision = await next() // 🔴 next 只能调一次
      try {
        const block = await evaluatePost(exec, result, cfg, seen)
        if (block && decision?.kind === 'accept') {
          const base = decision.content ?? (decision.value === undefined ? result?.content : undefined)
          if (Array.isArray(base)) {
            return { ...decision, content: [...base, { type: 'text', text: block }] }
          }
        }
      } catch {
        // 注入失败 → 原样返回，绝不因为加料而破坏工具结果
      }
      return decision
    })
  } catch {
    // 挂载失败 → 静默失效，不影响其它插件
  }
}
