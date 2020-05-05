; <AUT2EXE VERSION: 3.1.1.127>

; ----------------------------------------------------------------------------
; <AUT2EXE INCLUDE-START: G:\Green Soft\Launch\AutoAlias\AutoAlias.au3>
; ----------------------------------------------------------------------------


; ----------------------------------------------------------------------------
; <AUT2EXE INCLUDE-START: G:\Program Files\AutoIt3\beta\Include\file.au3>
; ----------------------------------------------------------------------------

; Include Version:1.58  (4/2/2006)

; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with files and directories.
;
; ------------------------------------------------------------------------------


;===============================================================================
;
; Description:      Returns the number of lines in the specified file.
; Syntax:           _FileCountLines( $sFilePath )
; Parameter(s):     $sFilePath - Path and filename of the file to be read
; Requirement(s):   None
; Return Value(s):  On Success - Returns number of lines in the file
;                   On Failure - Returns 0 and sets @error = 1
; Author(s):        Tylo <tylo at start dot no>
; Note(s):          It does not count a final @LF as a line.
;
;===============================================================================
Func _FileCountLines($sFilePath)
	Local $N = FileGetSize($sFilePath) - 1
	If @error Or $N = -1 Then Return 0
	Return StringLen(StringAddCR(FileRead($sFilePath, $N))) - $N + 1
EndFunc   ;==>_FileCountLines


;===============================================================================
;
; Description:      Creates or zero's out the length of the file specified.
; Syntax:           _FileCreate( $sFilePath )
; Parameter(s):     $sFilePath - Path and filename of the file to be created
; Requirement(s):   None
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0 and sets:
;                                @error = 1: Error opening specified file
;                                @error = 2: File could not be written to
; Author(s):        Brian Keene <brian_keene at yahoo dot com>
; Note(s):          None
;
;===============================================================================
Func _FileCreate($sFilePath)
	;==============================================
	; Local Constant/Variable Declaration Section
	;==============================================
	Local $hOpenFile
	Local $hWriteFile

	$hOpenFile = FileOpen($sFilePath, 2)

	If $hOpenFile = -1 Then
		SetError(1)
		Return 0
	EndIf

	$hWriteFile = FileWrite($hOpenFile, "")

	If $hWriteFile = -1 Then
		SetError(2)
		Return 0
	EndIf

	FileClose($hOpenFile)
	Return 1
EndFunc   ;==>_FileCreate

