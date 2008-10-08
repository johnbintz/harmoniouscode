class Result {
  public var type(getType, null) : ResultType;
  public var token(getToken, null) : String;
  public var version(getVersion, null) : String;
  public var is_enabled : Bool;

  public function new(type : ResultType, token : String, version : String) {
    this.type = type;
    this.token = token;
    this.version = version;
    this.is_enabled = true;
  }

  public function getType() { return this.type; }
  public function getToken() { return this.token; }
  public function getVersion() { return this.version; }

  public static function change_enabled(results : Array<Result>, token : String, set_is_enabled : Bool) {
    for (result in results) {
      if (result.token == token) {
        result.is_enabled = set_is_enabled;
      }
    }
  }

  public static function compare(a : Result, b : Result) : Int{
    if (a.token == b.token) { return 0; }
    return (a.token < b.token) ? -1 : 1;
  }
}