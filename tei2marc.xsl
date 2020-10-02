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
  
  <xsl:template match="tei:fileDesc[descendant::tei:title[@level = 'a']]">
    <marc:record>
      <marc:leader>
        <xsl:text>      a</xsl:text>
        <xsl:choose>
          <xsl:when test="descendant::tei:analytic or descendant::tei:title[@level = 'a']">a</xsl:when>
          <xsl:otherwise>m</xsl:otherwise>
        </xsl:choose>
        <xsl:text> a22     uu 4500</xsl:text>
      </marc:leader>
      
      <marc:datafield tag="245" ind1="0" ind2="0">
        <marc:subfield code="a">
          <xsl:value-of select="normalize-space(tei:titleStmt/tei:title[@level = 'a'])" />
        </marc:subfield>
      </marc:datafield>
      
      <xsl:if test="tei:titleStmt/tei:title[not(@type = ('short', 'abbreviated', 'abbrev'))]">
        <marc:datafield tag="773" ind1="0" ind2=" ">
          <marc:subfield code="a">
            <xsl:value-of select="normalize-space(tei:titleStmt/tei:title[@level = ('s', 'm')])" />
          </marc:subfield>
        </marc:datafield>
      </xsl:if>
      
      <xsl:apply-templates />
      <xsl:apply-templates select="../tei:profileDesc" />
    </marc:record>
  </xsl:template>
  
  <xsl:template match="tei:fileDesc">
    <marc:record>
      <marc:leader>
        <xsl:text>      a</xsl:text>
        <xsl:choose>
          <xsl:when test="descendant::tei:analytic or descendant::tei:title[@level = 'a']">a</xsl:when>
          <xsl:otherwise>m</xsl:otherwise>
        </xsl:choose>
        <xsl:text> a22     uu 4500</xsl:text>
      </marc:leader>
      <xsl:apply-templates />
      
      <xsl:if test="tei:titleStmt/tei:title[not(@type = ('short', 'abbreviated', 'abbrev'))]">
        <marc:datafield tag="245" ind1="0" ind2="0">
          <xsl:apply-templates select="tei:titleStmt/tei:title[not(@type = ('short', 'abbreviated', 'abbrev'))]" />
        </marc:datafield>
      </xsl:if>
    </marc:record>
  </xsl:template>
  
  <xsl:template match="tei:titleStmt">
    <!-- Main entries: personal name -->
    <xsl:for-each 
      select="tei:author[not(@type) or @type = ('per', 'person')] |
              tei:editor[not(@type) or @type = ('per', 'person')] |
              tei:respStmt[descendant::tei:persName or descendant::tei:name[not(@type) or @type = ('per', 'person')]]">
      <xsl:apply-templates select="." mode="person">
        <xsl:with-param name="tag">
          <xsl:choose>
            <xsl:when test="position() = 1">100</xsl:when>
            <xsl:otherwise>700</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
    
    <xsl:apply-templates select="tei:title[@type = ('short', 'abbreviated', 'abbrev')]" />
  </xsl:template>
  
  <xsl:template match="tei:editionStmt">
    <marc:datafield tag="250" ind1=" " ind2=" ">
      <xsl:apply-templates select="tei:edition" mode="subfield" />
    </marc:datafield>
    <xsl:apply-templates mode="person"
      select="tei:author[not(@type) or @type = ('per', 'person')] |
              tei:editor[not(@type) or @type = ('per', 'person')] |
              tei:respStmt[descendant::tei:persName or descendant::tei:name[not(@type) or @type = ('per', 'person')]]">
      <xsl:with-param name="tag">700</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="tei:seriesStmt">
    <xsl:if test="tei:title | tei:p">
      <xsl:variable name="ind1" select="count(tei:editor) gt 0" />
      <marc:datafield tag="490" ind1="{number($ind1)}" ind2=" ">
        <xsl:apply-templates select="(tei:title | tei:p)[1]" mode="subfield" />
        <xsl:apply-templates select="tei:idno[matches(., '\d{4}-\d{4}')]" mode="subfield">
          <xsl:with-param name="x" />
        </xsl:apply-templates>
      </marc:datafield>
    </xsl:if>
    
    <xsl:apply-templates mode="person"
      select="tei:author[not(@type) or @type = ('per', 'person')] |
      tei:editor[not(@type) or @type = ('per', 'person')] |
      tei:respStmt[descendant::tei:persName or descendant::tei:name[not(@type) or @type = ('per', 'person')]]">
      <xsl:with-param name="tag">800</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt">
    <marc:datafield tag="260" ind1=" " ind2=" ">
      <xsl:apply-templates select="(tei:pubPlace/tei:name | tei:pubPlace)[1]" />
      <xsl:apply-templates select="(tei:publisher/tei:name | tei:publisher)[1]" />
      <xsl:apply-templates select="tei:date" />
    </marc:datafield>
    <xsl:apply-templates select="tei:availability" />
  </xsl:template>
  <xsl:template match="tei:publicationStmt//*[not(self::tei:availability)]">
    <marc:subfield>
      <xsl:attribute name="code">
        <xsl:choose>
          <xsl:when test="ancestor-or-self::tei:pubPlace">a</xsl:when>
          <xsl:when test="ancestor-or-self::tei:publisher">b</xsl:when>
          <xsl:when test="ancestor-or-self::tei:date">c</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="tei:name">
          <xsl:value-of select="normalize-space(tei:name)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(string-join(node()[not(self::tei:idno)]))" />
        </xsl:otherwise>
      </xsl:choose>
    </marc:subfield>
  </xsl:template>
  
  <xsl:template match="tei:sourceDesc">
    <xsl:if test="tei:bibl or tei:biblFull">
      <xsl:apply-templates />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:*" mode="person">
    <xsl:param name="tag" required="1" />
    <xsl:variable name="ind1">
      <xsl:choose>
        <xsl:when test="contains(., ', ')">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="self::tei:author">
        <marc:datafield tag="{$tag}" ind1="{$ind1}" ind2=" ">
          <marc:subfield code="a">
            <xsl:value-of select="normalize-space()" />
          </marc:subfield>
          <marc:subfield code="e">aut</marc:subfield>
        </marc:datafield>
      </xsl:when>
      <xsl:when test="self::tei:editor">
        <marc:datafield tag="{$tag}" ind1="{$ind1}" ind2=" ">
          <marc:subfield code="a">
            <xsl:value-of select="normalize-space()" />
          </marc:subfield>
          <marc:subfield code="e">
            <xsl:choose>
              <xsl:when test="contains(@role, 'vocabulary/relators/')">
                <xsl:value-of select="replace(substring-after(@role, 'relators/'), '\.html', '')" />
              </xsl:when>
              <xsl:when test="@role">
                <xsl:value-of select="@role" />
              </xsl:when>
              <xsl:otherwise>edt</xsl:otherwise>
            </xsl:choose>
          </marc:subfield>
        </marc:datafield>
      </xsl:when>
      <xsl:when test="self::tei:respStmt">
        <xsl:for-each select="tei:name | tei:persName">
          <marc:datafield tag="{$tag}" ind1="{$ind1}" ind2=" ">
            <marc:subfield code="a">
              <xsl:value-of select="normalize-space()" />
            </marc:subfield>
            <marc:subfield code="e">
              <xsl:choose>
                <xsl:when test="contains(../tei:resp/@ref, 'vocabulary/relators/')">
                  <xsl:value-of select="replace(substring-after(../tei:resp/@ref, 'relators/'), '\.html', '')" />
                </xsl:when>
                <xsl:when test="../tei:resp/@ref">
                  <xsl:value-of select="../tei:resp/@ref" />
                </xsl:when>
                <xsl:when test="../tei:resp">
                  <xsl:value-of select="normalize-space(../tei:resp)"/>
                </xsl:when>
                <xsl:otherwise>edt</xsl:otherwise>
              </xsl:choose>
            </marc:subfield>
          </marc:datafield>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="parent::tei:correspAction">
        <marc:datafield tag="{$tag}" ind1="{$ind1}" ind2=" ">
          <marc:subfield code="a">
            <xsl:value-of select="normalize-space()" />
          </marc:subfield>
          <marc:subfield code="e">
            <xsl:choose>
              <xsl:when test="../@type = 'received'">rcp</xsl:when>
              <xsl:when test="../@type = 'sent'">aut</xsl:when>
            </xsl:choose>
          </marc:subfield>
        </marc:datafield>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:profileDesc">
    <xsl:apply-templates select="tei:abstract | tei:correspDesc/tei:correspAction" />
  </xsl:template>
  
  <xsl:template match="tei:*" mode="subfield">
    <xsl:param name="code">a</xsl:param>
    <marc:subfield code="{$code}">
      <xsl:value-of select="normalize-space()" />
    </marc:subfield>
  </xsl:template>
  
  <xsl:template match="tei:titleStmt/tei:title[@type = ('short', 'abbreviated', 'abbrev')]">
    <marc:datafield code="210" ind1="0" ind2="0">
      <marc:subfield code="a">
        <xsl:value-of select="normalize-space()"/>
      </marc:subfield>
    </marc:datafield>
  </xsl:template>
  <xsl:template match="tei:titleStmt/tei:title[not(@type = ('short', 'abbreviated', 'abbrev'))]">
    <marc:subfield>
      <xsl:attribute name="code">
        <xsl:choose>
          <xsl:when test="(not(@type) or @type = 'main') and not(preceding-sibling::tei:title[not(@type) or @type = 'main'])">a</xsl:when>
          <xsl:when test="@type = 'sub'">b</xsl:when>
          <xsl:when test="@type = 'resp'">c</xsl:when>
          <xsl:otherwise>p</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="normalize-space()" />
    </marc:subfield>
  </xsl:template>
  
  <xsl:template match="tei:availability">
    <marc:datafield tag="506" ind1=" " ind2=" ">
      <xsl:choose>
        <xsl:when test="tei:licence/@target">
          <marc:subfield code="a">
            <xsl:value-of select="normalize-space(tei:licence)" />
          </marc:subfield>
          <marc:subfield code="u">
            <xsl:value-of select="tei:licence/@target" />
          </marc:subfield>
        </xsl:when>
        <xsl:otherwise>
          <marc:subfield code="a">
            <xsl:value-of select="normalize-space()" />
          </marc:subfield>
        </xsl:otherwise>
      </xsl:choose>
    </marc:datafield>
  </xsl:template>
  
  <xsl:template match="tei:abstract">
    <marc:datafield tag="520" ind1="3" ind2=" ">
      <marc:subfield code="a">
        <xsl:value-of select="normalize-space(string-join(node()))" />
      </marc:subfield>
    </marc:datafield>
  </xsl:template>
  
  <xsl:template match="tei:correspAction">
    <xsl:apply-templates select="tei:persName" mode="person">
      <xsl:with-param name="tag">700</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
</xsl:stylesheet>