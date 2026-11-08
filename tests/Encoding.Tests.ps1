# Run only harmless loader fixtures: no Main, Windows scans or tuning actions.
param([string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$folder = Join-Path ([IO.Path]::GetTempPath()) ("boost-encoding O'Brien & (тест) " + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($folder)
$saved = @{}
foreach ($name in @('P3_NOMAIN','P3_SELF','P3_ARG','SystemDrive','ProgramData')) {
    $saved[$name] = [Environment]::GetEnvironmentVariable($name)
}
function Encoding-Literal([string]$Value) { return "'" + $Value.Replace("'", "''") + "'" }
try {
    $source = Join-Path $RepositoryRoot 'PLAYSIN BOOST 3.0.bat'
    $raw = [IO.File]::ReadAllText($source, [Text.Encoding]::UTF8)
    $env:P3_NOMAIN = '1'; $env:P3_SELF = $source
    $env:SystemDrive = $folder; $env:ProgramData = $folder
    . ([scriptblock]::Create($raw))
    $loaders = @{
        main = $raw
        rollback = Get-NestedText 'rollback' $RollbackBody $false
        game = Get-NestedText 'game' $GameBody $false
        check = Get-NestedText 'check' $CheckBody $true
        checker = [IO.File]::ReadAllText((Join-Path $RepositoryRoot 'checker/PLAYSIN TWEAK CHECK.bat'), [Text.Encoding]::UTF8)
    }
    $exe = (Get-Process -Id $PID).Path
    foreach ($name in $loaders.Keys) {
        $loader = ($loaders[$name] -split '\r?\n' | Where-Object { $_ -match '^powershell .* -Command ' } | Select-Object -First 1)
        if ($loader -notmatch '-Command "(.*)"$') { throw "Cannot extract loader: $name" }
        $command = $Matches[1]
        $fixture = Join-Path $folder ($name + '.bat')
        # This runs before any script-side encoding initialization can hide a faulty loader.
        $body = @'
if ([Console]::OutputEncoding.CodePage -ne 65001 -or [Console]::InputEncoding.CodePage -ne 65001 -or $OutputEncoding.CodePage -ne 65001) { throw 'Loader did not initialize UTF-8 before entering the script' }
Write-Host 'Проверка русского текста'
'@
        [IO.File]::WriteAllText($fixture, $body, [Text.UTF8Encoding]::new($false))
        $prefix = '[Console]::OutputEncoding=[Text.Encoding]::ASCII;[Console]::InputEncoding=[Text.Encoding]::ASCII;$OutputEncoding=[Text.Encoding]::ASCII;$env:P3_SELF=' + (Encoding-Literal $fixture) + ';$env:TC_SELF=$env:P3_SELF;'
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($prefix + $command))
        $output = @(& $exe -NoProfile -NonInteractive -EncodedCommand $encoded 6>&1 2>&1)
        if ($LASTEXITCODE -ne 0 -or ($output -join "`n") -notmatch 'Проверка русского текста') { throw ("UTF-8 loader failed: $name : " + ($output -join "`n")) }
        Write-Host "PASS: $name loader initializes UTF-8 before script execution from ASCII defaults"

        if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
            # Execute the actual BAT header through cmd.exe and Windows PowerShell 5.1.
            # The harmless fixture replaces the entire program after the hybrid header.
            $header = ($loaders[$name] -split '(?m)^#>\r?$', 2)[0]
            [IO.File]::WriteAllText($fixture, $header + "#>`r`n" + $body, [Text.UTF8Encoding]::new($false))
            $start = New-Object Diagnostics.ProcessStartInfo
            $start.FileName = $env:ComSpec
            $start.Arguments = '/d /c ""' + $fixture + '""'
            $start.UseShellExecute = $false
            $start.RedirectStandardOutput = $true
            $start.RedirectStandardError = $true
            $start.RedirectStandardInput = $true
            $start.StandardOutputEncoding = [Text.Encoding]::UTF8
            $child = [Diagnostics.Process]::Start($start)
            try {
                $child.StandardInput.Close()
                $stdoutTask = $child.StandardOutput.ReadToEndAsync()
                $stderrTask = $child.StandardError.ReadToEndAsync()
                if (-not $child.WaitForExit(15000)) { $child.Kill(); throw "cmd.exe loader timed out: $name" }
                $stdout = $stdoutTask.GetAwaiter().GetResult()
                $stderr = $stderrTask.GetAwaiter().GetResult()
                if ($child.ExitCode -ne 0 -or $stdout -notmatch 'Проверка русского текста') { throw "cmd.exe loader failed: $name : $stdout $stderr" }
            } finally { $child.Dispose() }
            Write-Host "PASS: $name BAT header prints Cyrillic through cmd.exe and Windows PowerShell"
        }
    }
    Write-Host 'SUCCESS: encoding loader fixtures passed; interactive UAC still requires a manual Windows check'
} finally {
    foreach ($name in $saved.Keys) { [Environment]::SetEnvironmentVariable($name, $saved[$name]) }
    Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
}
