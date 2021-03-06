import FunctionTokenProcessor;
import ConstantTokenProcessor;
import FunctionToken;
import ConstantToken;

/**
  The JavaScript functionality of Harmonious Code.
**/
class JavaScriptTarget {
  static public var code_parser : CodeParser;
  static public var current_results : Array<Result>;
  static public var show_only_modules : Hash<Bool>;
  static public var ignored_modules : Hash<Bool>;
  static public var ignored_tokens_in_modules : Hash<Hash<Bool>>;
  static public var manually_ignored_modules : Hash<Bool>;

  static public function main() {
    code_parser = new CodeParser();
    code_parser.load_processors_from_resources();

    show_only_modules         = new Hash<Bool>();
    ignored_modules           = new Hash<Bool>();
    ignored_tokens_in_modules = new Hash<Hash<Bool>>();
    manually_ignored_modules  = new Hash<Bool>();

    #if js
      var loading_div = js.Lib.document.getElementById("loading");
      var form_div = js.Lib.document.getElementById("form");

      loading_div.style.display = "none";
      form_div.style.display = "";

      var source = js.Lib.document.getElementById("source");
      untyped {
        if (source.value != "") {
          source.style.backgroundImage = "none";
        } else {
            source.onclick = function(e) { source.style.backgroundImage = "none"; }
        }
      }
    #end
  }

  /**
    Parse a String and get the token results and ignored modules.
  **/
  static public function get_results(s : String) {
    current_results = code_parser.parse(s);
    ignored_modules = code_parser.ignored_modules;
    ignored_tokens_in_modules = code_parser.ignored_tokens_in_modules;
    manually_ignored_modules = new Hash<Bool>();
  }

  /**
    Enable/disable a particular Result from the version calculations.
  **/
  static public function change_result(index_id : Int, state : Bool) : Bool {
    if (index_id < current_results.length) {
      current_results[index_id].is_enabled = state;
      return true;
    }
    return false;
  }

  /**
    Toggle the visibility of module functions.
  **/
  static public function toggle_module(module : String) {
    if (!show_only_modules.exists(module)) {
      show_only_modules.set(module, false);
    }
    show_only_modules.set(module, !show_only_modules.get(module));
  }

  /**
    Set the ignore state on a module.
  **/
  static public function change_module_ignore(module : String, state : Bool) {
    manually_ignored_modules.set(module, state);
  }

  /**
    Toggle ignoring a module.
  **/
  static public function toggle_ignore_module(module : String) {
    if (!manually_ignored_modules.exists(module)) {
      manually_ignored_modules.set(module, false);
    }
    manually_ignored_modules.set(module, !manually_ignored_modules.get(module));
  }

