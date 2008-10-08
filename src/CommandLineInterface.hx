class CommandLineInterface {
  static public function main() {
    var arguments = neko.Sys.args();

    if (arguments.length > 0) {
      if (neko.FileSystem.exists(arguments[0])) {
        var code = neko.io.File.getContent(arguments[0]);

        var parser = new CodeParser();
        parser.loadProcessorsFromDisk();

        var results = parser.parse(code);

        var version_info = new CodeVersionInformation(results);

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
          }
        }
      }
    }
  }
}