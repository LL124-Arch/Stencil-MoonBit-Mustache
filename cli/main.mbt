///|
fn main {
  let template = "Hello {{name}}! Welcome to {{project}}."
  let data : Json = {
    "name": "developer",
    "project": "Stencil Template Engine",
  }
  try {
    let result = @lib.render(template, data)
    println(result)
  } catch {
    @lib.TemplateError(msg) => println("Error: \{msg}")
  }
}
