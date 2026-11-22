; Instalador de Windows de «El Templo de los Ecos» (NSIS 3).
;
; Lo compila el CI (.github/workflows/android-alpha.yml) después de exportar el
; juego con el preset «Windows Desktop». A mano, desde la raíz del repositorio:
;
;   makensis -DVERSION=0.5.4-alpha -DEXE="$PWD/build/windows/ElTemploDeLosEcos.exe" \
;            -DSALIDA="$PWD/build/ElTemploDeLosEcos-v0.5.4-alpha-Windows-Setup.exe" \
;            instalador/windows/instalador.nsi
;
; (Las rutas relativas se leen desde esta carpeta; por eso se pasan absolutas.)
;
; Instala solo para el usuario actual (no pide permisos de administrador), en
; %LOCALAPPDATA%\Programs\El Templo de los Ecos, con accesos en el menú Inicio
; y el escritorio, y desinstalador en «Aplicaciones instaladas».

Unicode true
!include "MUI2.nsh"

!ifndef VERSION
  !define VERSION "dev"
!endif
!ifndef EXE
  !define EXE "../../build/windows/ElTemploDeLosEcos.exe"
!endif
!ifndef SALIDA
  !define SALIDA "../../build/ElTemploDeLosEcos-Windows-Setup.exe"
!endif

!define NOMBRE "El Templo de los Ecos"
!define CLAVE "Software\Microsoft\Windows\CurrentVersion\Uninstall\ElTemploDeLosEcos"

Name "${NOMBRE} ${VERSION}"
OutFile "${SALIDA}"
InstallDir "$LOCALAPPDATA\Programs\${NOMBRE}"
InstallDirRegKey HKCU "${CLAVE}" "InstallLocation"
RequestExecutionLevel user
SetCompressor /SOLID lzma
BrandingText "${NOMBRE} · versión de prueba ${VERSION}"

!define MUI_ICON "icono.ico"
!define MUI_UNICON "icono.ico"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${NOMBRE} ${VERSION}"
!define MUI_WELCOMEPAGE_TEXT "Vas a instalar una versión de prueba (alpha) de ${NOMBRE}.$\r$\n$\r$\nPuede tener errores: si encuentras alguno, el archivo LEEME.txt explica cómo reportarlo.$\r$\n$\r$\nSi Windows muestra «Windows protegió tu PC», pulsa «Más información» y luego «Ejecutar de todas formas»: el instalador no está firmado."
!define MUI_FINISHPAGE_RUN "$INSTDIR\ElTemploDeLosEcos.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Jugar ahora"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\LEEME.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Leer cómo reportar errores"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

VIProductVersion "0.0.0.0"
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductName" "${NOMBRE}"
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductVersion" "${VERSION}"
VIAddVersionKey /LANG=${LANG_SPANISH} "FileDescription" "Instalador de ${NOMBRE}"
VIAddVersionKey /LANG=${LANG_SPANISH} "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=${LANG_SPANISH} "CompanyName" "je7remy"
VIAddVersionKey /LANG=${LANG_SPANISH} "LegalCopyright" "© 2026 Jeremy De La Cruz"

Section "Juego" SecJuego
  SectionIn RO
  SetOutPath "$INSTDIR"
  ; Una versión anterior abierta impediría sobrescribir el ejecutable.
  nsExec::Exec 'taskkill /IM ElTemploDeLosEcos.exe /F'
  File "/oname=ElTemploDeLosEcos.exe" "${EXE}"
  File "icono.ico"
  File "LEEME.txt"
  WriteUninstaller "$INSTDIR\Desinstalar.exe"

  CreateDirectory "$SMPROGRAMS\${NOMBRE}"
  CreateShortcut "$SMPROGRAMS\${NOMBRE}\${NOMBRE}.lnk" "$INSTDIR\ElTemploDeLosEcos.exe" "" "$INSTDIR\icono.ico"
  CreateShortcut "$SMPROGRAMS\${NOMBRE}\Cómo reportar errores.lnk" "$INSTDIR\LEEME.txt"
  CreateShortcut "$SMPROGRAMS\${NOMBRE}\Desinstalar.lnk" "$INSTDIR\Desinstalar.exe"
  CreateShortcut "$DESKTOP\${NOMBRE}.lnk" "$INSTDIR\ElTemploDeLosEcos.exe" "" "$INSTDIR\icono.ico"

  WriteRegStr HKCU "${CLAVE}" "DisplayName" "${NOMBRE}"
  WriteRegStr HKCU "${CLAVE}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${CLAVE}" "Publisher" "je7remy"
  WriteRegStr HKCU "${CLAVE}" "DisplayIcon" "$INSTDIR\icono.ico"
  WriteRegStr HKCU "${CLAVE}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${CLAVE}" "UninstallString" '"$INSTDIR\Desinstalar.exe"'
  WriteRegDWORD HKCU "${CLAVE}" "NoModify" 1
  WriteRegDWORD HKCU "${CLAVE}" "NoRepair" 1
SectionEnd

; Desinstalar quita el programa. Las partidas guardadas (en %APPDATA%\Godot)
; se conservan, igual que al actualizar.
Section "Uninstall"
  nsExec::Exec 'taskkill /IM ElTemploDeLosEcos.exe /F'
  Delete "$INSTDIR\ElTemploDeLosEcos.exe"
  Delete "$INSTDIR\icono.ico"
  Delete "$INSTDIR\LEEME.txt"
  Delete "$INSTDIR\Desinstalar.exe"
  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\${NOMBRE}\${NOMBRE}.lnk"
  Delete "$SMPROGRAMS\${NOMBRE}\Cómo reportar errores.lnk"
  Delete "$SMPROGRAMS\${NOMBRE}\Desinstalar.lnk"
  RMDir "$SMPROGRAMS\${NOMBRE}"
  Delete "$DESKTOP\${NOMBRE}.lnk"
  DeleteRegKey HKCU "${CLAVE}"
SectionEnd
