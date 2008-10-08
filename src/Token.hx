class Token {
  public var token(getToken, null) : String;
  public var version(getVersion, null) : String;
  public var token_type(getTokenType, null) : ResultType;

  public function new(t : String, ?m : String) {
    this.token = t;
    this.version = m;
  }

  public function getToken() { return this.token; }
  public function getVersion() { return this.version; }
  public function getTokenType() { return ResultType.Generic; }

  public function toResult() {
    return new Result(this.token_type, this.token, this.version);
  }
}