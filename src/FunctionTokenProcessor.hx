class FunctionTokenProcessor extends TokenProcessor {
  public static var cachePath : String = "../data/functions_tokens_cache.hxd";
  override public function get_cache_path() { return FunctionTokenProcessor.cachePath; }
  public static var sourcePath : String = "../data/versions.xml";

  #if neko
    public function populate_from_file() {
      this.populate_from_string(neko.io.File.getContent(sourcePath));
    }

    public function populate_from_string(s : String) {
      this.tokenHash = new Hash<Token>();
      for (child in Xml.parse(s).firstElement()) {
        if (child.nodeType == Xml.Element) {
          if (child.nodeName == "function") {
            var version = child.get("from");
            version = ~/PECL /.replace(version, "");
            version = ~/\:/.replace(version, " ");
            var token = child.get("name");
            this.tokenHash.set(token, new FunctionToken(child.get("name"), version));
          }
        }
      }
    }
  #end
}