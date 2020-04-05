. $PSScriptRoot\..\vscode.install\update.ps1

$releases32 = 'https://vscode-update.azurewebsites.net/api/update/win32-archive/stable/VERSION'
$releases64 = 'https://vscode-update.azurewebsites.net/api/update/win32-x64-archive/stable/VERSION'

function global:au_SearchReplace {
   @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<dependency .+?`"$($Latest.PackageName).install`" version=)`"([^`"]+)`"" = "`$1`"[$($Latest.Version)]`""
        }
    }
}

update -ChecksumFor none
