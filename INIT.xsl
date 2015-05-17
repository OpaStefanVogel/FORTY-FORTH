<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
    <head>
      <link rel="stylesheet" href="INIT.css"/>
      </head>
    <body>
      <xsl:apply-templates />
      </body>
    </html>
  </xsl:template>

<xsl:template match="INIT"><INIT>zurück zu <a href="R11_ganze_Zahlen.xml">R11_ganze_Zahlen.xml</a>

Wozu die beiden Files INIT.xml und screenlog.xml verwendet werden:
  <a href="INIT.xml">INIT.xml</a>: FORTH-Interpreter recompilieren mit cp INIT.xml /dev/tty..
  <a href="screenlog.xml">screenlog.xml</a>: Logfile, welches dabei angefertigt wurde, 
    vor allem auch, um bequem die generierten Speicherarrays für P20_FFP.vhd entnehmen zu können.

Bedeutung der verwendeten Hintergrundfarben:
  <span style="background-color: Magenta;">Magenta</span> damit sind die Axiome eingerahmt
  <span style="background-color: Aqua;">Aqua</span> Überschriften aus der Inhaltsübersicht
  nur bei <a href="screenlog.xml">screenlog.xml</a>:
    <span style="background-color: LightGrey;">LightGrey</span> erreichte Speicheradressen vorm Weitercompilieren, Programm 0000H-1400H, Text E000H-FB00H
    <span style="background-color: Khaki;">Khaki</span> Programmausgaben des FORTH-Interpreters im xml-Ausgabemodus
    <span style="background-color: Pink;">Pink</span> generierte Speicherarrays zum Kopieren in P20_FFP.vhd hinein

  <h1 id="Inhalt">Inhalt:</h1>

  <ul>
    <xsl:for-each select="*/sekt">
      <li><a><xsl:attribute name="href">#<xsl:value-of select="@inhalt" /></xsl:attribute>
        <xsl:value-of select="@inhalt" />
        </a>
        <ul>
          <xsl:for-each select="sekt">
            <li><a><xsl:attribute name="href">#<xsl:value-of select="@inhalt" />
              </xsl:attribute>
              <xsl:value-of select="@inhalt" />
              </a>
              </li>
            </xsl:for-each>
          </ul>
        </li>
      </xsl:for-each>
    </ul>
  <xsl:apply-templates /></INIT>
  </xsl:template>

<xsl:template match="AXIOME">
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
    <a href="#Inhalt" class="zurück"> -----> zurück zur Übersicht</a>
    </div>
  <sekt><xsl:apply-templates /></sekt>
  </xsl:template>

<xsl:template match="REF1">
  <a href="https://de.wikipedia.org/wiki/Compiler#Einordnung_verschiedener_Compiler-Arten">multi-pass</a>
  </xsl:template>
  
<xsl:template match="table"><xsl:copy-of select="." /></xsl:template>

</xsl:stylesheet>
