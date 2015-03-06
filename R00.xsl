<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output 
  doctype-public="-//W3C//DTD XHTML 1.1//EN"
  doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>
<xsl:template match="/">

<html><xsl:attribute name="xmlns">http://www.w3.org/1999/xhtml</xsl:attribute>
  <head>
    <!--> ursprüngliches layout geändert bei:
       <meta..> in <meta.../> geändert und so.
       Monospace Font für section und code
       ein mdash ersetzt durch #x2014
       user-scalable=no in yes umgeschrieben
       stylesheet R00.css ergänzt
       title auch automatisch select="los/step"
       DOCTYPE HTML5 in XHTML 1.1, xmlns mittels xsl:attribute
       meta Cache-Control und ETag ergänzt
    <!-->
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="chrome=1"/>
    <meta http-equiv="Cache-Control" content="max-age=86400"/>
    <meta http-equiv="ETag" content="x234dff"/>
    <title><xsl:value-of select="los/step" /></title>

    <link rel="stylesheet" href="stylesheets/styles.css"/>
    <link rel="stylesheet" href="stylesheets/pygment_trac.css"/>
    <script src="javascripts/scale.fix.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=yes"/>

    <!--[if lt IE 9]>
    <script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <link rel="stylesheet" href="R00.css"/>
  </head>
  <body>
    <div class="wrapper">
      <header>
        <h1>FORTY-FORTH</h1>
        <p>Ohne Rundungsfehler Gleichungssysteme lösen</p>
        <p class="view"><a href="https://github.com/OpaStefanVogel/FORTY-FORTH">View the Project on GitHub <small>OpaStefanVogel/FORTY-FORTH</small></a></p>
        <ul>
          <li><a href="https://github.com/OpaStefanVogel/FORTY-FORTH/zipball/master">Download <strong>ZIP File</strong></a></li>
          <li><a href="https://github.com/OpaStefanVogel/FORTY-FORTH/tarball/master">Download <strong>TAR Ball</strong></a></li>
          <li><a href="https://github.com/OpaStefanVogel/FORTY-FORTH">View On <strong>GitHub</strong></a></li>
        </ul>
      </header>
      
      <section><span class="section"><xsl:apply-templates /></span></section>
      
      </div>

    <footer>
      <p>Project maintained by <a href="https://github.com/OpaStefanVogel">OpaStefanVogel</a></p>
      <p>Hosted on GitHub Pages &#x2014; Theme by <a href="https://github.com/orderedlist">orderedlist</a></p>

    </footer>

  </body>
</html>

  </xsl:template>


<xsl:template match="term0">Terminal: <i>&amp;</i><pre><code><xsl:apply-templates /></code></pre></xsl:template>
<xsl:template match="term"><span id="Terminal">Terminal-1: <i>your-master-repo&amp; </i></span><pre><code><xsl:apply-templates /></code></pre></xsl:template>
<xsl:template match="sterm">Terminal-2: <i>your-Spartan3-repo&amp; </i><pre><code><xsl:apply-templates /></code></pre></xsl:template>
<xsl:template match="yterm">Terminal-3: <i>beliebig&amp; </i><pre><code><xsl:apply-templates /></code></pre></xsl:template>
<xsl:template match="tterm">Tcl Console: <i>"Type a Tcl command here"</i><pre><code><xsl:apply-templates /></code></pre></xsl:template>

<xsl:template match="a"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="table"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="code"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="i"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="step"><span class="zurueck">zum <a href="#Terminal">Terminal</a> oder <a href="index.html#Inhalt">zurück zu Inhalt</a></span></xsl:template>
<xsl:template match="weiter">Das war Step <xsl:value-of select="/los/step" />
weiter mit <span class="zurueck"><a href="index.html#Inhalt">oder zurück zu Inhalt.</a></span></xsl:template>

<xsl:template match="favicon"><img src="favicon.ico"/></xsl:template>
<xsl:template match="ffterm">
  <img src="favicon.ico" style="vertical-align:top"/>
  <div class="ffterm"><xsl:apply-templates /></div>
  </xsl:template>
<xsl:template match="u">
  <span class="Nutzereingabe"><xsl:apply-templates /></span>
  </xsl:template>

<xsl:template match="diff"><span><a><xsl:attribute name="href">https://github.com/OpaStefanVogel/FORTY-FORTH/compare/<xsl:value-of select="." />
</xsl:attribute><xsl:value-of select="." /></a></span></xsl:template>




</xsl:stylesheet>
