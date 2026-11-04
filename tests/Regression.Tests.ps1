$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$raw=[IO.File]::ReadAllText((Join-Path $root 'PLAYSIN BOOST 3.0.bat'),[Text.Encoding]::UTF8)
. ([scriptblock]::Create($raw.Replace("[Environment]::GetFolderPath('Desktop')", '$work')))
$script:RegressionChecks=0
function Check($Value,$Message) { if (-not $Value) { throw ('FAIL: '+$Message) };$script:RegressionChecks++;Write-Host ('PASS: '+$Message) }
$all=@(Get-BoostPlan @{IsNvidia=$true;IsAmdGpu=$true} 'Max')
foreach ($preset in @('Keep','Light','Gaming')) {
    $p=@(Get-BoostPlan @{IsNvidia=$false;IsAmdGpu=$true} $preset | Where-Object {$_.Pre})
    Check (-not (@($p.Id) -contains 'global-timer') -and -not (@($p.Id) -contains 'storage')) ($preset+' does not hide NTFS/global timer in automatic system block')
}
Check (@($all.Id) -contains 'global-timer' -and @($all.Id) -contains 'storage' -and @($all.Id) -contains 'grouping') 'advanced system capabilities remain selectable'
$script:Specs=@()
function Section {}
function Apply-Reg($Title,$Values) { $script:Specs += $Values }
Invoke-SystemTweaks @{IsWin11=$true} 'Strong' @{System=$true} @{}
Check (-not (($script:Specs -join '|') -match 'GlobalTimerResolution|Ntfs|PagingFiles|UserPreferencesMask|KeyboardSpeed')) 'base system execution cannot touch split settings'
$script:Specs=@();Invoke-GlobalTimerTweaks @{IsWin11=$true} 'Strong' @{} @{}
Check ($script:Specs.Count -eq 1 -and $script:Specs[0] -match 'GlobalTimerResolutionRequests') 'global timer has isolated implementation'
$script:Specs=@();Invoke-GlobalTimerTweaks @{IsWin11=$false} 'Strong' @{} @{}
Check ($script:Specs.Count -eq 0) 'global timer is skipped on Windows 10'
$script:Specs=@();Invoke-StorageTweaks @{} 'Strong' @{} @{}
Check ($script:Specs.Count -eq 2 -and ($script:Specs -join '|') -notmatch 'GlobalTimerResolution') 'NTFS implementation is isolated'
$summary=@(Show-Answers @{IsNvidia=$false} 'Weak' @{} @{} @{Mode='Rec';Blocks=@('system');UsesVbs=$true;GameClose=@()})
Check (($summary -join '|') -notmatch 'Valorant.*да|NVIDIA|Службы оставить') 'summary does not invent installed games or unselected GPU/services'
$hw=@{Name='Windows';Cpu='5700X';Gpu='RX580';Main=@{VramGB=4};RamGB=16;WeakGpu=@{Why='4GB'};WeakCpu=@{Weak=$false};WeakRam=$false}
$output=Show-Profile $hw 'Weak' @{Video=$true;System=$false} 6>&1 | Out-String
Check ($output -notmatch 'Профиль: Слабый ПК|системные пункты не нужны') 'hardware summary does not misclassify the whole PC or hide general system actions'
$StateFile=Join-Path $work 'bcd-original.json';$State=@{Bcd=@{}}
Save-BcdChange 'disabledynamictick' $null 'Yes' $true
Save-BcdChange 'disabledynamictick' 'No' 'Yes' $true
Check ($null -eq (Read-Json $StateFile).Bcd.disabledynamictick.Old) 'BCD original absence survives repeated changes'
# Import rollback functions without its executable entry point.
$t=$null;$e=$null;$ast=[Management.Automation.Language.Parser]::ParseInput($RollbackBody,[ref]$t,[ref]$e)
foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]},$false)) { if ($fn.Name -ne 'Main') { . ([scriptblock]::Create($fn.Extent.Text)) } }
$script:Errors=0;$script:Messages=@()
function Log($Kind,$Message) { if ($Kind -eq 'ERR') {$script:Errors++};$script:Messages+=$Message }
function Ask {return $false}
$script:Registry=@{}
function Get-RegValue($Path,$Name) {return $script:Registry[$Path+'|'+$Name]}
function Set-RawReg($Path,$Name,$Kind,$Value) {$script:Registry[$Path+'|'+$Name]=[pscustomobject]@{Kind=$Kind;Value=$Value}}
function Remove-RawReg($Path,$Name) {[void]$script:Registry.Remove($Path+'|'+$Name)}
foreach ($case in @(@('DWord',[int64]4294967295,1),@('QWord',[int64]9999999999,1),@('Binary',[byte[]]@(1,2,255),[byte[]]@(3,4)),@('MultiString',[string[]]@('a','b'),[string[]]@('new')),@('String','old','new'),@('ExpandString','%windir%\old','%windir%\new'))) {
    $item=[pscustomobject]@{Path='HKCU\Fake';Name='Value';Kind=$case[0];Value=$case[1];NewKind=$case[0];NewValue=$case[2];Existed=$true;Note='type test'}
    $script:Registry['HKCU\Fake|Value']=[pscustomobject]@{Kind=$case[0];Value=$case[2]}
    Undo-Registry @{Items=@($item)}
    Check (Test-RegOriginal $item) ('rollback restores '+$case[0]+' value with correct type')
}
$item=[pscustomobject]@{Path='HKCU\Fake';Name='NewValue';NewKind='DWord';NewValue=1;Existed=$false;Note='absence'}
$script:Registry['HKCU\Fake|NewValue']=[pscustomobject]@{Kind='DWord';Value=1}
Undo-Registry @{Items=@($item)}
Check (-not $script:Registry.ContainsKey('HKCU\Fake|NewValue')) 'rollback removes values that did not exist originally'
function Power-Case($Active,$Fail) {
    $script:PowerActive=$Active;$script:PowerFail=$Fail;$script:Calls=@();$script:Schemes=@{boost=1;game=1;old=1;user=1};$script:Errors=0
    function Get-ActiveScheme {return $script:PowerActive}
    function Test-SchemeExists($Id) {return $script:Schemes.ContainsKey([string]$Id)}
    function Invoke-Native($Exe,$ArgList) {
        $script:Calls+=($ArgList -join ' ')
        if ($ArgList[0] -eq '/setactive') { if ($script:PowerFail) {return @{Code=1;Out='failed'}};$script:PowerActive=$ArgList[1] }
        if ($ArgList[0] -eq '/delete') {[void]$script:Schemes.Remove($ArgList[1])}
        return @{Code=0;Out=''}
    }
    Undo-Power @{OldScheme='old';NewScheme='boost';GameScheme='game';PowerDevs=@()}
    return @{Active=$script:PowerActive;Calls=$script:Calls;Errors=$script:Errors;Schemes=$script:Schemes}
}
$r=Power-Case 'boost' $true
Check ($r.Errors -gt 0 -and $r.Schemes.ContainsKey('boost') -and $r.Schemes.ContainsKey('game')) 'failed power restoration retains owned schemes for retry'
$r=Power-Case 'boost' $false
Check ($r.Active -eq 'old' -and -not $r.Schemes.ContainsKey('boost') -and -not $r.Schemes.ContainsKey('game')) 'successful power rollback restores old and deletes only owned schemes'
$r=Power-Case 'user' $false
Check ($r.Active -eq 'user' -and $r.Schemes.ContainsKey('user')) 'power rollback preserves a later user-selected scheme'
function Invoke-Native {throw 'rollback without owned schemes must not invoke powercfg'}
Undo-Power @{PowerDevs=@()}
Check $true 'rollback without recorded power changes leaves active scheme untouched'
$DrsBackup=Join-Path $work 'drs-backup';$DrsDir=Join-Path $work 'drs-current'
[void][IO.Directory]::CreateDirectory($DrsBackup);[void][IO.Directory]::CreateDirectory($DrsDir)
[IO.File]::WriteAllText((Join-Path $DrsBackup 'profiles.bin'),'original')
function Nvidia-Case($Version,$StopFails) {
    $script:Errors=0;$script:Stops=0;$script:Starts=0
    [IO.File]::WriteAllText((Join-Path $DrsDir 'profiles.bin'),'current')
    function Get-CimInstance {return @{Name='NVIDIA';DriverVersion=$Version}}
    function Stop-Service { $script:Stops++;if ($StopFails) {throw 'stop failed'} }
    function Start-Service {$script:Starts++}
    Undo-Nvidia @{NvDrs=$true;NvDriver='1.0'}
    return @{Errors=$script:Errors;Stops=$script:Stops;Starts=$script:Starts;Data=[IO.File]::ReadAllText((Join-Path $DrsDir 'profiles.bin'))}
}
foreach ($ver in @('','2.0')) { $r=Nvidia-Case $ver $false;Check ($r.Errors -gt 0 -and $r.Stops -eq 0 -and $r.Data -eq 'current') 'unknown/changed NVIDIA driver blocks DRS replacement' }
$r=Nvidia-Case '1.0' $true
Check ($r.Errors -gt 0 -and $r.Data -eq 'current') 'failed NVIDIA service stop prevents DRS replacement'
$r=Nvidia-Case '1.0' $false
Check ($r.Errors -eq 0 -and $r.Data -eq 'original' -and $r.Starts -eq 1) 'compatible NVIDIA rollback copies verified backup and restarts service'
# Updating existing tools must never reapply Windows settings or replace initial backups.
$P3Root=Join-Path $work 'update-existing'
[void][IO.Directory]::CreateDirectory($P3Root)
$StateFile=Join-Path $P3Root 'state.json'
Write-JsonAtomic $StateFile @{RolledBack=$false;Original='keep'}
$stateBefore=[IO.File]::ReadAllText($StateFile)
$toolNames=@(($RollbackName+'.bat'),($GameName+'.bat'),($CheckName+'.bat'))
foreach ($name in $toolNames) {[IO.File]::WriteAllText((Join-Path $P3Root $name),'old')}
function Protect-BoostDirectory {}
function Wait-Key {}
function Install-Nested { [IO.File]::WriteAllText((Join-Path $P3Root $toolNames[0]),'partial');return $false }
$failed=$false;try {Update-InstalledTools} catch {$failed=$true}
Check ($failed -and @($toolNames | Where-Object {[IO.File]::ReadAllText((Join-Path $P3Root $_)) -ne 'old'}).Count -eq 0) 'failed helper update restores all prior script files'
function Install-Nested {foreach ($name in $toolNames) {[IO.File]::WriteAllText((Join-Path $P3Root $name),'new')};return $true}
Update-InstalledTools
Check (@($toolNames | Where-Object {[IO.File]::ReadAllText((Join-Path $P3Root $_)) -ne 'new'}).Count -eq 0) 'helper update replaces all installed tools'
Check ($stateBefore -ceq [IO.File]::ReadAllText($StateFile)) 'helper update leaves original state file byte-for-byte intact'
Check ($null -eq $script:BoostLock) 'helper update releases operation lock on success and failure'

return $script:RegressionChecks
