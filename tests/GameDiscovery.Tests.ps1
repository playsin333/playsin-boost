# Read only temporary launcher fixtures; never query real Steam, Epic or game settings.
$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    Write-Host 'SKIP: Steam library discovery uses Windows drive paths; exercised by Windows CI'
    return
}
$repo = Split-Path -Parent $PSScriptRoot
$raw = [IO.File]::ReadAllText((Join-Path $repo 'PLAYSIN BOOST 3.0.bat'), [Text.Encoding]::UTF8)
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseInput($raw, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Invalid BOOST syntax' }
foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Get-GameFolders'}, $false)) {
    . ([scriptblock]::Create($fn.Extent.Text))
}
$folder = Join-Path ([IO.Path]::GetTempPath()) ('boost-steam-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($folder)
$oldProgramData = $env:ProgramData
$env:ProgramData = $folder
function Get-RegValue { return @{ Value = $script:SteamPath } }
function Get-CimInstance { return @() }
function Check-Discovery($Expected, $Message) {
    $actual = @(Get-GameFolders | ForEach-Object { $_.Title } | Sort-Object)
    if (($actual -join '|') -cne (@($Expected | Sort-Object) -join '|')) { throw ($Message + ': ' + ($actual -join ', ')) }
    Write-Host ('PASS: ' + $Message)
}
try {
    $letter = @('F','Z','Y','X','W','V','U','T' | Where-Object { -not (Get-PSDrive -Name $_ -ErrorAction SilentlyContinue) })[0]
    if (-not $letter) { throw 'No unused drive letter available for regression fixture' }
    $missing = $letter + ':\UnavailableSteamLibrary'
    $script:SteamPath = Join-Path $folder 'Steam'
    $primary = [IO.Path]::Combine($script:SteamPath, 'steamapps', 'common', 'Primary Game')
    $secondaryLib = Join-Path $folder 'Second Library'
    $secondary = [IO.Path]::Combine($secondaryLib, 'steamapps', 'common', 'Secondary Game')
    foreach ($dir in @($primary, $secondary)) { [void][IO.Directory]::CreateDirectory($dir) }
    $vdf = [IO.Path]::Combine($script:SteamPath, 'steamapps', 'libraryfolders.vdf')
    $content = '"libraryfolders" { "0" { "path" "' + $missing.Replace('\','\\') + '" } "1" { "path" "' + $secondaryLib.Replace('\','\\') + '" } }'
    [IO.File]::WriteAllText($vdf, $content, [Text.Encoding]::UTF8)
    Check-Discovery @('Primary Game','Secondary Game') 'missing drive in VDF is skipped and later accessible libraries are discovered'
    [IO.File]::WriteAllText($vdf, '"path" "' + $missing.Replace('\','\\') + '"', [Text.Encoding]::UTF8)
    Check-Discovery @('Primary Game') 'offline secondary library does not discard primary Steam games'
    [IO.File]::Delete($vdf)
    Check-Discovery @('Primary Game') 'missing optional VDF preserves default library'
    [IO.File]::WriteAllText($vdf, $content, [Text.Encoding]::UTF8)
    $locked = [IO.File]::Open($vdf, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    try { Check-Discovery @('Primary Game') 'unreadable optional VDF preserves default library' }
    finally { $locked.Dispose() }
    $script:SteamPath = $missing
    Check-Discovery @() 'unavailable primary Steam path does not abort discovery'
} finally {
    $env:ProgramData = $oldProgramData
    Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
}
