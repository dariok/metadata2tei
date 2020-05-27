<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>Transform a MARC XML record into a tei:biblStruct</xd:desc>
  </xd:doc>
  
  <xsl:output indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Main entry point. Will usually be overwritten by importing XSLT.</xd:p>
      <xd:p>Importing stylesheets will have to create tei:biblStruct in an appropriate place; this will depend on the
        source of the MARC data, e.g. a SRU API.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <listBibl>
      <xsl:for-each select="descendant::marc:record">
        <biblStruct>
          <xsl:apply-templates select="." />
        </biblStruct>
      </xsl:for-each>
    </listBibl>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the main container for title data. Depending on the type specified in the leader (position 7,
        zero-based), we create analytic or monogr.</xd:p>
      <xd:p>As a biblStruct with analytic also needs a monogr, both of which will be created from a marc:record,
        we cannot create a biblStruct here.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:record">
    <xsl:variable name="level">
      <xsl:variable name="code" select="substring(marc:leader, 8, 1)"/>
      <xsl:choose>
        <xsl:when test="$code = 'a'">analytic</xsl:when>
        <xsl:when test="$code = 'm'">monogr</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$level}">
      <xsl:apply-templates select="marc:datafield[@tag = '100']" />
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create an author, editor or respStmt element depending on the value of the “function” subfield. Uses the
        content of $e as element name in case an unknown value is encountered so these cases can be caught by schema
        validation.</xd:p>
      <xd:p>MARC fields 100 (personal name) and are used.</xd:p>
      <xd:p>TODO: provide a longer list of values to take care of different languages</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '100']">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code = 'e'] = ('Editor', 'Bearbeiter')">editor</xsl:when>
        <xsl:when test="not(marc:subfield[@code = 'e'])">author</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(marc:subfield[@code = 'e'], ' ', '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Fallback template for all unhandled marc:datafield</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield">
    <xsl:text>[unhandled data field]</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>text() to be left unchanged</xd:desc>
  </xd:doc>
  <xsl:template match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
</xsl:stylesheet>