class TestToken extends haxe.unit.TestCase {
  static var tokenName : String = "test";
  static var tokenVersion : String = "5.2";
  var t : Token;

  public override function setup() {
    t = new Token(tokenName, tokenVersion);
  }

  public function testInstantiateToken() {
    assertEquals(tokenName, t.token);
    assertEquals(tokenVersion, t.version);
  }

  public function testToResult() {
    var result = t.toResult();
    assertEquals(ResultType.Generic, result.type);
    assertEquals(tokenName, result.token);
    assertEquals(tokenVersion, result.version);
  }
}