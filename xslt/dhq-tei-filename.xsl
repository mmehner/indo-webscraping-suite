<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:d="http://www.digitalhumanities.org/ns/dhq"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
  
  <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="no"/>

  <xsl:preserve-space elements=""/>
  <xsl:strip-space elements=""/>
  
  <xsl:template match="/">
    <xsl:value-of select="normalize-space(//t:titleStmt//d:author_name)"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="substring-before(//t:publicationStmt/t:date/@when, '-')"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="normalize-space(//t:titleStmt/t:title)"/>
  </xsl:template>

</xsl:stylesheet>
