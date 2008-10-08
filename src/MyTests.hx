class MyTests {
  static function main() {
    var r = new haxe.unit.TestRunner();
    r.add(new TestToken());
    r.add(new TestFunctionToken());
    r.add(new TestFunctionTokenProcessor());
    r.add(new TestConstantToken());
    r.add(new TestCodeParser());
    r.add(new TestCodeVersionInformation());
    r.add(new TestResult());
    r.add(new TestJavaScriptTarget());
    r.run();
  }
}