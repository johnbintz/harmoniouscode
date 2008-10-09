class TestJavaScriptTarget extends haxe.unit.TestCase {
  function testGetResults() {
    JavaScriptTarget.main();
    JavaScriptTarget.get_results("this is my array_shift()");
    assertEquals(1, JavaScriptTarget.current_results.length);
    assertTrue(JavaScriptTarget.current_results[0].is_enabled);

    JavaScriptTarget.change_result(0, false);
    assertFalse(JavaScriptTarget.current_results[0].is_enabled);

    JavaScriptTarget.get_results("this is my array_shift() zip_close()");
    assertEquals(2, JavaScriptTarget.current_results.length);

    assertEquals("{}", JavaScriptTarget.show_only_modules.toString());
    JavaScriptTarget.toggle_module("zip");
    assertEquals("{zip => true}", JavaScriptTarget.show_only_modules.toString());

    assertEquals("{}", JavaScriptTarget.ignored_modules.toString());
    JavaScriptTarget.change_module_ignore("zip", true);
    assertEquals("{zip => true}", JavaScriptTarget.ignored_modules.toString());
    JavaScriptTarget.change_module_ignore("zip", false);
    assertEquals("{zip => false}", JavaScriptTarget.ignored_modules.toString());
  }
}