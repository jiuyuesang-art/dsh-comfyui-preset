// batch-progress Host 半的离线自检 —— 不需要 DSH、不需要 ComfyUI。
//
// 覆盖 readActive() 的六种情形：无指针 / 指针坏了 / 路径被拒 / 状态文件缺失 /
// 指针过期 / 正常读取。这些一旦错，界面卡片会显示错批次或永久空白。
//
// 用法: node tools/batch-progress-selftest.mjs

import { mkdtempSync, writeFileSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { readActive } from '../plugin/batch-progress.js'

let pass = 0
let fail = 0
const ok = (n) => { pass++; console.log('  ✓ ' + n) }
const no = (n, why) => { fail++; console.log('  ✗ ' + n + '\n      ' + why) }

const dir = mkdtempSync(join(tmpdir(), 'batchprogress-'))
const ptr = join(dir, 'active.json')

function writePtr(obj) { writeFileSync(ptr, JSON.stringify(obj), 'utf8') }
function writeState(name, obj) {
    const p = join(dir, name)
    writeFileSync(p, JSON.stringify(obj), 'utf8')
    return p
}

console.log('')
console.log('batch-progress Host 半自检')
console.log('─'.repeat(56))

// 1. 没有指针
let r = readActive({ pointer: join(dir, 'nope.json') })
if (r.active === null && r.reason === 'no-pointer') ok('无指针 → active=null / no-pointer')
else no('无指针 → active=null / no-pointer', JSON.stringify(r))

// 2. 指针不是合法 JSON
writeFileSync(ptr, '{ not json', 'utf8')
r = readActive({ pointer: ptr })
if (r.active === null && r.reason === 'bad-pointer') ok('指针非法 JSON → bad-pointer')
else no('指针非法 JSON → bad-pointer', JSON.stringify(r))

// 3. 指针指向非 .progress.json（安全边界）
writePtr({ statePath: join(dir, 'secret.txt'), updatedAt: Date.now() })
r = readActive({ pointer: ptr })
if (r.active === null && r.reason === 'rejected-path') ok('非 .progress.json 路径 → rejected-path')
else no('非 .progress.json 路径 → rejected-path', JSON.stringify(r))

// 4. 状态文件不存在
writePtr({ statePath: join(dir, 'gone.progress.json'), updatedAt: Date.now() })
r = readActive({ pointer: ptr })
if (r.active === null && r.reason === 'missing-state') ok('状态文件缺失 → missing-state')
else no('状态文件缺失 → missing-state', JSON.stringify(r))

// 5. 指针过期
const sp = writeState('stale.progress.json', { total: 2, done: 1, phase: 'running' })
writePtr({ statePath: sp, updatedAt: Date.now() - 7 * 3600 * 1000 })
r = readActive({ pointer: ptr })
if (r.active === null && r.reason === 'stale') ok('超过 staleMs → stale')
else no('超过 staleMs → stale', JSON.stringify(r))

// 6. 正常
const sp2 = writeState('live.progress.json', { total: 3, done: 2, ok: 2, failed: 0, phase: 'running', current: 'shot_b' })
const now = Date.now()
writePtr({ statePath: sp2, updatedAt: now })
r = readActive({ pointer: ptr, now })
if (r.active && r.active.state.done === 2 && r.active.state.current === 'shot_b' && r.active.statePath === sp2) {
    ok('正常读取 → 带回 state 与 statePath')
} else {
    no('正常读取 → 带回 state 与 statePath', JSON.stringify(r))
}

// 7. 指针缺 statePath 字段
writePtr({ updatedAt: now })
r = readActive({ pointer: ptr })
if (r.active === null && r.reason === 'bad-pointer') ok('指针缺 statePath → bad-pointer')
else no('指针缺 statePath → bad-pointer', JSON.stringify(r))

rmSync(dir, { recursive: true, force: true })

console.log('')
console.log('─'.repeat(56))
console.log('  结果：' + pass + ' 通过 / ' + fail + ' 失败')
process.exit(fail > 0 ? 1 : 0)
