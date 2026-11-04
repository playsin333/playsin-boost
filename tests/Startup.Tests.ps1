# Execute the exact command used by the BAT in a fresh process, without rewriting its source.
$ErrorActionPreference='Stop'
$repo=Split-Path -Parent $PSScriptRoot
$raw=[IO.File]::ReadAllText((Join-Path $repo 'PLAYSIN BOOST 3.0.bat'),[Text.Encoding]::UTF8)
$launchLine=($raw -split '\r?\n' | Where-Object { $_ -match '^powershell .* -Command ' } | Select-Object -First 1)
if ($launchLine -notmatch '-Command "(.*)"$') { throw 'Cannot extract BAT launch command' }
$launchCommand=$Matches[1]
$exe=(Get-Process -Id $PID).Path
$folder=Join-Path $work "Startup O'Brien & (тест)"
[void][IO.Directory]::CreateDirectory($folder)
$copy=Join-Path $folder 'PLAYSIN BOOST 3.0.bat'
[IO.File]::WriteAllText($copy,$raw,[Text.Encoding]::UTF8)
function Literal($Value) { return "'" + $Value.Replace("'","''") + "'" }
$prefix='$env:P3_NOMAIN=''1'';$env:P3_SELF='+ (Literal $copy) + ';$env:SystemDrive='+ (Literal $work) + ';$env:ProgramData='+ (Literal $work) + ';$env:TEMP='+ (Literal $folder) + ';$env:TMP='+ (Literal $folder) + ';$env:TMPDIR='+ (Literal $folder) + ';'
$expectedVersion=[string](Get-Content -LiteralPath (Join-Path $repo 'BOOST-PACKAGE.json') -Raw | ConvertFrom-Json).Version
$probe=$prefix+$launchCommand+'; if ($P3Version -ne '+(Literal $expectedVersion)+' -or -not (Get-Command Main -ErrorAction SilentlyContinue)) { exit 9 }; $banner=Show-Banner 6>&1 | Out-String; if ($banner -notmatch [regex]::Escape(''обновлённая сборка ''+$P3Version)) { exit 10 }; Write-Output ''STARTUP_LOADED'''
$encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($probe))
$output=@(& $exe -NoProfile -NonInteractive -EncodedCommand $encoded 2>&1)
if ($LASTEXITCODE -ne 0 -or ($output -join "`n") -notmatch 'STARTUP_LOADED') { throw ('Unmodified BAT failed to load: '+($output -join "`n")) }
Write-Host 'PASS: exact BAT loader loads source with special path characters and menu displays the loaded build version'
[IO.File]::WriteAllText($copy,'function Broken {',[Text.Encoding]::UTF8)
$encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($prefix+$launchCommand))
$output=@(& $exe -NoProfile -NonInteractive -EncodedCommand $encoded 2>&1)
$failureCode=$LASTEXITCODE
$log=Join-Path $folder 'PLAYSIN-BOOST-error.txt'
if ($failureCode -ne 1 -or -not (Test-Path -LiteralPath $log)) { throw ('Startup failure did not produce its diagnostic: '+($output -join "`n")) }
if ([string]::IsNullOrWhiteSpace([IO.File]::ReadAllText($log))) { throw 'Startup failure report was empty' }
Write-Host 'PASS: parse failure returns nonzero and writes a nonempty diagnostic file'
if ($raw -notmatch '(?m)^pause\r?$') { throw 'BAT does not keep a startup failure visible' }
Write-Host 'PASS: BAT pauses on unexpected failure before closing'
return 3
