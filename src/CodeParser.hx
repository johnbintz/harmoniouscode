class CodeParser {
  public var tokenProcessors(getTokenProcessors, null) : Hash<TokenProcessor>;

  public function new() {
    this.tokenProcessors = new Hash<TokenProcessor>();
  }

  #if neko
    public function loadProcessorsFromDisk() {
      var functionProcessor = new FunctionTokenProcessor();
      if (!functionProcessor.load_from_cache()) {
        functionProcessor.populate_from_file();
        functionProcessor.save_to_cache();
      }

      this.tokenProcessors.set(Type.getClassName(Type.getClass(functionProcessor)), functionProcessor);
    }
  #end

  public function loadProcessorsFromResources() {
    var functionProcessor = new FunctionTokenProcessor();
    functionProcessor.load_from_resource();

    this.tokenProcessors.set(Type.getClassName(Type.getClass(functionProcessor)), functionProcessor);
  }

  public function getTokenProcessors() { return this.tokenProcessors; }

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

    var function_token_processor = this.tokenProcessors.get("FunctionTokenProcessor");

    var function_tokens_found = new Hash<Bool>();
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

          if (!flattened_tokens.exists(token)) {
            if (is_function) {
              if (!function_tokens_found.exists(token)) {
                if (function_token_processor.tokenHash.exists(token)) {
                  results.push(function_token_processor.tokenHash.get(token).toResult());
                }
                function_tokens_found.set(token, true);
              }
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
                    tokens_to_ignore_hash.set(token, true);
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

    results.sort(Result.compare);

    return results;
  }
}