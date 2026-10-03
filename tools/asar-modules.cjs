// 正确解析 app.asar 的文件头，列出应用内全部模块。
//
// 为什么要自己解析：asar 的文件头就是一段 JSON 目录树，读它能拿到**完整清单**。
// 之前用 grep 式的清单工具只拿到 201 条（不完整），据此判断"模块不存在"是错的。
//
// asar 头格式（小端）：
//   UInt32  4                    —— pickle 的 size 字段长度
//   UInt32  headerSize           —— 头部总长（含下面的长度字段）
//   UInt32  jsonPaddedSize       —— JSON 字符串长度（4 字节对齐后）
//   UInt32  jsonActualSize       —— JSON 字符串实际长度
//   bytes   json                 —— 目录树 JSON
const fs = require('node:fs')

function readAsarIndex(asarPath) {
  const fd = fs.openSync(asarPath, 'r')
  try {
    const head = Buffer.alloc(16)
    fs.readSync(fd, head, 0, 16, 0)
    const jsonPaddedSize = head.readUInt32LE(8)
    const jsonActualSize = head.readUInt32LE(12)
    if (jsonActualSize <= 0 || jsonActualSize > 64 * 1024 * 1024) {
      throw new Error(`头部长度不合理：${jsonActualSize}`)
    }
    const buf = Buffer.alloc(jsonPaddedSize)
    fs.readSync(fd, buf, 0, jsonPaddedSize, 16)
    return JSON.parse(buf.toString('utf8', 0, jsonActualSize))
  } finally {
    fs.closeSync(fd)
  }
}

function walk(node, prefix, out) {
  if (!node || typeof node !== 'object') return
  if (node.files) {
    for (const [name, child] of Object.entries(node.files)) {
      walk(child, prefix ? `${prefix}/${name}` : name, out)
    }
  } else {
    out.push(prefix)
  }
}

const asarPath = process.argv[2] || 'D:/Deepseek/resources/app.asar'
const mode = process.argv[3] || 'modules'

const idx = readAsarIndex(asarPath)
const all = []
walk(idx, '', all)

if (mode === 'count') {
  console.log(`asar 内文件总数: ${all.length}`)
  process.exit(0)
}

// 抽取 node_modules/<scope>/<pkg>/package.json 形式的包
const pkgs = new Map()
for (const p of all) {
  const m = /(?:^|\/)node_modules\/((?:@[^/]+\/)?[^/]+)\/package\.json$/.exec(p)
  if (m) pkgs.set(m[1], p)
}

console.log(`asar: ${asarPath}`)
console.log(`文件总数 ${all.length}，其中 npm 包 ${pkgs.size} 个\n`)

const wanted = process.argv.slice(4)
if (wanted.length) {
  let miss = 0
  for (const w of wanted) {
    const hit = pkgs.has(w)
    console.log(`  ${hit ? '✅' : '❌'} ${w}`)
    if (!hit) miss++
  }
  console.log(`\n存在 ${wanted.length - miss} / ${wanted.length}`)
  process.exit(miss === 0 ? 0 : 1)
}

const ds = [...pkgs.keys()].filter((k) => k.startsWith('@deepseek-ai/')).sort()
console.log(`── @deepseek-ai/* 共 ${ds.length} 个 ──`)
for (const d of ds) console.log('  ' + d)
