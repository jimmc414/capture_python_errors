@echo off

:: First argument: path to the Python script
set "SCRIPT=%~1"

:: Run the Python script, capturing stdout + stderr to a temp file
python "%SCRIPT%" > out_temp.txt 2>&1

:: Store the exit code right after running Python
set SCRIPT_EXIT_CODE=%ERRORLEVEL%

:: Always display the output on the console
type out_temp.txt

:: Check the exit code
if %SCRIPT_EXIT_CODE% neq 0 (
    echo [ERROR]: The Python script exited with error code %SCRIPT_EXIT_CODE%.
    echo Copying error output to clipboard...
    type out_temp.txt | clip
) else (
    echo [SUCCESS]: The Python script exited successfully.
    echo The clipboard was not changed.
)

:: (Optional) Append output to a log file if desired
:: type out_temp.txt >> "C:\temp\python_output.log"

:: Clean up
del out_temp.txt

:: Exit with the same code as Python gave
exit /b %SCRIPT_EXIT_CODE%
