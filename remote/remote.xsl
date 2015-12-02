<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://bio.tools" xsi:schemaLocation="http://bio.tools/resources/biotools-1.4/biotools-1.4.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

    <xsl:param name="mobyle_root" select="mobyle_root"/>

    <xsl:param name="mobyle_contact" select="mobyle_contact"/>

    <xsl:variable name="operations" select="document('mobyle_operations.xml')"/>
    <xsl:variable name="topics" select="document('mobyle_topics.xml')"/>
    <xsl:variable name="data" select="document('mobyle_data.xml')"/>
    <xsl:variable name="formats" select="document('mobyle_formats.xml')"/>

    <xsl:variable name="edam" select="document('EDAM_1.8.owl')"/>

    <xsl:template match="/*">
        <resources xsi:schemaLocation="http://biotoolsregistry.org biotools-1.3.xsd" >
        <resource>
                <name>
<!--
                    <xsl:text>Mobyle_</xsl:text>
                    <xsl:if test="head/package/name">
                        <xsl:value-of select="head/package/name/text()" />
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="head/package/version/text()" />
                        <xsl:text>_</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="head/name/text()" />
                    <xsl:if test="head/version">
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="head/version/text()" />
                    </xsl:if>
-->
                    <xsl:value-of select="head/name/text()" />
                </name>
                <homepage><xsl:value-of select="$mobyle_root" />/#forms::<xsl:value-of select="head/name/text()" /></homepage>
                <version><xsl:value-of select="head/version/text()" /><xsl:value-of select="head/package/version/text()" /></version>
                <collection>Mobyle</collection>
                <xsl:if test="head/package">
                    <collection><xsl:value-of select="head/package/name/text()" />_<xsl:value-of select="head/package/version/text()" /></collection>
                </xsl:if>
                <resourceType>Tool</resourceType>
                <interface>
                    <interfaceType>Web UI</interfaceType>
                </interface>
                <description><xsl:value-of select="head/doc/description/text/text()" /></description>
                <xsl:for-each select="$topics//tool[@name=current()/head/name/text()]/topic">
                    <topic uri="{text()}">
                        <xsl:call-template name="owlClassLabel"> 
                            <xsl:with-param name="id"><xsl:value-of select="current()/text()" /></xsl:with-param>
                        </xsl:call-template>
                    </topic>
                </xsl:for-each>
                <function>
                    <xsl:for-each select="$operations//tool[@name=current()/head/name/text()]/operation">
                        <functionName uri="{text()}">
                            <xsl:call-template name="owlClassLabel">
                                <xsl:with-param name="id"><xsl:value-of select="current()/text()" /></xsl:with-param>
                            </xsl:call-template>
                        </functionName>
                    </xsl:for-each>

                    <xsl:for-each select="parameters//parameter[not(@isout) and not(@isstdout) and not(@ishidden)]">
			<xsl:apply-templates select="."/>
                    </xsl:for-each>

                    <xsl:for-each select="parameters//parameter[@isout or @isstdout]">
			<xsl:apply-templates select="."/>
                    </xsl:for-each>

                </function>
                <contact>
                    <contactEmail><xsl:value-of select="$mobyle_contact" /></contactEmail>
                    <contactRole>General</contactRole>
                </contact>
                <!--
                <docs>
                    <xsl:apply-templates select="head/doc/doclink" />
                </docs>
                -->
                <publications>
                    <publicationsPrimaryID>10.1093/bioinformatics/btp493</publicationsPrimaryID>
                    <xsl:apply-templates select="head/doc/reference/@doi" />
                </publications>
                <credits>
                    <xsl:apply-templates select="head/doc/authors" />
                </credits>
                <!--
                <xsl:apply-templates select="head/doc/homepagelink" />
                -->
        </resource>
        </resources>
    </xsl:template>

    <xsl:template match="authors">
        <creditsContributor><xsl:value-of select="text()" /></creditsContributor>
    </xsl:template>

    <xsl:template match="doclink">
        <docsHome><xsl:value-of select="text()" /></docsHome>
    </xsl:template>

    <xsl:template match="homepagelink">
        <homepage><xsl:value-of select="text()" /></homepage>
    </xsl:template>

    <xsl:template match="reference/@doi">
        <publicationsOtherID><xsl:value-of select="." /></publicationsOtherID>
    </xsl:template>

    <xsl:template name="owlClassLabel">
         <xsl:param name="id"/>
         <xsl:value-of select="$edam//owl:Class[@rdf:about=$id]/rdfs:label/text()"/>
    </xsl:template>

    <xsl:template match="parameter">
        <xsl:variable name="mobyle_class">
            <xsl:choose>
                <xsl:when test="type/datatype/superclass/text()">
                    <xsl:value-of select="type/datatype/superclass/text()" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="type/datatype/class/text()" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="parameter_type">
            <xsl:choose>
                <xsl:when test="@isout or @isstdout">output</xsl:when>
                <xsl:otherwise>input</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$data/datas/data[@name=$mobyle_class]">
            <xsl:element name="{$parameter_type}">
		<dataType uri="{$data/datas/data[@name=$mobyle_class]/text()}">
		    <xsl:call-template name="owlClassLabel">
			<xsl:with-param name="id">
			    <xsl:value-of select="$data/datas/data[@name=$mobyle_class]/text()" />
			</xsl:with-param>
		    </xsl:call-template>
		</dataType>
                <xsl:if test="$formats/formats/format[@name=current()/type/dataFormat/text()]/text()">
			<dataFormat uri="{$formats/formats/format[@name=current()/type/dataFormat/text()]/text()}">
			    <xsl:call-template name="owlClassLabel">
				<xsl:with-param name="id">
				    <xsl:value-of select="$formats/formats/format[@name=current()/type/dataFormat/text()]/text()" />
				</xsl:with-param>
			    </xsl:call-template>
			</dataFormat>
                </xsl:if>
		<dataHandle><xsl:value-of select="name/text()" /></dataHandle>
            </xsl:element>
        </xsl:if>



    </xsl:template>

</xsl:stylesheet>
