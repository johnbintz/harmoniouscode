class TokenProcessor {
  public var tokenHash : Hash<Token>;
  public static var cachePath : String = null;

  public function new() { this.tokenHash = new Hash<Token>(); }
  public function get_cache_path() { return TokenProcessor.cachePath; }
  public function get_default_token_type() { return Token; }

  #if neko
    public function load_from_cache() : Bool {
      if (neko.FileSystem.exists(this.get_cache_path())) {
        this.populate_from_unwound_tokens(haxe.Unserializer.run(neko.io.File.getContent(this.get_cache_path())));
        return true;
      } else {
        return false;
      }
    }

    public function save_to_cache() {
      var fh = neko.io.File.write(this.get_cache_path(), true);
      fh.writeString(haxe.Serializer.run(this.unwind_tokens()));
      fh.close();
    }

    public function populate_from_file() {}
  #end

  public function load_from_resource() {
    this.populate_from_unwound_tokens(haxe.Unserializer.run(haxe.Resource.getString(this.get_cache_path())));
  }

  public function unwind_tokens() : Hash<String> {
    var unwound_tokens = new Hash<String>();
    for (token in this.tokenHash.keys()) {
      unwound_tokens.set(token, this.tokenHash.get(token).version);
    }
    return unwound_tokens;
  }

  public function populate_from_unwound_tokens(unwound_tokens : Hash<String>) {
    this.tokenHash = new Hash<Token>();
    var token_type = get_default_token_type();
    for (token in unwound_tokens.keys()) {
      this.tokenHash.set(token, Type.createInstance(token_type, [ token, unwound_tokens.get(token) ]));
    }
  }
}