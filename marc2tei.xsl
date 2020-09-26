<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
      <xd:p>Entry point for biblStruct.</xd:p>
    </xd:desc>
    <xd:param name="id">
      <xd:p>If an @xml:id should be set, if can be provided with this param</xd:p>
    </xd:param>
  </xd:doc>
  <xsl:template match="marc:record" mode="biblStruct">
    <xsl:param name="id" />
    <biblStruct>
      <xsl:if test="$id">
        <xsl:attribute name="xml:id" select="$id" />
      </xsl:if>
      <xsl:apply-templates select="." mode="struct" />
      <!-- create series -->
      <xsl:apply-templates select="marc:datafield[@tag = ('490', '830')]" />
    </biblStruct>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Entry point for biblFull.</xd:p>
    </xd:desc>
    <xd:param name="id">
      <xd:p>If an @xml:id should be set, if can be provided with this param</xd:p>
    </xd:param>
  </xd:doc>
  <xsl:template match="marc:record" mode="biblFull">
    <xsl:param name="id" />
    <biblFull>
      <xsl:if test="$id">
        <xsl:attribute name="xml:id" select="$id" />
      </xsl:if>
    </biblFull>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the contents of a biblStruct. Depending on the type specified in the leader (position 7,
        zero-based), we create analytic or monogr.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:record">
    <xsl:variable name="level">
      <xsl:variable name="code" select="substring(marc:leader, 8, 1)"/>
      <xsl:choose>
        <xsl:when test="$code = 'a'">analytic</xsl:when>
        <xsl:when test="$code = 'm'">monogr</xsl:when>
        <xsl:when test="$code = 's'">monogr</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$level}">
      <!-- author, editor, respStmt -->
      <xsl:apply-templates select="marc:datafield[@tag = '100']" />
      <!-- title -->
      <xsl:apply-templates select="marc:datafield[@tag = '245']/*" />
      <!-- additional responsibility statements (e.g. works of an author in 100, edited by someone -->
      <xsl:apply-templates select="marc:datafield[@tag = '700']" />
      <!-- language(s) -->
      <xsl:apply-templates select="marc:datafield[@tag = '041']" />
      <!-- ID of this record -->
      <xsl:apply-templates select="marc:controlfield[@tag = '001']
        | marc:datafield[@tag = ('015', '016', '020', '022')]" />
      <!-- notes -->
      <xsl:apply-templates select="marc:datafield[@tag = ('500')]" />
      <!-- edition -->
      <xsl:apply-templates select="marc:datafield[@tag = ('250', '502')]" />
      <!-- imprint -->
      <xsl:apply-templates select="marc:datafield[@tag = ('260', '264')]" />
      <!-- extent -->
      <xsl:apply-templates select="marc:datafield[@tag = '300']/*" />
    </xsl:element>
    
    <!-- additional entries for series -->
    <xsl:apply-templates select="marc:datafield[@tag = ('810')]" />
    
    <!-- general annotations – no special TEI elements for these -->
    <!-- types -->
    <xsl:apply-templates select="marc:datafield[@tag = ('336', '337', '338')]" />
    <!-- dates and sequences -->
    <xsl:apply-templates select="marc:datafield[@tag = ('362', '363')]" />
    <!-- subject fields -->
    <xsl:apply-templates select="marc:datafield[@tag = ('650', '655')]" />
    <!-- Linking entries-General Information -->
    <xsl:apply-templates select="marc:datafield[@tag = '776']"/>
    
    <!-- TODO series from 760 and 762 -->
    <xsl:apply-templates select="marc:datafield[not(@tag
      = ('001', '015', '016', '020', '022', '035', '040', '041', '043', '084', '100', '245', '250', '260', '264', '300',
         '336', '337', '338', '362', '363', '490', '500', '502', '600', '650', '655', '700', '776', '810', '924'))]" />
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create an author, editor or respStmt element depending on the value of the “function” subfield. Uses the
        content of $e as element name in case an unknown value is encountered so these cases can be caught by schema
        validation.</xd:p>
      <xd:p>MARC fields 100 (personal name) and are used.</xd:p>
    </xd:desc>
  </xd:doc>
  <!-- TODO: provide a longer list of values to take care of different languages -->
  <xsl:template match="marc:datafield[@tag = ('100', '700')]">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code = '4'] = ('edt')">editor</xsl:when>
        <xsl:when test="not(marc:subfield[@code = '4'])">author</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(marc:subfield[@code = '4'], ' ', '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="marc:subfield[@code = '0']" />
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create a title from a MARC 245 field.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '245']/marc:subfield">
    <title>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@code = 'a'">main</xsl:when>
          <xsl:when test="@code = 'b'">sub</xsl:when>
          <xsl:when test="@code = 'c'">resp</xsl:when>
          <xsl:otherwise>other</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates />
    </title>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>create one textLang combining the entries in MARC 041</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '041']">
    <textLang mainLang="{string(marc:subfield[@code = 'a'][1])}">
      <xsl:if test="count(marc:subfield[@code = 'a']) gt 1">
        <xsl:attribute name="otherLangs"
          select="string-join(marc:subfield[@code = 'a' and preceding-sibling::*[@code = 'a']], ' ')" />
      </xsl:if>
    </textLang>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create an idno for the record.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:controlfield[@tag = '001']">
    <idno>
      <xsl:attribute name="type">
        <xsl:value-of select="parent::*/marc:controlfield[@tag = '003']" />
      </xsl:attribute>
      <xsl:value-of select="."/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Crete an idno from MARC 015 (number in national bilbiography)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '015']">
    <idno type="national_bibliography" subtype="{marc:subfield[@code = '2']}">
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Crete an idno from MARC 016 (controlnumber in national library)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '016']">
    <idno>
      <xsl:attribute name="type">
        <xsl:value-of select="marc:subfield[@code = '2']" />
      </xsl:attribute>
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Crete an idno from MARC 020 (ISBN)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '020']">
    <idno type="isbn">
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Crete an idno from MARC 022 (ISSN)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '022']">
    <idno type="issn">
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Information about the edition, created from MARC 205 (edition) or 502 (dissertation)</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('250', 502)]">
    <edition>
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
    </edition>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the imprint from 260 or 264.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('260', '264')]">
    <imprint>
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
      <xsl:apply-templates select="marc:subfield[@code = 'b']" />
      <xsl:apply-templates select="marc:subfield[@code = ('c', '3')]" />
    </imprint>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create imprint’s contents from MARC 260 or 264 subfields.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('260', '264')]/marc:subfield">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="@code = 'a'">pubPlace</xsl:when>
        <xsl:when test="@code = 'b'">publisher</xsl:when>
        <!-- TODO learn more about the usage of subfield 3 with dates -->
        <xsl:when test="@code = ('c', '3')">date</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$name}">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create a series element for each MARC 490</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '490']">
    <series>
      <xsl:apply-templates />
    </series>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create multiple extent from the data in 300</xd:p>
    </xd:desc>
  </xd:doc>
  <!-- TODO try to parse info in specific subfields, esp. dimensions in $c -->
  <xsl:template match="marc:datafield[@tag = '300']/marc:subfield">
    <extent>
      <xsl:apply-templates />
    </extent>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:note from MARC 500</xd:p>
    </xd:desc>
  </xd:doc>
  <!-- TODO try to parse info in specific subfields, esp. dimensions in $c -->
  <xsl:template match="marc:datafield[@tag = '500']">
    <note>
      <xsl:apply-templates select="marc:subfield" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:series from MARC 810</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('810')]">
    <series>
      <xsl:if test="marc:subfield[@code = '7']">
        <xsl:attribute name="n" select="marc:subfield[@code = '7']" />
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 't']" />
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
      <xsl:apply-templates select="marc:subfield[@code = 'v']" />
      <xsl:apply-templates select="marc:subfield[@code = 'w']" />
    </series>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:series/tei:respStmt for MARC 810$a</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('810')]/marc:subfield[@code = 'a']">
    <respStmt>
      <name type="org">
        <xsl:apply-templates />
      </name>
    </respStmt>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:series/tei:biblScope</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('810', '830')]/marc:subfield[@code = 'v']">
    <biblScope unit="volume">
      <xsl:apply-templates />
    </biblScope>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Content Type;
             Media Type;
             Carrier Type</xd:desc>
  </xd:doc>
  <!-- TODO split multiple values into multiple terms? -->
  <xsl:template match="marc:datafield[@tag = ('336', '337', '338')]">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@tag = '336'">Content-Type</xsl:when>
        <xsl:when test="@tag = '337'">Media-Type</xsl:when>
        <xsl:when test="@tag = '338'">Carrier-Type</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <note type="{$type}" source="https://www.loc.gov/standards/sourcelist/genre-form.html#{string(marc:subfield[@code='2'])}">
      <xsl:apply-templates select="marc:subfield[@code != '2']" />
    </note>
  </xsl:template>
  <xd:doc>
    <xd:desc>subfield of 336, 337, 338 will be terms</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('336', '337', '338')]/marc:subfield">
    <term>
      <xsl:apply-templates />
    </term>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Dates of Publication and/or Sequential Designation</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '362']">
    <note type="Dates-of-Publication">
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Normalizted Date and Sequential Designation</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '363']">
    <note type="Normalized-Date">
      <xsl:choose>
        <xsl:when test="@ind1 = '0'">
          <xsl:attribute name="subtype">
            <xsl:text>start</xsl:text>
            <xsl:if test="@ind2 != ' '">
              <xsl:text>:</xsl:text>
              <xsl:choose>
                <xsl:when test="@ind2 = '0'">closed</xsl:when>
                <xsl:when test="@ind2 = '1'">open</xsl:when>
              </xsl:choose>
            </xsl:if>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@ind1 = '1'">
          <xsl:attribute name="subtype">
            <xsl:text>end</xsl:text>
            <xsl:if test="@ind2 != ' '">
              <xsl:text>:</xsl:text>
              <xsl:choose>
                <xsl:when test="@ind2 = '0'">closed</xsl:when>
                <xsl:when test="@ind2 = '1'">open</xsl:when>
              </xsl:choose>
            </xsl:if></xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="marc:subfield[@code = '8']" />
      <xsl:value-of select="string-join(marc:subfield[@code = ('a', 'b', 'c', 'd', 'e', 'f')], '-')" />
      <xsl:if test="marc:subfield[@code = ('g', 'h')]">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="string-join(marc:subfield[@code = ('g', 'h')], '-')" />
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="string-join(marc:subfield[@code = ('i', 'j', 'k', 'l')], '-')" />
      <xsl:apply-templates select="marc:subfield[@code = ('x', 'z')]" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>MARC subject fields</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '650']">
    <ref type="Topical-Term" source="https://www.loc.gov/standards/sourcelist/subject.html#{string(marc:subfield[@code='2'])}">
      <xsl:if test="marc:subfield[@code = '0']">
        <xsl:attribute name="target" select="marc:subfield[@code = '0']" />
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>MARC subject fields</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '655']">
    <ref type="Genre-Term" source="https://www.loc.gov/standards/sourcelist/genre-form.html#{string(marc:subfield[@code='2'])}">
      <xsl:if test="marc:subfield[@code = '0']">
        <xsl:attribute name="target">
          <xsl:variable name="refs" as="xs:string+">
            <xsl:for-each select="marc:subfield[@code = '0']">
              <xsl:variable name="val">
                <xsl:apply-templates select="." mode="ref" />
              </xsl:variable>
              <xsl:value-of select="'thi:' || $val" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="string-join($refs, ' ')" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 'a']" />
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc></xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '776']">
    <note type="Additional-Physical-Form">
      <xsl:if test="marc:subfield[@code = 'i']">
        <note type="display-text">
          <xsl:apply-templates select="marc:subfield[@code = 'i']" />
        </note>
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = ('t', 'd')]" />
      <xsl:if test="marc:subfield[@code = 'h']">
        <note type="physical-description">
          <xsl:apply-templates select="marc:subfield[@code = 'h']" />
        </note>
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 'w']" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Series Added Entry – Uniform Title</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '830']">
    <series>
      <xsl:if test="marc:subfield[@code = '7']">
        <xsl:attribute name="n" select="marc:subfield[@code = '7']" />
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 'a']">
        <title>
          <xsl:apply-templates select="marc:subfield[@code = 'a']" />
        </title>
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 'v']" />
      <xsl:if test="marc:subfield[@code = '9']">
        <biblScope unit="volume-sortable">
          <xsl:apply-templates select="marc:subfield[@code = '9']" />
        </biblScope>
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 'w']" />
    </series>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Fallback template for all unhandled marc:datafield</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield">
    <xsl:text>[unhandled data field: </xsl:text>
    <xsl:value-of select="@tag"/>
    <xsl:text>] </xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create a URI in the form of {authority}:{identifier} for use in @ref</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="ref" as="xs:string">
    <xsl:variable name="value">
      <xsl:analyze-string select="." regex="\(([^\)]+)\)(.+)">
        <xsl:matching-substring>
          <xsl:call-template name="auth">
            <xsl:with-param name="code" select="regex-group(1)" />
          </xsl:call-template>
          <xsl:text>:</xsl:text>
          <xsl:value-of select="regex-group(2)"/>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:value-of select="normalize-space($value)"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the value for attribute @ref based on the information in the marc:subfields.</xd:p>
      <xd:p><xd:b>May be overwritten by importing stylesheets</xd:b> to use their own selection mechanism when multiple
        subfields are present.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield[@code = '0']">
    <xsl:variable name="refs" as="xs:string+">
      <xsl:apply-templates select="." mode="ref" />
    </xsl:variable>
    <!-- TODO: evaluate MARC field to use a different “prefix” -->
    <xsl:attribute name="ref"
      select="'per:' || ($refs[starts-with(., 'gnd')], $refs)[1]"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>MARC linking subfields</xd:desc>
  </xd:doc>
  <!-- TODO should the exact sequencing be reconstructed using @prev and @next? -->
  <xsl:template match="marc:subfield[@code = '8']">
    <xsl:attribute name="n" select="normalize-space()" />
  </xsl:template>
  
  <xd:doc>
    <xd:desc>subfield $d usually contains imprint information</xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield[@code = 'd']">
    <imprint>
      <xsl:apply-templates />
    </imprint>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>subfield $t usually contains a title</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield[@code = 't']">
    <title>
      <xsl:apply-templates />
    </title>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>subfield $w usually contains record control numbers or similar identifiers </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield[@code = 'w']">
    <idno type="MARC-Code">
      <xsl:attribute name="subtype" select="analyze-string(., '\w+-\d+')/*:match[1]" />
      <xsl:value-of select="substring-after(., ')')" />
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>public and non-public notes</xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield[@code = ('x', 'z')]">
    <note type="{if (@code = 'x') then 'non-' else ''}public">
      <xsl:apply-templates />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create a short form of and authority based on some form of identifier.</xd:p>
      <xd:p>Here, German ISIL are used and a few others. <xd:b>May be overwritten by importing stylesheets.</xd:b></xd:p>
    </xd:desc>
    <xd:param name="code">
      <xd:p>The code to be evaluated</xd:p>
    </xd:param>
  </xd:doc>
  <xsl:template name="auth">
    <xsl:param name="code" />
    <xsl:choose>
      <xsl:when test="$code='DE-101'">dnb</xsl:when>
      <xsl:when test="$code='DE-588'">gnd</xsl:when>
      <xsl:when test="$code='DE-603'">hebis</xsl:when>
      <xsl:otherwise>???</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>text() to be left unchanged</xd:desc>
  </xd:doc>
  <xsl:template match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
</xsl:stylesheet>