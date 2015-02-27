package ch.vorburger.maven.bulk

import java.io.File
import com.google.common.io.Files

/**
 * Generator for pom.xml.
 *
 * @author Michael Vorburger
 */
class POMGenerator {
	
	def pom(Iterable<File> jars, String groupID, String version) '''
		<?xml version="1.0" encoding="UTF-8"?>
		<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
			<modelVersion>4.0.0</modelVersion>
		
			<!-- This pom.xml has been automatically generated by ch.vorburger.maven.bulk,
			     see https://github.com/vorburger/MavenBulkInstallDeploy.
			     DO NOT MANUALLY EDIT THIS FILE, BUT RE.GEN. IT! -->
		
			<groupId>«groupID»</groupId>
			<artifactId>ALL</artifactId>
			<version>«version»</version>
			<!-- This must be jar instead of pom for the duplicate-finder-maven-plugin & maven-assembly-plugin to work as intended -->
			<packaging>jar</packaging>
		
			<name>${project.groupId}:${project.artifactId} (${project.version})</name>
		
			<build>
				<finalName>${project.groupId}.${project.artifactId}-${project.version}</finalName>
				<plugins>
					<!-- TODO plugin to regenerate myself, this very own pom.xml, and fail if it has changed. Path etc. should be <configuration> -->

<!-- TODO uncomment this when internal bug which causes duplicates is fixed 
					<plugin>
						<groupId>org.basepom.maven</groupId>
						<artifactId>duplicate-finder-maven-plugin</artifactId>
						<version>1.1.1</version>
						<executions>
							<execution>
								<id>default</id>
								<phase>test</phase> < ! - - Intentionally during test already, and not only verify - - >
								<goals>
									<goal>check</goal>
								</goals>
							</execution>
						</executions>
						<configuration>
							<failBuildInCaseOfConflict>true</failBuildInCaseOfConflict>
							< ! - - This will fail the build even in case of duplicate but identical classes/resources (as per their SHA256). If you don't want that, then use these two for more fine-grained control:
									<failBuildInCaseOfDifferentContentConflict>true</failBuildInCaseOfDifferentContentConflict>
									<failBuildInCaseOfEqualContentConflict>false</failBuildInCaseOfEqualContentConflict>
							 - - >
						</configuration>
					</plugin>
-->					
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<artifactId>maven-assembly-plugin</artifactId>
						<version>2.5.3</version>
						<configuration>
							<descriptorRefs>
								<descriptorRef>jar-with-dependencies</descriptorRef>
							</descriptorRefs>
							<finalName></finalName>
						</configuration>
						<executions>
							<execution>
								<id>make-assembly</id>
								<phase>package</phase>
								<goals>
									<goal>single</goal>
								</goals>
							</execution>
						</executions>
					</plugin>
					
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<artifactId>maven-install-plugin</artifactId>
						<version>2.5.2</version>
						<executions>
						«FOR jar : jars»
							«val name = Files.getNameWithoutExtension(jar.getName())»
							<execution>
								<id>«name»</id>
								<!-- Intentiontionally during initialize and not only late in install! Because we want duplicate-finder-maven-plugin and assembly/shade to use the latest. (Not 100% sure that this works like this.) -->
								<phase>initialize</phase>
								<goals>
									<goal>install-file</goal>
								</goals>
								<configuration>
									<file>«jar.getPath()»</file>
									<groupId>«groupID»</groupId>
									<artifactId>«name»</artifactId>
									<version>«version»</version>
									<packaging>jar</packaging>
									<createChecksum>true</createChecksum>
									<generatePom>true</generatePom>
									« /* <installAtEnd>true</installAtEnd> */»
								</configuration>
							</execution>
						«ENDFOR»
						</executions>
					</plugin>

					<!-- This isn't tested yet - does it work? ;) -->
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<artifactId>maven-deploy-plugin</artifactId>
						<version>2.8.2</version>
						<executions>
						«FOR jar : jars»
							«val name = Files.getNameWithoutExtension(jar.getName())»
							<execution>
								<id>«name»</id>
								<phase>deploy</phase>
								<goals>
									<goal>deploy-file</goal>
								</goals>
								<configuration>
									<repositoryId>T24mba</repositoryId>
									<file>«jar.getPath()»</file>
									<groupId>«groupID»</groupId>
									<artifactId>«name»</artifactId>
									<version>«version»</version>
									<packaging>jar</packaging>
								</configuration>
							</execution>
						«ENDFOR»
						</executions>
					</plugin>

				</plugins>
				
				<pluginManagement>
					<plugins>
						<!--This plugin's configuration is used to store Eclipse m2e settings only. It has no influence on the Maven build itself.-->
						<plugin>
							<groupId>org.eclipse.m2e</groupId>
							<artifactId>lifecycle-mapping</artifactId>
							<version>1.0.0</version>
							<configuration>
								<lifecycleMappingMetadata>
									<pluginExecutions>
										<pluginExecution>
											<pluginExecutionFilter>
												<groupId>org.apache.maven.plugins</groupId>
												<artifactId>maven-install-plugin</artifactId>
												<versionRange>[2.3.1,)</versionRange>
												<goals>
													<goal>install-file</goal>
												</goals>
											</pluginExecutionFilter>
											<action>
												<ignore></ignore>
											</action>
										</pluginExecution>
									</pluginExecutions>
								</lifecycleMappingMetadata>
							</configuration>
						</plugin>
					</plugins>
				</pluginManagement>
			</build>

			<dependencies>
				«FOR jar : jars»
					«val name = Files.getNameWithoutExtension(jar.getName())»
					<dependency>
						<groupId>«groupID»</groupId>
						<artifactId>«name»</artifactId>
						<version>«version»</version>
					</dependency>
				«ENDFOR»
			</dependencies>		
			
		</project>'''
	
}