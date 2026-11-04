$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$work=Join-Path ([IO.Path]::GetTempPath()) ('boost-after-report-'+[guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($work)
$previousEnv=@($env:P3_NOMAIN,$env:P3_SELF,$env:SystemDrive,$env:ProgramData)
$script:AfterChecks=0
function Check($Value,$Message) {if (-not $Value) {throw ('FAIL: '+$Message)};$script:AfterChecks++;Write-Host ('PASS: '+$Message)}
try {
    $path=Join-Path $root 'PLAYSIN BOOST 3.0.bat'
    $text=[IO.File]::ReadAllText($path,[Text.Encoding]::UTF8)
    $t=$null;$errors=$null
    [void][Management.Automation.Language.Parser]::ParseInput($text,[ref]$t,[ref]$errors)
    Check ($errors.Count -eq 0) 'BAT syntax'
    $env:P3_NOMAIN='1';$env:P3_SELF=$path;$env:SystemDrive=$work;$env:ProgramData=$work
    . ([scriptblock]::Create($text))
    foreach ($spec in @(@($RollbackBody,$false),@($GameBody,$false),@($CheckBody,$true))) {
        $generated=Get-NestedText 'test' $spec[0] $spec[1]
        $errors=$null;[void][Management.Automation.Language.Parser]::ParseInput($generated,[ref]$t,[ref]$errors)
        Check ($errors.Count -eq 0) 'generated helper syntax'
    }
    $P3Root=Join-Path $work 'installed';[void][IO.Directory]::CreateDirectory($P3Root)
    $StateFile=Join-Path $P3Root 'state.json'
    $checkPath=Join-Path $P3Root ($CheckName+'.bat')
    [IO.File]::WriteAllText($checkPath,"# BOOST_REPORT_READONLY_V1`n# BOOST_REPORT_ONCE_V1")
    $script:Exists=$false;$script:DeleteFails=$false;$script:ReadFails=$false;$script:Registered=@();$script:Removed=0
    function Get-ScheduledTask {param($TaskPath,$ErrorAction) if ($script:ReadFails) {throw 'task service unavailable'};if ($script:Exists) {return @{TaskName=$TaskAfter;State='Ready'}}}
    function Register-P3Task($Name,$Exe,$Arg,[bool]$AtLogon,[int]$Delay,$Desc) {$script:Exists=$true;$script:Registered+=@{Name=$Name;Arg=$Arg;AtLogon=$AtLogon;Delay=$Delay}}
    function Unregister-ScheduledTask {param($TaskName,$TaskPath,[switch]$Confirm,$ErrorAction) if ($script:DeleteFails) {throw 'cannot delete task'};$script:Exists=$false;$script:Removed++}
    Set-AfterReportTask $true
    Check ($script:Exists -and $script:Registered[-1].Delay -eq 5 -and $script:Registered[-1].AtLogon -and $script:Registered[-1].Arg -match 'after') 'enabled report registers at logon with five-minute delay'
    Set-AfterReportTask $false
    Check (-not $script:Exists -and $script:Removed -eq 1) 'disabling removes previous report task'
    Set-AfterReportTask $false
    Check (-not $script:Exists -and $script:Removed -eq 1) 'disabling an absent report is idempotent'
    Write-JsonAtomic $StateFile @{RolledBack=$false;Initial='keep';AfterReportEnabled=$false}
    Set-AfterReportPreference $true
    Check ((Read-Json $StateFile).AfterReportEnabled -and (Read-Json $StateFile).Initial -eq 'keep') 'enabling persists preference without replacing other state'
    Set-AfterReportPreference $false
    Check (-not (Read-Json $StateFile).AfterReportEnabled -and -not $script:Exists) 'disabling persists preference and removes task'
    $script:Exists=$true;$script:DeleteFails=$true
    $before=[IO.File]::ReadAllText($StateFile)
    $failed=$false;try {Set-AfterReportPreference $false} catch {$failed=$true}
    Check ($failed -and $before -ceq [IO.File]::ReadAllText($StateFile)) 'task deletion failure is reported without claiming saved preference'
    $script:DeleteFails=$false;$script:Exists=$false
    $savedFunction=(Get-Command Save-StateObj).ScriptBlock
    function Save-StateObj {throw 'disk full'}
    $failed=$false;try {Set-AfterReportPreference $true} catch {$failed=$true}
    Check ($failed -and -not $script:Exists -and $before -ceq [IO.File]::ReadAllText($StateFile)) 'state save failure restores previous task on/off behavior'
    Set-Item Function:Save-StateObj $savedFunction
    [IO.File]::WriteAllText($checkPath,'old auto-repair script')
    $failed=$false;try {Set-AfterReportTask $true} catch {$failed=$true}
    Check ($failed -and -not $script:Exists) 'old repair helper cannot be scheduled as a read-only report'
    $script:ReadFails=$true;$registeredBefore=$script:Registered.Count
    $failed=$false;try {Set-AfterReportPreference $false} catch {$failed=$true}
    Check ($failed -and $script:Registered.Count -eq $registeredBefore -and $null -eq $script:BoostLock) 'task service failure is visible and lock is released'
    # A queued task checks the disabled preference before measurements or registry reads.
    $result=& {
        $ast=[Management.Automation.Language.Parser]::ParseInput($CheckBody,[ref]$t,[ref]$errors)
        foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]},$false)) {. ([scriptblock]::Create($fn.Extent.Text))}
        $Auto=$true
        function Test-Admin {return $true}
        function Set-NoQuickEdit {}
        function Show-Head {}
        function Read-Json {return [pscustomobject]@{RolledBack=$false;AfterReportEnabled=$false}}
        function Write-Measure {throw 'disabled task must not measure'}
        function Show-DriftReport {throw 'disabled task must not report'}
        Main
    }
    Check ($result -eq 0) 'disabled preference suppresses an already queued automatic report'
    # Exercise actual claim logic and repeated starts using real state files.
    $script:ReadFails=$false;$script:DeleteFails=$false
    $LogPath=$null;$LogCopy=$null
    [IO.File]::WriteAllText($checkPath,"# BOOST_REPORT_READONLY_V1`n# BOOST_REPORT_ONCE_V1")
    $RegFile=Join-Path $P3Root 'registry.json';Write-JsonAtomic $RegFile @{Items=@();Marker='keep-registry'}
    $registryBefore=[IO.File]::ReadAllText($RegFile)
    function Run-AutoAttempt([bool]$FailReport=$false) {
        $ast=[Management.Automation.Language.Parser]::ParseInput($CheckBody,[ref]$t,[ref]$errors)
        foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]},$false)) {. ([scriptblock]::Create($fn.Extent.Text))}
        $Auto=$true
        function Test-Admin {return $true}
        function Set-NoQuickEdit {}
        function Show-Head {}
        function Wait-Close {}
        function Write-Measure {$script:Measurements++;if ($FailReport) {throw 'report failed'}}
        function Show-DriftReport {$script:Reports++}
        Main
    }
    Write-JsonAtomic $StateFile @{RolledBack=$false;Initial='keep';AfterReportEnabled=$true}
    $script:Exists=$true;$script:Measurements=0;$script:Reports=0
    [void](Run-AutoAttempt);[void](Run-AutoAttempt)
    Check ($script:Measurements -eq 1 -and $script:Reports -eq 1) 'two automatic starts produce only one report'
    Check (-not $script:Exists -and -not (Read-Json $StateFile).AfterReportEnabled) 'one-shot report removes task and persists consumed state'
    Check ((Read-Json $StateFile).Initial -eq 'keep' -and $registryBefore -ceq [IO.File]::ReadAllText($RegFile)) 'one-shot bookkeeping preserves optimization state and registry backup'
    Set-AfterReportPreference $true
    [void](Run-AutoAttempt);[void](Run-AutoAttempt)
    Check ($script:Reports -eq 2 -and -not $script:Exists) 'explicit rearm permits exactly one further report'
    Write-JsonAtomic $StateFile @{RolledBack=$false;AfterReportEnabled=$true}
    $script:Exists=$true;$script:Measurements=0;$script:Reports=0
    $failed=$false;try {[void](Run-AutoAttempt $true)} catch {$failed=$true}
    [void](Run-AutoAttempt)
    Check ($failed -and $script:Measurements -eq 1 -and -not $script:Exists) 'report failure does not cause a new report on every login'
    Write-JsonAtomic $StateFile @{RolledBack=$false;AfterReportEnabled=$true}
    $script:Exists=$true;$script:DeleteFails=$true;$script:Measurements=0;$script:Reports=0
    [void](Run-AutoAttempt);[void](Run-AutoAttempt)
    Check ($script:Reports -eq 1 -and $script:Exists -and -not (Read-Json $StateFile).AfterReportEnabled) 'failed task deletion still cannot repeat a consumed report'
    $script:DeleteFails=$false
    Write-JsonAtomic $StateFile @{RolledBack=$false;AfterReportEnabled=$true}
    $script:Exists=$true;$script:Measurements=0
    $originalSave=(Get-Command Save-StateObj).ScriptBlock
    function Save-StateObj {throw 'disk full'}
    $failed=$false;try {[void](Run-AutoAttempt)} catch {$failed=$true}
    Set-Item Function:Save-StateObj $originalSave
    Check ($failed -and $script:Measurements -eq 0 -and $script:Exists -and $null -eq $script:BoostLock) 'claim save failure prevents report execution and releases lock'
    Write-Host ('SUCCESS: '+$script:AfterChecks+' focused checks; Windows tasks were mocked.')
} finally {
    if (Get-Command Exit-BoostLock -ErrorAction SilentlyContinue) {Exit-BoostLock}
    $env:P3_NOMAIN=$previousEnv[0];$env:P3_SELF=$previousEnv[1];$env:SystemDrive=$previousEnv[2];$env:ProgramData=$previousEnv[3]
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
