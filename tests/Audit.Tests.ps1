$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$raw=[IO.File]::ReadAllText((Join-Path $root 'PLAYSIN BOOST 3.0.bat'),[Text.Encoding]::UTF8)
. ([scriptblock]::Create($raw.Replace("[Environment]::GetFolderPath('Desktop')", '$work')))
$script:AuditChecks=0
function Check($Value,$Message) {if (-not $Value) {throw ('FAIL: '+$Message)};$script:AuditChecks++;Write-Host ('PASS: '+$Message)}
$script:StartValue=3;$script:NativeCalls=0;$script:Stops=0;$script:Order=@()
function Get-RegValue {return @{Kind='DWord';Value=$script:StartValue}}
function Save-RegBackup {throw 'disk full'}
function Set-RawReg {throw 'access denied'}
function Invoke-Native {$script:NativeCalls++;$script:Order+='native';$script:StartValue=4;return @{Code=0;Out=''}}
function Stop-Service {$script:Stops++}
function Log {}
$caught=$false;try {Disable-Svc @('Example')} catch {$caught=$true}
Check ($caught -and $script:NativeCalls -eq 0 -and $script:Stops -eq 0) 'service backup failure blocks both sc.exe fallback and Stop-Service'
function Save-RegBackup {$script:Order+='backup'}
Disable-Svc @('Example')
Check ($script:NativeCalls -eq 1 -and $script:Stops -eq 1 -and ($script:Order -join ',') -eq 'backup,native') 'service registry denial can use sc.exe only after saving initial value'
$script:CimWrites=0
function Get-CimInstance {return @(@{InstanceName='USB\Example';Enable=$true})}
function Set-CimInstance {$script:CimWrites++}
function Add-StateList {throw 'state unavailable'}
$caught=$false;try {[void](Disable-DevicePowerOff @('USB\'))} catch {$caught=$true}
Check ($caught -and $script:CimWrites -eq 0) 'device power history failure prevents device mutation'
$script:TaskWrites=0
function Get-ScheduledTask {return @{State='Ready'}}
function Disable-ScheduledTask {$script:TaskWrites++}
$caught=$false;try {Invoke-TaskTweaks @{} @{} @{}} catch {$caught=$true}
Check ($caught -and $script:TaskWrites -eq 0) 'task history failure prevents scheduled-task disabling'
# Test NVIDIA backup creation and damage handling using real temporary files.
$DrsDir=Join-Path $work 'audit-drs-source';$DrsBackup=Join-Path $work 'audit-drs-backup'
[void][IO.Directory]::CreateDirectory($DrsDir)
$State=@{}
function Save-State {}
$caught=$false;try {Save-NvidiaBackup '1.0'} catch {$caught=$true}
Check ($caught -and -not $State.NvDrs -and -not (Test-Path -LiteralPath $DrsBackup)) 'empty source cannot become a trusted NVIDIA backup'
[IO.File]::WriteAllText((Join-Path $DrsDir 'one.bin'),'source-one')
[IO.File]::WriteAllText((Join-Path $DrsDir 'two.bin'),'source-two')
[void][IO.Directory]::CreateDirectory($DrsBackup)
[IO.File]::WriteAllText((Join-Path $DrsBackup 'partial.bin'),'incomplete old attempt')
Save-NvidiaBackup '1.0'
Check ($State.NvDrs -and $State.NvDriver -eq '1.0' -and (Test-NvidiaBackupFiles $DrsBackup)) 'NVIDIA backup is trusted only after copy and hash-manifest verification'
Check (@(Get-ChildItem $work -Directory -Filter 'audit-drs-backup.incomplete-*').Count -eq 1) 'incomplete prior backup is retained separately rather than silently reused'
Check (@(Get-ChildItem $work -Directory -Filter 'audit-drs-backup.preparing-*').Count -eq 0) 'NVIDIA staging directories are cleaned up'
$caught=$false;try {Save-NvidiaBackup '2.0'} catch {$caught=$true}
Check $caught 'changed driver cannot reuse original NVIDIA backup for new profile application'
[IO.File]::WriteAllText((Join-Path $DrsBackup 'one.bin'),'corrupted')
Check (-not (Test-NvidiaBackupFiles $DrsBackup)) 'backup verifier detects altered NVIDIA file'
$caught=$false;try {Save-NvidiaBackup '1.0'} catch {$caught=$true}
Check $caught 'corrupt NVIDIA backup blocks another profile application'
$State=@{};$DrsBackup=Join-Path $work 'audit-drs-copy-failure'
function Copy-Item {throw 'copy denied'}
$caught=$false;try {Save-NvidiaBackup '1.0'} catch {$caught=$true}
Check ($caught -and -not $State.NvDrs -and -not (Test-Path -LiteralPath $DrsBackup)) 'copy failure cannot commit a trusted NVIDIA backup'
$PackDir=Join-Path $work 'docs-only';$index=Join-Path (Join-Path $PackDir 'Программы') 'Открыть гайды.html'
[void][IO.Directory]::CreateDirectory((Split-Path -Parent $index));[IO.File]::WriteAllText($index,'local guide')
$script:Opened=@()
function Start-Process($FilePath) {$script:Opened+=$FilePath}
Show-ProgramGuides
Check ($script:Opened.Count -eq 1 -and $script:Opened[0] -eq $index) 'guides menu opens only the local index without installation'
return $script:AuditChecks
