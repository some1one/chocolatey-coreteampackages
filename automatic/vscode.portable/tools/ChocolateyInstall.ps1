$packageName = 'vscode.portable'
$ErrorActionPreference = 'Stop'

$toolsPath = $(Split-Path -Parent $MyInvocation.MyCommand.Definition)
$exePath = Join-Path $toolsPath "Code.exe"
$cmdPath = Join-Path $toolsPath "bin\code.cmd"
$shortcutPath = Join-Path $([Environment]::GetFolderPath("CommonDesktopDirectory")) "Visual Studio Code.lnk"

$pp = Get-PackageParameters
$packageArgs = @{
  packageName    = $packageName

  url            = 'https://az764295.vo.msecnd.net/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/VSCode-win32-ia32-1.43.2.zip'
  url64          = 'https://az764295.vo.msecnd.net/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/VSCode-win32-x64-1.43.2.zip'

  checksum       = 'dbee3793b6b4f9c4f67448089a225227d5e4dec0a38163de6a5777eb44509530'
  checksumType   = 'sha256'

  checksum64     = '2ad9da475f986abebe2189b9ddea1753d0fdf292ecc6f5b9b6c408312b09348e'
  checksumType64 = 'sha256'

  unzipLocation = "$toolsPath"
}

Get-Process code -ea 0 | ForEach-Object { $_.CloseMainWindow() | Out-Null }
Start-Sleep 1
Get-Process code -ea 0 | Stop-Process  #in case gracefull shutdown did not succeed, try hard kill

Install-ChocolateyZipPackage @PackageArgs

$files = get-childitem $toolsPath -include *.exe -recurse
foreach ($file in $files) {
  #generate an ignore file
  New-Item "$file.ignore" -type file -force | Out-Null
}

New-Item "$exePath.gui" -type file -force | Out-Null

$params = ""

If($pp.UserDataDir)
{
  $params = "$params --user-data-dir ""$($pp.UserDataDir)"""
}

If($pp.ExtDir)
{
  $params = "$params --extensions-dir ""$($pp.ExtDir)"""
}

If($pp.DisableGpu)
{
  $params = "$params --disable-gpu"
}

If(!$pp.NoDesktopIcon)
{
  If($pp.NoQuicklaunchIcon)
  {
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath $exePath -WorkingDirectory $toolsPath -Arguments $params
  }
  else
  {
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath $exePath -WorkingDirectory $toolsPath -Arguments $params -PinToTaskbar
  }
}

If(!$pp.DontAddToPath)
{
  New-Item "$cmdPath.gui" -type file -force | Out-Null
  Install-BinFile -Name Code -Path """$cmdPath""" -UseStart -Command """$params"""
}

if( -not (Test-Path -path HKCR:) ) {
  New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root
}

If(!$pp.NoContextMenuFiles)
{
    #%1 is automatically added at the end but we want it befored the params
  Install-ChocolateyExplorerMenuItem -MenuKey "VSCode" -MenuLabel "Open with Code" -Command """$exePath"" ""%1"" $params" -Type "file"
  $reg = Get-Item -LiteralPath 'HKCR:\*\shell\VSCode\command'
  $value = $reg.GetValue($null)
  $value = $value.substring(0,$value.length-6).trim()
  Set-ItemProperty -LiteralPath 'HKCR:\*\shell\VSCode\command' -Name '(Default)' -Value $value
}

If(!$pp.NoContextMenuFolders)
{
  Install-ChocolateyExplorerMenuItem -MenuKey "VSCode" -MenuLabel "Open with Code" -Command """$exePath"" ""%1"" $params" -Type "directory"
  $reg = Get-Item -LiteralPath 'HKCR:\directory\shell\VSCode\command'
  $value = $reg.GetValue($null)
  $value = $value.substring(0,$value.length-6).trim()
  Set-ItemProperty -LiteralPath 'HKCR:\directory\shell\VSCode\command' -Name '(Default)' -Value $value
}
