@echo off
title EPM Automate
REM mode con:cols=100
set returnValue=0

SET utility_dir=%~dp0 
set current_dir=%CD%

cd /d %utility_dir%
set temp_pwd=%cd%
cd /d %current_dir%

set JAVA_HOME=%temp_pwd%\..\jre1.8.0_111

if not exist "%JAVA_HOME%" (
    echo ERROR: JAVA_HOME is not set. Please set the JAVA_HOME and try again
    goto Finished )
	
SET /A ARGS_COUNT=0    
FOR %%A in (%*) DO SET /A ARGS_COUNT+=1    

if %ARGS_COUNT% == 0 (
	cls
	echo.
    echo EPM Automate Version 19.08.56
	echo Welcome to EPM Automate.Type epmautomate help and press ^<Enter^> for help.
	echo.
	set returnValue=6
	goto end
)
SET ARGS_LIST=%*

set lib_path=%temp_pwd%\..\lib
set class_path="%lib_path%\commons-codec-1.4.jar;%lib_path%\commons-httpclient-3.1.jar;%lib_path%\commons-io-1.4.jar;%lib_path%\commons-logging-1.1.jar;%lib_path%\json.jar;%lib_path%\commons-compress-1.18.jar;%lib_path%\epmautomate.jar;%lib_path%\opencsv-3.8.jar;BUFFER SPACE TO ADD NEW JARS WITHOUT WHICH UPGRADE WILL START FAILING AS IT REQUIRES THE FILE TO BE INTACT POST REPLACE"


set JAVA_OPTS=-Xms128m -Xmx1024m -DEXE_PATH="%lib_path%" -Dfile.encoding=UTF8

"%JAVA_HOME%\bin\java" %JAVA_OPTS% -cp %class_path% com.hyperion.epmctl.client.processor.EPMCTLProcessor %ARGS_LIST%
goto Finished

:end
cmd /k

:FoundError
if %ERRORLEVEL% == 0 (
	exit
)

:Finished

if %ERRORLEVEL% == 99 (
	goto Upgrade
)

set returnValue=%ERRORLEVEL%
endlocal & exit /B %returnValue%	


:Upgrade

cd /d "%temp_pwd%\.."

Call "upgrade.bat" "%current_dir%"

set returnValue=%ERRORLEVEL%
endlocal & exit /B %returnValue%