class TestFunctionTokenProcessor extends haxe.unit.TestCase {
  static var function_name : String = "test";
  static var function_from : String = "5.2";
  var token_processor : FunctionTokenProcessor;

  public override function setup() {
    var test_xml = "<versions> <function name='" + function_name + "' from='" + function_from + "'/> </versions>";
    token_processor = new FunctionTokenProcessor();
    token_processor.populate_from_string(test_xml);
  }

  public function testGenerateSampleToken() {
    assertTrue(token_processor.tokenHash.exists(function_name));
  }

  public function testSerializeInfo() {
    var test_xml = "<versions> <function name='one' from='PHP 4, PHP 5' /> <function name='two' from='PHP 4, PHP 5' /> </versions>";
    token_processor.populate_from_string(test_xml);

    var target_token_hash = "{one => { version => PHP 4, PHP 5, token => one }, two => { version => PHP 4, PHP 5, token => two }}";

    assertEquals(target_token_hash, token_processor.tokenHash.toString());

    var unwound_tokens = token_processor.unwind_tokens();

    assertTrue(unwound_tokens.toString().length < target_token_hash.length);

    token_processor = new FunctionTokenProcessor();
    token_processor.populate_from_unwound_tokens(unwound_tokens);

    assertEquals(target_token_hash, token_processor.tokenHash.toString());
  }
}