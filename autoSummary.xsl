<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="html" indent="yes" version="4.01" encoding="ISO-8859-1"/>

	<xsl:template match="/">

		<table align="center" width="550px" border="1" id="tblGrpSummary1">
			<tbody><tr>
						<th style="width:50%">Country</th>
						<th style="width:50%">Number of companies</th>
					</tr>
				<xsl:for-each select="data/cust">
					<xsl:sort select="@Country" />
					<xsl:variable name="Country" select="@Country"/>
					<xsl:choose>
						<xsl:when test="following-sibling::*[@Country=$Country]"></xsl:when>
						<xsl:otherwise>
							<tr>
								<td><xsl:value-of select="$Country"/></td>
								<td><xsl:value-of select="count(../cust[@Country=$Country])"/></td>
							</tr>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</tbody>
		</table>

	</xsl:template>

</xsl:stylesheet>