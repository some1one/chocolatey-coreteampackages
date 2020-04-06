$packageName = 'vscode.portable'
$ErrorActionPreference = 'Stop'
$toolsPath = $(Split-Path -Parent $MyInvocation.MyCommand.Definition)
. "$toolsPath\helpers.ps1"

$installPath = Join-Path $toolsPath $packageName
$exePath = Join-Path $installPath "Code.exe"
$cmdPath = Join-Path $installPath "bin\code.cmd"
$shortcutPath = Join-Path $([Environment]::GetFolderPath("CommonDesktopDirectory")) "Visual Studio Code.lnk"

$softwareName = 'Microsoft Visual Studio Code'
$version = '1.43.2'
if ($version -eq (Get-UninstallRegistryKey "$softwareName").DisplayVersion) {
  Write-Host "VS Code $version is already installed."
  return
}

$pp = Get-PackageParameters
$packageArgs = @{
  packageName    = $packageName
  
  url            = 'https://az764295.vo.msecnd.net/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/VSCodeSetup-ia32-1.43.2.exe'
  url64          = 'https://az764295.vo.msecnd.net/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/VSCodeSetup-x64-1.43.2.exe'
  
  checksum       = 'c66712e0d55727fbb94d4c665a33f071cb6165278617a9ee9a51d5ded172df08'
  checksumType   = 'sha256'
  
  checksum64     = '598c24e8db07b61346c7966601d458e2134abdeaba22f83431594dc734bfbc4b'
  checksumType64 = 'sha256'

  unzipLocation = "$toolsPath"
}

Get-Process code -ea 0 | ForEach-Object { $_.CloseMainWindow() | Out-Null }
Start-Sleep 1
Get-Process code -ea 0 | Stop-Process  #in case gracefull shutdown did not succeed, try hard kill

New-Item "$exePath.gui" -type file -force | Out-Null
New-Item "$exePath.ignore" -type file -force | Out-Null
Install-ChocolateyZipPackage @PackageArgs

$args = ""

If($pp.UserDataDir)
{
  $args = '$args --user-data-dir "$pp.UserDataDir"'
}

If($pp.ExtDir)
{
  $args = '$args --extensions-dir "$pp.ExtDir"'
}

If($pp.DisableGpu)
{
  $args = '$args --disable-gpu'
}

If(!$pp.NoDesktopIcon)
{
  If($pp.NoQuicklaunchIcon)
  {
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath $exePath -WorkingDirectory $installPath -Arguments $args
  }
  else
  {
    Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath $exePath -WorkingDirectory $installPath -Arguments $args -PinToTaskbar
  }
}

If(!$pp.DontAddToPath)
{
  New-Item "$cmdPath.gui" -type file -force | Out-Null
  Install-BinFile -Name Code -Path $cmdPath -UseStart -Command $args
}

If(!$pp.NoContextMenuFiles)
{
  Install-ChocolateyExplorerMenuItem -MenuKey "VSCode" -MenuLabel "Open with Code" -Command '"$exePath" $args' -Type "file"
}

If(!$pp.NoContextMenuFolders)
{
  Install-ChocolateyExplorerMenuItem -MenuKey "VSCode" -MenuLabel "Open with Code" -Command '"$exePath" $args' -Type "directory"
}
