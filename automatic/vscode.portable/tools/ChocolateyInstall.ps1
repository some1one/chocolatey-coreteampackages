$ErrorActionPreference = 'Stop'
$toolsPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
. "$toolsPath\helpers.ps1"

$packagePath = Join-Path $toolsPath $PackageName
$binPath = Join-Path $packagePath "bin\code.cmd"

$softwareName = 'Microsoft Visual Studio Code'
$version = '1.43.2'
if ($version -eq (Get-UninstallRegistryKey "$softwareName").DisplayVersion) {
  Write-Host "VS Code $version is already installed."
  return
}

$pp = Get-PackageParameters
Close-VSCode

$packageArgs = @{
  packageName    = 'vscode.portable'
  url            = 'https://az764295.vo.msecnd.net/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/VSCodeSetup-ia32-1.43.2.exe'
  url64bit       = 'https://az764295.vo.msecnd.net/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/VSCodeSetup-x64-1.43.2.exe'

  softwareName   = "$softwareName"

  checksum       = 'c66712e0d55727fbb94d4c665a33f071cb6165278617a9ee9a51d5ded172df08'
  checksumType   = 'sha256'
  checksum64     = '598c24e8db07b61346c7966601d458e2134abdeaba22f83431594dc734bfbc4b'
  checksumType64 = 'sha256'

  silentArgs     = '/verysilent /mergetasks="{0}" /log="{1}\install.log"' -f (Get-MergeTasks), (Get-PackageCacheLocation)
  destination = "$toolsPath"
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyZipPackage @PackageArgs

If(!$pp.DontAddToPath)
{
  Install-BinFile -Name code -Path $binPath
}

If(!$dd.NoDesktopIcon)
{
  $linkPath = Join-Path $([Environment]::GetFolderPath("CommonDesktopDirectory")) "Visual Studio Code.lnk"
  Install-ChocolateyShortcut -ShortcutFilePath $linkPath -TargetPath $binPath -WorkingDirectory $packagePath
}
