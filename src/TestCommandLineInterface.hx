import CommandLineInterface;

class TestCommandLineInterface extends haxe.unit.TestCase {
  function testOptionParsing() {
    var options = [
      [ [ "meow.php" ], "{file => meow.php}" ],
      [ [ "--file", "meow.php" ], "{file => meow.php}" ],
      [ [ "--php-version", "5.2.0", "meow.php" ], "{php-version => 5.2.0, file => meow.php}" ]
    ];

    for (option in options) {
      var arguments : Array<String> = option[0];
      var expected_result : String = option[1];
      assertEquals(expected_result.length, CommandLineInterface.parse_arguments(arguments).toString().length);
    }
  }
}