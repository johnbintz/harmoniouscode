/**
  Test the CodeVersionInformation object.
**/
class TestCodeVersionInformation extends haxe.unit.TestCase {
  /**
    Test is_invalid()
  **/
  function test_is_invalid() {
    var valid_results = [
      new Result(ResultType.Function, "one", "PHP 4, PHP 5"),
      new Result(ResultType.Function, "two", "PHP 4 &lt;= 4.2.0")
    ];

    var code_version_info = new CodeVersionInformation(valid_results);
    assertTrue(code_version_info.is_valid());

    var invalid_results = [
      new Result(ResultType.Function, "one", "PHP 5 &gt;= 5.2.0"),
      new Result(ResultType.Function, "two", "PHP 4 &lt;= 4.2.0")
    ];

    var code_version_info = new CodeVersionInformation(invalid_results);
    assertFalse(code_version_info.is_valid());
  }

  /**
    Test breakdown_version_string()
  **/
  function test_breakdown_version_string() {
    assertEquals("[PHP, 4]", CodeVersionInformation.breakdown_php_version_string("PHP 4").toString());
    assertEquals("[PHP, 4]", CodeVersionInformation.breakdown_php_version_string(" PHP 4").toString());
    assertEquals("[PHP, 5.2.0]", CodeVersionInformation.breakdown_php_version_string("PHP 5 &gt;= 5.2.0").toString());
    assertEquals("[xmlwriter, 2.0.4]", CodeVersionInformation.breakdown_php_version_string("xmlwriter 2.0.4").toString());

    assertEquals("[xmlwriter, 0.1]", CodeVersionInformation.breakdown_php_version_string("xmlwriter 0.1-2.0.4").toString());
  }

  /**
    Test version_compare()
  **/
  function test_version_compare() {
    assertEquals(-1, CodeVersionInformation.version_compare("4", "5"));
    assertEquals(1, CodeVersionInformation.version_compare("5", "4"));
    assertEquals(-1, CodeVersionInformation.version_compare("4", "4.5"));
    assertEquals(1, CodeVersionInformation.version_compare("4.5", "4"));
    assertEquals(1, CodeVersionInformation.version_compare("4.10", "4.5"));
    assertEquals(-1, CodeVersionInformation.version_compare("4.5", "4.10"));
  }

  /**
    Test get_highest_version()
  **/
  function test_get_highest_version() {
    assertEquals("5.2.0", CodeVersionInformation.get_highest_version(["5.2.0"]));
    assertEquals("5.2.0", CodeVersionInformation.get_highest_version(["5.1.0", "5.2.0"]));
    assertEquals("5", CodeVersionInformation.get_highest_version(["4", "4.1", "5"]));
  }

  /**
    Test get_lowest_version()
  **/
  function test_get_lowest_version() {
    assertEquals("5.2.0", CodeVersionInformation.get_lowest_version(["5.2.0"]));
    assertEquals("5.1.0", CodeVersionInformation.get_lowest_version(["5.1.0", "5.2.0"]));
    assertEquals("4", CodeVersionInformation.get_lowest_version(["4", "4.1", "5"]));
    assertEquals("4.0.6", CodeVersionInformation.get_lowest_version(["4.0.6", "5"]));
  }

  /**
    Test get_version_lower_than()
  **/
  function testGetVersionLowerThan() {
    assertEquals(null, CodeVersionInformation.get_version_lower_than("PHP 5"));
    assertEquals(null, CodeVersionInformation.get_version_lower_than("PHP 5 &gt;= 5.2.0"));
    assertEquals("4.0.4", CodeVersionInformation.get_version_lower_than("PHP 4 &lt;= 4.0.4"));
  }

  /**
    Test instantiating a CodeVersionInformation object
  **/
  function test_create() {
    var valid_results = [
      new Result(ResultType.Function, "one", "PHP 4, PHP 5"),
      new Result(ResultType.Function, "two", "PHP 4 &gt;= 4.0.6, PHP 5"),
    ];
    var v = new CodeVersionInformation(valid_results);

    assertEquals("4.0.6", v.minimum_versions.get("PHP"));

    Result.change_enabled(valid_results, "two", false);

    v = new CodeVersionInformation(valid_results);
    assertEquals("4", v.minimum_versions.get("PHP"));
  }

  /**
    Test split_version_string()
  **/
  function test_get_version_string_split() {
    assertEquals("{xmlwriter => 2.0.4, PHP => 4}", CodeVersionInformation.split_version_string("PHP 4, xmlwriter 2.0.4").toString());
    assertEquals("{xmlwriter => 2.0.4, PHP => 4.0.3}", CodeVersionInformation.split_version_string("PHP 4 &gt;= 4.0.3, xmlwriter 2.0.4").toString());
    assertEquals("{PHP => 4}", CodeVersionInformation.split_version_string("PHP 5, PHP 4").toString());
  }

  /**
    Test getting module information
  **/
  function test_get_module_information() {
    var valid_results = [
      new Result(ResultType.Function, "one", "PHP 4, zmod 5"),
      new Result(ResultType.Function, "two", "PHP 4 &gt;= 4.0.6, xmod 5"),
    ];
    var v = new CodeVersionInformation(valid_results);

    assertEquals("[PHP, xmod, zmod]", v.all_modules.toString());
  }

  /**
    Test ignoring modules
  **/
  function test_ignore_modules() {
    var valid_results = [
      new Result(ResultType.Function, "one", "PHP 4, zmod 5"),
      new Result(ResultType.Function, "two", "PHP 4 &gt;= 4.0.6, xmod 5"),
      new Result(ResultType.Function, "three", "zmod 5"),
    ];
    var ignored_modules = new Hash<Bool>();
    ignored_modules.set("xmod", true);
    var v = new CodeVersionInformation(valid_results, ignored_modules);

    assertEquals("[PHP, zmod]", v.all_modules.toString());
  }

  /**
    Test module name sorting
  **/
  function test_module_name_sorting() {
    var module_names = [ "zmod", "xmod", "PHP" ];

    module_names.sort(CodeVersionInformation.module_name_sorter);

    assertEquals("[PHP, xmod, zmod]", module_names.toString());
  }
}