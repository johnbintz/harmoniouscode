class RegenerateDataFiles {
  public static function main() {
    var functionProcessor = new FunctionTokenProcessor();
    if (!functionProcessor.load_from_cache()) {
      neko.Lib.print("Regenerating functions cache...\n");
      functionProcessor.populate_from_file();
      functionProcessor.save_to_cache();
    }

    var constantProcessor = new ConstantTokenProcessor();
    if (!constantProcessor.load_from_cache()) {
      neko.Lib.print("Regenerating constants cache...\n");
    }
  }
}