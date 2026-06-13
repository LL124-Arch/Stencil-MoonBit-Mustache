///|
/// HTML 特殊字符转义
/// 对 & < > " ' 进行实体替换，防止 XSS 注入
pub fn escape_html(raw : String) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < raw.length(); i = i + 1 {
    let ch = raw[i].to_int().unsafe_to_char()
    match ch {
      '&' => buf.write_string("&amp;")
      '<' => buf.write_string("&lt;")
      '>' => buf.write_string("&gt;")
      '"' => buf.write_string("&quot;")
      '\'' => buf.write_string("&#39;")
      _ => buf.write_char(ch)
    }
  }
  buf.to_string()
}
