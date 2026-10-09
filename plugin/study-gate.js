// study 前置门 —— 在调用 MCP 之前检查「有没有先学过」。
//
// 为什么存在：实测事故 —— 用户清空 study/ 后让 agent 用 ComfyUI + Qwen 2.1，
// 它加载了手册、也知道该往 study/ 放，却跳过了「去抓」这一步，直接凭记忆写了一份
// summary.md。**它自己觉得完成了** —— 没有报错、没有失败，没有任何东西拦住它。
//
// 所以这里做一个**机械的**前置门：MCP 是网页操作 / 电脑控制 / 软件控制的必经之路，
// 拦 mcp__* 就等于拦住了所有外部操作。
//
// 挂载点：DSH 的 `tools/pre-execute` 事件（waterfall，dispatch 之前，可 allow/deny/cancel/ask）。
//
// 🔴 三条设计纪律：
//   ① **fail-safe**：任何异常都必须放行，绝不能因为本插件而阻断用户的工具调用。
//      加载失败也只是这一个插件失效，不影响 preset 其余部分。
//   ② **不锁死**：deny 的信息里必须给出**可执行的出路**，并且留一个显式豁免文件，
//      让"本次确实不需要"成为一个**有意识的选择**，而不是卡住。
//   ③ **学习通道不受影响**：web_fetch / web_search 是 DSH 内置工具，**不是 mcp__***，
//      所以永远不被本门拦截 —— agent 能去查、能落盘、能再回来。

import fs from 'node:fs'
import path from 'node:path'

export const name = 'study-gate'

// 事件签名是 'tools/pre-execute'(this: Scoped<ToolRuntime>, ...)
export const inject = ['tools']

export const DEFAULTS = {
  enabled: true,
  // MCP server 名（mcp__<server>__<tool> 的中间段）→ study 主题名。
  // 这里只列"名字和主题对不上"的；名字就是主题的（如 blender）不用列。
  servers: {
    comfymcp: 'comfyui',
    wincu: 'windows-computer-use',
  },
  // 🔴 没在 servers 里、也不在 allowServers 里的 MCP server 怎么办？
  //    'gate'  = 也拦（默认）—— 主题名就用 server 名，如 mcp__blender__* → study/blender/
  //    'allow' = 放行
  //
  //    为什么默认 'gate'：本模式的立场是「用任何外部软件之前先学」。
  //    原来只认硬编码白名单，结果是**新装的 MCP 默认不受管** —— 与立场矛盾。
  //    用户实测就撞上了：装了 blender MCP，但它不在名单里，门禁形同虚设。
  unknownServer: 'gate',
  // 明确豁免的 server（放行、不要求 study）。
  // 用于那些「本身就是去取信息的」MCP —— 拦它们等于让 agent 没法学习。
  allowServers: [],
  // 工作根候选（含 00_assets / 01_projects / 02_env 的那层）。空 = 从 cwd 向上探测。
  workRoots: [],
  // 🔴 原档有了，还要求有总结吗？（默认 true）
  //
  //    用户描述的流程是「有原档 → **先看有没有总结** → 按总结的方法运行」。
  //    没有总结就没法"按总结运行" —— 只能重读原档，那正是要避免的开销。
  //    所以缺总结也拦一次，让它先写出来（成本很低，收益是以后每次都快）。
  //    改成 false 则只要求原档。
  requireSummary: true,
  // 🔴 默认 false = **每次都查**。
  //
  //    早先默认 true（放行后记住），但那有两个缺陷：
  //      ① `passed` 是**插件实例级**的 Set，活到 DSH 进程结束 —— 不是会话级。
  //         于是「有一次通过 → 整个进程内都不再检查」，清空 study/ 也不会重新拦。
  //      ② exec.agent?.id 是**可选**的，缺失时 key 退化成 '?|<server>'，
  //         所有会话共用一个 key —— 一个会话通过 = 全部放行。
  //    两个缺陷都朝「少检查」偏，会削弱门禁本身。改成每次查。
  //
  //    代价：每次 MCP 调用多约 1ms 的文件检查（相对 MCP 的网络往返可忽略）。
  //    想省这点开销再开 true —— 但要知道它会变"钝"。
  oncePerSession: false,
  // 豁免文件（相对 02_env/study/）。存在即放行，用于"本次确实不需要"。
  exemptPrefix: '.gate-exempt-',
}

// ── 工具函数（全部防御式）────────────────────────────────────────────────

function safe(fn, fallback) {
  try { return fn() } catch { return fallback }
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

function resolveWorkRoots(cfg) {
  const out = []
  for (const r of cfg.workRoots || []) {
    // 🔴 只接受**真实存在**的工作根 —— 配置了一个不存在的路径时，
    //    我们无法检查任何东西，此时必须放行（宁可漏拦，不可误伤）。
    if (r && safe(() => fs.existsSync(r), false)) out.push(r)
  }
  if (!out.length) {
    const d = safe(() => findWorkRootFrom(process.cwd()), null)
    if (d) out.push(d)
  }
  return out
}

/** study/<主题>/ 是合规的**原档**吗？（source.md 有 URL 或声明无官方 + refs/ 非空） */
function archiveIsCompliant(studyEntry) {
  const src = path.join(studyEntry, 'source.md')
  const refs = path.join(studyEntry, 'refs')

  if (!fs.existsSync(src)) return false

  const st = safe(() => fs.readFileSync(src, 'utf8'), '')
  const hasUrl = /https?:\/\/[^\s)\]<>"]+/.test(st)
  const saysNoOfficial = /无官方文档|无官方/.test(st)
  if (!hasUrl && !saysNoOfficial) return false

  if (!fs.existsSync(refs)) return false
  const n = safe(
    () => fs.readdirSync(refs, { recursive: true }).filter((f) => {
      const full = path.join(refs, String(f))
      return safe(() => fs.statSync(full).isFile(), false)
    }).length,
    0,
  )
  return n > 0
}

