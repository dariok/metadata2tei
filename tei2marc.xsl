<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
  
  <xsl:output indent="1" omit-xml-declaration="1" />
    
  <xsl:template match="/">
    <xsl:apply-templates select="//tei:teiHeader/tei:fileDesc | //tei:biblStruct | //tei:biblFull" />
  </xsl:template>
  
  <xsl:template match="tei:fileDesc">
    <marc:record>
      <xsl:choose>
        <xsl:when test="descendant::tei:title[@level = 'a'] or descendant::tei:analytic"></xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="tei:titleStmt/tei:title[@type = 'short']" />
          
          <marc:datafield tag="245" ind1="0" ind2="0">
            <xsl:apply-templates select="tei:titleStmt/tei:title[not(@type = 'short')]" />
          </marc:datafield>
        </xsl:otherwise>
      </xsl:choose>
    </marc:record>
  </xsl:template>
  
  <xsl:template match="tei:titleStmt/tei:title[@type = 'short']">
    <marc:datafield code="210" ind1="0" ind2="0">
      <marc:subfield code="a">
        <xsl:value-of select="normalize-space()"/>
      </marc:subfield>
    </marc:datafield>
  </xsl:template>
  <xsl:template match="tei:titleStmt/tei:title[not(@type = 'short')]">
    <marc:subfield>
      <xsl:attribute name="code">
        <xsl:choose>
          <xsl:when test="not(@type) or @type = 'main'">a</xsl:when>
          <xsl:when test="@type = 'sub'">b</xsl:when>
          <xsl:when test="@type = 'resp'">c</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="normalize-space()" />
    </marc:subfield>
  </xsl:template>
</xsl:stylesheet>