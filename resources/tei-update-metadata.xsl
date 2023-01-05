<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0"
		xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <!-- <xsl:variable name="otsikko" select="/whole/header/blurp"/> -->
  <xsl:output method="xml" media-type="text/xml" omit-xml-declaration="no" encoding="UTF-8" indent="no" />
  <xsl:variable name="docname" select="/TEI/@xml:id"/>

  <xsl:strip-space elements="p body"/>
  <xsl:param name="docid"/>
  <xsl:param name="author"/>
  <xsl:param name="title"/>
  <xsl:param name="year"/>


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
  
  <xsl:template match="worktitle"><xsl:value-of select="$title"/>: elektroninen versio tutkimuskäyttöön</xsl:template>
  
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

  <!-- <xsl:template match="lb[following-sibling::*[1][self::lb] and following-sibling::*[2][self::lb] and following-sibling::*[2][self::lb]]"> -->
  <!--   <divchange/> -->
  <!-- </xsl:template> -->

  <xsl:template match="space"><xsl:text> </xsl:text></xsl:template>
  <xsl:template match="w"><w><xsl:call-template name="numbering"/><xsl:value-of select="normalize-space(.)"/></w></xsl:template>

  <xsl:template match="pc"><xsl:copy><xsl:apply-templates select="@*"/><xsl:call-template name="numbering"/><xsl:value-of select="normalize-space(.)"/></xsl:copy></xsl:template>

  <xsl:template match="num"><xsl:copy><xsl:call-template name="numbering"/><xsl:value-of select="normalize-space(.)"/></xsl:copy></xsl:template>

  <xsl:template name="numbering"><xsl:attribute name="xml:id">
    <xsl:value-of select="$docid"/>-token<xsl:value-of select="accumulator-before('wnum')"/>
  </xsl:attribute>
  <xsl:attribute name="n" select="accumulator-before('wnum')"/>
  </xsl:template>
  
  <xsl:template match="lb"><xsl:copy/><xsl:text>
  </xsl:text></xsl:template>
</xsl:stylesheet>