/** notes/<主题>/summary.md 存在吗？（我们的总结 —— 与档案分开存） */
function summaryExists(root, topic) {
  return safe(() => fs.existsSync(path.join(root, '02_env', 'notes', topic, 'summary.md')), false)
}

function buildDenyReason(kind, server, topic, roots) {
  const studyWhere = roots.length
    ? roots.map((r) => path.join(r, '02_env', 'study', topic)).join('\n    或 ')
    : '<工作根>/02_env/study/' + topic
  const notesWhere = roots.length
    ? roots.map((r) => path.join(r, '02_env', 'notes', topic)).join('\n    或 ')
    : '<工作根>/02_env/notes/' + topic

  if (kind === 'no-summary') {
    // 原档有了，但还没写总结 —— 没有总结就无法"按总结运行"
    return [
      `🔴 study 前置门：「${topic}」的原档已有，但**还没写总结**，所以无法"按总结运行"。`,
      '',
      `  去读原档，写出总结：${notesWhere}\\summary.md`,
      `    原档在：${studyWhere}`,
      '    总结要点（🔴 不设长度下限，**上限 2000 tokens**，每条带指向 refs/ 的指针）：',
      '      · 官方怎么说（参数 / 步骤 / 限制）',
      '      · 与本机的关系（版本、显存、量化差异 —— 官方示例不一定适用）',
      '      · 还没搞清的（写清楚，别猜）',
      '',
      '  然后重试。总结是给"下次直接用"的 —— 没有它，每次都要重读原档。',
      '  （本次确实不需要，比如只查状态 → 在 02_env/study/' + DEFAULTS.exemptPrefix + server + ' 写一行理由）',
    ].join('\n')
  }

  // kind === 'no-archive'：连原档都没有
  return [
    `🔴 study 前置门：你还没学过「${topic}」，但正在调用 mcp__${server}__*。`,
    '',
    '动手之前先走 study 流程（这是前置步骤，不是事后记录）：',
    `  ① web_fetch 官方文档 → 原档落盘到 ${studyWhere}`,
    '     🔴 study/ 只存原档，必须两样：source.md（真实 URL + 抓取时间）+ refs/（抓下来的原文）',
    '     🔴 自问：refs/ 里是我从网上抓的，还是我自己脑子里写的？自己写的 → 停下，去抓。',
    `  ② 再写总结 → ${notesWhere}\\summary.md（我们的总结与经验放 notes/，不要混进 study/）`,
    '  ③ 官方不可达 → 停下问用户三选一（跳过 / 你提供文档 / 改善网络后重试）',
    `  ④ 本次确实不需要（非承重，比如只查个状态）→ 在 02_env/study/${DEFAULTS.exemptPrefix}${server} 里写一行理由，然后重试`,
    '',
    '自检：skills/study/scripts/check-study.ps1',
    '（web_fetch / web_search 不受本门限制，可以直接用。）',
  ].join('\n')
}

// ── 主逻辑（导出以便离线测试）────────────────────────────────────────────

export function evaluate(exec, cfg, passed) {
  const toolName = String(exec?.name || '')
  if (!toolName.startsWith('mcp__')) return null

  const parts = toolName.split('__')
  if (parts.length < 3) return null
  const server = parts[1]

  // 明确豁免的 server → 放行
  if (Array.isArray(cfg.allowServers) && cfg.allowServers.includes(server)) return null

  // 主题名：优先查映射表；没映射就按 unknownServer 决定（默认也拦，主题名 = server 名）
  const mapped = cfg.servers?.[server]
  const topic = mapped || (cfg.unknownServer === 'gate' ? server : null)
  if (!topic) return null

  const key = `${exec?.agent?.id ?? '?'}|${server}`
  if (cfg.oncePerSession && passed.has(key)) return null

  const roots = resolveWorkRoots(cfg)
  if (!roots.length) return null // 找不到工作根 → 不拦（fail-safe）

  // 遍历工作根：原档 + 总结都对上才算过。
  // 记住"最轻的缺口" —— 原档有了只差总结，比两者都缺更接近完成，报那个更有用。
  let sawArchive = false
  for (const root of roots) {
    const studyDir = path.join(root, '02_env', 'study')
    if (fs.existsSync(path.join(studyDir, `${cfg.exemptPrefix}${server}`))) {
      passed.add(key)
      return null
    }
    if (!archiveIsCompliant(path.join(studyDir, topic))) continue
    sawArchive = true
    if (cfg.requireSummary && !summaryExists(root, topic)) continue
    passed.add(key)
    return null
  }

  return {
    kind: 'deny',
    reason: buildDenyReason(sawArchive ? 'no-summary' : 'no-archive', server, topic, roots),
  }
}

// ── 挂载 ─────────────────────────────────────────────────────────────────

export function apply(ctx, config) {
  // 🔴 整段包在 try 里：本插件坏掉也绝不能影响 preset 其余部分
  try {
    const cfg = { ...DEFAULTS, ...(config || {}) }
    if (!cfg.enabled) return

    const passed = new Set()

    ctx.on('tools/pre-execute', async (exec, next) => {
      try {
        const decision = evaluate(exec, cfg, passed)
        if (decision) return decision
      } catch {
        // 任何异常 → 放行。宁可漏拦，不可误伤。
      }
      return next()
    })
  } catch {
    // 挂载失败 → 静默失效，不影响其它插件
  }
}
