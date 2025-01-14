# Capture Python Error Output (ce.bat)

This batch script is designed to run a Python script, display its output in the console, and **only** copy that output to the clipboard if an error (non-zero exit code) occurs. That way, if you need to quickly paste error messages into a Large Language Model (LLM) or elsewhere, you can do so easily—without overwriting your clipboard on successful runs.

## 1. How It Works

1. You provide the path to the Python script as an argument to `ce.bat`.
2. `ce.bat` captures the Python script’s output (both stdout and stderr) into a temporary file.
3. It then displays that output on the console (always).
4. It checks the Python script’s exit code:
   - **If Python returns a non-zero exit code** (indicating an error), `ce.bat` copies the output to the clipboard so you can quickly paste it into an LLM or anywhere else.
   - **If Python returns zero** (indicating success), `ce.bat` **does not** touch the clipboard, so whatever was there remains unchanged.
5. The script cleans up the temporary file and exits with the same code Python returned, preserving any error handling logic for other processes that call it.

## 2. Prerequisites

- **Windows** operating system (tested on Windows 10 or later).  
- **Python** installed and available on your system’s `PATH` (so the `python` command works in your console).  
- **clip.exe** is typically included in Windows by default (found in `System32`).  

## 3. Installation

### 3.1 Create the Batch File

1. Create a new text file (using Notepad or any text editor).
2. Paste the following script into it:

   ```bat
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
   ```

3. Save the file as **`ce.bat`** (short for “Capture Error”), or any other name you prefer. For the rest of this README, we assume `ce.bat`.

### 3.2 Place `ce.bat` in a Folder That’s On Your PATH

To run `ce.bat` from any directory, you need to put it somewhere on your system `PATH`. Two common approaches:

1. **Add `ce.bat` to an existing folder** that is already on your `PATH` (e.g., `C:\Windows\System32` or any custom folder you already have in your PATH).  
2. **Create a new folder** (e.g., `C:\tools\batch-scripts`) and add that folder to the `PATH`.

**To add a new folder to PATH** (on Windows 10/11):
1. Press `Win + R`, type `SystemPropertiesAdvanced`, and press Enter.  
2. Click on **Environment Variables**.  
3. Under **System variables**, scroll to **Path** and select **Edit**.  
4. Click **New** and paste the full path of your new folder (e.g., `C:\tools\batch-scripts`).  
5. Click **OK** to save changes.  
6. Move or copy `ce.bat` into this folder.

After updating your PATH, **close and reopen** any open command prompts or PowerShell sessions so the changes take effect.

## 4. Usage

Once `ce.bat` is on your PATH:

1. **Open** a Command Prompt or Windows Terminal (CMD mode).
2. **Navigate** to your Python script’s directory, or specify the full path.  
3. Run:
   ```bat
   ce myscript.py
   ```
   or  
   ```bat
   ce "C:\path\to\myscript.py"
   ```
4. You’ll see the script’s output on-screen.  
   - If the script **fails** (exit code != 0), you’ll see a message indicating an error, and the full output will be in your clipboard.  
   - If the script **succeeds** (exit code = 0), you’ll see a success message, and the clipboard will remain unchanged.

### 4.1 Example

```bat
cd C:\MyPythonProjects
ce data_processor.py
```

- The script’s output is shown in the console.  
- If `data_processor.py` raises an error, everything it printed (including stack traces) is automatically placed in the clipboard, ready for pasting into an LLM or text editor.

## 5. Technical Explanation

- **Redirection**: We use `> out_temp.txt 2>&1` to capture both stdout (file descriptor 1) and stderr (file descriptor 2) in a single file.  
- **Check Error Level**: `%ERRORLEVEL%` is a special variable CMD uses to store the exit code of the last run command. Python typically sets this to `0` for success and `1` (or other non-zero values) for errors.  
- **Clipboard**: `clip.exe` is a built-in Windows command that reads from stdin and writes to the clipboard. `type out_temp.txt | clip` copies the file’s contents to the clipboard.  
- **Cleanup**: We delete `out_temp.txt` once we’ve displayed it and optionally copied it. If you’d prefer to keep the temp file for inspection, remove the `del out_temp.txt` line.  
- **Exit Code**: By ending with `exit /b %SCRIPT_EXIT_CODE%`, this batch file returns the same status code as the Python script, preserving error handling logic if you use `ce.bat` in a larger pipeline.

## 6. Tips & Customization

- **Appending to a Log**: Uncomment the line  
  ```bat
  :: type out_temp.txt >> "C:\temp\python_output.log"
  ```  
  if you want to save all output (whether success or error) to a persistent file.  
- **Multiple Python Arguments**: If your Python script requires additional arguments (e.g., `myscript.py --foo bar`), run:  
  ```bat
  ce "myscript.py --foo bar"
  ```  
  Adjust the script if you need more sophisticated argument handling.  
- **Non-Python Commands**: This batch file can work for any command-line tool that returns a proper exit code—just replace `python "%SCRIPT%"` with your command.  

## 7. Contributing

If you have improvements—like better error messages, more robust argument handling, or additional features—feel free to fork this and submit a pull request or share your modifications with the community.

## 8. License

You can specify any open-source license you prefer (e.g., MIT, Apache 2.0, etc.). If not specified, assume you share it freely.

---

With `ce.bat` in place, you’ll be able to quickly capture error messages from Python scripts (or other command-line tools) to your clipboard—making it much easier to share or paste into chat-based Large Language Models or other troubleshooting channels.