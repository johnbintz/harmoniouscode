class TestTokenProcessor extends haxe.unit.TestCase {
  function testSerializeMultipleProcessors() {
    var token_processor_one = new TokenProcessor();
    token_processor_one.token_hash.set("one", new Token("one", "version one"));
    token_processor_one.token_hash.set("two", new Token("two", "version one"));
    token_processor_one.token_hash.set("three", new Token("three", "version two"));

    var token_processor_two = new TokenProcessor();
    token_processor_two.token_hash.set("four", new Token("four", "version one"));
    token_processor_two.token_hash.set("five", new Token("five", "version two"));
    token_processor_two.token_hash.set("six", new Token("six", "version three"));

    var normalized_data = TokenProcessor.normalize_processors([token_processor_one, token_processor_two]);

    assertTrue(normalized_data.exists("types"));
    assertEquals("{0 => TokenProcessor, 1 => TokenProcessor}", normalized_data.get("types").toString());

    assertTrue(normalized_data.exists("versions"));
    assertEquals("{version one => 0, version two => 1, version three => 2}".length, normalized_data.get("versions").toString().length);

    assertTrue(normalized_data.exists("processor-0"));
    assertTrue(normalized_data.exists("processor-1"));

    var trap_invalid = true;
    try {
      TokenProcessor.unnormalize_processors(new Hash<Hash<Dynamic>>());
      trap_invalid = false;
    } catch (e : Dynamic) {}
    assertTrue(trap_invalid);

    var unnormalized_processors = TokenProcessor.unnormalize_processors(normalized_data);

    assertTrue(unnormalized_processors.length == 2);
  }
}