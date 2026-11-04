# Integration scenarios run the real setup coordinator with Windows I/O replaced.
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$text=[IO.File]::ReadAllText((Join-Path $root 'PLAYSIN BOOST 3.0.bat'),[Text.Encoding]::UTF8)
$loadText=$text.Replace("[Environment]::GetFolderPath('Desktop')", '$work')
. ([scriptblock]::Create($loadText))
$script:ScenarioChecks=0
function Check($Condition,$Message) {
    if (-not $Condition) { throw ('FAIL: '+$Message) }
    $script:ScenarioChecks++;Write-Host ('PASS: '+$Message)
}
function Run-Scenario([bool]$RecoveryFailure,[bool]$ModuleFailure,[bool]$Cancel,[bool]$Empty,[bool]$WithFps=$false) {
    $script:Trace=@();$script:SaveCount=0;$script:LockCount=0
    $script:Count=@{OK=0;SKIP=0;ERR=0;INFO=0}
    $script:State=@{}
    function Set-ConsoleLook {}
    function Test-Admin {return $true}
    function Test-SameUser {return $true}
    function Test-Unpacked {return $true}
    function Get-SystemInfo {return @{IsNvidia=$false;IsAmdGpu=$false;IsLaptop=$false;RamGB=16;Cpu='test';Name='Windows';Build=22631;Refresh=$null}}
    function Ask-Profile {return @{Prof='Strong';Flags=@{Video=$false;System=$false};Manual=$false}}
    function Get-Context {return @{OneDrive=@{Block=$false};GameRoots=@()}}
    function Get-Answers { $a=@{Junk=@();Light=$false;OneDrive=$false;Progs=@();GameClose=@();DefExcl=@()};if ($WithFps) {$a.FrameLimit=@{Value=144;Backend='Nvidia'}};return $a }
    function Get-SuggestedStartup {return @()}
    function Show-Answers {return @('test answers')}
    function Show-BoostPlan {}
    function Show-MaxWarning {}
    function Ask {return $false}
    function Ask-Opt {if ($Cancel) {return 3};return 1}
    function Select-BoostPlan {return @()}
    function Stop-Nothing($Message) {return 2}
    function Enter-BoostLock {$script:LockCount++}
    function Protect-BoostDirectory {}
    function Test-OldBackups {return 'fresh'}
    function Initialize-Backup {}
    function Save-State {$script:SaveCount++}
    function Install-Nested {return (-not $RecoveryFailure)}
    function Write-MeasureBefore {return @{}}
    function New-P3RestorePoint {return $true}
    function Write-HardwareLog {}
    function Write-LogFile {}
    function Log($Kind,$Message) {$script:Count[$Kind]++}
    function Invoke-SystemTweaks {$script:Trace+='system';if ($ModuleFailure) {Log 'ERR' 'simulated write rejected'}}
    function Invoke-Power {$script:Trace+='power'}
    function Invoke-FrameLimit {$script:Trace+='fps'}
    function Invoke-InterfaceTweaks {$script:Trace+='interface';if ($ModuleFailure) {Log 'ERR' 'simulated write rejected'}}
    function Invoke-AppearanceTweaks {$script:Trace+='appearance'}
    function Invoke-BrowserMemoryTweaks {$script:Trace+='browser-memory'}
    function Invoke-MemoryTweaks {$script:Trace+='memory'}
    function Invoke-KeyboardTweaks {$script:Trace+='keyboard'}
    function Invoke-BackgroundTweaks {$script:Trace+='privacy'}
    function Invoke-StartupTweaks {$script:Trace+='startup'}
    function Invoke-MouseMonitor {$script:Trace+='input'}
    function Invoke-NetTweaks {throw 'unselected module must never run'}
    function Invoke-SecurityTweaks {throw 'unselected module must never run'}
    function Invoke-Cleanup {throw 'unselected module must never run'}
    function Install-Tasks {$script:Trace+='infrastructure'}
    function Get-LagState {return @{}}
    function Show-BeforeAfter {}
    function Show-List {}
    function Get-ManualNotes {return @()}
    function Get-Hints {return @()}
    function Show-Final {}
    $P3Root=Join-Path $work ('setup-'+[guid]::NewGuid().ToString('N'))
    $LogPath=Join-Path $P3Root 'log.txt'
    $mode='Rec';if ($Empty) {$mode='Manual'}
    $thrown=$false;$result=$null
    try {$result=Invoke-Setup $mode 'Keep'} catch {$thrown=$true}
    return @{Thrown=$thrown;Result=$result;Trace=@($script:Trace);Saves=$script:SaveCount;Locks=$script:LockCount;State=$script:State}
}
$r=Run-Scenario $true $false $false $false
Check ($r.Thrown -and $r.Trace.Count -eq 0) 'missing recovery script blocks every tuning module'
$r=Run-Scenario $false $true $false $false
Check (-not $r.Thrown -and ($r.Trace -join ',') -eq 'interface,infrastructure') 'failed module stops later tuning modules'
Check ($r.State.RunStatus -eq 'Failed' -and $r.State.Results[0].Status -eq 'Failed') 'partial failure is persisted without a success claim'
$r=Run-Scenario $false $false $true $false
Check ($r.Result -eq 2 -and $r.Locks -eq 0 -and $r.Saves -eq 0 -and $r.Trace.Count -eq 0) 'cancel at preview makes no backup or settings changes'
$r=Run-Scenario $false $false $false $true
Check ($r.Result -eq 2 -and $r.Locks -eq 0 -and $r.Saves -eq 0) 'empty manual plan never starts setup'
$r=Run-Scenario $false $false $false $false
Check (-not $r.Thrown -and ($r.Trace -join ',') -eq 'interface,privacy,infrastructure') 'coordinator runs exactly the selected preset blocks'
Check ($r.State.RunStatus -eq 'Completed' -and $r.State.Results.Count -eq 2) 'completed run contains all selected module results'
Check ($r.State.Plan.Count -eq 2 -and $r.State.Preset -eq 'Keep') 'saved plan matches the reviewed preset'
$r=Run-Scenario $false $false $true $false $true
Check ($r.Result -eq 2 -and $r.Trace.Count -eq 0 -and $r.Saves -eq 0) 'cancelled FPS preview writes neither cap nor backup'
$r=Run-Scenario $false $false $false $false $true
Check (($r.Trace -join ',') -eq 'interface,privacy,fps,infrastructure' -and $r.State.Plan[-1] -eq 'frame-limit') 'confirmed explicit FPS cap appears in saved plan and executes exactly once'
# The default preview/report path must not call any mutating coordinator.
function Get-SystemInfo {return @{}}
function Get-AutoProfile {return 'Strong'}
function Get-Flags {return @{}}
function Show-Profile {}
function Get-CimInstance {return @()}
function Get-SchemeName {return 'Balanced'}
function Get-StartupItems {return @()}
function Wait-Key {}
function Set-Reg {throw 'diagnostics attempted a write'}
function Save-State {throw 'diagnostics attempted a backup write'}
function Enter-BoostLock {throw 'diagnostics attempted a write lock'}
Show-PcReport
Check $true 'PC report completes without calling mutation helpers'
return $script:ScenarioChecks
