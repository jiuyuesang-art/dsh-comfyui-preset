// 离线渲染验证：把 client 半的组件跑起来，检查两种形态的渲染树。
//
// 用最小 React 垫片（createElement / useState / useEffect / useRef），
// 通过控制 useState 的返回值分别渲染「折叠」与「展开」两种形态，
// 再把元素树拍平成文本做断言 —— 不依赖浏览器、不依赖 DSH。
//
// 用法: node tools/batch-progress-render-selftest.mjs

import { readFileSync } from 'node:fs'

const src = readFileSync(new URL('../plugin/batch-progress-client.js', import.meta.url), 'utf8')

let captured = null
globalThis.window = { __ModuleLoader__: { load: (spec) => { captured = spec } } }
await import('data:text/javascript;base64,' + Buffer.from(src, 'utf8').toString('base64'))

// ── 最小 React 垫片 ───────────────────────────────────────────────────────
let stateQueue = []
const shim = {
    createElement: (type, props, ...children) => ({ type, props: props ?? {}, children }),
    useState: () => {
        const v = stateQueue.length ? stateQueue.shift() : undefined
        return [v, () => {}]
    },
    useEffect: () => {},
    useRef: () => ({ current: null }),
}

const plugin = captured.factory((name) => {
    if (name === 'react') return shim
    throw new Error('未预期的模块请求: ' + name)
})

// 抓取注册的组件
let component = null
plugin.apply({
    slots: {
        inject: (slot, fn) => fn(),
        register: (_opts, comp) => { component = comp; return () => {} },
    },
})

// ── 把元素树拍平成文本 ────────────────────────────────────────────────────
function flatten(node, out = []) {
    if (node === null || node === undefined || node === false) return out
    if (typeof node === 'string' || typeof node === 'number') { out.push(String(node)); return out }
    if (Array.isArray(node)) { node.forEach((n) => flatten(n, out)); return out }
    if (typeof node === 'object') {
        if (node.children) node.children.forEach((c) => flatten(c, out))
    }
    return out
}

// 注意：组件吃的是 host 路由返回的 active = { state, statePath, updatedAt }
const PAYLOAD = {
    state: {
        total: 3, done: 3, ok: 3, failed: 0,
        phase: 'done', current: null, currentIndex: 3,
        startedAt: '2026-10-22 22:59:31', totalSeconds: 82.7,
    },
    statePath: 'C:/tmp/x.progress.json',
    updatedAt: 1792676216016,
}

function render({ folded }) {
    // 顺序：data, folded, gone
    stateQueue = [PAYLOAD, folded, false]
    return flatten(component())
}

let pass = 0, fail = 0
const ok = (n) => { pass++; console.log('  ✓ ' + n) }
const no = (n, why) => { fail++; console.log('  ✗ ' + n + '\n      ' + why) }

console.log('')
console.log('卡片渲染树验证（离线）')
console.log('─'.repeat(56))

// 1. 折叠形态：一行胶囊
{
    const text = render({ folded: true }).join(' ')
    if (text.includes('批量 3/3') && text.includes('全部完成')) ok('折叠形态：一行胶囊「批量 3/3 · 全部完成」')
    else no('折叠形态：一行胶囊', text.slice(0, 120))

    if (!text.includes('成功 3')) ok('折叠形态：不铺开明细（只有阶段）')
    else no('折叠形态：不铺开明细', text.slice(0, 120))
}

// 2. 展开形态：完整卡片
{
    const text = render({ folded: false }).join(' ')
    const need = ['ComfyUI 批量渲染', '3', '/ 3', '100%', '全部任务已结束', '成功 3', '失败 0', '全部完成']
    const missing = need.filter((t) => !text.includes(t))
    if (missing.length === 0) ok('展开形态：标题/计数/百分比/阶段/明细 全部齐备')
    else no('展开形态：完整卡片', '缺少 ' + JSON.stringify(missing) + ' · 实际 ' + text.slice(0, 160))
}

// 3. 无数据 → 不渲染任何东西
{
    stateQueue = [null, true, false]
    const el = component()
    if (el === null) ok('无数据时返回 null（不占界面）')
    else no('无数据时返回 null', String(el))
}

console.log('')
console.log('─'.repeat(56))
console.log('  结果：' + pass + ' 通过 / ' + fail + ' 失败')
process.exit(fail > 0 ? 1 : 0)
