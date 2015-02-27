<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
<html>
  <head>
    <!--> ursprüngliches layout geändert bei:
       Monospace Font für section und code
       ein mdash ersetzt durch #x2014
       user-scalable=no in yes umgeschrieben
       stylesheet R00.css ergänzt
    <!-->
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="chrome=1"/>
    <title>Step ?</title>

    <link rel="stylesheet" href="stylesheets/styles.css"/>
    <link rel="stylesheet" href="stylesheets/pygment_trac.css"/>
    <script src="javascripts/scale.fix.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=yes"/>

    <!--[if lt IE 9]>
    <script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <link rel="stylesheet" href="R00.css"/>
  </head>
  <body style="white-space: pre-wrap;">
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

    <section>
      <xsl:apply-templates />
      </section>
      </div>

    <footer>
      <p>Project maintained by <a href="https://github.com/OpaStefanVogel">OpaStefanVogel</a></p>
      <p>Hosted on GitHub Pages &#x2014; Theme by <a href="https://github.com/orderedlist">orderedlist</a></p>

    </footer>

  </body>
</html>

  </xsl:template>


<xsl:template match="term">Terminal: <i>your-repo&amp; ...</i>
<pre><code><xsl:apply-templates /></code></pre>
  </xsl:template>
<xsl:template match="tterm">Tcl Console: <i>"Type a Tcl command here"</i>
  <pre><code><xsl:apply-templates /></code></pre>
  </xsl:template>

<xsl:template match="a"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="table"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="code"><xsl:copy-of select="." /></xsl:template>
<xsl:template match="i"><xsl:copy-of select="." /></xsl:template>

<xsl:template match="favicon"><img src="favicon.ico"/></xsl:template>
<xsl:template match="ffterm">
  <img src="favicon.ico" style="vertical-align:top"/>
  <div class="ffterm"><xsl:apply-templates /></div>
  </xsl:template>

</xsl:stylesheet>
