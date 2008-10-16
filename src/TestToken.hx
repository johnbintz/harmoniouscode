class TestToken extends haxe.unit.TestCase {
  static var token_name : String = "test";
  static var token_version : String = "5.2";
  var t : Token;

  public override function setup() {
    t = new Token(token_name, token_version);
  }

  public function testInstantiateToken() {
    assertEquals(token_name, t.token);
    assertEquals(token_version, t.version);
  }

  public function testToResult() {
    var result = t.to_result();
    assertEquals(ResultType.Generic, result.type);
    assertEquals(token_name, result.token);
    assertEquals(token_version, result.version);
  }
}