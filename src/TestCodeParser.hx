class TestCodeParser extends haxe.unit.TestCase {
  static var test_code = [
    [ "this is my array_shift() method", "1", "{minimum => {PHP => 4}, maximum => {}}" ],
    [ "this is my array_shift() json_encode() method", "2", "{minimum => {PHP => 5.2.0, json => 1.2.0}, maximum => {}}" ],
    [ "this is my array_shift() json_encode() cpdf_arc()", "3", "{minimum => {PHP => 5.2.0, json => 1.2.0}, maximum => {PHP => 5.0.5}}" ],
    [ "array_shift()", "1", "{minimum => {PHP => 4}, maximum => {}}" ],
    [ "//harmonious json_encode\narray_shift() json_encode()\n//harmonious_end", "1", "{minimum => {PHP => 4}, maximum => {}}" ],
    [ "//harmonious json_encode\narray_shift() json_encode()\n//harmonious_end\njson_encode()", "2", "{minimum => {PHP => 5.2.0, json => 1.2.0}, maximum => {}}" ],
    [ "//harmonious @json\narray_shift() json_encode()\n//harmonious_end\njson_encode()", "2", "{minimum => {PHP => 5.2.0}, maximum => {}}" ],
    [ "//harmonious @PHP\narray_shift()", "1", "{minimum => {PHP => 4}, maximum => {}}" ]
  ];

  #if neko
    function testCodeParserLoadTokens() {
      var p = new CodeParser();
      p.loadProcessorsFromDisk();
      assertTrue(p.token_processors.exists("FunctionTokenProcessor"));
    }

    function testProcessCode() {
      var p = new CodeParser();
      p.loadProcessorsFromDisk();

      for (code in test_code) {
        var result = p.parse(code[0]);
        var ignored_modules = p.ignored_modules;
        assertEquals(Std.parseInt(code[1]), result.length);
        var code_version_info = new CodeVersionInformation(result, ignored_modules);
        assertEquals(code[2], code_version_info.final_versions.toString());
      }
    }
  #end
}