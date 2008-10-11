class CodeVersionInformation {
  public var final_versions : Hash<Hash<String>>;
  public var minimum_versions : Hash<String>;
  public var maximum_versions : Hash<String>;
  public var all_modules : Array<String>;

  public static function breakdown_version_number(version : String) {
    return version.split(".");
  }

  public static function get_version_lower_than(s : String) : String {
    var greater_than = ~/\&lt;= (.*)$/;

    if (greater_than.match(s)) {
      return greater_than.matched(1);
    }
    return null;
  }

  public static function breakdown_php_version_string(s : String) {
    var parts = new Array<String>();

    for (regexp in [ ~/^([^\ ]*) (.*)$/ ]) {
      if (regexp.match(s)) {
        var version = regexp.matched(2).split("-").shift();

        var greater_than = ~/\&gt;= (.*)$/;
        if (greater_than.match(version)) {
          version = greater_than.matched(1);
        }

        parts.push(regexp.matched(1));
        parts.push(version);
        break;
      }
    }

    return parts;
  }

  public static function get_highest_version(versions : Array<String>) : String {
    return get_terminal_version(versions, true);
  }

  public static function get_lowest_version(versions : Array<String>) : String {
    return get_terminal_version(versions, false);
  }

  public static function version_compare(one : String, two : String) {
    var one_parts = one.split(".");
    var two_parts = two.split(".");
    var shortest = Math.floor(Math.min(one_parts.length, two_parts.length));
    for (i in 0...shortest) {
      var one_int = Std.parseInt(one_parts[i]);
      var two_int = Std.parseInt(two_parts[i]);
      if (one_int != two_int) {
        return (one_int < two_int) ? -1 : 1;
      }
    }
    if (one_parts.length < two_parts.length) { return -1; }
    if (one_parts.length > two_parts.length) { return 1; }
    return 0;
  }

  private static function get_terminal_version(versions : Array<String>, ?find_highest : Bool = true) : String {
    var terminal_version = null;

    for (version in versions) {
      if (terminal_version == null) {
        terminal_version = version;
      } else {
        switch (version_compare(terminal_version, version)) {
          case -1:
            terminal_version = (find_highest) ? version : terminal_version;
          case 1:
            terminal_version = (find_highest) ? terminal_version : version;
        }
      }
    }

    if (terminal_version != null) {
      return terminal_version;
    } else {
      return null;
    }
  }

  private static function merge_versions(target_hash : Hash<Array<String>>,
                                         source_hash : Hash<Array<String>>,
                                         is_lower : Bool) : Hash<Array<String>> {
    for (source in source_hash.keys()) {
      if (!target_hash.exists(source)) { target_hash.set(source, new Array<String>()); }
      var version_info = target_hash.get(source);
      if (is_lower) {
        version_info.push(get_lowest_version(source_hash.get(source)));
      } else {
        version_info.push(get_highest_version(source_hash.get(source)));
      }
      target_hash.set(source, version_info);
    }

    return target_hash;
  }

  public static function split_version_string(s : String) : Hash<String> {
    var version_lists = new Hash<Array<String>>();
    var version_match = ~/^([^\ ]+) (.*)$/;
    for (part in s.split(", ")) {
      var parts = breakdown_php_version_string(part);
      var source = parts[0];
      if (!version_lists.exists(source)) {
        version_lists.set(source, new Array<String>());
      }
      var tmp = version_lists.get(source);
      tmp.push(parts[1]);
      version_lists.set(source, tmp);
    }

    var final_versions = new Hash<String>();
    for (source in version_lists.keys()) {
      final_versions.set(source, CodeVersionInformation.get_lowest_version(version_lists.get(source)));
    }
    return final_versions;
  }

  public function new(results : Array<Result>, ?ignored_modules : Hash<Bool>) {
    var start_minimum_versions = new Hash<Array<String>>();
    var start_maximum_versions = new Hash<Array<String>>();

    for (result in results) {
      if (result.is_enabled) {
        var internal_minimum_version = new Hash<Array<String>>();
        var internal_maximum_version = new Hash<Array<String>>();

        for (part in result.version.split(", ")) {
          var version_string_info = breakdown_php_version_string(part);
          if (version_string_info.length > 0) {
            var source = version_string_info[0];

            var ok_to_use = true;
            if (ignored_modules != null) {
              ok_to_use = !ignored_modules.exists(source);
            }

            if (ok_to_use) {
              if (!internal_minimum_version.exists(source)) {
                internal_minimum_version.set(source, new Array<String>());
              }
              var version_info = internal_minimum_version.get(source);
              version_info.push(version_string_info[1]);
              internal_minimum_version.set(source, version_info);

              var is_lower_than = get_version_lower_than(part);
              if (is_lower_than != null) {
                if (!internal_maximum_version.exists(source)) {
                  internal_maximum_version.set(source, new Array<String>());
                }

                var versions = internal_maximum_version.get(source);
                versions.push(is_lower_than);
                internal_maximum_version.set(source, versions);
              }
            }
          }
        }

        merge_versions(start_minimum_versions, internal_minimum_version, true);
        merge_versions(start_maximum_versions, internal_maximum_version, false);
      }
    }

    this.minimum_versions = new Hash<String>();
    this.maximum_versions = new Hash<String>();
    this.all_modules      = new Array<String>();

    for (source in start_minimum_versions.keys()) {
      this.minimum_versions.set(source, get_highest_version(start_minimum_versions.get(source)));
      this.all_modules.push(source);
    }

    this.all_modules.sort(CodeVersionInformation.module_name_sorter);

    for (source in start_maximum_versions.keys()) {
      this.maximum_versions.set(source, get_lowest_version(start_maximum_versions.get(source)));
    }

    this.final_versions = new Hash<Hash<String>>();

    this.final_versions.set("minimum", minimum_versions);
    this.final_versions.set("maximum", maximum_versions);
  }

  /**
    Return true if the minimum and maximum module versions within this
    CodeVersionInformation object will produce runnable code.
  **/
  public function is_valid() {
    for (source in this.maximum_versions.keys()) {
      var versions = [ this.maximum_versions.get(source), this.minimum_versions.get(source) ];

      if (get_highest_version(versions) == this.minimum_versions.get(source)) {
        return false;
      }
    }
    return true;
  }

  /**
    Sort module names, making sure PHP is first in the list.
  **/
  public static function module_name_sorter(a : String, b : String) : Int {
    if (a.toLowerCase() == "php") { return -1; }
    if (b.toLowerCase() == "php") { return 1; }
    if (a == b) { return 0; }
    return (a < b) ? -1 : 1;
  }
}