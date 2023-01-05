<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0">
  <!-- <xsl:variable name="otsikko" select="/whole/header/blurp"/> -->
  <xsl:output method="xml" media-type="text/xml" omit-xml-declaration="no" encoding="UTF-8" indent="no" />
  
  <xsl:strip-space elements="pubblurp line"/>

  <xsl:param name="basename"/>

  <xsl:template match="whole">
    <xsl:document>
      <TEI>
    <xsl:call-template name="workhead"/>
    <xsl:apply-templates/></TEI>
    </xsl:document>
  </xsl:template>

  <xsl:template match="header"><xsl:comment>Header</xsl:comment>
  <!-- <TEI><xsl:attribute name="xml:id" select="concat('lonnrot-',$basename,'-',position())"/> -->
  <!-- <xsl:call-template name="workhead"/> -->
  <!-- </TEI> -->
  </xsl:template>


  <xsl:template name="workhead">
    <xsl:variable name="blurp" select="/whole/header/blurp"/>
    <xsl:variable name="pubblurp" select="/whole/header/pubblurp"/>
    <xsl:variable name="otsikko" select="/whole/header/otsikko"/>
    <xsl:variable name="kirjoittaja" select="/whole/header/kirjoittaja"/>
    <xsl:variable name="julkaisutiedot" select="/whole/header/julkaisutiedot"/>
    <teiHeader>
      <fileDesc>
	<titleStmt>
          <title><worktitle/>
          </title>
          <author><workauthor/>
          </author>
	  <respStmt><resp>Alkuperäinen elektroninen editio</resp><name>Projekti Lönnrot</name>
	  </respStmt>
	  <principal>Harri Kiiskinen</principal>
	</titleStmt>
	<editionStmt>
	  <edition>Projekti Lönnrotin versio, alkup. ilmestymisvuosi <workyear/></edition>
	</editionStmt>
	<publicationStmt>
	  <authority>Suomalaisen kirjallisuuden atlas 1870–1940 -projekti</authority>
	<availability><p><xsl:apply-templates select="$pubblurp" mode="header"/></p><p><xsl:apply-templates select="$blurp" mode="header"/></p>
	</availability></publicationStmt>
	<sourceDesc>
	  <bibl><author><workauthor/></author><xsl:text>: </xsl:text><title><worktitle/></title> (<workyear/>)<note>Converted from Projekti Lönnrot files</note></bibl>
	</sourceDesc>
      </fileDesc>
      <encodingDesc>
	<projectDesc>
	  <p>Teksti TEI-koodattu Suomalaisen kirjallisuuden atlas 1870–1940 -hankkeen tutkimusaineistoksi.</p>
	</projectDesc>
      </encodingDesc>
    </teiHeader>
  </xsl:template>

  <xsl:template match="line/anyword" mode="header"><xsl:value-of select="normalize-space()"/></xsl:template>
  <xsl:template match="space" mode="header"><xsl:text>&#32;</xsl:text></xsl:template>
  <xsl:template match="punct" mode="header"><xsl:value-of select="normalize-space()"/></xsl:template>
  <xsl:template match="line/text()" mode="header"/>
  <xsl:template match="lb" mode="header"/>



  <xsl:template match="work1">
    <!-- <xsl:document> -->
    <xsl:variable name="worknum"><xsl:number/></xsl:variable>
    <TEI><xsl:attribute name="xml:id" select="concat('lonnrot-',$basename,'-',$worknum)"/>
      <xsl:comment>Work, number <xsl:number/></xsl:comment>
      <xsl:call-template name="workhead"/>
      <text>
	<body>
	<xsl:apply-templates mode="text"/>
	</body>
      </text>
      </TEI>
    <!-- </xsl:document> -->
  </xsl:template>

  <xsl:template match="par"><p><xsl:apply-templates/></p></xsl:template>
  <xsl:template match="par" mode="nopars"><xsl:apply-templates/></xsl:template>
  
  <xsl:template match="anyword"><xsl:value-of select="normalize-space(.)"/></xsl:template>
  <xsl:template match="space"><space/></xsl:template>
  <xsl:template match="punct"><xsl:value-of select="normalize-space(.)"/></xsl:template>
  <xsl:template match="lineend"><lb/></xsl:template>
  <xsl:template match="lineend" mode="nopars"><xsl:text> </xsl:text></xsl:template>
  <xsl:template match="line" mode="nopars"><xsl:apply-templates/></xsl:template>
  <xsl:template match="num"><xsl:value-of select="normalize-space(.)"/></xsl:template>

  <!-- mode: text -->
  <xsl:template match="par" mode="text"><p><xsl:apply-templates mode="text"/></p></xsl:template>
  <xsl:template match="anyword" mode="text"><w><xsl:value-of select="normalize-space(.)"/></w></xsl:template>
  <xsl:template match="space" mode="text"><space/></xsl:template>
  <xsl:template match="punct" mode="text">
    <pc>
      <xsl:if test="local-name(preceding::*[1])=('anyword','num')">
	<xsl:attribute name="join">left</xsl:attribute>
      </xsl:if>
    <xsl:value-of select="normalize-space(.)"/></pc>
  </xsl:template>
    <xsl:template match="lineend" mode="text"><lb/></xsl:template>
  <xsl:template match="line" mode="text"><xsl:apply-templates mode="text"/></xsl:template>
  <xsl:template match="num" mode="text"><num><xsl:value-of select="normalize-space(.)"/></num></xsl:template>

    
  
</xsl:stylesheet>
