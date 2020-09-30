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
    <xd:desc>Transform a MARC XML record into a tei:biblStruct or tei:biblFull (= tei:fileDesc)</xd:desc>
  </xd:doc>
  
  <xsl:output indent="1" omit-xml-declaration="1"/>
  
  <xd:doc>
    <xd:desc>Whether to create a biblStruct, a biblFull or a fileDesc</xd:desc>
  </xd:doc>
  <xsl:param name="type" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Main entry point. Will usually be overwritten by importing XSLT.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$type = 'biblStruct'">
        <xsl:apply-templates select="//marc:record" mode="biblStruct" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="//marc:record" mode="biblFull" />
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:param name="id" tunnel="1"/>
    <biblStruct>
      <xsl:if test="$id">
        <xsl:attribute name="xml:id" select="$id" />
      </xsl:if>
      <xsl:variable name="level">
        <xsl:variable name="code" select="substring(marc:leader, 8, 1)"/>
        <xsl:choose>
          <xsl:when test="$code = 'a'">analytic</xsl:when>
          <xsl:when test="$code = 'm'">monogr</xsl:when>
          <xsl:when test="$code = 's'">monogr</xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$level = ('monogr', 'series')">
          <monogr>
            <!-- title -->
            <xsl:apply-templates select="marc:datafield[@tag = '245']/*" mode="title" />
            <xsl:apply-templates select="marc:datafield[@tag = ('240')]" />
            
            <!-- ID of this record -->
            <xsl:apply-templates select="marc:controlfield[@tag = '001']
              | marc:datafield[@tag = ('015', '016', '020', '022', '024', '026')]" />
            
            <!-- author, editor, respStmt -->
            <xsl:apply-templates select="marc:datafield[@tag = ('100', '110')]" />
            
            <!-- language(s) -->
            <xsl:if test="marc:datafield[@tag = ('041', '546')]">
              <textLang>
                <xsl:if test="marc:datafield[@tag = '041']/marc:subfield[@code = 'a']">
                  <xsl:attribute name="mainLang" select="string(marc:datafield[@tag = '041']/marc:subfield[@code = 'a'][1])" />
                </xsl:if>
                <xsl:if test="count(marc:datafield[@tag = '041']/marc:subfield[@code = 'a']) gt 1">
                  <xsl:attribute name="otherLangs"
                    select="string-join(marc:datafield[@tag = '041']/marc:subfield[@code = 'a' and preceding-sibling::*[@code = 'a']], ' ')" />
                </xsl:if>
                <xsl:value-of select="marc:datafield[@tag = '546']/marc:subfield[@code = 'a']" />
              </textLang>
            </xsl:if>
            
            <xsl:apply-templates select="marc:datafield[@tag = ('247')]" />
            
            <!-- edition -->
            <xsl:apply-templates select="marc:datafield[@tag = ('250', '502')]" />
            
            <!-- imprint -->
            <xsl:apply-templates select="marc:datafield[@tag = ('260', '264')]" />
            
            <!-- extent -->
            <xsl:apply-templates select="marc:datafield[@tag = '300']/*" />
          </monogr>
        </xsl:when>
        <xsl:when test="$level = 'analytic'">
          <analytic>
            <!-- author, editor, respStmt -->
            <xsl:apply-templates select="marc:datafield[@tag = ('100', '110')]" />
            
            <!-- title -->
            <xsl:apply-templates select="marc:datafield[@tag = '245']/*" mode="title" />
            <xsl:apply-templates select="marc:datafield[@tag = ('240', '247')]" />
            
            <xsl:apply-templates select="marc:datafield[@tag = '264']/*[@code = 'c']">
              <xsl:with-param name="name">date</xsl:with-param>
            </xsl:apply-templates>
            
            <!-- language(s) -->
            <xsl:if test="marc:datafield[@tag = ('041', '546')]">
              <textLang>
                <xsl:if test="marc:datafield[@tag = '041']/marc:subfield[@code = 'a']">
                  <xsl:attribute name="mainLang" select="string(marc:datafield[@tag = '041']/marc:subfield[@code = 'a'][1])" />
                </xsl:if>
                <xsl:if test="count(marc:datafield[@tag = '041']/marc:subfield[@code = 'a']) gt 1">
                  <xsl:attribute name="otherLangs"
                    select="string-join(marc:datafield[@tag = '041']/marc:subfield[@code = 'a' and preceding-sibling::*[@code = 'a']], ' ')" />
                </xsl:if>
                <xsl:value-of select="marc:datafield[@tag = '546']/marc:subfield[@code = 'a']" />
              </textLang>
            </xsl:if>
            
            <!-- ID of this record -->
            <xsl:apply-templates select="marc:controlfield[@tag = '001']
              | marc:datafield[@tag = ('015', '016', '020', '022', '024')]" />
          </analytic>
          <monogr>
            <xsl:apply-templates select="*[@tag = '773']/*[@code = 'w'][1]" mode="attribute">
              <xsl:with-param name="name">source</xsl:with-param>
            </xsl:apply-templates>
            
            <!-- title fields -->
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 'a']">
              <xsl:with-param name="name">title</xsl:with-param>
              <xsl:with-param name="type">main</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 't']">
              <xsl:with-param name="name">title</xsl:with-param>
              <xsl:with-param name="type">title</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 's']">
              <xsl:with-param name="name">title</xsl:with-param>
              <xsl:with-param name="type">uniform-title</xsl:with-param>
            </xsl:apply-templates>
            
            <!-- identificator numbers -->
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 'x']">
              <xsl:with-param name="name">idno</xsl:with-param>
              <xsl:with-param name="type">issn</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 'z']">
              <xsl:with-param name="name">idno</xsl:with-param>
              <xsl:with-param name="type">isbn</xsl:with-param>
            </xsl:apply-templates>
            
            <!-- edition -->
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 'b']">
              <xsl:with-param name="name">edition</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:datafield[@tag = '250']" />
            
            <!-- imprint -->
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 'd']" mode="imprint"/>
            <xsl:apply-templates select="marc:datafield[@tag = '264']" />
            
            <!-- extent -->
            <xsl:apply-templates select="marc:datafield[@tag = '773']/marc:subfield[@code = 'h']">
              <xsl:with-param name="name">extent</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:datafield[@tag = '300']/*" />
          </monogr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$level"/>
        </xsl:otherwise>
      </xsl:choose>
      
      
      <!-- series and added entries-->
      <xsl:apply-templates select="marc:datafield[@tag = ('490')]" />
      <xsl:apply-templates select="marc:datafield[@tag = ('800', '810', '830')]" />
      
      <!-- notes -->
      <xsl:apply-templates select="marc:datafield[@tag = ('500', '501', '504', '510', '515', '520', '533', '550')]" />
      
      <!-- general annotations – no special TEI elements for these -->
      <!-- Classification numbers -->
      <xsl:apply-templates select="marc:datafield[@tag = ('082', '083', '084')]" />
      
      <!-- types -->
      <xsl:apply-templates select="marc:datafield[@tag = ('336', '337', '338')]" />
      
      <!-- dates and sequences -->
      <xsl:apply-templates select="marc:datafield[@tag = ('362', '363')]" />
      
      <!-- subject fields -->
      <xsl:apply-templates select="marc:datafield[@tag = ('600', '610', '630', '648', '650', '651', '655')]" />
      
      <!-- Additional entries -->
      <xsl:apply-templates select="marc:datafield[@tag = ('700', '710', '730')]"/>
      
      <!-- additional relationship entries -->
      <xsl:apply-templates select="marc:datafield[@tag = ('770', '772', '776', '780', '785')]" />
      <xsl:if test="$level != 'analytic'">
        <!-- for analytic, 773 will be evaluated as monogr -->
        <xsl:apply-templates select="marc:datafield[@tag = '773']" />
      </xsl:if>
      <xsl:apply-templates select="marc:datafield[@tag = '787'][1]" />
      
      <!-- Electronic Location and Access -->
      <xsl:apply-templates select="marc:datafield[@tag = '856']" />
      <!-- additional metadata entries -->
      <xsl:apply-templates select="marc:datafield[@tag = '883']" />
      
      <xsl:apply-templates select="marc:datafield[not(@tag
        = ('001', '015', '016', '020', '022', '024', '026', '028', '035', '040', '041', '043', '050', '082', '083',
           '084', '085', '090', '100', '110', '240', '245', '246', '247', '249', '250', '260', '264', '300', '336',
           '337', '338', '362', '363', '490', '500', '501', '502', '504', '510', '515', '520', '530', '533', '538',
           '546', '550', '555', '600', '610', '630', '648', '650', '651', '655', '700', '710', '730', '770', '772',
           '773', '776', '780', '785', '787', '800', '810', '830', '856', '883', '912', '924'))]" />
    </biblStruct>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Entry point for biblFull or fileDesc.</xd:p>
    </xd:desc>
    <xd:param name="id">
      <xd:p>If an @xml:id should be set, if can be provided with this param</xd:p>
    </xd:param>
  </xd:doc>
  <xsl:template match="marc:record" mode="biblFull">
    <xsl:param name="id" />
    <xsl:variable name="level">
      <xsl:variable name="code" select="substring(marc:leader, 8, 1)"/>
      <xsl:choose>
        <xsl:when test="$code = 'a'">analytic</xsl:when>
        <xsl:when test="$code = 'm'">monogr</xsl:when>
        <xsl:when test="$code = 's'">monogr</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <biblFull>
      <xsl:if test="$id">
        <xsl:attribute name="xml:id" select="$id" />
      </xsl:if>
      <fileDesc>
        <titleStmt>
          <!-- title fields -->
          <xsl:apply-templates select="*[@tag = '245']/*[@code = 'a']" mode="title" />
          <xsl:apply-templates select="*[@tag = '245']/*[@code = 'b']" mode="title" />
        </titleStmt>
        
        <editionStmt>
          <p>meta dataautomatically transformed from MARC21 by https://github.com/dariok/metadata2tei</p>
        </editionStmt>
        
        <publicationStmt>
          <xsl:variable name="imprints">
            <xsl:apply-templates select="marc:datafield[@tag = '264']" />
          </xsl:variable>
          <xsl:sequence select="$imprints/*/*"></xsl:sequence>
        </publicationStmt>
        
        <sourceDesc>
          <xsl:apply-templates select="." mode="biblStruct" />
        </sourceDesc>
      </fileDesc>
      <profileDesc>
        <langUsage>
          <xsl:for-each select="marc:datafield[@tag = '041']/marc:subfield[@code = 'a']">
            <language ident="{normalize-space()}" />
          </xsl:for-each>
        </langUsage>
      </profileDesc>
    </biblFull>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create an idno for the record.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:controlfield[@tag = '001']">
    <idno type="Control-Number" source="info:isil/{parent::*/marc:controlfield[@tag = '003']}">
      <xsl:value-of select="."/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Crete an idno from MARC 015 (number in national bilbiography)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '015']">
    <idno type="National-Bibliography" source="{marc:subfield[@code = '2']}">
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Crete an idno from MARC 016 (controlnumber in national library)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '016']">
    <idno type="National-Bibliographic-Agency" source="info:isil/{marc:subfield[@code = '2']}">
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Standard Identifiers (020, 022, 024) and fingerprint (026)</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('020', '022', '024', '026')]">
    <idno>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@tag = '020'">ISBN</xsl:when>
          <xsl:when test="@tag = '022'">ISSN</xsl:when>
          <xsl:when test="@tag = '024'">Other-Standard-Identifier</xsl:when>
          <xsl:when test="@tag = '026'">Fingerprint</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="marc:subfield[@code = 'a']"/>
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Classification Numbers: DDC</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('082', '083')]">
    <ref type="DDC">
      <xsl:if test="marc:subfield[@code = '2']">
        <xsl:attribute name="subtype" select="'edition_' || marc:subfield[@code = '2']" />
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 'a']">
        <xsl:attribute name="cRef" select="string-join(marc:subfield[@code = 'a'], '|')" />
      </xsl:if>
      <xsl:if test="marc:subfield[@code = '8']">
        <xsl:attribute name="n" select="marc:subfield[@code ='8']" />
      </xsl:if>
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Other Classification Number</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '084']">
    <ref type="Other-Classification" subtype="{marc:subfield[@code = '2']}" cRef="{marc:subfield[@code = 'a']}">
      <xsl:apply-templates select="marc:subfield[@code = '0']" mode="idno" />
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create an author, editor or respStmt element depending on the value of the “function” subfield. Uses the
        content of $e as element name in case an unknown value is encountered so these cases can be caught by schema
        validation.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('100', '110')]">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code = '4'] = ('edt')">editor</xsl:when>
        <xsl:when test="not(marc:subfield[@code = '4']) or marc:subfield[@code = '4'] = 'aut'">author</xsl:when>
        <xsl:otherwise>respStmt</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@tag = '100'">per</xsl:when>
        <xsl:when test="@tag = '110'">org</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="marc:subfield[@code = '0'][1]" mode="attribute">
        <xsl:with-param name="name">ref</xsl:with-param>
      </xsl:apply-templates>
      <xsl:choose>
        <xsl:when test="$name = 'respStmt'">
          <xsl:attribute name="ana" select="'https://id.loc.gov/vocabulary/relators/' || marc:subfield[@code = '4']" />
          <xsl:apply-templates select="marc:subfield[@code = 'a']" mode="resp">
            <xsl:with-param name="resp" select="marc:subfield[@code = 'e']" />
            <xsl:with-param name="type" select="$type" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <name type="{$type}">
            <xsl:value-of select="marc:subfield[@code = 'a']" />
          </name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Uniform Title</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '240']">
    <xsl:apply-templates select="*[@code = 'a']">
      <xsl:with-param name="name">title</xsl:with-param>
      <xsl:with-param name="type">Uniform-Title</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Former Title</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '247']">
    <note type="Former-Title">
      <xsl:apply-templates select="*[@code = ('a', 'b')]" mode="title" />
      <xsl:apply-templates select="*[@code = 'f']">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">date-sequential</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = ('n', 'p')]" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Information about the edition, created from MARC 205 (edition) or 502 (dissertation)</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('250', 502)]">
    <edition>
      <xsl:value-of select="marc:subfield[@code = 'a']" />
    </edition>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the imprint from 260 or 264.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('260', '264')]">
    <imprint>
      <xsl:apply-templates select="marc:subfield[@code = 'b']">
        <xsl:with-param name="name">publisher</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'a']">
        <xsl:with-param name="name">pubPlace</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = ('c')]">
        <xsl:with-param name="name">date</xsl:with-param>
      </xsl:apply-templates>
    </imprint>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create multiple extent from the data in 300</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '300']/marc:subfield">
    <extent>
      <xsl:attribute name="n">
        <xsl:choose>
          <xsl:when test="@code = 'a'">Extent</xsl:when>
          <xsl:when test="@code = 'b'">Physical-Details</xsl:when>
          <xsl:when test="@code = 'c'">Dimensions</xsl:when>
          <xsl:when test="@code = 'e'">Accompanying-Material</xsl:when>
          <xsl:when test="@code = 'f'">Type-of-Unit</xsl:when>
          <xsl:when test="@code = 'g'">Size-of-Unit</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates />
    </extent>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Content Type; Media Type; Carrier Type</xd:desc>
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
    <note type="{$type}" source="https://id.loc.gov/vocabulary/genreFormSchemes/{string(marc:subfield[@code='2'])}.html">
      <xsl:apply-templates select="*[@code = 'a']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">term</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = 'b']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">code</xsl:with-param>
      </xsl:apply-templates>
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Dates of Publication and/or Sequential Designation</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '362']">
    <note type="Dates-of-Publication">
      <xsl:value-of select="marc:subfield[@code = 'a']" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Normalized Date and Sequential Designation</xd:desc>
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
      <xsl:apply-templates select="marc:subfield[@code = '8']" mode="n" />
      <xsl:value-of select="string-join(marc:subfield[@code = ('a', 'b', 'c', 'd', 'e', 'f')], '-')" />
      <xsl:if test="marc:subfield[@code = ('g', 'h')]">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="string-join(marc:subfield[@code = ('g', 'h')], '-')" />
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="string-join(marc:subfield[@code = ('i', 'j', 'k', 'l')], '-')" />
      <xsl:apply-templates select="marc:subfield[@code = ('x')]">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">public</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = ('z')]">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">non-public</xsl:with-param>
      </xsl:apply-templates>
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create a series element for each MARC 490</xd:p>
    </xd:desc>
    <xd:param name="name">the name for the element: series (default) or seriesStmt</xd:param>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '490']">
    <xsl:param name="name">series</xsl:param>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="*[@code = ('a', 'v')]" mode="title" />
      <xsl:apply-templates select="*[@code = 'x']">
        <xsl:with-param name="name">idno</xsl:with-param>
        <xsl:with-param name="type">issn</xsl:with-param>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:note from MARC 500</xd:p>
    </xd:desc>
  </xd:doc>
  <!-- TODO try to parse info in specific subfields, esp. dimensions in $c -->
  <xsl:template match="marc:datafield[@tag = ('500', '501', '504', '515', '520', '550')]">
    <note>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@tag = '500'">General-Note</xsl:when>
          <xsl:when test="@tag = '501'">With-Note</xsl:when>
          <xsl:when test="@tag = '504'">Bibliography-Note</xsl:when>
          <xsl:when test="@tag = '515'">Numbering-Peculiarities-Note</xsl:when>
          <xsl:when test="@tag = '520'">Summary</xsl:when>
          <xsl:when test="@tag = '550'">Issuing-Body-Note</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="marc:subfield" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Reference Note</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '510']">
    <note type="Citation-Reference-Note">
      <xsl:apply-templates select="*[@code = 'a']">
        <xsl:with-param name="name">ref</xsl:with-param>
        <xsl:with-param name="type">source</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = 'c']">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">location</xsl:with-param>
      </xsl:apply-templates>
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Reproduction Note</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '533']">
    <note type="Reproduction-Note">
      <xsl:apply-templates select="*[@code = 'a']">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">display-text</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = 'b']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">place</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = 'c']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">org</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = 'd']">
        <xsl:with-param name="name">date</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="*[@code = 'e']">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">physical-description</xsl:with-param>
      </xsl:apply-templates>
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Subject Added Entries</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('600')]">
    <ref type="Subject-Added-Entry" source="https://id.loc.gov/vocabulary/subjectSchemes/{string(marc:subfield[@code='2'])}.html">
      <xsl:attribute name="subtype">
        <xsl:choose>
          <xsl:when test="@tag = '600'">Personal-Name</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="marc:subfield[@code = '0'][1]" mode="attribute">
        <xsl:with-param name="name">target</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'a']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">per</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'b']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">numeration</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'c']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">titles</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'd']">
        <xsl:with-param name="name">date</xsl:with-param>
      </xsl:apply-templates>
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Subject Added Entries</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('610', '630', '648', '650', '651')]">
    <ref type="Subject-Added-Entry" source="https://id.loc.gov/vocabulary/subjectSchemes/{string(marc:subfield[@code='2'])}.html">
      <xsl:attribute name="subtype">
        <xsl:choose>
          <xsl:when test="@tag = '610'">Corporate-Name</xsl:when>
          <xsl:when test="@tag = '630'">Uniform-Title</xsl:when>
          <xsl:when test="@tag = '648'">Chronological-Term</xsl:when>
          <xsl:when test="@tag = '650'">Topical-Term</xsl:when>
          <xsl:when test="@tag = '651'">Geographic-Name</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="marc:subfield[@code = '0'][1]" mode="attribute">
        <xsl:with-param name="name">target</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'a']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">main</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'b']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">subordinate</xsl:with-param>
      </xsl:apply-templates>
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Index Terms</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '655']">
    <ref type="Index-Term" subtype="Genre-Term" source="http://id.loc.gov/vocabulary/genreFormSchemes/{string(marc:subfield[@code='2'])}.html">
      <xsl:apply-templates select="marc:subfield[@code = '0'][1]" mode="attribute">
        <xsl:with-param name="name">target</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'a']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">main</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'b']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">subordinate</xsl:with-param>
      </xsl:apply-templates>
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Added Entries</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('700', '710')]">
    <ref type="Added-Entry" source="https://id.loc.gov/vocabulary/subjectSchemes/{string(marc:subfield[@code='2'])}.html">
      <xsl:attribute name="subtype">
        <xsl:choose>
          <xsl:when test="@tag = '700'">Personal-Name</xsl:when>
          <xsl:when test="@tag = '710'">Corporate-Name</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="marc:subfield[@code = '0'][1]" mode="attribute">
        <xsl:with-param name="name">target</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = '4']" mode="relator" />
      
      <xsl:apply-templates select="marc:subfield[@code = 'a']">
        <xsl:with-param name="name">name</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'b']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">
          <xsl:choose>
            <xsl:when test="@tag = '700'">numeration</xsl:when>
            <xsl:when test="@tag = '710'">subordinate</xsl:when>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'd']">
        <xsl:with-param name="name">note</xsl:with-param>
        <xsl:with-param name="type">date</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'e']">
        <xsl:with-param name="name">term</xsl:with-param>
        <xsl:with-param name="type">relator</xsl:with-param>
      </xsl:apply-templates>
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Added Entry: Uniform Title</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag ='730']">
    <note type="Added-Entry" subtype="Uniform-Title">
      <xsl:value-of select="*[@code = 'a']" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Additional Physical Form Entry</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('770', '772', '773', '776', '780', '785')]">
    <relatedItem>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@tag = '770'">Supplement-Entry</xsl:when>
          <xsl:when test="@tag = '772'">Supplementary-Parent-Entry</xsl:when>
          <xsl:when test="@tag = '773'">Host-Item-Entry</xsl:when>
          <xsl:when test="@tag = '776'">Additional-Physical-Form</xsl:when>
          <xsl:when test="@tag = '780'">Preceding-Entry</xsl:when>
          <xsl:when test="@tag = '785'">Succeeding-Entry</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:choose>
        <xsl:when test="not(*[@code = ('a', 'b', 'd', 't', 'x', 'z', 'h')]) and *[@code = 'w']">
          <xsl:apply-templates select="marc:subfield[@code = 'w'][1]" mode="attribute">
            <xsl:with-param name="name">target</xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <bibl>
            <xsl:apply-templates select="marc:subfield[@code = 'w'][1]" mode="attribute">
              <xsl:with-param name="name">source</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'i']">
              <xsl:with-param name="name">note</xsl:with-param>
              <xsl:with-param name="type">display-text</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'a']">
              <xsl:with-param name="name">title</xsl:with-param>
              <xsl:with-param name="type">main</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'b']">
              <xsl:with-param name="name">title</xsl:with-param>
              <xsl:with-param name="type">edition</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 't']">
              <xsl:with-param name="name">title</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'd']">
              <xsl:with-param name="name">note</xsl:with-param>
              <xsl:with-param name="type">imprint</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'x']">
              <xsl:with-param name="name">idno</xsl:with-param>
              <xsl:with-param name="type">issn</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'z']">
              <xsl:with-param name="name">idno</xsl:with-param>
              <xsl:with-param name="type">isbn</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="marc:subfield[@code = 'h']">
              <xsl:with-param name="name">extent</xsl:with-param>
            </xsl:apply-templates>
          </bibl>
        </xsl:otherwise>
      </xsl:choose>
    </relatedItem>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>List for: Other Relationshio entry</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '787']">
    <note type="other-relationship">
      <listBibl>
        <xsl:for-each select=". | following-sibling::*[@tag = '787']">
          <bibl>
            <xsl:apply-templates select="marc:subfield[@code = 'w']" mode="attribute">
              <xsl:with-param name="name">source</xsl:with-param>
            </xsl:apply-templates>
            <xsl:if test="marc:subfield[@code = 'i']">
              <note>
                <xsl:value-of select="marc:subfield[@code = 'i']" />
              </note>
            </xsl:if>
            <xsl:if test="marc:subfield[@code = 'a']">
              <author>
                <xsl:value-of select="marc:subfield[@code = 'a']" />
              </author>
            </xsl:if>
            <xsl:apply-templates select="marc:subfield[@code = 't']">
              <xsl:with-param name="name">title</xsl:with-param>
            </xsl:apply-templates>
          </bibl>
        </xsl:for-each>
      </listBibl>
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Series Added Entries</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('800', '810')]">
    <note type="Series-Added-Entry">
      <xsl:attribute name="subtype">
        <xsl:choose>
          <xsl:when test="@tag = '800'">Personal-Name</xsl:when>
          <xsl:when test="@tag = '810'">Corporate-Name</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="marc:subfield[@code = '7']" mode="n" />
      
      <xsl:apply-templates select="marc:subfield[@code = 't']">
        <xsl:with-param name="name">title</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'a']">
        <xsl:with-param name="name">name</xsl:with-param>
        <xsl:with-param name="type">
          <xsl:choose>
            <xsl:when test="@tag = '800'">per</xsl:when>
            <xsl:when test="@tag = '810'">org</xsl:when>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'd']">
        <xsl:with-param name="name">date</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="marc:subfield[@code = 'v']" mode="title" />
      <xsl:apply-templates select="marc:subfield[@code = 'w']" mode="idno" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Series Added Entry – Uniform Title</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '830']">
    <note type="Series-Added-Entry" subtype="Uniform-Title">
      <xsl:if test="marc:subfield[@code = '7']">
        <xsl:attribute name="n" select="marc:subfield[@code = '7']" />
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = ('a', 'v')]" mode="title" />
      <xsl:if test="marc:subfield[@code = '9']">
        <note type="volume-sortable">
          <xsl:value-of select="marc:subfield[@code = '9']" />
        </note>
      </xsl:if>
      <xsl:apply-templates select="marc:subfield[@code = 'w']" mode="idno" />
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Electronic Location and Access</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '856']">
    <ref>
      <xsl:apply-templates select="marc:subfield[@code = 'u'][1]" mode="attributeq">
        <xsl:with-param name="name">target</xsl:with-param>
      </xsl:apply-templates>
      <xsl:value-of select="marc:subfield[@code = '3']" />
    </ref>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Metadata provenance</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = '883']">
    <note type="Metadata-Provenance" corresp="{marc:subfield[@code = '8']}">
      <name type="org"><xsl:value-of select="marc:subfield[@code = 'q']" /></name>
    </note>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Fallback template for all unhandled marc:datafield</xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield" mode="#all">
    <xsl:text>[unhandled data field: </xsl:text>
    <xsl:value-of select="@tag"/>
    <xsl:text>] </xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>create an attribute by converting MARC () notation to URI and concatenating siblings</xd:desc>
    <xd:param name="name"><xd:b>required:</xd:b> the name of the attribute</xd:param>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="attribute">
    <xsl:param name="name" required="1" />
    
    <xsl:variable name="code" select="@code" />
    <xsl:variable name="siblings" select="following-sibling::*[@code = $code]" />
    <xsl:variable name="refs" as="xs:string+">
      <xsl:for-each select=". | $siblings">
        <xsl:value-of select="translate(., ')(', ':')"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:attribute name="{$name}">
      <xsl:value-of select="string-join($refs, ' ')" />
    </xsl:attribute>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create respStmt from subfield with an optional resp</xd:p>
    </xd:desc>
    <xd:param name="type"><xd:b>required:</xd:b> the type of name (e. g. per, org)</xd:param>
    <xd:param name="resp"><xd:b>optional:</xd:b> content for an optional tei:resp</xd:param>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="resp">
    <xsl:param name="type" required="1" />
    <xsl:param name="resp" />
    
    <respStmt>
      <xsl:if test="$resp">
        <resp>
          <xsl:value-of select="$resp"/>
        </resp>
      </xsl:if>
  
      <name type="{$type}">
        <xsl:value-of select="." />
      </name>
    </respStmt>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>create element from a subfield</xd:desc>
    <xd:param name="name"><xd:b>required:</xd:b> the name for the element to be created</xd:param>
    <xd:param name="type"><xd:b>optional:</xd:b> a value for a type attribute</xd:param>
  </xd:doc>
  <xsl:template match="marc:subfield">
    <xsl:param name="name" required="1" />
    <xsl:param name="type" />
    
    <xsl:element name="{$name}">
      <xsl:if test="$type">
        <xsl:attribute name="type" select="$type" />
      </xsl:if>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>create idno from $0</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="idno">
    <idno source="info:isil/{analyze-string(., '\w+-\d+')/*:match[1]}">
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="parent::*/@tag = ('800', '810', '830')">bibliographic-record-control-number</xsl:when>
          <xsl:when test="parent::*/@tag = ('082', '084', '700', '710')">authority-record-control-number</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="substring-after(., ')')" />
    </idno>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Try to parse data of a combined field as imprint</xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="imprint">
    <xsl:analyze-string select="." regex="(.*) : (.*), (.*)">
      <xsl:matching-substring>
        <imprint>
          <pubPlace>
            <xsl:value-of select="regex-group(1)" />
          </pubPlace>
          <publisher>
            <xsl:value-of select="regex-group(2)" />
          </publisher>
          <date>
            <xsl:value-of select="regex-group(3)" />
          </date>
        </imprint>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  
  <xd:doc>
    <xd:desc>
      <xd:p>Create a title from a subfield</xd:p>
      <xd:p>As these usually are considered “title”-fields by the cataloguer, no specialised elemenrs are used.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="title">
    <title>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@code = 'a'">main</xsl:when>
          <xsl:when test="@code = 'b'">sub</xsl:when>
          <xsl:when test="@code = 'c'">resp</xsl:when>
          <xsl:when test="@code = 'h'">medium</xsl:when>
          <xsl:when test="@code = 'n'">partNumber</xsl:when>
          <xsl:when test="@code = 'p'">partName</xsl:when>
          <xsl:when test="@code = 'v'">sequencial</xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates />
    </title>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create attribute ana from a subfield with a MARC relator</xd:desc>
  </xd:doc>
  <xsl:template match="marc:subfield" mode="relator">
    <xsl:attribute name="ana" select="'https://id.loc.gov/vocabulary/relators/' || ." />
  </xsl:template>
  
  <xd:doc>
    <xd:desc>MARC linking subfields</xd:desc>
  </xd:doc>
  <!-- TODO should the exact sequencing be reconstructed using @prev and @next? -->
  <xsl:template match="marc:subfield" mode="n">
    <xsl:attribute name="n" select="normalize-space()" />
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:biblScope</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="marc:datafield[@tag = ('490', '810', '830')]/marc:subfield[@code = 'v'] | marc:datafield[@tag = '773']/marc:subfield[@code = 'q']">
    <biblScope unit="volume">
      <xsl:value-of select="." />
    </biblScope>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>text() to be left unchanged</xd:desc>
  </xd:doc>
  <xsl:template match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
</xsl:stylesheet>