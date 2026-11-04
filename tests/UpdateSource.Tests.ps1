$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $root 'PLAYSIN BOOST 3.0.bat'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Invalid BAT syntax' }
$fn=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Get-BoostUpdateSource'},$false)
# Import only the source resolver; no tuning entry point or Windows settings execute.
. ([scriptblock]::Create($fn.Extent.Text))
function Read-Json($File) { return Get-Content -LiteralPath $File -Raw | ConvertFrom-Json }
$work=Join-Path ([IO.Path]::GetTempPath()) ('boost-source-'+[guid]::NewGuid().ToString('N'))
$PackDir=Join-Path $work 'current'
[void][IO.Directory]::CreateDirectory($PackDir)
$bundled=Join-Path $PackDir 'PLAYSIN-BOOST-update-source.json'
$parent=Join-Path $work 'PLAYSIN-BOOST-update-source.json'
$new='https://raw.githubusercontent.com/playsin333/playsin-boost/main/boost-release.json'
$old='https://raw.githubusercontent.com/playsin333/pc-optimizer/main/boost-release.json'
function Source($File,$Url) { [IO.File]::WriteAllText($File,(@{ManifestUrl=$Url}|ConvertTo-Json),[Text.Encoding]::UTF8) }
function Check($Value,$Name) { if (-not $Value) {throw ('FAIL: '+$Name)};Write-Host ('PASS: '+$Name) }
try {
    Source $bundled $new
    Check ((Get-BoostUpdateSource) -ceq $new) 'new bundled channel'
    Source $parent $old
    $before=[IO.File]::ReadAllBytes($parent)
    Check ((Get-BoostUpdateSource) -ceq $new) 'old official parent migrates'
    Check ([Convert]::ToBase64String($before) -ceq [Convert]::ToBase64String([IO.File]::ReadAllBytes($parent))) 'source file is unchanged'
    Source $parent 'https://example.invalid/custom.json'
    Check ((Get-BoostUpdateSource) -ceq 'https://example.invalid/custom.json') 'custom override retains priority'
    Source $parent ($old+'?custom=1')
    Check ((Get-BoostUpdateSource) -ceq ($old+'?custom=1')) 'similar custom URL remains unchanged'
    [IO.File]::Delete($parent)
    Source $bundled $old.ToUpperInvariant()
    Check ((Get-BoostUpdateSource) -ceq $new) 'old bundled address migrates regardless of case'
    foreach($url in @('http://example.invalid/release.json','https://user:password@example.invalid/release.json','relative.json')) {
        Source $parent $url
        $caught=$false;try { [void](Get-BoostUpdateSource) } catch {$caught=$true}
        Check $caught 'invalid source rejected'
    }
    Write-Host 'SUCCESS: 9 isolated update-source checks; no tuning or network operations.'
} finally {
    [IO.File]::Delete($parent);[IO.File]::Delete($bundled)
    [IO.Directory]::Delete($PackDir);[IO.Directory]::Delete($work)
}
