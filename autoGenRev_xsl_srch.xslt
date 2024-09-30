<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:msxsl="urn:schemas-microsoft-com:xslt"
 xmlns:exslt="http://exslt.org/common"
 xmlns:xyz="http://www.w3.org/1999/XSL/Transform-alias"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="msxsl exslt xsi">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>
    <xsl:preserve-space elements="*"/>
	<xsl:param name="sort1" select="'p4'"/>
	<xsl:param name="sort2" select="''"/>
	<xsl:param name="sort3" select="''"/>
	<xsl:param name="sort4" select="''"/>
	<xsl:param name="sortDir1" select="'asc'"/>
	<xsl:param name="sortDir2" select="''"/>
	<xsl:param name="sortDir3" select="''"/>
	<xsl:param name="sortDir4" select="''"/>
	<xsl:param name="search" select="'x'"/>
	<xsl:param name="pageNo" select="'1'"/>
	<xsl:param name="numPerPage" select="'200'"/>
  	<xsl:variable name="vLC" select="'abcdefghijklmnopqrstuvwxyz'"/>
  	<xsl:variable name="vUC" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="vMap">	
		<xsl:variable name="numAttsRow1x" select="count(//*[count(ancestor::*)=0]/child::*[1]/@*)"/>		
		<xsl:variable name="ordOfRowToUseForMappings">
			<xsl:choose>
				<xsl:when test="count(//*[count(ancestor::*)=0]/child::*[count(@*)!=$numAttsRow1x])=0">1</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="iMaxNumberOfAtts">
						<xsl:call-template name="getMaxNumberOfAtts">
							<xsl:with-param name="ord" select="0"/>
							<xsl:with-param name="vList" select="//*[count(ancestor::*)=0]/child::*"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="row1stMax" select="//*[count(ancestor::*)=0]/child::*[count(@*)=$iMaxNumberOfAtts][1]"/>
					<xsl:value-of select="count($row1stMax/preceding-sibling::*)+1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	
		<map>		
			<xsl:for-each select="//*[count(ancestor::*)=0]/child::*[number($ordOfRowToUseForMappings)]/@*">
				<xsl:variable name="pos" select="position()"/>
				<xsl:element name="att">
					<xsl:attribute name="pre">
						<xsl:value-of select="name()"/>
					</xsl:attribute>
					<xsl:attribute name="post"><xsl:value-of select="concat('p',$pos)"/></xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</map>
	</xsl:variable>
   	<msxsl:script language="javascript" implements-prefix="exslt">
    this['node-set'] =  function (x) {
    return x;
    }
   	</msxsl:script>
   	
	<xsl:template match="/">	
		<xsl:call-template name="template1"/>
	</xsl:template>
	
	<xsl:template name="template1"><xyz:stylesheet version="1.0" xmlns__msxsl="urn:schemas-microsoft-com:xslt" xmlns__exslt="http://exslt.org/common" exclude-result-prefixes="msxsl exslt"><xsl:text>
  </xsl:text><xyz:param name="search" select="'{$search}'"/><xsl:text>
  	</xsl:text><xyz:param name="pageNo" select="'{$pageNo}'"/><xsl:text>
  	</xsl:text><xyz:param name="numPerPage" select="'{$numPerPage}'"/><xsl:text>
   	</xsl:text><msxsl__script language="javascript" implements-prefix="exslt"><xsl:text>
  	</xsl:text>this['node-set'] =  function (x) {<xsl:text>
  	</xsl:text>return x;<xsl:text>
  	</xsl:text>}
   	</msxsl__script><xsl:text>
  	</xsl:text>
  <xyz:template match="/"><xsl:text>
  	</xsl:text><xyz:variable name="vLC" select="'{$vLC}'"/><xsl:text>
  	</xsl:text><xyz:variable name="vUC" select="'{$vUC}'"/><xsl:text>
    </xsl:text><xyz:variable name="pass1"><xyz:element name="{name(//*[count(ancestor::*)=0])}"><xyz:text>__CR__
 		</xyz:text><xyz:for-each select="{concat(name(//*[count(ancestor::*)=0]),'/child::*')}">
		<xsl:call-template name="templateA">
			<xsl:with-param name="int" select="1"/>
		</xsl:call-template><xsl:text>
  		</xsl:text></xyz:for-each></xyz:element></xyz:variable><xsl:text>
  </xsl:text><xsl:text>
  </xsl:text><xyz:variable name="numRowsNow" select="count(exslt:node-set($pass1)/child::*[1]/child::*)"/>	<xsl:text>
  </xsl:text><xyz:variable name="pageNoNow"><xsl:text>
  	</xsl:text><xyz:choose><xsl:text>
      </xsl:text><xyz:when test="($pageNo * $numPerPage) &gt; $numRowsNow"><xsl:text>
          </xsl:text><xyz:value-of select="ceiling($numRowsNow div $numPerPage)"/><xsl:text>
      </xsl:text></xyz:when><xsl:text>
      </xsl:text><xyz:otherwise><xsl:text>
          </xsl:text><xyz:value-of select="$pageNo"/><xsl:text>
      </xsl:text></xyz:otherwise><xsl:text>
     </xsl:text></xyz:choose><xsl:text>
  </xsl:text></xyz:variable><xsl:text>
  </xsl:text><xsl:text>
  </xsl:text><xyz:variable name="iFrom" select="($pageNoNow - 1) * $numPerPage"/><xsl:text>
  </xsl:text><xyz:variable name="iTo" select="($pageNoNow * $numPerPage) + 1"/><xsl:text>
  </xsl:text><xyz:variable name="pass2"><xsl:text>
  	</xsl:text><xyz:element name="{name(//*[count(ancestor::*)=0])}"><xsl:text>
  		</xsl:text><xyz:attribute name="totalNumberOfRows"><xyz:value-of select="count(//child::*[1]/child::*)"/></xyz:attribute><xsl:text>
  		</xsl:text><xyz:attribute name="numberOfRowsInCurrentSelection"><xyz:value-of select="count(exslt:node-set($pass1)/child::*[1]/child::*)"/></xyz:attribute><xsl:text>
  		</xsl:text><xyz:attribute name="pageNoNow"><xyz:value-of select="$pageNoNow"/></xyz:attribute><xsl:text>
  		</xsl:text><xyz:attribute name="numDonePlus"><xyz:value-of  select="(($pageNoNow - 1) * $numPerPage) + 1"/></xyz:attribute><xsl:text>
  		</xsl:text><xyz:for-each select="exslt:node-set($pass1)/child::*[1]/child::*"><xsl:text>
  				</xsl:text><xyz:variable name="iPos" select="position()"/><xsl:text>
  					</xsl:text><xyz:if test="$iPos &gt; number($iFrom) and $iPos &lt; number($iTo)"><xyz:text>__CR__<xsl:text>
  					</xsl:text></xyz:text><xyz:copy-of select="."/><xsl:text>
  				</xsl:text></xyz:if><xsl:text>
  		</xsl:text></xyz:for-each><xsl:text>
  	</xsl:text></xyz:element><xsl:text>
  </xsl:text></xyz:variable><xsl:text>
  </xsl:text><xyz:copy-of select="$pass2"/><xsl:text>
 </xsl:text></xyz:template><xsl:text>
