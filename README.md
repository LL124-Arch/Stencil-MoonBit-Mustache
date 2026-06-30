# Stencil

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-orange.svg)](https://www.moonbitlang.cn/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)](#)

**Stencil** is a lightweight, high-performance, original template engine for the **MoonBit** programming language. It supports Mustache-style template syntax, offering a flexible and clean way to separate logic and presentation in your applications.

**Stencil** 鏄负 **MoonBit** 缂栫▼璇█璁捐鐨勪竴娆捐交閲忕骇銆侀珮鎬ц兘鐨勫師鐢熸ā鏉垮紩鎿庛€傚畠鏀寔 Mustache 椋庢牸鐨勬ā鏉胯娉曪紝涓烘偍鎻愪緵鐏垫椿銆佹竻鏅扮殑閫昏緫涓庤鍥惧垎绂绘柟妗堛€?
---

## Features | 鐗规€?
- **Safe Variable Interpolation**: HTML-escaped by default to prevent XSS vulnerabilities.
- **Raw Variable Support**: Triple curly braces `{{{value}}}` or `{{&value}}` for raw, unescaped HTML output.
- **Section Blocks (`{{#section}}`)**: Supports conditional rendering, list iteration (with implicit iterator `{{.}}`), and nested object contexts.
- **Inverted Sections (`{{^section}}`)**: Renders content when values are false, null, empty strings, or empty arrays.
- **Partials (`{{>partial}}`)**: Supports sub-templates and template reuse with correct indentation formatting.
- **Comments (`{{!comment}}`)**: Ignored by the rendering engine, useful for documentation.
- **Bilingual Documentation & Full Test Coverage**: Robust unit and integration tests under MoonBit's modern toolchain.

- **瀹夊叏鍙橀噺鎻掑€?*锛氶粯璁ゅ鍙橀噺杩涜 HTML 杞箟锛岄槻姝?XSS 璺ㄧ珯鑴氭湰娉ㄥ叆銆?- **鍘熷鍙橀噺杈撳嚭**锛氭敮鎸?`{{{value}}}` 鎴?`{{&value}}` 杈撳嚭鏈粡杞箟鐨勫師濮?HTML 鏂囨湰銆?- **鍖哄潡鎺у埗 (`{{#section}}`)**锛氭敮鎸佹潯浠跺垽鏂€佹暟缁勫垪琛ㄨ凯浠ｏ紙鍚殣寮忚凯浠ｅ櫒 `{{.}}`锛変互鍙婂璞′綔鐢ㄥ煙宓屽銆?- **鍙嶈浆鍖哄潡 (`{{^section}}`)**锛氬綋鍙橀噺涓哄亣銆乶ull銆佺┖瀛楃涓叉垨绌烘暟缁勬椂娓叉煋鍐呭銆?- **灞€閮ㄦā鏉?(`{{>partial}}`)**锛氭敮鎸佸瓙妯℃澘寮曠敤涓庡鐢紝涓旀敮鎸佽嚜鍔ㄧ缉杩涘榻愩€?- **妯℃澘娉ㄩ噴 (`{{!comment}}`)**锛氭敞閲婂唴瀹逛細琚覆鏌撳紩鎿庡拷鐣ワ紝鏂逛究璁板綍閫昏緫銆?- **瀹屽杽鐨勬祴璇曡鐩?*锛氬湪 MoonBit 鏈€鏂板伐鍏烽摼涓嬪疄鐜伴珮姣斾緥鐨勫崟鍏冩祴璇曚笌闆嗘垚娴嬭瘯瑕嗙洊銆?
---

## Quick Start | 蹇€熷紑濮?
Add `LL124-Arch/stencil` to your package dependencies. Here is a simple example of compiling and rendering a template:

灏?`LL124-Arch/stencil` 娣诲姞涓洪」鐩緷璧栥€備互涓嬫槸缂栬瘧鍜屾覆鏌撴ā鏉跨殑绠€鍗曠ず渚嬶細

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

## API Reference | API 鏂囨。

### `render(template : String, data : Json) -> String raise TemplateError`
Compiles and renders the template string directly in one step.
涓€姝ュ畬鎴愭ā鏉跨紪璇戜笌娓叉煋銆?
### `compile(source : String) -> Template raise TemplateError`
Compiles a raw template string into a reusable `Template` AST representation. Useful when you need to render the same template multiple times with different datasets.
灏嗗師濮嬫ā鏉跨紪璇戜负鍙噸澶嶄娇鐢ㄧ殑 `Template` 璇硶鏍戝璞°€傞€傜敤浜庨渶瑕佺敤涓嶅悓鏁版嵁澶氭娓叉煋鍚屼竴妯℃澘鐨勫満鏅€?
### `Template::render(self : Template, data : Json) -> String`
Renders a pre-compiled template with the given JSON context.
浣跨敤鎸囧畾鏁版嵁娓叉煋宸茬紪璇戠殑妯℃澘銆?
### `render_with_partials(template : String, data : Json, partials : Map[String, String]) -> String raise TemplateError`
Renders a template including references to partial sub-templates.
娓叉煋鍖呭惈瀛愭ā鏉匡紙灞€閮ㄦā鏉匡級寮曠敤鐨勬ā鏉裤€?
---

## Template Syntax | 妯℃澘璇硶

### 1. Variables | 鍙橀噺
- Escaped (杞箟): `{{name}}` -> Transforms `<script>` to `&lt;script&gt;`
- Unescaped (鍘熸牱杈撳嚭): `{{{html}}}` or `{{&html}}`

### 2. Sections | 鍖哄潡 (`{{#section}} ... {{/section}}`)
Renders based on the value's type:
鏍规嵁鍙橀噺鍊肩被鍨嬫墽琛屼笉鍚岄€昏緫锛?- **Boolean/Truthy**: Renders once if the value is truthy (not null, false, empty string, or empty list).
  **甯冨皵鍊?鐪熷€?*锛氬鏋滃€间负鐪熷垯娓叉煋涓€娆°€?- **List/Array**: Iterates over the items and sets each item as the current context. Use `{{.}}` for the current primitive value.
  **鍒楄〃/鏁扮粍**锛氶亶鍘嗘暟缁勶紝姣忎釜鍏冪礌浣滀负瀛愪笂涓嬫枃娓叉煋銆備娇鐢?`{{.}}` 鑾峰彇褰撳墠鍊笺€?- **Object**: Navigates into the object's context.
  **瀵硅薄**锛氳繘鍏ュ璞＄殑瀛楁灞炴€т綔鐢ㄥ煙銆?
### 3. Inverted Sections | 鍙嶈浆鍖哄潡 (`{{^section}} ... {{/section}}`)
Renders only when the key is missing, null, false, empty string, or empty array.
浠呭綋鍙橀噺缂哄け銆佷负绌恒€佷负 false銆佺┖瀛楃涓叉垨绌烘暟缁勬椂杩涜娓叉煋銆?
### 4. Partials | 灞€閮ㄦā鏉?(`{{>partial_name}}`)
Inlines another template. Indentation at the tag position is automatically applied to all lines in the partial output.
鍐呰仈骞跺紩鍏ュ彟涓€涓ā鏉裤€傛爣绛炬墍鍦ㄨ鐨勭缉杩涢噺浼氳嚜鍔ㄥ簲鐢ㄤ簬瀛愭ā鏉夸腑鐨勬瘡涓€琛屻€?
---

## Development & Testing | 寮€鍙戜笌娴嬭瘯

Make sure you have the [MoonBit CLI toolchain](https://www.moonbitlang.cn/download/) installed (version `>= 0.1.20260529`).

纭繚宸插畨瑁?[MoonBit CLI 宸ュ叿閾綸(https://www.moonbitlang.cn/download/)銆?
### Compile project | 缂栬瘧椤圭洰
```bash
moon check
```

### Run tests | 杩愯娴嬭瘯
```bash
moon test
```

### Run demo | 杩愯绀轰緥
```bash
moon run cli
```

---

## License | 璁稿彲璇?
This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

鏈」鐩噰鐢?Apache 2.0 璁稿彲璇併€傝鎯呭弬瑙?[LICENSE](LICENSE)銆?