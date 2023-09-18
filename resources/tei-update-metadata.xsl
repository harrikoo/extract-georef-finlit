<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0"
		xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  
  <xsl:output method="xml" media-type="text/xml" omit-xml-declaration="no" encoding="UTF-8" indent="no" />

  <xsl:variable name="docname" select="/TEI/@xml:id"/>

  <xsl:strip-space elements="p body"/>

  <!-- Values for these parameters must be supplied when calling this
       template.-->
  
  <xsl:param name="docid"/>
  <xsl:param name="author"/>
  <xsl:param name="title"/>
  <xsl:param name="year"/>
  
  <!-- Accumulator to construct a serial ID for the tokens. The XSL 1.0
       way was to use various applications of counting, but that becomes
       impossibly slow in the case of larger documents. We are having
       token numbers in the tens of thousands, requirin as many times
       for counting through the whole document using the old way. The
       modern versions of XSL provide the <accumulator> element to count
       things along processing the original document. -->
  
  <xsl:accumulator name="wnum" initial-value="0" > 
    <xsl:accumulator-rule match="body" select="0"/>
    <xsl:accumulator-rule match="w|pc|num" select="$value + 1"/>
  </xsl:accumulator>
  
  <xsl:mode use-accumulators="wnum"/>
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()" priority="2"><xsl:copy/></xsl:template>
  
  <xsl:template match="worktitle"><xsl:value-of select="$title"/></xsl:template>
  
  <xsl:template match="workauthor"><xsl:value-of select="$author"/></xsl:template>

  <xsl:template match="workyear">
    <date><xsl:attribute name="when" select="$year"/><xsl:value-of select="$year"/></date>
  </xsl:template>

  <xsl:template match="body">
    <body>
      <xsl:for-each-group select="*" group-ending-with="lb[following-sibling::*[1][self::lb] and following-sibling::*[2][self::lb] and following-sibling::*[2][self::lb]]">
	<div>
	  <xsl:apply-templates select="current-group()"/>
	</div>
      </xsl:for-each-group>
    </body>
  </xsl:template>

  <!-- 
       These templates match the XML elements created by the
       parser. <space>-elements are replaces with single space
       characters, since TEI only recommends using the <space> element
       to mark extraordinary spaces in text, not normal interword
       spacing.  

Parser elements <w> "word", <pc> "punctuation" and <num> "number" are
replaced with TEI elements of the same name, and a sequential unique
ID is added to each token thus created. The ID is composed of the
document id also used in the base TEI element with added
"-token<number>" text.

-->
  <xsl:template match="space"><xsl:text> </xsl:text></xsl:template>

  <xsl:template match="w"><w><xsl:call-template name="numbering"/><xsl:value-of select="normalize-space(.)"/></w></xsl:template>

  <xsl:template match="pc"><xsl:copy><xsl:apply-templates select="@*"/><xsl:call-template name="numbering"/><xsl:value-of select="normalize-space(.)"/></xsl:copy></xsl:template>

  <xsl:template match="num"><xsl:copy><xsl:call-template name="numbering"/><xsl:value-of select="normalize-space(.)"/></xsl:copy></xsl:template>

  <!-- This creates the actual ID attribute for each element it is
       called from. It also adds a simple numerical n-attribute to the
       element.-->
  
  <xsl:template name="numbering"><xsl:attribute name="xml:id">
    <xsl:value-of select="$docid"/>-token<xsl:value-of
    select="accumulator-before('wnum')"/>
  </xsl:attribute>
  <xsl:attribute name="n" select="accumulator-before('wnum')"/>
  </xsl:template>

  <!-- Line breaks are replaces with actual text line breaks. 

This is a point that could arguably done differently, and can be
changed if desired. -->
  
  <xsl:template match="lb"><xsl:copy/><xsl:text>
</xsl:text>
  </xsl:template>
</xsl:stylesheet>

