$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$raw=[IO.File]::ReadAllText((Join-Path $root 'PLAYSIN BOOST 3.0.bat'),[Text.Encoding]::UTF8)
. ([scriptblock]::Create($raw.Replace("[Environment]::GetFolderPath('Desktop')", '$work')))
$script:ProductChecks=0
function Check($Value,$Message) { if (-not $Value) {throw ('FAIL: '+$Message)};$script:ProductChecks++;Write-Host ('PASS: '+$Message) }
foreach ($preset in @('Keep','Light','Gaming')) {
 $plan=@(Get-BoostPlan @{WeakRam=$false;WeakCpu=@{Weak=$false};IsAmdGpu=$true} $preset | Where-Object {$_.Pre})
 Check (@($plan.Id | Where-Object {$_ -in @('system','input','keyboard','amd','nvidia','global-timer','storage')}).Count -eq 0) ($preset+' preserves mouse and excludes global quality/legacy system overrides')
}
$weak=@(Get-BoostPlan @{WeakRam=$true;WeakCpu=@{Weak=$false}} 'Keep' | Where-Object {$_.Pre})
Check (@($weak.Id) -contains 'browser-memory' -and @($weak.Id) -contains 'appearance') 'limited RAM influences automatic recommendations'
Check (Test-ProtectedStartup @{Name='SecurityHealth';Command='security.exe'}) 'security startup is protected'
Check (Test-ProtectedStartup @{Name='RtkAudUService';Command='audio.exe'}) 'hardware startup is protected'
Check (-not (Test-ProtectedStartup @{Name='Unknown';Command='unknown.exe'})) 'unknown startup can be chosen explicitly'
Check ((Get-StartupDescription @{Name='Steam';Command='steam.exe'}) -match 'лаунчер') 'known startup purpose explained'
Check ((Get-GpuPreference 'Other=abc;GpuPreference=1;More=xyz;' 2) -eq 'Other=abc;More=xyz;GpuPreference=2;') 'game GPU preference preserves unrelated settings'
$script:Specs=@();$script:RegWrites=@()
function Apply-Reg($Title,$Values) {$script:Specs+=$Values}
$script:GpuValue='Other=abc;GpuPreference=1;'
function Get-RegValue {return @{Value=$script:GpuValue}}
function Set-Reg($Path,$Name,$Kind,$Value) {$script:RegWrites+=@{Path=$Path;Name=$Name;Value=$Value};$script:GpuValue=$Value}
Invoke-GameProfiles @(@{Path='C:\Games\game.exe';HighPriority=$false;PreferGpu=$true})
Check ($script:Specs.Count -eq 0 -and $script:RegWrites.Count -eq 1 -and $script:RegWrites[0].Value -eq 'Other=abc;GpuPreference=2;') 'per-game GPU selection does not set unwanted priority'
$script:RegWrites=@();Invoke-GameProfiles @()
Check ($script:RegWrites.Count -eq 0) 'empty game selection writes nothing'
# Real scoped Appx wrapper, with the OS cmdlets mocked as a removable package store.
$script:Packages=@(@{PackageFullName='Example_1'});$script:AppCalls=@();$script:Recorded=@();$script:Errors=0
function Get-AppxPackage {param($Name,[switch]$AllUsers,$ErrorAction) $script:AppCalls+=('query:'+ [bool]$AllUsers);return $script:Packages}
function Remove-AppxPackage {param($Package,[switch]$AllUsers,$ErrorAction) $script:AppCalls+=('remove:'+ [bool]$AllUsers);$script:Packages=@()}
function Get-AppxProvisionedPackage {param([switch]$Online,$ErrorAction) $script:AppCalls+='provision-query';return @(@{DisplayName='Example';PackageName='Example_provision'})}
function Remove-AppxProvisionedPackage {param([switch]$Online,$PackageName,$ErrorAction) $script:AppCalls+='provision-remove'}
function Add-StateList($Key,$Value) {$script:Recorded+=$Key+':'+$Value}
function Log($Kind,$Message) {if ($Kind -eq 'ERR') {$script:Errors++}}
Check (Remove-JunkApp @{Name='Example';Title='Example';AllUsers=$false}) 'current-user Appx removal succeeds'
Check (@($script:AppCalls | Where-Object {$_ -match 'True|provision'}).Count -eq 0) 'current-user removal never calls AllUsers or provisioning APIs'
$script:Packages=@(@{PackageFullName='Example_1'});$script:AppCalls=@()
Check (Remove-JunkApp @{Name='Example';Title='Example';AllUsers=$true}) 'all-user removal succeeds when explicitly selected'
Check (@($script:AppCalls) -contains 'remove:True' -and @($script:AppCalls) -contains 'provision-remove') 'explicit all-user removal includes provisioning'
Check (Test-RemovalAllUsers @{RemovedPkgs=@('Example')} 'Example') 'legacy removal history keeps its original all-user scope'
Check (-not (Test-RemovalAllUsers @{RemovalScopeVersion=1;RemovedAllUsersPkgs=@()} 'Example')) 'new current-user history does not expand scope'
Check (Test-RemovalAllUsers @{RemovalScopeVersion=1;RemovedAllUsersPkgs=@('Example')} 'Example') 'mixed history retains explicit all-user scope'
$script:Packages=@(@{PackageFullName='Example_1'});$script:AppCalls=@()
function Remove-AppxPackage {param($Package,[switch]$AllUsers,$ErrorAction) $script:AppCalls+=('fail:'+ [bool]$AllUsers);throw 'access denied'}
Check (-not (Remove-JunkApp @{Name='Example';Title='Example';AllUsers=$true})) 'Appx denial is reported as failure'
Check (($script:AppCalls | Where-Object {$_ -eq 'fail:False'}).Count -eq 0) 'all-user denial never silently falls back to another scope'
function Add-StateList {throw 'backup full'}
$script:AppCalls=@()
Check (-not (Remove-JunkApp @{Name='Example';Title='Example';AllUsers=$false}) -and $script:AppCalls.Count -eq 0) 'history failure blocks irreversible app removal'
# Quality options must not affect filtering/tessellation when explicitly kept.
$script:AmdWrites=@()
function Get-AmdGpuKeys {return @(@{Key='fake';Title='AMD'})}
function Set-AmdKmd($Key,$Name,$Value) {$script:AmdWrites+=$Name;return $true}
function Set-AmdUmd($Key,$Name,$Value) {$script:AmdWrites+=$Name;return $true}
[void](Apply-AmdProfile $true $false $false)
Check (@($script:AmdWrites | Where-Object {$_ -match 'TFQ|SurfaceFormat|Tessellation'}).Count -eq 0) 'AMD preserved-quality option excludes filtering and tessellation writes'
$script:AmdWrites=@();[void](Apply-AmdProfile $true $false $true)
Check (@($script:AmdWrites) -contains 'TFQ' -and @($script:AmdWrites) -contains 'Tessellation') 'original AMD quality settings remain available explicitly'
# Failed game-mode power restoration retains its recovery file.
$t=$null;$e=$null;$ast=[Management.Automation.Language.Parser]::ParseInput($GameBody,[ref]$t,[ref]$e)
foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]},$false)) {if ($fn.Name -ne 'Main') {. ([scriptblock]::Create($fn.Extent.Text))}}
$GameFile=Join-Path $work 'product-game.json';Write-JsonAtomic $GameFile @{OldScheme='before'}
function Get-ActiveScheme {return 'game'}
function Test-SchemeExists {return $true}
function Invoke-Native {return @{Code=1;Out='failed'}}
$caught=$false;try {[void](Game-Off @{GameScheme='game';NewScheme='boost'})} catch {$caught=$true}
Check ($caught -and (Test-Path -LiteralPath $GameFile)) 'failed game restoration keeps recovery state'
# New defaults do not purge memory or force-close programs implicitly.
Check ($GameBody -match '\$purge = \(\$St.GamePurge -and') 'game memory purge requires explicit permission'
# Adaptive power does not touch the legacy USB/hibernation path and retains old scheme ownership.
$script:PowerActive='legacy';$script:PowerCalls=@();$script:PowerRows=@();$script:Bases=@()
$State=@{OldScheme='original';NewScheme='legacy';GameScheme='old-game'}
function Add-StateList($Name,$Value) {$script:Recorded+=($Name+':'+$Value)}
function Save-State {}
function Get-ActiveScheme {return $script:PowerActive}
function Test-SchemeExists($Id) {return ($Id -eq 'original')}
function New-OurScheme($Bases,$Name,$About) {$script:Bases=$Bases;return 'adaptive'}
function Set-SchemeAc($Id,$Values) {$script:PowerRows=$Values;return 0}
function Invoke-Native($Exe,$ArgList) {$script:PowerCalls+=($ArgList -join ' ');if ($ArgList[0] -eq '/setactive') {$script:PowerActive=$ArgList[1]};return @{Code=0;Out=''}}
Invoke-Power @{} 'Strong' @{PowerStyle='Adaptive'}
Check ($script:Bases[0] -eq 'original' -and $State.OldScheme -eq 'original') 'adaptive plan uses recorded original source and keeps original rollback scheme'
Check ($script:PowerRows.Count -eq 1 -and $script:PowerRows[0][2] -eq 5 -and ($script:PowerCalls -join '|') -eq '/setactive adaptive') 'adaptive power sets CPU minimum 5 percent without USB or hibernation commands'
Check (@($script:Recorded) -contains 'OwnedSchemes:legacy' -and @($script:Recorded) -contains 'OwnedSchemes:old-game') 'switching power styles retains ownership of previous plans for rollback'
# Exercise actual game closure behavior, rather than just checking its text.
$script:CloseRequests=0;$script:Forced=0
$proc=New-Object PSObject -Property @{ProcessName='Zoom';Id=456;HasExited=$false}
$proc | Add-Member -MemberType ScriptMethod -Name CloseMainWindow -Value {$script:CloseRequests++;return $false}
function Get-Process {return @($proc)}
function Stop-Process {$script:Forced++}
function Start-Sleep {}
function Test-OnAc {return $false}
function Test-SchemeExists {return $true}
Game-On @{GameClose=@('Zoom');GameForceClose=$false;GamePurge=$false;GameScheme='game';RamGB=16}
Check ($script:CloseRequests -eq 1 -and $script:Forced -eq 0) 'game mode requests normal closure without killing unresponsive apps by default'
Game-On @{GameClose=@('Zoom');GameForceClose=$true;GamePurge=$false;GameScheme='game';RamGB=16}
Check ($script:Forced -eq 1) 'explicit force-close option retains original game-mode capability'
# Editing options changes only game preferences in state, without closing applications.
$P3Root=Join-Path $work 'options';[void][IO.Directory]::CreateDirectory($P3Root)
$StateFile=Join-Path $P3Root 'state.json';Write-JsonAtomic $StateFile @{RolledBack=$false;InitialBackupMarker='keep';AfterReportEnabled=$true}
[IO.File]::WriteAllText((Join-Path $P3Root ($GameName+'.bat')), '# BOOST_GAME_OPTIONS_V1 # BOOST_GAME_OPTIONS_V2')
function Get-ClosableFound {return @('Zoom')}
function Ask-Multi {return @(1)}
function Ask($Question) {return ($Question -like 'Сохранить настройки*')}
function Wait-Key {}
$script:Forced=0;$script:CloseRequests=0
Set-GameOptions
$updated=Read-Json $StateFile
Check ($updated.InitialBackupMarker -eq 'keep' -and @($updated.GameClose) -contains 'Zoom' -and -not $updated.GameForceClose -and -not $updated.GamePurge) 'game preferences save chosen close list and explicit defaults while preserving other state'
Check ($script:Forced -eq 0 -and $script:CloseRequests -eq 0) 'editing game preferences does not close running apps'
Check $updated.AfterReportEnabled 'editing game preferences preserves pending one-shot report permission'