</xsl:text></xyz:stylesheet><xsl:text>
 </xsl:text>
	</xsl:template>
	<xsl:template name="templateA">
		<xsl:param name="int"/>
		<xsl:variable name="sort">
			<xsl:choose>
				<xsl:when test="$int=1">
					<xsl:value-of select="$sort1"/>
				</xsl:when>
				<xsl:when test="$int=2">
					<xsl:value-of select="$sort2"/>
				</xsl:when>
				<xsl:when test="$int=3">
					<xsl:value-of select="$sort3"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sort4"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sortDir">
			<xsl:choose>
				<xsl:when test="$int=1">
					<xsl:value-of select="$sortDir1"/>
				</xsl:when>
				<xsl:when test="$int=2">
					<xsl:value-of select="$sortDir2"/>
				</xsl:when>
				<xsl:when test="$int=3">
					<xsl:value-of select="$sortDir3"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sortDir4"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="colName">
			<xsl:for-each select="exslt:node-set($vMap)//*[name()='att']">					
				<xsl:if test="@post=$sort">
					<xsl:value-of select="@pre"/>
				</xsl:if>				
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$colName=''">
			</xsl:when>
			<xsl:when test="$sortDir='desc'">
				<xyz:sort select="{concat('@',$colName)}" order="descending"/>
			</xsl:when>
			<xsl:otherwise><xsl:text>
	</xsl:text><xsl:choose>
					<xsl:when test="$sortDir='desc'">
						<xyz:sort select="{concat('@',$colName)}" order="descending"/>
					</xsl:when>
					<xsl:otherwise>
						<xyz:sort select="{concat('@',$colName)}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
        <xsl:choose>
			<xsl:when test="$int=4">
