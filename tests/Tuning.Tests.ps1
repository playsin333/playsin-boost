$ErrorActionPreference='Stop'
$repo=Split-Path -Parent $PSScriptRoot
$work=Join-Path ([IO.Path]::GetTempPath()) ('boost-tuning-'+[guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($work)
$oldEnv=@($env:P3_NOMAIN,$env:P3_SELF,$env:SystemDrive,$env:ProgramData,$env:SystemRoot,$env:P3_ARG)
$script:TuningChecks=0
function Verify($Condition,$Message) {if (-not $Condition) {throw ('FAIL: '+$Message)};$script:TuningChecks++;Write-Host ('PASS: '+$Message)}
function Import-BodyFunctions($Body) {
    $t=$null;$e=$null;$a=[Management.Automation.Language.Parser]::ParseInput($Body,[ref]$t,[ref]$e)
    if ($e.Count) {throw 'Generated body syntax error'}
    foreach ($f in $a.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]},$false)) {
        . ([scriptblock]::Create(($f.Extent.Text -replace '^function\s+','function script:')))
    }
}
try {
    $env:P3_NOMAIN='1';$env:P3_SELF=Join-Path $repo 'PLAYSIN BOOST 3.0.bat';$env:SystemDrive=$work;$env:ProgramData=$work
    $raw=[IO.File]::ReadAllText($env:P3_SELF,[Text.Encoding]::UTF8)
    . ([scriptblock]::Create($raw.Replace("[Environment]::GetFolderPath('Desktop')",'$work')))
    Initialize-BoostGraphicsNative
    Verify ($null -ne ('P3Graphics' -as [type])) 'native bridge compiles without invoking Windows APIs'
    $script:Messages=@();$Count=@{OK=0;SKIP=0;ERR=0;INFO=0}
    function Log($Kind,$Text) {$script:Messages+=@{Kind=$Kind;Text=$Text};$Count[$Kind]++}
    function Section {}
    $P3Root=Join-Path $work 'state';[void][IO.Directory]::CreateDirectory($P3Root)
    $StateFile=Join-Path $P3Root 'state.json';$RegFile=Join-Path $P3Root 'registry.json'
    $GameFile=Join-Path $P3Root 'game.json';$GameFlag=Join-Path $P3Root 'stop.flag'
    $State=@{};$script:Registry=@{};$script:RawWrites=0;$script:RemoveFails=$false
    function Get-RegValue($Path,$Name) {return $script:Registry[$Path+'|'+$Name]}
    function Set-RawReg($Path,$Name,$Kind,$Value) {$script:RawWrites++;$script:Registry[$Path+'|'+$Name]=[pscustomobject]@{Kind=$Kind;Value=$Value}}
    function Remove-RawReg($Path,$Name) {if ($script:RemoveFails) {throw 'denied'};$script:RawWrites++;[void]$script:Registry.Remove($Path+'|'+$Name)}
    $nativePolicy=(Get-Command Get-GameDownloadPolicy).ScriptBlock
    # Resolve the real ADMX value name, not an assumed CSP-to-registry spelling.
    $env:SystemRoot=Join-Path $work 'Windows';[void][IO.Directory]::CreateDirectory((Join-Path $env:SystemRoot 'PolicyDefinitions'))
    $cv='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    Set-RawReg $cv 'CurrentBuildNumber' 'String' '26200';Set-RawReg $cv 'EditionID' 'String' 'Professional'
    $admx=Join-Path $env:SystemRoot 'PolicyDefinitions/DeliveryOptimization.admx'
    [IO.File]::WriteAllText($admx,'<policyDefinitions><policies><policy><elements><decimal valueName="DOPercentageMaxBackgroundBandwidth" /></elements></policy></policies></policyDefinitions>')
    Verify ((Get-GameDownloadPolicy).Name -eq 'DOPercentageMaxBackgroundBandwidth') 'bandwidth policy resolves an existing supported ADMX setting'
    Set-RawReg $cv 'EditionID' 'String' 'Core'
    Verify ($null -eq (Get-GameDownloadPolicy)) 'Home edition is not treated as a supported policy target'
    Set-RawReg $cv 'EditionID' 'String' 'Professional'
    [IO.File]::WriteAllText($admx,'<policyDefinitions/>')
    Verify ($null -eq (Get-GameDownloadPolicy)) 'absent ADMX capability does not create an ineffective policy'
    function Get-GameDownloadPolicy {return $null}
    function Get-RtssDirectory {return $null}
    $script:Inputs=New-Object 'Collections.Generic.Queue[string]'
    function Read-Line {return $script:Inputs.Dequeue()}
    function Ask {return $false}
    $ctx=@{OneDrive=@{Installed=$false;Block=''};GameRoots=@();Closable=@();MonitorLow=$false;IntelGen=0}
    foreach ($mode in @('Rec','Max','Manual')) {
        $script:Inputs.Enqueue('0')
        $a=Get-Answers @{IsNvidia=$false;IsWin11=$true} 'Strong' @{} $ctx $mode @()
        Verify ($a.FrameLimit.Value -eq 0 -and $script:Inputs.Count -eq 0) ($mode+' requires and retains an explicit zero FPS answer')
    }
    foreach ($bad in @('','-1','word','1001','1e2')) {$script:Inputs.Enqueue($bad)};$script:Inputs.Enqueue('120')
    $f=Select-FrameLimit @{IsNvidia=$false} $false
    Verify ($f.Value -eq 120 -and $f.Backend -eq 'Manual' -and $script:Inputs.Count -eq 0) 'invalid/empty FPS input cannot silently choose an unlimited or default cap'
    $script:Inputs.Enqueue('м');$f=Select-FrameLimit @{Refresh=@{Current=144;Max=165}} $false
    Verify ($f.Value -eq 144) 'monitor option uses current refresh when no refresh change is planned'
    $script:Inputs.Enqueue('M');$f=Select-FrameLimit @{Refresh=@{Current=144;Max=165}} $true
    Verify ($f.Value -eq 165) 'monitor option follows explicitly planned refresh change'
    $script:Inputs.Enqueue('м');$script:Inputs.Enqueue('0');$f=Select-FrameLimit @{} $false
    Verify ($f.Value -eq 0) 'unknown refresh requires another explicit FPS answer'
    Verify ((Get-FrameLimitText @{Value=0;Backend='Manual'}) -match '0.*ручная|ручная.*0') 'plan distinguishes an unapplied manual cap and explicit zero'
    $State=@{};$script:RawWrites=0
    Invoke-FrameLimit @{} @{Value=120;Backend='Manual'}
    Verify (-not $State.FrameLimitApplied -and $script:RawWrites -eq 0 -and $State.FrameLimit.Value -eq 120) 'unsupported backend records a manual action without pretending to apply a cap'
    # Exercise actual NVIDIA path with only driver import/export replaced.
    $DrsDir=Join-Path $work 'drs';[void][IO.Directory]::CreateDirectory($DrsDir)
    $NvDir=Join-Path $work 'nv';$NpiSrc=Join-Path $repo 'nvidia'
    $State=@{NvDrs=$true;NvSet=@('274197361|1|Power management')}
    function Save-NvidiaBackup {}
    function Import-NvAndCheck($Npi,$Nip,$Set) {$script:NvImported=@($Set);return @{Checked=$true;Bad=@()}}
    $gpu=@{IsNvidia=$true;Main=@{DriverVer='test'}}
    Invoke-FrameLimit $gpu @{Value=144;Backend='Nvidia'}
    Verify ($State.FrameLimitApplied -and $script:NvImported.Count -eq 1 -and $script:NvImported[0][1] -eq 0x10835002 -and $script:NvImported[0][2] -eq 144) 'NVIDIA FPS-only path imports just the requested limiter'
    Verify (@($State.NvSet).Count -eq 2 -and @($State.NvSet | Where-Object {$_ -like '274197361|*'}).Count -eq 1) 'FPS-only import preserves tracking of earlier NVIDIA changes'
    $script:ExportXml='<ArrayOfProfile />'
    function Export-NvCustom { $p=Join-Path $work 'export.nip';[IO.File]::WriteAllText($p,$script:ExportXml);return $p }
    $res=Test-NvSet 'unused' @(,@('Frame Rate Limiter',0x10835002,144))
    Verify (-not $res.Checked -or $res.Bad.Count -gt 0) 'missing nonzero driver cap is never verified as applied'
    $res=Test-NvSet 'unused' @(,@('Frame Rate Limiter',0x10835002,0))
    Verify ($res.Checked -and $res.Bad.Count -eq 0) 'valid empty export can verify the driver-default zero cap'
    $script:ExportXml='<broken';$res=Test-NvSet 'unused' @(,@('Frame Rate Limiter',0x10835002,0))
    Verify (-not $res.Checked) 'malformed export cannot verify even a zero cap'
    # Actual RTSS state journaling; native calls are represented by a driver value store.
    $script:Started=@()
    function Get-Process {return @()}
    function Start-Process {param($FilePath,$WorkingDirectory,$WindowStyle,$ErrorAction) $script:Started+=$FilePath}
    $rtss=Join-Path $work 'RTSS';[void][IO.Directory]::CreateDirectory($rtss)
    [IO.File]::WriteAllText((Join-Path $rtss 'RTSSHooks64.dll'),'test placeholder')
    [IO.File]::WriteAllText((Join-Path $rtss 'RTSS.exe'),'test placeholder')
    $State=@{};$script:RtssValue=75;$script:RtssWrites=0
    function Get-RtssFrameLimit {return $script:RtssValue}
    function Set-RtssFrameLimit($Directory,$Limit) {
        $saved=Read-Json $StateFile
        if (-not $saved.RtssFrameLimit) {throw 'RTSS write before backup'}
        $script:RtssWrites++;$script:RtssValue=$Limit
    }
    Invoke-FrameLimit @{} @{Value=0;Backend='RTSS';Directory=$rtss}
    Invoke-FrameLimit @{} @{Value=144;Backend='RTSS';Directory=$rtss}
    Verify ($State.RtssFrameLimit.Old -eq 75 -and $State.RtssFrameLimit.New -eq 144 -and $script:RtssValue -eq 144) 'RTSS repeat changes preserve the first cap for rollback'
    Undo-RtssFrameLimit $State
    Verify ($script:RtssValue -eq 75) 'RTSS rollback restores the original cap'
    $script:RtssValue=333;$before=$script:RtssWrites
    Undo-RtssFrameLimit $State
    Verify ($script:RtssWrites -eq $before -and $script:RtssValue -eq 333) 'later manual RTSS change is preserved by default'
    $State=@{};$savedSave=(Get-Command Save-State).ScriptBlock
    function Save-State {throw 'disk full'}
    $failed=$false;$before=$script:RtssWrites
    try {Invoke-FrameLimit @{} @{Value=60;Backend='RTSS';Directory=$rtss}} catch {$failed=$true}
    Verify ($failed -and $before -eq $script:RtssWrites) 'RTSS backup failure prevents a limiter write'
    Set-Item Function:Save-State $savedSave
    Import-BodyFunctions $CheckBody
    $Chk=@{Total=0;Fixed=0;Boot=0;Kept=0;Failed=@()};$Auto=$true
    $rtssState=Read-Json $StateFile;$before=$script:RtssWrites
    Check-RtssFrameLimit $rtssState
    Verify ($script:RtssWrites -eq $before -and $Chk.Kept -eq 1) 'automatic RTSS drift check never repairs a later user cap'
    $Auto=$false;Check-RtssFrameLimit $rtssState
    Verify ($script:RtssValue -eq 144 -and $Chk.Fixed -eq 1 -and (Read-Json $StateFile).RtssFrameLimit.Old -eq 75) 'manual RTSS repair restores requested cap while retaining original rollback value'
    # Actual GPU preference path preserves adjacent fields for all detected games.
    $script:Registry=@{};$script:RawWrites=0;$RegBackup=New-Object Collections.ArrayList;$RegIndex=@{};$State=@{}
    $profileKey='HKCU\Software\Microsoft\DirectX\UserGpuPreferences'
    Set-RawReg $profileKey 'C:\Games\one.exe' 'String' 'Other=keep;GpuPreference=1;AutoHDREnable=0;'
    function Get-GameExes {return @('C:\Games\one.exe')}
    function Get-HagsCapability {return @{Known=$false;Supported=$false;Enabled=$false}}
    Invoke-VideoTweaks @{HasDGpu=$true;MultiGpu=$true;IsWin11=$false;Build=26200;Main=@{Pnp='PCI\GPU'}} 'Strong' @{} @{KeepCapture=$true;MsiTweaks=$false}
    $profile=(Get-RegValue $profileKey 'C:\Games\one.exe').Value
    Verify ($profile -eq 'Other=keep;AutoHDREnable=0;GpuPreference=2;') 'legacy bulk GPU path preserves unrelated fields like per-game path'
    Verify ($null -eq (Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode')) 'unknown HAGS capability never forces a registry override'
    function Get-HagsCapability {return @{Known=$true;Supported=$true;Enabled=$false}}
    Invoke-VideoTweaks @{HasDGpu=$false;IsWin11=$false;Build=26200;Main=@{Pnp='PCI\GPU'}} 'Strong' @{} @{KeepCapture=$true;MsiTweaks=$false}
    Verify ((Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode').Value -eq 2) 'confirmed HAGS support allows the existing setting'
    $msi='HKLM\Test\MSI';$before=$script:RawWrites
    Set-DeviceMsiIfDeclared $msi $true 'test'
    Verify ($script:RawWrites -eq $before) 'missing MSI capability setting is not invented'
    Set-RawReg $msi 'MSISupported' 'DWord' 0;$before=$script:RawWrites
    Set-DeviceMsiIfDeclared $msi $false 'test'
    Verify ($script:RawWrites -eq $before) 'MSI stays driver-controlled without explicit permission'
    Set-DeviceMsiIfDeclared $msi $true 'test'
    Verify ((Get-RegValue $msi 'MSISupported').Value -eq 1) 'explicit MSI experiment remains available for an existing driver setting'
    function Get-RefreshRate {return @{Current=144;Max=144}}
    function Get-SchemeName {return 'daily'}
    function Get-GpuMsiState {return 'driver setting'}
    function Get-VbsState {return @{Running=$false;Hvci=$false}}
    function Get-StartupItems {return @()}
    $lag=Get-LagState @{}
    Verify ($lag['Аппаратное план. GPU'] -like '*запрошено*') 'diagnostics distinguish requested HAGS from driver-confirmed enablement'
    function Get-HagsCapability {return @{Known=$true;Supported=$true;Enabled=$true}}
    $lag=Get-LagState @{}
    Verify ($lag['Аппаратное план. GPU'] -like '*подтверждено*') 'diagnostics use actual driver scheduling state'
    # Compression repeats keep the first state instead of inverting the last change on rollback.
    $State=@{};$script:Compression=$true;$script:CompressionWrites=0
    function Get-MMAgent {return @{MemoryCompression=$script:Compression}}
    function Enable-MMAgent {$script:Compression=$true;$script:CompressionWrites++}
    function Disable-MMAgent {$script:Compression=$false;$script:CompressionWrites++}
    Invoke-MemoryTweaks @{RamGB=32} 'Strong' @{} @{MemoryCompression='Keep'}
    Verify ($script:Compression -and $script:CompressionWrites -eq 0) 'ordinary memory choice does not disable compression on high-RAM PCs'
    Invoke-MemoryTweaks @{RamGB=32} 'Strong' @{} @{MemoryCompression='Off'}
    Invoke-MemoryTweaks @{RamGB=32} 'Strong' @{} @{MemoryCompression='On'}
    Verify ($State.MemoryCompressionOriginal -eq $true -and $State.Mmc -eq 'on') 'repeat compression changes preserve the initial state'
    Undo-MemoryCompression $State
    Verify $script:Compression 'rollback returns initial compression after opposite repeat choices'
    $State=@{Mmc='off'};$script:Compression=$false
    Invoke-MemoryTweaks @{RamGB=32} 'Strong' @{} @{MemoryCompression='On'}
    Verify $State.MemoryCompressionOriginal 'legacy compression history is migrated without rebasing the original state'
    # Verify daily/game scheme ownership and explicit opt-out without native power calls.
    $State=@{OldScheme='OEM';NewScheme='old-boost';GameScheme='old-game'}
    $script:Active='OEM';$script:Created=@();$script:PowerWrites=@()
    function Get-ActiveScheme {return $script:Active}
    function Test-SchemeExists {param($Id) return ($Id -in @('OEM','old-boost','old-game'))}
    function New-OurScheme($Bases,$Name,$About) {
        $id='daily';if ($Name -like '*Игра от сети*') {$id='game'}
        $script:Created+=@{Id=$id;Bases=@($Bases)};return $id
    }
    function Set-SchemeAc($Id,$Values) {$script:PowerWrites+=@{Id=$Id;Values=@($Values)};return 0}
    function Invoke-Native($Exe,$ArgList) {if ($ArgList[0] -eq '/setactive') {$script:Active=$ArgList[1]};return @{Code=0;Out=''}}
    Invoke-Power @{} 'Strong' @{PowerStyle='Adaptive';GamePower=$true}
    Verify ($State.GamePowerEnabled -and $State.GameScheme -eq 'game' -and $State.NewScheme -eq 'daily' -and $State.OldScheme -eq 'OEM' -and $script:Active -eq 'daily') 'PC adaptive setup prepares a separate game scheme while retaining the daily and original schemes'
    Verify ($script:Created[1].Bases[0] -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' -and $script:PowerWrites[1].Values[0][2] -eq 5) 'game copy uses standard High Performance and an explicit CPU minimum of 5 percent'
    $State=@{OldScheme='OEM';NewScheme='old-boost';GameScheme='old-game'};$script:Created=@();$script:Active='OEM'
    Invoke-Power @{} 'Laptop' @{PowerStyle='Adaptive';GamePower=$false}
    Verify (-not $State.GamePowerEnabled -and $script:Created.Count -eq 1 -and $script:Active -eq 'daily') 'opting out never activates a stale game scheme or changes battery settings'
    $script:Scheduled=@()
    function Register-P3Task($Name,$Exe,$Arguments,$AtLogon,$Delay,$Description) {$script:Scheduled+=@{Name=$Name;Arguments=$Arguments;AtLogon=$AtLogon}}
    Register-GameRecoveryTask @{GameScheme='';GameDownloadPercent=10}
    Verify ($script:Scheduled.Count -eq 1 -and $script:Scheduled[0].AtLogon -and $script:Scheduled[0].Arguments -like '*EncodedCommand*') 'bandwidth-only game mode registers login recovery without requiring a game power scheme'
    # Real temporary JSON journal + a simulated registry, including partial failures and crash reset.
    Import-BodyFunctions $GameBody
    $StateFile=Join-Path $P3Root 'state.json';$GameFile=Join-Path $P3Root 'game.json';$GameFlag=Join-Path $P3Root 'stop.flag'
    $script:Registry=@{};$script:RawWrites=0;$script:Active='daily';$script:FailPower=$false;$script:Domain=$false
    function Get-GameDownloadPolicy {return @{Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization';Name='DOPercentageMaxBackgroundBandwidth'}}
    $dk='HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization';$dn='DOPercentageMaxBackgroundBandwidth'
    function Get-CimInstance {return @{PartOfDomain=$script:Domain}}
    function Get-ActiveScheme {return $script:Active}
    function Test-SchemeExists {return $true}
    function Test-OnAc {return $true}
    function Get-Process {return @()}
    function Invoke-Native($Exe,$ArgList) {
        if ($ArgList[0] -eq '/setactive') {if ($script:FailPower) {return @{Code=1;Out='denied'}};$script:Active=$ArgList[1]}
        return @{Code=0;Out=''}
    }
    $st=@{GameScheme='game';GamePowerEnabled=$true;NewScheme='daily';GameDownloadPercent=10;GameClose=@();GamePurge=$false;RamGB=32}
    Game-On $st
    $journal=Read-Json $GameFile
    Verify ($journal.DownloadPolicy.Applied -eq 10 -and $script:Active -eq 'game' -and (Get-RegValue $dk $dn).Value -eq 10) 'game start journals and applies transient downloads and power'
    $script:FailPower=$true;$failed=$false
    try {[void](Game-Off $st)} catch {$failed=$true}
    Verify ($failed -and (Test-Path -LiteralPath $GameFile) -and $null -eq (Get-RegValue $dk $dn)) 'power return failure keeps recovery journal after bandwidth was restored'
    $script:FailPower=$false;[void](Game-Off $st)
    Verify ($script:Active -eq 'daily' -and -not (Test-Path -LiteralPath $GameFile)) 'recovery retry returns original power and removes the journal'
    Game-On $st;$script:RemoveFails=$true;$failed=$false
    try {[void](Game-Off $st)} catch {$failed=$true}
    Verify ($failed -and (Test-Path -LiteralPath $GameFile)) 'failed bandwidth restoration keeps game recovery reachable'
    $script:RemoveFails=$false;[void](Game-Off $st)
    Game-On $st;Set-RawReg $dk $dn 'DWord' 33;[void](Game-Off $st)
    Verify ((Get-RegValue $dk $dn).Value -eq 33) 'later user bandwidth policy is preserved'
    $before=$script:RawWrites;Game-On $st
    Verify ($script:RawWrites -eq $before -and -not (Read-Json $GameFile).DownloadPolicy) 'existing bandwidth policy is not overwritten on next game start'
    [void](Game-Off $st);Remove-RawReg $dk $dn
    $script:Domain=$true;$before=$script:RawWrites;Game-On $st
    Verify ($script:RawWrites -eq $before) 'domain management prevents automatic bandwidth changes'
    [void](Game-Off $st);$script:Domain=$false
    $originalAtomic=(Get-Command Write-JsonAtomic).ScriptBlock
    function Write-JsonAtomic {throw 'journal cannot be saved'}
    $failed=$false;$before=$script:RawWrites
    try {Game-On $st} catch {$failed=$true}
    Verify ($failed -and $script:RawWrites -eq $before) 'game journal failure prevents the first transient mutation'
    Set-Item Function:Write-JsonAtomic $originalAtomic
    # Reset path runs on login only for a retained journal and does not reapply optimization.
    $reset=@{GameScheme='';GameDownloadPercent=10;GameClose=@();GamePurge=$false;RamGB=32}
    Write-JsonAtomic $StateFile $reset;Game-On $reset
    $script:Locks=0;$script:ResetLogs=0
    function Enter-BoostLock {$script:Locks++}
    function Write-GameLog {$script:ResetLogs++}
    $env:P3_ARG='reset';$code=Main;$after=$script:RawWrites;$code2=Main
    Verify ($code -eq 0 -and $code2 -eq 0 -and $script:RawWrites -eq $after -and $script:ResetLogs -eq 1 -and -not (Test-Path -LiteralPath $GameFile)) 'login reset restores a transient cap once and subsequent logins do not repeat it'
    [IO.File]::WriteAllText($GameFile,'null')
    $failed=$false;try {[void](Game-Off $reset)} catch {$failed=$true}
    Verify ($failed -and (Test-Path -LiteralPath $GameFile)) 'invalid game journal is retained instead of silently deleting recovery'
    Write-Host ('SUCCESS: '+$script:TuningChecks+' tuning checks; Windows commands and native calls were mocked, file journals were real.')
} finally {
    $env:P3_NOMAIN=$oldEnv[0];$env:P3_SELF=$oldEnv[1];$env:SystemDrive=$oldEnv[2];$env:ProgramData=$oldEnv[3];$env:SystemRoot=$oldEnv[4];$env:P3_ARG=$oldEnv[5]
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
