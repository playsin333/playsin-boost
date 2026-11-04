$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$work=Join-Path ([IO.Path]::GetTempPath()) ('boost-update-tests-'+[guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($work)
$oldEnv=@($env:P3_NOMAIN,$env:P3_SELF,$env:SystemDrive,$env:ProgramData)
$script:UpdateChecks=0
function Check($Value,$Message) {if (-not $Value) {throw ('FAIL: '+$Message)};$script:UpdateChecks++;Write-Host ('PASS: '+$Message)}
function Sha([byte[]]$Data) {$algo=[Security.Cryptography.SHA256]::Create();try {return ([BitConverter]::ToString($algo.ComputeHash($Data))).Replace('-','')} finally {$algo.Dispose()}}
try {
    $path=Join-Path $root 'PLAYSIN BOOST 3.0.bat';$text=[IO.File]::ReadAllText($path,[Text.Encoding]::UTF8)
    $tokens=$null;$errors=$null;[void][Management.Automation.Language.Parser]::ParseInput($text,[ref]$tokens,[ref]$errors)
    Check ($errors.Count -eq 0) 'BAT syntax'
    $env:P3_NOMAIN='1';$env:P3_SELF=$path;$env:SystemDrive=$work;$env:ProgramData=$work
    . ([scriptblock]::Create($text))
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    function Fixture([string]$Mode) {
        $zipPath=Join-Path $work ($Mode+'.zip')
        $entries=@{'BOOST-PACKAGE.json'='{ "Schema":1, "Product":"PLAYSIN BOOST", "Version":"9.9.9" }';'PLAYSIN BOOST 3.0.bat'="<# :`n@echo off`n#>`n`$P3Version = '9.9.9'`n";'README.md'='test package'}
        if ($Mode -eq 'wrong-product') {$entries['BOOST-PACKAGE.json']='{ "Schema":1,"Product":"OTHER","Version":"9.9.9" }'}
        if ($Mode -eq 'mismatch-version') {$entries['PLAYSIN BOOST 3.0.bat']="`$P3Version = '8.8.8'`n"}
        if ($Mode -eq 'syntax-error') {$entries['PLAYSIN BOOST 3.0.bat']="`$P3Version = '9.9.9'`nfunction Broken {"}
        if ($Mode -eq 'traversal') {$entries['../escape.txt']='unsafe'}
        if ($Mode -eq 'ads') {$entries['file.txt:payload']='unsafe'}
        if ($Mode -eq 'reserved') {$entries['CON.txt']='unsafe'}
        $checksums=(@($entries.Keys | Sort-Object | ForEach-Object {(Sha ([Text.Encoding]::UTF8.GetBytes($entries[$_])))+'  '+$_}) -join "`n")+"`n"
        if ($Mode -eq 'corrupt') {$entries['README.md']='changed after checksum'}
        if ($Mode -eq 'unlisted') {$entries['extra.txt']='not listed'}
        $entries['SHA256SUMS.txt']=$checksums
        $zip=[IO.Compression.ZipFile]::Open($zipPath,[IO.Compression.ZipArchiveMode]::Create)
        try {
            foreach ($name in $entries.Keys) {
                $entry=$zip.CreateEntry('BOOST/'+$name)
                if ($Mode -eq 'symlink' -and $name -eq 'README.md') {$entry.ExternalAttributes=-1577123840}
                $stream=$entry.Open();$data=[Text.Encoding]::UTF8.GetBytes($entries[$name]);try {$stream.Write($data,0,$data.Length)} finally {$stream.Dispose()}
            }
            if ($Mode -eq 'duplicate') {$entry=$zip.CreateEntry('BOOST/readme.MD');$stream=$entry.Open();$stream.Dispose()}
        } finally {$zip.Dispose()}
        return $zipPath
    }
    $valid=Fixture 'valid'
    Check ((Get-BoostPackage $valid).Version -eq '9.9.9') 'valid package metadata and every checksum accepted'
    foreach ($mode in @('wrong-product','mismatch-version','syntax-error','traversal','ads','reserved','corrupt','unlisted','symlink','duplicate')) {
        $bad=Fixture $mode;$failed=$false;try {[void](Get-BoostPackage $bad)} catch {$failed=$true}
        Check $failed ('reject '+$mode+' before installation')
    }
    $parent=Join-Path $work 'installed';[void][IO.Directory]::CreateDirectory($parent)
    $old=Join-Path $parent 'old';[void][IO.Directory]::CreateDirectory($old);[IO.File]::WriteAllText((Join-Path $old 'state.json'),'old copy marker')
    $target=Install-BoostPackage $valid $parent '3.0.7'
    Check ((Test-Path -LiteralPath $target) -and [IO.File]::ReadAllText((Join-Path $old 'state.json')) -eq 'old copy marker') 'installation creates new version and leaves previous folder intact'
    Check (@(Get-ChildItem $parent -Directory -Filter '.boost-stage-*').Count -eq 0) 'staging is cleaned after successful commit'
    $failed=$false;try {[void](Install-BoostPackage $valid $parent '3.0.7')} catch {$failed=$true}
    Check ($failed -and (Test-Path -LiteralPath $target)) 'existing destination is never overwritten'
    $failed=$false;try {[void](Install-BoostPackage $valid $parent '9.9.9')} catch {$failed=$true}
    Check $failed 'same or older package cannot replace current version'
    # Even if the selected ZIP changes between validation and extraction, it cannot escape staging.
    $cached=Get-BoostPackage $valid
    $originalValidator=(Get-Command Get-BoostPackage).ScriptBlock
    function Get-BoostPackage {return $cached}
    $bad=Join-Path $work 'traversal.zip';$failed=$false
    try {[void](Install-BoostPackage $bad $parent '3.0.7')} catch {$failed=$true}
    Set-Item Function:Get-BoostPackage $originalValidator
    Check ($failed -and -not (Test-Path -LiteralPath (Join-Path $parent 'escape.txt')) -and @(Get-ChildItem $parent -Directory -Filter '.boost-stage-*').Count -eq 0) 'changed archive cannot escape staging and failed install cleans up'
    $failed=$false;try {Receive-BoostUpdateFile 'http://example.invalid/archive.zip' (Join-Path $work 'http.zip') 1MB} catch {$failed=$true}
    Check $failed 'unencrypted update URL is rejected without downloading'
    # Exercise the online protocol without contacting a network or private repository.
    $onlineDir=Join-Path $work 'online';[void][IO.Directory]::CreateDirectory($onlineDir)
    $script:WrongHash=$false;$script:OldRelease=$false;$script:Downloads=0
    function Receive-BoostUpdateFile($Url,$Dest,$Limit) {
        $script:Downloads++
        if ($Url -like '*release.json') {
            $hash=(Get-FileHash -LiteralPath $valid -Algorithm SHA256).Hash;if ($script:WrongHash) {$hash='0'*64}
            $version='9.9.9';if ($script:OldRelease) {$version=$P3Version}
            Write-JsonAtomic $Dest @{Schema=1;Product='PLAYSIN BOOST';Version=$version;Sha256=$hash;ArchiveUrl='https://example.invalid/update.zip'}
        } else {Copy-Item -LiteralPath $valid -Destination $Dest -Force}
    }
    $downloaded=Get-OnlineBoostUpdate 'https://example.invalid/release.json' $onlineDir
    Check ((Test-Path -LiteralPath $downloaded) -and $script:Downloads -eq 2) 'online protocol checks release and package hashes before installation'
    $script:WrongHash=$true;$failed=$false;try {[void](Get-OnlineBoostUpdate 'https://example.invalid/release.json' $onlineDir)} catch {$failed=$true}
    Check $failed 'online archive hash mismatch is rejected'
    $script:WrongHash=$false;$script:OldRelease=$true;$script:Downloads=0
    Check ($null -eq (Get-OnlineBoostUpdate 'https://example.invalid/release.json' $onlineDir) -and $script:Downloads -eq 1) 'up-to-date release avoids archive download'
    # Resolve bundled channels and retain existing per-installation overrides.
    $PackDir=Join-Path (Join-Path $work 'source-resolution') 'current'
    [void][IO.Directory]::CreateDirectory($PackDir)
    $bundled=Join-Path $PackDir 'PLAYSIN-BOOST-update-source.json'
    $override=Join-Path (Split-Path $PackDir) 'PLAYSIN-BOOST-update-source.json'
    Write-JsonAtomic $bundled @{ManifestUrl='https://example.invalid/bundled/release.json'}
    Check ((Get-BoostUpdateSource) -eq 'https://example.invalid/bundled/release.json') 'bundled channel needs no configuration on the client PC'
    Write-JsonAtomic $override @{ManifestUrl='https://example.invalid/custom/release.json'}
    Check ((Get-BoostUpdateSource) -eq 'https://example.invalid/custom/release.json') 'existing per-installation source takes precedence'
    $oldOfficial='https://raw.githubusercontent.com/playsin333/pc-optimizer/main/boost-release.json'
    $newOfficial='https://raw.githubusercontent.com/playsin333/playsin-boost/main/boost-release.json'
    Write-JsonAtomic $override @{ManifestUrl=$oldOfficial}
    $beforeSource=[IO.File]::ReadAllText($override)
    Check ((Get-BoostUpdateSource) -eq $newOfficial -and [IO.File]::ReadAllText($override) -ceq $beforeSource) 'legacy official parent source resolves to public channel without rewriting its file'
    Remove-Item -LiteralPath $override
    Write-JsonAtomic $bundled @{ManifestUrl=$oldOfficial}
    Check ((Get-BoostUpdateSource) -eq $newOfficial) 'legacy official bundled source resolves to public channel'
    Write-JsonAtomic $bundled @{ManifestUrl=$newOfficial}
    Write-JsonAtomic $override @{ManifestUrl='https://example.invalid/custom/release.json'}
    Check ((Get-BoostUpdateSource) -eq 'https://example.invalid/custom/release.json') 'custom parent source retains priority over new official channel'
    Write-JsonAtomic $override @{ManifestUrl=($oldOfficial+'?custom=1')}
    Check ((Get-BoostUpdateSource) -eq ($oldOfficial+'?custom=1')) 'legacy-looking custom URLs are not migrated'
    foreach ($url in @('http://example.invalid/release.json','https://user:password@example.invalid/release.json','release.json')) {
        Write-JsonAtomic $override @{ManifestUrl=$url}
        $failed=$false;try {[void](Get-BoostUpdateSource)} catch {$failed=$true}
        Check $failed 'source rejects insecure, credentialed or relative URL'
    }
    Remove-Item -LiteralPath $override

    $script:NetworkFails=$false;$script:WrongHash=$false;$script:OldRelease=$false;$script:BadArchiveUrl=$false
    function Receive-BoostUpdateFile($Url,$Dest,$Limit) {
        $script:Downloads++
        if ($script:NetworkFails) { throw 'simulated connection failure' }
        if ($Url -like '*release.json') {
            $script:ReleaseDirectory=Split-Path $Dest
            $hash=(Get-FileHash -LiteralPath $valid -Algorithm SHA256).Hash;if ($script:WrongHash) {$hash='0'*64}
            $version='9.9.9';if ($script:OldRelease) {$version=$P3Version}
            $archiveUrl='https://example.invalid/update.zip';if ($script:BadArchiveUrl) {$archiveUrl='http://example.invalid/update.zip'}
            Write-JsonAtomic $Dest @{Schema=1;Product='PLAYSIN BOOST';Version=$version;Sha256=$hash;ArchiveUrl=$archiveUrl}
        } else { Copy-Item -LiteralPath $valid -Destination $Dest -Force }
    }
    $script:Downloads=0
    $release=Get-OnlineBoostRelease 'https://example.invalid/release.json' $onlineDir
    Check ($release.Version -eq '9.9.9' -and $script:Downloads -eq 1) 'version check downloads only metadata before confirmation'
    $script:BadArchiveUrl=$true;$failed=$false
    try {[void](Get-OnlineBoostRelease 'https://example.invalid/release.json' $onlineDir)} catch {$failed=$true}
    Check $failed 'insecure archive URL is rejected before asking to install'
    $script:BadArchiveUrl=$false
    function Test-Unpacked { return $true }
    function Wait-Key {}
    function New-Shortcut {}
    function Select-BoostUpdateArchive { throw 'online update must not open a file picker' }
    function Ask {
        $script:Asks++
        $script:AskedAtDownloads=$script:Downloads
        return $script:Confirm
    }
    function Start-Process {param($FilePath,$ArgumentList,$ErrorAction) $script:Launches++;$script:LaunchedFile=$FilePath;$script:LaunchedArgs=$ArgumentList}
    function New-UpdateFlow($Name) {
        $script:PackDir=Join-Path (Join-Path $work $Name) 'old'
        [void][IO.Directory]::CreateDirectory($PackDir)
        [IO.File]::WriteAllText((Join-Path $PackDir 'marker.txt'),'previous version')
        Write-JsonAtomic (Join-Path $PackDir 'PLAYSIN-BOOST-update-source.json') @{ManifestUrl='https://example.invalid/release.json'}
        $script:StateFile=Join-Path $PackDir 'state.json'
        Write-JsonAtomic $StateFile @{RolledBack=$false;InitialBackupMarker='original'}
        $script:Desktop=$PackDir
        $script:Downloads=0;$script:Asks=0;$script:Launches=0;$script:Confirm=$true
    }
    New-UpdateFlow 'auto-success'
    $result=Show-PackUpdater
    Check ($result -and $script:Asks -eq 1 -and $script:AskedAtDownloads -eq 1 -and $script:Downloads -eq 2) 'point 13 checks version then uses one confirmation to download and install'
    Check ($script:Launches -eq 1 -and (Test-Path -LiteralPath $script:LaunchedFile) -and $script:LaunchedArgs[0] -eq '9') 'new BAT opens with service-script refresh and no optimization reapply'
    Check ([IO.File]::ReadAllText((Join-Path $PackDir 'marker.txt')) -eq 'previous version' -and (Read-Json $StateFile).InitialBackupMarker -eq 'original') 'automatic update preserves old folder and original backup state'
    Check (-not (Test-Path -LiteralPath $script:ReleaseDirectory)) 'successful update removes temporary downloads'
    New-UpdateFlow 'auto-cancel';$script:Confirm=$false
    Check (-not (Show-PackUpdater) -and $script:Asks -eq 1 -and $script:Downloads -eq 1 -and $script:Launches -eq 0) 'cancellation downloads no ZIP and starts no new version'
    Check (-not (Test-Path -LiteralPath $script:ReleaseDirectory)) 'cancellation removes temporary metadata'
    New-UpdateFlow 'auto-current';$script:OldRelease=$true
    Check (-not (Show-PackUpdater) -and $script:Asks -eq 0 -and $script:Downloads -eq 1) 'current version needs no confirmation or archive download'
    $script:OldRelease=$false
    New-UpdateFlow 'auto-offline';$script:NetworkFails=$true;$script:Confirm=$false
    Check (-not (Show-PackUpdater) -and $script:Launches -eq 0 -and (Test-Path -LiteralPath $StateFile)) 'connection failure returns to the menu and preserves state'
    $script:NetworkFails=$false
    New-UpdateFlow 'auto-bad-hash';$script:WrongHash=$true
    Check (-not (Show-PackUpdater) -and $script:Launches -eq 0 -and -not (Test-Path -LiteralPath (Join-Path (Split-Path $PackDir) 'PLAYSIN BOOST 9.9.9'))) 'corrupt online archive cannot install or start a new version'
    $script:WrongHash=$false
    New-UpdateFlow 'local-no-channel'
    Remove-Item -LiteralPath (Join-Path $PackDir 'PLAYSIN-BOOST-update-source.json')
    function Select-BoostUpdateArchive { return $valid }
    Check ((Show-PackUpdater) -and $script:Downloads -eq 0 -and $script:Launches -eq 1) 'local ZIP installation remains available without an online source'
    New-UpdateFlow 'local-offline-fallback';$script:NetworkFails=$true
    Check ((Show-PackUpdater) -and $script:Asks -eq 2 -and $script:Launches -eq 1) 'offline source still allows explicit local ZIP installation'
    $script:NetworkFails=$false
    Write-Host ('SUCCESS: '+$script:UpdateChecks+' focused checks. Network and launches were not performed.')
} finally {
    $env:P3_NOMAIN=$oldEnv[0];$env:P3_SELF=$oldEnv[1];$env:SystemDrive=$oldEnv[2];$env:ProgramData=$oldEnv[3]
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
