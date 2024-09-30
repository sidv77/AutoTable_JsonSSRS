<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
 xmlns:exslt="http://exslt.org/common"
 exclude-result-prefixes="msxsl exslt xsl">
  <xsl:output method="html" indent="yes" version="4.01" encoding="ISO-8859-1" />
  <xsl:param name="sort1" select="'p4'"/>
  <xsl:param name="sort2" select="'p5'"/>
  <xsl:param name="sort3" select="'p3'"/>
  <xsl:param name="sort4" select="''"/>
  <xsl:param name="sortDir1" select="'asc'"/>
  <xsl:param name="sortDir2" select="'asc'"/>
  <xsl:param name="sortDir3" select="'asc'"/>
  <xsl:param name="sortDir4" select="''"/>
  <xsl:param name="search" select="''"/>
  
  <xsl:param name="missingAttsValue" select="'{missing}'"/>
  <xsl:param name="group1" select="'p4'"/>
  <xsl:param name="group2" select="'p5'"/>
  <xsl:param name="group3" select="'p3'"/>
  <xsl:param name="group4" select="''"/>
  
  <xsl:param name="pageNo" select="'2'"/>
  <xsl:param name="numPerPage" select="'100'"/>
  <xsl:param name="outputGroupCols" select="''"/><!-- default blank -->
  <xsl:param name="hideRowNumbers" select="''"/><!--  default blank -->
  <xsl:param name="lastClicked" select="''"/>
  <xsl:param name="debug" select="''"/>	
  
  <xsl:variable name="vLC" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="vUC" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <!-- ORIG order: t a s K st y -->
  <xsl:param name="columnMappings" select="'|1^4|4^1|'"/> <!-- |1^4|4^1| |1^5|2^4|4^2|5^1| output order; st k s a t; sorts   -->

	<!-- Be very careful about using global variables. XslProcessor has issues with the sequence. -->
  <xsl:variable name="numRows" select="//*[count(ancestor::*)=0]/@totalNumberOfRows"/>
  <xsl:variable name="pageNoNow" select="//*[count(ancestor::*)=0]/@pageNoNow"/>
  <xsl:variable name="numberOfRowsInCurrentSelection" select="//*[count(ancestor::*)=0]/@numberOfRowsInCurrentSelection"/>
  <xsl:variable name="numDonePlus" select="//*[count(ancestor::*)=0]/@numDonePlus"/>
  
  	<msxsl:script language="javascript" implements-prefix="exslt">
    this['node-set'] =  function (x) {
    return x;
    }
    </msxsl:script>
	
	<xsl:template match="/">		
		<xsl:variable name="pageNoActual">
			<xsl:choose>
				<xsl:when test="$numRows &lt; $numPerPage"><xsl:value-of select="0"/></xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$pageNoNow"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	
	
		<!-- get the first row having the max # of atts for the mapping xml. -->		
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
	
	  	<xsl:variable name="vColsX">
		  <map>		  	
			<xsl:for-each select="//*[count(ancestor::*)=0]/child::*[number($ordOfRowToUseForMappings)]/@*">
				<xsl:variable name="pos" select="position()"/>
				<xsl:variable name="override">
					<xsl:choose>
						<xsl:when test="contains($columnMappings,concat('|',$pos,'^'))">
							<xsl:variable name="post" select="substring-after($columnMappings,concat('|',$pos,'^'))"/>
							<xsl:value-of select="substring-before($post,'|')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="att">
					<xsl:attribute name="pre"><xsl:value-of select="$pos"/></xsl:attribute>
					<xsl:attribute name="post">
					<xsl:choose>
						<xsl:when test="$override!=''">
							<xsl:value-of select="$override"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pos"/>
						</xsl:otherwise>
					</xsl:choose>
					</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		  </map>
	  	</xsl:variable>	
  	
		<xsl:variable name="vMapXpre">
			<map>
				<xsl:for-each select="//*[count(ancestor::*)=0]/child::*[number($ordOfRowToUseForMappings)]/@*">
					<xsl:sort select="@pre" data-type="number"/>
					<xsl:variable name="pos" select="position()"/>
					<xsl:variable name="newPos" select="string(exslt:node-set($vColsX)//*[name()='att'][@post=number($pos)]/@pre)"/>
					<xsl:element name="att">
						<xsl:attribute name="pre">
							<xsl:value-of select="name()"/>
						</xsl:attribute>
						<xsl:attribute name="post"><xsl:value-of select="concat('p',$newPos)"/></xsl:attribute>						
						<xsl:attribute name="init"><xsl:value-of select="$pos"/></xsl:attribute>
						<xsl:choose>
							<xsl:when test="concat('p',$pos)=$sort1">
								<xsl:attribute name="sort">1</xsl:attribute>
								<xsl:attribute name="sortDir"><xsl:value-of select="$sortDir1"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="concat('p',$pos)=$sort2">
								<xsl:attribute name="sort">2</xsl:attribute>
								<xsl:attribute name="sortDir"><xsl:value-of select="$sortDir2"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="concat('p',$pos)=$sort3">
								<xsl:attribute name="sort">3</xsl:attribute>
								<xsl:attribute name="sortDir"><xsl:value-of select="$sortDir3"/></xsl:attribute>
							</xsl:when>
							<xsl:when test="concat('p',$pos)=$sort4">
								<xsl:attribute name="sort">4</xsl:attribute>
								<xsl:attribute name="sortDir"><xsl:value-of select="$sortDir4"/></xsl:attribute>
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="concat('p',$pos)=$group1"><xsl:attribute name="group">1</xsl:attribute></xsl:when>
							<xsl:when test="concat('p',$pos)=$group2"><xsl:attribute name="group">2</xsl:attribute></xsl:when>
							<xsl:when test="concat('p',$pos)=$group3"><xsl:attribute name="group">3</xsl:attribute></xsl:when>
							<xsl:when test="concat('p',$pos)=$group4"><xsl:attribute name="group">4</xsl:attribute></xsl:when>
						</xsl:choose>
					</xsl:element>
				</xsl:for-each>
			</map>
		</xsl:variable>
		<xsl:variable name="vMapX">
			<map>
				<xsl:for-each select="exslt:node-set($vMapXpre)//att">
					<xsl:sort select="substring(@post,2)" data-type="number"/><!-- do not want p1, p10; need p1, p2 -->
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</map>
		</xsl:variable>					
		<xsl:variable name="pass1">
			<xsl:apply-templates select="//*[count(ancestor::*)=0]" mode="P1">
				<xsl:with-param name="vMapX" select="$vMapX"/>
			</xsl:apply-templates>
		</xsl:variable>		
		<xsl:variable name="pass2">
			<xsl:choose>
				<xsl:when test="$search=$missingAttsValue">
					<rows>
						<xsl:for-each select="exslt:node-set($pass1)/rows/child::*">
							<xsl:if test="@*[contains(translate(normalize-space(.), $vLC, $vUC),translate($search, $vLC, $vUC))]">
								<xsl:copy-of select="."/>
							</xsl:if>
						</xsl:for-each>
					</rows>		
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$pass1"/>					
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$pageNoActual=0">
				<xsl:apply-templates select="exslt:node-set($pass2)/rows">
					<xsl:with-param name="vMapX" select="$vMapX"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="numRowsNow" select="count(exslt:node-set($pass2)/rows/child::*)"/>
				<xsl:variable name="pageIt">
					<!-- real cheats way of doing this! (I already had it using the entire dataset) -->
					<xsl:variable name="fakeRows">
						<xsl:element name="rows">
							<xsl:call-template name="outputXrows">
								<xsl:with-param name="iToGo" select="$numberOfRowsInCurrentSelection"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:variable>				
					<ul class="vm-pagination">
						<xsl:apply-templates select="exslt:node-set($fakeRows)/rows/child::*[position() mod $numPerPage = 1]" mode="pageIt">
							<xsl:with-param name="pageNo" select="$pageNoActual"/>
						</xsl:apply-templates>
					</ul>		
				</xsl:variable>		
				<xsl:apply-templates select="exslt:node-set($pass2)//rows">
					<xsl:with-param name="vMapX" select="$vMapX"/>
					<xsl:with-param name="pagingX" select="$pageIt"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>	

	</xsl:template>		
	
	<xsl:template name="outputXrows">
		<xsl:param name="iToGo"/>
		<xsl:choose>
			<xsl:when test="$iToGo &gt; 0">
				<xsl:element name="row"/>
				<xsl:call-template name="outputXrows">
					<xsl:with-param name="iToGo" select="$iToGo - 1"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>		
			
	<xsl:template match="row" mode="pageIt">
		<xsl:param name="pageNo"/>
		<xsl:variable name="numPrev" select="count(preceding-sibling::*) div $numPerPage + 1"/>
	    <li>
	    	<xsl:choose>
	    		<xsl:when test="$numPrev = $pageNo"><xsl:attribute name="class">currentPage</xsl:attribute></xsl:when>
	    		<xsl:otherwise>
	    			<xsl:attribute name="onclick"><xsl:value-of select="concat('changePage(',$numPrev,');')"/></xsl:attribute>
	    		</xsl:otherwise>
	    	</xsl:choose>	    	
	        <xsl:value-of select="$numPrev"/></li>
	</xsl:template>
	
	<!-- create rows templates -->			
 	<xsl:template match="@*|node()" mode="P1">
 		<xsl:param name="vMapX"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="P1">
				<xsl:with-param name="vMapX" select="$vMapX"/>
			</xsl:apply-templates>
		</xsl:copy>
  	</xsl:template> 	
	<xsl:template match="node()" mode="P1">
		<xsl:param name="vMapX"/>
		<xsl:variable name="numAtts" select="count(exslt:node-set($vMapX)//*[name()='att'])"/>
		<xsl:variable name="elemName">
			<xsl:choose>
				<xsl:when test="not (ancestor::*)">rows</xsl:when>
				<xsl:otherwise>row</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$elemName='rows'">
				<xsl:element name="{$elemName}">
					<xsl:apply-templates select="@*|node()" mode="P1">
						<xsl:with-param name="vMapX" select="$vMapX"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:when>			
			<xsl:when test="count(@*)=$numAtts">
				<xsl:element name="{$elemName}">
					<xsl:apply-templates select="@*|node()" mode="P1">
						<xsl:with-param name="vMapX" select="$vMapX"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="ctx" select="."/>
				<xsl:element name="{$elemName}">
					<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">
						<xsl:sort select="@init" data-type="number"/>
						<xsl:variable name="name" select="@pre"/>
						<xsl:variable name="newName" select="@post"/>
						<xsl:attribute name="{$newName}">
							<xsl:choose>
								<xsl:when test="$ctx[@*[name()=$name]]">
									<xsl:value-of select="$ctx/@*[name()=$name]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$missingAttsValue"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:for-each>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	<xsl:template match="@*" mode="P1">
		<xsl:param name="vMapX"/>
		<xsl:variable name="attName" select="string(name())"/>
		<xsl:variable name="newAttName" select="string(exslt:node-set($vMapX)//*[name()='att'][@pre=$attName]/@post)"/>
		<xsl:choose>
			<xsl:when test="$newAttName!=''">
				<xsl:attribute name="{$newAttName}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>	
	<xsl:template match="text()" mode="P1"/>		
	
	<xsl:template match="rows">
		<xsl:param name="vMapX"/>
		<xsl:param name="pagingX" />
	<div align="center" id="divMain">				
			<xsl:variable name="tblPaging">
				<table style="background-color:#ffffff;display:block;border-collapse:collapse" border="0" width="430px" align="center">
				<tr>
					<td style="width:25%;min-width:60px" valign="bottom">				
						<xsl:if test="$pagingX"><xsl:value-of select="'Go to page:'"/></xsl:if>
					</td>				
					<td style="width:55%;text-align:right;font-weight:bolder;color:#696963;min-width:240px" valign="bottom">
						<xsl:value-of select="'Number per page: '"/>
					</td>
					<td style="width:20%;color:#af0000;font-weight:bolder" valign="bottom">
						<xsl:value-of select="$numPerPage"/>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align:center;" nowrap="nowrap">
						<xsl:copy-of select="$pagingX"/><div style="clear:right;font-weight:bolder;margin-left:12px;padding-top:5px">	
						<xsl:variable name="xtra">
							<xsl:if test="$numberOfRowsInCurrentSelection!=$numRows"><xsl:value-of select="' (filtered) '"/></xsl:if>	
						</xsl:variable>
						<xsl:value-of select="concat(' Total ',$xtra,' # of rows: ')"/></div>	
					</td>
					<td><br/>
						<span style="color:#af0000;font-weight:bolder"><xsl:value-of select="$numRows"/>
						<xsl:if test="$numberOfRowsInCurrentSelection!=$numRows"><xsl:value-of select="concat(' (',$numberOfRowsInCurrentSelection,')')"/></xsl:if>
						</span>
					</td>
				</tr>
				</table>
			</xsl:variable>		
			
			<xsl:variable name="numGroups" select="count(exslt:node-set($vMapX)//*[name()='att'][@group])"/>
			<table align="center" border="0" width="90%" id="tblSorts">
				<tr>
					<td style="width:15%;text-align:right;padding-top:15px" valign="top"><span style="font-weight:bolder;">Current sorts:</span><br/>
						<span>(click any sort to remove)</span>
						<br/><br/>Output group columns:	<input id="chkOutputGroupsColsXsl" type="checkbox" onclick="toggleGroupDisplay(this);"><xsl:if test="$outputGroupCols='Y'"><xsl:attribute name="checked"/></xsl:if></input>						
						<br/></td>
					<td style="width:15%" valign="top">
						<br /><br />
						<ul id="ulSorts">
							<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att'][@sort]">
								<xsl:sort select="@sort"/>
								<xsl:variable name="iPos" select="position()"/>
								<li onclick="clearSingleSort({$iPos},this)">	
									<xsl:value-of select="@pre"/>								
									<xsl:if test="@sortDir!='asc'"> (desc)</xsl:if>
									<xsl:if test="@group"><xsl:value-of select="' (grp)'"/></xsl:if>
								</li>
							</xsl:for-each>																	
						</ul>
					</td>
					<td style="width:15%;text-align:left;padding-top:15px;padding-right:22px" valign="top">
						<b>Filter:</b><br/><br/>
						<input type="text" id="txtSearchBox" value="{$search}" onblur="applyFilter();" style="margin-right:8px;width:90px;"/>						
					</td>
					
					<xsl:variable name="lastClickedText">
						<xsl:variable name="lastClickedInt">
							<xsl:choose>
								<xsl:when test="$lastClicked!=''">
									<xsl:value-of select="translate($lastClicked,'p','')"/>
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="string(exslt:node-set($vMapX)//*[name()='att'][@init=$lastClickedInt]/@pre)"/>
					</xsl:variable>		
					<td style="width:35%;text-align:left;padding-top:15px;padding-right:22px" valign="top">
						<b>Column order:</b>
						<br />							
						<table>
							<tr>
								<td>
									<select size="6" style="width:220px" id="cboOrder">
										<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">											
											<option value="{@init}">											
												<xsl:if test="@pre=$lastClickedText">
													<xsl:attribute name="selected">selected</xsl:attribute>
												</xsl:if>
											<xsl:value-of select="@pre"/>											
											<xsl:if test="$debug='Y'"><xsl:value-of select="concat(' (p',@init,')')"/></xsl:if></option>	
										</xsl:for-each>		
									</select>
								</td>
								<td>
								<input type="button" class="btnUD" id="btnSwapOrder" onclick="swap('cboOrder',1)" value="Move left (⇧)"/>
								<br />
								<input type="button" class="btnUD" id="btnSwapOrder" onclick="swap('cboOrder',0)" value="Move right (⇩)"/>
								<br/><br />
									Last column clicked:<br /> <xsl:value-of select="$lastClickedText"/><br/><br/><br/>
								</td>
							</tr>
						</table>																																						
					</td>
					<td style="width:20%;text-align:right;padding-top:15px;padding-right:32px" valign="top">
						<a href="javascript:void(0);" onclick="clearParams();">Clear all param.s</a>
						<xsl:choose>
							<xsl:when test="$debug='Y'"><br/><br/>
							sort1 <xsl:value-of select="$sort1"/><br/>
							sort2 <xsl:value-of select="$sort2"/><br/>
							sort3 <xsl:value-of select="$sort3"/><br/>
							sort4 <xsl:value-of select="$sort4"/><br/>
							<br/><br/>
							</xsl:when>
							<xsl:otherwise>
								<br/><br/> <br/><br/> 
							</xsl:otherwise>
						</xsl:choose>		
						<br />				
					</td>
				</tr>
			</table>
			<br />
			<table align="center" border="0" width="98%" style="background-color:#ffffff;margin-left:52px">
				<tr>
					<td style="text-align:center;height:28px"><span id="spnInfo" class="message"></span><span id="spnWarning" class="warning"></span></td>
					<td rowspan="2" style="width:40%;">						
						<xsl:copy-of select="$tblPaging"/>
					</td>
				</tr>
				<tr>
					<td style="width:60%;height:42px" valign="top" id="target">
						<span style="margin-top:8px"><b>Groups: </b></span>		<!--  onmouseover="checkPipes();" -->				
						<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att'][@group]">
							<xsl:sort select="@group"/>	
							<xsl:variable name="iPos" select="position()"/>		
							<span class="pipe" id="pipe{$iPos - 1}" style="color:#000099;visibility:hidden">|</span>
							<div id="grp_p{@init}" class="dvHdrX">
								<xsl:if test="$numGroups!=1"><xsl:attribute name="draggable">true</xsl:attribute></xsl:if>
								<table border="0" style="border-collapse:collapse" width="100%">
									<tr><td nowrap="nowrap"><xsl:value-of select="@pre"/></td>
										<td class="clsGrp" onclick="removeGroup(this,{$iPos});"></td></tr></table></div>
						</xsl:for-each>	
						<span class="pipe" id="pipe{$numGroups}" style="color:#000099;visibility:hidden">|</span>
					</td>
				</tr>

			</table>
			<br />

			<xsl:choose>
				<xsl:when test="count(exslt:node-set($vMapX)//*[name()='att'][@group])=0">	
					<table align="center" width="98%" id="tblRows" class="std">
						<tr>
						<xsl:if test="$hideRowNumbers!='Y'"><th style="text-align:center;color:#8c8c8c">#</th></xsl:if>
						<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">							
							<xsl:variable name="cls"><xsl:call-template name="getCls"/></xsl:variable>
							<th onclick="thClick(this,'{concat('p',@init)}')" class="{$cls}">
								<div id="grp_{concat('p',@init)}" class="dvHdr" draggable="true"><xsl:value-of select="@pre"/></div>
							</th>
						</xsl:for-each>							
						</tr>			
						<xsl:for-each select="row">
							<xsl:variable name="iPos" select="position()"/>
							<xsl:variable name="tdMod" select="string($iPos mod 2)"/>
							<xsl:call-template name="trOut">
								<xsl:with-param name="vMapX" select="$vMapX"/>
								<xsl:with-param name="cls" select="concat('td',$tdMod)"/>
							</xsl:call-template>
						</xsl:for-each>		
					</table>
				</xsl:when>
				<xsl:otherwise>				
					<xsl:call-template name="grpsOut">
						<xsl:with-param name="vMapX" select="$vMapX"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>		
			<script>
			 attachDivHdrs();
			</script>
		</div>
		
	</xsl:template>
	<xsl:template name="getCls">
		<xsl:choose>
			<xsl:when test="@sortDir='desc'">sortDesc</xsl:when>
			<xsl:when test="@sort">sortAsc</xsl:when>
			<xsl:otherwise>bth</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="valOut">
		<xsl:param name="data" select="''"/>
		<xsl:choose>
			<xsl:when test="starts-with($data,'http')"><a href="{$data}"><xsl:value-of select="$data"/></a></xsl:when>
			<xsl:otherwise><xsl:value-of select="$data"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template name="trOutOLD">
		<xsl:param name="vMapX"/>
		<xsl:param name="cls"/>
		<xsl:variable name="oCur" select="."/>
		<tr>
			<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">
				<xsl:variable name="iPos" select="position()"/>
				<xsl:variable name="_data" select="$oCur/@*[name()=concat('p',$iPos)]"/>	
				<td><xsl:attribute name="class"><xsl:value-of select="$cls"/></xsl:attribute>
				<xsl:call-template name="valOut"><xsl:with-param name="data" select="$_data"/></xsl:call-template></td>
			</xsl:for-each>
		</tr>
	</xsl:template>	
	
	<xsl:template name="trOut">
		<xsl:param name="vMapX"/>
		<xsl:variable name="oCur" select="."/>
		<!-- NB search is now done by the sort xsl EXCEPT for the 'missing' value-->
		<xsl:choose>
			<xsl:when test="$search=''">
				<tr>
					<xsl:if test="$hideRowNumbers!='Y'"><td style="text-align:center;color:#8c8c8c"><xsl:value-of select="$numDonePlus + count(preceding-sibling::*)"/>.</td></xsl:if>
					<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">
						<xsl:variable name="iPos" select="position()"/>
						<xsl:variable name="_data" select="$oCur/@*[name()=concat('p',$iPos)]"/>
						<td><xsl:call-template name="valOut"><xsl:with-param name="data" select="$_data"/></xsl:call-template></td>
					</xsl:for-each>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@*[contains(translate(normalize-space(.), $vLC, $vUC),translate($search, $vLC, $vUC))]">
					<tr>
						<xsl:if test="$hideRowNumbers!='Y'"><td style="text-align:center"><xsl:value-of select="$numDonePlus + count(preceding-sibling::*)"/>.</td></xsl:if>
						<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">
							<xsl:variable name="iPos" select="position()"/>
							<xsl:variable name="_data" select="$oCur/@*[name()=concat('p',$iPos)]"/>
							<td><xsl:call-template name="valOut"><xsl:with-param name="data" select="$_data"/></xsl:call-template></td>
						</xsl:for-each>
					</tr>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="grpsOut">
		<xsl:param name="vMapX"/>		
		<xsl:variable name="numGroups">
			<xsl:choose>
				<xsl:when test="$group4!=''">4</xsl:when>
				<xsl:when test="$group3!=''">3</xsl:when>
				<xsl:when test="$group2!=''">2</xsl:when>
				<xsl:when test="$group1!=''">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		
		<table border="1" align="center" width="98%" id="tblRows">		
			
			<xsl:variable name="group1actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=1]/@post)"/>			
			
			<tr>	
			<xsl:choose>
				<xsl:when test="$outputGroupCols='Y'">
					<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att'][@group]">
						<xsl:variable name="iPosX" select="position()"/>
						<th>
							<xsl:attribute name="style"><xsl:choose>
								<xsl:when test="$iPosX=1">width:3%;border-top-left-radius: 8px;</xsl:when>
								<xsl:otherwise>width:3%;</xsl:otherwise>
							</xsl:choose></xsl:attribute>					
							<xsl:attribute name="onclick"><xsl:value-of select="concat('toggleGrpAll(this,',$iPosX,');')"/></xsl:attribute>
							<xsl:value-of select="'   +/-'"/>
						</th>
					</xsl:for-each>
					<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">	
						<xsl:variable name="cls"><xsl:call-template name="getCls"/></xsl:variable>
						<th onclick="thClick(this,'{concat('p',@init)}')" class="{$cls}">
							<div id="grp_{concat('p',@init)}" class="dvHdr">
								<xsl:if test="not (@group)">
									<xsl:attribute name="draggable"><xsl:value-of select="'true'"/></xsl:attribute>
								</xsl:if>
							<xsl:value-of select="@pre"/></div>				
						</th>
						</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>		
					<!-- this is the initial +/- THs -->
					<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att'][@group]">
						<xsl:variable name="iPosX" select="position()"/>	
						<th>
							<xsl:attribute name="style"><xsl:choose>
								<xsl:when test="$iPosX=1">width:3%;border-top-left-radius: 8px;</xsl:when>
								<xsl:otherwise>width:3%;</xsl:otherwise>
							</xsl:choose></xsl:attribute>
							<xsl:attribute name="onclick"><xsl:value-of select="concat('toggleGrpAll(this,',$iPosX,');')"/></xsl:attribute>
							<xsl:value-of select="'   +/-'"/>
						</th>					
					</xsl:for-each>		
					<!--already sorted by OUTPUT cols -->					
					<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att'][not (@group)]">	
						<xsl:choose>
							<xsl:when test="@group"></xsl:when>
							<xsl:otherwise>
								<xsl:variable name="cls"><xsl:call-template name="getCls"/></xsl:variable>
								<th onclick="thClick(this,'{concat('p',@init)}')" class="{$cls}">
									<div id="grp_{concat('p',@init)}" class="dvHdr" draggable="true"><xsl:value-of select="@pre"/></div>
								</th>									
							</xsl:otherwise>
						</xsl:choose>			
					</xsl:for-each>			
				</xsl:otherwise>
			</xsl:choose>
			</tr>	
			<xsl:variable name="ctx" select="."/>
			<xsl:for-each select="row">
				<xsl:variable name="iPos" select="position()"/>
				<xsl:if test="$iPos=1">
					<xsl:variable name="numContigW">
						<xsl:call-template name="getNumContig">
							<xsl:with-param name="rows" select="$ctx/row"/>
							<xsl:with-param name="attNameW" select="$group1actual"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:call-template name="eachRow">
						<xsl:with-param name="numDone" select="0"/>
						<xsl:with-param name="rows" select="$ctx/row"/>
						<xsl:with-param name="vMapX" select="$vMapX"/>
						<xsl:with-param name="numGrp1" select="$numContigW"/>
						<xsl:with-param name="inc1" select="1"/>
						<xsl:with-param name="inc2" select="1"/>
						<xsl:with-param name="inc3" select="1"/>
						<xsl:with-param name="inc4" select="1"/>
					</xsl:call-template>
					<xsl:value-of select="END"/>
				</xsl:if>
			</xsl:for-each>
		</table>
		
	</xsl:template>
	
	<!-- xsl for grouping -->
	
	<xsl:template name="getNumContig">
		<xsl:param name="rows"/>
		<xsl:param name="iUpTo"/>
		<xsl:param name="attNameW"/>
		<xsl:param name="attNameX"/>
		<xsl:param name="attNameY"/>
		<xsl:param name="attNameZ"/>
		<xsl:variable name="tmp">
			<xsl:for-each select="$rows">
				<xsl:variable name="iPos" select="position()"/>
				<xsl:variable name="attNowW" select="@*[name()=$attNameW]"/>
				<xsl:variable name="attNowX" select="@*[name()=$attNameX]"/>
				<xsl:variable name="attNowY" select="@*[name()=$attNameY]"/>
				<xsl:variable name="attNowZ" select="@*[name()=$attNameZ]"/>
				<xsl:choose>
					<xsl:when test="$iPos=1">
						<xsl:value-of select="'A'"/>
					</xsl:when>
					<xsl:when test="$attNameW!='' and string(preceding-sibling::*[1]/@*[name()=$attNameW])!=$attNowW">
						<xsl:value-of select="'N'"/>
					</xsl:when>
					<xsl:when test="$attNameX!='' and string(preceding-sibling::*[1]/@*[name()=$attNameX])!=$attNowX">
						<xsl:value-of select="'N'"/>
					</xsl:when>
					<xsl:when test="$attNameY!='' and string(preceding-sibling::*[1]/@*[name()=$attNameY])!=$attNowY">
						<xsl:value-of select="'N'"/>
					</xsl:when>
					<xsl:when test="$attNameZ!='' and string(preceding-sibling::*[1]/@*[name()=$attNameZ])!=$attNowZ">
						<xsl:value-of select="'N'"/>
					</xsl:when>
					<xsl:when test="$iPos &gt; $iUpTo">
						<xsl:value-of select="'N'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'A'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($tmp,'N')">
				<xsl:value-of select="string-length(normalize-space(substring-before($tmp,'N')))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="string-length(normalize-space($tmp))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getNumDiff">
		<xsl:param name="rows"/>
		<xsl:param name="iUpTo"/>
		<xsl:param name="attNameW" select="''"/>
		<xsl:param name="attNameX" select="''"/>
		<xsl:param name="attNameY" select="''"/>
		<xsl:param name="attNameZ" select="''"/>
		<xsl:param name="attNamePrevCheckW" select="''"/>
		<xsl:param name="attNamePrevCheckX" select="''"/>
		<xsl:param name="attNamePrevCheckY" select="''"/>
		<xsl:variable name="vPrevDiffW">
			<xsl:if test="$attNameW=''">
				<xsl:for-each select="$rows[1]">
					<xsl:variable name="attNowW" select="@*[name()=$attNamePrevCheckW]"/>
					<xsl:if test="string(preceding-sibling::*[1]/@*[name()=$attNamePrevCheckW])!=$attNowW">w</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="vPrevDiffX">
			<xsl:if test="$attNameX=''">
				<xsl:for-each select="$rows[1]">
					<xsl:variable name="attNowX" select="@*[name()=$attNamePrevCheckX]"/>
					<xsl:if test="string(preceding-sibling::*[1]/@*[name()=$attNamePrevCheckX])!=$attNowX">x</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="vPrevDiffY">
			<xsl:if test="$attNameY=''">
				<xsl:for-each select="$rows[1]">
					<xsl:variable name="attNowY" select="@*[name()=$attNamePrevCheckY]"/>
					<xsl:if test="string(preceding-sibling::*[1]/@*[name()=$attNamePrevCheckY])!=$attNowY">y</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="tmp">
			<xsl:for-each select="$rows">
				<xsl:variable name="iPos" select="position()"/>
				<xsl:variable name="attNowW" select="@*[name()=$attNameW]"/>
				<xsl:variable name="attNowX" select="@*[name()=$attNameX]"/>
				<xsl:variable name="attNowY" select="@*[name()=$attNameY]"/>
				<xsl:variable name="attNowZ" select="@*[name()=$attNameZ]"/>
				<xsl:choose>
					<xsl:when test="$iPos &gt; $iUpTo"></xsl:when>
					<xsl:when test="$attNowW!='' and ($iPos=1 or string(preceding-sibling::*[1]/@*[name()=$attNameW])!=$attNowW)">
						<xsl:value-of select="'W'"/>
						<xsl:if test="$attNameX!=''">
							<xsl:value-of select="'X'"/>
						</xsl:if>
						<xsl:if test="$attNameY!=''">
							<xsl:value-of select="'Y'"/>
						</xsl:if>
						<xsl:if test="$attNameZ!=''">
							<xsl:value-of select="'Z'"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$attNameX!='' and string(preceding-sibling::*[1]/@*[name()=$attNameX])!=$attNowX">
						<xsl:value-of select="'X'"/>
						<xsl:if test="$attNameY!=''">
							<xsl:value-of select="'Y'"/>
						</xsl:if>
						<xsl:if test="$attNameZ!=''">
							<xsl:value-of select="'Z'"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$attNameY!='' and string(preceding-sibling::*[1]/@*[name()=$attNameY])!=$attNowY">
						<xsl:value-of select="'Y'"/>
						<xsl:if test="$attNameZ!=''">
							<xsl:value-of select="'Z'"/>
						</xsl:if>
						<xsl:if test="$attNameX!='' and $iPos=1 and $vPrevDiffW!=''">
								<xsl:value-of select="'x'"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$attNameZ!='' and string(preceding-sibling::*[1]/@*[name()=$attNameZ])!=$attNowZ">
						<xsl:value-of select="'Z'"/>
						<xsl:choose>
							<xsl:when test="$attNameX!='' and $iPos=1 and $vPrevDiffW!=''">
								<xsl:value-of select="'x'"/>
								<xsl:value-of select="'y'"/>
							</xsl:when>
							<xsl:when test="$attNameY!='' and $iPos=1 and $vPrevDiffX!=''">
								<xsl:value-of select="'y'"/>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$attNameX!='' and $iPos=1 and $vPrevDiffW!=''">
						<xsl:value-of select="'x'"/>
						<xsl:value-of select="'y'"/>
						<xsl:if test="$attNameZ!=''">
							<xsl:value-of select="'z'"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$attNameY!='' and $iPos=1 and $vPrevDiffX!=''">
						<xsl:value-of select="'y'"/>
						<xsl:if test="$attNameZ!=''">
							<xsl:value-of select="'z'"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="string-length(normalize-space($tmp)) - 1"/>
	</xsl:template>
	<!-- keep these alphabetically ordered -->
	<xsl:template name="l">
		<xsl:attribute name="style"><xsl:value-of select="'border-left:0px solid #ffffff'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="bl">
		<xsl:attribute name="style"><xsl:value-of select="'border-left:0px solid #ffffff;border-bottom:0px solid #ffffff'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="r">
		<xsl:attribute name="style"><xsl:value-of select="'border-right:0px solid #ffffff'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="b">
		<xsl:attribute name="style"><xsl:value-of select="'border-bottom:0px solid #ffffff'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="brToggle">
		<xsl:param name="styleExtra" select="''"/>
		<xsl:attribute name="style"><xsl:value-of select="concat('border-bottom:0px solid #ffffff;border-right:0px solid #ffffff;text-align:center;',$styleExtra)"/></xsl:attribute>
		<xsl:attribute name="onclick"><xsl:value-of select="'toggleGrp(this)'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="t">
		<xsl:attribute name="style"><xsl:value-of select="'border-top:0px solid #ffffff'"/></xsl:attribute>
	</xsl:template>	
	<xsl:template name="blr">
		<xsl:attribute name="style"><xsl:value-of select="'border-bottom:0px solid #ffffff;border-left:0px solid #ffffff;border-right:0px solid #ffffff;'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="bt">
		<xsl:attribute name="style"><xsl:value-of select="'border-bottom:0px solid #ffffff;border-top:0px solid #ffffff;'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="br">
		<xsl:attribute name="style"><xsl:value-of select="'border-bottom:0px solid #ffffff;border-right:0px solid #ffffff;'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="brt">
		<xsl:attribute name="style"><xsl:value-of select="'border-bottom:0px solid #ffffff;border-right:0px solid #ffffff;border-top:0px solid #ffffff;'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="brtC">
		<xsl:attribute name="style"><xsl:value-of select="'border-bottom:0px solid #ffffff;border-right:0px solid #ffffff;border-top:0px solid #ffffff;text-align:center'"/></xsl:attribute>
	</xsl:template>
	<xsl:template name="rt">
		<xsl:attribute name="style"><xsl:value-of select="'border-right:0px solid #ffffff;border-top:0px solid #ffffff;'"/></xsl:attribute>
	</xsl:template>
	
	
	<xsl:template name="eachRowStd">
		<xsl:param name="rows"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="numDone"/>
		<xsl:param name="numGrp1" select="-1"/>
		<xsl:param name="numGrp2" select="-1"/>
		<xsl:param name="numGrp3" select="-1"/>
		<xsl:param name="numGrp4" select="-1"/>
		<xsl:param name="inc1"/>
		<xsl:param name="inc2"/>
		<xsl:param name="inc3"/>
		<xsl:param name="inc4"/>
		<xsl:param name="cls1"/>
		<xsl:param name="cls2"/>
		<xsl:param name="cls3"/>
		<xsl:param name="cls4"/>
		<xsl:for-each select="$rows[1]">
			<xsl:call-template name="trOutGrp">
				<xsl:with-param name="numDone" select="$numDone"/>
				<xsl:with-param name="numGrp1" select="$numGrp1"/>
				<xsl:with-param name="numGrp2" select="$numGrp2"/>
				<xsl:with-param name="numGrp3" select="$numGrp3"/>
				<xsl:with-param name="numGrp4" select="$numGrp4"/>
				<xsl:with-param name="vMapX" select="$vMapX"/>
				<xsl:with-param name="cls1" select="$cls1"/>
				<xsl:with-param name="cls2" select="$cls2"/>
				<xsl:with-param name="cls3" select="$cls3"/>
				<xsl:with-param name="cls4" select="$cls4"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="eachRow">
			<xsl:with-param name="numDone" select="$numDone + 1" />
			<xsl:with-param name="rows" select="$rows[position()!=1]"/>
			<xsl:with-param name="vMapX" select="$vMapX"/>
			<xsl:with-param name="numGrp1" select="$numGrp1 - 1"/>
			<xsl:with-param name="numGrp2" select="$numGrp2 - 1"/>
			<xsl:with-param name="numGrp3" select="$numGrp3 - 1"/>
			<xsl:with-param name="numGrp4" select="$numGrp4 - 1"/>
			<xsl:with-param name="inc1" select="$inc1"/>
			<xsl:with-param name="inc2" select="$inc2"/>
			<xsl:with-param name="inc3" select="$inc3"/>
			<xsl:with-param name="inc4" select="$inc4"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="eachRow">
		<xsl:param name="rows"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="numDone"/>
		<xsl:param name="numGrp1" select="-1"/>
		<xsl:param name="numGrp2" select="-1"/>
		<xsl:param name="numGrp3" select="-1"/>
		<xsl:param name="numGrp4" select="-1"/>
		<xsl:param name="inc1" select="0"/>
		<xsl:param name="inc2" select="0"/>
		<xsl:param name="inc3" select="0"/>
		<xsl:param name="inc4" select="0"/>


		<xsl:variable name="numAttsRow" select="count(exslt:node-set($vMapX)//*[name()='att'])"/>
		
		<xsl:variable name="_inc1"><xsl:choose>
									<xsl:when test="$numGrp1=0"><xsl:value-of select="$inc1 + 1"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$inc1"/></xsl:otherwise></xsl:choose></xsl:variable>
		<xsl:variable name="_inc2"><xsl:choose>
									<xsl:when test="$numGrp2=0"><xsl:value-of select="$inc2 + 1"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$inc2"/></xsl:otherwise></xsl:choose></xsl:variable>
		<xsl:variable name="_inc3"><xsl:choose>
									<xsl:when test="$numGrp3=0"><xsl:value-of select="$inc3 + 1"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$inc3"/></xsl:otherwise></xsl:choose></xsl:variable>
		<xsl:variable name="_inc4"><xsl:choose>
									<xsl:when test="$numGrp4=0"><xsl:value-of select="$inc4 + 1"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$inc4"/></xsl:otherwise></xsl:choose></xsl:variable>

		<xsl:variable name="aMod" select="string($_inc1 mod 2)"/>
		<xsl:variable name="bMod" select="string($_inc2 mod 2)"/>
		<xsl:variable name="cMod" select="string($_inc3 mod 2)"/>
		<xsl:variable name="dMod" select="string($_inc4 mod 2)"/>

		<xsl:variable name="group1actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=1]/@post)"/>
		<xsl:variable name="group2actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=2]/@post)"/>
		<xsl:variable name="group3actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=3]/@post)"/>
		<xsl:variable name="group4actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=4]/@post)"/>
		
		<xsl:choose>
			<xsl:when test="$rows">
				<xsl:variable name="row" select="$rows[1]"/>
				<xsl:variable name="doStdRowYN">
					<xsl:choose>
						<xsl:when test="$numDone!=0">
							<xsl:choose>
								<xsl:when test="$group2actual='' and $numGrp1 &gt; 0"><xsl:value-of select="'Y'"/></xsl:when>
								<xsl:when test="$group3actual='' and $numGrp2 &gt; 0"><xsl:value-of select="'Y'"/></xsl:when>
								<xsl:when test="$group4actual='' and $numGrp3 &gt; 0"><xsl:value-of select="'Y'"/></xsl:when>
								<xsl:when test="$numGrp4 &gt; 0"><xsl:value-of select="'Y'"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="'N'"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="'N'"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="$doStdRowYN='Y'">
						<xsl:call-template name="eachRowStd">
							<xsl:with-param name="numDone" select="$numDone"/>
							<xsl:with-param name="rows" select="$rows"/>
							<xsl:with-param name="numGrp1" select="$numGrp1"/>
							<xsl:with-param name="numGrp2" select="$numGrp2"/>
							<xsl:with-param name="numGrp3" select="$numGrp3"/>
							<xsl:with-param name="numGrp4" select="$numGrp4"/>
							<xsl:with-param name="vMapX" select="$vMapX"/>

							<xsl:with-param name="cls1" select="concat('RSa',$aMod)"/>
							<xsl:with-param name="cls2" select="concat('RSb',$bMod)"/>
							<xsl:with-param name="cls3" select="concat('RSc',$cMod)"/>
							<xsl:with-param name="cls4" select="concat('RSd',$dMod)"/>
							<xsl:with-param name="inc1" select="$_inc1"/>
							<xsl:with-param name="inc2" select="$_inc2"/>
							<xsl:with-param name="inc3" select="$_inc3"/>
							<xsl:with-param name="inc4" select="$_inc4"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>

						<xsl:choose>
							<xsl:when test="$numDone=0 or $numGrp1 = 0">
								<xsl:variable name="numContigW">
									<xsl:call-template name="getNumContig">
										<xsl:with-param name="rows" select="$rows"/>
										<xsl:with-param name="attNameW" select="$group1actual"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:variable name="a1" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
								<xsl:variable name="a2" select="concat(' (cols(1): ',number($numAttsRow) - 1,')')"/>
								<xsl:call-template name="grp1hdr">
									<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
									<xsl:with-param name="vMapX" select="$vMapX"/>
									<xsl:with-param name="row" select="$row"/>
									<xsl:with-param name="info" select="concat($a1,$a2)"/>
								</xsl:call-template>

								<xsl:choose>
									<xsl:when test="$group2=''">
										<xsl:call-template name="firstRowGrpA">
											<xsl:with-param name="numDone" select="$numDone" />
											<xsl:with-param name="vMapX" select="$vMapX"/>
											<xsl:with-param name="rows" select="$rows"/>
											<xsl:with-param name="numGrp1" select="$numContigW"/>
											<xsl:with-param name="inc1" select="$_inc1"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<!-- group 1 and 2 captions at least -->
										<xsl:variable name="numContigX">
											<xsl:call-template name="getNumContig">
												<xsl:with-param name="rows" select="$rows"/>
												<xsl:with-param name="attNameW" select="$group1actual"/>
												<xsl:with-param name="attNameX" select="$group2actual"/>
											</xsl:call-template>
										</xsl:variable>

										<xsl:variable name="b1" select="concat(' (cols(1): ',number($numAttsRow) - 2,') 2.xX ')"/>
										<xsl:variable name="b2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
										<xsl:call-template name="grp2hdr">
											<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
											<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
											<xsl:with-param name="row" select="$row"/>
											<xsl:with-param name="info" select="concat('FIRST!',$b1,$b2)"/>
											<xsl:with-param name="vMapX" select="$vMapX"/>
										</xsl:call-template>

										<xsl:choose>
											<xsl:when test="$group3=''">
												<xsl:call-template name="firstRowGrpB">
													<xsl:with-param name="numDone" select="$numDone" />
													<xsl:with-param name="vMapX" select="$vMapX"/>
													<xsl:with-param name="rows" select="$rows"/>
													<xsl:with-param name="numGrp1" select="$numContigW"/>
													<xsl:with-param name="numGrp2" select="$numContigX"/>
													<xsl:with-param name="inc1" select="$_inc1"/>
													<xsl:with-param name="inc2" select="$_inc2"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<!-- $group3!='' -->
												<xsl:variable name="c1" select="concat(' (cols(1): ',number($numAttsRow) - 3,') B(X)')"/>
												<xsl:variable name="c2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
												<xsl:call-template name="grp3hdr">
													<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
													<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
													<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
													<xsl:with-param name="vMapX" select="$vMapX"/>
													<xsl:with-param name="row" select="$row"/>
													<xsl:with-param name="info" select="concat('FIRST!',$c1,$c2)"/>
												</xsl:call-template>
												<xsl:variable name="numContigY">
													<xsl:call-template name="getNumContig">
														<xsl:with-param name="rows" select="$rows"/>
														<xsl:with-param name="attNameW" select="$group1actual"/>
														<xsl:with-param name="attNameX" select="$group2actual"/>
														<xsl:with-param name="attNameY" select="$group3actual"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:choose>
													<xsl:when test="$group4=''">
														<xsl:call-template name="firstRowGrpC">
															<xsl:with-param name="numDone" select="$numDone" />
															<xsl:with-param name="vMapX" select="$vMapX"/>
															<xsl:with-param name="rows" select="$rows"/>
															<xsl:with-param name="numGrp1" select="$numContigW"/>
															<xsl:with-param name="numGrp2" select="$numContigX"/>
															<xsl:with-param name="numGrp3" select="$numContigY"/>
															<xsl:with-param name="inc1" select="$_inc1"/>
															<xsl:with-param name="inc2" select="$_inc2"/>
															<xsl:with-param name="inc3" select="$_inc3"/>
														</xsl:call-template>
													</xsl:when>
													<xsl:otherwise>
														<xsl:variable name="d1" select="concat(' (cols(1): ',number($numAttsRow) - 4,') 1.4')"/>
														<xsl:variable name="d2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
														<xsl:call-template name="grp4hdr">
															<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
															<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
															<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
															<xsl:with-param name="clsD" select="concat('RSd',$dMod)"/>
															<xsl:with-param name="vMapX" select="$vMapX"/>
															<xsl:with-param name="row" select="$row"/>
															<xsl:with-param name="info" select="concat('FIRST!',$d1,$d2)"/>
														</xsl:call-template>
														<xsl:variable name="numContigZ">
															<xsl:call-template name="getNumContig">
																<xsl:with-param name="rows" select="$rows"/>
																<xsl:with-param name="attNameW" select="$group1actual"/>
																<xsl:with-param name="attNameX" select="$group2actual"/>
																<xsl:with-param name="attNameY" select="$group3actual"/>
																<xsl:with-param name="attNameZ" select="$group4actual"/>
															</xsl:call-template>
														</xsl:variable>
														<xsl:call-template name="firstRowGrpD">
															<xsl:with-param name="numDone" select="$numDone" />
															<xsl:with-param name="vMapX" select="$vMapX"/>
															<xsl:with-param name="rows" select="$rows"/>
															<xsl:with-param name="numGrp1" select="$numContigW"/>
															<xsl:with-param name="numGrp2" select="$numContigX"/>
															<xsl:with-param name="numGrp3" select="$numContigY"/>
															<xsl:with-param name="numGrp4" select="$numContigZ"/>
															<xsl:with-param name="inc1" select="$_inc1"/>
															<xsl:with-param name="inc2" select="$_inc2"/>
															<xsl:with-param name="inc3" select="$_inc3"/>
															<xsl:with-param name="inc4" select="$_inc4"/>
														</xsl:call-template>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!-- new 2nd group -->
							<xsl:when test="$numGrp2 = 0">
								<xsl:variable name="numContigX">
									<xsl:call-template name="getNumContig">
										<xsl:with-param name="rows" select="$rows"/>
										<xsl:with-param name="attNameW" select="$group1actual"/>
										<xsl:with-param name="attNameX" select="$group2actual"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="b1" select="concat(' (cols(1): ',number($numAttsRow) - 2,') ')"/>
								<xsl:variable name="b2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
								<xsl:call-template name="grp2hdr">
									<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
									<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
									<xsl:with-param name="vMapX" select="$vMapX"/>	
									<xsl:with-param name="row" select="$row"/>
									<xsl:with-param name="info" select="concat($b1,$b2)"/>
								</xsl:call-template>
								<xsl:choose>
									<xsl:when test="$group3=''">
										<xsl:call-template name="firstRowGrpB">
											<xsl:with-param name="numDone" select="$numDone" />
											<xsl:with-param name="vMapX" select="$vMapX"/>		
											<xsl:with-param name="rows" select="$rows"/>
											<xsl:with-param name="numGrp1" select="$numGrp1"/>
											<xsl:with-param name="numGrp2" select="$numContigX"/>
											<xsl:with-param name="inc1" select="$_inc1"/>
											<xsl:with-param name="inc2" select="$_inc2"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="numContigY">
											<xsl:call-template name="getNumContig">
												<xsl:with-param name="rows" select="$rows"/>
												<xsl:with-param name="attNameW" select="$group1actual"/>
												<xsl:with-param name="attNameX" select="$group2actual"/>
												<xsl:with-param name="attNameY" select="$group3actual"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="c1" select="concat(' (cols(1): ',number($numAttsRow) - 3,') B(Xx)')"/>
										<xsl:variable name="c2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
										<xsl:call-template name="grp3hdr">
											<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
											<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
											<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
											<xsl:with-param name="vMapX" select="$vMapX"/>
											<xsl:with-param name="row" select="$row"/>
											<xsl:with-param name="info" select="concat('FIRST!',$c1,$c2)"/>
										</xsl:call-template>
										<xsl:choose>
											<xsl:when test="$group4=''">
												<xsl:call-template name="firstRowGrpC">
													<xsl:with-param name="numDone" select="$numDone" />
													<xsl:with-param name="vMapX" select="$vMapX"/>
													<xsl:with-param name="rows" select="$rows"/>
													<xsl:with-param name="numGrp1" select="$numGrp1"/>
													<xsl:with-param name="numGrp2" select="$numContigX"/>
													<xsl:with-param name="numGrp3" select="$numContigY"/>
													<xsl:with-param name="inc1" select="$_inc1"/>
													<xsl:with-param name="inc2" select="$_inc2"/>
													<xsl:with-param name="inc3" select="$_inc3"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:variable name="d1" select="concat(' (cols(1): ',number($numAttsRow) - 4,') 2.4')"/>
												<xsl:variable name="d2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
												<xsl:call-template name="grp4hdr">
													<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
													<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
													<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
													<xsl:with-param name="clsD" select="concat('RSd',$dMod)"/>
													<xsl:with-param name="vMapX" select="$vMapX"/>			
													<xsl:with-param name="row" select="$row"/>
													<xsl:with-param name="info" select="concat('FIRST!',$d1,$d2)"/>
												</xsl:call-template>
												<xsl:variable name="numContigZ">
													<xsl:call-template name="getNumContig">
														<xsl:with-param name="rows" select="$rows"/>
														<xsl:with-param name="attNameW" select="$group1actual"/>
														<xsl:with-param name="attNameX" select="$group2actual"/>
														<xsl:with-param name="attNameY" select="$group3actual"/>
														<xsl:with-param name="attNameZ" select="$group4actual"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="firstRowGrpD">
													<xsl:with-param name="numDone" select="$numDone" />
													<xsl:with-param name="vMapX" select="$vMapX"/>
													<xsl:with-param name="rows" select="$rows"/>
													<xsl:with-param name="numGrp1" select="$numGrp1"/>
													<xsl:with-param name="numGrp2" select="$numContigX"/>
													<xsl:with-param name="numGrp3" select="$numContigY"/>
													<xsl:with-param name="numGrp4" select="$numContigZ"/>
													<xsl:with-param name="inc1" select="$_inc1"/>
													<xsl:with-param name="inc2" select="$_inc2"/>
													<xsl:with-param name="inc3" select="$_inc3"/>
													<xsl:with-param name="inc4" select="$_inc4"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:when>
							<!-- new 3rd group -->
							<xsl:when test="$numGrp3 = 0">
								<xsl:variable name="numContigY">
									<xsl:call-template name="getNumContig">
										<xsl:with-param name="rows" select="$rows"/>
										<xsl:with-param name="attNameW" select="$group1actual"/>
										<xsl:with-param name="attNameX" select="$group2actual"/>
										<xsl:with-param name="attNameY" select="$group3actual"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="c1" select="concat(' (cols(1): ',number($numAttsRow) - 3,') 3.3F ')"/>
								<xsl:variable name="c2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
								<xsl:call-template name="grp3hdr">
									<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
									<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
									<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
									<xsl:with-param name="vMapX" select="$vMapX"/>
									<xsl:with-param name="row" select="$row"/>
									<xsl:with-param name="info" select="concat($c1,$c2)"/>
								</xsl:call-template>

								<xsl:choose>
									<xsl:when test="$group4=''">
										<xsl:call-template name="firstRowGrpC">
											<xsl:with-param name="numDone" select="$numDone" />
											<xsl:with-param name="vMapX" select="$vMapX"/>	
											<xsl:with-param name="rows" select="$rows"/>
											<xsl:with-param name="numGrp1" select="$numGrp1"/>
											<xsl:with-param name="numGrp2" select="$numGrp2"/>
											<xsl:with-param name="numGrp3" select="$numContigY"/>
											<xsl:with-param name="inc1" select="$_inc1"/>
											<xsl:with-param name="inc2" select="$_inc2"/>
											<xsl:with-param name="inc3" select="$_inc3"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="d1" select="concat(' (cols(1): ',number($numAttsRow) - 4,') 3.4')"/>
										<xsl:variable name="d2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
										<xsl:call-template name="grp4hdr">
											<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
											<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
											<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
											<xsl:with-param name="clsD" select="concat('RSd',$dMod)"/>
											<xsl:with-param name="vMapX" select="$vMapX"/>
											<xsl:with-param name="row" select="$row"/>
											<xsl:with-param name="info" select="concat('FIRST!',$d1,$d2)"/>
										</xsl:call-template>
										<xsl:variable name="numContigZ">
											<xsl:call-template name="getNumContig">
												<xsl:with-param name="rows" select="$rows"/>
												<xsl:with-param name="attNameW" select="$group1actual"/>
												<xsl:with-param name="attNameX" select="$group2actual"/>
												<xsl:with-param name="attNameY" select="$group3actual"/>
												<xsl:with-param name="attNameZ" select="$group4actual"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:call-template name="firstRowGrpD">
											<xsl:with-param name="numDone" select="$numDone" />
											<xsl:with-param name="vMapX" select="$vMapX"/>		
											<xsl:with-param name="rows" select="$rows"/>
											<xsl:with-param name="numGrp1" select="$numGrp1"/>
											<xsl:with-param name="numGrp2" select="$numGrp2"/>
											<xsl:with-param name="numGrp3" select="$numContigY"/>
											<xsl:with-param name="numGrp4" select="$numContigZ"/>
											<xsl:with-param name="inc1" select="$_inc1"/>
											<xsl:with-param name="inc2" select="$_inc2"/>
											<xsl:with-param name="inc3" select="$_inc3"/>
											<xsl:with-param name="inc4" select="$_inc4"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:when>
							<!-- new 4th group -->
							<xsl:when test="$group4!='' and $numGrp4=0">
								<xsl:variable name="d1" select="concat(' (cols(1): ',number($numAttsRow) - 4,') 4.4')"/>
								<xsl:variable name="d2" select="concat($_inc1,'|',$_inc2,'|',$_inc3,'|',$_inc4,' M',$aMod,'^',$bMod,'^',$cMod,'^',$dMod)"/>
								<xsl:call-template name="grp4hdr">
									<xsl:with-param name="clsA" select="concat('RSa',$aMod)"/>
									<xsl:with-param name="clsB" select="concat('RSb',$bMod)"/>
									<xsl:with-param name="clsC" select="concat('RSc',$cMod)"/>
									<xsl:with-param name="clsD" select="concat('RSd',$dMod)"/>
									<xsl:with-param name="vMapX" select="$vMapX"/>
									<xsl:with-param name="row" select="$row"/>
									<xsl:with-param name="info" select="concat($d1,$d2)"/>
								</xsl:call-template>
								<xsl:variable name="numContigZ">
									<xsl:call-template name="getNumContig">
										<xsl:with-param name="rows" select="$rows"/>
										<xsl:with-param name="attNameW" select="$group1actual"/>
										<xsl:with-param name="attNameX" select="$group2actual"/>
										<xsl:with-param name="attNameY" select="$group3actual"/>
										<xsl:with-param name="attNameZ" select="$group4actual"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="firstRowGrpD">
									<xsl:with-param name="numDone" select="$numDone" />
									<xsl:with-param name="vMapX" select="$vMapX"/>
									<xsl:with-param name="rows" select="$rows"/>
									<xsl:with-param name="numGrp1" select="$numGrp1"/>
									<xsl:with-param name="numGrp2" select="$numGrp2"/>
									<xsl:with-param name="numGrp3" select="$numGrp3"/>
									<xsl:with-param name="numGrp4" select="$numContigZ"/>
									<xsl:with-param name="inc1" select="$_inc1"/>
									<xsl:with-param name="inc2" select="$_inc2"/>
									<xsl:with-param name="inc3" select="$_inc3"/>
									<xsl:with-param name="inc4" select="$_inc4"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>	</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="firstRowGrpA">
		<xsl:param name="numDone"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="rows"/>
		<xsl:param name="numGrp1"/>
		<xsl:param name="inc1"/>
		<xsl:variable name="aMod" select="string($inc1 mod 2)"/>
		<tr>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSa',$aMod)"/></xsl:attribute>
				<xsl:call-template name="brtC"/>
				<xsl:if test="$hideRowNumbers!='Y'"><xsl:value-of select="concat($numDonePlus + $numDone,'.')"/></xsl:if>
				<xsl:call-template name="debugOut"><xsl:with-param name="s" select="concat(' X(W) ',$numGrp1)"/></xsl:call-template>
			</td>
			<xsl:for-each select="$rows[1]">
				<xsl:call-template name="trOutColsOnly">
					<xsl:with-param name="numDone" select="$numDone"/>
					<xsl:with-param name="vMapX" select="$vMapX"/>
					<xsl:with-param name="numGrp1" select="$numGrp1"/>
					<xsl:with-param name="addToTd1Class"/><!--  select="' tdOutRow1Col1'" -->
				</xsl:call-template>
			</xsl:for-each>
		</tr>
		<xsl:call-template name="eachRow">
			<xsl:with-param name="numDone" select="$numDone + 1" />
			<xsl:with-param name="rows" select="$rows[position()!=1]"/>
			<xsl:with-param name="vMapX" select="$vMapX"/>
			<xsl:with-param name="numGrp1" select="$numGrp1 - 1"/>
			<xsl:with-param name="inc1" select="$inc1"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="firstRowGrpB">
		<xsl:param name="numDone"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="rows"/>

		<xsl:param name="numGrp1"/>
		<xsl:param name="numGrp2"/>
		<xsl:param name="inc1"/>
		<xsl:param name="inc2"/>

		<xsl:variable name="aMod" select="string($inc1 mod 2)"/>
		<xsl:variable name="bMod" select="string($inc2 mod 2)"/>

		<tr>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSa',$aMod)"/></xsl:attribute>
				<xsl:call-template name="brtC"/>
				<xsl:if test="$hideRowNumbers!='Y'"><xsl:value-of select="concat($numDonePlus + $numDone,'.')"/></xsl:if>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..A+y Y(X)'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="concat('RSb',$bMod)"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="concat(' Y(X) ',$numGrp2)"/>
				</xsl:call-template>
			</td>
			<xsl:for-each select="$rows[1]">
				<xsl:call-template name="trOutColsOnly">
					<xsl:with-param name="numDone" select="$numDone"/>
					<xsl:with-param name="vMapX" select="$vMapX"/>
					<xsl:with-param name="addToTd1Class"/><!--  select="' tdOutRow1Col1'" -->
					<xsl:with-param name="numGrp1" select="$numGrp1"/>
					<xsl:with-param name="numGrp2" select="$numGrp2"/>
				</xsl:call-template>
			</xsl:for-each>
		</tr>
		<xsl:call-template name="eachRow">
			<xsl:with-param name="numDone" select="$numDone + 1" />
			<xsl:with-param name="rows" select="$rows[position()!=1]"/>
			<xsl:with-param name="vMapX" select="$vMapX"/>
			<xsl:with-param name="numGrp1" select="$numGrp1 - 1"/>
			<xsl:with-param name="numGrp2" select="$numGrp2 - 1"/>
			<xsl:with-param name="inc1" select="$inc1"/>
			<xsl:with-param name="inc2" select="$inc2"/>
		</xsl:call-template>

	</xsl:template>

	<xsl:template name="firstRowGrpC">

		<xsl:param name="numDone"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="rows"/>

		<xsl:param name="numGrp1"/>
		<xsl:param name="numGrp2"/>
		<xsl:param name="numGrp3"/>
		<xsl:param name="inc1"/>
		<xsl:param name="inc2"/>
		<xsl:param name="inc3"/>

		<xsl:variable name="aMod" select="string($inc1 mod 2)"/>
		<xsl:variable name="bMod" select="string($inc2 mod 2)"/>
		<xsl:variable name="cMod" select="string($inc3 mod 2)"/>

		<tr>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSa',$aMod)"/></xsl:attribute>
				<xsl:call-template name="brtC"/>
				<xsl:if test="$hideRowNumbers!='Y'"><xsl:value-of select="concat($numDonePlus + $numDone,'.')"/></xsl:if>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..A+y D(y)'"/>
				</xsl:call-template>
			</td>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSb',$bMod)"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..B+y D(y)'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="concat('RSc',$cMod)"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="concat(' D(y) ',$numGrp3)"/>
				</xsl:call-template>
			</td>
			<xsl:for-each select="$rows[1]">
				<xsl:call-template name="trOutColsOnly">
					<xsl:with-param name="numDone" select="$numDone"/>
					<xsl:with-param name="vMapX" select="$vMapX"/>
					<xsl:with-param name="addToTd1Class"/><!--  select="' tdOutRow1Col1'" -->
					<xsl:with-param name="numGrp1" select="$numGrp1"/>
					<xsl:with-param name="numGrp2" select="$numGrp2"/>
					<xsl:with-param name="numGrp3" select="$numGrp3"/>
				</xsl:call-template>
			</xsl:for-each>
		</tr>

		<xsl:call-template name="eachRow">
			<xsl:with-param name="numDone" select="$numDone + 1" />
			<xsl:with-param name="rows" select="$rows[position()!=1]"/>
			<xsl:with-param name="vMapX" select="$vMapX"/>
			<xsl:with-param name="numGrp1" select="$numGrp1 - 1"/>
			<xsl:with-param name="numGrp2" select="$numGrp2 - 1"/>
			<xsl:with-param name="numGrp3" select="$numGrp3 - 1"/>
			<xsl:with-param name="inc1" select="$inc1"/>
			<xsl:with-param name="inc2" select="$inc2"/>
			<xsl:with-param name="inc3" select="$inc3"/>
		</xsl:call-template>

	</xsl:template>

	<xsl:template name="firstRowGrpD">
		<xsl:param name="numDone"/>
		<xsl:param name="rows"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="numGrp1"/>
		<xsl:param name="numGrp2"/>
		<xsl:param name="numGrp3"/>
		<xsl:param name="numGrp4"/>
		
		<xsl:param name="inc1"/>
		<xsl:param name="inc2"/>
		<xsl:param name="inc3"/>
		<xsl:param name="inc4"/>

		<xsl:variable name="aMod" select="string($inc1 mod 2)"/>
		<xsl:variable name="bMod" select="string($inc2 mod 2)"/>
		<xsl:variable name="cMod" select="string($inc3 mod 2)"/>
		<xsl:variable name="dMod" select="string($inc4 mod 2)"/>

		<tr>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSa',$aMod)"/></xsl:attribute>
				<xsl:call-template name="brtC"/>
				<xsl:if test="$hideRowNumbers!='Y'"><xsl:value-of select="concat($numDonePlus + $numDone,'.')"/></xsl:if>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..A+y 1'"/>
				</xsl:call-template>
			</td>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSb',$bMod)"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..B+y 1'"/>
				</xsl:call-template>
			</td>
			<td><xsl:attribute name="class"><xsl:value-of select="concat('RSc',$cMod)"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' XCCC'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="concat('RSd',$dMod)"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="concat('4.4z: ',$numGrp4)"/>
				</xsl:call-template>
			</td>
			<xsl:for-each select="$rows[1]">
				<xsl:call-template name="trOutColsOnly">
					<xsl:with-param name="numDone" select="$numDone"/>
					<xsl:with-param name="vMapX" select="$vMapX"/>
					<xsl:with-param name="addToTd1Class"/><!--  select="' tdOutRow1Col1'" -->
					<xsl:with-param name="numGrp1" select="$numGrp1"/>
					<xsl:with-param name="numGrp2" select="$numGrp2"/>
					<xsl:with-param name="numGrp3" select="$numGrp3"/>
					<xsl:with-param name="numGrp4" select="$numGrp4"/>
				</xsl:call-template>
			</xsl:for-each>
		</tr>

		<xsl:call-template name="eachRow">
			<xsl:with-param name="numDone" select="$numDone + 1" />
			<xsl:with-param name="rows" select="$rows[position()!=1]"/>
			<xsl:with-param name="vMapX" select="$vMapX"/>
			<xsl:with-param name="numGrp1" select="$numGrp1 - 1"/>
			<xsl:with-param name="numGrp2" select="$numGrp2 - 1"/>
			<xsl:with-param name="numGrp3" select="$numGrp3 - 1"/>
			<xsl:with-param name="numGrp4" select="$numGrp4 - 1"/>
			<xsl:with-param name="inc1" select="$inc1"/>
			<xsl:with-param name="inc2" select="$inc2"/>
			<xsl:with-param name="inc3" select="$inc3"/>
			<xsl:with-param name="inc4" select="$inc4"/>
		</xsl:call-template>

	</xsl:template>

	<xsl:template name="grp1hdr">
	
		<xsl:param name="clsA"/>
		<xsl:param name="row"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="info" select="''"/>		

		<xsl:variable name="group1actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=1]/@post)"/>
		<xsl:variable name="numAttsRow" select="count(exslt:node-set($vMapX)//*[name()='att'])"/>
		
		<tr>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsA"/></xsl:attribute>
				<xsl:call-template name="brToggle"/>
				<xsl:value-of select="'+/-'"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="concat(' 1.1',' ')"/>
				</xsl:call-template>
			</td>
			<xsl:variable name="colspan">
				<xsl:choose>
					<xsl:when test="$outputGroupCols='Y'">
						<xsl:variable name="iNumExtra">
							<xsl:choose>
								<xsl:when test="$group4!=''">3</xsl:when>
								<xsl:when test="$group3!=''">2</xsl:when>
								<xsl:when test="$group2!=''">1</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="$numAttsRow + $iNumExtra"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numAttsRow - 1"/>
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:variable>
			<td colspan="{$colspan}">				
				<xsl:attribute name="class"><xsl:value-of select="$clsA"/></xsl:attribute>
				<xsl:call-template name="blr"/>
				<span class="b">
					<xsl:variable name="th" select="string(exslt:node-set($vMapX)//*[name()='att'][@post=$group1actual]/@pre)"></xsl:variable>
					<xsl:value-of select="$th"/>:
				</span>
				<xsl:value-of select="$row/@*[name()=$group1actual]"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="$info"/>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="grp2hdr">
		<xsl:param name="clsA"/>
		<xsl:param name="clsB"/>

		<xsl:param name="vMapX"/>
		<xsl:param name="row"/>
		<xsl:param name="info" select="''"/>
		<xsl:variable name="group2actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=2]/@post)"/>
		<xsl:variable name="numAttsRow" select="count(exslt:node-set($vMapX)//*[name()='att'])"/>
		<tr>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsA"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="'1.2 A H'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsB"/></xsl:attribute>
				<xsl:call-template name="brToggle">
					<xsl:with-param name="styleExtra">
						<xsl:if test="contains($info,'FIRST!')"><xsl:value-of select="'border-top-left-radius: 8px;'"/></xsl:if>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="'+/-'"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="'1.2 A H'"/>
				</xsl:call-template>
			</td>
			<xsl:variable name="colspan">
				<xsl:choose>
					<xsl:when test="$outputGroupCols='Y'">
						<xsl:variable name="iNumExtra">
							<xsl:choose>
								<xsl:when test="$group4!=''">2</xsl:when>
								<xsl:when test="$group3!=''">1</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="$numAttsRow + $iNumExtra"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numAttsRow - 2"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<td colspan="{$colspan}">
				<xsl:attribute name="class"><xsl:value-of select="$clsB"/></xsl:attribute>
				<xsl:call-template name="blr"/>
				<span class="b">	
					<xsl:variable name="th" select="string(exslt:node-set($vMapX)//*[name()='att'][@post=$group2actual]/@pre)"></xsl:variable>
					<xsl:value-of select="$th"/>:
				</span>
				<xsl:value-of select="$row/@*[name()=$group2actual]"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="$info"/>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="grp3hdr">
		<xsl:param name="clsA"/>
		<xsl:param name="clsB"/>
		<xsl:param name="clsC"/>

		<xsl:param name="vMapX"/>		
		<xsl:param name="row"/>
		<xsl:param name="info" select="''"/>
		<xsl:variable name="numAttsRow" select="count(exslt:node-set($vMapX)//*[name()='att'])"/>
		<xsl:variable name="group3actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=3]/@post)"/>
		<tr>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsA"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..A+y 3H'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsB"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="' ..B+y 3H'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsC"/></xsl:attribute>
				<xsl:call-template name="brToggle">
					<xsl:with-param name="styleExtra">
						<xsl:if test="contains($info,'FIRST!')"><xsl:value-of select="'border-top-left-radius: 8px;'"/></xsl:if>					
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="'+/-'"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="concat(' 3.3H',' ')"/>
				</xsl:call-template>
			</td>
			<xsl:variable name="colspan">
				<xsl:choose>
					<xsl:when test="$outputGroupCols='Y'">
						<xsl:variable name="iNumExtra">
							<xsl:choose>
								<xsl:when test="$group4!=''">1</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="$numAttsRow + $iNumExtra"/>
						<xsl:value-of select="$numAttsRow"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numAttsRow - 3"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<td colspan="{$colspan}">
				<xsl:attribute name="class"><xsl:value-of select="$clsC"/></xsl:attribute>
				<xsl:call-template name="blr"/>
				<span class="b">
					<xsl:variable name="th" select="string(exslt:node-set($vMapX)//*[name()='att'][@post=$group3actual]/@pre)"></xsl:variable>
					<xsl:value-of select="$th"/>:
				</span>
				<xsl:value-of select="$row/@*[name()=$group3actual]"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="$info"/>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="grp4hdr">
		<xsl:param name="clsA"/>
		<xsl:param name="clsB"/>
		<xsl:param name="clsC"/>
		<xsl:param name="clsD"/>
		<xsl:param name="vMapX"/>		
		<xsl:param name="row"/>
		<xsl:param name="info" select="''"/>
		<xsl:variable name="numAttsRow" select="count(exslt:node-set($vMapX)//*[name()='att'])"/>
		<xsl:variable name="group4actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=4]/@post)"/>
		<tr>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsA"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="'A 4H'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsB"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="'B 4H'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsC"/></xsl:attribute>
				<xsl:call-template name="brt"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="'C 4H'"/>
				</xsl:call-template>
			</td>
			<td>
				<xsl:attribute name="class"><xsl:value-of select="$clsD"/></xsl:attribute>
				<xsl:call-template name="brToggle">
					<xsl:with-param name="styleExtra">
						<xsl:if test="contains($info,'FIRST!')"><xsl:value-of select="'border-top-left-radius: 8px;'"/></xsl:if>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="'+/-'"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="concat(' 4H',' ')"/>
				</xsl:call-template>
			</td>
			<xsl:variable name="colspan">
				<xsl:choose>
					<xsl:when test="$outputGroupCols='Y'">
						<xsl:value-of select="$numAttsRow"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numAttsRow - 4"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<td colspan="{$colspan}">
				<xsl:attribute name="class"><xsl:value-of select="$clsD"/></xsl:attribute>
				<xsl:call-template name="blr"/>
				<span class="b">
					<xsl:variable name="th" select="string(exslt:node-set($vMapX)//*[name()='att'][@post=$group4actual]/@pre)"></xsl:variable>
					<xsl:value-of select="$th"/>:
				</span>
				<xsl:value-of select="$row/@*[name()=$group4actual]"/>
				<xsl:call-template name="debugOut">
					<xsl:with-param name="s" select="$info"/>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="debugOut">
		<xsl:param name="s" select="''"/>
		<xsl:if test="$debug='Y'">
			<xsl:value-of select="$s"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="trOutColsOnly">
		<xsl:param name="numDone"/>
		<xsl:param name="vMapX"/>

		<xsl:param name="numGrp1"/>
		<xsl:param name="numGrp2"/>
		<xsl:param name="numGrp3"/>
		<xsl:param name="numGrp4"/>
		<xsl:param name="addToTd1Class" select="''"/>
		
		<xsl:variable name="tdMod" select="string($numDone mod 2)"/>
		<xsl:variable name="oCur" select="."/>

		<xsl:variable name="group1actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=1]/@post)"/>
		<xsl:variable name="group2actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=2]/@post)"/>
		<xsl:variable name="group3actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=3]/@post)"/>
		<xsl:variable name="group4actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=4]/@post)"/>
		
		<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">
			<xsl:sort select="@post"/>
			<xsl:variable name="iPos" select="position()"/>
			<xsl:variable name="_data" select="$oCur/@*[name()=concat('p',$iPos)]"/>
			<xsl:choose>
				<xsl:when test="concat('p',$iPos)=$group1actual and $outputGroupCols!='Y'"></xsl:when>
				<xsl:when test="concat('p',$iPos)=$group2actual and $outputGroupCols!='Y'"></xsl:when>
				<xsl:when test="concat('p',$iPos)=$group3actual and $outputGroupCols!='Y'"></xsl:when>
				<xsl:when test="concat('p',$iPos)=$group4actual and $outputGroupCols!='Y'"></xsl:when>
				<xsl:otherwise>
					<td>
						<xsl:attribute name="class"><xsl:choose>
							<xsl:when test="$iPos=1"><xsl:value-of select="concat('td',$tdMod,$addToTd1Class)"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="concat('td',$tdMod)"/></xsl:otherwise>
						</xsl:choose></xsl:attribute>
						<xsl:call-template name="br"/>						
						<xsl:call-template name="valOut"><xsl:with-param name="data" select="$_data"/></xsl:call-template>						
						<xsl:if test="position()=last() and $debug='Y'">
							<xsl:value-of select="concat(' c :',$numGrp1,' :',$numGrp2,' :',$numGrp3,' :',$numGrp4)"/>
							<xsl:value-of select="concat(' ND;',$numDone)"/>
						</xsl:if>
					</td>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="trOutGrp">
	
		<xsl:param name="numDone"/>
		<xsl:param name="vMapX"/>
		<xsl:param name="numGrp1"/>
		<xsl:param name="numGrp2"/>
		<xsl:param name="numGrp3"/>
		<xsl:param name="numGrp4"/>
		
		<xsl:param name="cls1"/>
		<xsl:param name="cls2"/>
		<xsl:param name="cls3"/>
		<xsl:param name="cls4"/>
		<xsl:variable name="oCur" select="."/>
		<xsl:variable name="tdMod" select="string($numDone mod 2)"/>

		<xsl:variable name="group1actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=1]/@post)"/>
		<xsl:variable name="group2actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=2]/@post)"/>
		<xsl:variable name="group3actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=3]/@post)"/>
		<xsl:variable name="group4actual" select="string(exslt:node-set($vMapX)//*[name()='att'][@group=4]/@post)"/>
		
		<tr>
			<xsl:if test="$group1actual!=''">
				<td><xsl:attribute name="class"><xsl:value-of select="$cls1"/></xsl:attribute>
					<xsl:call-template name="brtC"/>
					<xsl:if test="$debug='Y'">mm </xsl:if><xsl:if test="$hideRowNumbers!='Y'"><xsl:value-of select="concat($numDonePlus + $numDone,'.')"/></xsl:if>
				</td>
			</xsl:if>
			<xsl:if test="$group2actual!=''">
				<td><xsl:attribute name="class"><xsl:value-of select="$cls2"/></xsl:attribute>
					<xsl:call-template name="brt"/>
					<xsl:if test="$debug='Y'">nn</xsl:if>
				</td>
			</xsl:if>

			<xsl:if test="$group3actual!=''">
				<td><xsl:attribute name="class"><xsl:value-of select="$cls3"/></xsl:attribute>
					<xsl:call-template name="brt"/>
					<xsl:if test="$debug='Y'">pp</xsl:if>
				</td>
			</xsl:if>

			<xsl:if test="$group4actual!=''">
				<td><xsl:attribute name="class"><xsl:value-of select="$cls4"/></xsl:attribute>
					<xsl:call-template name="brt"/>
					<xsl:if test="$debug='Y'">qq</xsl:if>
				</td>
			</xsl:if>
			
			<xsl:for-each select="exslt:node-set($vMapX)//*[name()='att']">
				<xsl:sort select="@post"/>
				<xsl:variable name="iPos" select="position()"/>
				<xsl:variable name="_data" select="$oCur/@*[name()=concat('p',$iPos)]"/>
				<xsl:choose>
					<xsl:when test="concat('p',$iPos)=$group1actual and $outputGroupCols!='Y'"></xsl:when>
					<xsl:when test="concat('p',$iPos)=$group2actual and $outputGroupCols!='Y'"></xsl:when>
					<xsl:when test="concat('p',$iPos)=$group3actual and $outputGroupCols!='Y'"></xsl:when>
					<xsl:when test="concat('p',$iPos)=$group4actual and $outputGroupCols!='Y'"></xsl:when>
					<xsl:otherwise>
						<td>
							<xsl:attribute name="class"><xsl:value-of select="concat('td',$tdMod)"/></xsl:attribute>
							<xsl:call-template name="br"/>
							<xsl:call-template name="valOut"><xsl:with-param name="data" select="$_data"/></xsl:call-template>
							<xsl:if test="position()=last() and $debug='Y'">
								<xsl:choose>
									<xsl:when test="$numGrp4 &gt; 0">
										<xsl:value-of select="concat(' ORDS: ',$numGrp1,' : ',$numGrp2,' : ',$numGrp3,' : ',$numGrp4)"/>
									</xsl:when>
									<xsl:when test="$numGrp3 &gt; 0">
										<xsl:value-of select="concat(' ORDS: ',$numGrp1,' : ',$numGrp2,' : ',$numGrp3)"/>
									</xsl:when>
									<xsl:when test="$numGrp2 &gt; 0">
										<xsl:value-of select="concat(' ORDS: ',$numGrp1,' : ',$numGrp2)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat(' ORDS: ',$numGrp1)"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="concat(' ND:',$numDone)"/>
							</xsl:if>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</tr>
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