@echo off
setlocal
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

set SkyDriveDir=%CD%
set WorkingDir=%PUBLIC%\Working

:PROCESSORS
if not "%1"=="" (
  for /f "tokens=3,4,5 delims=," %%i in (__arglist.csv) do (
    set CurDir=%%i
      if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set CurDir=%%j
      start /d "%DstDir%\%%i" !CurDir! %%k
  )
) else (
  set DataDir=Programs
    if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set DataDir=!DataDir!\amd64
    call :START !DataDir!
)
goto :eof

:START
set PATH=%WorkingDir%\%~1\Program Files\Libraries;%PATH%
set OutputDir=%USERPROFILE%\Desktop
set SevenZipExe=7za
set SrcDir=%PUBLIC%\packages
set DstDir=%OutputDir%\Programs
choice /c SDL
  if %ERRORLEVEL% EQU 1 (
    rd /s /q "%DstDir%"
    set XD=amd64
      call :RC %1
      call :EnvVar
      call :PROCESSORS .
      call :SKP 1
  ) else if %ERRORLEVEL% EQU 2 (
    rd /s /q "%SrcDir%"
    set XD=_Exception
      choice /t 10 /c CA /d A
        set FLAG=!ERRORLEVEL!
          call :DEPLOY "Program Files"
          call :DEPLOY "ProgramData"
  ) else if %ERRORLEVEL% EQU 3 (
    call :EnvVar
    choice /c AL
      if !ERRORLEVEL! EQU 1 (
        rd /s /q "%DstDir%"
        set XD=amd64
          call :RC %1
      ) else if !ERRORLEVEL! EQU 2 (
        echo.
      )
    call :SKP 10
  )

:EnvVar
for /f "tokens=*" %%i in ('dir /b /a:d "%DstDir%"') do (
  set PATH=%DstDir%\%%i;!PATH!
)
goto :eof

:SKP
for /f "skip=%1 tokens=1,2 delims=," %%i in (__arglist.csv) do (
  start /d "%DstDir%\%%i" %%i %%j
)
goto :eof

:DEPLOY
if %FLAG% EQU 2 (
  if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set FLAG=0
)
set SrcDir=%WorkingDir%\Programs
set DstDir=%PUBLIC%\packages\Programs
  if %FLAG% GEQ 1 (
    call :RC %1
    call :RC "%~1\%XD%"
  )
  if %FLAG% LEQ 1 (
    set DstDir=%DstDir%\amd64
      call :RC %1
    set SrcDir=%SrcDir%\amd64
      call :RC %1
      call :RC "%~1\%XD%"
  )

:RC
for /f "tokens=*" %%i in ('dir /b /a:d "%SrcDir%\%~1"') do (
  if not "%%i"=="%XD%" (
    robocopy "%SrcDir%\%~1\%%i" "%DstDir%\%%i" /E /V /NP /MT:128 2>&1>NUL
  )
)