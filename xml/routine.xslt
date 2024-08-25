<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:include href="capitalize.xslt"/>
	<xsl:output method="html" encoding="UTF-8"/>
	<xsl:template match="/routine">
		<html>
			<head>
				<title><xsl:call-template name="routine-type"/> - <xsl:call-template name="semester"/></title>
				<style>
						:root {
								font-family: Hack, monospace;
								text-align: center;
								line-height: 1.25em;
								font-size: 1.25em;
						}
						table {
								width: 100%;
								border-collapse: collapse;
								font-size: 0.9em;
						}
						th, td {
								border: 1.5pt solid black;
								text-align: center;
								padding: 2pt;
						}
						th {
								background-color: #f2f2f2;
						}
						.border {
							background-color: black;
						}
						.break-time {
								background-color: #ffcccb;
								font-weight: bold;
						}
				</style>
			</head>
			<body>
				<h1>
					<u>Department of <xsl:value-of select="department"/></u>
				</h1>
				<h1>
					<u><xsl:value-of select="institute"/></u>
				</h1>
				<h2>
					<u><xsl:call-template name="routine-type"/>, <xsl:call-template name="semester"/></u>
				</h2>
				<h3>Batch <xsl:value-of select="batch"/></h3>
				<table>
					<thead>
						<tr>
							<th></th>
							<xsl:apply-templates select="timeslots/time"/>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="table/slots"/>
					</tbody>
				</table>
				<hr />
				<table>
					<thead>
						<tr>
							<th colspan="2">Courses</th>
							<th class="border"></th>
							<th colspan="2">Faculties</th>
						</tr>
					</thead>
					<tbody>
						<xsl:call-template name="map-course-faculty">
							<xsl:with-param name="course"  select="count(/routine/courses/course)"/>
							<xsl:with-param name="faculty" select="count(/routine/faculties/faculty)"/>
							<xsl:with-param name="current" select="1"/>
						</xsl:call-template>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="map-course-faculty">
		<xsl:param name="course"/>
		<xsl:param name="faculty"/>
		<xsl:param name="current"/>
		<xsl:if test="$current &gt; 0 and (/routine/courses/course[$current] or /routine/faculties/faculty[$current])">
			<tr>
				<xsl:choose>
					<xsl:when test="$current &gt; $course">
						<td colspan="2"></td>
					</xsl:when>
					<xsl:otherwise>
						<th><xsl:value-of select="/routine/courses/course[$current]/@id" /></th>
						<td><xsl:value-of select="/routine/courses/course[$current]" /></td>
					</xsl:otherwise>
				</xsl:choose>
				<td class="border"></td>
				<xsl:choose>
					<xsl:when test="$current &gt; $faculty">
						<td colspan="2"></td>
					</xsl:when>
					<xsl:otherwise>
						<th><xsl:value-of select="/routine/faculties/faculty[$current]/@id" /></th>
						<td><xsl:value-of select="/routine/faculties/faculty[$current]/text()" />
						<xsl:if test="/routine/faculties/faculty[$current]/@phone">
							<br />
							<xsl:text>( </xsl:text>
							<xsl:value-of select="/routine/faculties/faculty[$current]/@phone" />
							<xsl:text> )</xsl:text>
						</xsl:if>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
			<xsl:if test="$current &lt; $course or $current &lt; $faculty">
				<xsl:call-template name="map-course-faculty">
					<xsl:with-param name="course" select="$course"/>
					<xsl:with-param name="faculty" select="$faculty"/>
					<xsl:with-param name="current" select="$current + 1"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="slots">
		<tr>
			<th>
				<xsl:call-template name="capitalize">
					<xsl:with-param name="s" select="@day"/>
				</xsl:call-template>
			</th>
			<xsl:call-template name="time-slots">
				<xsl:with-param name="current-slot" select="1"/>
			</xsl:call-template>
		</tr>
	</xsl:template>
	<xsl:template name="time-slots">
		<xsl:param name="current-slot"/>
		<xsl:variable name="max-slots" select="count(/routine/timeslots/time)"/>
		<xsl:variable name="break-from" select="/routine/table/break/@from" />
		<xsl:variable name="break-to" select="/routine/table/break/@to" />
		<xsl:if test="$current-slot &lt; $max-slots">
			<xsl:variable name="next-slot" select="$current-slot + 1"/>
			<xsl:choose>
				<xsl:when test="$current-slot = $break-from">
					<xsl:if test="position() = 1">
						<td class="break-time" rowspan="{count(/routine/table/slots)}" colspan="{$break-to - $break-from}">Break<br/>Time</td>
					</xsl:if>
					<xsl:call-template name="time-slots">
						<xsl:with-param name="current-slot" select="$next-slot"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="slot[@from = $current-slot] and $current-slot &lt; slot[@from = $current-slot]/@to">
					<td colspan="{slot[@from = $current-slot]/@to - $current-slot}"><xsl:value-of select="slot[@from = $current-slot]/@course"/> -
						<xsl:value-of select="slot[@from = $current-slot]/@room"/><br/>
						<xsl:call-template name="faculty">
							<xsl:with-param name="course" select="slot[@from = $current-slot]/@course"/>
						</xsl:call-template> - <xsl:call-template name="class-type">
							<xsl:with-param name="course" select="slot[@from = $current-slot]/@course"/>
							<xsl:with-param name="type" select="slot[@from = $current-slot]/@type"/>
						</xsl:call-template>
					</td>
					<xsl:call-template name="time-slots">
						<xsl:with-param name="current-slot" select="slot[@from = $current-slot]/@to"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<td/>
					<xsl:call-template name="time-slots">
						<xsl:with-param name="current-slot" select="$next-slot"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="timeslots/time">
		<xsl:variable name="next-time" select="position() + 1"/>
		<xsl:if test="position() &lt; last()">
			<th><xsl:value-of select="text()"/> - <xsl:value-of select="../time[$next-time]" /></th>
		</xsl:if>
	</xsl:template>

	<xsl:template name="routine-type">
		<xsl:call-template name="cap-words">
			<xsl:with-param name="delimiters" select="' -'"/>
			<xsl:with-param name="s" select="/routine/@type"/>
		</xsl:call-template>
		<xsl:text> Routine</xsl:text>
	</xsl:template>

	<xsl:template name="faculty">
		<xsl:param name="course"/>
		<xsl:call-template name="capitalize">
			<xsl:with-param name="s" select="/routine/courses/course[@id=$course]/@faculty"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="class-type">
		<xsl:param name="course"/>
		<xsl:param name="type"/>
		<xsl:variable name="has-lab" select="/routine/courses/course[@id=$course]/@lab"/>
		<xsl:variable name="has-theory" select="/routine/courses/course[@id=$course]/@theory"/>
		<xsl:choose>
			<xsl:when test="$has-lab = 'true' and $has-theory = 'false' or $has-lab = 'true' and $type = 'lab'">Lab</xsl:when>
			<xsl:otherwise>Theory</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="semester">
		<xsl:call-template name="cap-first">
			<xsl:with-param name="s" select="/routine/semester"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
