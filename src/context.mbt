/// 数据上下文管理
/// 用上下文栈实现 Section 内的作用域查找

///|
/// 在 Json 对象中按 key 查找值
pub fn lookup(data : Json, key : String) -> Json {
  if key == "." {
    // 隐式迭代器，返回当前元素
    return data
  }
  // 支持点号分隔的路径查找 如 person.name
  if find_str(key, ".", 0) >= 0 {
    return lookup_path(data, key)
  }
  match data {
    Object(map) =>
      match map.get(key) {
        Some(v) => v
        None => null
      }
    _ => null
  }
}

///|
/// 按 "a.b.c" 路径逐级查找
fn lookup_path(data : Json, path : String) -> Json {
  let parts = split_by_char(path, '.')
  let mut current = data
  let mut i = 0
  while i < parts.length() {
    match current {
      Object(map) =>
        match map.get(parts[i]) {
          Some(v) => current = v
          None => return null
        }
      _ => return null
    }
    i = i + 1
  }
  current
}

///|
/// 判断一个 Json 值是否为"真值"
/// null、false、空字符串、空数组视为假
pub fn is_truthy(value : Json) -> Bool {
  match value {
    Null => false
    True => true
    False => false
    String(s) => s.length() > 0
    Number(_, ..) => true
    Array(arr) => arr.length() > 0
    Object(_) => true
  }
}

///|
/// 将 Json 值转为字符串输出
pub fn value_to_string(value : Json) -> String {
  match value {
    Null => ""
    True => "true"
    False => "false"
    String(s) => s
    Number(n, ..) => n.to_string()
    Array(_) => "[Array]"
    Object(_) => "[Object]"
  }
}

///|
/// 上下文栈，支持 Section 内嵌套查找
/// 查找时从栈顶向下逐层搜索
pub struct Context {
  stack : Array[Json]
}

///|
pub fn Context::new(data : Json) -> Context {
  { stack: [data] }
}

///|
pub fn Context::push(self : Context, data : Json) -> Unit {
  self.stack.push(data)
}

///|
pub fn Context::pop(self : Context) -> Unit {
  if self.stack.length() > 1 {
    let _ = self.stack.pop()
  }
}

///|
/// 从栈顶向下查找 key
pub fn Context::find(self : Context, key : String) -> Json {
  if key == "." {
    return self.stack[self.stack.length() - 1]
  }
  let mut i = self.stack.length() - 1
  while i >= 0 {
    let val = lookup(self.stack[i], key)
    match val {
      Null => i = i - 1
      _ => return val
    }
  }
  null
}
