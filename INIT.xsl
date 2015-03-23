<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output 
  doctype-public="-//W3C//DTD XHTML 1.1//EN"
  doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

<xsl:template match="/">
  <html><xsl:attribute name="xmlns">http://www.w3.org/1999/xhtml</xsl:attribute>
    <head>
      <link rel="stylesheet" href="INIT.css"/>
      </head>
    <body>
      <xsl:apply-templates />
      </body>
    </html>
  </xsl:template>

<xsl:template match="INIT"><INIT>
  <h1 id="Übersicht">Übersicht</h1>
  <ul>
    <xsl:for-each select="//sekt">
      <li><a><xsl:attribute name="href">#<xsl:value-of select="@inhalt" /></xsl:attribute>
        <xsl:value-of select="@inhalt" />
        </a></li>
      </xsl:for-each>
    </ul>
  <xsl:apply-templates /></INIT>
  </xsl:template>

<xsl:template match="AXIOME">
  <div>AXIOME </div>
  <AXIOME><xsl:apply-templates /></AXIOME>
  </xsl:template>

<xsl:template match="ok">
  <xsl:copy-of select="." />
  </xsl:template>

<xsl:template match="fl">
  <xsl:copy-of select="." />
  </xsl:template>

<xsl:template match="fr">
  <xsl:copy-of select="." />
  </xsl:template>

<xsl:template match="DUMPZ">
  <xsl:copy-of select="." />
  </xsl:template>

<xsl:template match="sekt">
  <div class="VorSekt">
    <xsl:attribute name="id"><xsl:value-of select="@inhalt" /></xsl:attribute>
    <xsl:value-of select="@inhalt" />
    <a href="#Übersicht"> -----> zurück zur Übersicht</a>
    </div>
  <sekt><xsl:apply-templates /></sekt>
  </xsl:template>

</xsl:stylesheet>
