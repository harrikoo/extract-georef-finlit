<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
		xmlns:map="http://www.w3.org/2005/xpath-functions/map"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns="http://www.tei-c.org/ns/1.0"
		xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:param name="lemmamap">map{'lonnrot-0050-2-token39883' : map{'lemma': 'yleinen', 'upos' : '', 'feats' : ''}}</xsl:param>

  <xsl:variable name="pr2" as="map(xs:string,map(xs:string,xs:string))">
    <xsl:evaluate
	as="map(xs:string,map(xs:string,xs:string))"
	xpath="$lemmamap" />
  </xsl:variable>


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="w|pc">
    <xsl:variable name="currid" select="@xml:id"/>
    <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:choose>
      <xsl:when test="map:contains($pr2,@xml:id)">
	<xsl:attribute name="lemma" select="map:get(map:get($pr2,@xml:id),'lemma')"/>
	<xsl:attribute name="pos" select="map:get(map:get($pr2,@xml:id),'upos')"/>
	<xsl:attribute name="msd" select="map:get(map:get($pr2,@xml:id),'feats')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:apply-templates/>

    </xsl:copy>
  </xsl:template>
  

  <xsl:template match="body">
    <body>
      <xsl:apply-templates/>
      <!-- <p>lemmamap: -->
      <!-- <xsl:value-of select="map:get(map:get($pr2,'lonnrot-0050-2-token25'),'lemma')"/> -->
      <!-- </p> -->
      <!-- <xsl:value-of select="$pr2"/> -->
      <!-- <xsl:value-of select="map:get(map:get($pr2,'lonnrot-0050-2-token39881'),'xmlid')"/> -->

    </body>
  </xsl:template>
</xsl:stylesheet>
