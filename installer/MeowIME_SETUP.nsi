Unicode True
!include nsDialogs.nsh
!include MUI2.nsh
!include "Registry.nsh"
!include x64.nsh


!define PRODUCT_NAME "MeowIME"
!define PRODUCT_VERSION "0.1"
!define PRODUCT_PUBLISHER "elsbfed"
!define PRODUCT_WEB_SITE "https://github.com/elsbfed/MeowIME"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
; ## HKLM = HKEY_LOCAL_MACHINE
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; ## HKCU = HKEY_CURRENT_USER

SetCompressor lzma
ManifestDPIAware true
BrandingText " "

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_NOSTRETCH

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

Var LANGID_EN
Var LANGID_CHT
Var LANGID_CHS
Var LANGID_JP
Var LANGID_KR
Var LANGID

Function myPageCreate

nsDialogs::Create 1018
Pop $0
${NSD_CreateLabel} 0 0 100% 12u "請選擇以下一種語言"
Pop $1

${NSD_CreateRadioButton} 5% 10% 100% 20 "英文(美國)"
Pop $LANGID_EN
${NSD_CreateRadioButton} 5% 20% 100% 20 "中文(繁體，台灣)"
Pop $LANGID_CHT
${NSD_CreateRadioButton} 5% 30% 100% 20 "中文(簡體，中國)"
Pop $LANGID_CHS
${NSD_CreateRadioButton} 5% 40% 100% 20 "日文(日本)"
Pop $LANGID_JP
${NSD_CreateRadioButton} 5% 50% 100% 20 "韓文(韓國)"
Pop $LANGID_KR

${NSD_OnClick} $LANGID_EN OnRadio
${NSD_OnClick} $LANGID_CHT OnRadio
${NSD_OnClick} $LANGID_CHS OnRadio
${NSD_OnClick} $LANGID_JP OnRadio
${NSD_OnClick} $LANGID_KR OnRadio

${NSD_Check} $LANGID_EN

nsDialogs::Show

FunctionEnd

Function OnRadio
  Pop $R0
  ${If} $R0 == $LANGID_EN
    StrCpy $LANGID 1033
  ${ElseIf} $R0 == $LANGID_CHT
    StrCpy $LANGID 1028
  ${ElseIf} $R0 == $LANGID_CHS
    StrCpy $LANGID 2052
  ${ElseIf} $R0 == $LANGID_JP
    StrCpy $LANGID 1041
  ${ElseIf} $R0 == $LANGID_KR
    StrCpy $LANGID 1042
  ${EndIf}
FunctionEnd

; Welcome page
!insertmacro MUI_PAGE_WELCOME
Page custom myPageCreate 

; License page
;!insertmacro MUI_PAGE_LICENSE "LICENSE-zh-Hant.rtf"
; Directory page
;!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_TITLE "安裝完成"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
;!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "TradChinese"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
RequestExecutionLevel admin
OutFile "MeowIME_SETUP_${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES64\MeowIME"
ShowInstDetails show
ShowUnInstDetails show

; Language Strings
LangString DESC_INSTALLING ${LANG_TradChinese} "安裝中"
LangString DESC_DOWNLOADING1 ${LANG_TradChinese} "下載中"
 
Function .onInit
  ; !insertmacro MUI_LANGDLL_DISPLAY
  !insertmacro MUI_HEADER_TEXT "TITLE" "SUBTITLE"

  StrCpy $LANGID 1033

  InitPluginsDir

  ${If} ${RunningX64}
  	SetRegView 64
  ${EndIf}
  ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion"
  StrCmp $0 "" StartInstall 0

  MessageBox MB_OKCANCEL|MB_ICONQUESTION "偵測到舊版 $0，必須先移除才能安裝新版。是否要現在進行？" IDOK +2
  	Abort
  ExecWait '"$INSTDIR\uninst.exe" /S _?=$INSTDIR'
   ${If} ${RunningX64}
  	${DisableX64FSRedirection}
  	IfFileExists "$SYSDIR\MeowIME.dll"  0 CheckX64     ;代表反安裝失敗
  		Abort
  CheckX64:
 	${EnableX64FSRedirection}
  ${EndIf}
  IfFileExists "$SYSDIR\MeowIME.dll"  0 RemoveFinished     ;代表反安裝失敗
        Abort
  RemoveFinished:
    	MessageBox MB_ICONINFORMATION|MB_OK "舊版已移除。"
