<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:output encoding="UTF-8" method="text" indent="no"/>

  <xsl:template match="tei:w|tei:pc|tei:num"><xsl:value-of select="@xml:id"/><xsl:text>	</xsl:text><xsl:value-of select="."/><xsl:text></xsl:text></xsl:template>
  <xsl:template match="text()"/>

  <xsl:template match="tei:p">
    <xsl:apply-templates/>
    <xsl:text>###par</xsl:text>
  </xsl:template>
</xsl:stylesheet>
