class TestResult extends haxe.unit.TestCase {
  function testInstantiateResult() {
    var result = new Result(ResultType.Function, "test", "5.2");
    assertEquals(ResultType.Function, result.type);
    assertEquals("test",              result.token);
    assertEquals("5.2",               result.version);
    assertEquals(true,                result.is_enabled);
  }

  function testResultArraySort() {
    var result_array = [
      new Result(ResultType.Function, "dog", "4"),
      new Result(ResultType.Function, "cat", "4"),
    ];

    assertEquals("dog", result_array[0].token);

    result_array.sort(Result.compare);

    assertEquals("cat", result_array[0].token);
  }
}