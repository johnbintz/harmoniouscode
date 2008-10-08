class TestConstantToken extends haxe.unit.TestCase {
  function testCreateConstantToken() {
    var t = new ConstantToken("meow", "hiss");
    assertEquals("meow", t.token);
    assertEquals("hiss", t.version);
    assertEquals(ResultType.Constant, t.token_type);
  }
}