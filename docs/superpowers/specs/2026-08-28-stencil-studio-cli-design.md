# Stencil Studio CLI 视觉与信息架构设计

## 目标

将仓库的 CLI 示例从单行输出升级为可读、可探索的终端产品入口，并同步重排 README，使首次访问者能快速理解 Stencil 的定位、能力和运行方式。

## 体验方向

- 视觉关键词：深色终端、青绿色品牌色、清晰分区、低噪音信息层级。
- CLI 默认命令展示品牌头部、能力标签、模板/数据/输出三段式演示和下一步命令。
- 命令输出统一使用 `[ok]`、`[info]`、`[warn]` 语义标签，避免依赖 ANSI 颜色，保证 CI 与纯文本终端可读。
- README 采用“定位 → 特性 → 快速运行 → API → 边界 → 开发验证”的产品首页顺序。

## 范围

### CLI

保留现有 `benchmark`、`analyze`、`compatibility` 命令兼容性；新增 `help` 和显式 `demo` 命令。默认无参数等价于 `demo`。演示内容使用现有 `render` API，展示 HTML 转义、区块迭代和可复用模板等真实能力。

### 文档

更新 README 的标题、徽章式状态信息、目录、快速开始和 CLI 区块；不修改库 API 的语义和兼容性说明。新增 CHANGELOG 条目记录本次体验改造。

## 结构与错误处理

CLI 内部拆分为标题、帮助、默认演示和命令分发四类小函数。渲染失败继续通过现有 `TemplateError` 输出可读错误，不引入新依赖或全局状态。

## 验证

- `moon fmt --check`
- `moon check --deny-warn --target all`
- `moon test --deny-warn --target native`
- `moon run cli`
- `moon run cli -- help`
- `moon run cli -- benchmark`

