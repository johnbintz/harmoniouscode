class ConstantTokenProcessor extends TokenProcessor {
  public static var cachePath : String = "constant_tokens_cache.hxd";
  override public function get_cache_path() { return ConstantTokenProcessor.cachePath; }

  #if neko
    public function populate_from_file(path : String) {
      this.populate_from_string(neko.io.File.getContent(path));
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