;===============================================================================
;
; Description:      lists all files and folders in a specified path (Similar to using Dir with the /B Switch)
; Syntax:           _FileListToArray($sPath, $sFilter = "*", $iFlag = 0)
; Parameter(s):    	$sPath = Path to generate filelist for
;                   $iFlag = determines weather to return file or folders or both
;					$sFilter = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;						$iFlag=0(Default) Return both files and folders
;                       $iFlag=1 Return files Only
;						$iFlag=2 Return Folders Only
;
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;					On Failure - Returns an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $sFilter
;                       @Error=3 Invalid $iFlag
;
; Author(s):        SolidSnake <MetalGearX91 at Hotmail dot com>
; Note(s):			The array returned is one-dimensional and is made up as follows:
;					$array[0] = Number of Files\Folders returned
;					$array[1] = 1st File\Folder
;					$array[2] = 2nd File\Folder
;					$array[3] = 3rd File\Folder
;					$array[n] = nth File\Folder
;
;					Special Thanks to Helge and Layer for help with the $iFlag update
;===============================================================================
Func _FileListToArray($sPath, $sFilter = "*", $iFlag = 0)
	Local $hSearch, $sFile, $asFileList[1]
	If Not FileExists($sPath) Then
		SetError(1)
		Return ""
	EndIf
	If (StringInStr($sFilter, "\")) or (StringInStr($sFilter, "/")) or (StringInStr($sFilter, ":")) or (StringInStr($sFilter, ">")) or (StringInStr($sFilter, "<")) or (StringInStr($sFilter, "|")) or (StringStripWS($sFilter, 8) = "") Then
		SetError(2)
		Return 0
	EndIf
	If Not ($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then
		SetError(3)
		Return ""
	EndIf
	$asFileList[0] = 0
	$hSearch = FileFindFirstFile($sPath & "\" & $sFilter)
	If $hSearch = -1 Then
		SetError(0)
		Return 0
	EndIf
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If $iFlag = 1 Then
			If StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") <> 0 Then ContinueLoop
		EndIf
		If $iFlag = 2 Then
			If StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") = 0 Then ContinueLoop
		EndIf
		ReDim $asFileList[UBound($asFileList) + 1]
		$asFileList[0] = $asFileList[0] + 1
		$asFileList[UBound($asFileList) - 1] = $sFile
	WEnd
	FileClose($hSearch)
	SetError(0)
	If $asFileList[0] = 0 Then Return ""
	Return $asFileList
EndFunc   ;==>_FileListToArray

;===============================================================================
; Function Name:   _FilePrint()
; Description:     Prints a plain text file.
; Syntax:          _FilePrint ( $s_File [, $i_Show] )
;
; Parameter(s):    $s_File     = The file to print.
;                  $i_Show     = The state of the window. (default = @SW_HIDE)
;
; Requirement(s):  External:   = shell32.dll (it's already in system32).
;                  Internal:   = None.
;
; Return Value(s): On Success: = Returns 1.
;                  On Failure: = Returns 0 and sets @error according to the global constants list.
;
; Author(s):       erifash <erifash [at] gmail [dot] com>
;
; Note(s):         Uses the ShellExecute function of shell32.dll.
;
; Example(s):
;   _FilePrint("C:\file.txt")
;===============================================================================
Func _FilePrint($s_File, $i_Show = @SW_HIDE)
	Local $a_Ret = DllCall("shell32.dll", "long", "ShellExecute", _
			"hwnd", 0, _
			"string", "print", _
			"string", $s_File, _
			"string", "", _
			"string", "", _
			"int", $i_Show)
	If $a_Ret[0] > 32 And Not @error Then
		Return 1
	Else
		SetError($a_Ret[0])
		Return 0
	EndIf
EndFunc   ;==>_FilePrint

;===============================================================================
;
; Description:      Reads the specified file into an array.
; Syntax:           _FileReadToArray( $sFilePath, $aArray )
; Parameter(s):     $sFilePath - Path and filename of the file to be read
;                   $aArray    - The array to store the contents of the file
; Requirement(s):   None
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0 and sets @error = 1
; Author(s):        Jonathan Bennett <jon at hiddensoft dot com>
; Note(s):          None
;
;===============================================================================
Func _FileReadToArray($sFilePath, ByRef $aArray)
	;==============================================
	; Local Constant/Variable Declaration Section
	;==============================================
	Local $hFile

	$hFile = FileOpen($sFilePath, 0)

	If $hFile = -1 Then
		SetError(1)
		Return 0
	EndIf

	$aArray = StringSplit( StringStripCR( FileRead($hFile, FileGetSize($sFilePath))), @LF)

	FileClose($hFile)
	Return 1
EndFunc   ;==>_FileReadToArray

;===============================================================================
;
; Description:      Write array to File.
; Syntax:           _FileWriteFromArray( $sFilePath, $aArray )
; Parameter(s):     $sFilePath - Path and filename of the file to be written
;                   $a_Array   - The array to retrieve the contents
;                   $i_Base    - Start reading at this Array entry.
;                   $I_Ubound  - End reading at this Array entry.
;                                Default UBound($a_Array) - 1
; Requirement(s):   None
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0 and sets @error = 1
; Author(s):        Jos van der Zande <jdeb at autoitscript dot com>
; Note(s):          None
;
;===============================================================================
Func _FileWriteFromArray($sFilePath, $a_Array, $i_Base = 0, $i_UBound = 0)
	;==============================================
	; Local Constant/Variable Declaration Section
	;==============================================
	Local $hFile
	; Check if we have a valid array as input
	If Not IsArray($a_Array) Then
		SetError(2)
		Return 0
	EndIf
	; determine last entry
	Local $last = UBound($a_Array) - 1
	If $i_UBound < 1 Or $i_UBound > $last Then $i_UBound = $last
	If $i_Base < 0 Or $i_Base > $last Then $i_Base = 0
	; Open output file
	$hFile = FileOpen($sFilePath, 2)

	If $hFile = -1 Then
		SetError(1)
		Return 0
	EndIf
	;
	FileWrite($hFile, $a_Array[$i_Base])
	For $x = $i_Base + 1 To $i_UBound
		FileWrite($hFile, @CRLF & $a_Array[$x])
	Next

	FileClose($hFile)
	Return 1
EndFunc   ;==>_FileWriteFromArray

;===============================================================================
;
; Description:      Writes the specified text to a log file.
; Syntax:           _FileWriteLog( $sLogPath, $sLogMsg )
; Parameter(s):     $sLogPath - Path and filename to the log file
;                   $sLogMsg  - Message to be written to the log file
; Requirement(s):   None
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0 and sets:
;                                @error = 1: Error opening specified file
;                                @error = 2: File could not be written to
; Author(s):        Jeremy Landes <jlandes at landeserve dot com>
; Note(s):          If the text to be appended does NOT end in @CR or @LF then
;                   a DOS linefeed (@CRLF) will be automatically added.
;
;===============================================================================
Func _FileWriteLog($sLogPath, $sLogMsg)
	;==============================================
	; Local Constant/Variable Declaration Section
	;==============================================
	Local $sDateNow
	Local $sTimeNow
	Local $sMsg
	Local $hOpenFile
	Local $hWriteFile

	$sDateNow = @YEAR & "-" & @MON & "-" & @MDAY
	$sTimeNow = @HOUR & ":" & @MIN & ":" & @SEC
	$sMsg = $sDateNow & " " & $sTimeNow & " : " & $sLogMsg

	$hOpenFile = FileOpen($sLogPath, 1)

	If $hOpenFile = -1 Then
		SetError(1)
		Return 0
	EndIf

	$hWriteFile = FileWriteLine($hOpenFile, $sMsg)

	If $hWriteFile = -1 Then
		SetError(2)
		Return 0
	EndIf

	FileClose($hOpenFile)
	Return 1
EndFunc   ;==>_FileWriteLog

;========================================
;Function name:       _FileWriteToLine
;Description:         Write text to specified line in a file
;Parameters:
;                     $sFile - The file to write to
;                     $iLine - The line number to write to
;                     $sText - The text to write
;                     $fOverWrite - if set to 1 will overwrite the old line
;                     if set to 0 will not overwrite
;Requirement(s):      None
;Return Value(s):     On success - 1
;                      On Failure - 0 And sets @ERROR
;                                @ERROR = 1 - File has less lines than $iLine
;                                @ERROR = 2 - File does not exist
;                                @ERROR = 3 - Error opening file
;                                @ERROR = 4 - $iLine is invalid
;                                @ERROR = 5 - $fOverWrite is invalid
;                                @ERROR = 6 - $sText is invalid
;Author(s):           cdkid
;Note(s):
;=========================================
Func _FileWriteToLine($sFile, $iLine, $sText, $fOverWrite = 0)
	If $iLine <= 0 Then
		SetError(4)
		Return 0
	EndIf
	If Not IsString($sText) Then
		SetError(6)
		Return 0
	EndIf
	If $fOverWrite <> 0 And $fOverWrite <> 1 Then
		SetError(5)
		Return 0
	EndIf
	If Not FileExists($sFile) Then
		SetError(2)
		Return 0
	EndIf
	Local $filtxt = FileRead($sFile, FileGetSize($sFile))
	$filtxt = StringSplit($filtxt, @CRLF, 1)
	If UBound($filtxt, 1) < $iLine Then
		SetError(1)
		Return 0
	EndIf
	Local $fil = FileOpen($sFile, 2)
	If $fil = -1 Then
		SetError(3)
		Return 0
	EndIf
	For $i = 1 To UBound($filtxt) - 1
		If $i = $iLine Then
			If $fOverWrite = 1 Then
				If $sText <> '' Then
					FileWrite($fil, $sText & @CRLF)
				Else
					FileWrite($fil, $sText)
				EndIf
			EndIf
			If $fOverWrite = 0 Then
				FileWrite($fil, $sText & @CRLF)
				FileWrite($fil, $filtxt[$i] & @CRLF)
			EndIf
		ElseIf $i < UBound($filtxt, 1) - 1 Then
			FileWrite($fil, $filtxt[$i] & @CRLF)
		ElseIf $i = UBound($filtxt, 1) - 1 Then
			FileWrite($fil, $filtxt[$i])
		EndIf
	Next
	FileClose($fil)
	Return 1
EndFunc   ;==>_FileWriteToLine

; ===================================================================
	; Author: Jason Boggs <vampirevalik AT hotmail DOT com
	;		updated 2006/01/07
	;
	; _PathFull($szRelPath)
	;
	; Creates a path based on the relative path you provide.  For example, if you specify:
	;	"C:\test\folder\..\file.txt", the output would be "C:\test\file.txt" because of the ..\.
	;	If no relative path is specified, the current working directory is returned.  If no drive is specified,
	;	the new path is relative to the current working directory.  Passing only a drive will return the
	;	current working directory for that drive.  This function depends on _PathSplit and _PathMake.
	; Parameters:
	; 	$szRelPath - IN - The relative path
	; Returns:
	;	The newly created absolute path is returned (Same as $szABSPath)
	; ===================================================================
Func _PathFull($szRelPath)
	Local $drive, $dir, $file, $ext, $wDrive, $NULL
	Local $i, $nPos; For Opt("MustDeclareVars", 1)
	; Let's use _PathSplit to make this a hell of a lot easier to work with
	_PathSplit($szRelPath, $drive, $dir, $file, $ext)
	_PathSplit(@WorkingDir, $wDrive, $NULL, $NULL, $NULL)

	; If no drive specified, then we use the working directory to set our path relative to
	If Not StringLen($drive) Then
		$drive = $wDrive
		If StringLen(@WorkingDir) = StringLen($drive) + 1 Then
			$dir = StringTrimLeft(@WorkingDir, StringLen($drive)) & $dir
		Else
			$dir = StringTrimLeft(@WorkingDir, StringLen($drive)) & "\" & $dir
		EndIf
	EndIf

	; If the only thing specified was the drive, then return the working directory for that drive
	If Not StringLen($dir) And Not StringLen($file) And Not StringLen($ext) Then
		If $drive = $wDrive Then Return @WorkingDir
		Return _PathMake($drive, "\", "", "")
	EndIf

	; Look for any .\ and ..\
	While StringInStr($dir, ".\") Or StringInStr($dir, "./")
		$nPos = StringInStr($dir, ".\")
		If $nPos = 0 Then $nPos = StringInStr($dir, "./")
		If $nPos = 0 Then ExitLoop
		If StringMid($dir, $nPos - 1, 1) = "." Then; It's ..\
			For $i = ($nPos - 3) To 0 Step - 1
				If StringMid($dir, $i, 1) = "\" Or StringMid($dir, $i, 1) = "/" Then ExitLoop
			Next
			If $i > 0 Then
				$dir = StringLeft($dir, $i) & StringRight($dir, StringLen($dir) - ($nPos + 1))
			Else
				$dir = StringRight($dir, StringLen($dir) - ($nPos + 1))
			EndIf
		Else; It's .\
			$dir = StringLeft($dir, $nPos - 1) & StringRight($dir, StringLen($dir) - $nPos - 1)
		EndIf
		If Not StringLen($dir) Then $dir = "\"
	WEnd
	Return _PathMake($drive, $dir, $file, $ext)
EndFunc   ;==>_PathFull

; ===================================================================
; Author: Jason Boggs <vampirevalik AT hotmail DOT com
;
; _PathMake($szDrive, $szDir, $szFName, $szExt)
;
; Creates a string containing the path from drive, directory, file name and file extension parts.  Not all parts must be
;	passed. The path will still be built with what is passed.  This doesn't check the validity of the path
;	created, it could contain characters which are invalid on your filesystem.
; Parameters:
; 	$szDrive - IN - Drive (Can be UNC).  If it's a drive letter, a : is automatically appended
; 	$szDir - IN - Directory.  A trailing slash is added if not found (No preceeding slash is added)
; 	$szFName - IN - The name of the file
; 	$szExt - IN - The file extension.  A period is supplied if not found in the extension
; Returns:
;	The string for the newly created path
; ===================================================================
Func _PathMake($szDrive, $szDir, $szFName, $szExt)
	; Format $szDrive, if it's not a UNC server name, then just get the drive letter and add a colon
	Local $szFullPath
	;
	If StringLen($szDrive) Then
		If Not (StringLeft($szDrive, 2) = "\\") Then	$szDrive = StringLeft($szDrive, 1) & ":"
	EndIf

	; Format the directory by adding any necessary slashes
	If StringLen($szDir) Then
		If Not (StringRight($szDir, 1) = "\") And Not (StringRight($szDir, 1) = "/") Then $szDir = $szDir & "\"
	EndIf

	; Nothing to be done for the filename

	; Add the period to the extension if necessary
	If StringLen($szExt) Then
		If Not (StringLeft($szExt, 1) = ".") Then $szExt = "." & $szExt
	EndIf

	$szFullPath = $szDrive & $szDir & $szFName & $szExt
	Return $szFullPath
EndFunc   ;==>_PathMake

; ===================================================================
; Author: Jason Boggs <vampirevalik AT hotmail DOT com
;
; _PathSplit($szPath, ByRef $szDrive, ByRef $szDir, ByRef $szFName, ByRef $szExt)
;
; Splits a path into the drive, directory, file name and file extension parts.  An empty string is set if a
;	part is missing.
; Parameters:
;	$szPath - IN - The path to be split (Can contain a UNC server or drive letter)
;	$szDrive - OUT - String to hold the drive
; 	$szDir - OUT - String to hold the directory
; 	$szFName - OUT - String to hold the file name
; 	$szExt - OUT - String to hold the file extension
; Returns:
;	Array with 5 elements where 0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
; ===================================================================
Func _PathSplit($szPath, ByRef $szDrive, ByRef $szDir, ByRef $szFName, ByRef $szExt)
	; Set local strings to null (We use local strings in case one of the arguments is the same variable)
	Local $drive = ""
	Local $dir = ""
	Local $fname = ""
	Local $ext = ""
	Local $i, $pos; For Opt("MustDeclareVars", 1)

	; Create an array which will be filled and returned later
	Local $array[5]
	$array[0] = $szPath; $szPath can get destroyed, so it needs set now

	; Get drive letter if present (Can be a UNC server)
	If StringMid($szPath, 2, 1) = ":" Then
		$drive = StringLeft($szPath, 2)
		$szPath = StringTrimLeft($szPath, 2)
	ElseIf StringLeft($szPath, 2) = "\\" Then
		$szPath = StringTrimLeft($szPath, 2) ; Trim the \\
		$pos = StringInStr($szPath, "\")
		If $pos = 0 Then $pos = StringInStr($szPath, "/")
		If $pos = 0 Then
			$drive = "\\" & $szPath; Prepend the \\ we stripped earlier
			$szPath = ""; Set to null because the whole path was just the UNC server name
		Else
			$drive = "\\" & StringLeft($szPath, $pos - 1) ; Prepend the \\ we stripped earlier
			$szPath = StringTrimLeft($szPath, $pos - 1)
		EndIf
	EndIf

	; Set the directory and file name if present
	For $i = StringLen($szPath) To 0 Step - 1
		If StringMid($szPath, $i, 1) = "\" Or StringMid($szPath, $i, 1) = "/" Then
			$dir = StringLeft($szPath, $i)
			$fname = StringRight($szPath, StringLen($szPath) - $i)
			ExitLoop
		EndIf
	Next

	; If $szDir wasn't set, then the whole path must just be a file, so set the filename
	If StringLen($dir) = 0 Then $fname = $szPath

	; Check the filename for an extension and set it
	For $i = StringLen($fname) To 0 Step - 1
		If StringMid($fname, $i, 1) = "." Then
			$ext = StringRight($fname, StringLen($fname) - ($i - 1))
			$fname = StringLeft($fname, $i - 1)
			ExitLoop
		EndIf
	Next

	; Set the strings and array to what we found
	$szDrive = $drive
	$szDir = $dir
	$szFName = $fname
	$szExt = $ext
	$array[1] = $drive
	$array[2] = $dir
	$array[3] = $fname
	$array[4] = $ext
	Return $array
EndFunc   ;==>_PathSplit

; ===================================================================
; Author: Kurt (aka /dev/null) and JdeB
;
; _ReplaceStringInFile($szFileName, $szSearchString, $szReplaceString,$bCaseness = 0, $bOccurance = 0)
;
; Replaces a string ($szSearchString) with another string ($szReplaceString) the given TEXT file
; (via filename)
;
; Operation:
; The funnction opens the original file for reading and a temp file for writing. Then
; it reads in all lines and searches for the string. If it was found, the original line will be
; modified and written to the temp file. If the string was not found, the original line will be
; written to the temp file. At the end the original file will be deleted and the temp file will
; be renamed.
;
; Parameters:
; 	$szFileName 		name of the file to open.
;				ATTENTION !! Needs the FULL path, not just the name returned by eg. FileFindNextFile
; 	$szSearchString		The string we want to replace in the file
; 	$szReplaceString	The string we want as a replacement for $szSearchString
; 	$fCaseness		shall case matter?
;				0 = NO, case doe not matter (default), 1 = YES, case does matter
;	$fOccurance		shall we replace the string in every line or just the first occurance
;				0 = first only, 1 = ALL strings (default)
;
; Return Value(s):
;	On Success 		Returns the number of occurences of $szSearchString we found
;
;	On Failure 		Returns -1 sets @error
;					@error=1	Cannot open file
;					@error=2	Cannot open temp file
;					@error=3	Cannot write to temp file
;					@error=4	Cannot delete original file
;					@error=5	Cannot rename/move temp file
;
; ===================================================================
Func _ReplaceStringInFile($szFileName, $szSearchString, $szReplaceString, $fCaseness = 0, $fOccurance = 1)

	Local $iRetVal = 0
	Local $szTempFile, $hWriteHandle, $aFileLines, $nCount, $sEndsWith, $hFile
	;===============================================================================
	;== Read the file into an array
	;===============================================================================
	$hFile = FileOpen($szFileName, 0)
	If $hFile = -1 Then
		SetError(1)
		Return -1
	EndIf
	Local $s_TotFile = FileRead($hFile, FileGetSize($szFileName))
	If StringRight($s_TotFile, 2) = @CRLF Then
		$sEndsWith = @CRLF
	ElseIf StringRight($s_TotFile, 1) = @CR Then
		$sEndsWith = @CR
	ElseIf StringRight($s_TotFile, 1) = @LF Then
		$sEndsWith = @LF
	Else
		$sEndsWith = ""
	EndIf
	$aFileLines = StringSplit(StringStripCR($s_TotFile), @LF)
	FileClose($hFile)
	;===============================================================================
	;== Open the temporary file in write mode
	;===============================================================================
	$szTempFile = _TempFile()

	$hWriteHandle = FileOpen($szTempFile, 2)
	If $hWriteHandle = -1 Then
		SetError(2)
		Return -1
	EndIf
	;===============================================================================
	;== Loop through the array and search for $szSearchString
	;===============================================================================
	For $nCount = 1 To $aFileLines[0]
		If StringInStr($aFileLines[$nCount], $szSearchString, $fCaseness) Then
			$aFileLines[$nCount] = StringReplace($aFileLines[$nCount], $szSearchString, $szReplaceString, 1 - $fOccurance, $fCaseness)
			$iRetVal = $iRetVal + 1

			;======================================================================
			;== If we want just the first string replaced, copy the rest of the lines
			;== and stop
			;======================================================================
			If $fOccurance = 0 Then
				$iRetVal = 1
				ExitLoop
			EndIf
		EndIf
	Next
	;===============================================================================
	;== Write the lines to a temp file.
	;===============================================================================
	For $nCount = 1 To $aFileLines[0] - 1
		If FileWriteLine($hWriteHandle, $aFileLines[$nCount]) = 0 Then
			SetError(3)
			FileClose($hWriteHandle)
			Return -1
		EndIf
	Next
	; Write the last record and ensure it ends wit hthe same as the input file
	If $aFileLines[$nCount] <> "" Then FileWrite($hWriteHandle, $aFileLines[$nCount] & $sEndsWith)
	FileClose($hWriteHandle)

	;======================================================================
	;== Delete the original file
	;======================================================================
	If FileDelete($szFileName) = 0 Then
		SetError(4)
		Return -1
	EndIf

	;======================================================================
	;== Rename the temp file to the original file
	;======================================================================
	If FileMove($szTempFile, $szFileName) = 0 Then
		SetError(5)
		Return -1
	EndIf

	Return $iRetVal
EndFunc   ;==>_ReplaceStringInFile

;========================================================================================================
;
; Function Name:    _TempFile([s_DirectoryName],[s_FilePrefix], [s_FileExtension], [i_RandomLength)
; Description:      Generate a name for a temporary file. The file is guaranteed not to already exist.
; Parameter(s):
;     $s_DirectoryName    optional  Name of directory for filename, defaults to @TempDir
;     $s_FilePrefix       optional  File prefixname, defaults to "~"
;     $s_FileExtension    optional  File extenstion, defaults to ".tmp"
;     $i_RandomLength     optional  Number of characters to use to generate a unique name, defaults to 7
; Requirement(s):   None.
; Return Value(s):  Filename of a temporary file which does not exist.
; Author(s):        Dale (Klaatu) Thompson
;                   Hans Harder - Added Optional parameters
; Notes:            None.
;
;========================================================================================================
Func _TempFile($s_DirectoryName = @TempDir, $s_FilePrefix = "~", $s_FileExtension = ".tmp", $i_RandomLength = 7)
	Local $s_TempName
	; Check parameters
	If Not FileExists($s_DirectoryName) Then $s_DirectoryName = @TempDir   ; First reset to default temp dir
	If Not FileExists($s_DirectoryName) Then $s_DirectoryName = @ScriptDir ; Still wrong then set to Scriptdir
	; add trailing \ for directory name
	If StringRight($s_DirectoryName, 1) <> "\" Then $s_DirectoryName = $s_DirectoryName & "\"
	;
	Do
		$s_TempName = ""
		While StringLen($s_TempName) < $i_RandomLength
			$s_TempName = $s_TempName & Chr(Random(97, 122, 1))
		WEnd
		$s_TempName = $s_DirectoryName & $s_FilePrefix & $s_TempName & $s_FileExtension
	Until Not FileExists($s_TempName)

	Return ($s_TempName)
EndFunc   ;==>_TempFile


; ----------------------------------------------------------------------------
; <AUT2EXE INCLUDE-END: G:\Program Files\AutoIt3\beta\Include\file.au3>
; ----------------------------------------------------------------------------


; ----------------------------------------------------------------------------
; <AUT2EXE INCLUDE-START: G:\Program Files\AutoIt3\beta\Include\array.au3>
; ----------------------------------------------------------------------------

; Include Version:1.63 (19 June 2006)

; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with array management.
;
; Apr 28, 2005 - Fixed _ArrayTrim(): $iTrimDirection test.
; ------------------------------------------------------------------------------




;===============================================================================
;
; Function Name:  _ArrayAdd()
; Description:    Adds a specified value at the end of an array, returning the
;                 adjusted array.
; Author(s):      Jos van der Zande <jdeb at autoitscript dot com>
;
;===============================================================================
Func _ArrayAdd(ByRef $avArray, $sValue)
	If IsArray($avArray) Then
		ReDim $avArray[UBound($avArray) + 1]
		$avArray[UBound($avArray) - 1] = $sValue
		SetError(0)
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_ArrayAdd


;===============================================================================
;
; Function Name:  _ArrayBinarySearch()
; Description:    Uses the binary search algorithm to search through a
;                 1-dimensional array.
; Author(s):      Jos van der Zande <jdeb at autoitscript dot com>
;
;===============================================================================
Func _ArrayBinarySearch(ByRef $avArray, $sKey, $i_Base = 0)
	Local $iLwrLimit = $i_Base
	Local $iUprLimit
	Local $iMidElement

	If (Not IsArray($avArray)) Then
		SetError(1)
		Return ""
	EndIf
	$iUprLimit = UBound($avArray) - 1
	$iMidElement = Int( ($iUprLimit + $iLwrLimit) / 2)
	; sKey is smaller than the first entry
	If $avArray[$iLwrLimit] > $sKey Or $avArray[$iUprLimit] < $sKey Then
		SetError(2)
		Return ""
	EndIf

	While $iLwrLimit <= $iMidElement And $sKey <> $avArray[$iMidElement]
		If $sKey < $avArray[$iMidElement] Then
			$iUprLimit = $iMidElement - 1
		Else
			$iLwrLimit = $iMidElement + 1
		EndIf
		$iMidElement = Int( ($iUprLimit + $iLwrLimit) / 2)
	WEnd
	If $iLwrLimit > $iUprLimit Then
		; Entry not found
		SetError(3)
		Return ""
	Else
		;Entry found , return the index
		SetError(0)
		Return $iMidElement
	EndIf
EndFunc   ;==>_ArrayBinarySearch

;===============================================================================
;
; Function Name:    _ArrayCreate()
; Description:      Create a small array and quickly assign values.
; Parameter(s):     $v_0  - The first element of the array.
;                   $v_1  - The second element of the array (optional).
;                   ...
;                   $v_20 - The twentyfirst element of the array (optional).
; Requirement(s):   None.
; Return Value(s):  The array with values.
; Author(s):        Dale (Klaatu) Thompson
; Note(s):          None.
;
;===============================================================================
Func _ArrayCreate($v_0, $v_1 = 0, $v_2 = 0, $v_3 = 0, $v_4 = 0, $v_5 = 0, $v_6 = 0, $v_7 = 0, $v_8 = 0, $v_9 = 0, $v_10 = 0, $v_11 = 0, $v_12 = 0, $v_13 = 0, $v_14 = 0, $v_15 = 0, $v_16 = 0, $v_17 = 0, $v_18 = 0, $v_19 = 0, $v_20 = 0)

	Local $i_UBound = @NumParams
	Local $av_Array[$i_UBound]
	Local $i_Index

	For $i_Index = 0 To ($i_UBound - 1)
		$av_Array[$i_Index] = Eval("v_" & String($i_Index))
	Next
	Return $av_Array
	; Create fake usage for the variables to suppress Au3Check -w 6
	$v_0 = $v_0 = $v_1 = $v_2 = $v_3 = $v_4 = $v_5 = $v_6 = $v_7 = $v_8 = $v_9 = $v_10
    $v_11 = $v_11 = $v_12 = $v_13 = $v_14 = $v_15 = $v_16 = $v_17 = $v_18 = $v_19 = $v_20
EndFunc   ;==>_ArrayCreate


;===============================================================================
;
; Function Name:  _ArrayDelete()
; Description:    Deletes the specified element from the given array, returning
;                 the adjusted array.
; Author(s)       Cephas <cephas at clergy dot net>
; Modifications   Array is passed via Byref  - Jos van der zande
;===============================================================================
Func _ArrayDelete(ByRef $avArray, $iElement)
	Local $iCntr = 0, $iUpper = 0

	If (Not IsArray($avArray)) Then
		SetError(1)
		Return ""
	EndIf

	; We have to define this here so that we're sure that $avArray is an array
	; before we get it's size.
	$iUpper = UBound($avArray)    ; Size of original array

	; If the array is only 1 element in size then we can't delete the 1 element.
	If $iUpper = 1 Then
		SetError(2)
		Return ""
	EndIf

	Local $avNewArray[$iUpper - 1]
	If $iElement < 0 Then
		$iElement = 0
	EndIf
	If $iElement > ($iUpper - 1) Then
		$iElement = ($iUpper - 1)
	EndIf
	If $iElement > 0 Then
		For $iCntr = 0 To $iElement - 1
			$avNewArray[$iCntr] = $avArray[$iCntr]
		Next
	EndIf
	If $iElement < ($iUpper - 1) Then
		For $iCntr = ($iElement + 1) To ($iUpper - 1)
			$avNewArray[$iCntr - 1] = $avArray[$iCntr]
		Next
	EndIf
	$avArray = $avNewArray
	SetError(0)
	Return 1
EndFunc   ;==>_ArrayDelete


;===============================================================================
;
; Function Name:  _ArrayDisplay()
; Description:    Displays a 1-dimensional array in a message box.
; Author(s):      Brian Keene <brian_keene at yahoo dot com>
;
;===============================================================================
Func _ArrayDisplay(Const ByRef $avArray, $sTitle)
	Local $iCounter = 0, $sMsg = ""

	If (Not IsArray($avArray)) Then
		SetError(1)
		Return 0
	EndIf

	For $iCounter = 0 To UBound($avArray) - 1
		$sMsg = $sMsg & "[" & $iCounter & "]    = " & StringStripCR($avArray[$iCounter]) & @CR
	Next

	MsgBox(4096, $sTitle, $sMsg)
	SetError(0)
	Return 1
EndFunc   ;==>_ArrayDisplay


;===============================================================================
;
; Function Name:  _ArrayInsert()
; Description:    Add a new value at the specified position.
;
; Author(s):      Jos van der Zande <jdeb at autoitscript dot com>
;
;===============================================================================
Func _ArrayInsert(ByRef $avArray, $iElement, $sValue = "")
	Local $iCntr = 0

	If Not IsArray($avArray) Then
		SetError(1)
		Return 0
	EndIf
	; Add 1 to the Array
	ReDim $avArray[UBound($avArray) + 1]
	; Move all entries one up till the specified Element
	For $iCntr = UBound($avArray) - 1 To $iElement + 1 Step - 1
		$avArray[$iCntr] = $avArray[$iCntr - 1]
	Next
	; add the value in the specified element
	$avArray[$iCntr] = $sValue
	Return 1
EndFunc   ;==>_ArrayInsert


;===============================================================================
;
; Function Name:  _ArrayMax()
; Description:    Returns the highest value held in an array.
; Author(s):      Cephas <cephas at clergy dot net>
;
;                 Jos van der Zande
; Modified:       Added $iCompNumeric and $i_Base parameters and logic
;===============================================================================
Func _ArrayMax(Const Byref $avArray, $iCompNumeric = 0, $i_Base = 0)
	If IsArray($avArray) Then
		Return $avArray[_ArrayMaxIndex($avArray, $iCompNumeric, $i_Base) ]
	Else
		SetError(1)
		Return ""
	EndIf
EndFunc   ;==>_ArrayMax


;===============================================================================
;
; Function Name:  _ArrayMaxIndex()
; Description:    Returns the index where the highest value occurs in the array.
; Author(s):      Cephas <cephas at clergy dot net>
;
;                 Jos van der Zande
; Modified:       Added $iCompNumeric and $i_Base parameters and logic
;===============================================================================
Func _ArrayMaxIndex(Const ByRef $avArray, $iCompNumeric = 0, $i_Base = 0)
	Local $iCntr, $iMaxIndex = $i_Base

	If Not IsArray($avArray) Then
		SetError(1)
		Return ""
	EndIf

	Local $iUpper = UBound($avArray)
	For $iCntr = $i_Base To ($iUpper - 1)
		If $iCompNumeric = 1 Then
			If Number($avArray[$iMaxIndex]) < Number($avArray[$iCntr]) Then
				$iMaxIndex = $iCntr
			EndIf
		Else
			If $avArray[$iMaxIndex] < $avArray[$iCntr] Then
				$iMaxIndex = $iCntr
			EndIf
		EndIf
	Next
	SetError(0)
	Return $iMaxIndex
EndFunc   ;==>_ArrayMaxIndex


;===============================================================================
;
; Function Name:  _ArrayMin()
; Description:    Returns the lowest value held in an array.
; Author(s):      Cephas <cephas ay clergy dot net>
;
;                 Jos van der Zande
; Modified:       Added $iCompNumeric and $i_Base parameters and logic
;===============================================================================
Func _ArrayMin(Const ByRef $avArray, $iCompNumeric = 0, $i_Base = 0)
	If IsArray($avArray) Then
		Return $avArray[_ArrayMinIndex($avArray, $iCompNumeric, $i_Base) ]
	Else
		SetError(1)
		Return ""
	EndIf
EndFunc   ;==>_ArrayMin


;===============================================================================
;
; Function Name:  _ArrayMinIndex()
; Description:    Returns the index where the lowest value occurs in the array.
; Author(s):      Cephas <cephas at clergy dot net>
;
;                 Jos van der Zande
; Modified:       Added $iCompNumeric and $i_Base parameters and logic
;===============================================================================
Func _ArrayMinIndex(Const ByRef $avArray, $iCompNumeric = 0, $i_Base = 0)
	Local $iCntr = 0, $iMinIndex = $i_Base

	If Not IsArray($avArray) Then
		SetError(1)
		Return ""
	EndIf

	Local $iUpper = UBound($avArray)
	For $iCntr = $i_Base To ($iUpper - 1)
		If $iCompNumeric = 1 Then
			If Number($avArray[$iMinIndex]) > Number($avArray[$iCntr]) Then
				$iMinIndex = $iCntr
			EndIf
		Else
			If $avArray[$iMinIndex] > $avArray[$iCntr] Then
				$iMinIndex = $iCntr
			EndIf
		EndIf
	Next
	SetError(0)
	Return $iMinIndex
EndFunc   ;==>_ArrayMinIndex


;===============================================================================
;
; Function Name:  _ArrayPop()
; Description:    Returns the last element of an array, deleting that element
;                 from the array at the same time.
; Author(s):      Cephas <cephas at clergy dot net>
; Modified:       Use Redim to remove last entry.
;===============================================================================
Func _ArrayPop(ByRef $avArray)
	Local $sLastVal
	If (Not IsArray($avArray)) Then
		SetError(1)
		Return ""
	EndIf
	$sLastVal = $avArray[UBound($avArray) - 1]
	; remove the last value
	If UBound($avArray) = 1 Then
		$avArray = ""
	Else
		ReDim $avArray[UBound($avArray) - 1]
	EndIf
	; return last value
	Return $sLastVal
EndFunc   ;==>_ArrayPop

;=====================================================================================
;
; Function Name:    _ArrayPush
; Description:      Add new values without increasing array size.Either by inserting
;                   at the end the new value and deleting the first one or vice versa.
; Parameter(s):     $avArray      - Array
;                   $sValue       - The new value.It can be an array too.
;                   $i_Direction  - 0 = Leftwise slide (adding at the end) (default)
;                                   1 = Rightwise slide (adding at the start)
; Requirement(s):   None
; Return Value(s):  On Success -  Returns 1
;                   On Failure -  0 if $avArray is not an array.
;								 -1 if $sValue array size is greater than $avArray size.
;								 In both cases @error is set to 1.
; Author(s):        Helias Gerassimou(hgeras)
;
;======================================================================================
Func _ArrayPush(ByRef $avArray, $sValue, $i_Direction = 0)
	Local $i, $j

	If (Not IsArray($avArray)) Then
		SetError(1)
		Return 0
	EndIf
;
	If (Not IsArray($sValue)) Then
		If $i_Direction = 1 Then
			For $i = (UBound($avArray) - 1) To 1 Step -1
				$avArray[$i] = $avArray[$i - 1]
			Next
			$avArray[0] = $sValue
		Else
			For $i = 0 To (UBound($avArray) - 2)
				$avArray[$i] = $avArray[$i + 1]
			Next
			$i = (UBound($avArray) - 1)
			$avArray[$i] = $sValue
		EndIf
		;
		SetError(0)
		Return 1
	Else
		If UBound($sValue) > UBound($avArray) Then
			SetError(1)
			Return -1
		Else
			For $j = 0 to (UBound($sValue) - 1)
				If $i_Direction = 1 Then
					For $i = (UBound($avArray) - 1) To 1
						$avArray[$i] = $avArray[$i - 1]
					Next
					$avArray[$j] = $sValue[$j]
				Else
					For $i = 0 To (UBound($avArray) - 2)
						$avArray[$i] = $avArray[$i + 1]
					Next
					$i = (UBound($avArray) - 1)
					$avArray[$i] = $sValue[$j]
				EndIf
			Next
		EndIf
	EndIf
	;
	SetError(0)
	Return 1
;
EndFunc   ;==>_ArrayPush

;===============================================================================
;
; Function Name:  _ArrayReverse()
; Description:    Takes the given array and reverses the order in which the
;                 elements appear in the array.
; Author(s):      Brian Keene <brian_keene at yahoo dot com>
;
; Modified:       Added $i_Base parameter and logic (Jos van der Zande)
;                 Added $i_UBound parameter and rewrote it for speed. (Tylo)
;===============================================================================

Func _ArrayReverse(ByRef $avArray, $i_Base = 0, $i_UBound = 0)
    If Not IsArray($avArray) Then
        SetError(1)
        Return 0
    EndIf
    Local $tmp, $last = UBound($avArray) - 1
    If $i_UBound < 1 Or $i_UBound > $last Then $i_UBound = $last
    For $i = $i_Base To $i_Base + Int(($i_UBound - $i_Base - 1) / 2)
        $tmp = $avArray[$i]
        $avArray[$i] = $avArray[$i_UBound]
        $avArray[$i_UBound] = $tmp
        $i_UBound = $i_UBound - 1
    Next
    Return 1
EndFunc  ;==>_ArrayReverse

;===============================================================================
;
; Description:      Finds an entry within a one-dimensional array. (Similar to _ArrayBinarySearch() except the array does not need to be sorted.)
; Syntax:           _ArraySearch($avArray, $vWhat2Find, $iStart = 0, $iEnd = 0,$iCaseSense=0)
;
; Parameter(s):      $avArray           = The array to search
;                    $vWhat2Find        = What to search $avArray for
;                    $iStart (Optional) = Start array index for search, normally set to 0 or 1. If omitted it is set to 0
;                    $iEnd  (Optional)  = End array index for search. If omitted or set to 0 it is set to Ubound($AvArray)-
;					 $iCaseSense (Optional) = If set to 1 then search is case sensitive
; Requirement(s):   None
;
; Return Value(s):  On Success - Returns the position of an item in an array.
;                   On Failure - Returns an -1 if $vWhat2Find is not found
;                        @Error=1 $avArray is not an array
;                        @Error=2 $iStart is greater than UBound($AvArray)-1
;                        @Error=3 $iEnd is greater than UBound($AvArray)-1
;                        @Error=4 $iStart is greater than $iEnd
;						 @Error=5 $iCaseSense was invalid. (Must be 0 or 1)
;						 @Error=6 $vWhat2Find was not found in $avArray
;
; Author(s):        SolidSnake <MetalGearX91 at Hotmail dot com>
; Note(s):          This might be slower than _ArrayBinarySearch() but is useful when the array's order can't be altered.
;===============================================================================
Func _ArraySearch(Const ByRef $avArray, $vWhat2Find, $iStart = 0, $iEnd = 0, $iCaseSense = 0)
	Local $iCurrentPos, $iUBound
	If Not IsArray($avArray) Then
		SetError(1)
		Return -1
	EndIf
	$iUBound = UBound($avArray) - 1
	If $iEnd = 0 Then $iEnd = $iUBound
	If $iStart > $iUBound Then
		SetError(2)
		Return -1
	EndIf
	If $iEnd > $iUBound Then
		SetError(3)
		Return -1
	EndIf
	If $iStart > $iEnd Then
		SetError(4)
		Return -1
	EndIf
	If Not ($iCaseSense = 0 Or $iCaseSense = 1) Then
		SetError(5)
		Return -1
	EndIf
	For $iCurrentPos = $iStart To $iEnd
		Select
			Case $iCaseSense = 0
				If $avArray[$iCurrentPos] = $vWhat2Find Then
					SetError(0)
					Return $iCurrentPos
				EndIf
			Case $iCaseSense = 1
				If $avArray[$iCurrentPos] == $vWhat2Find Then
					SetError(0)
					Return $iCurrentPos
				EndIf
		EndSelect
	Next
	SetError(6)
	Return -1
EndFunc   ;==>_ArraySearch

;===============================================================================
;
; Function Name:    _ArraySort()
; Description:      Sort an 1 or 2 dimensional Array on a specific index
;                   using the quicksort/insertsort algorithms.
; Parameter(s):     $a_Array      - Array
;                   $i_Descending - Sort Descending when 1
;                   $i_Base       - Start sorting at this Array entry.
;                   $I_Ubound     - End sorting at this Array entry.
;                                   Default UBound($a_Array) - 1
;                   $i_Dim        - Elements to sort in second dimension
;                   $i_SortIndex  - The Index to Sort the Array on.
;                                   (for 2-dimensional arrays only)
; Requirement(s):   None
; Return Value(s):  On Success - 1 and the sorted array is set
;                   On Failure - 0 and sets @ERROR = 1
; Author(s):        Jos van der Zande <jdeb at autoitscript dot com>
;                   LazyCoder - added $i_SortIndex option
;                   Tylo - implemented stable QuickSort algo
;                   Jos - Changed logic to correctly Sort arrays with mixed Values and Strings
;
;===============================================================================
;
Func _ArraySort(ByRef $a_Array, $i_Decending = 0, $i_Base = 0, $i_UBound = 0, $i_Dim = 1, $i_SortIndex = 0)
  ; Set to ubound when not specified
    If Not IsArray($a_Array) Then
       SetError(1)
       Return 0
    EndIf
    Local $last = UBound($a_Array) - 1
    If $i_UBound < 1 Or $i_UBound > $last Then $i_UBound = $last

    If $i_Dim = 1 Then
        __ArrayQSort1($a_Array, $i_Base, $i_UBound)
        If $i_Decending Then _ArrayReverse($a_Array, $i_Base, $i_UBound)
    Else
        __ArrayQSort2($a_Array, $i_Base, $i_UBound, $i_Dim, $i_SortIndex, $i_Decending)
    EndIf
    Return 1
EndFunc;==>_ArraySort

; Private
Func __ArrayQSort1(ByRef $array, ByRef $left, ByRef $right)
    Local $i, $j, $t
    If $right - $left < 10 Then
      ; InsertSort - fastest on small segments (= 25% total speedup)
        For $i = $left + 1 To $right
            $t = $array[$i]
            $j = $i
			While $j > $left _
				And (    (IsNumber($array[$j - 1]) = IsNumber($t) And $array[$j - 1] > $t) _
				      Or (IsNumber($array[$j - 1]) <> IsNumber($t) And String($array[$j - 1]) > String($t)))
                $array[$j] = $array[$j - 1]
                $j = $j - 1
            Wend
            $array[$j] = $t
        Next
        Return
    EndIf

  ; QuickSort - fastest on large segments
    Local $pivot = $array[Int(($left + $right)/2)]
    Local $L = $left
    Local $R = $right
    Do
		While ((IsNumber($array[$L]) = IsNumber($pivot) And $array[$L] < $pivot) _
				Or (IsNumber($array[$L]) <> IsNumber($pivot) And String($array[$L]) < String($pivot)))
			;While $array[$L] < $pivot
            $L = $L + 1
        Wend
		While ((IsNumber($array[$R]) = IsNumber($pivot) And $array[$R] > $pivot) _
				Or (IsNumber($array[$R]) <> IsNumber($pivot) And String($array[$R]) > String($pivot)))
			;	While $array[$R] > $pivot
            $R = $R - 1
        Wend
      ; Swap
        If $L <= $R Then
            $t = $array[$L]
            $array[$L] = $array[$R]
            $array[$R] = $t
            $L = $L + 1
            $R = $R - 1
        EndIf
    Until $L > $R

    __ArrayQSort1($array, $left, $R)
    __ArrayQSort1($array, $L, $right)
EndFunc

; Private
Func __ArrayQSort2(ByRef $array, ByRef $left, ByRef $right, ByRef $dim2, ByRef $sortIdx, ByRef $decend)
    If $left >= $right Then Return
    Local $t, $d2 = $dim2 - 1
    Local $pivot = $array[Int(($left + $right)/2)][$sortIdx]
    Local $L = $left
    Local $R = $right
    Do
        If $decend Then
			While ((IsNumber($array[$L][$sortIdx]) = IsNumber($pivot) And $array[$L][$sortIdx] > $pivot) _
				Or (IsNumber($array[$L][$sortIdx]) <> IsNumber($pivot) And String($array[$L][$sortIdx]) > String($pivot)))
				;While $array[$L][$sortIdx] > $pivot
                $L = $L + 1
            Wend
			While ((IsNumber($array[$R][$sortIdx]) = IsNumber($pivot) And $array[$R][$sortIdx] < $pivot) _
				Or (IsNumber($array[$R][$sortIdx]) <> IsNumber($pivot) And String($array[$R][$sortIdx]) < String($pivot)))
				;While $array[$R][$sortIdx] < $pivot
                $R = $R - 1
            Wend
        Else
			While ((IsNumber($array[$L][$sortIdx]) = IsNumber($pivot) And $array[$L][$sortIdx] < $pivot) _
				Or (IsNumber($array[$L][$sortIdx]) <> IsNumber($pivot) And String($array[$L][$sortIdx]) < String($pivot)))
				;While $array[$L][$sortIdx] < $pivot
                $L = $L + 1
            Wend
			While ((IsNumber($array[$R][$sortIdx]) = IsNumber($pivot) And $array[$R][$sortIdx] > $pivot) _
				Or (IsNumber($array[$R][$sortIdx]) <> IsNumber($pivot) And String($array[$R][$sortIdx]) > String($pivot)))
				;While $array[$R][$sortIdx] > $pivot
                $R = $R - 1
            Wend
        EndIf
        If $L <= $R Then
            For $x = 0 To $d2
                $t = $array[$L][$x]
                $array[$L][$x] = $array[$R][$x]
                $array[$R][$x] = $t
            Next
            $L = $L + 1
            $R = $R - 1
        EndIf
    Until $L > $R

    __ArrayQSort2($array, $left, $R, $dim2, $sortIdx, $decend)
    __ArrayQSort2($array, $L, $right, $dim2, $sortIdx, $decend)
EndFunc



;===============================================================================
;
; Function Name:  _ArraySwap()
; Description:    Swaps two elements of an array.
; Author(s):      David Nuttall <danuttall at rocketmail dot com>
;
;===============================================================================
Func _ArraySwap(ByRef $svector1, ByRef $svector2)
	Local $sTemp = $svector1

	$svector1 = $svector2
	$svector2 = $sTemp

	SetError(0)
EndFunc   ;==>_ArraySwap


;===============================================================================
;
; Function Name:  _ArrayToClip()
; Description:    Sends the contents of an array to the clipboard.
; Author(s):      Cephas <cephas at clergy dot net>
;
;                 Jos van der Zande
; Modified:       Added $i_Base parameter and logic
;===============================================================================
Func _ArrayToClip(const ByRef $avArray, $i_Base = 0)
	Local $iCntr, $iRetVal = 0, $sCr = "", $sText = ""

	If (IsArray($avArray)) Then
		For $iCntr = $i_Base To (UBound($avArray) - 1)
			$iRetVal = 1
			If $iCntr > $i_Base Then
				$sCr = @CR
			EndIf
			$sText = $sText & $sCr & $avArray[$iCntr]
		Next
	EndIf
	ClipPut($sText)
	Return $iRetVal
EndFunc   ;==>_ArrayToClip


;===============================================================================
;
; Function Name:  _ArrayToString()
; Description:    Places the elements of an array into a single string,
;                 separated by the specified delimiter.
; Author(s):      Brian Keene <brian_keene at yahoo dot com>
;
;===============================================================================
Func _ArrayToString(Const ByRef $avArray, $sDelim, $iStart = 0, $iEnd = 0)
	; Declare local variables.
	Local $iCntr = 0, $iUBound = 0, $sResult = ""

	; If $avArray is an array then set var for efficiency sake.
	If (IsArray($avArray)) Then
		$iUBound = UBound($avArray) - 1
	EndIf
	If $iEnd = 0 Then $iEnd = $iUBound
	; Check for parameter validity.
	Select
		Case (Not IsArray($avArray))
			SetError(1)
			Return ""
		Case( ($iUBound + 1) < 2 Or UBound($avArray, 0) > 1)
			SetError(2)
			Return ""
		Case (Not IsInt($iStart))
			SetError(3)
			Return ""
		Case (Not IsInt($iEnd))
			SetError(5)
			Return ""
		Case (Not IsString($sDelim))
			SetError(7)
			Return ""
		Case ($sDelim = "")
			SetError(8)
			Return ""
		Case (StringLen($sDelim) > 1)
			SetError(9)
			Return ""
		Case ($iStart = -1 And $iEnd = -1)
			$iStart = 0
			$iEnd = $iUBound
		Case ($iStart < 0)
			SetError(4)
			Return ""
		Case ($iEnd < 0)
			SetError(6)
			Return ""
	EndSelect

	; Make sure that $iEnd <= to the size of the array.
	If ($iEnd > $iUBound) Then
		$iEnd = $iUBound
	EndIf

	; Combine the elements into the string.
	For $iCntr = $iStart To $iEnd
		$sResult = $sResult & $avArray[$iCntr]
		If ($iCntr < $iEnd) Then
			$sResult = $sResult & $sDelim
		EndIf
	Next

	SetError(0)
	Return $sResult
EndFunc   ;==>_ArrayToString

;===============================================================================
;
; FunctionName:     _ArrayTrim()
; Description:      Trims all elements in an array a certain number of characters.
; Syntax:           _ArrayTrim( $aArray, $iTrimNum , [$iTrimDirection] , [$iBase] , [$iUbound] )
; Parameter(s):     $aArray              - The array to trim the items of
;                   $iTrimNum            - The amount of characters to trim
;                    $iTrimDirection     - 0 to trim left, 1 to trim right
;                                            [Optional] : Default = 0
;                   $iBase               - Start trimming at this element in the array
;                                            [Optional] : Default = 0
;                   $iUbound             - End trimming at this element in the array
;                                            [Optional] : Default = Full Array
; Requirement(s):   None
; Return Value(s):  1 - If invalid array
;                   2 - Invalid base boundry parameter
;                   3 - Invalid end boundry parameter
;                   4 - If $iTrimDirection is not a zero or a one
;                    Otherwise it returns the new trimmed array
; Author(s):        Adam Moore (redndahead)
; Note(s):          None
;
;===============================================================================
Func _ArrayTrim($aArray, $iTrimNum, $iTrimDirection = 0, $iBase = 0, $iUBound = 0)
	Local $i

	;Validate array and options given
	If UBound($aArray) = 0 Then
		SetError(1)
		Return $aArray
	EndIf

	If $iBase < 0 Or Not IsNumber($iBase) Then
		SetError(2)
		Return $aArray
	EndIf

	If UBound($aArray) <= $iUBound Or Not IsNumber($iUBound) Then
		SetError(3)
		Return $aArray
	EndIf

	; Set to ubound when not specified
	If $iUBound < 1 Then $iUBound = UBound($aArray) - 1

	If $iTrimDirection < 0 Or $iTrimDirection > 1 Then
		SetError(4)
		Return
	EndIf
	;Trim it off
	For $i = $iBase To $iUBound
		If $iTrimDirection = 0 Then
			$aArray[$i] = StringTrimLeft($aArray[$i], $iTrimNum)
		Else
			$aArray[$i] = StringTrimRight($aArray[$i], $iTrimNum)
		EndIf
	Next
	Return $aArray
EndFunc   ;==>_ArrayTrim

; ----------------------------------------------------------------------------
; <AUT2EXE INCLUDE-END: G:\Program Files\AutoIt3\beta\Include\array.au3>
; ----------------------------------------------------------------------------


Opt("TrayIconHide", 1)

;soft title
Const $my_title = 'AutoAlias V1.0 by guitarbug@ccf'

;当前运行的路径
Const $my_path = @WorkingDir

;用于存储文件列表的临时文件
Const $tmp_file = @TempDir & '\AutoAlias.tmp'

;用于存储别名列表的文件
Const $result_file = $my_path & '\AutoAlias_Config.txt'
CreateFile($result_file)

;用于存储别名history的文件
Const $history_file = $my_path & '\AutoAlias_History.txt'
CreateFile($history_file)

;设定用的ini文件
Const $ini_file = $my_path & '\AutoAlias.ini'
CreateINIFile($ini_file)

;解析ini文件
$file_ext = IniRead("AutoAlias.ini", "FileExtension", "ext", "*.exe")

;解析search folder
$searchdir = IniReadSection("AutoAlias.ini", "SearchFolder")
If @error Then
    ;无ini文件或者没有SearchFolder字段,默认搜索@ProgramFilesDir
	$searchdir = @ProgramFilesDir
	DirList($searchdir,$file_ext,$tmp_file)
	ParseFile($tmp_file,$history_file,$result_file)
Else
    For $i = 1 To $searchdir[0][0]
		;Key:	$searchdir[$i][0]
		;Value:	$searchdir[$i][1]
		If DirList($searchdir[$i][1],$file_ext,$tmp_file) = 0 Then ContinueLoop
		ParseFile($tmp_file,$history_file,$result_file)
    Next
EndIf

FileDelete($tmp_file)
MsgBox(4096,$my_title,'done!click ok to see the AutoAlias_History.txt and AutoAlias_Config.txt');
Run("Notepad.exe " & $history_file)
Run("Notepad.exe " & $result_file )

Func DirList($work_dir,$option,$output_file)
	$b = FileChangeDir($work_dir)
	;路径不存在?
	If $b = 0 Then Return 0

	;构造dir命令字符串
	$dir_cmd = 'dir ' & $option & ' /S /B > ' & $output_file

	;执行dir命令
	RunWait (@ComSpec & " /c " & $dir_cmd, "", @SW_HIDE)
	Return 1
EndFunc

Func ParseFile($file_name,$history_file,$result_file)
	;解析tmp文件
	Dim $aRecords
	If Not _FileReadToArray($file_name,$aRecords) Then
		MsgBox(4096,"Error", " Error reading " & $file_name & " error:" & @error)
		Exit
	EndIf

	Dim $szDrive, $szDir, $szFName, $szExt
	For $x = 1 to $aRecords[0]
		_PathSplit($aRecords[$x], $szDrive, $szDir, $szFName, $szExt)
		If(StringLen ( $szFName )) Then
			FileWriteLine($history_file,$szFName)
			$newline = $szFName & '|' & $aRecords[$x]
			FileWriteLine($result_file,$newline)
		EndIf
	Next
EndFunc

;创建文件
Func CreateFile($full_file_name)
	If Not _FileCreate($full_file_name) Then
		MsgBox(4096,"Error", " Error Creating " & $full_file_name & "      error:" & @error)
		Exit
	EndIf
EndFunc

Func CreateINIFile($ini_file)
	If FileExists($ini_file) Then
		Return
	Else
		IniWrite($ini_file, "SearchFolder", "1", @StartMenuCommonDir)
		IniWrite($ini_file, "SearchFolder", "2", @StartMenuDir)
		IniWrite($ini_file, "SearchFolder", "3", @DesktopCommonDir)
		IniWrite($ini_file, "SearchFolder", "4", @DesktopDir)
		IniWrite($ini_file, "FileExtension", "ext", "*.exe *.lnk")
	EndIf
EndFunc

; ----------------------------------------------------------------------------
; <AUT2EXE INCLUDE-END: G:\Green Soft\Launch\AutoAlias\AutoAlias.au3>
; ----------------------------------------------------------------------------

