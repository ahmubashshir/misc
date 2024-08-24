<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="digit" select="'0123456789'"/>
	<xsl:variable name="alnum" select="concat(concat($upper, $lower), $digit)"/>
	<!-- Example usage:
		<xsl:template match="/">
				<xsl:variable name="input" select="'i-only@had a*very%rudimentary_education-by:anna#russell'"/>
				<xsl:call-template name="cap-words">
						<!- Use anything not alphanumeric as a delimiter. ->
						<xsl:with-param name="delimiters" select="translate($input, $alnum, '')"/>
						<xsl:with-param name="s" select="$input"/>
				</xsl:call-template>
		</xsl:template>
		Outputs: IOnlyHadAVeryRudimentaryEducationByAnnaRussell -->
	<xsl:template name="capitalize">
		<!-- Capitalize all the letters in a string -->
		<xsl:param name="s"/>
		<xsl:value-of select="translate($s, $lower, $upper)"/>
	</xsl:template>
	<xsl:template name="cap-first">
		<!-- Capitalize the first letter in a string -->
		<xsl:param name="s"/>
		<!-- Use the FP convention of x:xs for recurring on a list -->
		<xsl:variable name="x" select="substring($s, 1, 1)"/>
		<xsl:variable name="xs" select="substring($s, 2)"/>
		<xsl:call-template name="capitalize">
			<xsl:with-param name="s" select="$x"/>
		</xsl:call-template>
		<xsl:value-of select="$xs"/>
	</xsl:template>
	<xsl:template name="cap-words">
		<!-- Capitalize the first letter of each word as determined by delimiters. -->
		<xsl:param name="delimiters"/>
		<xsl:param name="s"/>
		<xsl:if test="string-length($s)">
			<xsl:choose>
				<xsl:when test="string-length($delimiters)">
					<!-- Use the FP convention of x:xs for recurring on a list -->
					<xsl:variable name="d" select="substring($delimiters, 1, 1)"/>
					<xsl:variable name="ds" select="substring($delimiters, 2)"/>
					<xsl:call-template name="cap-words">
						<xsl:with-param name="delimiters" select="$ds"/>
						<xsl:with-param name="s">
							<!-- substring-before and -after return the empty string if the delimiter isn't in the string -->
							<xsl:choose>
								<xsl:when test="contains($s, $d)">
									<xsl:value-of select="substring-before($s, $d)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$s"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="contains($s, $d)">
						<xsl:value-of select="$d"/>
					</xsl:if>
					<xsl:call-template name="cap-words">
						<xsl:with-param name="delimiters" select="$ds"/>
						<xsl:with-param name="s" select="substring-after($s, $d)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="cap-first">
						<xsl:with-param name="s" select="$s"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
