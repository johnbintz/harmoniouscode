class TokenProcessor {
  public var tokenHash : Hash<Token>;
  public static var cachePath : String = null;

  public function new() { this.tokenHash = new Hash<Token>(); }
  public function get_cache_path() { return TokenProcessor.cachePath; }

  #if neko
    public function load_from_cache() : Bool {
      if (neko.FileSystem.exists(this.get_cache_path())) {
        this.tokenHash = haxe.Unserializer.run(neko.io.File.getContent(this.get_cache_path()));
        return true;
      } else {
        return false;
      }
    }

    public function save_to_cache() {
      var fh = neko.io.File.write(this.get_cache_path(), true);
      fh.writeString(haxe.Serializer.run(this.tokenHash));
      fh.close();
    }
  #end

  public function load_from_resource() {
    this.tokenHash = haxe.Unserializer.run(haxe.Resource.getString(this.get_cache_path()));
  }
}