# An old installed helper must not interpret new preferences with old forced-close behavior.
$before=[IO.File]::ReadAllText($StateFile)
[IO.File]::WriteAllText((Join-Path $P3Root ($GameName+'.bat')), 'old helper')
Set-GameOptions
Check ($before -ceq [IO.File]::ReadAllText($StateFile)) 'new game preferences require updated helper before saving'
# Startup uses the captured explicit selection without rescanning or forcing background policies.
$script:BackgroundWrites=0;$script:Disabled=@()
function Apply-Reg {$script:BackgroundWrites++}
function Get-SuggestedStartup {throw 'must use preview selection'}
function Disable-StartupItem($It) {$script:Disabled+=$It.Name}
Invoke-StartupTweaks @{} @{RestrictBackground=$false;Startup=@(@{Name='Steam'})} @{OneDrive=@{Block=$false}}
Check ($script:BackgroundWrites -eq 0 -and ($script:Disabled -join ',') -eq 'Steam') 'startup choice preserves notification policies and uses only previewed entry'
Invoke-StartupTweaks @{} @{RestrictBackground=$true;Startup=@()} @{OneDrive=@{Block=$false}}
Check ($script:BackgroundWrites -eq 2) 'explicit background restriction keeps original policies available'
$script:ShownItems=@()
function Ask-Multi($Question,$Hint,$Items) {$script:ShownItems=$Items;return @(1)}
$selected=@(Select-Startup @(@{Name='SecurityHealth';Title='Security';Command='security.exe'},@{Name='Unknown';Title='Unknown';Command='unknown.exe'},@{Name='Steam';Title='Steam';Command='steam.exe'}))
Check ($selected.Count -eq 1 -and $selected[0].Name -eq 'Unknown' -and @($script:ShownItems | Where-Object {$_.Pre}).Count -eq 0) 'unknown startup remains manual and protected startup is excluded'
# Classic replacement packages must inherit the selected removal population too.
$script:ClassicScopes=@()
function Get-AppPackages {return @(@{PackageFullName='fake'})}
function Enable-ClassicWmp {return $true}
function Remove-JunkApp($App) {$script:ClassicScopes+=([bool]$App.AllUsers);return $true}
Invoke-Apps @{IsWin11=$false} @{Junk=@();Light=$true;AppScope='AllUsers';Menu=$false;OneDrive=$false;OneDriveNote=''} @{}
Check ($script:ClassicScopes.Count -eq 2 -and @($script:ClassicScopes | Where-Object {-not $_}).Count -eq 0) 'classic media replacement removals inherit all-user scope when explicitly selected'

return $script:ProductChecks
