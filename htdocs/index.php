<html>
  <head>
    <title>Harmonious Code: Will my PHP code and Web hosting work together?</title>
    <meta name="keywords" content="php, static code analysis, web hosting, functions, constants, language features" />
    <link rel="stylesheet" href="style.css" type="text/css" />
  </head>
  <body>
    <h1>Harmonious Code</h1>
    <div id="loading">
      Loading...
    </div>
    <div id="form" style="display: none">
      <div id="form-holder">
        <form action="" method="post" onsubmit="return false;">
          <textarea name="source" id="source" rows="15" cols="80"></textarea><br />
          <input id="analyze-code-button" type="button" value="Analyze Code" onclick="JavaScriptTarget.do_analysis(this.form.elements.source)" />
        </form>
      </div>
      <div id="output"></div>
      <div id="permanent-ignore" style="display: none">
        To permanently ignore tokens, do one of the following:
        <ul>
          <li>To ignore globally, place at the top of the file on its own line:
            <blockquote><code>//harmonious <span class="ignore-code-holder"></span></code></blockquote>
          </li>
          <li>To ignore within a particular block of code, wrap the code in the following:
            <blockquote><code>//harmonious <span class="ignore-code-holder"></span><br />
            &nbsp;&nbsp;...your code...<br />
            //harmonious_end</code></blockquote>
          </li>
        </ul>
      </div>
    </div>
    <div id="local-info">
      <?php @include('local-info.php') ?>
    </div>
    <div id="haxe:trace"></div>
    <div id="footer">
      Harmonious Code is Copyright &copy; 2008 John Bintz &mdash; Licensed under the GPL Version 2
    </div>
    <script type="text/javascript" src="harmoniouscode.js"> </script>
  </body>
</html>