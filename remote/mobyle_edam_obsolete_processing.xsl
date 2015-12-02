<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:oboInOwl="http://www.geneontology.org/formats/oboInOwl#" >

    <xsl:variable name="edam" select="document('EDAM_1.8.owl')"/>

    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="operation/text()">
        <xsl:call-template name="owlClassObsoleteCheck">
            <xsl:with-param name="id"><xsl:value-of select="current()" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="topic/text()">
        <xsl:call-template name="owlClassObsoleteCheck">
            <xsl:with-param name="id"><xsl:value-of select="current()" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="data/text()">
        <xsl:call-template name="owlClassObsoleteCheck">
            <xsl:with-param name="id"><xsl:value-of select="current()" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="format/text()">
        <xsl:call-template name="owlClassObsoleteCheck">
            <xsl:with-param name="id"><xsl:value-of select="current()" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="owlClassObsoleteCheck">
         <xsl:param name="id"/>
         <xsl:choose>
             <xsl:when test="$edam//owl:Class[@rdf:about=$id]/owl:deprecated">
                 <xsl:comment><xsl:value-of select="$id" /> is deprecated and replaced by <xsl:value-of select="$edam//owl:Class[@rdf:about=$id]/oboInOwl:replacedBy/@rdf:resource" /></xsl:comment>
                 <xsl:value-of select="$edam//owl:Class[@rdf:about=$id]/oboInOwl:replacedBy/@rdf:resource" />
             </xsl:when>
             <xsl:otherwise>
                 <xsl:value-of select="$id" />
             </xsl:otherwise>
         </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
