@echo off
:: Compila o icone do componente TQuery4D para .dcr (legado) e .res (moderno).
:: Requer brcc32.exe no PATH (instalado com o Delphi em C:\Program Files (x86)\Embarcadero\Studio\XX.0\bin).
:: Execute este script da pasta src\icons\ apos rodar Create-Icons.ps1.

echo [1/2] Gerando icones BMP...
powershell -ExecutionPolicy Bypass -File Create-Icons.ps1
if errorlevel 1 (
    echo ERRO: Falha ao gerar icones. Verifique o PowerShell.
    pause
    exit /b 1
)

echo [2/2] Compilando recurso .dcr (legado) e .res (moderno)...

:: .dcr para compatibilidade com Delphi 7 ate DX
brcc32 -fo Query4D.dcr Query4D.rc
if errorlevel 1 (
    echo AVISO: brcc32 nao encontrado no PATH.
    echo Adicione o bin do Delphi ao PATH, por exemplo:
    echo   C:\Program Files (x86)\Embarcadero\Studio\23.0\bin
    echo Ou compile manualmente no Delphi IDE via Project ^> Resources.
) else (
    echo Criado: Query4D.dcr
)

:: .res moderno (alternativa)
brcc32 Query4D.rc 2>nul
if not errorlevel 1 echo Criado: Query4D.res

echo.
echo Concluido. Recompile o pacote Query4DLib.dpk no Delphi IDE.
pause