StartInstall:

FunctionEnd

Section "MainSection" SEC01
  SetOutPath "$SYSDIR"
  SetOverwrite ifnewer
  ${If} ${RunningX64}
  	${DisableX64FSRedirection}
  	File "system32.x64\MeowIME.dll"
  	ExecWait '"$SYSDIR\regsvr32.exe" /i:$LANGID /n /s $SYSDIR\MeowIME.dll'
  	File "system32.x64\*.dll"
  	${EnableX64FSRedirection}
  ${EndIf}
  File "system32.x86\MeowIME.dll"
  ExecWait '"$SYSDIR\regsvr32.exe" /i:$LANGID /n /s $SYSDIR\MeowIME.dll'
  File "system32.x86\*.dll"
  CreateDirectory  "$INSTDIR"
  SetOutPath "$INSTDIR"
  SetOutPath "$APPDATA\MeowIME\"
  CreateDirectory "$APPDATA\MeowIME"
  ;File "config.ini"

SectionEnd

Section "Modules" SEC02
SetOutPath $PROGRAMFILES64
  SetOVerwrite ifnewer
SectionEnd

Section -AdditionalIcons
  SetShellVarContext all
  SetOutPath $SMPROGRAMS\MeowIME
  CreateDirectory "$SMPROGRAMS\MeowIME"
  CreateShortCut "$SMPROGRAMS\MeowIME\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  SetOutPath  "$INSTDIR"
  WriteUninstaller "$INSTDIR\uninst.exe"
  ${If} ${RunningX64}
  	SetRegView 64
  ${EndIf}
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$SYSDIR\MeowIME.dll"
  ${If} ${RunningX64}
  	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "EstimatedSize" 286
  ${Else}
  	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "EstimatedSize" 183
   ${EndIf}
SectionEnd

Function un.onUninstSuccess
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name)已移除成功。" /SD IDOK
FunctionEnd

Function un.onInit
;!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "確定要完全移除$(^Name)？" /SD IDYES IDYES +2
  Abort
FunctionEnd

Section Uninstall
 ${If} ${RunningX64}
  ${DisableX64FSRedirection}
  ExecWait '"$SYSDIR\regsvr32.exe" /u /s $SYSDIR\MeowIME.dll'
  ${EnableX64FSRedirection}
 ${EndIf}
  ExecWait '"$SYSDIR\regsvr32.exe" /u /s $SYSDIR\MeowIME.dll'

  ClearErrors
  ${If} ${RunningX64}
  ${DisableX64FSRedirection}
  IfFileExists "$SYSDIR\MeowIME.dll"  0 +3
  Delete "$SYSDIR\MeowIME.dll"
  IfErrors lbNeedReboot +1
  ${EnableX64FSRedirection}
  ${EndIf}
  IfFileExists "$SYSDIR\MeowIME.dll"  0  lbContinueUninstall
  Delete "$SYSDIR\MeowIME.dll"
  IfErrors lbNeedReboot lbContinueUninstall

  lbNeedReboot:
  MessageBox MB_ICONSTOP|MB_YESNO "偵測到有程式正在使用輸入法，請重新開機以繼續移除舊版。是否要立即重新開機？" IDNO lbNoReboot
  Reboot

  lbNoReboot:
  MessageBox MB_ICONSTOP|MB_OK "請將所有程式關閉，再嘗試執行本安裝程式。若仍看到此畫面，請重新開機。" IDOK +1
  Quit
  lbContinueUninstall:

  Delete "$INSTDIR\uninst.exe"
  RMDir /r "$INSTDIR"
  SetShellVarContext all
  Delete "$SMPROGRAMS\MeowIME\Uninstall.lnk"
  RMDir  "$SMPROGRAMS\MeowIME"
  ${If} ${RunningX64}
  	SetRegView 64
  ${EndIf}
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd


 
