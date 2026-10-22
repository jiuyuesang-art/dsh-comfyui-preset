/**
 * batch-progress —— Host 半：给 DSH 界面里的进度卡片提供数据。
 *
 * 只做一件事：把「当前批次的状态文件」读出来，用 JSON 吐给 Client 半。
 *
 * 为什么要一个「指针文件」：
 *   批次的状态文件写在**计划文件旁边**（可能在任意工作根），Host 不该去扫盘找它。
 *   所以 batch-render.ps1 每次更新状态时，顺手把状态文件路径写进一个固定位置
 *   （%LOCALAPPDATA%\dsh-comfy-batch\active.json），这里只读那个指针。
 *
 * 安全边界：
 *   · 只接受文件名以 `.progress.json` 结尾的路径（防止被指到任意文件）
 *   · 只读、不写、不杀进程；GET only
 *   · 指针超过 staleMs（默认 6 小时）就当没有活动批次
 */

export const name = 'comfy-batch-progress'
export const inject = ['webServer']

export const API_PREFIX = '/api/comfy-batch'

import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'
import { homedir } from 'node:os'

/** 指针文件位置：%LOCALAPPDATA%\dsh-comfy-batch\active.json（其它平台退化到 ~/.dsh） */
export function pointerPath() {
    const base = process.env.LOCALAPPDATA || join(homedir(), '.dsh')
    return join(base, 'dsh-comfy-batch', 'active.json')
}

function readJson(path) {
    try {
        return JSON.parse(readFileSync(path, 'utf8'))
    } catch {
        return null
    }
}

/**
 * 取当前批次状态。返回 { active: null } 或 { active: { ...progress, statePath } }。
 * 纯函数，方便测试：接受注入的 pointerPath / now。
 */
export function readActive({ pointer = pointerPath(), now = Date.now(), staleMs = 6 * 3600 * 1000 } = {}) {
    if (!existsSync(pointer)) return { active: null, reason: 'no-pointer' }
    const p = readJson(pointer)
    if (!p || typeof p.statePath !== 'string') return { active: null, reason: 'bad-pointer' }
    if (!p.statePath.endsWith('.progress.json')) return { active: null, reason: 'rejected-path' }
    if (!existsSync(p.statePath)) return { active: null, reason: 'missing-state' }

    const state = readJson(p.statePath)
    if (!state) return { active: null, reason: 'bad-state' }

    const updatedAt = Number(p.updatedAt) || 0
    if (updatedAt && now - updatedAt > staleMs) return { active: null, reason: 'stale' }

    return { active: { state, statePath: p.statePath, updatedAt } }
}

function sendJson(res, status, body) {
    const text = JSON.stringify(body)
    res.writeHead(status, {
        'content-type': 'application/json; charset=utf-8',
        'cache-control': 'no-store',
    })
    res.end(text)
}

export function createRoutes(options = {}) {
    return [
        {
            kind: 'exact',
            path: `${API_PREFIX}/progress`,
            handler(req, res) {
                if (req.method !== 'GET') return sendJson(res, 405, { ok: false, error: '只支持 GET' })
                const { active, reason } = readActive(options)
                sendJson(res, 200, { ok: true, active, reason: active ? undefined : reason })
            },
        },
    ]
}

export function apply(ctx, config) {
    const raw = typeof config?.get === 'function' ? config.get() : config
    const options = {}
    if (Number.isFinite(raw?.staleMs)) options.staleMs = raw.staleMs
    if (typeof raw?.pointer === 'string') options.pointer = raw.pointer

    for (const route of createRoutes(options)) {
        ctx.effect(() => ctx.webServer.register(route), `${name} ${route.path}`)
    }
}
