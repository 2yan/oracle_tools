@echo off
title EPM Automate Upgrade

SET CURR_DIR=%cd%
SET TEMP_PATH=%CURR_DIR%\temp
SET OUTPUT_DIR=%CURR_DIR%\temp\extracted
SET LOG_FILE=%CURR_DIR%\upgrade.log
SET "WORK_DIR=%1"

IF exist "%LOG_FILE%" ( 
del "%LOG_FILE%"
echo ::Removed %LOG_FILE% > "%LOG_FILE%"
)

echo Enter RemoveDirIfExists %TEMP_PATH% >> "%LOG_FILE%"
IF exist "%TEMP_PATH%" ( 
rd /s /q "%TEMP_PATH%" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :ErrorAndExit 2
	exit /B 2
)

echo ::Removed %TEMP_PATH% >> "%LOG_FILE%"
)
echo Exit RemoveDirIfExists >> "%LOG_FILE%"

echo Enter CreateIfNotExisting %TEMP_PATH% >> "%LOG_FILE%"
IF not exist "%TEMP_PATH%" (
md "%TEMP_PATH%" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :ErrorAndExit 3
	exit /B 3
)

echo ::Created %TEMP_PATH% >> "%LOG_FILE%"
) 

echo Exit CreateIfNotExisting >> "%LOG_FILE%"


echo Enter CreateIfNotExisting %OUTPUT_DIR% >> "%LOG_FILE%"
IF not exist "%OUTPUT_DIR%" (
md "%OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :ErrorAndExit 3
	exit /B 3
)

echo ::Created %OUTPUT_DIR% >> "%LOG_FILE%"
) 

echo Exit CreateIfNotExisting >> "%LOG_FILE%"


echo Enter ExtractFiles %TEMP_PATH% %OUTPUT_DIR% >> "%LOG_FILE%"
"EPM Automate.exe" /s /b"%TEMP_PATH%" /v"/qn" >> "%LOG_FILE%" 2>&1
ECHO msiexec /a "%TEMP_PATH%\EPM Automate.msi" /qb TARGETDIR="%OUTPUT_DIR%" >> "%LOG_FILE%"
msiexec /a "%TEMP_PATH%\EPM Automate.msi" /qb TARGETDIR="%OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :ErrorAndExit 4
	exit /B 4
)

echo Exit ExtractFiles >> "%LOG_FILE%"



echo Enter StartUpgrade >> "%LOG_FILE%"	

	echo Enter RemoveFileIfExists bin\epmautomate.bak >> "%LOG_FILE%"
	IF exist "bin\epmautomate.bak" ( 
	del "bin\epmautomate.bak" >> "%LOG_FILE%" 2>&1
	
	if %ERRORLEVEL% NEQ 0 (
		call :ErrorAndExit 5
		exit /B 5
	)
	
	echo "::Removed bin\epmautomate.bak" >> "%LOG_FILE%"
	)
	echo Exit RemoveFileIfExists >> "%LOG_FILE%"
	
	echo Enter RenameDirectory "bin\epmautomate.bat" to "epmautomate.bak" >> "%LOG_FILE%"
	REN "bin\epmautomate.bat" "epmautomate.bak" >> "%LOG_FILE%" 2>&1

	if %ERRORLEVEL% NEQ 0 (
		call :ErrorAndExit 5
		exit /B 5
	)

	echo Exit RenameDirectory >> "%LOG_FILE%"
	
	echo Enter RemoveDirIfExists lib_bk >> "%LOG_FILE%"
	IF exist "lib_bk" ( 
	rd /s /q "lib_bk" >> "%LOG_FILE%" 2>&1

	if %ERRORLEVEL% NEQ 0 (
		call :RestoreAndExit 6
		exit /B 6
	)

	echo ::Removed lib_bk >> "%LOG_FILE%"
	)
	echo Exit RemoveDirIfExists >> "%LOG_FILE%"
	
	echo Enter RenameDirectory "lib" to "lib_bk" >> "%LOG_FILE%"
	REN "lib" "lib_bk" >> "%LOG_FILE%" 2>&1

	if %ERRORLEVEL% NEQ 0 (
		call :RestoreAndExit 6
		exit /B 6
	)

	echo Exit RenameDirectory >> "%LOG_FILE%"	

	echo cd /d %OUTPUT_DIR%\Oracle\EPM Automate >> "%LOG_FILE%"	
	cd /d "%OUTPUT_DIR%\Oracle\EPM Automate"

	FOR /D %%G in ("*") DO ( 				
		
		IF not exist "%CURR_DIR%\%%~nxG" ( 
		echo Enter CopyDirectory "%%~nxG" to "%CURR_DIR%\%%~nxG" >> "%LOG_FILE%"
			echo "::copying %%~nxG" >> "%LOG_FILE%"
			xcopy "%%~nxG" "%CURR_DIR%\%%~nxG" /E /D /i >> "%LOG_FILE%" 2>&1
		
				if %ERRORLEVEL% NEQ 0 (
					call :RestoreAndExit 7
					exit /B 7
				)
		echo Exit CopyDirectory >> "%LOG_FILE%"
		)
    )
	
	echo "::copying epmautomate.bat" >> "%LOG_FILE%"
	xcopy "bin" "%CURR_DIR%\bin" /E /D /i >> "%LOG_FILE%" 2>&1
	
	if %ERRORLEVEL% NEQ 0 (
		call :RestoreAndExit 8
		exit /B 8
	)	
	
echo Exit StartUpgrade >> "%LOG_FILE%"

