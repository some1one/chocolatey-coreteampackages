$packageName = 'vscode.portable'
$ErrorActionPreference = 'Stop'

$toolsPath = $(Split-Path -Parent $MyInvocation.MyCommand.Definition)
$exePath = Join-Path $toolsPath "Code.exe"
$cmdPath = Join-Path $toolsPath "bin\code.cmd"
$shortcutPath = Join-Path $([Environment]::GetFolderPath("CommonDesktopDirectory")) "Visual Studio Code.lnk"

Get-Process code -ea 0 | ForEach-Object { $_.CloseMainWindow() | Out-Null }
Start-Sleep 1
Get-Process code -ea 0 | Stop-Process  #in case gracefull shutdown did not succeed, try hard kill

if(Test-Path $shortcutPath)
{
  Remove-Item $shortcutPath -Force -ea 0
}

Uninstall-BinFile "Code"

if( -not (Test-Path -path HKCR:) ) {
  New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root
}

If(Test-Path -LiteralPath 'HKCR:\*\shell\VSCode')
{
  Remove-Item -LiteralPath 'HKCR:\*\shell\VSCode' -Recurse
}

If(Test-Path -LiteralPath 'HKCR:\directory\shell\VSCode')
{
  Remove-Item -LiteralPath 'HKCR:\directory\shell\VSCode' -Recurse
}