  #if js
    /**
      Display code version information.
    **/
    static public function display_version_information() {
      var output : String;
      var ignored_tokens        = new Array<String>();
      var ignored_modules_array = new Array<String>();

      if (current_results.length == 0) {
        output = "<div id=\"code-announcement\">Your code doesn't have any tokens in it!</div>";
      } else {
        var version_info = new CodeVersionInformation(current_results, ignored_modules, ignored_tokens_in_modules);

        output = "<div id=\"code-announcement\">Your code requires the following minimum PHP & PECL module versions:</div>";

        var minimum = version_info.final_versions.get("minimum");

        output += "<form action=\"\" onsubmit=\"return false\">";

        // module list
        var all_modules_hash = new Hash<Bool>();

        for (module in minimum.keys()) { all_modules_hash.set(module, true); }
        for (module in ignored_modules.keys()) { all_modules_hash.set(module, true); }
        for (module in manually_ignored_modules.keys()) { all_modules_hash.set(module, true); }

        var all_modules = new Array<String>();

        for (module in all_modules_hash.keys()) { all_modules.push(module); }

        all_modules.sort(CodeVersionInformation.module_name_sorter);

        for (module in manually_ignored_modules.keys()) {
          if (manually_ignored_modules.get(module) == true) {
            ignored_modules_array.push("@" + module);
          }
        }

        output += "<table cellspacing=\"0\" id=\"modules\">";
        output += "<tr><th>Module</th><th>Ignore?</th><th>Version</th></tr>";

        for (module in all_modules) {
          var is_ignored = false;
          var is_ignored_in_source = false;
          var show_checkbox = true;
          var is_checked = false;

          if (ignored_modules.exists(module) == true) {
            is_ignored = true;
            is_ignored_in_source = true;
            show_checkbox = false;
          }
          if (manually_ignored_modules.get(module) == true) {
            is_ignored = true;
            is_checked = true;
          }

          output += "<tr class=\"" + (is_ignored ? "disabled" : "enabled") + "\"><td class=\"module\">" + module + "</td>";

          if (show_checkbox && (module.toLowerCase() != "php")) {
            output += "<td align=\"center\"><input type=\"checkbox\" name=\"ignore-module-" + module + "\" id=\"ignore-module-" + module + "\" onclick=\"JavaScriptTarget.toggle_ignore_module_and_redraw('" + module + "')\" " + (is_checked ? " checked" : "") + "/></td>";
          } else {
            output += "<td>&nbsp;</td>";
          }

          if (is_ignored) {
            if (is_ignored_in_source) {
              output += "<td>(ignored in source)</td>";
            } else {
              output += "<td>(ignored)</td>";
            }
          } else {
            if (minimum.exists(module)) {
              output += "<td>" + minimum.get(module) + "</td>";
            } else {
              output += "<td>&nbsp;</td>";
            }
          }

          output += "</tr>";
        }

        output += "</table>";

        // maximum version info
        var maximum = version_info.final_versions.get("maximum");
        var printed_message = false;

        for (module in maximum.keys()) {
          if (!printed_message) {
            output += "Your code also can't use PHP or PECL modules newer than:<ul>";
            printed_message = true;
          }
          output += ("<li>" + module + ": " + maximum.get(module) + "</li>");
        }

        if (printed_message) { output += "</ul>"; }

        if (!version_info.is_valid()) {
          output += "<p><strong>This code may not run!</strong></p>";
        }

        // tokens list
        output += "<table cellspacing=\"0\" id=\"results-list\">";

        output += "<tr><th>Token</th><th>Ignore?</th>";

        for (module in version_info.all_modules) {
          var classes = ["filter"];
          if (show_only_modules.exists(module)) {
            if (show_only_modules.get(module)) {
              classes.push("is-filtering");
            }
          }

          if (manually_ignored_modules.get(module) != true) {
            output += "<th title=\"click to toggle filter\" class=\"" + classes.join(" ") + "\" onclick=\"JavaScriptTarget.toggle_module_and_redraw('" + module + "')\">" + module + "</th>";
          }
        }

        output += "</tr>";

        var id_index = 0;
        for (result in current_results) {
          var ok_to_show = true;
          var modules_check_out = true;
          var any_visible_modules = false;

          if (!result.is_enabled) { ignored_tokens.push(result.token); }

          var max_versions = CodeVersionInformation.split_version_string(result.version);

          for (module in show_only_modules.keys()) {
            if (show_only_modules.get(module)) {
              ok_to_show = false;
              if (!max_versions.exists(module)) { modules_check_out = false; }
            }
          }

          for (module in max_versions.keys()) {
            if (ignored_modules.exists(module)) {
              if (!ignored_modules.get(module)) { any_visible_modules = true; }
            } else {
              any_visible_modules = true;
            }
          }

          if (modules_check_out) { ok_to_show = true; }
          if (!any_visible_modules) { ok_to_show = false; }

          if (ok_to_show) {
            var result_class = (result.is_enabled ? "enabled" : "disabled");
            var result_id    = "result-" + id_index;
            var enabled_id   = "result-enabled-" + id_index;
            output += "<tr id=\"" + result_id + "\" class=\"" + result_class + "\">";

            output += "<td class=\"token\">" + result.token + "</td>";

            output += "<td align=\"center\"><input onclick=\"JavaScriptTarget.change_result_and_redraw(this)\" type=\"checkbox\" name=\"" + enabled_id + "\" id=\"" + enabled_id + "\""
            + ((!result.is_enabled) ? " checked" : "") + " /></td>";

            for (module in version_info.all_modules) {
              if (manually_ignored_modules.get(module) != true) {
                output += "<td>";
                if (max_versions.exists(module)) {
                  output += max_versions.get(module);
                } else {
                  output += "&nbsp;";
                }
                output += "</td>";
              }
            }

            output += "</tr>";
          }
          id_index++;
        }
        output += "</table>";

        output += "</form>";
      }

      // update the how-to-ignore information
      var permanent_ignore_div = js.Lib.document.getElementById("permanent-ignore");

      if ((ignored_modules_array.length > 0) || (ignored_tokens.length > 0)) {
        var ignored_modules_string = ignored_modules_array.join(" ");
        var ignored_tokens_string  = ignored_tokens.join(" ");

        var global_span = js.Lib.document.getElementById("ignore-code-holder-global");
        global_span.innerHTML = ignored_modules_string + " " + ignored_tokens_string;

        var permanent_ignore_block_li = js.Lib.document.getElementById("permanent-ignore-block");

        if (ignored_tokens.length > 0) {
          var block_span = js.Lib.document.getElementById("ignore-code-holder-block");
          block_span.innerHTML = ignored_tokens_string;

          permanent_ignore_block_li.style.display = "";
        } else {
          permanent_ignore_block_li.style.display = "none";
        }

        permanent_ignore_div.style.display = "";
      } else {
        permanent_ignore_div.style.display = "none";
      }

      js.Lib.document.getElementById('output').innerHTML = output;
    }

    /**
      Analyze the provided code and display the results.
    **/
    static public function do_analysis(textarea) {
      show_only_modules = new Hash<Bool>();

      js.Lib.document.getElementById('processing').innerHTML = "Analyzing code...";
      untyped {
        js.Lib.document.getElementById('analyze-code-button').disabled = true;
      }

      haxe.Timer.delay(function() {
        JavaScriptTarget.get_results(textarea.value);
        JavaScriptTarget.display_version_information();

        js.Lib.document.getElementById('processing').innerHTML = "";
        untyped {
          js.Lib.document.getElementById('analyze-code-button').disabled = false;
        }
      }, 100);
    }

    /**
      Toggle a token's visibility and redraw the page.
    **/
    static public function change_result_and_redraw(result_checkbox : Dynamic) {
      var index_id_search = ~/^result-enabled-([0-9]+)$/;
      if (index_id_search.match(result_checkbox.id)) {
        var index_id = Std.parseInt(index_id_search.matched(1));
        if (change_result(index_id, !result_checkbox.checked)) {
          display_version_information();
        }
      }
    }

    /**
      Toggle a module's visibiity and redraw the page.
    **/
    static public function toggle_module_and_redraw(module : String) {
      JavaScriptTarget.toggle_module(module);
      JavaScriptTarget.display_version_information();
    }

    /**
      Toggle a module's enabled/disabed status and redraw the page.
    **/
    static public function toggle_ignore_module_and_redraw(module : String) {
      JavaScriptTarget.toggle_ignore_module(module);
      JavaScriptTarget.display_version_information();
    }
  #end
}