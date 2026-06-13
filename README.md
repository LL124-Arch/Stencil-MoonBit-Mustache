# Stencil

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-orange.svg)](https://www.moonbitlang.cn/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

**Stencil** is a lightweight, high-performance, original template engine for the **MoonBit** programming language. It supports Mustache-style template syntax, offering a flexible and clean way to separate logic and presentation in your applications.

**Stencil** 是为 **MoonBit** 编程语言设计的一款轻量级、高性能的原生模板引擎。它支持 Mustache 风格的模板语法，为您提供灵活、清晰的逻辑与视图分离方案。

---

## Features | 特性

- **Safe Variable Interpolation**: HTML-escaped by default to prevent XSS vulnerabilities.
- **Raw Variable Support**: Triple curly braces `{{{value}}}` or `{{&value}}` for raw, unescaped HTML output.
- **Section Blocks (`{{#section}}`)**: Supports conditional rendering, list iteration (with implicit iterator `{{.}}`), and nested object contexts.
- **Inverted Sections (`{{^section}}`)**: Renders content when values are false, null, empty strings, or empty arrays.
- **Partials (`{{>partial}}`)**: Supports sub-templates and template reuse with correct indentation formatting.
- **Comments (`{{!comment}}`)**: Ignored by the rendering engine, useful for documentation.
- **Bilingual Documentation & Full Test Coverage**: Robust unit and integration tests under MoonBit's modern toolchain.

- **安全变量插值**：默认对变量进行 HTML 转义，防止 XSS 跨站脚本注入。
- **原始变量输出**：支持 `{{{value}}}` 或 `{{&value}}` 输出未经转义的原始 HTML 文本。
- **区块控制 (`{{#section}}`)**：支持条件判断、数组列表迭代（含隐式迭代器 `{{.}}`）以及对象作用域嵌套。
- **反转区块 (`{{^section}}`)**：当变量为假、null、空字符串或空数组时渲染内容。
- **局部模板 (`{{>partial}}`)**：支持子模板引用与复用，且支持自动缩进对齐。
- **模板注释 (`{{!comment}}`)**：注释内容会被渲染引擎忽略，方便记录逻辑。
- **完善的测试覆盖**：在 MoonBit 最新工具链下实现高比例的单元测试与集成测试覆盖。

---

## Quick Start | 快速开始

Add `LL124-Arch/stencil` to your package dependencies. Here is a simple example of compiling and rendering a template:

将 `LL124-Arch/stencil` 添加为项目依赖。以下是编译和渲染模板的简单示例：

```moonbit
// main.mbt
fn main {
  let template = "Hello {{name}}! Welcome to {{project}}."
  let data : Json = {
    "name": "Developer",
    "project": "Stencil Template Engine"
  }
  
  try {
    let result = @stencil.render(template, data)
    println(result) // Output: Hello Developer! Welcome to Stencil Template Engine.
  } catch {
    @stencil.TemplateError(msg) => println("Error: \{msg}")
  }
}
```

---

## API Reference | API 文档

### `render(template : String, data : Json) -> String raise TemplateError`
Compiles and renders the template string directly in one step.
一步完成模板编译与渲染。

### `compile(source : String) -> Template raise TemplateError`
Compiles a raw template string into a reusable `Template` AST representation. Useful when you need to render the same template multiple times with different datasets.
将原始模板编译为可重复使用的 `Template` 语法树对象。适用于需要用不同数据多次渲染同一模板的场景。

### `Template::render(self : Template, data : Json) -> String`
Renders a pre-compiled template with the given JSON context.
使用指定数据渲染已编译的模板。

### `render_with_partials(template : String, data : Json, partials : Map[String, String]) -> String raise TemplateError`
Renders a template including references to partial sub-templates.
渲染包含子模板（局部模板）引用的模板。

---

## Template Syntax | 模板语法

### 1. Variables | 变量
- Escaped (转义): `{{name}}` -> Transforms `<script>` to `&lt;script&gt;`
- Unescaped (原样输出): `{{{html}}}` or `{{&html}}`

### 2. Sections | 区块 (`{{#section}} ... {{/section}}`)
Renders based on the value's type:
根据变量值类型执行不同逻辑：
- **Boolean/Truthy**: Renders once if the value is truthy (not null, false, empty string, or empty list).
  **布尔值/真值**：如果值为真则渲染一次。
- **List/Array**: Iterates over the items and sets each item as the current context. Use `{{.}}` for the current primitive value.
  **列表/数组**：遍历数组，每个元素作为子上下文渲染。使用 `{{.}}` 获取当前值。
- **Object**: Navigates into the object's context.
  **对象**：进入对象的字段属性作用域。

### 3. Inverted Sections | 反转区块 (`{{^section}} ... {{/section}}`)
Renders only when the key is missing, null, false, empty string, or empty array.
仅当变量缺失、为空、为 false、空字符串或空数组时进行渲染。

### 4. Partials | 局部模板 (`{{>partial_name}}`)
Inlines another template. Indentation at the tag position is automatically applied to all lines in the partial output.
内联并引入另一个模板。标签所在行的缩进量会自动应用于子模板中的每一行。

---

## Development & Testing | 开发与测试

Make sure you have the [MoonBit CLI toolchain](https://www.moonbitlang.cn/download/) installed (version `>= 0.1.20260529`).

确保已安装 [MoonBit CLI 工具链](https://www.moonbitlang.cn/download/)。

### Compile project | 编译项目
```bash
moon check
```

### Run tests | 运行测试
```bash
moon test
```

### Run demo | 运行示例
```bash
moon run cli
```

---

## License | 许可证

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

本项目采用 Apache 2.0 许可证。详情参见 [LICENSE](LICENSE)。
