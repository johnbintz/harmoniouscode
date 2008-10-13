class TestConstantTokenProcessor extends haxe.unit.TestCase {
  static var constant_name : String = "TEST";
  static var constant_from : String = "5.2";
  static var test_xml_strings = [
    "<appendix> <variablelist> <varlistentry> <term> <constant>$constant</constant> </term> <listitem> <simpara>Since PHP $version</simpara> </listitem> </varlistentry> </variablelist> </appendix>",
    "<appendix> <para> <variablelist> <varlistentry> <term> <constant>$constant</constant> </term> <listitem> <simpara>Since PHP $version</simpara> </listitem> </varlistentry> </variablelist> </para> </appendix>",
    "<appendix> <section> <variablelist> <varlistentry> <term> <constant>$constant</constant> </term> <listitem> <simpara>Since PHP $version</simpara> </listitem> </varlistentry> </variablelist> </section> </appendix>",
    "<appendix> <table> <tbody> <row> <entry> <constant>$constant</constant> </entry> <entry> since PHP $version</entry> </row> </tbody> </table> </appendix>",
    "<appendix> <section> <para> <table> <tgroup> <tbody> <row> <entry> <constant>$constant</constant> </entry> <entry>since PHP $version</entry> </row> </tbody> </tgroup> </table> </para> </section> </appendix>",
    "<appendix> <para> <table> <tgroup> <tbody> <row> <entry> <constant>$constant</constant> </entry> <entry>since PHP $version</entry> </row> </tbody> </tgroup> </table> </para> </appendix>",
    "<appendix> <para> <informaltable> <tgroup> <tbody> <row> <entry> <constant>$constant</constant> </entry> <entry>since PHP $version</entry> </row> </tbody> </tgroup> </informaltable> </para> </appendix>",
    "<appendix> <para> <itemizedlist> <listitem> <simpara> <constant>$constant</constant> </simpara> <simpara>since PHP $version</simpara> </listitem> </itemizedlist> </para> </appendix>"
  ];

  public function testConstantLists() {
    for (string in test_xml_strings) {
      string = ~/\$constant/.replace(string, constant_name);
      string = ~/\$version/.replace(string, constant_from);

      var tokenProcessor = new ConstantTokenProcessor();
      tokenProcessor.populate_from_string(string);

      assertTrue(tokenProcessor.tokenHash.exists(constant_name));
      assertEquals("PHP " + constant_from, tokenProcessor.tokenHash.get(constant_name).version);
    }
  }
}