echo cd /d %CURR_DIR% >> "%LOG_FILE%"	
cd /d "%CURR_DIR%"

echo Enter RemoveDirIfExists %TEMP_PATH% >> "%LOG_FILE%"
IF exist "%TEMP_PATH%" ( 
rd /s /q "%TEMP_PATH%" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :WarnAndExit 9
	exit /B 9
)

echo ::Removed %TEMP_PATH% >> "%LOG_FILE%"
)
echo Exit RemoveDirIfExists >> "%LOG_FILE%"

echo Enter RemoveDirIfExists lib_bk >> "%LOG_FILE%"
IF exist "lib_bk" ( 
rd /s /q "lib_bk" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :WarnAndExit 9
	exit /B 9
)

echo "::Removed lib_bk" >> "%LOG_FILE%"
)
echo Exit RemoveDirIfExists >> "%LOG_FILE%"

echo Enter RemoveFileIfExists EPM Automate.exe >> "%LOG_FILE%"
IF exist "EPM Automate.exe" ( 
del "EPM Automate.exe" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :WarnAndExit 9
	exit /B 9
)

echo "::Removed EPM Automate.exe" >> "%LOG_FILE%"
)
echo Exit RemoveFileIfExists >> "%LOG_FILE%"

echo Enter RemoveFileIfExists bin\epmautomate.bak >> "%LOG_FILE%"
IF exist "bin\epmautomate.bak" ( 
del "bin\epmautomate.bak" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :WarnAndExit 9
	exit /B 9
)

echo "::Removed bin\epmautomate.bak" >> "%LOG_FILE%"
)
echo Exit RemoveFileIfExists >> "%LOG_FILE%"

echo cd /d %WORK_DIR% >> "%LOG_FILE%"	
cd /d "%WORK_DIR%"

echo upgrade completed successfully
EXIT /B 0

:RestoreAndExit	 
echo Enter RestoreAndExit %~1 >> "%LOG_FILE%"

echo cd /d %CURR_DIR% >> "%LOG_FILE%"	
cd /d "%CURR_DIR%"

echo Enter RemoveDirIfExists %TEMP_PATH% >> "%LOG_FILE%"
IF exist "%TEMP_PATH%" ( 
rd /s /q "%TEMP_PATH%" >> "%LOG_FILE%" 2>&1
echo ::Removed %TEMP_PATH% >> "%LOG_FILE%"
)
echo Exit RemoveDirIfExists >> "%LOG_FILE%"

echo Enter RemoveDirIfExists lib >> "%LOG_FILE%"
IF exist "lib_bk" ( 
rd /s /q "lib" >> "%LOG_FILE%" 2>&1
echo "::Removed lib" >> "%LOG_FILE%"
)
echo Exit RemoveDirIfExists >> "%LOG_FILE%"

echo Enter RemoveFileIfExists bin\epmautomate.bat >> "%LOG_FILE%"
IF exist "bin\epmautomate.bat" ( 
del "bin\epmautomate.bat" >> "%LOG_FILE%" 2>&1

echo "::Removed bin\epmautomate.bat" >> "%LOG_FILE%"
)
echo Exit RemoveFileIfExists >> "%LOG_FILE%"

echo Enter RenameDirectory "bin\epmautomate.bak" to "epmautomate.bat" >> "%LOG_FILE%"

IF exist "bin\epmautomate.bak" (
REN "bin\epmautomate.bak" "epmautomate.bat" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :WarnAndExit 10
	exit /B 10
)
)
echo Exit RenameDirectory >> "%LOG_FILE%"
	
echo Enter RenameDirectory "lib_bk" to "lib" >> "%LOG_FILE%"
IF exist "lib_bk" (
REN "lib_bk" "lib" >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
	call :WarnAndExit 10
	exit /B 10
)
)

echo Exit RenameDirectory >> "%LOG_FILE%"	

echo cd /d %WORK_DIR% >> "%LOG_FILE%"	
cd /d "%WORK_DIR%"
echo Auto upgrade failed. The system has been restored to the original version of EPMAutomate. Please upgrade manually using EPM Automate.exe downloaded in the epmautomate home.
echo Exit RestoreAndExit >> "%LOG_FILE%"
exit /B %~1

:ErrorAndExit
echo Enter ErrorAndExit %~1 >> "%LOG_FILE%"

echo cd /d %CURR_DIR% >> "%LOG_FILE%"	
cd /d "%CURR_DIR%"

echo Enter RemoveDirIfExists %TEMP_PATH% >> "%LOG_FILE%"
IF exist "%TEMP_PATH%" ( 
rd /s /q "%TEMP_PATH%" >> "%LOG_FILE%" 2>&1
echo ::Removed %TEMP_PATH% >> "%LOG_FILE%"
)
echo Exit RemoveDirIfExists >> "%LOG_FILE%"

echo cd /d %WORK_DIR% >> "%LOG_FILE%"	
cd /d "%WORK_DIR%"

echo Auto upgrade failed. Please upgrade manually using EPM Automate.exe downloaded in the epmautomate home.
echo Exit ErrorAndExit >> "%LOG_FILE%"
exit /b %~1

:WarnAndExit
echo Enter WarnAndExit %~1 >> "%LOG_FILE%"
echo cd /d %WORK_DIR% >> "%LOG_FILE%"	
cd /d "%WORK_DIR%"
echo Auto upgrade completed with cleanup failures. 
echo Exit WarnAndExit >> "%LOG_FILE%"
exit /B %~1