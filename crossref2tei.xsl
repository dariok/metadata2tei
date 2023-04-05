<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="#all"
   version="3.0">
   
   <xsl:output indent="1" />
   
   <xsl:param name="id" required="yes" />
   
   <xsl:template match="/">
      <TEI xml:id="{$id}">
         <xsl:apply-templates select="fn:map" />
         <text>
            <body />
         </text>
      </TEI>
   </xsl:template>
   
   <xsl:template match="/fn:map">
      <teiHeader>
         <fileDesc>
            <titleStmt>
               <xsl:apply-templates select="fn:array[@key = 'title']" />
               <xsl:apply-templates select="fn:array[@key = 'author']" mode="titleStmt" />
            </titleStmt>
            <editionStmt>
               <edition>Elektronische Ausgabe nach TEI P5</edition>
               <respStmt>
                  <resp ref="http://id.loc.gov/vocabulary/relators/mrk">Ersteller der TEI-Fassung</resp>
                  <orgName>Universitäts- und Landesbibliothek Darmstadt</orgName>
               </respStmt>
            </editionStmt>
            <publicationStmt>
               <distributor ref="http://d-nb.info/gnd/10073682-8">
                  <email>wdm@ulb.tu-darmstadt.de</email>
                  <orgName role="hostingInstitution">Universitäts- und Landesbibliothek Darmstadt</orgName>
                  <idno type="ISIL">http://lobid.org/organisation/DE-17</idno>
                  <idno type="ISNI">http://www.isni.org/0000000110101946</idno>
                  <idno type="GND">http://d-nb.info/gnd/10073682-8</idno>
                  <address>
                     <addrLine>Magdalenenstr. 8, 64289 Darmstadt</addrLine>
                     <country>Germany</country>
                  </address>
               </distributor>
               <pubPlace ref="https://d-nb.info/gnd/4011077-1">
                  <placeName>Darmstadt</placeName>
               </pubPlace>
               <availability>
                  <licence target="https://creativecommons.org/licenses/by/4.0">CC BY 4.0</licence>
                  <p xml:lang="en">This file is licensed under the terms of the Creative Commons License CC BY 4.0 (Attribution 4.0 International)</p>
               </availability>
               <date when="{current-date()}">
                  <xsl:value-of select="current-date() => string() => substring(1, 4)"/>
               </date>
            </publicationStmt>
            <sourceDesc>
               <biblStruct>
                  <analytic>
                     <xsl:apply-templates select="fn:array[@key = 'title']">
                        <xsl:with-param name="level">a</xsl:with-param>
                     </xsl:apply-templates>
                     <xsl:apply-templates select="fn:array[@key = 'author']" mode="titleStmt" />
                     <xsl:apply-templates select="*[@key = 'DOI']" />
                     <xsl:apply-templates select="*[@key = 'license']/*" />
                  </analytic>
                  <monogr>
                     <xsl:apply-templates select="*[@key = 'container-title']">
                        <xsl:with-param name="level">m</xsl:with-param>
                     </xsl:apply-templates>
                     <imprint>
                        <xsl:apply-templates select="*[@key = 'publisher']" />
                        <xsl:apply-templates select="*[@key = 'published-online']" />
                        <xsl:apply-templates select="*[@key = 'journal-issue']//fn:number[1]" mode="scope">
                           <xsl:with-param name="unit">year</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="*[@key = 'volume']" mode="scope">
                           <xsl:with-param name="unit">volume</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="*[@key = 'issue']" mode="scope">
                           <xsl:with-param name="unit">issue</xsl:with-param>
                        </xsl:apply-templates>
                     </imprint>
                  </monogr>
                  <series>
                     <xsl:apply-templates select="*[@key = 'container-title']">
                        <xsl:with-param name="level">j</xsl:with-param>
                     </xsl:apply-templates>
                     <xsl:apply-templates select="*[@key = 'short-container-title']">
                        <xsl:with-param name="level">j</xsl:with-param>
                     </xsl:apply-templates>
                     <xsl:apply-templates select="*[@key = 'ISSN']" mode="idno" />
                  </series>
               </biblStruct>
            </sourceDesc>
         </fileDesc>
         <encodingDesc>
            <p xml:lang="de">Automatische Konversion der digitalen Vorlage mittels</p>
            <p xml:lang="en">The digital source has been converted using</p>
            <p>
               <ref target="">Workflow Digitale Medien @ ULB Darmstadt</ref>
            </p>
         </encodingDesc>
         <profileDesc>
            <xsl:apply-templates select="*[@key = 'abstract']" />
            <xsl:apply-templates select="*[@key = 'subject']" />
            <xsl:apply-templates select="*[@key = 'language']" />
         </profileDesc>
         <revisionDesc status="embargoed">
            <change status="automaticConversion"
               who="#toolbox"
               when="{fn:current-dateTime()}"/>
         </revisionDesc>
      </teiHeader>
      <standOff>
         <listPerson source="https://api.crossref.org/v1/works/{normalize-space(*[@key = 'DOI'])}">
            <xsl:apply-templates select="*[@key = 'author']/*" mode="list" />
         </listPerson>
      </standOff>
   </xsl:template>
   
   <xsl:template match="*[@key = 'publisher']">
      <publisher ref="#{fn:generate-id()}">
         <xsl:value-of select="." />
      </publisher>
   </xsl:template>
   
   <xsl:template match="*[@key = 'published-online']">
      <date type="{@key}" when="{string-join(descendant::fn:number, '-')}" />
   </xsl:template>
   
   <xsl:template match="*[@key = 'DOI']">
      <idno type="DOI">
         <xsl:value-of select="." />
      </idno>
   </xsl:template>
   
   <xsl:template match="*[@key = ('title', 'container-title', 'short-container-title')]">
      <xsl:param name="level" />
      <title>
         <xsl:if test="$level">
            <xsl:attribute name="level" select="$level" />
         </xsl:if>
         <xsl:if test="contains(@key, 'short')">
            <xsl:attribute name="type">abbr</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*" />
      </title>
   </xsl:template>
   
   <xsl:template match="*[@key = 'author']/fn:map" mode="titleStmt">
      <author ref="#{fn:generate-id()}">
         <persName>
            <xsl:value-of select="*[@key = 'family']" />
            <xsl:if test="*[@key = 'family'] and *[@key = 'given']">
               <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="*[@key = 'given']" />
         </persName>
      </author>
   </xsl:template>
   
   <xsl:template match="*[@key = 'author']/fn:map" mode="list">
      <person xml:id="{fn:generate-id()}">
         <persName>
            <xsl:apply-templates select="*[@key = 'family']" />
            <xsl:apply-templates select="*[@key = 'given']" />
         </persName>
         <xsl:apply-templates select="*[@key = 'ORCID']" mode="idno" />
         <xsl:apply-templates select="*[@key = 'affiliation']/*" />
      </person>
   </xsl:template>
   
   <xsl:template match="*[@key = 'family']">
      <surname>
         <xsl:value-of select="."/>
      </surname>
   </xsl:template>
   
   <xsl:template match="*[@key = 'given']">
      <forename>
         <xsl:value-of select="."/>
      </forename>
   </xsl:template>
   
   <xsl:template match="*[@key = 'affiliation']/*">
      <affiliation>
         <xsl:value-of select="fn:normalize-space()" />
      </affiliation>
   </xsl:template>
   
   <xsl:template match="*" mode="scope">
      <xsl:param name="unit" />
      <biblScope unit="{$unit}">
         <xsl:value-of select="." />
      </biblScope>
   </xsl:template>
   
   <xsl:template match="*" mode="idno">
      <idno type="{@key}">
         <xsl:value-of select="normalize-space()" />
      </idno>
   </xsl:template>
   
   <xsl:template match="*[@key = 'license']/*">
      <availability>
         <licence target="{normalize-space(*[@key = 'URL'])}">
            <xsl:apply-templates select="*[@key = 'start']" />
         </licence>
      </availability>
   </xsl:template>
   
   <xsl:template match="*[@key = 'start']">
      <xsl:attribute name="notBefore" select="substring(*[@key = 'date-time'], 1, 10)" />
   </xsl:template>
   
   <xsl:template match="*[@key = 'abstract']">
      <abstract>
         <p>
            <xsl:value-of select="fn:normalize-space()" />
         </p>
      </abstract>
   </xsl:template>
   
   <xsl:template match="*[@key = 'subject']">
      <textClass>
         <keywords>
            <xsl:apply-templates select="*" />
         </keywords>
      </textClass>
   </xsl:template>
   
   <xsl:template match="*[@key = 'subject']/*">
      <term>
         <xsl:value-of select="fn:normalize-space()" />
      </term>
   </xsl:template>
   
   <xsl:template match="*[@key = 'language']">
      <langUsage>
         <language ident="{normalize-space()}" />
      </langUsage>
   </xsl:template>
</xsl:stylesheet>