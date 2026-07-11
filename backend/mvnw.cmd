@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    https://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script
@REM
@REM Required ENV vars:
@REM JAVA_HOME - location of a JDK home dir
@REM
@REM Optional ENV vars
@REM M2_HOME - location of maven2's installed home dir
@REM MAVEN_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM MAVEN_BATCH_PAUSE - set to 'on' to wait for a keystroke before ending
@REM MAVEN_OPTS - parameters passed to the Java VM when running Maven
@REM     e.g. to debug Maven itself, use
@REM set MAVEN_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
@REM MAVEN_SKIP_RC - flag to disable loading of mavenrc files
@REM ----------------------------------------------------------------------------

@IF "%MAVEN_BATCH_ECHO%" == "on"  @ECHO ON
@IF "%MAVEN_BATCH_ECHO%" == "" @ECHO OFF

@SETLOCAL

@SET "EXEC_DIR=%CD%"
@SET "WDIR=%EXEC_DIR%"

:findBaseDir
@IF EXIST "%WDIR%\.mvn" GOTO foundBaseDir
@CD ..
@IF "%WDIR%"=="%CD%" GOTO baseDirNotFound
@SET "WDIR=%CD%"
@GOTO findBaseDir

:baseDirNotFound
@SET "WDIR=%EXEC_DIR%"
@CD "%WDIR%"

:foundBaseDir
@SET "PROJECT_BASE_DIR=%WDIR%"
@CD "%EXEC_DIR%"

@IF NOT "%JAVA_HOME%" == "" GOTO OkJHome

@ECHO.
@ECHO Error: JAVA_HOME not found in your environment. >&2
@ECHO Please set the JAVA_HOME variable in your environment to match the >&2
@ECHO location of your Java installation. >&2
@ECHO.
@GOTO error

:OkJHome
@IF EXIST "%JAVA_HOME%\bin\java.exe" GOTO init

@ECHO.
@ECHO Error: JAVA_HOME is set to an invalid directory. >&2
@ECHO JAVA_HOME = "%JAVA_HOME%" >&2
@ECHO Please set the JAVA_HOME variable in your environment to match the >&2
@ECHO location of your Java installation. >&2
@ECHO.
@GOTO error

:init
@SET "CMD_LINE_ARGS=%*"

@SET "MAVEN_PROJECTBASEDIR=%PROJECT_BASE_DIR%"
@SET "MAVEN_CMD_LINE_ARGS=%CMD_LINE_ARGS%"
@SET "WRAPPER_JAR=%PROJECT_BASE_DIR%\.mvn\wrapper\maven-wrapper.jar"
@SET "DOWNLOAD_URL=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar"

@IF EXIST "%WRAPPER_JAR%" GOTO run

@ECHO - Downloader started
@ECHO - Downloading %DOWNLOAD_URL% to %WRAPPER_JAR%
@IF NOT EXIST "%PROJECT_BASE_DIR%\.mvn\wrapper" MKDIR "%PROJECT_BASE_DIR%\.mvn\wrapper"
@powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%WRAPPER_JAR%')"

:run
@"%JAVA_HOME%\bin\java.exe" %MAVEN_OPTS% -Dmaven.multiModuleProjectDirectory="%MAVEN_PROJECTBASEDIR%" -classpath "%WRAPPER_JAR%" org.apache.maven.wrapper.MavenWrapperMain %MAVEN_CMD_LINE_ARGS%

@IF ERRORLEVEL 1 GOTO error
@GOTO end

:error
@SET ERROR_CODE=1

:end
@IF NOT "%MAVEN_BATCH_PAUSE%" == "on" GOTO quit
@PAUSE

:quit
@IF "%OS%"=="Windows_NT" @ENDLOCAL
@EXIT /B %ERROR_CODE%
