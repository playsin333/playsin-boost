$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$temp = Join-Path ([IO.Path]::GetTempPath()) ('boost-checker-' + [guid]::NewGuid().ToString('N'))
$script:CheckerChecks = 0
function Assert-Checker($Value, $Message) {
    if (-not $Value) { throw ('FAIL: ' + $Message) }
    $script:CheckerChecks++
    Write-Host ('PASS: ' + $Message)
}
try {
    $raw = [IO.File]::ReadAllText((Join-Path $repo 'PLAYSIN BOOST 3.0.bat'))
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput($raw, [ref]$tokens, [ref]$errors)
    Assert-Checker ($errors.Count -eq 0) 'BOOST syntax with checker entry'
    foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]}, $false)) {
        if ($fn.Name -in @('Get-TweakCheckerStartInfo', 'Show-TweakChecker')) { . ([scriptblock]::Create($fn.Extent.Text)) }
    }
    $vendor = Join-Path (Join-Path $repo 'checker') 'PLAYSIN TWEAK CHECK.bat'
    $source = Get-Content -LiteralPath (Join-Path (Split-Path $vendor) 'SOURCE.json') -Raw | ConvertFrom-Json
    Assert-Checker ((Get-FileHash -LiteralPath $vendor -Algorithm SHA256).Hash -eq $source.Sha256) 'bundled checker matches its recorded source/patch checksum'
    [void][Management.Automation.Language.Parser]::ParseInput([IO.File]::ReadAllText($vendor), [ref]$tokens, [ref]$errors)
    Assert-Checker ($errors.Count -eq 0) 'upstream checker syntax'
    Assert-Checker (Test-Path -LiteralPath (Join-Path (Split-Path $vendor) 'LICENSE')) 'checker license is shipped'

    # Exercise the real child command using harmless fixtures, without scanning or changing Windows.
    $PackDir = Join-Path $temp "Проверка O'Brien & (100% ready)"
    $folder = Join-Path $PackDir 'checker'
    [void][IO.Directory]::CreateDirectory($folder)
    $fixture = Join-Path $folder 'PLAYSIN TWEAK CHECK.bat'
    [IO.File]::WriteAllText($fixture, 'function Main { throw "child function" }; [IO.File]::WriteAllText($env:TC_SELF + ".ran", $env:TC_SELF)')
    $parentSelf = $env:TC_SELF
    function Main { return 'parent function' }
    $start = Get-TweakCheckerStartInfo
    Assert-Checker ($start.EnvironmentVariables['TC_SELF'] -ceq $fixture -and $env:TC_SELF -ceq $parentSelf) 'literal path is passed only in child environment'
    Assert-Checker (-not $start.UseShellExecute -and $start.Arguments -notlike '*cmd*' -and $start.Arguments -notlike '*O*Brien*') 'launch command contains no interpolated source path'
    $start.FileName = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $child = [Diagnostics.Process]::Start($start)
    try {
        if (-not $child.WaitForExit(10000)) { $child.Kill(); throw 'Checker probe timed out' }
        Assert-Checker ($child.ExitCode -eq 0 -and [IO.File]::ReadAllText($fixture + '.ran') -ceq $fixture) 'child executes successfully with spaces, apostrophe, ampersand, percent and Cyrillic path'
    } finally { $child.Dispose() }
    Assert-Checker ((Main) -eq 'parent function') 'checker functions do not replace BOOST functions'

    # Exercise the complete menu action, including restoration of the shared console title.
    $script:ProbeStart = $start
    function Get-TweakCheckerStartInfo { return $script:ProbeStart }
    $script:ConsoleRestored = $false
    function Set-ConsoleLook { $script:ConsoleRestored = $true }
    Show-TweakChecker
    Assert-Checker ($script:ConsoleRestored -and (Main) -eq 'parent function') 'menu action waits for checker and restores BOOST console'
    $helper = $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Get-TweakCheckerStartInfo'}, $false)
    . ([scriptblock]::Create($helper.Extent.Text))

    [IO.File]::WriteAllText($fixture, 'function Broken {')
    $start.EnvironmentVariables['TC_NOWAIT'] = '1'
    $child = [Diagnostics.Process]::Start($start)
    try {
        if (-not $child.WaitForExit(10000)) { $child.Kill(); throw 'Failure probe timed out' }
        Assert-Checker ($child.ExitCode -eq 1) 'parse failure is reported by the child without killing BOOST'
    } finally { $child.Dispose() }
    Remove-Item -LiteralPath $fixture
    $failed = $false
    try { [void](Get-TweakCheckerStartInfo) } catch { $failed = $_.Exception.Message -like '*checker*' }
    Assert-Checker $failed 'missing checker is detected before starting a process'
    $script:Waited = $false
    function Wait-Key { $script:Waited = $true }
    Show-TweakChecker
    Assert-Checker $script:Waited 'missing checker shows a message and returns to BOOST'
    return $script:CheckerChecks
} finally { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
