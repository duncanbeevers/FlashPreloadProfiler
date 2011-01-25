@echo off
 
set flex_sdk_dir=%FLEX_PATH%
 
if (%FLEX_PATH%) == (path_to_flex_sdk) goto sdk_missing
if (%FLEX_PATH%) == () goto sdk_missing
if not exist %FLEX_PATH% goto sdk_missing
 
goto make
 
:sdk_missing
echo You have to set the path to the Flex SDK inside "%0.bat".
goto end
 
:make
if not exist bin md bin
if not exist obj md obj


%FLEX_PATH%\bin\compc.exe -load-config+=%cd%\obj\build_swc.xml

echo Build SWC complete.
:end
echo Done. 
@echo on
@pause