<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
  
  <xsl:output indent="1" omit-xml-declaration="1" />
  
  <xsl:template match="tei:fileDesc">
    <marc:record>
        
    </marc:record>
  </xsl:template>
</xsl:stylesheet>