///|
test "help presents the cli command map" {
  let output = command_help()
  assert_true(output.contains("Stencil Studio"))
  assert_true(output.contains("demo"))
  assert_true(output.contains("benchmark"))
}

///|
test "demo presents template data and rendered output" {
  let output = demo_output()
  assert_true(output.contains("TEMPLATE"))
  assert_true(output.contains("DATA"))
  assert_true(output.contains("RENDERED OUTPUT"))
  assert_true(output.contains("&lt;strong&gt;MoonBit&lt;/strong&gt;"))
}