<xsl:text>
        		</xsl:text><xyz:choose><xsl:text>
        		</xsl:text><xyz:when test="$search=''">
<xsl:text>
        	</xsl:text><xyz:element name="{name(//*[count(ancestor::*)=0]/child::*[1])}">        		
        		<xsl:text>
        			</xsl:text><xyz:for-each select="@*"><xsl:text>
						</xsl:text><xyz:attribute name="{concat('{','name()','}')}"><xsl:text>
        					</xsl:text><xyz:value-of select="."/><xsl:text>
        				</xsl:text></xyz:attribute></xyz:for-each></xyz:element><xyz:text>__CR__
 					</xyz:text><xsl:text>
        					</xsl:text>
 					</xyz:when><xsl:text>
        					</xsl:text>
 					<xyz:otherwise><xsl:text>
        					</xsl:text>
 					<xyz:if test="@*[contains(translate(normalize-space(.), $vLC, $vUC),translate($search, $vLC, $vUC))]"><xsl:text>
        					</xsl:text>
<xyz:element name="{name(//*[count(ancestor::*)=0]/child::*[1])}">        		
        		<xsl:text>
        			</xsl:text><xyz:for-each select="@*"><xsl:text>
						</xsl:text><xyz:attribute name="{concat('{','name()','}')}"><xsl:text>
        					</xsl:text><xyz:value-of select="."/><xsl:text>
        				</xsl:text></xyz:attribute></xyz:for-each></xyz:element><xyz:text>__CR__
 					</xyz:text>
 					<xsl:text>
        					</xsl:text>
 					</xyz:if><xsl:text>
        					</xsl:text>
 					</xyz:otherwise><xsl:text>
        					</xsl:text>
 					</xyz:choose><xsl:text>
        					</xsl:text>
 					</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="templateA">
					<xsl:with-param name="int" select="$int + 1"/>
				</xsl:call-template>
			</xsl:otherwise>
        </xsl:choose>		
	</xsl:template>	
	<xsl:template name="getMaxNumberOfAtts">
		<xsl:param name="vList"/>
		<xsl:param name="ord" select="0"/>
		<xsl:choose>
			<xsl:when test="$ord!=0">
				<xsl:value-of select="$ord"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$vList">
						<xsl:variable name="vFirst" select="$vList[position()=1]"/>
						<xsl:variable name="numAtts" select="count($vFirst/@*)"/>
						<xsl:choose>
							<xsl:when test="$vFirst/following-sibling::*[count(@*) &gt; $numAtts]">
								<xsl:call-template name="getMaxNumberOfAtts">
									<xsl:with-param name="ord" select="0"/>
									<xsl:with-param name="vList" select="$vFirst/following-sibling::*[count(@*) &gt; $numAtts]"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="getMaxNumberOfAtts">
									<xsl:with-param name="ord" select="$numAtts"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>