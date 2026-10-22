/**
 * batch-progress —— Client 半：把批量渲染进度挂进 DSH 自己的界面。
 *
 * 以 DSH client-modules 的自注册格式发布：window.__ModuleLoader__.load({ id, factory })。
 * factory 里的 require('react') 由 DSH 客户端运行时解析，**不需要打包**。
 *
 * 数据来自 Host 半的 GET /api/comfy-batch/progress；本文件不写任何东西。
 *
 * 挂载点：`shell.overlay`（全框浮层，不进任何列的滚动容器）——
 * 和小窗版本一样的位置语义，但现在住在 DSH 界面里。
 */

window.__ModuleLoader__.load({
    id: 'comfy-batch-progress',
    factory(require) {
        const React = require('react')
        const { useEffect, useRef, useState } = React
        const h = React.createElement

        const API = '/api/comfy-batch/progress'
        const POLL_MS = 800

        const PHASE_TEXT = {
            starting: '准备中',
            running: '渲染中',
            freeing: '清显存',
            restarting: '重启 ComfyUI',
            done: '全部完成',
            partial: '部分失败',
            failed: '全部失败',
            aborted: '已中止',
        }
        const PHASE_COLOR = {
            starting: '#7DD3FC',
            running: '#22D3EE',
            freeing: '#FDE68A',
            restarting: '#FCA5A5',
            done: '#34D399',
            partial: '#FDBA74',
            failed: '#F87171',
            aborted: '#F87171',
        }

        function fmtDuration(seconds) {
            const s = Math.max(0, Math.round(seconds || 0))
            const mm = String(Math.floor(s / 60)).padStart(2, '0')
            const ss = String(s % 60).padStart(2, '0')
            return mm + ':' + ss
        }

        const S = {
            wrap: {
                position: 'fixed',
                right: '20px',
                bottom: '20px',
                width: '296px',
                background: 'rgba(15, 22, 38, 0.96)',
                border: '1px solid rgba(34, 211, 238, 0.35)',
                borderRadius: '14px',
                boxShadow: '0 12px 32px rgba(0, 0, 0, 0.45)',
                color: '#E6EDF7',
                font: '13px/1.5 system-ui, "Microsoft YaHei UI", sans-serif',
                padding: '12px 14px',
                zIndex: 2147483000,
                backdropFilter: 'blur(8px)',
            },
            head: { display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' },
            title: { fontSize: '12.5px', fontWeight: 600, letterSpacing: '0.2px', opacity: 0.92, flex: 1 },
            pill: { fontSize: '11px', padding: '2px 8px', borderRadius: '9px', border: '1px solid transparent' },
            numRow: { display: 'flex', alignItems: 'baseline', gap: '6px', margin: '2px 0 8px' },
            big: { fontSize: '30px', fontWeight: 700, fontFamily: 'ui-monospace, Consolas, monospace', lineHeight: 1 },
            total: { fontSize: '30px', fontWeight: 700, fontFamily: 'ui-monospace, Consolas, monospace', color: '#64748B', lineHeight: 1 },
            pct: { fontSize: '12px', color: '#94A3B8', marginLeft: 'auto', fontFamily: 'ui-monospace, Consolas, monospace' },
            track: { height: '8px', borderRadius: '5px', background: '#1B2A44', overflow: 'hidden', marginBottom: '9px' },
            fill: { height: '100%', borderRadius: '5px', transition: 'width 240ms ease' },
            line: { fontSize: '12px', color: '#CBD5E1', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' },
            sub: { fontSize: '11.5px', color: '#64748B', marginTop: '3px' },
            fold: {
                position: 'fixed',
                right: '20px',
                bottom: '20px',
                background: 'rgba(15, 22, 38, 0.96)',
                border: '1px solid rgba(34, 211, 238, 0.35)',
                borderRadius: '999px',
                padding: '6px 14px',
                color: '#E6EDF7',
                font: '12px/1 system-ui, "Microsoft YaHei UI", sans-serif',
                cursor: 'pointer',
                boxShadow: '0 8px 24px rgba(0, 0, 0, 0.4)',
                zIndex: 2147483000,
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
            },
            btn: {
                background: 'transparent',
                border: 'none',
                color: '#64748B',
                cursor: 'pointer',
                fontSize: '13px',
                padding: '0 2px',
                lineHeight: 1,
            },
        }

        function BatchCard() {
            const [data, setData] = useState(null)     // { state, updatedAt } | null
            const [folded, setFolded] = useState(false)
            const [gone, setGone] = useState(false)    // 👤 手动关闭（阶段变化时自动恢复）
            const lastPhase = useRef(null)

            useEffect(() => {
                let alive = true
                let timer = null
                const tick = async () => {
                    try {
                        const res = await fetch(API, { credentials: 'same-origin' })
                        const payload = await res.json()
                        if (!alive) return
                        const active = payload?.active ?? null
                        setData(active)
                        const phase = active?.state?.phase ?? null
                        // 阶段切换（例如又开新批次）时把「已关闭」状态清掉
                        if (phase !== lastPhase.current) {
                            lastPhase.current = phase
                            setGone(false)
                        }
                    } catch {
                        if (alive) setData(null)
                    } finally {
                        if (alive) timer = setTimeout(tick, POLL_MS)
                    }
                }
                tick()
                return () => { alive = false; if (timer) clearTimeout(timer) }
            }, [])

            if (!data || gone) return null

            const s = data.state || {}
            const total = Number(s.total) || 0
            const done = Number(s.done) || 0
            const pct = total > 0 ? Math.min(100, Math.round((done / total) * 100)) : 0
            const phase = s.phase || 'running'
            const color = PHASE_COLOR[phase] || '#22D3EE'
            const phaseText = PHASE_TEXT[phase] || s.statusText || ''

            if (folded) {
                return h('div', {
                    style: S.fold,
                    onClick: () => setFolded(false),
                    title: '展开批量渲染进度',
                }, h('span', { style: { width: 8, height: 8, borderRadius: '50%', background: color } }),
                '批量 ' + done + '/' + total + ' · ' + phaseText)
            }

            const current = s.current
                ? ('正在处理：' + s.current + '（' + (s.currentIndex || done + 1) + '/' + total + '）')
                : (phase === 'restarting' ? '正在重启 ComfyUI（换进程，显存归零）…'
                    : phase === 'freeing' ? '正在清理显存…'
                        : total > 0 && done >= total ? '全部任务已结束'
                            : '提交中…')

            return h('div', { style: S.wrap },
                h('div', { style: S.head },
                    h('span', { style: S.title }, 'ComfyUI 批量渲染'),
                    h('span', {
                        style: Object.assign({}, S.pill, {
                            color: color,
                            background: color + '1A',
                            borderColor: color + '55',
                        }),
                    }, phaseText),
                    h('button', { style: S.btn, title: '收起', onClick: () => setFolded(true) }, '—'),
                    h('button', { style: S.btn, title: '关闭（新批次会自动出现）', onClick: () => setGone(true) }, '×'),
                ),

                h('div', { style: S.numRow },
                    h('span', { style: Object.assign({}, S.big, { color }) }, String(done)),
                    h('span', { style: S.total }, '/ ' + total),
                    h('span', { style: S.pct }, pct + '%'),
                ),

                h('div', { style: S.track },
                    h('div', { style: Object.assign({}, S.fill, { width: pct + '%', background: color }) }),
                ),

                h('div', { style: S.line, title: current }, current),
                h('div', { style: S.sub },
                    '成功 ' + (s.ok || 0) + ' · 失败 ' + (s.failed || 0) +
                    ' · 总耗时 ' + fmtDuration(s.totalSeconds) +
                    (s.startedAt ? ' · 开始于 ' + String(s.startedAt).slice(11) : '')),
            )
        }

        return {
            inject: ['slots'],
            apply(ctx) {
                ctx.slots.inject('shell.overlay', () =>
                    ctx.slots.register(
                        { name: 'shell.overlay', id: 'comfy-batch-progress', order: 120, label: '批量渲染进度' },
                        () => React.createElement(BatchCard),
                    ))
            },
        }
    },
})
