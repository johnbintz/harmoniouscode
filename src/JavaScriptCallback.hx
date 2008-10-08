class JavaScriptCallback {
  public function parse(t : Token) {
    js.Lib.document.getElementById("Current token: " + t.token);
  }
}