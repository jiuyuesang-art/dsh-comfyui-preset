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
  // 🔴 放行后，把总结的**关键点**直接注入上下文（默认 true）。
  //
  //    用户的目的：「让模型更积极地学习」。拦只是第一步 ——
  //    拦完还得让它真的看到该看的东西，否则它只会补完文件、然后照旧凭感觉干。
  //    与其让它自己去翻，不如**直接给它**（这是效率上的划算买卖）。
  //
  //    只注入一次/会话/server，不会每次调用都灌。
  injectSummary: true,
  // 注入内容的上限（字符）。摘要本身已限 2000 tokens，这里再兜一层。
  summaryMaxChars: 2500,
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

/** notes/<主题>/summary.md 的路径；不存在返回 null */
function summaryPath(root, topic) {
  const p = path.join(root, '02_env', 'notes', topic, 'summary.md')
  return safe(() => (fs.existsSync(p) ? p : null), null)
}

/**
 * 从 summary.md 里取「关键结论」段（没有该小节就取开头），并限长。
 * 目的：把最该看的那部分直接塞进上下文，省掉模型自己去翻的开销。
 */
export function extractKeyPoints(md, maxChars) {
  let body = String(md || '')
  // 去掉一级标题（那只是文件名），保留内容
  const sec = body.match(/##\s*关键结论[^\n]*\n([\s\S]*?)(?=\n##\s|\s*$)/)
  if (sec) body = sec[1].trim()
  else body = body.replace(/^#.*\n/, '').trim()

  if (body.length <= maxChars) return body
  // 截断时尽量切在行边界，并明确标注被截断
  const cut = body.lastIndexOf('\n', maxChars)
  return body.slice(0, cut > maxChars * 0.6 ? cut : maxChars).trimEnd() + '\n\n…（关键点已截断，完整见 summary.md）'
}

/** 生成要注入的 text block；不需要注入时返回 null */
function buildInjection(exec, cfg, root, topic) {
  const sp = summaryPath(root, topic)
  if (!sp) return null
  const md = safe(() => fs.readFileSync(sp, 'utf8'), '')
  if (!md.trim()) return null
  const key = extractKeyPoints(md, cfg.summaryMaxChars)

  const rel = path.join('02_env', 'notes', topic, 'summary.md')
  const refs = path.join('02_env', 'study', topic, 'refs')
  const text = [
    `📚 **${topic} 的要点已给你**（不用再去翻总结）：`,
    '',
    '────────────────────────────────',
    key,
    '────────────────────────────────',
    '',
    `· 完整总结：\`${rel}\`　· 官方原档：\`${refs}\``,
    '· 🔵 如果按这些要点跑**不通** → 去翻上面的 `refs/` **完整文档**找原因（原档一字未删就是为了这个），',
    '  再不行 → **问社区**（见 study 手册 §3.5）。',
  ].join('\n')

  return { type: 'text', text }
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
    const injected = new Set()

    ctx.on('tools/pre-execute', async (exec, next) => {
      try {
        const decision = evaluate(exec, cfg, passed)
        if (decision) return decision
      } catch {
        // 任何异常 → 放行。宁可漏拦，不可误伤。
      }
      return next()
    })

    // ── 注入：把总结的关键点直接塞进上下文 ──────────────────────────────
    //
    // 用户的目的：「让模型更积极地学习」。拦只是第一步 ——
    // 拦完还得让它真的**看到**该看的东西，否则它只会去补文件、然后照旧凭感觉干。
    //
    // 通道：PostToolDecision.content（ContentBlock[]）。实测形状就是 { type:'text', text }
    //      —— 不依赖任何模块（@deepseek-ai/dsh-llm 在 profile 里不可解析，用不了它的 createUserMessage）。
    //
    // 「有条件」：每个 (会话, server) **只注入一次**，之后不再重复塞（否则每次调用都灌一遍会撑爆上下文）。
    ctx.on('tools/post-execute', async (exec, result, next) => {
      const decision = await next()   // 🔴 next 只能调一次，先拿到原始决策，再决定要不要加料
      try {
        if (!cfg.injectSummary) return decision
        const toolName = String(exec?.name || '')
        if (!toolName.startsWith('mcp__')) return decision
        const parts = toolName.split('__')
        if (parts.length < 3) return decision
        const server = parts[1]
        if (Array.isArray(cfg.allowServers) && cfg.allowServers.includes(server)) return decision
        const topic = cfg.servers?.[server] || (cfg.unknownServer === 'gate' ? server : null)
        if (!topic) return decision

        const ikey = `${exec?.agent?.id ?? '?'}|${server}`
        if (injected.has(ikey)) return decision
        injected.add(ikey)

        // 门禁刚放行说明文件齐；再确认一次，并在多个工作根里选命中的那个
        let block = null
        for (const root of resolveWorkRoots(cfg)) {
          const b = buildInjection(exec, cfg, root, topic)
          if (b) { block = b; break }
        }
        if (!block) return decision

        if (decision?.kind === 'accept') {
          const base = decision.content ?? (decision.value === undefined ? result?.content : undefined)
          if (Array.isArray(base)) return { ...decision, content: [...base, block] }
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
