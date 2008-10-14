class Token {
  public var token(get_token, null) : String;
  public var version(get_version, null) : String;
  public var token_type(get_token_type, null) : ResultType;

  public function new(t : String, ?m : String) {
    this.token = t;
    this.version = m;
  }

  public function get_token() { return this.token; }
  public function get_version() { return this.version; }
  public function get_token_type() { return ResultType.Generic; }

  public function toResult() {
    return new Result(this.token_type, this.token, this.version);
  }
}