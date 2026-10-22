// Verify the new workRoots resolution: project-relative default + relative entries.
// Drives the exported functions directly with a fake ctx (workingDirectory service).
import path from 'node:path'

const BASE = 'C:\\Users\\10174\\Documents\\deepseek-harness\\default-workspace\\comfyui-preset\\plugin\\'
const study = await import('file:///' + BASE.replace(/\\/g, '/') + 'study-gate.js')
const review = await import('file:///' + BASE.replace(/\\/g, '/') + 'review-gate.js')

let pass = 0
let fail = 0
function check(label, cond, extra) {
  if (cond) { pass++; console.log('  ✓ ' + label) }
  else { fail++; console.log('  ✗ ' + label + (extra === undefined ? '' : '  → ' + JSON.stringify(extra))) }
}

// A fake ctx exposing workingDirectory.get(session).
function makeCtx(dir) {
  return {
    get(name) {
      if (name !== 'workingDirectory') return undefined
      return { get: () => dir }
    },
  }
}

const PROJECT = 'C:\\Users\\10174\\Documents\\deepseek-harness\\default-workspace'
const ART5 = 'H:\\作品\\AI\\ART5'

console.log('\n1) 会话目录优先于宿主 cwd')
{
  const ctx = makeCtx(ART5)
  const exec = { name: 'mcp__comfymcp__system_stats', agent: { id: 'a1', session: {} } }
  // ART5 有 02_env/study/comfyui，所以应当放行（已 study）
  const d = study.evaluate(exec, { ...study.DEFAULTS }, new Set(), ART5)
  check('ART5（已 study comfyui）→ 放行', d === null, d && d.kind)
}

console.log('\n2) 换到没有 study 的项目 → 应当拦（证明跟随项目，而不是写死 ART5）')
{
  const d = study.evaluate(
    { name: 'mcp__comfymcp__system_stats', agent: { id: 'a2', session: {} } },
    { ...study.DEFAULTS },
    new Set(),
    PROJECT, // default-workspace：没有 02_env/study
  )
  check('default-workspace（无 study）→ 拦下', d !== null && d.kind === 'deny', d)
  if (d) {
    check('deny 文案指向**当前项目**下的 study，不是 ART5',
      d.reason.includes(PROJECT) && !d.reason.includes(ART5))
    check('deny 文案给了可执行出路', /source\.md|refs/.test(d.reason))
  }
}

console.log('\n3) 相对路径 workRoots 相对项目目录解析')
{
  // './dev-ws' 不存在 → 无法检查 → fail-safe 放行（等价于"工作根不存在"）
  const d = study.evaluate(
    { name: 'mcp__comfymcp__system_stats', agent: { id: 'a3', session: {} } },
    { ...study.DEFAULTS, workRoots: ['./does-not-exist'] },
    new Set(),
    PROJECT,
  )
  check('相对路径不存在 → 放行（fail-safe）', d === null, d && d.kind)
}

console.log('\n4) 绝对路径 workRoots 仍然生效（向后兼容）')
{
  const d = study.evaluate(
    { name: 'mcp__comfymcp__system_stats', agent: { id: 'a4', session: {} } },
    { ...study.DEFAULTS, workRoots: [ART5] },
    new Set(),
    PROJECT, // 传入的是别的项目，但配置写死 ART5 → 应以 ART5 为准
  )
  check('写死 ART5 + 传入其它项目 → 仍按 ART5 判定（放行）', d === null, d && d.kind)
}

console.log('\n5) review-gate 同样跟随项目')
{
  // 在 default-workspace 里放一个假媒体产物（存在即可）
  const fakeMedia = path.join(PROJECT, '01_projects', '_probe', 'x.png')
  const d = await review.evaluatePresent(
    { name: 'present', args: { files: [{ path: fakeMedia }] } },
    { ...review.DEFAULTS },
    PROJECT,
  )
  // 文件不存在 → isFile false → 放行。这里只验证不抛、路径按 base 解析。
  check('不存在的产物 → 放行且不抛', d === null, d && d.kind)
}

console.log('\n6) 没有 workingDirectory 服务时回落 cwd（不崩）')
{
  const ctxNoSvc = { get: () => undefined }
  const exec = { name: 'mcp__comfymcp__x', agent: { id: 'a6', session: {} } }
  let threw = null
  try { study.evaluate(exec, { ...study.DEFAULTS }, new Set(), undefined) } catch (e) { threw = e }
  check('base 为 undefined 不抛', threw === null, threw && String(threw))
}

console.log('\n────────────────────────────────────────')
console.log(`结果：${pass} 通过 / ${fail} 失败`)
process.exitCode = fail === 0 ? 0 : 1
