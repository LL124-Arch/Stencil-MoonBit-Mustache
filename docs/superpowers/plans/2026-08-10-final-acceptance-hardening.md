# Stencil 最终验收工程化加固实施计划

> 执行规则：每个行为变更先加入一个最小失败测试，确认测试因缺少目标行为而失败，再实现最小改动并运行全量测试。

## 1. 建立当前基线

- 记录当前 Git 状态、MoonBit 工具链、测试数量、源码行数和 Mooncakes 版本。
- 以 GitHub 工作树作为主实现树；GitLink 只在主树验证通过后同步。

## 2. 解析与渲染安全测试先行

- 添加未闭合标签、错配标签、空标签、CRLF 和 Unicode 测试。
- 添加超深 section、超深 partial、partial 循环和超长列表边界测试。
- 添加 Mustache 核心行为矩阵：变量、原始变量、section、inverted、dotted path、上下文遮蔽、缩进 partial、缺失值。
- 先运行新增测试，记录预期失败，再实现错误诊断和深度保护。

## 3. 实现最小安全机制

- 引入内部解析/渲染限制对象，不破坏现有公共 API。
- 为递归解析、section 渲染和 partial 展开设置明确上限。
- 统一错误文本，保证失败可定位、可复现、不会无限递归。
- 维持现有兼容边界，并补充 README 中的行为契约。

## 4. 扩充规范测试与工程规模

- 新增独立的兼容性测试文件和确定性压力测试文件。
- 用表驱动测试覆盖 JSON 类型组合、HTML 特殊字符、Unicode、CRLF、深层路径和空值语义。
- 测试数据保持固定，不依赖网络或随机种子外部状态。

## 5. 增强可复现基准

- 扩展 CLI 为可选择 workload 的 benchmark 入口，支持编译+渲染与复用编译模板两种模式。
- 更新 PowerShell 基准脚本，输出 workload、迭代次数、总耗时和平均耗时。
- 记录至少三档真实 workload 的结果，注明机器、工具链、日期及启动开销口径。

## 6. 文档与合规修订

- README 增加 Mooncakes 直接链接、版本、限制、错误行为、测试分类、基准复现方式和最终验收命令。
- CHANGELOG 增加 0.1.2 和本轮加固记录。
- 修复申报书控制字符、测试数量和当前功能描述。
- 更新验收清单，加入源码规模、边界测试、基准、远程 HEAD、唯一贡献者和 Mooncakes 元数据。
- 复核 Apache-2.0、贡献指南、行为准则和新增文件的来源。

## 7. 验证与双仓库同步

- 本地依次运行 `moon fmt --check`、`moon check --deny-warn --target all`、`moon build --target wasm,wasm-gc,js`、`moon info --target all`、接口漂移检查和三目标测试。
- 有 C 编译器的环境运行 native build/test；当前 Windows 环境如无编译器必须明确记录跳过原因。
- 运行 `scripts/verify_acceptance.ps1` 和 benchmark 脚本。
- 检查最终 Git 历史、默认分支、贡献者、工作树和双仓库文件哈希。
- 只有所有检查完成后，才创建提交、推送两个远程仓库，并按版本策略发布 Mooncakes。

## 8. 交付证据

- 变更文件清单与提交记录。
- 本地验收脚本完整输出。
- GitHub Actions 最终提交绿色结果。
- Mooncakes API 的版本和构建状态。
- GitHub/GitLink 默认分支和唯一贡献者复核结果。
