<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
		xmlns:map="http://www.w3.org/2005/xpath-functions/map"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns="http://www.tei-c.org/ns/1.0"
		xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:param name="processlist1" as="map(xs:string, map(xs:string,xs:string*))" select="map{'lonnrot-0050-2-token39881' : map{'xmlid': 'testanno1', 'other' : ('lonnrot-0050-2-token39882', 'lonnrot-0050-2-token39883')}}"/>

  <xsl:param name="processlist">map{'lonnrot-0050-2-token39515' : map{'xmlid': 'testanno1', 'other' : ('lonnrot-0050-2-token39515', 'lonnrot-0050-2-token39516')}}</xsl:param>

  <xsl:param name="elementname" as="xs:string">placeName</xsl:param>
  <!-- Elementin nimi on lisättävä parametriksi, jotta voidaan prosessoida yksi annotaatiotyyppi kerrallaan! -->
  
  <xsl:variable name="pr2" as="map(xs:string,map(xs:string,xs:string*))">
    <xsl:evaluate
	as="map(xs:string,map(xs:string,xs:string*))"
	xpath="$processlist" />
  </xsl:variable>

  <xsl:param name="skiplist" as="xs:string*">('lonnrot-0050-2-token39515', 'lonnrot-0050-2-token39516')</xsl:param>

  <xsl:variable name="skip2" as="xs:string*">
    <xsl:evaluate as="xs:string*"
		  xpath="$skiplist" />
  </xsl:variable>
  


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="w|pc|num">
    <xsl:variable name="currid" select="@xml:id"/>
    <xsl:choose>
      <xsl:when test="map:contains($pr2,@xml:id)">
	<xsl:element name="{$elementname}">
	  <xsl:attribute name="xml:id" select="map:get(map:get($pr2,@xml:id),'xmlid')"/>
	  <xsl:copy-of select="."/>

	  <xsl:apply-templates select="(following-sibling::w|following-sibling::pc|following-sibling::num)[@xml:id=map:get(map:get($pr2,$currid),'other')]|following-sibling::text()[following-sibling::*[@xml:id=map:get(map:get($pr2,$currid),'other')]]" mode="forreal" />
	</xsl:element>
      </xsl:when>
      <xsl:when test="$currid=$skip2" />
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
      
  </xsl:template>
  <xsl:template match="text()[following-sibling::*][1][@xml:id=$skip2]"/>
  
  <xsl:template match="w|pc|num|text()" mode="forreal">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="body">
    <body>
      <xsl:apply-templates/>
      <!-- <p>Skiplist: -->
      <!-- <xsl:value-of select="$skip2[2]"/> -->
      <!-- </p> -->
      <!-- <xsl:value-of select="$pr2"/> -->
      <!-- <xsl:value-of select="map:get(map:get($pr2,'lonnrot-0050-2-token39881'),'xmlid')"/> -->

    </body>
  </xsl:template>
</xsl:stylesheet>
