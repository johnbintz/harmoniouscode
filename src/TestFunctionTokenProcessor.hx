class TestFunctionTokenProcessor extends haxe.unit.TestCase {
  static var functionName : String = "test";
  static var functionFrom : String = "5.2";
  var testXml : String;
  var tokenProcessor : FunctionTokenProcessor;

  public override function setup() {
    testXml = "<versions> <function name='" + functionName + "' from='" + functionFrom + "'/> </versions>";
    tokenProcessor = new FunctionTokenProcessor();
    tokenProcessor.populate_from_string(testXml);
  }

  public function testGenerateSampleToken() {
    var testTokenArray = [ new FunctionToken(functionName, functionFrom) ];
    assertTrue(tokenProcessor.tokenHash.exists(functionName));
  }
}