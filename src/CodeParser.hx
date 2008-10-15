import FunctionTokenProcessor;
import ConstantTokenProcessor;

/**
  CodeParser parses a block of PHP code and returns information on the
  tokens it finds.
**/
class CodeParser {
  public var token_processors(get_token_processors, null) : Hash<TokenProcessor>;
  public var ignored_modules(get_ignored_modules, null) : Hash<Bool>;

  public static var processor_types = [ "FunctionTokenProcessor", "ConstantTokenProcessor" ];

  public function new() {
    this.token_processors = new Hash<TokenProcessor>();
    this.ignored_modules  = new Hash<Bool>();
  }

  #if neko
    /**
      Load all possible token processors from disk.
    **/
    public function load_processors_from_disk() {
      for (processor_type_name in processor_types) {
        var processor : TokenProcessor = Type.createInstance(Type.resolveClass(processor_type_name), []);

        if (!processor.load_from_cache()) {
          processor.populate_from_file();
          processor.save_to_cache();
        }

        this.token_processors.set(processor_type_name, processor);
      }
    }
  #end

  /**
    Load all possible token processors form haXe Resources.
  **/
  public function load_processors_from_resources() {
    for (processor_type_name in processor_types) {
      var processor : TokenProcessor = Type.createInstance(Type.resolveClass(processor_type_name), []);

      processor.load_from_resource();

      this.token_processors.set(processor_type_name, processor);
    }
  }

  public function get_token_processors() { return this.token_processors; }
  public function get_ignored_modules() { return this.ignored_modules; }

  private function flatten_tokens_to_ignore(tokens_to_ignore : Array<Hash<Bool>>) : Hash<Bool> {
    var flattened_tokens = new Hash<Bool>();
    for (token_hash in tokens_to_ignore) {
      for (token in token_hash.keys()) {
        flattened_tokens.set(token, true);
      }
    }
    return flattened_tokens;
  }

  public function parse(s : String) : Array<Result> {
    var results = new Array<Result>();
    this.ignored_modules = new Hash<Bool>();

    var tokens_found = new Hash<Bool>();
    var tokens_to_ignore = new Array<Hash<Bool>>();
    var flattened_tokens = new Hash<Bool>();

    var index = 0;
    var capture_index = null;
    var s_length = s.length;
    var is_capturing = false;

    var capturable_search = ~/[a-zA-Z0-9\_]/;
    var stoppable_search = ~/[a-zA-Z0-9\_\/]/;

    while (index < s_length) {
      var current = s.charAt(index);
      var is_capturable = capturable_search.match(current);

      if (is_capturable) {
        if (!is_capturing) {
          is_capturing = true;
          capture_index = index;
        }
      } else {
        if (is_capturing) {
          var token = s.substr(capture_index, index - capture_index);

          var is_function = false;
          var is_function_searching = true;
          var paren_search_index = index;

          do {
            var function_character = s.charAt(paren_search_index);
            if (function_character == "(") {
              is_function = true;
              is_function_searching = false;
              index = paren_search_index;
            } else {
              if (stoppable_search.match(function_character)) {
                is_function_searching = false;
                index = paren_search_index - 1;
              }
            }
            if (is_function_searching) {
              paren_search_index++;
              if (paren_search_index >= s_length) {
                is_function_searching = false;
              }
            }
          } while (is_function_searching);

          is_capturing = false;

          if (!tokens_found.exists(token)) {
            if (!flattened_tokens.exists(token)) {
              for (token_processor in this.token_processors.iterator()) {
                if (token_processor.tokenHash.exists(token)) {
                  results.push(token_processor.tokenHash.get(token).toResult()); break;
                }
              }
              tokens_found.set(token, true);
            }
          }
        } else {
          if (current == "/") {
            if (s.indexOf("//harmonious", index) == index) {
              var end_of_line = s.indexOf("\n", index);
              var ok_to_capture = false;
              if (end_of_line > index) { ok_to_capture = true; }
              if (end_of_line == -1) {
                ok_to_capture = true;
                end_of_line = s_length - 1;
              }
              if (ok_to_capture) {
                if (s.indexOf("//harmonious_end", index) == index) {
                  tokens_to_ignore.pop();
                } else {
                  var new_tokens_to_ignore = s.substr(index, end_of_line - index).split(" ");
                  new_tokens_to_ignore.shift();
                  var tokens_to_ignore_hash = new Hash<Bool>();
                  for (token in new_tokens_to_ignore) {
                    if (token.charAt(0) == "@") {
                      if (token.toLowerCase() != "@php") {
                        this.ignored_modules.set(token.substr(1), true);
                      }
                    } else {
                      tokens_to_ignore_hash.set(token, true);
                    }
                  }
                  tokens_to_ignore.push(tokens_to_ignore_hash);
                }
                flattened_tokens = flatten_tokens_to_ignore(tokens_to_ignore);
                index = end_of_line;
              }
            }
          }
        }
      }
      index++;
    }

    if (is_capturing) {
      var token = s.substr(capture_index, index - capture_index);

      for (token_processor in this.token_processors.iterator()) {
        if (token_processor.tokenHash.exists(token)) {
          results.push(token_processor.tokenHash.get(token).toResult()); break;
        }
      }
    }

    results.sort(Result.compare);

    return results;
  }
}