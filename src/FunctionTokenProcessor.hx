class FunctionTokenProcessor extends TokenProcessor {
  public static var source_path : String = "../data/phpdoc_function_versions.xml";
  override public function get_default_token_type() { return FunctionToken; }

  #if neko
    public override function populate_from_file() {
      this.populate_from_string(neko.io.File.getContent(source_path));
    }

    public function populate_from_string(s : String) {
      this.token_hash = new Hash<Token>();
      var tokens_parsed = 0;

      //
      // haXe XML parsing is slow, as it uses a custom XML parser...
      // ..so I'll my own custom XML parser for this particular data.
      //
      /*var start = Date.now();
      var first_element = Xml.parse(s).firstElement();
      var end = Date.now();
      trace(end.getTime() - start.getTime());
      for (child in first_element) {
        if (child.nodeType == Xml.Element) {
          if (child.nodeName == "function") {
            var version = child.get("from");
            version = ~/PECL /.replace(version, "");
            version = ~/\:/.replace(version, " ");
            var token = child.get("name");
            this.token_hash.set(token, new FunctionToken(child.get("name"), version));
            tokens_parsed++;
          }
        }
      }*/

      var s_length = s.length;
      var i = 0;

      var version_regexp = ~/from=\'([^\']*)\'/i;
      var token_regexp   = ~/name=\'([^\']*)\'/i;

      var version_clean_regexps = [
        function(s) { return ~/PECL /.replace(s, ""); },
        function(s) { return ~/\:/.replace(s, " "); },
        function(s) { return ~/\, /.replace(s, ","); }
      ];

      while (i < s_length) {
        var new_i = s.indexOf("<function", i);
        if (new_i != -1) {
          var tag_end = s.indexOf(">", new_i);
          if (tag_end != -1) {
            var tag = s.substr(new_i, tag_end - new_i + 1);

            if (version_regexp.match(tag) && token_regexp.match(tag)) {
              var version = version_regexp.matched(1);
              var token   = token_regexp.matched(1);
              for (rf in version_clean_regexps) { version = rf(version); }

              this.token_hash.set(token, new FunctionToken(token, version));
              tokens_parsed++;
              i = tag_end;
            } else {
              i++;
            }
          } else {
            break;
          }
        } else {
          break;
        }
      }
    }
  #end
}