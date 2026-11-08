# Compile the shipped font helper, then test its native API in a disposable Windows console.
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$raw = [IO.File]::ReadAllText((Join-Path $repo 'PLAYSIN BOOST 3.0.bat'), [Text.Encoding]::UTF8)
$match = [regex]::Match($raw, '(?s)function Set-BoostConsoleFont.*?Add-Type -TypeDefinition @"\r?\n(.*?)\r?\n"@')
if (-not $match.Success) { throw 'Console font helper not found' }
$code = $match.Groups[1].Value
if (-not ('BoostConsoleFont' -as [type])) { Add-Type -TypeDefinition $code }
if ([Runtime.InteropServices.Marshal]::SizeOf([type]'BoostConsoleFont+FontInfo') -ne 84) { throw 'Invalid CONSOLE_FONT_INFOEX layout' }
if (-not [BoostConsoleFont]::IsRaster(0x30) -or [BoostConsoleFont]::IsRaster(0x36)) { throw 'Raster/TrueType detection failed' }
Write-Host 'PASS: native font helper compiles, struct is 84 bytes, raster and TrueType flags are distinguished'

# Ensure the same helper is shipped inside the checker and generated tools.
$checker = [IO.File]::ReadAllText((Join-Path $repo 'checker/PLAYSIN TWEAK CHECK.bat'), [Text.Encoding]::UTF8)
if (-not $checker.Contains($code)) { throw 'Checker uses a different console font helper' }
$common = [regex]::Match($raw, '(?s)\$CommonCode = @''\r?\n(.*?)\r?\n''@').Groups[1].Value
if (-not $common.Contains($code)) { throw 'Generated tools do not include the console font helper' }
Write-Host 'PASS: main program, generated tools and bundled checker share the font helper'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    Write-Host 'SKIP: real console font switching requires Windows'
    exit 0
}
$probe = @'
using System;
using System.Runtime.InteropServices;
public static class ConsoleFontProbe {
    [DllImport("kernel32.dll")] static extern bool AllocConsole();
    [DllImport("kernel32.dll")] static extern bool FreeConsole();
    [DllImport("kernel32.dll")] static extern IntPtr GetStdHandle(int id);
    [DllImport("kernel32.dll")] static extern bool SetStdHandle(int id, IntPtr handle);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] static extern IntPtr CreateFile(string name, uint access, uint share, IntPtr security, uint creation, uint flags, IntPtr template);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] static extern bool GetCurrentConsoleFontEx(IntPtr h, bool m, ref BoostConsoleFont.FontInfo f);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] static extern bool SetCurrentConsoleFontEx(IntPtr h, bool m, ref BoostConsoleFont.FontInfo f);
    public static string Run() {
        FreeConsole();
        if (!AllocConsole()) throw new Exception("Could not create disposable console");
        // CI redirects standard output to a pipe. AllocConsole may preserve that handle.
        IntPtr output = CreateFile("CONOUT$", 0xC0000000, 3, IntPtr.Zero, 3, 0, IntPtr.Zero);
        try {
            if (output == new IntPtr(-1) || !SetStdHandle(-11, output)) throw new Exception("Could not attach disposable console output");
            var f = new BoostConsoleFont.FontInfo();
            f.Size = 84; f.Face = "Terminal"; f.Family = 0x30; f.Weight = 400; f.Cell.X = 8; f.Cell.Y = 12;
            IntPtr h = GetStdHandle(-11);
            bool raster = SetCurrentConsoleFontEx(h, false, ref f) && GetCurrentConsoleFontEx(h, false, ref f) && BoostConsoleFont.IsRaster(f.Family);
            if (raster) {
                if (!BoostConsoleFont.EnsureUnicodeFont()) throw new Exception("Unicode font fallback failed");
                if (!GetCurrentConsoleFontEx(h, false, ref f) || BoostConsoleFont.IsRaster(f.Family) || f.Face != "Consolas")
                    throw new Exception("Console did not switch from raster font to Consolas");
            }
            f.Face = "Lucida Console"; f.Family = 0x36;
            if (!SetCurrentConsoleFontEx(h, false, ref f) || !GetCurrentConsoleFontEx(h, false, ref f)) throw new Exception("Could not set TrueType precondition");
            string face = f.Face;
            if (!BoostConsoleFont.EnsureUnicodeFont() || !GetCurrentConsoleFontEx(h, false, ref f) || f.Face != face)
                throw new Exception("Existing TrueType font was changed");
            return raster ? "PASS: raster console switched to Consolas; TrueType font preserved" : "SKIP: runner could not select a raster font; PASS: existing TrueType font preserved";
        } finally { if (output != new IntPtr(-1)) CloseHandle(output); FreeConsole(); }
    }
}
'@
# Compile both definitions together so the probe can reference the shipped struct.
$folder = Join-Path ([IO.Path]::GetTempPath()) ('boost-font-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($folder)
try {
    $source = Join-Path $folder 'font.cs'
    [IO.File]::WriteAllText($source, $code + "`n" + ($probe -replace 'using System;\r?\n','' -replace 'using System.Runtime.InteropServices;\r?\n',''), [Text.Encoding]::UTF8)
    $env:BOOST_FONT_TEST_SOURCE = $source
    $exe = (Get-Process -Id $PID).Path
    $probeCommand = @'
try {
    $ErrorActionPreference = 'Stop'
    Add-Type -Path $env:BOOST_FONT_TEST_SOURCE
    $result = [ConsoleFontProbe]::Run()
    [IO.File]::WriteAllText($env:BOOST_FONT_TEST_SOURCE + '.result', $result)
    exit 0
} catch {
    [IO.File]::WriteAllText($env:BOOST_FONT_TEST_SOURCE + '.result', $_.Exception.ToString())
    exit 1
}
'@
    & $exe -NoProfile -NonInteractive -Command $probeCommand
    if ($LASTEXITCODE -ne 0) { throw ('Native font regression test failed: ' + [IO.File]::ReadAllText($source + '.result')) }
    Write-Host ([IO.File]::ReadAllText($source + '.result'))
} finally {
    Remove-Item Env:BOOST_FONT_TEST_SOURCE -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
}
