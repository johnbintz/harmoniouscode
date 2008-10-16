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
}