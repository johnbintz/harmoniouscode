/**
  The Neko command line interface to Harmonious Code. This is *far* from complete, but
  can, at the moment, function as a very simple way to integrate a version check into
  a build or test script.
**/
class CommandLineInterface {
  #if neko
    static public function main() {
      var arguments = neko.Sys.args();

      var usage_string = "Usage: ./command_line.sh [ --php-version <version> ] [ --file ] <filename>\n";

      if (arguments.length > 0) {
        var mapped_arguments = parse_arguments(arguments);

        if (!mapped_arguments.exists("file")) {
          neko.Lib.print(usage_string);
          neko.Sys.exit(1);
        }

        var filepath = mapped_arguments.get("file");
        if (!neko.FileSystem.exists(filepath)) {
          neko.Lib.print("The specified file does not exist: " + filepath + "\n");
          neko.Sys.exit(1);
        }

        var code = neko.io.File.getContent(filepath);

        var parser = new CodeParser();
        parser.load_processors_from_resources();

        var results = parser.parse(code);

        if (results.length == 0) {
          neko.Lib.print("Your code didn't have any tokens in it!");
          neko.Sys.exit(0);
        }

        var ignored_modules = parser.ignored_modules;
        var ignored_tokens_in_modules = parser.ignored_tokens_in_modules;

        var version_info = new CodeVersionInformation(results, ignored_modules, ignored_tokens_in_modules);

        neko.Lib.print("Your code in " + arguments[0] + " requires the following minimum PHP & PECL module versions:\n");

        var minimum = version_info.final_versions.get("minimum");

        for (module in minimum.keys()) {
          neko.Lib.print("* " + module + ": " + minimum.get(module) + "\n");
        }

        var maximum = version_info.final_versions.get("maximum");
        var printed_message = false;

        for (module in maximum.keys()) {
          if (!printed_message) {
            neko.Lib.print("Your code also can't use PHP or PECL modules newer than:\n");
            printed_message = true;
          }
          neko.Lib.print("* " + module + ": " + maximum.get(module) + "\n");

          if (!version_info.is_valid()) {
            neko.Lib.print("This code may not run!\n");
            neko.Sys.exit(1);
          }
        }

        if (mapped_arguments.exists("php-version")) {
          var minimum_specified_php_version = mapped_arguments.get("php-version");
          if (CodeVersionInformation.version_compare(minimum_specified_php_version, minimum.get("PHP")) == -1) {
            neko.Lib.print("Your code requires a version higher than the minimum version you specified, " + minimum_specified_php_version + "!\n");
            neko.Sys.exit(1);
          }
        }

        neko.Sys.exit(0);
      }
      neko.Lib.print(usage_string);
      neko.Sys.exit(1);
    }
  #end

  /**
    Parse a series of arguments fed via the command line.
  **/
  public static function parse_arguments(arguments : Array<String>) : Hash<String> {
    var mapped_arguments = new Hash<String>();

    var capturable_options = [ "file", "php-version" ];
    var valid_options_hash = new Hash<Bool>();

    for (option in capturable_options) {
      valid_options_hash.set(option, true);
    }

    var current_option : String = null;
    for (argument in arguments) {
      if (argument.indexOf("--") == 0) {
        var option = argument.substr(2);
        if (valid_options_hash.exists(option)) {
          if (valid_options_hash.get(option)) {
            current_option = option;
          } else {
            mapped_arguments.set(option, "true");
          }
        }
      } else {
        if (current_option != null) {
          mapped_arguments.set(current_option, argument);
          current_option = null;
        } else {
          mapped_arguments.set("file", argument);
        }
      }
    }

    return mapped_arguments;
  }
}