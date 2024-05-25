@echo off

set DST_MOD_DIR=D:\Steam\steamapps\common\Don't Starve Together\mods
set GALE_MOD_DIR=%DST_MOD_DIR%\gale
set RELEASE_MOD_DIR=%DST_MOD_DIR%\gale_release

@REM cd "%GALE_MOD_DIR%"
git clone "%GALE_MOD_DIR%" "%RELEASE_MOD_DIR%" 

@REM cd %RELEASE_MOD_DIR%
@REM rm -rf .git