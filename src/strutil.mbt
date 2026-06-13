// 字符串辅助函数

///|
fn char_at(s : String, i : Int) -> Char {
  s[i].to_int().unsafe_to_char()
}

///|
/// 从 pos 开始查找 pattern 在 s 中首次出现的位置，未找到返回 -1
fn find_str(s : String, pattern : String, from : Int) -> Int {
  let slen = s.length()
  let plen = pattern.length()
  if plen == 0 {
    return from
  }
  if from + plen > slen {
    return -1
  }
  let mut i = from
  while i <= slen - plen {
    let mut matched = true
    let mut j = 0
    while j < plen {
      if s[i + j] != pattern[j] {
        matched = false
        break
      }
      j = j + 1
    }
    if matched {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// 去除字符串首尾空白字符
fn trim_spaces(s : String) -> String {
  let len = s.length()
  if len == 0 {
    return s
  }
  let mut start = 0
  while start < len && is_whitespace(char_at(s, start)) {
    start = start + 1
  }
  let mut end = len - 1
  while end >= start && is_whitespace(char_at(s, end)) {
    end = end - 1
  }
  if start > end {
    return ""
  }
  substring(s, start, end + 1)
}

///|
fn is_whitespace(ch : Char) -> Bool {
  ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r'
}

///|
/// 提取 s[start..end) 的子串
fn substring(s : String, start : Int, end : Int) -> String {
  let buf = StringBuilder::new()
  let mut i = start
  while i < end && i < s.length() {
    buf.write_char(char_at(s, i))
    i = i + 1
  }
  buf.to_string()
}

///|
/// 从 start 位置截取到末尾
fn substring_from(s : String, start : Int) -> String {
  substring(s, start, s.length())
}

///|
/// 按单个字符分割字符串
fn split_by_char(s : String, sep : Char) -> Array[String] {
  let parts : Array[String] = []
  let buf = StringBuilder::new()
  for i = 0; i < s.length(); i = i + 1 {
    if char_at(s, i) == sep {
      parts.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(char_at(s, i))
    }
  }
  parts.push(buf.to_string())
  parts
}
