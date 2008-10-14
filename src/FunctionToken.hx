class FunctionToken extends Token {
  override public function get_token_type() {
    return ResultType.Function;
  }
}