#NoTrayIcon
#include <Crypt.au3>
#include <cmdline.au3>
#include <Array.au3>
#include <File.au3>
#include <WinAPIShPath.au3>

If Not StringInStr($CmdLineRaw, "in") Or $CmdLineRaw == "" Then
	ConsoleWrite("Hash Digest Tool - ALBANESE Lab " & Chr(184) & " 2018-2020" & @CRLF & @CRLF) ;
	ConsoleWrite("Usage: " & @CRLF) ;
	ConsoleWrite("   " & @ScriptName & " [-c|r] --in <file.ext> [--alg <algorithm>] [--out <file>]" & @CRLF & @CRLF) ;
	ConsoleWrite("Options: " & @CRLF) ;
	ConsoleWrite("   -c: Check a hash file" & @CRLF) ;
	ConsoleWrite("   -r: Recursive (Process directories recursively)" & @CRLF & @CRLF) ;
	ConsoleWrite("Parameters: " & @CRLF) ;
	ConsoleWrite("   /alg: Algorithm" & @CRLF) ;
	ConsoleWrite("   /in : Input file" & @CRLF) ;
	ConsoleWrite("   /out: Output hash file" & @CRLF & @CRLF) ;
	ConsoleWrite("Algorithms: ") ;
	ConsoleWrite("MD2, MD4, MD5, SHA1, SHA-256, SHA-384, SHA-512" & @CRLF & @CRLF) ;
	ConsoleWrite("Examples: " & @ScriptName & " --in *.txt (Default MD5)" & @CRLF) ;
	ConsoleWrite("          " & @ScriptName & " --in *.txt --alg sha-256" & @CRLF) ;
	ConsoleWrite("          " & @ScriptName & " -r --in *.* --out Hash.md5" & @CRLF) ;
	ConsoleWrite("          " & @ScriptName & " -c --in Hash.md5" & @CRLF) ;
	Exit
Else
	If _CmdLine_KeyExists('alg') Then
		Local $algo = _CmdLine_Get('alg')
		If $algo = "MD2" Then
			$alg = $CALG_MD2
		ElseIf $algo = "MD4" Then
			$alg = $CALG_MD4
		ElseIf $algo = "MD5" Then
			$alg = $CALG_MD5
		ElseIf $algo = "SHA1" Then
			$alg = $CALG_SHA1
		ElseIf $algo = "SHA-256" Then
			$alg = $CALG_SHA_256
		ElseIf $algo = "SHA-384" Then
			$alg = $CALG_SHA_384
		ElseIf $algo = "SHA-512" Then
			$alg = $CALG_SHA_512
		Else
			ConsoleWrite("Error: Unknown Algorithm." & @CRLF) ;
			Exit
		EndIf
		Local $file = _CmdLine_Get('in')
	Else
		$alg = $CALG_MD5
		Local $file = _CmdLine_Get('in')
	EndIf
EndIf

_Crypt_Startup()

If _CmdLine_KeyExists('c') Then
	If FileExists(_CmdLine_Get('in')) Then
		Local $aArray = FileReadToArray($file)
		$i = "0"
		For $sLine In $aArray
			Local $aArray = StringSplit($sLine, ' *', $STR_ENTIRESPLIT)
			If StringReplace(_Crypt_HashFile($aArray[2], $alg), "0x", "") = $aArray[1] Then
				ConsoleWrite($aArray[2] & ": OK" & @CRLF)
			Else
				$i += "1﻿"
				ConsoleWrite($aArray[2] & ": FAILED!" & @CRLF)
			EndIf
		Next
		ConsoleWrite(@CRLF & "Errors: " & $i & @CRLF)
		Exit
	Else
		ConsoleWrite("File doesn't exist." & @CRLF)
		Exit
	EndIf
EndIf

$aPathArr = _pathsplitbyregexp(_PathFull($file))
If _CmdLine_KeyExists('r') Then
	$aFileList = _filelisttoarrayex($aPathArr[2], $aPathArr[6])
Else
	$aFileList = _filelisttoarrayex($aPathArr[2], $aPathArr[6], 1, '', False)
EndIf

