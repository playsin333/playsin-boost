# Exercise real menu handlers with harmless old-tool fixtures, never tuning Windows.
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$raw = [IO.File]::ReadAllText((Join-Path $repo 'PLAYSIN BOOST 3.0.bat'), [Text.Encoding]::UTF8)
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseInput($raw, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'BOOST source has syntax errors' }
foreach ($fn in $ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst]}, $false)) {
    if ($fn.Name -in @('Q','Set-BoostConsoleFont','Get-BoostToolStartInfo','Open-BoostTool')) { . ([scriptblock]::Create($fn.Extent.Text)) }
}
$common = [regex]::Match($raw, '(?s)\$CommonCode = @''\r?\n(.*?)\r?\n''@').Groups[1].Value
$commonAst = [Management.Automation.Language.Parser]::ParseInput($common, [ref]$tokens, [ref]$errors)
foreach ($fn in $commonAst.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Set-BoostConsoleFont'}, $false)) { . ([scriptblock]::Create($fn.Extent.Text)) }
$factory = (Get-Command Get-BoostToolStartInfo).ScriptBlock
$folder = Join-Path ([IO.Path]::GetTempPath()) ("boost-old-tools O'Brien & (100% тест) " + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($folder)
$oldEnv = @{}
foreach ($name in @('SystemRoot','P3_SELF','P3_ARG','P3_NOMAIN')) { $oldEnv[$name] = [Environment]::GetEnvironmentVariable($name) }
try {
    if (-not $env:SystemRoot) { $env:SystemRoot = $folder }
    $env:P3_SELF = 'parent-file'; $env:P3_ARG = '5'; $env:P3_NOMAIN = '1'
    $P3Root = $folder
    $RollbackName = 'rollback'; $GameName = 'game'; $CheckName = 'check'
    $script:Restored = 0
    function Set-ConsoleLook { $script:Restored++ }
    function Wait-Key { throw 'Unexpected error or missing file' }
    $exe = (Get-Process -Id $PID).Path
    # Only adapt the executable for this host. Keep the exact shipped encoded command.
    function Get-BoostToolStartInfo($Path) {
        $start = & $factory $Path
        if (-not $start.UseShellExecute -or $start.Arguments -notmatch '-EncodedCommand ') { throw 'Expected separate shell console and encoded command' }
        $start.FileName = $exe
        $start.UseShellExecute = $false
        $start.RedirectStandardInput = $true
        return $start
    }
    $fixture = @'
# Legacy tool has no encoding or font initialization of its own.
if ($env:P3_ARG -or $env:P3_NOMAIN) { throw 'Inherited menu arguments were not cleared' }
if ([Console]::OutputEncoding.CodePage -ne 65001 -or $OutputEncoding.CodePage -ne 65001) { throw 'Tool entered without UTF-8' }
if (-not (Get-Command Set-BoostConsoleFont -ErrorAction SilentlyContinue)) { throw 'Current font helper not injected' }
if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and -not $env:WT_SESSION -and -not ('BoostConsoleFont' -as [type])) { throw 'Font helper was not invoked before the legacy tool' }
function Main { [IO.File]::WriteAllText($env:P3_SELF + '.result', 'Проверка русского текста', [Text.Encoding]::UTF8) }
Main
'@
    foreach ($kind in @('game','rollback','check')) {
        $path = Join-Path $folder ($kind + '.bat')
        [IO.File]::WriteAllText($path, $fixture, [Text.UTF8Encoding]::new($false))
        $before = (Get-FileHash -LiteralPath $path).Hash
        Open-BoostTool $kind
        if ([IO.File]::ReadAllText($path + '.result', [Text.Encoding]::UTF8) -cne 'Проверка русского текста') { throw "Legacy tool did not execute: $kind" }
        if ((Get-FileHash -LiteralPath $path).Hash -cne $before) { throw 'Legacy source was rewritten' }
        if ($env:P3_SELF -cne 'parent-file' -or $env:P3_ARG -cne '5' -or $env:P3_NOMAIN -cne '1') { throw 'Child changed parent environment' }
        Write-Host "PASS: menu opens legacy $kind with current font/UTF-8 preparation and preserves its source"
    }
    if ($script:Restored -ne 3) { throw 'Parent console was not restored after each tool' }
    $missing = $false
    try { & $factory (Join-Path $folder 'missing.bat') } catch { $missing = $true }
    if (-not $missing) { throw 'Missing tool was accepted' }
    Write-Host 'PASS: missing tool is rejected before launch; parent console restored'
    $broken = Join-Path $folder 'broken.bat'
    [IO.File]::WriteAllText($broken, 'function Broken {')
    $start = Get-BoostToolStartInfo $broken
    $child = [Diagnostics.Process]::Start($start)
    try {
        if (-not $child.WaitForExit(15000)) { $child.Kill(); throw 'Broken tool hung' }
        if ($child.ExitCode -ne 1) { throw 'Broken tool did not return failure' }
    } finally { $child.Dispose() }
    Write-Host 'PASS: legacy tool parse failure returns nonzero without closing parent'
} finally {
    foreach ($name in $oldEnv.Keys) { [Environment]::SetEnvironmentVariable($name, $oldEnv[$name]) }
    Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
}
