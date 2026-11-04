$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'PLAYSIN BOOST 3.0.bat'
$work = Join-Path ([IO.Path]::GetTempPath()) ('boost-test-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($work)
$script:Checks = 0
function Assert($Condition, [string]$Message) {
    if (-not $Condition) { throw ('FAIL: ' + $Message) }
    $script:Checks++
    Write-Host ('PASS: ' + $Message)
}
function Parse-Text([string]$Text) {
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw ($errors | ForEach-Object { $_.Message + ' line ' + $_.Extent.StartLineNumber }) }
    return $ast
}
function Import-Functions([string]$Text) {
    $ast = Parse-Text $Text
    foreach ($fn in $ast.FindAll({ param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
        . ([scriptblock]::Create(($fn.Extent.Text -replace '^function\s+', 'function global:')))
    }
}
$oldNoMain = $env:P3_NOMAIN; $oldSelf = $env:P3_SELF; $oldDrive = $env:SystemDrive; $oldProgramData = $env:ProgramData
try {
    $text = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    $ast = Parse-Text $text
    Assert ($null -ne $ast) 'hybrid BAT parses as PowerShell'
    Assert ($text -notmatch 'del "%~f0"') 'launcher remains after use'
    Assert ($text -notmatch '(?m)^\s*\.\s+\(Join-Path') 'hybrid BAT does not load separate runtime modules'
    $env:P3_NOMAIN = '1'; $env:P3_SELF = $path; $env:SystemDrive = $work; $env:ProgramData = $work
    $loadText = $text.Replace("[Environment]::GetFolderPath('Desktop')", '$work')
    . ([scriptblock]::Create($loadText))
    $LogPath = $null; $LogCopy = $null
    foreach ($name in @('Invoke-SystemTweaks','Invoke-SecurityTweaks','Invoke-Power','Invoke-Timer','Invoke-VideoTweaks','Invoke-Nvidia','Apply-AmdProfile','Invoke-NetTweaks','Invoke-BackgroundTweaks','Invoke-Apps','Invoke-MouseMonitor','Invoke-Programs','Invoke-Cleanup','Get-GameExes','Find-JunkApps','Disable-StartupItem')) {
        Assert ($null -ne (Get-Command $name -ErrorAction SilentlyContinue)) ('original feature retained: ' + $name)
    }
    foreach ($body in @($RollbackBody, $GameBody, $CheckBody)) { Assert ($null -ne (Parse-Text $body)) 'embedded body syntax' }
    foreach ($spec in @(@('rollback',$RollbackBody,$false), @('game',$GameBody,$false), @('check',$CheckBody,$true))) {
        $generated = Get-NestedText $spec[0] $spec[1] $spec[2]
        Assert ($null -ne (Parse-Text $generated)) ('generated script syntax: ' + $spec[0])
        Assert ($generated.Contains('function Write-JsonAtomic')) 'atomic backup helper embedded'
        Assert ($generated.Contains('function Enter-BoostLock')) 'operation lock helper embedded'
    }
    $sys = @{ IsNvidia=$false; IsAmdGpu=$true }
    $plan = @(Get-BoostPlan $sys 'Keep')
    Assert (@($plan | Where-Object { $_.Id -eq 'amd' }).Count -eq 1) 'AMD remains available'
    Assert (@($plan | Where-Object { $_.Id -eq 'nvidia' }).Count -eq 0) 'NVIDIA omitted on AMD machine'
    Assert (@($plan | Where-Object { $_.Pre -and $_.Id -in @('security','network','apps','cleanup','timer') }).Count -eq 0) 'default preset avoids additional/removal blocks'
    $max = @(Get-BoostPlan @{IsNvidia=$true;IsAmdGpu=$true} 'Max')
    Assert ($max.Count -eq 26 -and @($max | Where-Object { -not $_.Pre }).Count -eq 0) 'all 26 original/split blocks available in maximum'
    $game = @(Get-BoostPlan $sys 'Gaming' | Where-Object { $_.Pre })
    Assert (@($game.Id) -contains 'video' -and @($game.Id) -contains 'game-profiles' -and @($game.Id) -notcontains 'amd') 'gaming preset selects Windows/game profiles without global driver quality changes'
    $script:BoostCatalog = $max
    $script:Answers = New-Object 'System.Collections.Generic.Queue[string]'
    function Read-Line { return $script:Answers.Dequeue() }
    $script:Answers.Enqueue('0')
    Assert (@(Select-BoostPlan $max $true).Count -eq 0) 'manual empty choice executes no modules'
    $script:Answers.Enqueue((@($max | Where-Object { $_.Id -in @('system','network','cleanup') } | ForEach-Object { $_.N }) -join ' '))
    $selected = @(Select-BoostPlan @() $true)
    Assert (($selected.Id -join ',') -eq 'system,network,cleanup') 'manual selection uses exact block ids'
    $script:Answers.Enqueue([string](@($max | Where-Object { $_.Id -eq 'nvidia' })[0].N))
    $selected = @(Select-BoostPlan @($max[0]) $false)
    Assert ($selected[0].Id -eq 'nvidia') 'editing preset can add previously unselected block'
    $file = Join-Path $work 'atomic.json'
    Write-JsonAtomic $file @{Value=1}
    Write-JsonAtomic $file @{Value=2}
    Assert ((Read-Json $file).Value -eq 2) 'atomic write replaces current JSON'
    Assert ((Read-Json ($file + '.bak')).Value -eq 1) 'previous JSON is retained'
    Assert (@(Get-ChildItem $work -Filter '*.tmp').Count -eq 0) 'temporary backup files cleaned up'
    [IO.File]::WriteAllText($file, '{broken')
    $caught = $false; try { [void](Read-Json $file) } catch { $caught = $true }
    Assert $caught 'corrupt current backup fails closed instead of silently using stale copy'
    $RegFile = Join-Path $work 'registry.json'
    $RegBackup = New-Object System.Collections.ArrayList
    $RegIndex = @{}; $RegNoFix = $false; $RegNote = 'test'
    $script:Values = @{ 'HKCU\Test|Value' = [pscustomobject]@{ Kind='DWord'; Value=7 } }
    $script:Writes = 0
    function Get-RegValue($Key,$Name) { return $script:Values[$Key+'|'+$Name] }
    function Set-RawReg($Key,$Name,$Kind,$Value) { $script:Writes++; $script:Values[$Key+'|'+$Name]=[pscustomobject]@{Kind=$Kind;Value=$Value} }
    Set-Reg 'HKCU\Test' 'Value' 'DWord' 10
    Set-Reg 'HKCU\Test' 'Value' 'DWord' 20
    $saved = Read-Json $RegFile
    Assert ($saved.Items.Count -eq 1 -and $saved.Items[0].Value -eq 7 -and $saved.Items[0].NewValue -eq 20) 'repeat application preserves initial value for rollback'
    $originalAtomic = (Get-Command Write-JsonAtomic).ScriptBlock
    function Write-JsonAtomic { throw 'simulated disk full' }
    $before = $script:Writes
    $caught = $false; try { Set-Reg 'HKCU\Test' 'Other' 'DWord' 1 } catch { $caught=$true }
    Assert ($caught -and $script:Writes -eq $before) 'backup failure prevents registry mutation'
    Set-Item Function:Write-JsonAtomic $originalAtomic
    $P3Root = Join-Path $work 'lock'
    Enter-BoostLock
    $held = $script:BoostLock; $script:BoostLock = $null
    $caught = $false; try { Enter-BoostLock } catch { $caught=$true }
    $script:BoostLock = $held; Exit-BoostLock
    Assert $caught 'concurrent operation cannot acquire backup lock'
    Enter-BoostLock; Exit-BoostLock
    Assert ($null -eq $script:BoostLock) 'released lock can be acquired again'
    # Automatic answers must not quietly select deletions or antivirus exclusions.
    $ctx=@{OneDrive=@{Installed=$true;Block='';Setups=@()};GameRoots=@('C:\Games');Closable=@();MonitorLow=$true;IntelGen=7}
    $hw=@{IsWin11=$true;IsNvidia=$false}
    function Find-JunkApps { return @(@{Title='Example';Name='Example';Packages=@()}) }
    $script:Answers.Enqueue('0') # Mandatory explicit FPS answer, even in Max.
    $answers=Get-Answers $hw 'Strong' @{} $ctx 'Max' @('apps','defender')
    Assert (@($answers.Junk).Count -eq 0 -and @($answers.DefExcl).Count -eq 0 -and -not $answers.Light) 'automatic maximum never preselects app removal or Defender exclusions'
    Assert (-not $answers.VbsOff -and -not $answers.Spectre -and -not $answers.Timer) 'unselected security and timer blocks do not request disabling protection'
    # Rollback verifies the saved value and handles later manual changes explicitly.
    Import-Functions $RollbackBody
    function Remove-RawReg($Key,$Name) { $script:Writes++; [void]$script:Values.Remove($Key+'|'+$Name) }
    $entry=[pscustomobject]@{Path='HKCU\Test';Name='Value';Existed=$true;Kind='DWord';Value=7;NewKind='DWord';NewValue=20;Note='test'}
    function Ask { return $false }
    $script:Values['HKCU\Test|Value']=[pscustomobject]@{Kind='DWord';Value=20}
    Undo-Registry @{Items=@($entry)}
    Assert ($script:Values['HKCU\Test|Value'].Value -eq 7) 'registry rollback restores and verifies original data'
    $script:Values['HKCU\Test|Value']=[pscustomobject]@{Kind='DWord';Value=99}
    $before=$script:Writes
    Undo-Registry @{Items=@($entry)}
    Assert ($script:Writes -eq $before -and $script:Values['HKCU\Test|Value'].Value -eq 99) 'rollback keeps subsequent user change by default'
    function Ask { return $true }
    Undo-Registry @{Items=@($entry)}
    Assert ($script:Values['HKCU\Test|Value'].Value -eq 7) 'explicit rollback choice can restore over later change'
    $before=$script:Writes
    Undo-Registry @{Items=@($entry)}
    Assert ($script:Writes -eq $before) 'repeated registry rollback leaves already-restored value alone'

    # Load the original game handlers without running their entry point.
    Import-Functions $GameBody
    $GameFile = Join-Path $work 'game.json'
    Write-JsonAtomic $GameFile @{ OldScheme='before-game' }
    $script:ActiveScheme = 'game'; $script:SwitchedTo = ''
    function Get-ActiveScheme { return $script:ActiveScheme }
    function Test-SchemeExists($Scheme) { return [bool]$Scheme }
    function Invoke-Native($Exe,$ArgList) { if ($ArgList[0] -eq '/setactive') { $script:SwitchedTo = $ArgList[1]; $script:ActiveScheme=$ArgList[1] }; return @{Code=0;Out=''} }
    [void](Game-Off @{GameScheme='game';NewScheme='boost'})
    Assert ($script:SwitchedTo -eq 'before-game') 'game mode restores actual preceding scheme'
    Write-JsonAtomic $GameFile @{ OldScheme='before-game' }
    $script:ActiveScheme='user-choice';$script:SwitchedTo=''
    [void](Game-Off @{GameScheme='game';NewScheme='boost'})
    Assert ($script:SwitchedTo -eq '') 'game mode respects later manual power change'
    Import-Functions $CheckBody
    $script:Chk = @{Total=0;Fixed=0;Boot=0;Kept=0;Failed=@()}
    $script:Auto=$true
    $script:ReportLog=@()
    function Log($Kind,$Message) { $script:ReportLog += $Message }
    function Test-Admin { return $true }
    function Set-NoQuickEdit {}
    function Show-Head {}
    function Write-Measure {}
    function Wait-Close {}
    function Test-RegItem { return $false }
    function Get-ScheduledTask { return @{State='Ready'} }
    function Get-AppxPackage { return @(@{Name='restored-app'}) }
    function Set-RegItemNew { throw 'report must never repair registry' }
    function Remove-AppxPackage { throw 'report must never remove apps' }
    function Add-MpPreference { throw 'report must never add exclusions' }
    function Get-MpPreference { return @{ScanAvgCPULoadFactor=50;ExclusionPath=@()} }
    $StateFile=Join-Path $work 'check-state.json'; $RegFile=Join-Path $work 'check-registry.json'
    Write-JsonAtomic $StateFile @{RolledBack=$false;RemovedPkgs=@('App');Tasks=@('\Test\|Task');DefenderSet=$true;DefExcl=@('C:\Games')}
    Write-JsonAtomic $RegFile @{Items=@(@{Path='HKCU\Test';Name='V';NewKind='DWord';NewValue=1;Note='test'})}
    $snapshot=[IO.File]::ReadAllText($StateFile)
    $result=Main
    $afterState=Read-Json $StateFile
    Assert ($result -eq 0 -and -not $afterState.AfterReportEnabled -and $afterState.DefenderSet -and $afterState.RemovedPkgs[0] -eq 'App') 'automatic self-check consumes its one-shot flag without reapplying settings'
    Assert (@($script:ReportLog | Where-Object { $_ -match 'Отличается|Снова установлено|Нет исключения' }).Count -ge 4) 'automatic self-check reports drift including restored apps and exclusions'
    $script:Checks += & (Join-Path $PSScriptRoot 'Setup.Tests.ps1')
    $script:Checks += & (Join-Path $PSScriptRoot 'Startup.Tests.ps1')
    $script:Checks += & (Join-Path $PSScriptRoot 'Regression.Tests.ps1')
    $script:Checks += & (Join-Path $PSScriptRoot 'Product.Tests.ps1')
    $script:Checks += & (Join-Path $PSScriptRoot 'Audit.Tests.ps1')
    $script:Checks += & (Join-Path $PSScriptRoot 'Checker.Tests.ps1')
    Write-Host ('SUCCESS: ' + $script:Checks + ' checks. Windows system commands were mocked.')
} finally {
    if (Get-Command Exit-BoostLock -ErrorAction SilentlyContinue) { Exit-BoostLock }
    $env:P3_NOMAIN=$oldNoMain; $env:P3_SELF=$oldSelf; $env:SystemDrive=$oldDrive; $env:ProgramData=$oldProgramData
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