If _CmdLine_KeyExists('out') Then
	FileDelete(_CmdLine_Get('out'))
	If IsArray($aFileList) Then
		For $fileInf In $aFileList
			If isFolder($fileInf) Then
				If FileExists($file) Then
					If StringInStr(@WorkingDir, _PathFull($fileInf)) Or StringInStr(_PathFull($fileInf), @WorkingDir) Then
						FileWrite(_CmdLine_Get('out'), StringLower(StringReplace(_Crypt_HashFile($fileInf, $alg), "0x", "")) & " *" & _PathGetRelative(@WorkingDir, _PathFull($fileInf)) & @CRLF) ;
					Else
						FileWrite(_CmdLine_Get('out'), StringLower(StringReplace(_Crypt_HashFile($fileInf, $alg), "0x", "")) & " *" & _PathFull($fileInf) & @CRLF) ;
					EndIf
				Else
					ConsoleWrite("Error: """ & $fileInf & """ not found." & @CRLF) ;
				EndIf
			EndIf
		Next
	Else
		ConsoleWrite("File(s) not found!" & @CRLF)
	EndIf
Else
	If IsArray($aFileList) Then
		For $fileInf In $aFileList
			If isFolder($fileInf) Then
				If FileExists($file) Then
					If StringInStr(@WorkingDir, _PathFull($fileInf)) Or StringInStr(_PathFull($fileInf), @WorkingDir) Then
						ConsoleWrite(StringLower(StringReplace(_Crypt_HashFile($fileInf, $alg), "0x", "")) & " *" & _PathGetRelative(@WorkingDir, _PathFull($fileInf)) & @CRLF) ;
					Else
						ConsoleWrite(StringLower(StringReplace(_Crypt_HashFile($fileInf, $alg), "0x", "")) & " *" & _PathFull($fileInf) & @CRLF) ;
					EndIf
				Else
					ConsoleWrite("Error: """ & $fileInf & """ not found." & @CRLF) ;
				EndIf
			EndIf
		Next
	Else
		ConsoleWrite("File(s) not found!" & @CRLF)
	EndIf
EndIf

; FUNCTIONS

Func isFolder($path)
	If StringInStr(FileGetAttrib($path), "A") Then Return 1
	Return 0
EndFunc   ;==>isFolder

Func getdir($sfilepath)
	Local $afolders = StringSplit($sfilepath, "\")
	Local $iarrayfolderssize = UBound($afolders)
	Local $filedir = ""
	If (Not IsString($sfilepath)) Then
		Return SetError(1, 0, -1)
	EndIf
	$afolders = StringSplit($sfilepath, "\")
	$iarrayfolderssize = UBound($afolders)
	For $i = 1 To ($iarrayfolderssize - 2)
		$filedir &= $afolders[$i] & "\"
	Next
	Return $filedir
EndFunc   ;==>getdir

Func getfilename($sfilepath)
	Local $afolders = ""
	Local $filename = ""
	Local $iarrayfolderssize = 0
	If (Not IsString($sfilepath)) Then
		Return SetError(1, 0, -1)
	EndIf
	$afolders = StringSplit($sfilepath, "\")
	$iarrayfolderssize = UBound($afolders)
	$filename = $afolders[($iarrayfolderssize - 1)]
	Return $filename
EndFunc   ;==>getfilename

Func _pathsplitbyregexp($spath)
	If $spath = "" Or (StringInStr($spath, "\") And StringInStr($spath, "/")) Then
		Return SetError(1, 0, -1)
	EndIf
	Local $aretarray[9], $pdelim = ""
	If StringRegExp($spath, "^(?i)([A-Z]:|\\)(\\[^\\]+)+$") Then
		$pdelim = "\"
	EndIf
	If StringRegExp($spath, "(?i)(^.*:/)(/[^/]+)+$") Then
		$pdelim = "//"
	EndIf
	If $pdelim = "" Then
		$pdelim = "/"
	EndIf
	If Not StringInStr($spath, $pdelim) Then
		Return $spath
	EndIf
	If $pdelim = "\" Then
		$pdelim &= "\"
	EndIf
	$aretarray[0] = $spath
	$aretarray[1] = StringRegExpReplace($spath, $pdelim & ".*", $pdelim)
	$aretarray[2] = StringRegExpReplace($spath, $pdelim & "[^" & $pdelim & "]*$", "")
	$aretarray[3] = StringRegExpReplace($spath, "\.[^.]*$", "")
	$aretarray[4] = StringRegExpReplace($spath, "(?i)([A-Z]:" & $pdelim & ")", "")
	$aretarray[5] = StringRegExpReplace($aretarray[4], $pdelim & "[^" & $pdelim & "]*$", "")
	$aretarray[6] = StringRegExpReplace($spath, "^.*" & $pdelim, "")
	$aretarray[7] = StringRegExpReplace($spath, ".*" & $pdelim & "|\.[^.]*$", "")
	$aretarray[8] = StringRegExpReplace($aretarray[6], "^.*\.|^.*$", "")
	Return $aretarray
EndFunc   ;==>_pathsplitbyregexp

Func _filelisttoarrayex($s_path, $s_mask = "*.*", $i_flag = 0, $s_exclude = -1, $f_recurse = True, $f_full_path = True)
	If FileExists($s_path) = 0 Then Return SetError(1, 1, 0)
	$s_path = StringRegExpReplace($s_path, "[\\/]+\z", "") & "\"
	If $s_mask = -1 Or $s_mask = Default Then $s_mask = "*.*"
	If $i_flag = -1 Or $i_flag = Default Then $i_flag = 0
	If $s_exclude = -1 Or $s_exclude = Default Then $s_exclude = ""
	If StringRegExp($s_mask, "[/:><\|]") Or StringRegExp($s_exclude, "[/:><\|]") Then
		Return SetError(2, 2, 0)
	EndIf
	$s_mask = StringRegExpReplace($s_mask, "\s*;\s*", ";")
	If $s_exclude Then $s_exclude = StringRegExpReplace($s_exclude, "\s*;\s*", ";")
	If StringStripWS($s_mask, 8) = "" Then Return SetError(2, 2, 0)
	If $i_flag < 0 Or $i_flag > 2 Then Return SetError(3, 3, 0)
	Local $a_split = StringSplit($s_mask, ";"), $s_hold_split = ""
	For $i = 1 To $a_split[0]
		If StringStripWS($a_split[$i], 8) = "" Then ContinueLoop
		If StringRegExp($a_split[$i], "^\..*?\..*?\z") Then
			$a_split[$i] &= "*" & $a_split[$i]
		EndIf
		$s_hold_split &= '"' & $s_path & $a_split[$i] & '" '
	Next
	$s_hold_split = StringTrimRight($s_hold_split, 1)
	If $s_hold_split = "" Then $s_hold_split = '"' & $s_path & '*.*"'
	Local $i_pid, $s_stdout, $s_hold_out, $s_dir_file_only = "", $s_recurse = "/s "
	If $i_flag = 1 Then $s_dir_file_only = ":-d"
	If $i_flag = 2 Then $s_dir_file_only = ":D"
	If Not $f_recurse Then $s_recurse = ""
	$i_pid = Run(@ComSpec & " /c dir /b " & $s_recurse & "/a" & $s_dir_file_only & " " & $s_hold_split, "", @SW_HIDE, 4 + 2)
	While 1
		$s_stdout = StdoutRead($i_pid)
		If @error Then ExitLoop
		$s_hold_out &= $s_stdout
	WEnd
	$s_hold_out = StringRegExpReplace($s_hold_out, "\v+\z", "")
	If Not $s_hold_out Then Return SetError(4, 4, 0)
	Local $a_fsplit = StringSplit(StringStripCR($s_hold_out), @LF), $s_hold_ret
	$s_hold_out = ""
	If $s_exclude Then $s_exclude = StringReplace(StringReplace($s_exclude, "*", ".*?"), ";", "|")
	For $i = 1 To $a_fsplit[0]
		If $s_exclude And StringRegExp(StringRegExpReplace($a_fsplit[$i], "(.*?[\\/]+)*(.*?\z)", "\2"), "(?i)\Q" & $s_exclude & "\E") Then ContinueLoop
		If StringRegExp($a_fsplit[$i], "^\w:[\\/]+") = 0 Then $a_fsplit[$i] = $s_path & $a_fsplit[$i]
		If $f_full_path Then
			$s_hold_ret &= $a_fsplit[$i] & Chr(1)
		Else
			$s_hold_ret &= StringRegExpReplace($a_fsplit[$i], "((?:.*?[\\/]+)*)(.*?\z)", "$2") & Chr(1)
		EndIf
	Next
	$s_hold_ret = StringTrimRight($s_hold_ret, 1)
	If $s_hold_ret = "" Then Return SetError(5, 5, 0)
	Return StringSplit($s_hold_ret, Chr(1))
EndFunc   ;==>_filelisttoarrayex
