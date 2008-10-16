import FunctionTokenProcessor;
import ConstantTokenProcessor;

class TokenProcessor {
  public var tokenHash : Hash<Token>;
  public static var cache_path : String = "../data/all_tokens.hxd";

  public function new() { this.tokenHash = new Hash<Token>(); }
  public function get_default_token_type() { return Token; }

  public static var all_token_processors = [ "FunctionTokenProcessor", "ConstantTokenProcessor" ];

  #if neko
    public static function load_all_from_cache() : Array<TokenProcessor> {
      if (neko.FileSystem.exists(cache_path)) {
        return unnormalize_processors(haxe.Unserializer.run(neko.io.File.getContent(cache_path)));
      } else {
        return null;
      }
    }

    public static function save_all_to_cache() {
      if (!neko.FileSystem.exists(cache_path)) {
        var all_processors = new Array<TokenProcessor>();
        for (processor_class in all_token_processors) {
          var processor : TokenProcessor = Type.createInstance(Type.resolveClass(processor_class), []);
          processor.populate_from_file();
          all_processors.push(processor);
        }

        var fh = neko.io.File.write(cache_path, true);
        fh.writeString(haxe.Serializer.run(normalize_processors(all_processors)));
        fh.close();
      }
    }

    public function populate_from_file() {}
  #end

  public static function load_all_from_resource() {
    return unnormalize_processors(haxe.Unserializer.run(haxe.Resource.getString(cache_path)));
  }

  public static function normalize_processors(processors : Array<TokenProcessor>) : Hash<Hash<Dynamic>> {
    if (processors.length == 0) { throw "no processors specified"; }
    var normalized_data = new Hash<Hash<Dynamic>>();

    var types = new Hash<String>();
    var all_versions_with_index = new Hash<Int>();

    var version_index = 0;
    for (i in 0...processors.length) {
      var i_string = Std.string(i);
      var tokens_with_version_index = new Hash<Int>();
      types.set(i_string, Type.getClassName(Type.getClass(processors[i])));
      for (token in processors[i].tokenHash.keys()) {
        var version = processors[i].tokenHash.get(token).version;
        if (!all_versions_with_index.exists(version)) {
          all_versions_with_index.set(version, version_index);
          version_index++;
        }
        tokens_with_version_index.set(token, all_versions_with_index.get(version));
      }

      normalized_data.set("processor-" + i_string, tokens_with_version_index);
    }

    trace("Unique version strings: " + version_index);

    var flipped_versions = new Hash<String>();
    for (version in all_versions_with_index.keys()) {
      flipped_versions.set(Std.string(all_versions_with_index.get(version)), version);
    }

    normalized_data.set("versions", flipped_versions);
    normalized_data.set("types", types);

    return normalized_data;
  }

  public static function unnormalize_processors(normalized_data : Hash<Hash<Dynamic>>) : Array<TokenProcessor> {
    var unnormalized_processors = new Array<TokenProcessor>();

    if (!normalized_data.exists("versions")) { throw "versions not defined"; }
    if (!normalized_data.exists("types")) { throw "types not defined"; }

    var versions = normalized_data.get("versions");
    var types = normalized_data.get("types");

    for (type_key in types.keys()) {
      var i = Std.parseInt(type_key);
      var processor : TokenProcessor = Type.createInstance(Type.resolveClass(types.get(type_key)), []);

      var processor_key = "processor-" + type_key;
      if (!normalized_data.exists(processor_key)) { throw "processor " + type_key + " not defined"; }

      var processor_tokens = normalized_data.get(processor_key);
      var token_type = processor.get_default_token_type();
      for (token in processor_tokens.keys()) {
        var version_lookup = Std.string(processor_tokens.get(token));
        processor.tokenHash.set(token, Type.createInstance(token_type, [token, versions.get(version_lookup)]));
      }

      unnormalized_processors.push(processor);
    }

    return unnormalized_processors;
  }
}