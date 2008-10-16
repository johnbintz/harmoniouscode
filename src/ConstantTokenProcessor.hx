class ConstantTokenProcessor extends TokenProcessor {
  override public function get_default_token_type() { return ConstantToken; }

  public static var source_path : String = "../data";
  public static var source_file_pattern : EReg = ~/phpdoc_constants_.*\.xml/;
  public static var version_match = ~/since php ([0-9\.]+)/i;
  public static var node_skip_information = [
    [ "para", "variablelist" ],
    [ "section", "para" ],
    [ "section", "table" ],
    [ "para", "table" ],
    [ "para", "informaltable" ],
    [ "para", "itemizedlist" ],
    [ "section", "variablelist" ]
  ];

  #if neko
    public override function populate_from_file() {
      this.tokenHash = new Hash<Token>();
      for (file in neko.FileSystem.readDirectory(source_path)) {
        if (source_file_pattern.match(file)) {
          trace(file + ": " + this.append_from_string(neko.io.File.getContent(source_path + "/" + file)));
        }
      }
    }

    public function append_from_string(s : String) : String {
      var type = "none";
      for (child in Xml.parse(s).firstElement()) {
        if (child.nodeType == Xml.Element) {
          var any_skipped;
          do {
            any_skipped = false;
            for (nodes_to_skip in node_skip_information) {
              if (child.nodeName == nodes_to_skip[0]) {
                for (subchild in child) {
                  if (subchild.nodeType == Xml.Element) {
                    if (subchild.nodeName == nodes_to_skip[1]) {
                      child = subchild;
                      any_skipped = true;
                      break;
                    }
                  }
                }
              }
            }
          } while (any_skipped == true);

          // itemizedlist
          if (child.nodeName == "itemizedlist") {
            type = "itemizedlist";
            var fast_child = new haxe.xml.Fast(child);
            if (fast_child.hasNode.listitem) {
              for (item in fast_child.nodes.listitem) {
                if (item.hasNode.simpara) {
                  var token_name : String = null;
                  var token_version : String = "4";
                  for (simpara in item.nodes.simpara) {
                    if (simpara.hasNode.constant) {
                      try {
                        token_name = simpara.node.constant.innerData;
                      } catch (e : Dynamic) {}
                    }
                    try {
                      var description_string = simpara.innerHTML;
                      if (version_match.match(description_string)) {
                        token_version = ~/\.$/.replace(version_match.matched(1), "");
                      }
                    } catch (e : Dynamic) {}
                  }
                  if (token_name != null) {
                    this.tokenHash.set(token_name, new ConstantToken(token_name, "PHP " + token_version));
                  }
                }
              }
            }
          }
          
          // variablelist
          if (child.nodeName == "variablelist") {
            type = "variablelist";
            for (variable in child) {
              if (variable.nodeType == Xml.Element) {
                var token_name : String = null;
                var token_version : String = "4";
                var fast_variable = new haxe.xml.Fast(variable);
                if (fast_variable.hasNode.term) {
                  var term_variable = fast_variable.node.term;
                  if (term_variable.hasNode.constant) {
                    try {
                      token_name = term_variable.node.constant.innerData;
                    } catch (e : Dynamic) {}
                  }
                }
                if (fast_variable.hasNode.listitem) {
                  var listitem_variable = fast_variable.node.listitem;
                  if (listitem_variable.hasNode.simpara) {
                    try {
                      var description_string = listitem_variable.node.simpara.innerData;
                      if (version_match.match(description_string)) {
                        token_version = ~/\.$/.replace(version_match.matched(1), "");
                      }
                    } catch (e : Dynamic) {}
                  }
                }

                if (token_name != null) {
                  this.tokenHash.set(token_name, new ConstantToken(token_name, "PHP " + token_version));
                }
              }
            }
          }

          // table
          if ((child.nodeName == "table") || (child.nodeName == "informaltable")) {
            type = "table";

            var node_drilldown = [ "tgroup" ];
            for (node_name in node_drilldown) {
              for (node in child) {
                if (node.nodeType == Xml.Element) {
                  if (node.nodeName == node_name) {
                    child = node; break;
                  }
                }
              }
            }

            var fast_child = new haxe.xml.Fast(child);
            if (fast_child.hasNode.tbody) {
              if (fast_child.node.tbody.hasNode.row) {
                for (row in fast_child.node.tbody.nodes.row) {
                  var token_name : String = null;
                  var token_version : String = "4";
                  if (row.hasNode.entry) {
                    for (entry in row.nodes.entry) {
                      if (entry.hasNode.constant) {
                        try {
                          token_name = entry.node.constant.innerData;
                        } catch (e : Dynamic) {}
                      } else {
                        try {
                          var description_string = entry.innerHTML;
                          if (version_match.match(description_string)) {
                            token_version = ~/\.$/.replace(version_match.matched(1), "");
                          }
                        } catch (e : Dynamic) {}
                      }
                    }
                  }
                  if (token_name != null) {
                    this.tokenHash.set(token_name, new ConstantToken(token_name, "PHP " + token_version));
                  }
                }
              }
            }
          }
        }
      }
      return type;
    }

    public function populate_from_string(s : String) {
      this.tokenHash = new Hash<Token>();
      this.append_from_string(s);
    }
  #end
}