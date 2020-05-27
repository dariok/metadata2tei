<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xsl:template match="marc:datafield">
    <xsl:text>[unhandled data field]</xsl:text>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
</xsl:stylesheet>