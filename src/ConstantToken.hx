class ConstantToken extends Token {
  override public function getTokenType() {
    return ResultType.Constant;
  }
}