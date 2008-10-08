class TestFunctionToken extends haxe.unit.TestCase {
  function testCreateFunctionToken() {
    var t = new FunctionToken("meow", "hiss");
    assertEquals("meow", t.token);
    assertEquals("hiss", t.version);
    assertEquals(ResultType.Function, t.token_type);
  }
}