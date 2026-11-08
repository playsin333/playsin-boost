<# :
@echo off
chcp 65001 >nul
set "P3_SELF=%~f0"
set "P3_ARG=%~1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false); [Console]::InputEncoding = [Console]::OutputEncoding; $OutputEncoding = [Console]::OutputEncoding; iex ([IO.File]::ReadAllText($env:P3_SELF,[Text.Encoding]::UTF8)) } catch { $r=$_; $d=[IO.Path]::Combine([IO.Path]::GetTempPath(),'PLAYSIN-BOOST-error.txt'); $m=$r.ToString()+[Environment]::NewLine+$r.InvocationInfo.PositionMessage+[Environment]::NewLine+$r.ScriptStackTrace; try { [IO.File]::WriteAllText($d,$m,[Text.Encoding]::UTF8) } catch {}; Write-Host $m -ForegroundColor Red; Write-Host ('Error details: '+$d); exit 1 }"
set "P3_EXIT=%errorlevel%"
if "%P3_EXIT%"=="0" exit /b 0
if "%P3_EXIT%"=="2" exit /b 0
if "%P3_EXIT%"=="3" exit /b 0
echo.
echo BOOST could not finish. Please send the error text shown above.
echo Error details are shown above and saved in TEMP as PLAYSIN-BOOST-error.txt.
pause
exit /b %P3_EXIT%
:: ============================================================
::  PLAYSIN BOOST 3.0 · by playsin333
::  Бесплатный инструмент · автор playsin333
::  https://funpay.com/users/21612506/
::  YouTube: www.youtube.com/@plays1n
::  TikTok: tiktok.com/@playsin333
::  Telegram: t.me/playsin333tgk
::  Бесплатный пак. Индивидуальная настройка ПК — отдельная услуга.
::  (c) playsin333, 2026
:: ============================================================
#>
# =====================================================================
#  Гибридный BAT/PowerShell: проверка ПК, автоматические наборы и ручной
#  выбор блоков. План показывается перед подтверждением применения.
#  Исходные значения отслеживаемых настроек сохраняются для отката;
#  удаление файлов и приложений автоматически не отменяется.
#  Верхние строки запускают этот же файл через штатный PowerShell.
#  Исходный BAT сохраняется после работы.
# =====================================================================

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# @brand-begin
$BR = @{
    Tag    = 'PLAYSIN333'
    Short  = 'PLAYSIN'
    Pack   = 'PLAYSIN BOOST 3.0'
    Title  = 'PLAYSIN BOOST 3.0 · by playsin333'
    Sign   = '; PLAYSIN BOOST 3.0 · playsin333'
    Client = $false
    Other  = 'PRIVATE'
    Shop   = 'https://funpay.com/users/21612506/'
    Seller = 'Бесплатный PLAYSIN BOOST · индивидуальная настройка — по желанию'
    Social = 'youtube.com/@plays1n · t.me/playsin333tgk · discord.gg/brMD3VYUAu'
    Plus   = ''
    Head   = @(
        'PLAYSIN BOOST 3.0 | 2026 | BY PLAYSIN333',
        'НАСТРОЙКА WINDOWS ПОД ТВОИ ЗАДАЧИ',
        'БЕСПЛАТНЫЙ ПАК · АВТОНАСТРОЙКА И РУЧНОЙ ВЫБОР',
        'ПРОВЕРКА ПК · ПОНЯТНЫЙ ПЛАН · БЭКАП И ОТКАТ'
    )
    Art    = @(
        '██████████████████████████████████████████████████████████████████████████████████████████████████████████',
        '███      ████  ██████████    ████  ██████  ████      ██      ██  ██████  ██      ████      ████      █████',
        '███  ████  ██  ████████  ████  ████  ██  ████  ██████████  ████    ████  ████████  ████████  ████████  ███',
        '███      ████  ████████        ██████  ████████    ██████  ████  ██  ██  ████    ██████    ██████    █████',
        '███  ████████  ████████  ████  ██████  ████████████  ████  ████  ████    ████████  ████████  ████████  ███',
        '███  ████████        ██  ████  ██████  ██████      ████      ██  ██████  ██      ████      ████      █████',
        '██████████████████████████████████████████████████████████████████████████████████████████████████████████'
    )
}
# @brand-end

# PLAYSIN BOOST 3.0 · playsin333
$P3Version   = '3.0.15'
$P3Root      = Join-Path $env:SystemDrive $BR.Tag
$OtherRoot   = Join-Path $env:SystemDrive $BR.Other
$Desktop     = [Environment]::GetFolderPath('Desktop')
# A redirected or missing Desktop must not prevent the menu from loading.
if ([string]::IsNullOrWhiteSpace($Desktop)) { $Desktop = [Environment]::GetFolderPath('UserProfile') }
if ([string]::IsNullOrWhiteSpace($Desktop)) { $Desktop = [IO.Path]::GetTempPath() }
$LogName     = $BR.Pack + ' лог.txt'
$LogPath     = Join-Path $Desktop $LogName
$LogCopy     = Join-Path $P3Root $LogName
$RegFile     = Join-Path $P3Root 'registry.json'
$StateFile   = Join-Path $P3Root 'state.json'
$MeasureFile = Join-Path $P3Root 'measure-before.json'
$DrsBackup   = Join-Path $P3Root 'nvidia-drs'
$NvDir       = Join-Path $P3Root 'nvidia'
$P3Point     = $BR.Pack
$PackDir     = Split-Path -Parent $env:P3_SELF
$NpiSrc      = Join-Path $PackDir 'nvidia'
$DrsDir      = Join-Path $env:ProgramData 'NVIDIA Corporation\Drs'
$RollbackName = 'Откат ' + $BR.Tag
$GameName    = 'Игровой режим ' + $BR.Short
$CheckName   = 'Самопроверка ' + $BR.Tag
$ProgDir     = Join-Path $Desktop ('Программы ' + $BR.Short)
$TaskAfter   = $BR.Tag + '_BOOST_after'
$TaskGame    = $BR.Tag + '_BOOST_game'
$TaskReset   = $BR.Tag + '_BOOST_gamereset'
$GpuClass    = 'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$NetClass    = 'HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}'
$GuidRx      = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

# Игры с высоким приоритетом через IFEO. Список можно дополнять
$IfeoGames = @('cs2.exe', 'FortniteClient-Win64-Shipping.exe', 'RustClient.exe', 'TslGame.exe', 'dota2.exe', 'GTA5.exe', 'GTA5_Enhanced.exe')
# exe известных игр: для привязки к дискретной видеокарте и для игрового режима
$GameExeNames = @('cs2.exe', 'FortniteClient-Win64-Shipping.exe', 'RustClient.exe', 'TslGame.exe', 'VALORANT-Win64-Shipping.exe', 'r5apex.exe', 'r5apex_dx12.exe', 'dota2.exe', 'GTA5.exe', 'GTA5_Enhanced.exe', 'cod.exe', 'RainbowSix.exe', 'RobloxPlayerBeta.exe', 'Overwatch.exe', 'League of Legends.exe', 'DeadByDaylight-Win64-Shipping.exe', 'EscapeFromTarkov.exe', 'Marvel-Win64-Shipping.exe', 'deadlock.exe', 'Minecraft.Windows.exe', 'javaw.exe')

# ---------------------------------------------------------------------
#  Общие функции. Этот же блок кладётся в откат, игровой режим и самопроверку.
# ---------------------------------------------------------------------
$CommonCode = @'
$Utf8Bom   = New-Object System.Text.UTF8Encoding($true)
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Count = @{ OK = 0; SKIP = 0; ERR = 0; INFO = 0 }

# Raster console fonts can render Cyrillic as question marks even with UTF-8.
# Change only the current classic console; keep existing TrueType fonts and Terminal settings.
function Set-BoostConsoleFont {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -or $env:WT_SESSION) { return }
    try {
        if (-not ('BoostConsoleFont' -as [type])) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class BoostConsoleFont {
    [StructLayout(LayoutKind.Sequential)]
    public struct Coord { public short X; public short Y; }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct FontInfo {
        public uint Size;
        public uint Index;
        public Coord Cell;
        public uint Family;
        public uint Weight;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string Face;
    }
    [DllImport("kernel32.dll")] static extern IntPtr GetStdHandle(int id);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool GetCurrentConsoleFontEx(IntPtr handle, bool maximum, ref FontInfo font);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool SetCurrentConsoleFontEx(IntPtr handle, bool maximum, ref FontInfo font);
    public static bool IsRaster(uint family) { return (family & 4) == 0; }
    public static bool EnsureUnicodeFont() {
        IntPtr handle = GetStdHandle(-11);
        if (handle == IntPtr.Zero || handle == new IntPtr(-1)) return false;
        var font = new FontInfo();
        font.Size = (uint)Marshal.SizeOf(typeof(FontInfo));
        if (!GetCurrentConsoleFontEx(handle, false, ref font)) return false;
        if (!IsRaster(font.Family)) return true;
        font.Face = "Consolas";
        font.Family = 0x36;
        font.Weight = 400;
        font.Cell.X = 0;
        font.Cell.Y = (short)Math.Max(12, (int)font.Cell.Y);
        if (!SetCurrentConsoleFontEx(handle, false, ref font)) return false;
        return GetCurrentConsoleFontEx(handle, false, ref font) && !IsRaster(font.Family);
    }
}
"@
        }
        [void][BoostConsoleFont]::EnsureUnicodeFont()
    } catch {
        # Font APIs are unavailable for redirected output and some console hosts.
        # A display-only fallback must never prevent startup or rollback.
    }
}

function Initialize-BoostGraphicsNative {
    if ('P3Graphics' -as [type]) { return }
    Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
public static class P3Graphics {
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    struct DisplayDevice {
        public int cb;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string Name;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string Description;
        public uint Flags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string Id;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string Key;
    }
    [StructLayout(LayoutKind.Sequential)] struct Luid { public uint Low; public int High; }
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    struct OpenAdapter { [MarshalAs(UnmanagedType.LPWStr)] public string Name; public uint Handle; public Luid Id; public uint Source; }
    [StructLayout(LayoutKind.Sequential)] struct QueryAdapter { public uint Handle; public int Type; public IntPtr Data; public uint Size; }
    [StructLayout(LayoutKind.Sequential)] struct CloseAdapter { public uint Handle; }
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern bool EnumDisplayDevices(string device, uint index, ref DisplayDevice data, uint flags);
    [DllImport("gdi32.dll")] static extern int D3DKMTOpenAdapterFromDeviceName(ref OpenAdapter data);
    [DllImport("gdi32.dll")] static extern int D3DKMTQueryAdapterInfo(ref QueryAdapter data);
    [DllImport("gdi32.dll")] static extern int D3DKMTCloseAdapter(ref CloseAdapter data);
    // Null means unknown, not unsupported. Match the actual PnP instance rather than a GPU name heuristic.
    public static uint? HagsCaps(string pnp) {
        if (String.IsNullOrWhiteSpace(pnp)) return null;
        for (uint i=0;i<64;i++) {
            var d=new DisplayDevice();d.cb=Marshal.SizeOf(typeof(DisplayDevice));
            if (!EnumDisplayDevices(null,i,ref d,0)) break;
            if (!String.Equals(d.Id,pnp,StringComparison.OrdinalIgnoreCase)) continue;
            var a=new OpenAdapter();a.Name=d.Name;
            if (D3DKMTOpenAdapterFromDeviceName(ref a)!=0) return null;
            IntPtr data=Marshal.AllocHGlobal(4);
            try {
                Marshal.WriteInt32(data,0);
                var q=new QueryAdapter();q.Handle=a.Handle;q.Type=70;q.Data=data;q.Size=4;
                if (D3DKMTQueryAdapterInfo(ref q)!=0) return null;
                return unchecked((uint)Marshal.ReadInt32(data));
            } finally { Marshal.FreeHGlobal(data);var c=new CloseAdapter();c.Handle=a.Handle;D3DKMTCloseAdapter(ref c); }
        }
        return null;
    }
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr LoadLibraryEx(string path, IntPtr file, uint flags);
    [DllImport("kernel32.dll", CharSet=CharSet.Ansi, ExactSpelling=true)] static extern IntPtr GetProcAddress(IntPtr module, string name);
    [DllImport("kernel32.dll")] static extern bool FreeLibrary(IntPtr module);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet=CharSet.Ansi)] delegate void Profile(string name);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet=CharSet.Ansi)]
    [return:MarshalAs(UnmanagedType.Bool)] delegate bool Property(string name, IntPtr data, uint size);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)] delegate void Update();
    static Delegate Proc(IntPtr module,string name,Type type) {
        IntPtr p=GetProcAddress(module,name);
        if(p==IntPtr.Zero) throw new InvalidOperationException("RTSS SDK export is missing: "+name);
        return Marshal.GetDelegateForFunctionPointer(p,type);
    }
    static uint Rtss(string directory, uint? limit) {
        string path=Path.Combine(Path.GetFullPath(directory),"RTSSHooks64.dll");
        IntPtr module=LoadLibraryEx(path,IntPtr.Zero,0x1100);
        if(module==IntPtr.Zero) throw new InvalidOperationException("RTSSHooks64.dll could not be loaded");
        IntPtr data=Marshal.AllocHGlobal(4);
        try {
            var load=(Profile)Proc(module,"LoadProfile",typeof(Profile));
            var get=(Property)Proc(module,"GetProfileProperty",typeof(Property));
            // Resolve every required export before making any change.
            Profile save=null;Property set=null;Update update=null;
            if(limit.HasValue) {
                save=(Profile)Proc(module,"SaveProfile",typeof(Profile));
                set=(Property)Proc(module,"SetProfileProperty",typeof(Property));
                update=(Update)Proc(module,"UpdateProfiles",typeof(Update));
            }
            load("");
            if(!get("FramerateLimit",data,4)) throw new InvalidOperationException("RTSS FramerateLimit is unavailable");
            if(limit.HasValue) {
                Marshal.WriteInt32(data,unchecked((int)limit.Value));
                if(!set("FramerateLimit",data,4)) throw new InvalidOperationException("RTSS rejected FramerateLimit");
                save("");update();load("");
                if(!get("FramerateLimit",data,4)) throw new InvalidOperationException("RTSS readback failed");
            }
            uint actual=unchecked((uint)Marshal.ReadInt32(data));
            if(limit.HasValue && actual!=limit.Value) throw new InvalidOperationException("RTSS FramerateLimit did not persist");
            return actual;
        } finally { Marshal.FreeHGlobal(data);FreeLibrary(module); }
    }
    public static uint ReadRtssLimit(string directory) { return Rtss(directory,null); }
    public static void WriteRtssLimit(string directory,uint value) { Rtss(directory,value); }
}
"@
}
function Get-HagsCapability($Sys) {
    if ([int]$Sys.Build -lt 19041 -or -not $Sys.Main) { return @{Known=$true;Supported=$false;Enabled=$false} }
    try {
        Initialize-BoostGraphicsNative
        $caps=[P3Graphics]::HagsCaps([string]$Sys.Main.Pnp)
        if ($null -eq $caps) { return @{Known=$false;Supported=$false;Enabled=$false} }
        return @{Known=$true;Supported=([uint32]$caps -band 1) -ne 0;Enabled=([uint32]$caps -band 2) -ne 0}
    } catch { return @{Known=$false;Supported=$false;Enabled=$false} }
}
function Get-RtssFrameLimit([string]$Directory) {
    if (-not [Environment]::Is64BitProcess) {throw 'RTSS: нужен 64-битный PowerShell'}
    Initialize-BoostGraphicsNative
    return [P3Graphics]::ReadRtssLimit($Directory)
}
function Set-RtssFrameLimit([string]$Directory, [uint32]$Limit) {
    if (-not [Environment]::Is64BitProcess) {throw 'RTSS: нужен 64-битный PowerShell'}
    Initialize-BoostGraphicsNative
    [P3Graphics]::WriteRtssLimit($Directory,$Limit)
}

function Write-LogFile([string]$Text) {
    foreach ($p in @($LogPath, $LogCopy)) {
        if ($p) { try { [IO.File]::AppendAllText($p, $Text + "`r`n", $Utf8Bom) } catch {} }
    }
}

function Log([string]$Kind, [string]$Text) {
    $Count[$Kind]++
    switch ($Kind) {
        'OK'    { $tag = '[OK]   '; $color = 'Green' }
        'SKIP'  { $tag = '[ПРОП] '; $color = 'DarkGray' }
        'ERR'   { $tag = '[ОШИБ] '; $color = 'Red' }
        default { $tag = '       '; $color = 'Gray' }
    }
    Write-Host ('   ' + $tag + $Text) -ForegroundColor $color
    Write-LogFile ($tag + $Text)
}

function Section([string]$Title) {
    Write-Host ''
    Write-Host ('  » ' + $Title) -ForegroundColor Cyan
    Write-LogFile ''
    Write-LogFile ('--- ' + $Title + ' ---')
}

function Split-RegPath([string]$Path) {
    $i = $Path.IndexOf('\')
    $hive = $Path.Substring(0, $i).ToUpper()
    switch ($hive) {
        'HKLM'  { [Microsoft.Win32.RegistryHive]::LocalMachine }
        'HKCU'  { [Microsoft.Win32.RegistryHive]::CurrentUser }
        default { throw ('Неизвестный раздел реестра: ' + $hive) }
    }
    $Path.Substring($i + 1)
}

function Open-RegBase($Hive) {
    [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, [Microsoft.Win32.RegistryView]::Registry64)
}

function Get-RegValue([string]$Path, [string]$Name) {
    $h, $sub = Split-RegPath $Path
    $base = Open-RegBase $h
    try {
        $k = $base.OpenSubKey($sub)
        if ($null -eq $k) { return $null }
        try {
            if ($k.GetValueNames() -notcontains $Name) { return $null }
            return [pscustomobject]@{
                Kind  = $k.GetValueKind($Name).ToString()
                Value = $k.GetValue($Name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            }
        } finally { $k.Close() }
    } finally { $base.Close() }
}

function Get-RegNames([string]$Path) {
    $h, $sub = Split-RegPath $Path
    $base = Open-RegBase $h
    try {
        $k = $base.OpenSubKey($sub)
        if ($null -eq $k) { return }
        try { return $k.GetValueNames() } finally { $k.Close() }
    } finally { $base.Close() }
}

function Get-RegSubKeys([string]$Path) {
    $h, $sub = Split-RegPath $Path
    $base = Open-RegBase $h
    try {
        $k = $base.OpenSubKey($sub)
        if ($null -eq $k) { return }
        try { return $k.GetSubKeyNames() } finally { $k.Close() }
    } finally { $base.Close() }
}

function Convert-RegData([string]$Kind, $Value) {
    switch ($Kind) {
        'DWord' {
            $v = [int64]$Value
            if ($v -gt 2147483647) { $v -= 4294967296 }
            return [int32]$v
        }
        'QWord' { return [int64]$Value }
        'Binary' {
            if ($null -eq $Value) { return ,([byte[]]@()) }
            if ($Value -is [string]) {
                $b = New-Object byte[] ([int]($Value.Length / 2))
                for ($i = 0; $i -lt $b.Length; $i++) { $b[$i] = [Convert]::ToByte($Value.Substring($i * 2, 2), 16) }
                return ,$b
            }
            return ,([byte[]]@($Value))
        }
        'MultiString' {
            if ($null -eq $Value) { return ,([string[]]@()) }
            return ,([string[]]@($Value))
        }
        default { return [string]$Value }
    }
}

# Значение реестра в виде строки для сравнения: DWord без знака, Binary в hex, MultiString через перевод строки
function Format-RegData([string]$Kind, $Value) {
    if ($null -eq $Value) { return '' }
    $d = Convert-RegData $Kind $Value
    switch ($Kind) {
        'DWord' { $v = [int64]$d; if ($v -lt 0) { $v += 4294967296 }; return [string]$v }
        'Binary' { return ((@($d) | ForEach-Object { ([byte]$_).ToString('X2') }) -join '') }
        'MultiString' { return ((@($d) | ForEach-Object { [string]$_ }) -join "`n") }
        default { return [string]$d }
    }
}

function Set-RawReg([string]$Path, [string]$Name, [string]$Kind, $Value) {
    $data = Convert-RegData $Kind $Value
    $h, $sub = Split-RegPath $Path
    $base = Open-RegBase $h
    try {
        $k = $base.CreateSubKey($sub)
        if ($null -eq $k) { throw ('Не открыть раздел ' + $Path) }
        try { $k.SetValue($Name, $data, [Microsoft.Win32.RegistryValueKind]$Kind) } finally { $k.Close() }
    } finally { $base.Close() }
}

function Remove-RawReg([string]$Path, [string]$Name) {
    $h, $sub = Split-RegPath $Path
    $base = Open-RegBase $h
    try {
        $k = $base.OpenSubKey($sub, $true)
        if ($null -eq $k) { return }
        try { $k.DeleteValue($Name, $false) } finally { $k.Close() }
    } finally { $base.Close() }
}

function Clear-Keys {
    try { while ([Console]::KeyAvailable) { [void][Console]::ReadKey($true) } } catch {}
}

function Read-Line {
    Clear-Keys
    $s = ''
    try { $s = [string](Read-Host '  ') } catch {}
    if ($null -eq $s) { $s = '' }
    return $s.Trim()
}

# Вопрос: цифра и Enter, пустой Enter = рекомендуемый ответ. Возвращает номер ответа
function Ask-Opt([string]$Question, [string]$Hint, [string[]]$Opts, [int]$Def) {
    Write-Host ''
    Write-Host ('  ' + $Question) -ForegroundColor White
    if ($Hint) { foreach ($h in ($Hint -split "`n")) { Write-Host ('  ' + $h) -ForegroundColor DarkGray } }
    for ($i = 0; $i -lt $Opts.Count; $i++) {
        $t = '     [' + ($i + 1) + '] ' + $Opts[$i]
        if (($i + 1) -eq $Def) { $t += '   [рекомендуется]' }
        Write-Host $t -ForegroundColor Cyan
    }
    $n = 0
    while ($true) {
        $in = Read-Line
        if ($in -eq '' -and $Def -gt 0) { $n = $Def; break }
        $n = 0
        if ([int]::TryParse($in, [ref]$n) -and $n -ge 1 -and $n -le $Opts.Count) { break }
        Write-Host '     Введи цифру из списка и нажми Enter.' -ForegroundColor Yellow
    }
    Write-Host ('     > ' + $Opts[$n - 1]) -ForegroundColor Green
    return $n
}

function Ask([string]$Question, [string]$Hint, [string]$Yes = 'Да', [string]$No = 'Нет', [int]$Def = 1) {
    return ((Ask-Opt $Question $Hint @($Yes, $No) $Def) -eq 1)
}

# Выбор из списка номерами через пробел. Items: N, Text, Pre (отмечено заранее)
function Ask-Multi([string]$Question, [string]$Hint, $Items) {
    Write-Host ''
    Write-Host ('  ' + $Question) -ForegroundColor White
    if ($Hint) { foreach ($h in ($Hint -split "`n")) { Write-Host ('  ' + $h) -ForegroundColor DarkGray } }
    foreach ($it in @($Items)) {
        $m = '[ ]'
        if ($it.Pre) { $m = '[x]' }
        Write-Host ('    ' + $it.N + '. ' + $m + ' ' + $it.Text)
    }
    Write-Host '  Номера через пробел и Enter. Пустой Enter: как отмечено [x]. 0: ничего.' -ForegroundColor DarkGray
    $pick = @()
    while ($true) {
        $in = Read-Line
        if ($in -eq '') { $pick = @(@($Items) | Where-Object { $_.Pre } | ForEach-Object { [int]$_.N }); break }
        if ($in -eq '0') { $pick = @(); break }
        $pick = @()
        $bad = $false
        foreach ($t in ($in -split '[\s,;]+')) {
            if (-not $t) { continue }
            $n = 0
            if ([int]::TryParse($t, [ref]$n) -and @(@($Items) | Where-Object { [int]$_.N -eq $n }).Count -gt 0) { $pick += $n } else { $bad = $true }
        }
        if (-not $bad) { break }
        Write-Host '     Только номера из списка, через пробел.' -ForegroundColor Yellow
    }
    $pick = @($pick | Select-Object -Unique)
    $txt = 'ничего'
    if ($pick.Count -gt 0) { $txt = ($pick -join ' ') }
    Write-Host ('     > ' + $txt) -ForegroundColor Green
    return $pick
}

function Wait-Key([string]$Text = '  Нажми любую клавишу, чтобы закрыть окно...') {
    Write-Host ''
    Write-Host $Text -ForegroundColor DarkGray
    Clear-Keys
    try { [void][Console]::ReadKey($true) } catch { Start-Sleep -Seconds 5 }
}

function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Admin {
    Write-Host ''
    Write-Host '  Нужны права администратора. Сейчас Windows спросит разрешение, нажми «Да».' -ForegroundColor Yellow
    try {
        $argList = @()
        if ($env:P3_ARG -match '^(1|2|4|5|6|7|9|10|12|13|after|reset)$') { $argList = @($env:P3_ARG) }
        $start = @{ FilePath = $env:P3_SELF; Verb = 'RunAs'; ErrorAction = 'Stop' }
        if ($argList.Count -gt 0) { $start.ArgumentList = $argList }
        Start-Process @start
    }
    catch {
        Write-Host '  Без прав администратора ничего не получится. Запусти файл ещё раз и нажми «Да».' -ForegroundColor Red
        Wait-Key
    }
}

function Invoke-Native([string]$Exe, [string[]]$ArgList) {
    $ErrorActionPreference = 'Continue'
    $out = & $Exe @ArgList 2>&1 | ForEach-Object { [string]$_ }
    [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}


# JSON is validated before replacing the current file. Never delete a good backup on failure.
function Write-JsonAtomic([string]$Path, $Object, [int]$Depth = 12) {
    if (Test-Path -LiteralPath $Path) {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw ('Файл бэкапа является ссылкой: ' + $Path) }
    }
    $text = ConvertTo-Json -InputObject $Object -Depth $Depth
    [void](ConvertFrom-Json $text -ErrorAction Stop)
    $tmp = $Path + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($tmp, $text, $Utf8NoBom)
        [void](ConvertFrom-Json ([IO.File]::ReadAllText($tmp, [Text.Encoding]::UTF8)) -ErrorAction Stop)
        if ([IO.File]::Exists($Path)) { [IO.File]::Replace($tmp, $Path, ($Path + '.bak')) }
        else { [IO.File]::Move($tmp, $Path) }
    } finally { if ([IO.File]::Exists($tmp)) { [IO.File]::Delete($tmp) } }
}

function Enter-BoostLock {
    if ($script:BoostLock) { return }
    [void][IO.Directory]::CreateDirectory($P3Root)
    try { $script:BoostLock = [IO.File]::Open((Join-Path $P3Root 'operation.lock'), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
    catch { throw 'Другой запуск BOOST уже меняет настройки. Закрой настройку, откат или игровой режим и повтори.' }
}
function Protect-BoostDirectory {
    $dir = Get-Item -LiteralPath $P3Root -Force -ErrorAction Stop
    if (($dir.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Папка бэкапа является ссылкой. Используй обычную локальную папку.' }
    $acl = New-Object Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    $me = [Security.Principal.WindowsIdentity]::GetCurrent().User
    $acl.SetOwner($me)
    foreach ($sid in @($me, (New-Object Security.Principal.SecurityIdentifier('S-1-5-18')), (New-Object Security.Principal.SecurityIdentifier('S-1-5-32-544')))) {
        $rule = New-Object Security.AccessControl.FileSystemAccessRule($sid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
        $acl.AddAccessRule($rule)
    }
    Set-Acl -LiteralPath $P3Root -AclObject $acl -ErrorAction Stop
}
function Exit-BoostLock {
    if ($script:BoostLock) { $script:BoostLock.Dispose(); $script:BoostLock = $null }
}

function Get-AppPackages([string]$Name, [bool]$AllUsers) {
    if ($AllUsers) { return @(Get-AppxPackage -AllUsers -Name $Name -ErrorAction Stop) }
    return @(Get-AppxPackage -Name $Name -ErrorAction Stop)
}
function Test-RemovalAllUsers($St, [string]$Name) {
    if (-not $St.RemovalScopeVersion) { return $true } # Original 3.0 used AllUsers.
    return (@($St.RemovedAllUsersPkgs) -contains $Name)
}

function Test-NvidiaBackupFiles([string]$Directory) {
    try {
        $files = @(Get-ChildItem -LiteralPath $Directory -Filter '*.bin' -File -ErrorAction Stop)
        if ($files.Count -eq 0 -or @($files | Where-Object { $_.Length -eq 0 }).Count -gt 0) { return $false }
        $manifestPath = Join-Path $Directory 'manifest.json'
        if (-not (Test-Path -LiteralPath $manifestPath)) { return $true } # Legacy backup: no hash manifest.
        $manifest = Read-Json $manifestPath
        if ($manifest.Schema -ne 1 -or @($manifest.Files).Count -ne $files.Count) { return $false }
        foreach ($file in $files) {
            $entry = @($manifest.Files | Where-Object { $_.Name -ceq $file.Name })
            if ($entry.Count -ne 1 -or $entry[0].Hash -notmatch '^[a-fA-F0-9]{64}$') { return $false }
            if ((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash -ne $entry[0].Hash) { return $false }
        }
        return $true
    } catch { return $false }
}

function Get-AfterReportTask {
    return @(Get-ScheduledTask -TaskPath '\' -ErrorAction Stop | Where-Object { $_.TaskName -eq $TaskAfter })
}
function Remove-AfterReportTask {
    foreach ($task in @(Get-AfterReportTask)) { Unregister-ScheduledTask -TaskName $TaskAfter -TaskPath '\' -Confirm:$false -ErrorAction Stop }
    if (@(Get-AfterReportTask).Count -gt 0) { throw 'Не удалось удалить задачу автоотчёта' }
}

function Read-Json([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    try { return (ConvertFrom-Json ([IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)) -ErrorAction Stop) }
    catch { throw ('Не удалось прочитать ' + $Path + '. Настройки остановлены. Сохрани файл и его .bak для восстановления. ' + $_.Exception.Message) }
}

function Get-BootMs($Since) {
    try {
        $e = Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Diagnostics-Performance/Operational'; Id = 100 } -MaxEvents 1 -ErrorAction Stop
    } catch { return $null }
    if (-not $e) { return $null }
    if ($Since -and $e.TimeCreated -lt $Since) { return $null }
    $x = [xml]$e.ToXml()
    $d = $x.Event.EventData.Data | Where-Object { $_.Name -eq 'BootTime' } | Select-Object -First 1
    if ($d) { return [int]$d.'#text' }
    return $null
}

function Get-Snapshot($Since) {
    $os = Get-CimInstance Win32_OperatingSystem
    [pscustomobject]@{
        BootMs    = (Get-BootMs $Since)
        RamUsedMB = [int][math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1024)
        Procs     = @(Get-Process -ErrorAction SilentlyContinue).Count
        Services  = @(Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Running' }).Count
        At        = (Get-Date).ToString('o')
    }
}

function Format-Boot($Ms) {
    if ($null -eq $Ms -or $Ms -le 0) { return 'нет данных' }
    return ('{0:N1} с' -f ($Ms / 1000))
}

# Окно консоли: без QuickEdit (клик мышью не замораживает батник), свернуть
$P3ConCode = @"
using System;
using System.Runtime.InteropServices;
public static class P3Con {
    [DllImport("kernel32.dll")] static extern IntPtr GetStdHandle(int n);
    [DllImport("kernel32.dll")] static extern bool GetConsoleMode(IntPtr h, out int m);
    [DllImport("kernel32.dll")] static extern bool SetConsoleMode(IntPtr h, int m);
    [DllImport("kernel32.dll")] static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int c);
    public static void NoQuickEdit() {
        IntPtr h = GetStdHandle(-10);
        int m;
        if (GetConsoleMode(h, out m)) { SetConsoleMode(h, (m & ~0x40) | 0x80); }
    }
    public static void Minimize() { ShowWindow(GetConsoleWindow(), 6); }
}
"@
function Set-NoQuickEdit {
    Set-BoostConsoleFont
    try { if (-not ('P3Con' -as [type])) { Add-Type -TypeDefinition $P3ConCode }; [P3Con]::NoQuickEdit() } catch {}
}

# Частота основного монитора: текущая, максимальная для текущего разрешения, смена частоты
$P3DisplayCode = @"
using System;
using System.Runtime.InteropServices;
public static class P3Display {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
        public short dmSpecVersion; public short dmDriverVersion; public short dmSize; public short dmDriverExtra;
        public int dmFields; public int dmPositionX; public int dmPositionY; public int dmDisplayOrientation; public int dmDisplayFixedOutput;
        public short dmColor; public short dmDuplex; public short dmYResolution; public short dmTTOption; public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
        public short dmLogPixels; public int dmBitsPerPel; public int dmPelsWidth; public int dmPelsHeight;
        public int dmDisplayFlags; public int dmDisplayFrequency;
        public int dmICMMethod; public int dmICMIntent; public int dmMediaType; public int dmDitherType;
        public int dmReserved1; public int dmReserved2; public int dmPanningWidth; public int dmPanningHeight;
    }
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);
}
"@
function Get-RefreshRate {
    if (-not ('P3Display' -as [type])) { Add-Type -TypeDefinition $P3DisplayCode }
    $dm = New-Object P3Display+DEVMODE
    $dm.dmSize = [int16][Runtime.InteropServices.Marshal]::SizeOf([type]'P3Display+DEVMODE')
    # -1 = текущий режим. [NullString] вместо $null: иначе PowerShell передаст пустую строку
    if (-not [P3Display]::EnumDisplaySettings([NullString]::Value, -1, [ref]$dm)) { return $null }
    $w = $dm.dmPelsWidth
    $h = $dm.dmPelsHeight
    $cur = $dm.dmDisplayFrequency
    $max = $cur
    $i = 0
    while ($i -lt 2000 -and [P3Display]::EnumDisplaySettings([NullString]::Value, $i, [ref]$dm)) {
        if ($dm.dmPelsWidth -eq $w -and $dm.dmPelsHeight -eq $h -and $dm.dmDisplayFrequency -gt $max) { $max = $dm.dmDisplayFrequency }
        $i++
    }
    return @{ Current = $cur; Max = $max; W = $w; H = $h; Res = ('' + $w + 'x' + $h) }
}

# Ставит частоту основному монитору для текущего разрешения. true = Windows приняла
function Set-RefreshRate([int]$Hz) {
    if (-not ('P3Display' -as [type])) { Add-Type -TypeDefinition $P3DisplayCode }
    $dm = New-Object P3Display+DEVMODE
    $dm.dmSize = [int16][Runtime.InteropServices.Marshal]::SizeOf([type]'P3Display+DEVMODE')
    if (-not [P3Display]::EnumDisplaySettings([NullString]::Value, -1, [ref]$dm)) { return $false }
    $dm.dmDisplayFrequency = $Hz
    $dm.dmFields = 0x400000
    # CDS_UPDATEREGISTRY = 1: частота остаётся после перезагрузки
    return ([P3Display]::ChangeDisplaySettings([ref]$dm, 1) -eq 0)
}

function Test-BitLockerOn {
    try {
        $v = Get-CimInstance -Namespace 'root/cimv2/Security/MicrosoftVolumeEncryption' -ClassName Win32_EncryptableVolume -Filter ("DriveLetter='" + $env:SystemDrive + "'") -ErrorAction Stop
        if (-not $v -or [int]$v.ProtectionStatus -notin @(0, 1)) { throw 'Состояние защиты тома неизвестно' }
        return ([int]$v.ProtectionStatus -eq 1)
    } catch { throw 'Не удалось определить состояние BitLocker. Загрузчик не меняется.' }
}

# Перед правкой загрузчика: BitLocker на паузу на одну перезагрузку, иначе Windows спросит ключ восстановления
function Suspend-BitLockerOnce {
    try { $on = Test-BitLockerOn } catch { Log ERR $_.Exception.Message; return $false }
    if (-not $on) { return $true }
    try { [void](Suspend-BitLocker -MountPoint $env:SystemDrive -RebootCount 1 -ErrorAction Stop); Log INFO 'BitLocker на паузе на одну перезагрузку (потом включится сам)'; return $true }
    catch { Log ERR ('BitLocker не встал на паузу, загрузчик не трогаю: ' + $_.Exception.Message); return $false }
}

# Изоляция ядра: работает ли VBS, включена ли «Целостность памяти», закреплена ли в UEFI
function Get-VbsState {
    $running = $false
    try {
        $dg = Get-CimInstance -Namespace 'root/Microsoft/Windows/DeviceGuard' -ClassName Win32_DeviceGuard -ErrorAction Stop
        $running = ([int]$dg.VirtualizationBasedSecurityStatus -eq 2)
    } catch {}
    $hvci = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'Enabled'
    $lock = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard' 'Locked'
    return @{ Running = $running; Hvci = ($hvci -and [int]$hvci.Value -eq 1); Locked = ($lock -and [int]$lock.Value -eq 1) }
}

# Значение загрузчика (bcdedit /enum {current}): строка значения или $null, если не задано
function Get-BcdValue([string]$Name) {
    $r = Invoke-Native 'bcdedit.exe' @('/enum', '{current}')
    if ($r.Code -ne 0) { throw ('загрузчик не прочитался: ' + $r.Out) }
    if ($r.Out -match ('(?m)^' + [regex]::Escape($Name) + '\s+(\S+)')) { return $Matches[1] }
    return $null
}

# Значение параметра схемы питания «от сети» из реестра (там его хранит powercfg)
function Get-PowerAc([string]$Scheme, [string]$Sub, [string]$Setting) {
    $v = Get-RegValue ('HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\' + $Scheme + '\' + $Sub + '\' + $Setting) 'ACSettingIndex'
    if ($v) { return [int64]$v.Value }
    return $null
}

function Get-ActiveScheme {
    $r = Invoke-Native 'powercfg.exe' @('/getactivescheme')
    if ($r.Out -match '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}') { return $Matches[0] }
    return $null
}

function Test-SchemeExists([string]$Guid) {
    if (-not $Guid) { return $false }
    return ((Invoke-Native 'powercfg.exe' @('/list')).Out -match [regex]::Escape($Guid))
}

function New-Shortcut([string]$Lnk, [string]$Target, [string]$ArgsLine, [string]$Dir, [string]$Icon, [string]$Desc, [int]$Style = 1) {
    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut($Lnk)
    $sc.TargetPath = $Target
    if ($ArgsLine) { $sc.Arguments = $ArgsLine }
    if ($Dir) { $sc.WorkingDirectory = $Dir }
    if ($Icon) { $sc.IconLocation = $Icon }
    $sc.Description = $Desc
    $sc.WindowStyle = $Style
    $sc.Save()
}
'@
. ([scriptblock]::Create($CommonCode))

# PLAYSIN BOOST 3.0 · playsin333
# ---------------------------------------------------------------------
#  Бэкап: каждое значение реестра запоминается ДО изменения, вместе с тем,
#  что поставили мы (по этому списку работают откат и самопроверка).
#  При повторном запуске исходное значение не перезаписывается.
# ---------------------------------------------------------------------
$RegBackup = New-Object System.Collections.ArrayList
$RegIndex  = @{}
$State     = @{}
$RegNote   = ''
$RegNoFix  = $false

function Save-RegBackup {
    $o = [ordered]@{ Sign = $BR.Sign; Items = $RegBackup.ToArray() }
    Write-JsonAtomic $RegFile $o 8
}

# Подпись первым полем, дальше всё остальное
function Save-State {
    $o = [ordered]@{ Sign = $BR.Sign }
    foreach ($k in @($State.Keys | Sort-Object)) { if ($k -ne 'Sign') { $o[$k] = $State[$k] } }
    Write-JsonAtomic $StateFile $o 12
}

function Initialize-Backup {
    if (-not (Test-Path -LiteralPath $P3Root)) { [void](New-Item -ItemType Directory -Path $P3Root -Force) }
    $old = Read-Json $RegFile
    if ($old -and $old.Items) {
        foreach ($e in @($old.Items | ForEach-Object { $_ })) {
            if ($null -eq $e) { continue }
            $e = [pscustomobject]@{ Path = [string]$e.Path; Name = [string]$e.Name; Existed = [bool]$e.Existed; Kind = $e.Kind; Value = $e.Value; NewKind = $e.NewKind; NewValue = $e.NewValue; Fix = [bool]$e.Fix; Note = [string]$e.Note }
            $RegIndex[($e.Path + '|' + $e.Name).ToLower()] = $RegBackup.Count
            [void]$RegBackup.Add($e)
        }
    }
    $s = Read-Json $StateFile
    if ($s) { foreach ($p in $s.PSObject.Properties) { $State[$p.Name] = $p.Value } }
    if (-not $State.Created) { $State.Created = (Get-Date).ToString('o') }
    if (-not $State.RemovalScopeVersion) {
        $State.RemovedAllUsersPkgs = @($State.RemovedPkgs | Where-Object { $_ })
        $State.RemovalScopeVersion = 1
    }
    $State.Product = 'BOOST'
    $State.Version = $P3Version
    $State.Build = 'free'
    $State.RolledBack = $false
    foreach ($k in @('Tasks', 'PowerDevs', 'RemovedApps', 'RemovedPkgs', 'DefExcl', 'PowerSet', 'Programs', 'GameRoots', 'GameProcs', 'GameClose', 'Runs')) {
        $State[$k] = @($State[$k] | Where-Object { $_ })
    }
    # Из JSON загрузчик приходит объектом, а писать в него нужно как в таблицу
    $bcd = @{}
    if ($State.Bcd -is [hashtable]) { $bcd = $State.Bcd }
    elseif ($State.Bcd) { foreach ($p in $State.Bcd.PSObject.Properties) { $bcd[$p.Name] = @{ Old = $p.Value.Old; New = $p.Value.New; Fix = [bool]$p.Value.Fix } } }
    $State.Bcd = $bcd
    $State.Runs = @($State.Runs) + (Get-Date).ToString('o')
    Save-RegBackup
    Save-State
}

function Backup-RegValue([string]$Path, [string]$Name, [string]$Kind, $Value) {
    $id = ($Path + '|' + $Name).ToLower()
    if (-not $RegIndex.ContainsKey($id)) {
        $cur = Get-RegValue $Path $Name
        $e = [pscustomobject]@{ Path = $Path; Name = $Name; Existed = $false; Kind = $null; Value = $null; NewKind = $Kind; NewValue = $Value; Fix = (-not $RegNoFix); Note = $RegNote }
        if ($null -ne $cur) { $e.Existed = $true; $e.Kind = $cur.Kind; $e.Value = $cur.Value }
        $RegIndex[$id] = $RegBackup.Count
        [void]$RegBackup.Add($e)
    } else {
        $e = $RegBackup[$RegIndex[$id]]
        $e.NewKind = $Kind
        $e.NewValue = $Value
        $e.Fix = (-not $RegNoFix)
        if ($RegNote) { $e.Note = $RegNote }
    }
    Save-RegBackup
}

function Set-Reg([string]$Path, [string]$Name, [string]$Kind, $Value) {
    Backup-RegValue $Path $Name $Kind $Value
    Set-RawReg $Path $Name $Kind $Value
}

# Spec: 'HIVE\путь|Имя|Тип|Значение'. После записи читаем назад
function Apply-Reg([string]$Title, [string[]]$Specs) {
    $script:RegNote = $Title
    $ok = 0
    $bad = @()
    foreach ($s in $Specs) {
        $p = $s.Split('|')
        try {
            Set-Reg $p[0] $p[1] $p[2] $p[3]
            $back = Get-RegValue $p[0] $p[1]
            if ($null -eq $back -or (Format-RegData $back.Kind $back.Value) -ne (Format-RegData $p[2] $p[3])) { throw 'после записи значение другое' }
            $ok++
        }
        catch { $bad += ($p[0] + '\' + $p[1] + ': ' + $_.Exception.Message) }
    }
    $script:RegNote = ''
    if ($bad.Count -eq 0) { Log OK ($Title + ' (' + $ok + ')') }
    else {
        Log ERR ($Title + ': не применилось ' + $bad.Count + ' из ' + $Specs.Count)
        foreach ($b in $bad) { Log INFO $b }
    }
}

function Disable-Svc([string[]]$Names) {
    $script:RegNote = 'служба'
    foreach ($n in $Names) {
        $path = 'HKLM\SYSTEM\CurrentControlSet\Services\' + $n
        $cur = Get-RegValue $path 'Start'
        if ($null -eq $cur) { Log SKIP ($n + ': такой службы нет'); continue }
        if ([int]$cur.Value -eq 4) { Log SKIP ($n + ': уже отключена'); continue }
        # Некоторые службы Windows закрывает от записи в реестр, тогда через sc.exe
        $done = $false
        Backup-RegValue $path 'Start' 'DWord' 4
        try { Set-RawReg $path 'Start' 'DWord' 4; $done = $true } catch {}
        if (-not $done) {
            $r = Invoke-Native 'sc.exe' @('config', $n, 'start=', 'disabled')
            $done = ($r.Code -eq 0)
        }
        $back = Get-RegValue $path 'Start'
        $done = ($done -and $back -and [int]$back.Value -eq 4)
        if ($done) {
            try { Stop-Service -Name $n -Force -ErrorAction Stop -WarningAction SilentlyContinue } catch {}
            Log OK ($n + ': отключена')
        } else { Log SKIP ($n + ': Windows защищает эту службу, пропускаю') }
    }
    $script:RegNote = ''
}

function Add-StateList([string]$Key, $Item) {
    if (@($State[$Key]) -notcontains $Item) { $State[$Key] = @(@($State[$Key]) + $Item | Where-Object { $_ }); Save-State }
}

# ---------------------------------------------------------------------
#  Железо и профиль
# ---------------------------------------------------------------------
# Объём видеопамяти из реестра драйвера: AdapterRAM 32-битный и на картах больше 4 ГБ врёт
function Get-GpuVram([string]$Name, $Vc) {
    foreach ($n in @(Get-RegSubKeys $GpuClass)) {
        if ($n -notmatch '^\d{4}$') { continue }
        $k = $GpuClass + '\' + $n
        try {
            $d = Get-RegValue $k 'DriverDesc'
            if (-not $d -or [string]$d.Value -ne $Name) { continue }
            $q = Get-RegValue $k 'HardwareInformation.qwMemorySize'
            if ($q) { return [math]::Round([double][uint64]$q.Value / 1GB, 1) }
            $m = Get-RegValue $k 'HardwareInformation.MemorySize'
            if ($m) {
                if ($m.Value -is [byte[]]) { $v = [BitConverter]::ToUInt32([byte[]]$m.Value, 0) }
                else { $v = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int32]$m.Value), 0) }
                return [math]::Round([double]$v / 1GB, 1)
            }
        } catch {}
    }
    if ($Vc -and $Vc.AdapterRAM) { return [math]::Round([double][uint32]$Vc.AdapterRAM / 1GB, 1) }
    return 0
}

function Get-GpuList {
    $list = @()
    foreach ($vc in @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)) {
        $name = [string]$vc.Name
        if (-not $name -or $name -match 'Microsoft Basic|Remote|Virtual|Parsec|Citrix|DisplayLink|Mirage|Indirect') { continue }
        $igpu = ($name -match 'Intel') -and ($name -notmatch 'Arc\b')
        if ($name -match 'Radeon\(TM\) Graphics|Radeon Graphics|Radeon\(TM\) Vega|Radeon Vega|Vega \d+ Graphics|Radeon\(TM\) \d{3}M|Radeon \d{3}M') { $igpu = $true }
        $disc = (-not $igpu) -and ($name -match 'NVIDIA|GeForce|Quadro|Radeon|FirePro|Arc\b')
        $date = $null
        try { if ($vc.DriverDate) { $date = [datetime]$vc.DriverDate } } catch {}
        $list += [pscustomobject]@{
            Name = $name; Pnp = [string]$vc.PNPDeviceID; Discrete = $disc
            Nvidia = ($name -match 'NVIDIA|GeForce|Quadro'); Amd = ($name -match 'Radeon|AMD|FirePro')
            VramGB = (Get-GpuVram $name $vc); DriverVer = [string]$vc.DriverVersion; DriverDate = $date
        }
    }
    return $list
}

# Слабая видеокарта: GTX до 1660 Ti и GTX 1070, RX 570–590, 5500 XT, 6500 XT, 4 ГБ и меньше, только встройка
function Test-WeakGpu($G) {
    $n = [string]$G.Name
    if ($G.VramGB -gt 0 -and $G.VramGB -le 4.1) { return @{ Weak = $true; Why = ('видеопамять ' + $G.VramGB + ' ГБ'); Known = $true } }
    if ($G.Nvidia) {
        if ($n -match 'RTX') { return @{ Weak = $false; Why = 'RTX'; Known = $true } }
        if ($n -match 'GTX\s*(\d{3,4})') {
            if ([int]$Matches[1] -eq 1080) { return @{ Weak = $false; Why = 'GTX 1080'; Known = $true } }
            return @{ Weak = $true; Why = 'GTX до 1660 Ti / 1070'; Known = $true }
        }
        if ($n -match '\bGT\s*\d{3,4}|\bMX\s*\d{3}|Quadro') { return @{ Weak = $true; Why = 'офисная или старая NVIDIA'; Known = $true } }
    }
    if ($G.Amd) {
        if ($n -match 'RX\s*Vega') { return @{ Weak = $true; Why = 'RX Vega'; Known = $true } }
        if ($n -match 'RX\s*(\d{3,4})') {
            $m = [int]$Matches[1]
            if ($m -lt 1000) { return @{ Weak = $true; Why = ('RX ' + $m); Known = $true } }
            if (@(5300, 5500, 6300, 6400, 6500) -contains $m) { return @{ Weak = $true; Why = ('RX ' + $m); Known = $true } }
            return @{ Weak = $false; Why = ('RX ' + $m); Known = $true }
        }
        if ($n -match '\bR9\b|\bR7\b|\bHD\s*\d') { return @{ Weak = $true; Why = 'старая Radeon'; Known = $true } }
    }
    if ($n -match 'Arc\b') { return @{ Weak = $false; Why = 'Intel Arc'; Known = $true } }
    if ($G.VramGB -gt 4.1) { return @{ Weak = $false; Why = 'карта не из списка, видеопамяти больше 4 ГБ'; Known = $false } }
    return @{ Weak = $true; Why = 'карта не из списка, видеопамять не определилась'; Known = $false }
}

# Поколение Intel Core по названию: i7-8700 → 8, i5-10400 → 10. Не Intel Core iX → 0
function Get-IntelGen([string]$Cpu) {
    if ($Cpu -notmatch 'Intel' -or $Cpu -notmatch 'i[3579]-(\d{4,5})') { return 0 }
    $num = $Matches[1]
    if ($num.Length -eq 5) { return [int]$num.Substring(0, 2) }
    return [int]$num.Substring(0, 1)
}

# Слабый процессор: Intel до 11 поколения, Ryzen на Zen, Zen+ и Zen 2 (1000–4000, 5300U/5500U/5700U, мобильные 7x2x)
function Test-WeakCpu([string]$Cpu) {
    if ($Cpu -match 'Intel') {
        if ($Cpu -match 'Core\(TM\) Ultra|Core Ultra') { return @{ Weak = $false; Why = 'Intel Core Ultra'; Known = $true } }
        if ($Cpu -match 'Pentium|Celeron|Atom|Processor N\d|\bN\d{2,3}\b|Core\(TM\)2|Core 2') { return @{ Weak = $true; Why = 'Pentium, Celeron или N-серия'; Known = $true } }
        $gen = Get-IntelGen $Cpu
        if ($gen -gt 0 -and $gen -le 11) { return @{ Weak = $true; Why = ('Intel ' + $gen + '-го поколения'); Known = $true } }
        if ($gen -ge 12) { return @{ Weak = $false; Why = ('Intel ' + $gen + '-го поколения'); Known = $true } }
        if ($Cpu -match 'Core\(TM\) i[3579] CPU|Core\(TM\) i[3579]\s+\d{3}\b') { return @{ Weak = $true; Why = 'Intel 1-го поколения'; Known = $true } }
        if ($Cpu -match 'Core\(TM\) [3579] \d{3}|Core [3579] \d{3}') { return @{ Weak = $false; Why = 'Intel Core новой серии'; Known = $true } }
        return @{ Weak = $false; Why = 'процессор не из списка'; Known = $false }
    }
    if ($Cpu -match 'AMD') {
        if ($Cpu -match 'Athlon|FX-|\bA\d{1,2}-|Phenom|Sempron|\bE\d-') { return @{ Weak = $true; Why = 'Athlon, FX или A-серия'; Known = $true } }
        if ($Cpu -match 'Ryzen\s*(?:Threadripper\s*)?(?:PRO\s*)?[3579]?\s*(?:PRO\s*)?(\d)(\d)(\d)(\d)([A-Za-z0-9]*)') {
            $s = [int]$Matches[1]
            $d3 = [int]$Matches[3]
            $suf = [string]$Matches[5]
            $model = [int]($Matches[1] + $Matches[2] + $Matches[3] + $Matches[4])
            $mobile = ($suf -match '^(U|H|HS|HX|HN)')
            if ($s -le 4) { return @{ Weak = $true; Why = ('Ryzen ' + $model + ' (Zen, Zen+ или Zen 2)'); Known = $true } }
            if ($s -eq 5 -and $suf -match '^U' -and @(5300, 5500, 5700) -contains $model) { return @{ Weak = $true; Why = ('Ryzen ' + $model + 'U (Zen 2)'); Known = $true } }
            if ($s -ge 7 -and $mobile -and $d3 -le 2) { return @{ Weak = $true; Why = ('Ryzen ' + $model + $suf + ' (Zen 2)'); Known = $true } }
            return @{ Weak = $false; Why = ('Ryzen ' + $model + $suf); Known = $true }
        }
        return @{ Weak = $false; Why = 'процессор не из списка'; Known = $false }
    }
    return @{ Weak = $false; Why = 'процессор не из списка'; Known = $false }
}

# Тип диска по букве: 'SSD', 'HDD' или '' (не определился)
function Get-DriveKind([string]$Letter) {
    try {
        $part = Get-Partition -DriveLetter $Letter -ErrorAction Stop
        $pd = Get-PhysicalDisk -ErrorAction Stop | Where-Object { [string]$_.DeviceId -eq [string]$part.DiskNumber } | Select-Object -First 1
        if (-not $pd) { return '' }
        $media = [string]$pd.MediaType
        $bus = [string]$pd.BusType
        if ($media -eq 'SSD' -or $media -eq '4' -or $bus -eq 'NVMe' -or $bus -eq '17') { return 'SSD' }
        if ($media -eq 'HDD' -or $media -eq '3') { return 'HDD' }
        if ($pd.SpindleSpeed -eq 0) { return 'SSD' }
    } catch {}
    return ''
}

# Где стоят игры: библиотеки Steam, Epic и папки Riot Games
function Get-GameFolders {
    $found = New-Object System.Collections.ArrayList
    $steam = Get-RegValue 'HKCU\Software\Valve\Steam' 'SteamPath'
    if ($steam) {
        $libs = @(([string]$steam.Value) -replace '/', '\')
        $vdf = Join-Path $libs[0] 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            foreach ($m in [regex]::Matches([IO.File]::ReadAllText($vdf), '"path"\s+"([^"]+)"')) { $libs += ($m.Groups[1].Value -replace '\\\\', '\') }
        }
        foreach ($lib in @($libs | Select-Object -Unique)) {
            $common = Join-Path $lib 'steamapps\common'
            if (-not (Test-Path -LiteralPath $common)) { continue }
            foreach ($g in @(Get-ChildItem -LiteralPath $common -Directory -ErrorAction SilentlyContinue)) {
                if ($g.Name -match 'Steamworks|Redist|Proton|Runtime') { continue }
                [void]$found.Add([pscustomobject]@{ Path = $g.FullName; Title = $g.Name })
            }
        }
    }
    $man = Join-Path $env:ProgramData 'Epic\EpicGamesLauncher\Data\Manifests'
    foreach ($f in @(Get-ChildItem -LiteralPath $man -Filter '*.item' -ErrorAction SilentlyContinue)) {
        try {
            $j = ConvertFrom-Json ([IO.File]::ReadAllText($f.FullName))
            if ($j.InstallLocation) { [void]$found.Add([pscustomobject]@{ Path = [string]$j.InstallLocation; Title = [string]$j.DisplayName }) }
        } catch {}
    }
    foreach ($drv in @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue)) {
        $riot = [string]$drv.DeviceID + '\Riot Games'
        if (-not (Test-Path -LiteralPath $riot)) { continue }
        foreach ($g in @(Get-ChildItem -LiteralPath $riot -Directory -ErrorAction SilentlyContinue)) {
            if ($g.Name -match 'Riot Client') { continue }
            [void]$found.Add([pscustomobject]@{ Path = $g.FullName; Title = $g.Name })
        }
    }
    return $found
}

# Папки для исключений Defender: steamapps\common целиком, Epic и Riot только папка самой игры
function Get-GameRoots {
    $roots = @()
    foreach ($g in @(Get-GameFolders)) {
        try { $p = Split-Path -Parent ([string]$g.Path) } catch { continue }
        if ($p -notmatch '\\steamapps\\common$') { $p = [string]$g.Path }
        if ($p -and $p -match '^[A-Za-z]:\\.+' -and (Test-Path -LiteralPath $p) -and $roots -notcontains $p) { $roots += $p }
    }
    return $roots
}

function Get-GameExes {
    $found = @()
    foreach ($g in @(Get-GameFolders)) {
        $dir = [string]$g.Path
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        foreach ($f in @(Get-ChildItem -LiteralPath $dir -Recurse -Depth 5 -File -Filter '*.exe' -ErrorAction SilentlyContinue | Where-Object { $GameExeNames -contains $_.Name })) {
            if ($found -notcontains $f.FullName) { $found += $f.FullName }
        }
    }
    return $found
}

# OneDrive: установлен ли и лежат ли в нём папки пользователя (тогда удалять нельзя)
function Get-OneDriveInfo {
    $setups = @()
    foreach ($p in @("$env:LOCALAPPDATA\Microsoft\OneDrive", "$env:ProgramFiles\Microsoft OneDrive", "${env:ProgramFiles(x86)}\Microsoft OneDrive")) {
        foreach ($f in @(Get-ChildItem -LiteralPath $p -Recurse -Depth 2 -Filter 'OneDriveSetup.exe' -File -ErrorAction SilentlyContinue)) { $setups += $f.FullName }
    }
    foreach ($f in @("$env:SystemRoot\System32\OneDriveSetup.exe", "$env:SystemRoot\SysWOW64\OneDriveSetup.exe")) { if (Test-Path -LiteralPath $f) { $setups += $f } }
    $installed = (Test-Path -LiteralPath "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe") -or (Test-Path -LiteralPath "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe") -or (Test-Path -LiteralPath "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe")
    $why = $null
    $shell = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    foreach ($n in @('Desktop', 'Personal', 'My Pictures', '{F42EE2D3-909F-4907-8871-4C22FC0BF756}')) {
        $v = Get-RegValue $shell $n
        if ($v -and [string]$v.Value -match 'OneDrive') { $why = 'рабочий стол, документы или изображения перенесены в OneDrive'; break }
    }
    if (-not $why) {
        foreach ($a in @(Get-RegSubKeys 'HKCU\Software\Microsoft\OneDrive\Accounts')) {
            $f = Get-RegValue ('HKCU\Software\Microsoft\OneDrive\Accounts\' + $a) 'UserFolder'
            if ($f -and (Test-Path -LiteralPath ([string]$f.Value))) {
                $cloud = @(Get-ChildItem -LiteralPath ([string]$f.Value) -Recurse -Force -File -ErrorAction SilentlyContinue | Select-Object -First 2000 | Where-Object { ([int]$_.Attributes -band 0x400000) -or ([int]$_.Attributes -band 0x1000) } | Select-Object -First 1)
                if ($cloud.Count -gt 0) { $why = 'в OneDrive есть файлы, которые лежат только в облаке'; break }
            }
        }
    }
    return @{ Installed = $installed; Setups = @($setups | Select-Object -Unique); Block = $why }
}

function Get-SystemInfo {
    $cv = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $build = [int](Get-RegValue $cv 'CurrentBuildNumber').Value
    $isWin11 = $build -ge 22000
    $edition = [string](Get-RegValue $cv 'ProductName').Value
    if ($isWin11) { $edition = $edition -replace 'Windows 10', 'Windows 11' }
    $dv = Get-RegValue $cv 'DisplayVersion'
    if ($null -eq $dv) { $dv = Get-RegValue $cv 'ReleaseId' }
    $ver = ''
    if ($dv) { $ver = ' ' + $dv.Value }

    $cs = Get-CimInstance Win32_ComputerSystem
    $ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB)
    $ramKB = [int64][math]::Floor($cs.TotalPhysicalMemory / 1KB)
    $cpu = ([string](@(Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue) | Select-Object -First 1).Name).Trim()

    $gpus = @(Get-GpuList)
    $dgpu = @($gpus | Where-Object { $_.Discrete })
    $main = $null
    if ($dgpu.Count -gt 0) { $main = $dgpu | Sort-Object -Property VramGB -Descending | Select-Object -First 1 }
    $isNvidia = ($main -and $main.Nvidia)
    $isAmd = ($main -and $main.Amd)

    # Память: тип, частота сейчас и на которую рассчитана. 26 = DDR4, 34 = DDR5, 24 = DDR3
    $ramMHz = 0; $ramRated = 0; $ramType = ''
    try {
        $mods = @(Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop)
        $ramMHz = [int](($mods | ForEach-Object { if ($_.ConfiguredClockSpeed) { [int]$_.ConfiguredClockSpeed } else { [int]$_.Speed } } | Measure-Object -Minimum).Minimum)
        $ramRated = [int](($mods | ForEach-Object { [int]$_.Speed } | Measure-Object -Minimum).Minimum)
        $t = [int](@($mods | ForEach-Object { $_.SMBIOSMemoryType }) | Select-Object -First 1)
        if ($t -eq 26) { $ramType = 'DDR4' } elseif ($t -eq 34) { $ramType = 'DDR5' } elseif ($t -eq 24) { $ramType = 'DDR3' }
    } catch {}

    # Ноутбук: по типу корпуса, батарея только если корпус не определился
    $laptopTypes = @(8, 9, 10, 11, 12, 14, 18, 21, 30, 31, 32)
    $chassis = @(Get-CimInstance Win32_SystemEnclosure -ErrorAction SilentlyContinue | ForEach-Object { $_.ChassisTypes })
    $hasBattery = @(Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue).Count -gt 0
    $isLaptop = @($laptopTypes | Where-Object { $chassis -contains $_ }).Count -gt 0
    $chassisUnknown = ($chassis.Count -eq 0) -or (@($chassis | Where-Object { @(1, 2) -notcontains $_ }).Count -eq 0)
    if (-not $isLaptop -and $hasBattery -and $chassisUnknown) { $isLaptop = $true }

    $kind = Get-DriveKind $env:SystemDrive.Substring(0, 1)
    $isSSD = ($kind -eq 'SSD')
    $diskNote = $kind
    if (-not $kind) { $diskNote = 'не определился, считаю HDD' }

    $rr = $null
    try { $rr = Get-RefreshRate } catch {}

    $wg = @{ Weak = $true; Why = 'только встроенная графика'; Known = $true }
    if ($main) { $wg = Test-WeakGpu $main }
    $wc = Test-WeakCpu $cpu
    $wr = ($cs.TotalPhysicalMemory / 1GB) -le 8.5

    $devs = @{ Printer = $false; Bluetooth = $false; Xbox = $false; Bio = $false }
    try { $devs.Printer = @(Get-CimInstance Win32_Printer -ErrorAction Stop | Where-Object { [string]$_.Name -notmatch 'PDF|XPS|OneNote|Fax|Факс' -and [string]$_.PortName -notmatch '^(PORTPROMPT|nul|FILE)' }).Count -gt 0 } catch {}
    try { $devs.Bluetooth = @(Get-PnpDevice -Class Bluetooth -PresentOnly -ErrorAction Stop | Where-Object { [string]$_.InstanceId -match '^USB\\|^PCI\\' -or [string]$_.FriendlyName -match 'Adapter|Radio|Адаптер' }).Count -gt 0 } catch {}
    try { $devs.Xbox = @(Get-AppxPackage -AllUsers -Name 'Microsoft.GamingApp' -ErrorAction Stop).Count -gt 0 } catch {}
    try { $devs.Bio = @(Get-PnpDevice -Class Biometric -PresentOnly -ErrorAction Stop).Count -gt 0 } catch {}

    $vgk = (Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Services\vgk' 'Start') -or (Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Services\vgc' 'Start')
    $faceit = [bool](Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Services\FACEIT' 'Start')

    return @{
        Build = $build; IsWin11 = $isWin11; Name = ($edition + $ver + ' (сборка ' + $build + ')')
        RamGB = $ramGB; RamKB = $ramKB; RamMHz = $ramMHz; RamRated = $ramRated; RamType = $ramType
        Cpu = $cpu; Gpus = $gpus; Gpu = (($gpus | ForEach-Object { $_.Name }) -join ' + '); Main = $main
        HasDGpu = ($dgpu.Count -gt 0); MultiGpu = ($gpus.Count -gt 1); IsNvidia = [bool]$isNvidia; IsAmdGpu = [bool]$isAmd
        IsLaptop = $isLaptop; IsSSD = $isSSD; DiskNote = $diskNote; Refresh = $rr
        WeakGpu = $wg; WeakCpu = $wc; WeakRam = $wr; Devices = $devs; Vanguard = [bool]$vgk; Faceit = $faceit
    }
}

# Профиль: ноутбук по корпусу, иначе слабый ПК при любом слабом пункте, иначе мощный
function Get-AutoProfile($Sys) {
    if ($Sys.IsLaptop) { return 'Laptop' }
    if ($Sys.WeakGpu.Weak -or $Sys.WeakCpu.Weak -or $Sys.WeakRam) { return 'Weak' }
    return 'Strong'
}

$ProfileTitle = @{ Weak = 'ПК с ограничением CPU, RAM или GPU'; Strong = 'ПК без выявленных ограничений по эвристике'; Laptop = 'Ноутбук' }

# PLAYSIN BOOST 3.0 · playsin333
# ---------------------------------------------------------------------
#  Видеокарта: профиль NVIDIA и настройки AMD Adrenalin
# ---------------------------------------------------------------------
# Настройки глобального профиля NVIDIA: имя в Profile Inspector, ID, значение
function Get-NvSettings([bool]$WeakVideo, [bool]$Ultra) {
    $set = @(
        @('Power management mode', 274197361, 1),
        @('Maximum pre-rendered frames', 8102046, 1),
        @('Ultra Low Latency - CPL State', 390467, 1),
        @('Texture filtering - Quality', 13510289, 20),
        @('Anisotropic filter - Sample Optimization', 15151633, 1),
        @('Shader Cache - Cache Size', 11306135, 4294967295),
        @('Antialiasing - FXAA Enabled', 276089202, 0),
        @('Antialiasing - MFAA Enabled', 10011052, 0),
        @('Ambient Occlusion - Setting', 6714153, 0)
    )
    if ($Ultra) {
        $set[2] = @('Ultra Low Latency - CPL State', 390467, 2)
        $set += ,@('Ultra Low Latency - Enabled', 277041152, 1)
    }
    # Слабой видеокарте помогает ещё потоковая и трилинейная оптимизация
    if ($WeakVideo) {
        $set += ,@('Threaded optimization', 549528094, 1)
        $set += ,@('Texture filtering - Trilinear optimization', 3066610, 0)
    }
    return $set
}

function Write-NvNip([string]$Path, $Set) {
    $xml = @('<?xml version="1.0" encoding="utf-16"?>', '<ArrayOfProfile>', '  <Profile>', '    <ProfileName>Base Profile</ProfileName>', '    <Executeables />', '    <Settings>')
    foreach ($s in $Set) {
        $xml += @('      <ProfileSetting>', ('        <SettingNameInfo>' + $s[0] + '</SettingNameInfo>'), ('        <SettingID>' + $s[1] + '</SettingID>'), ('        <SettingValue>' + $s[2] + '</SettingValue>'), '        <ValueType>Dword</ValueType>', '      </ProfileSetting>')
    }
    $xml += @('    </Settings>', '  </Profile>', '</ArrayOfProfile>')
    [IO.File]::WriteAllText($Path, ($xml -join "`r`n"), [Text.Encoding]::Unicode)
}

# AMD Radeon: Anti-Lag, Chill, Boost в разделе видеокарты, остальное в UMD цифрами в UTF-16.
# Меняем только то, что у драйвера уже есть
function Get-AmdGpuKeys([bool]$SkipIgpu) {
    $keys = @()
    foreach ($n in @(Get-RegSubKeys $GpuClass)) {
        if ($n -notmatch '^\d{4}$') { continue }
        $k = $GpuClass + '\' + $n
        try {
            $desc = [string](Get-RegValue $k 'DriverDesc').Value
            $prov = Get-RegValue $k 'ProviderName'
            if (-not ($desc -match 'Radeon|AMD' -or ($prov -and [string]$prov.Value -match 'Advanced Micro Devices|AMD'))) { continue }
            # Встроенная Radeon в процессоре: через неё идёт экран ноутбука, не трогаем
            if ($SkipIgpu -and $desc -match 'Radeon\(TM\) Graphics|Radeon Graphics|Vega \d+ Graphics|Radeon\(TM\) Vega|Radeon Vega|Radeon\(TM\) \d{3}M|Radeon \d{3}M') { continue }
            if (@(Get-RegSubKeys $k) -contains 'UMD') { $keys += [pscustomobject]@{ Key = $k; Title = $desc } }
        } catch {}
    }
    return $keys
}

function Set-AmdUmd([string]$Key, [string]$Name, [string]$Digits) {
    $cur = Get-RegValue ($Key + '\UMD') $Name
    if ($null -eq $cur) { return $false }
    $hex = (([Text.Encoding]::Unicode.GetBytes($Digits)) | ForEach-Object { $_.ToString('X2') }) -join ''
    Set-Reg ($Key + '\UMD') $Name 'Binary' $hex
    return $true
}

function Set-AmdKmd([string]$Key, [string]$Name, [int]$Value) {
    $cur = Get-RegValue $Key $Name
    if ($null -eq $cur) { return $false }
    Set-Reg $Key $Name 'DWord' $Value
    return $true
}

function Apply-AmdProfile([bool]$WeakVideo, [bool]$SkipIgpu, [bool]$ChangeQuality = $true) {
    $gpus = @(Get-AmdGpuKeys $SkipIgpu)
    if ($gpus.Count -eq 0) { Log SKIP 'Нет ключей Adrenalin (драйвер без панели или видеокарта не Radeon), пропускаю'; return $false }
    $script:RegNote = 'AMD Adrenalin'
    $any = $false
    foreach ($g in $gpus) {
        $done = @()
        try {
            if (Set-AmdKmd $g.Key 'KMD_DeLagEnabled' 1) { $done += 'Anti-Lag вкл' }
            if (Set-AmdKmd $g.Key 'KMD_ChillEnabled' 0) { $done += 'Chill выкл' }
            if (Set-AmdKmd $g.Key 'KMD_RadeonBoostEnabled' 0) { $done += 'Boost выкл' }
            if (Set-AmdUmd $g.Key 'TurboSync' '0') { $done += 'Enhanced Sync выкл' }
            if ($ChangeQuality) {
            if (Set-AmdUmd $g.Key 'TFQ' '2') { $done += 'фильтрация текстур «Производительность»' }
            if (Set-AmdUmd $g.Key 'SurfaceFormatReplacements' '1') { $done += 'оптимизация формата поверхности вкл' }
            if ($WeakVideo) {
                if ((Set-AmdUmd $g.Key 'Tessellation_OPTION' '2') -and (Set-AmdUmd $g.Key 'Tessellation' '1')) { $done += 'тесселяция выкл' }
            }
            }
            if ($done.Count -gt 0) { $any = $true; Log OK ($g.Title + ': ' + ($done -join ', ') + ' (после перезагрузки)') }
            else { Log SKIP ($g.Title + ': у этого драйвера нет знакомых настроек, Adrenalin руками') }
        } catch { Log ERR ($g.Title + ': ' + $_.Exception.Message) }
    }
    $script:RegNote = ''
    return $any
}

# ---------------------------------------------------------------------
#  Сеть и устройства
# ---------------------------------------------------------------------
function Get-NicClassKey([string]$Guid) {
    foreach ($n in @(Get-RegSubKeys $NetClass)) {
        if ($n -notmatch '^\d{4}$') { continue }
        try {
            $id = Get-RegValue ($NetClass + '\' + $n) 'NetCfgInstanceId'
            if ($id -and ([string]$id.Value).Trim('{}') -ieq $Guid.Trim('{}')) { return ($NetClass + '\' + $n) }
        } catch {}
    }
    return $null
}

function Get-PhysicalNics {
    $list = @()
    foreach ($a in @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { [string]$_.Status -ne 'Disabled' })) {
        $wifi = ([string]$a.PhysicalMediaType -match '802\.11|Wireless') -or ([string]$a.NdisPhysicalMedium -match '^9$|Native802_11') -or ([string]$a.InterfaceDescription -match 'Wi-?Fi|Wireless|802\.11|WLAN')
        $list += [pscustomobject]@{ Name = [string]$a.Name; Desc = [string]$a.InterfaceDescription; Guid = [string]$a.InterfaceGuid; Pnp = [string]$a.PnPDeviceID; Wifi = $wifi }
    }
    return $list
}

# Галочка «Разрешить отключение этого устройства для экономии энергии». Откат ставит обратно
function Disable-DevicePowerOff([string[]]$Prefixes) {
    $done = 0
    $items = @(Get-CimInstance -Namespace 'root/wmi' -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue)
    foreach ($it in $items) {
        $name = [string]$it.InstanceName
        $hit = $false
        foreach ($p in $Prefixes) { if ($p -and $name.StartsWith($p, [StringComparison]::OrdinalIgnoreCase)) { $hit = $true; break } }
        if (-not $hit -or -not $it.Enable) { continue }
        Add-StateList 'PowerDevs' $name
        try {
            Set-CimInstance -InputObject $it -Property @{ Enable = $false } -ErrorAction Stop
            $done++
        } catch {}
    }
    return $done
}

# ---------------------------------------------------------------------
#  Автозагрузка (то же, что вкладка «Автозагрузка» в диспетчере задач)
# ---------------------------------------------------------------------
$SysAppData = 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData'

function Test-Approved([string]$Path, [string]$Name) {
    $v = Get-RegValue $Path $Name
    if ($null -eq $v -or $v.Kind -ne 'Binary') { return $true }
    $b = [byte[]]$v.Value
    if ($b.Length -eq 0) { return $true }
    return (($b[0] -band 1) -eq 0)
}

function Get-StartupItems {
    $items = New-Object System.Collections.ArrayList
    $runs = @(
        @('HKCU\Software\Microsoft\Windows\CurrentVersion\Run', 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'),
        @('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'),
        @('HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run', 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32')
    )
    foreach ($r in $runs) {
        foreach ($n in @(Get-RegNames $r[0])) {
            if (-not $n) { continue }
            $v = Get-RegValue $r[0] $n
            [void]$items.Add([pscustomobject]@{ Kind = 'run'; Name = $n; Title = $n; Command = [string]$v.Value; Appr = $r[1]; Enabled = (Test-Approved $r[1] $n) })
        }
    }
    $folders = @(
        @([Environment]::GetFolderPath('Startup'), 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder'),
        @([Environment]::GetFolderPath('CommonStartup'), 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder')
    )
    foreach ($f in $folders) {
        if (-not $f[0] -or -not (Test-Path -LiteralPath $f[0])) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $f[0] -File -Force -ErrorAction SilentlyContinue)) {
            if ($file.Name -ieq 'desktop.ini') { continue }
            [void]$items.Add([pscustomobject]@{ Kind = 'run'; Name = $file.Name; Title = $file.BaseName; Command = $file.FullName; Appr = $f[1]; Enabled = (Test-Approved $f[1] $file.Name) })
        }
    }
    foreach ($pkg in @(Get-RegSubKeys $SysAppData)) {
        foreach ($task in @(Get-RegSubKeys ($SysAppData + '\' + $pkg))) {
            $key = $SysAppData + '\' + $pkg + '\' + $task
            $st = Get-RegValue $key 'State'
            if ($null -eq $st) { continue }
            [void]$items.Add([pscustomobject]@{ Kind = 'appx'; Name = $task; Title = ($pkg -split '_')[0]; Command = $pkg; Appr = $key; Enabled = (@(2, 4) -contains [int]$st.Value) })
        }
    }
    return $items.ToArray()
}

# Мусор в автозагрузке, который выключаем всегда (как в Max 2.0). OneDrive только если в нём не лежат папки пользователя
function Test-AutoOff($It, [bool]$KeepOneDrive) {
    $s = $It.Name + ' ' + $It.Command
    if (-not $KeepOneDrive -and $s -match 'OneDrive') { return $true }
    return ($s -match 'MicrosoftEdgeAutoLaunch|msedge\.exe.*--no-startup-window|MSTeams|MicrosoftTeams|com\.squirrel\.Teams|TeamsMachine')
}

function Disable-StartupItem($It) {
    $script:RegNote = 'автозагрузка'
    if ($It.Kind -eq 'appx') { Set-Reg $It.Appr 'State' 'DWord' 1 }
    else { Set-Reg $It.Appr $It.Name 'Binary' '030000000000000000000000' }
    $script:RegNote = ''
}

# ---------------------------------------------------------------------
#  Встроенные приложения
# ---------------------------------------------------------------------
# Store, Калькулятор, Фото, Терминал, панели драйверов и утилиты ноутбуков не трогаем. Список можно дополнять
$JunkApps = @(
    'Microsoft.BingNews|Новости',
    'Microsoft.BingWeather|Погода',
    'Microsoft.GetHelp|Техническая поддержка',
    'Microsoft.Getstarted|Советы',
    'Microsoft.MicrosoftSolitaireCollection|Solitaire',
    'Microsoft.WindowsMaps|Карты',
    'Microsoft.People|Люди',
    'microsoft.windowscommunicationsapps|Почта и Календарь',
    'Microsoft.OutlookForWindows|Outlook (new)',
    'Clipchamp.Clipchamp|Clipchamp',
    'Microsoft.549981C3F5F10|Cortana',
    'Microsoft.YourPhone|Связь с телефоном',
    'Microsoft.WindowsFeedbackHub|Центр отзывов',
    'Microsoft.MicrosoftOfficeHub|Microsoft 365 (реклама Office)',
    'Microsoft.Todos|Microsoft To Do',
    'Microsoft.PowerAutomateDesktop|Power Automate',
    'Microsoft.BingSearch|Поиск Bing',
    'Microsoft.ZuneVideo|Кино и ТВ',
    'Microsoft.MixedReality.Portal|Портал смешанной реальности',
    'Microsoft.Microsoft3DViewer|Средство 3D-просмотра',
    'Microsoft.SkypeApp|Skype',
    'Microsoft.Copilot|Copilot',
    'Microsoft.Windows.DevHome|Dev Home',
    '*CandyCrush*|Candy Crush',
    '*Disney*|Disney+',
    '*TikTok*|TikTok',
    '*Facebook*|Facebook',
    '*Instagram*|Instagram',
    '*SpotifyAB.SpotifyMusic*|Spotify (предустановленный)'
)
$XboxApps = @('Microsoft.GamingApp|Xbox', 'Microsoft.XboxApp|Компаньон консоли Xbox')

function Find-JunkApps([bool]$WithXbox, [bool]$AllUsers = $false) {
    $found = @()
    $specs = $JunkApps
    if ($WithXbox) { $specs = $specs + $XboxApps }
    foreach ($s in $specs) {
        $p = $s.Split('|')
        $pk = @(Get-AppPackages $p[0] $AllUsers)
        if ($pk.Count -gt 0) { $found += [pscustomobject]@{ Name = $p[0]; Title = $p[1]; Packages = $pk; AllUsers = $AllUsers } }
    }
    return $found
}

function Remove-JunkApp($App) {
    $all = [bool]$App.AllUsers
    try {
        Add-StateList 'RemovedApps' $App.Title
        Add-StateList 'RemovedPkgs' $App.Name
        if ($all) { Add-StateList 'RemovedAllUsersPkgs' $App.Name }
        foreach ($pkg in @(Get-AppPackages $App.Name $all | Sort-Object -Property PackageFullName -Unique)) {
            if ($all) { Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop }
            else { Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop }
        }
        if ($all) {
            foreach ($pkg in @(Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object { $_.DisplayName -like $App.Name })) {
                [void](Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction Stop)
            }
            Add-StateList 'RemovedAllUsersPkgs' $App.Name
        }
        if (@(Get-AppPackages $App.Name $all).Count -gt 0) { throw 'Часть пакетов осталась установлена' }
        return $true
    } catch { Log ERR ('Удаление ' + $App.Title + ': ' + $_.Exception.Message);return $false }
}

# Классический Windows Media Player: компонент Windows (в 11 бывает «компонентом по запросу»)
function Enable-ClassicWmp {
    $wmp = Join-Path ${env:ProgramFiles(x86)} 'Windows Media Player\wmplayer.exe'
    if (Test-Path -LiteralPath $wmp) {
        try {
            $f = Get-WindowsOptionalFeature -Online -FeatureName 'WindowsMediaPlayer' -ErrorAction Stop
            if ([string]$f.State -eq 'Enabled') { return $true }
        } catch { return $true }
    }
    try {
        $f = Get-WindowsOptionalFeature -Online -FeatureName 'WindowsMediaPlayer' -ErrorAction Stop
        if ($f -and [string]$f.State -ne 'Enabled') { [void](Enable-WindowsOptionalFeature -Online -FeatureName 'WindowsMediaPlayer' -All -NoRestart -ErrorAction Stop) }
        if ($f) { return $true }
    } catch {}
    try {
        $cap = @(Get-WindowsCapability -Online -ErrorAction Stop | Where-Object { $_.Name -like 'Media.WindowsMediaPlayer*' }) | Select-Object -First 1
        if ($cap) {
            if ([string]$cap.State -ne 'Installed') { [void](Add-WindowsCapability -Online -Name $cap.Name -ErrorAction Stop) }
            return $true
        }
    } catch {}
    return $false
}

# ---------------------------------------------------------------------
#  Программы: только скачиваем с официальных источников и ставим, ничего не настраиваем.
#  Сначала winget (сверяет хеш установщика), если его нет: прямая ссылка с сайта.
#  Ссылки держим здесь, чтобы их было легко поправить
# ---------------------------------------------------------------------
$Programs = @(
    [pscustomobject]@{ N = 1; Id = 'BitSum.ProcessLasso'; Title = 'Process Lasso'; Why = 'держит игру в приоритете, фон не мешает'; Site = 'bitsum.com'; Url = 'https://dl.bitsum.com/files/processlassosetup64.exe'; Page = ''; Rx = '' },
    [pscustomobject]@{ N = 2; Id = 'Wagnardsoft.ISLC'; Title = 'ISLC'; Why = 'чистит список ожидания памяти, помогает при статтерах'; Site = 'wagnardsoft.com'; Url = ''; Page = 'https://www.wagnardsoft.com/'; Rx = 'https?://[^"''\s<>]*ISLC[^"''\s<>]*\.exe' },
    [pscustomobject]@{ N = 3; Id = 'Guru3D.Afterburner'; Title = 'MSI Afterburner с RTSS'; Why = 'счётчик FPS, ровный лимит кадров, мониторинг'; Site = 'msi.com'; Url = 'https://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip'; Page = ''; Rx = '' },
    [pscustomobject]@{ N = 4; Id = 'CXWorld.CapFrameX'; Title = 'CapFrameX'; Why = 'замер FPS и 1% low, температуры и частоты'; Site = 'capframex.com'; Url = ''; Page = 'https://api.github.com/repos/CXWorld/CapFrameX/releases/latest'; Rx = 'https://github\.com/CXWorld/CapFrameX/releases/download/[^"]+\.(?:exe|msi|zip)' },
    [pscustomobject]@{ N = 5; Id = 'REALiX.HWiNFO'; Title = 'HWiNFO'; Why = 'температуры, прямо пишет троттлинг'; Site = 'hwinfo.com'; Url = ''; Page = 'https://www.hwinfo.com/download/'; Rx = 'https?://[^"''\s<>]*hwi(?:64)?_\d+\.exe' }
)

function Get-Winget {
    $c = Get-Command 'winget.exe' -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $p = @(Get-ChildItem -Path (Join-Path $env:ProgramFiles 'WindowsApps') -Filter 'Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1)
    if ($p.Count -gt 0) {
        $w = Join-Path $p[0].FullName 'winget.exe'
        if (Test-Path -LiteralPath $w) { return $w }
    }
    return $null
}

function Save-Download([string]$Url, [string]$Dir) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $name = [IO.Path]::GetFileName(([Uri]$Url).AbsolutePath)
    if (-not $name) { $name = 'setup.exe' }
    $dst = Join-Path $Dir $name
    Invoke-WebRequest -Uri $Url -OutFile $dst -UseBasicParsing -TimeoutSec 180 -Headers @{ 'User-Agent' = 'Mozilla/5.0' }
    return $dst
}

function Find-DownloadUrl($P) {
    if ($P.Url) { return $P.Url }
    if (-not $P.Page) { return $null }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $html = (Invoke-WebRequest -Uri $P.Page -UseBasicParsing -TimeoutSec 60 -Headers @{ 'User-Agent' = 'Mozilla/5.0' }).Content
    $m = [regex]::Match($html, $P.Rx)
    if ($m.Success) { return $m.Value }
    return $null
}

# Ставит одну программу. Возвращает строку для лога; бросает исключение, если не вышло
function Install-Program($P, [string]$Winget) {
    $dir = Join-Path $ProgDir $P.Title
    [void](New-Item -ItemType Directory -Path $dir -Force)
    if ($Winget) {
        $common = @('--id', $P.Id, '-e', '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity')
        [void](Invoke-Native $Winget (@('download') + $common + @('-d', $dir)))
        $r = Invoke-Native $Winget (@('install') + $common + @('--silent'))
        # 0 = поставлено, -1978335189 и -1978335135 = уже стоит
        if ($r.Code -eq 0 -or $r.Code -eq -1978335189 -or $r.Code -eq -1978335135) {
            if ($r.Code -eq 0) { return 'поставлен через winget (установщик с официального источника, хеш проверен)' }
            return 'уже стоит последней версии'
        }
        Log INFO ($P.Title + ': winget не справился (код ' + $r.Code + '), качаю с ' + $P.Site)
    }
    $url = Find-DownloadUrl $P
    if (-not $url) { throw ('ссылка на ' + $P.Site + ' не нашлась, скачать руками') }
    $file = Save-Download $url $dir
    if ($file -match '\.zip$') {
        $ex = Join-Path $dir 'распаковано'
        Expand-Archive -LiteralPath $file -DestinationPath $ex -Force
        $exe = @(Get-ChildItem -LiteralPath $ex -Recurse -Filter '*.exe' -File | Select-Object -First 1)
        if ($exe.Count -eq 0) { throw 'в архиве нет установщика' }
        $file = $exe[0].FullName
    }
    $sig = Get-AuthenticodeSignature -FilePath $file
    if ([string]$sig.Status -ne 'Valid') { throw ('у установщика нет действительной подписи (' + $sig.Status + '), не запускаю. Файл: ' + $file) }
    if ($P.Id -eq 'Wagnardsoft.ISLC') { return ('скачан в «' + (Split-Path -Leaf $ProgDir) + '», распаковать вместе с продавцом') }
    Write-Host ('   Открываю установщик ' + $P.Title + ', пройди его до конца...') -ForegroundColor Yellow
    $pr = Start-Process -FilePath $file -PassThru
    [void]$pr.WaitForExit(900000)
    return ('скачан с ' + $P.Site + ', подпись проверена, установщик пройден')
}

# Process Lasso: не запускаем, автозапуск выключаем до настройки с продавцом (иначе он меняет схему питания)
function Stop-Lasso {
    foreach ($n in @('ProcessLasso', 'ProcessGovernor', 'bitsumsessionagent')) {
        Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object { try { Stop-Process -Id $_.Id -Force -ErrorAction Stop } catch {} }
    }
    $off = 0
    foreach ($it in @(Get-StartupItems | Where-Object { $_.Enabled -and (($_.Name + ' ' + $_.Command) -match 'ProcessLasso|ProcessGovernor|Bitsum') })) {
        try { Disable-StartupItem $it; $off++ } catch {}
    }
    foreach ($s in @(Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'ProcessGovernor|Bitsum' -or $_.DisplayName -match 'Process Lasso|Process Governor' })) {
        try {
            $script:RegNote = 'Process Lasso до настройки'
            Set-Reg ('HKLM\SYSTEM\CurrentControlSet\Services\' + $s.Name) 'Start' 'DWord' 3
            $script:RegNote = ''
            Stop-Service -Name $s.Name -Force -ErrorAction SilentlyContinue
            $off++
        } catch {}
    }
    foreach ($t in @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Process Lasso|ProcessLasso|ProcessGovernor' -and [string]$_.State -ne 'Disabled' })) {
        try { [void](Disable-ScheduledTask -TaskPath $t.TaskPath -TaskName $t.TaskName -ErrorAction Stop); Add-StateList 'Tasks' ($t.TaskPath + '|' + $t.TaskName); $off++ } catch {}
    }
    return $off
}

# ---------------------------------------------------------------------
#  Было / стало (как в Input Lag 1.0)
# ---------------------------------------------------------------------
function Get-GpuMsiState($Sys) {
    if (-not $Sys.Main -or [string]$Sys.Main.Pnp -notmatch '^PCI\\') { return 'нет отд. видеокарты' }
    $v = Get-RegValue ('HKLM\SYSTEM\CurrentControlSet\Enum\' + $Sys.Main.Pnp + '\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties') 'MSISupported'
    if ($v -and [int]$v.Value -eq 1) { return 'вкл' }
    return 'выкл'
}

function Get-SchemeName {
    $r = Invoke-Native 'powercfg.exe' @('/getactivescheme')
    if ($r.Out -match '\(([^)]+)\)\s*$') { return $Matches[1] }
    return '?'
}

function Get-LagState($Sys) {
    $s = [ordered]@{}
    try {
        $rr = Get-RefreshRate
        if ($rr) { $s['Частота монитора'] = ('' + $rr.Current + ' из ' + $rr.Max + ' Гц') } else { $s['Частота монитора'] = '?' }
    } catch { $s['Частота монитора'] = '?' }
    $ms = Get-RegValue 'HKCU\Control Panel\Mouse' 'MouseSpeed'
    if ($ms -and [string]$ms.Value -eq '0') { $s['Акселерация мыши'] = 'выкл' } else { $s['Акселерация мыши'] = 'вкл' }
    $s['Схема питания'] = Get-SchemeName
    $pc = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation'
    if ($pc) { $s['Приоритет окна'] = ('0x' + ([int]$pc.Value).ToString('X')) } else { $s['Приоритет окна'] = 'стандарт' }
    $gm = Get-RegValue 'HKCU\Software\Microsoft\GameBar' 'AutoGameModeEnabled'
    if ($gm -and [int]$gm.Value -eq 0) { $s['Режим игры'] = 'выкл' } else { $s['Режим игры'] = 'вкл' }
    $dvr = Get-RegValue 'HKCU\System\GameConfigStore' 'GameDVR_Enabled'
    if ($dvr -and [int]$dvr.Value -eq 0) { $s['Фоновая запись игр'] = 'выкл' } else { $s['Фоновая запись игр'] = 'вкл' }
    $hw = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode'
    $caps=Get-HagsCapability $Sys
    if (-not $caps.Known) {$s['Аппаратное план. GPU']='состояние драйвера неизвестно'}
    elseif (-not $caps.Supported) {$s['Аппаратное план. GPU']='не поддерживается текущим драйвером'}
    elseif ($caps.Enabled) {$s['Аппаратное план. GPU']='вкл (подтверждено драйвером)'}
    elseif ($hw -and [int]$hw.Value -eq 2) {$s['Аппаратное план. GPU']='запрошено, драйвер пока не включил; требуется перезагрузка'}
    else {$s['Аппаратное план. GPU']='выкл (по драйверу)'}
    if ($Sys.IsWin11) {
        $dx = Get-RegValue 'HKCU\Software\Microsoft\DirectX\UserGpuPreferences' 'DirectXUserGlobalSettings'
        if ($dx -and [string]$dx.Value -match 'SwapEffectUpgradeEnable=1') { $s['Игры в окне без задержки'] = 'вкл' } else { $s['Игры в окне без задержки'] = 'стандарт' }
        $gt = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests'
        if ($gt -and [int]$gt.Value -eq 1) { $s['Точный таймер'] = 'вкл' } else { $s['Точный таймер'] = 'выкл' }
    }
    $s['MSI mode видеокарты'] = Get-GpuMsiState $Sys
    $bg = Get-RegValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled'
    if ($bg -and [int]$bg.Value -eq 1) { $s['Фоновые приложения'] = 'выкл' } else { $s['Фоновые приложения'] = 'вкл' }
    $v = Get-VbsState
    if ($v.Running -or $v.Hvci) { $s['VBS (изоляция ядра)'] = 'вкл' } else { $s['VBS (изоляция ядра)'] = 'выкл' }
    $s['Автозагрузка, шт.'] = [string]@(Get-StartupItems | Where-Object { $_.Enabled }).Count
    return $s
}

function Get-Cell([string]$V) { if ($V.Length -gt 27) { return $V.Substring(0, 26) + '…' }; return $V }

# PLAYSIN BOOST 3.0 · playsin333
# ---------------------------------------------------------------------
#  Окно, шапка, проверки перед стартом
# ---------------------------------------------------------------------
function Set-ConsoleLook {
    try { $Host.UI.RawUI.WindowTitle = $BR.Title } catch {}
    try {
        $raw = $Host.UI.RawUI
        if ($raw.WindowSize.Width -lt 110) {
            $buf = $raw.BufferSize
            if ($buf.Width -lt 112) { $buf.Width = 112; $raw.BufferSize = $buf }
            $win = $raw.WindowSize
            $win.Width = [Math]::Min(112, $raw.MaxPhysicalWindowSize.Width)
            $raw.WindowSize = $win
        }
    } catch {}
    Set-NoQuickEdit
}

function Show-Banner {
    Clear-Host
    Write-Host ''
    foreach ($l in $BR.Art) { Write-Host $l -ForegroundColor Cyan }
    Write-Host ''
    foreach ($l in $BR.Head) { Write-Host ('   ' + $l) -ForegroundColor White }
    Write-Host ''
    Write-Host '   Перед изменениями: точка восстановления и бэкап каждого значения, откат одним ярлыком.' -ForegroundColor DarkGray
    Write-Host '===================================================================='
    Write-Host ('   Бесплатный BOOST 3.0 · обновлённая сборка ' + $P3Version) -ForegroundColor Green
}

function Stop-Nothing([string]$Text) {
    Write-Host ''
    Write-Host ('   ' + $Text) -ForegroundColor Yellow
    Write-Host '   Ничего не изменено.' -ForegroundColor Yellow
    Wait-Key
    return 2
}

# Запущен из архива или временной папки: рядом нет папки nvidia, после закрытия всё пропадёт
function Test-Unpacked {
    $p = [string]$PackDir
    if ($p -match '\\AppData\\Local\\Temp\\|\\Temp\\Rar\$|\\Temp\\7z|\.zip\\|\\INetCache\\') { return $false }
    return $true
}

# Тот ли пользователь: настройки HKCU и ярлыки должны достаться тому, кто вошёл в Windows
function Test-SameUser {
    try {
        $owner = [string](Get-CimInstance Win32_ComputerSystem).UserName
        if (-not $owner) { return $true }
        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        return ($owner -ieq $me)
    } catch { return $true }
}

# Старые бэкапы: пак 2.x или Input Lag без отката, BOOST другой сборки, свой прошлый запуск
function Test-OldBackups {
    $other = Read-Json (Join-Path $OtherRoot 'state.json')
    if ($other -and [string]$other.Product -eq 'BOOST' -and -not $other.RolledBack) {
        Write-Host ''
        Write-Host ('   На этом ПК уже стоит другая сборка BOOST (бэкап в ' + $OtherRoot + ').') -ForegroundColor Yellow
        Write-Host '   Сначала откати её ярлыком отката на рабочем столе, перезагрузись и запусти этот файл снова.' -ForegroundColor Yellow
        return 'exit'
    }
    $old = @()
    foreach ($b in @((Join-Path $P3Root 'backup'), (Join-Path $P3Root 'InputLag\backup'))) {
        if (Test-Path -LiteralPath (Join-Path $b 'registry.json')) { $old += $b }
    }
    if ($old.Count -gt 0) {
        $root = Split-Path -Parent $old[0]
        $rb = @(Get-ChildItem -LiteralPath $root -Filter 'Откат*.bat' -File -ErrorAction SilentlyContinue | Select-Object -First 1)
        Write-Host ''
        Write-Host '   Нашёл бэкап старого пака (Lite, Max, Esports или Input Lag), откат которого не делали.' -ForegroundColor Yellow
        Write-Host '   Если ставить BOOST поверх, его откат вернёт настройки старого пака, а не чистой Windows.' -ForegroundColor DarkGray
        $c = Ask-Opt 'Что делаем?' '' @('Запустить откат старого пака сейчас', 'Выйти') 1
        if ($c -eq 1) {
            if ($rb.Count -gt 0) {
                Start-Process -FilePath $rb[0].FullName -WorkingDirectory $root
                Write-Host ''
                Write-Host '   Открыл откат старого пака. Пройди его, перезагрузи ПК и запусти BOOST снова.' -ForegroundColor Green
            } else {
                Write-Host ''
                Write-Host ('   Файл отката не нашёл в ' + $root + '. Запусти ярлык отката старого пака на рабочем столе, потом BOOST снова.') -ForegroundColor Yellow
            }
        }
        return 'exit'
    }
    foreach ($d in @(Get-ChildItem -LiteralPath $P3Root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'backup-откачен-*' } | Select-Object -First 1)) {
        Write-LogFile 'Найден старый бэкап, откат уже сделан: старые файлы не трогаю.'
    }
    $mine = Read-Json $StateFile
    if ($mine -and [string]$mine.Product -eq 'BOOST') {
        if ($mine.RolledBack) {
            # Откат делали: старые файлы BOOST убираем в сторону, начинаем с чистого бэкапа
            $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            foreach ($f in @('state.json', 'registry.json', 'measure-before.json')) {
                $p = Join-Path $P3Root $f
                if (Test-Path -LiteralPath $p) { Rename-Item -LiteralPath $p -NewName ([IO.Path]::GetFileNameWithoutExtension($f) + '-откачен-' + $stamp + '.json') }
            }
            if (Test-Path -LiteralPath $DrsBackup) { Rename-Item -LiteralPath $DrsBackup -NewName ('nvidia-drs-откачен-' + $stamp) }
            return 'fresh'
        }
        Write-Host ''
        if ($mine.RunStatus -eq 'Applying' -or $mine.RunStatus -eq 'Prepared' -or $mine.RunStatus -eq 'Failed') {
            Write-Host ('   Предыдущая настройка не завершилась. Последний блок: ' + $mine.ActiveStep + '. Можно повторить настройку с исходным бэкапом или выполнить откат.') -ForegroundColor Yellow
        }
        Write-Host '   BOOST на этом ПК уже запускали.' -ForegroundColor Yellow
        Write-Host '   Исходные значения в бэкапе не перезапишутся, откат всё равно вернёт Windows как до первого запуска.' -ForegroundColor DarkGray
        if ((Ask-Opt 'Что делаем?' '' @('Применить заново', 'Выйти') 1) -eq 2) { return 'exit' }
        return 'again'
    }
    return 'fresh'
}

# ---------------------------------------------------------------------
#  Экран «что нашёл» и профиль
# ---------------------------------------------------------------------
function Show-Profile($Sys, [string]$Prof, $Fl) {
    Write-Host ''
    Write-Host '  ---------------------------- Что я нашёл ----------------------------' -ForegroundColor White
    Write-Host ('    Windows:     ' + $Sys.Name)
    $dev = 'ПК'
    if ($Sys.IsLaptop) { $dev = 'ноутбук' }
    Write-Host ('    Устройство:  ' + $dev)
    Write-Host ('    Процессор:   ' + $Sys.Cpu)
    $g = $Sys.Gpu
    if ($Sys.Main -and $Sys.Main.VramGB -gt 0) { $g = $g + ' (' + $Sys.Main.VramGB + ' ГБ)' }
    Write-Host ('    Видеокарта:  ' + $g)
    $ram = [string]$Sys.RamGB + ' ГБ'
    if ($Sys.RamMHz -gt 0) { $ram = $ram + ' · ' + (($Sys.RamType + ' ' + $Sys.RamMHz + ' МГц').Trim()) }
    Write-Host ('    Память:      ' + $ram)
    Write-Host ('    Диск C:      ' + $Sys.DiskNote)
    if ($Sys.Refresh) { Write-Host ('    Монитор:     ' + $Sys.Refresh.Current + ' Гц (умеет ' + $Sys.Refresh.Max + ' Гц)') }
    Write-Host ''
    Write-Host ('    Профиль: ' + $ProfileTitle[$Prof]) -ForegroundColor Green
    $vw = 'адаптация для ограниченной графики не выбрана'
    if ($Fl.Video) { $vw = 'адаптация по признаку: ' + $Sys.WeakGpu.Why }
    $sw = 'упрощение оформления и группировка служб по железу не выбраны; общие настройки выбираются отдельно'
    if ($Fl.System) {
        $why = @()
        if ($Sys.WeakCpu.Weak) { $why += $Sys.WeakCpu.Why }
        if ($Sys.WeakRam) { $why += ('память ' + $Sys.RamGB + ' ГБ') }
        if ($why.Count -eq 0) { $why += 'выбран слабый профиль' }
        $sw = 'слабые (' + ($why -join ', ') + '), системные пункты включены'
    }
    Write-Host ('    Видеокарта: ' + $vw)
    Write-Host ('    Процессор и память: ' + $sw)
}

# Профиль выбран руками: «Слабый» включает все пункты для слабого железа, «Мощный» ни одного
function Get-Flags($Sys, [string]$Prof, [bool]$Manual) {
    if ($Manual -and $Prof -eq 'Weak') { return @{ Video = $true; System = $true } }
    if ($Manual -and $Prof -eq 'Strong') { return @{ Video = $false; System = $false } }
    return @{ Video = [bool]$Sys.WeakGpu.Weak; System = ([bool]$Sys.WeakCpu.Weak -or [bool]$Sys.WeakRam) }
}

# ---------------------------------------------------------------------
#  Вопросы: три режима. Рекомендовано и Максимум спрашивают только то, что угадать нельзя
# ---------------------------------------------------------------------
$Closable = [ordered]@{
    'Telegram'         = @('Telegram')
    'WhatsApp'         = @('WhatsApp', 'WhatsApp.Root')
    'Viber'            = @('Viber')
    'Skype'            = @('Skype')
    'Teams'            = @('ms-teams', 'Teams')
    'Zoom'             = @('Zoom')
    'Spotify'          = @('Spotify')
    'Яндекс Музыка'    = @('Яндекс Музыка', 'YandexMusic')
    'OneDrive'         = @('OneDrive')
    'Яндекс Диск'      = @('YandexDisk2')
    'Google Drive'     = @('GoogleDriveFS')
    'Dropbox'          = @('Dropbox')
    'qBittorrent'      = @('qbittorrent')
    'uTorrent'         = @('uTorrent')
    'BitTorrent'       = @('BitTorrent')
    'Wallpaper Engine' = @('wallpaper32', 'wallpaper64')
    'iCUE'             = @('iCUE')
    'Armoury Crate'    = @('ArmouryCrate')
}

function Get-ClosableFound {
    $running = @(Get-Process -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName } | Sort-Object -Unique)
    $start = (@(Get-StartupItems | Where-Object { $_.Enabled } | ForEach-Object { $_.Name + ' ' + $_.Command }) -join "`n")
    $found = @()
    foreach ($k in $Closable.Keys) {
        $hit = @($Closable[$k] | Where-Object { $running -contains $_ -or $start -match [regex]::Escape($_) }).Count -gt 0
        if ($hit) { $found += $k }
    }
    return $found
}

function Get-Context($Sys, [string]$Prof) {
    $c = @{}
    $c.Vbs = Get-VbsState
    $c.IntelGen = Get-IntelGen $Sys.Cpu
    $c.GameRoots = @(Get-GameRoots)
    $c.OneDrive = Get-OneDriveInfo
    $c.Closable = @(Get-ClosableFound)
    $c.ShowIslc = ($Sys.RamGB -le 16)
    $c.MonitorLow = ($Sys.Refresh -and $Sys.Refresh.Max - $Sys.Refresh.Current -ge 5)
    return $c
}

$SvcItems = @(
    @(1, 'принтер или сканер'), @(2, 'Bluetooth (наушники, геймпад, мышь)'), @(3, 'Xbox и Game Pass'),
    @(4, 'удалённый рабочий стол Windows (RDP)'), @(5, 'вход по лицу или отпечатку'),
    @(6, 'геолокация (карты, погода, поиск устройства)'), @(7, 'быстрый поиск по файлам в Пуске'), @(8, 'смарт-карты и токены (ЭЦП)')
)

function Ask-Services($Sys) {
    $pre = @(1, 2, 3, 4, 5, 6, 7, 8)
    if ($Sys.Devices.Printer) { $pre += 1 }
    if ($Sys.Devices.Xbox) { $pre += 3 }
    if ($Sys.Devices.Bio) { $pre += 5 }
    $items = @($SvcItems | ForEach-Object { [pscustomobject]@{ N = $_[0]; Text = $_[1]; Pre = ($pre -contains $_[0]) } })
    $r = Ask-Multi 'Службы: отметь, чем пользуешься, остальное выключу.' 'По умолчанию отмечены все функции. Сними отметку только с ненужной. Сеть и звук сохраняются.' $items
    return @($r)
}

function Ask-Programs($Ctx, [bool]$Laptop) {
    $items = @()
    foreach ($p in $Programs) {
        if ($p.N -eq 2 -and -not $Ctx.ShowIslc) { continue }
        $items += [pscustomobject]@{ N = $p.N; Text = ($p.Title + ': ' + $p.Why); Pre = $false }
    }
    $r = Ask-Multi 'Программы: что скачать и поставить?' 'Необязательная установка. Выбирай только нужное; настройка программ выполняется отдельно.' $items
    return @($r)
}

function Ask-Vbs($Sys, $Ctx, $Ans) {
    $def = 1
    if ($Sys.Vanguard -or $Sys.Faceit) { $def = 1 }
    $h = "Требования Vanguard и FACEIT зависят от версии и конфигурации. При сомнениях сохраняй совместимость.`nБез гипервизора не работают WSL, Docker, Песочница Windows и эмуляторы Android на Hyper-V."
    if ($Sys.Vanguard) { $h += "`nНа этом ПК стоит Vanguard (Valorant)." }
    if ($Sys.Faceit) { $h += "`nНа этом ПК стоит клиент FACEIT." }
    $Ans.UsesVbs = ((Ask-Opt 'Играешь в Valorant или на FACEIT, пользуешься WSL, Docker, Песочницей или эмулятором Android на Hyper-V?' $h @('Да', 'Нет') $def) -eq 1)
}

function Get-RtssDirectory {
    $candidates=@()
    foreach ($key in @('HKLM\SOFTWARE\Unwinder\RTSS','HKLM\SOFTWARE\WOW6432Node\Unwinder\RTSS','HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RTSS','HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\RTSS')) {
        foreach ($name in @('InstallPath','InstallLocation')) {
            try { $v=Get-RegValue $key $name;if ($v -and $v.Value) {$candidates+=[string]$v.Value} } catch {}
        }
    }
    foreach ($base in @(${env:ProgramFiles(x86)},$env:ProgramFiles)) { if ($base) { $candidates+=Join-Path $base 'RivaTuner Statistics Server' } }
    foreach ($dir in @($candidates | Select-Object -Unique)) {
        if ((Test-Path -LiteralPath (Join-Path $dir 'RTSS.exe') -PathType Leaf) -and (Test-Path -LiteralPath (Join-Path $dir 'RTSSHooks64.dll') -PathType Leaf)) { return [IO.Path]::GetFullPath($dir) }
    }
    return $null
}
function Select-FrameLimit($Sys, [bool]$RaiseRefresh) {
    $hz=0
    if ($Sys.Refresh) { $hz=[int]$Sys.Refresh.Current;if ($RaiseRefresh) {$hz=[int]$Sys.Refresh.Max} }
    while ($true) {
        Write-Host ''
        Write-Host '  Какой лимит FPS поставить?' -ForegroundColor Cyan
        Write-Host '    0 — без ограничения со стороны выбранного лимитера'
        if ($hz -gt 0 -and $hz -le 1000) { Write-Host ('    М — по частоте основного монитора: '+$hz+' Гц → '+$hz+' FPS') }
        else { Write-Host '    Частота монитора недоступна; можно указать своё число.' }
        Write-Host '    Или введи своё число от 1 до 1000. Пустой ответ не выбирает лимит.'
        $answer=(Read-Line).Trim();$fps=-1
        if ($answer -match '^(м|m)$' -and $hz -gt 0 -and $hz -le 1000) {$fps=$hz}
        elseif ($answer -match '^\d{1,4}$') { $number=0;if ([int]::TryParse($answer,[ref]$number) -and $number -le 1000) {$fps=$number} }
        if ($fps -lt 0) { Write-Host '  Введи 0, М или число от 1 до 1000.' -ForegroundColor Yellow;continue }
        $backend='Manual';$rtss=Get-RtssDirectory
        if ($Sys.IsNvidia -and (Test-Path -LiteralPath $DrsDir) -and (Test-Path -LiteralPath (Join-Path $NpiSrc 'nvidiaProfileInspector.exe'))) { $backend='Nvidia' }
        elseif ($rtss -and [Environment]::Is64BitProcess) { $backend='RTSS' }
        if ($backend -eq 'Manual') { Write-Host '  Автоматический лимитер не найден. Выбор попадёт в план и подсказку для ручной настройки; FPS автоматически не изменится.' -ForegroundColor Yellow }
        elseif ($backend -eq 'RTSS') { Write-Host '  Используется установленный RTSS. Для действия лимита RTSS должен работать; игровые профили RTSS могут переопределять общий лимит.' }
        else { Write-Host '  Общий лимит драйвера NVIDIA; отдельные профили игр и другие ограничители могут задавать свой предел.' }
        return @{Value=$fps;Backend=$backend;Directory=$rtss;ByRefresh=($answer -match '^(м|m)$')}
    }
}
function Get-FrameLimitText($Frame) {
    if (-not $Frame) { return 'не задан' }
    $value=([string]$Frame.Value+' FPS');if ([int]$Frame.Value -eq 0) {$value='без ограничения выбранного лимитера (0)'}
    $names=@{Nvidia='общий профиль NVIDIA';RTSS='общий профиль RTSS';Manual='ручная настройка, автоматически не применяется'}
    return ($value+' · '+$names[[string]$Frame.Backend])
}
function Merge-NvSettings($Existing, $Added) {
    $map=[ordered]@{}
    foreach ($row in @($Existing)+@($Added)) { if ($row -and $row.Count -ge 3) {$map[[string]$row[1]]=$row} }
    return ,@($map.Values)
}
function Invoke-FrameLimit($Sys, $Frame) {
    if (-not $Frame) { return }
    $State.FrameLimit=$Frame;$State.FrameLimitApplied=$false;Save-State
    switch ([string]$Frame.Backend) {
        'Nvidia' {
            $answer=@{FrameLimitOnly=$true;FrameLimit=$Frame;NvUltra=$false;ChangeQuality=$false}
            $result=Invoke-Nvidia $Sys @{Video=$false} $answer
            if ($result -ne 'ok') { Log ERR 'Лимит FPS NVIDIA не применён; выбранное значение сохранено в отчёте' }
            else {$State.FrameLimitApplied=$true;Save-State}
        }
        'RTSS' {
            $dir=[string]$Frame.Directory
            if (-not $dir -or -not (Test-Path -LiteralPath (Join-Path $dir 'RTSSHooks64.dll')) -or -not (Test-Path -LiteralPath (Join-Path $dir 'RTSS.exe'))) { throw 'RTSS больше не найден; лимит не применён' }
            $old=Get-RtssFrameLimit $dir
            if (-not $State.RtssFrameLimit) { $State.RtssFrameLimit=@{Directory=$dir;Old=$old;New=[uint32]$Frame.Value} }
            else {
                if ([string]$State.RtssFrameLimit.Directory -ine $dir) { throw 'RTSS переустановлен в другую папку. Сначала верни прежний лимит через откат.' }
                $State.RtssFrameLimit.New=[uint32]$Frame.Value
            }
            Save-State
            Set-RtssFrameLimit $dir ([uint32]$Frame.Value)
            $State.FrameLimitApplied=$true;Save-State
            if ([int]$Frame.Value -gt 0 -and -not (Get-Process -Name RTSS -ErrorAction SilentlyContinue)) {
                Start-Process -FilePath (Join-Path $dir 'RTSS.exe') -WorkingDirectory $dir -WindowStyle Minimized -ErrorAction Stop
            }
            Log OK ('Лимит RTSS сохранён и проверен: '+$Frame.Value+'; исходный лимит записан в бэкап')
        }
        default { Log INFO ('Лимит FPS выбран: '+$Frame.Value+'. Настрой его в игре или панели драйвера; автоматически не применялся.') }
    }
}
function Set-DeviceMsiIfDeclared([string]$Path, [bool]$Requested, [string]$Title) {
    $cur=Get-RegValue $Path 'MSISupported'
    if ($cur -and [string]$cur.Kind -eq 'DWord' -and [int64]$cur.Value -eq 1) { Log SKIP ($Title+': MSI уже включён');return }
    if (-not $Requested) { Log SKIP ($Title+': MSI сохраняется по настройке драйвера');return }
    if (-not $cur -or [string]$cur.Kind -ne 'DWord' -or [int64]$cur.Value -ne 0) { Log SKIP ($Title+': нет явной настройки MSI драйвера; поддержка не доказана, значение не создаётся');return }
    $script:RegNote=$Title+': эксперимент MSI'
    try {
        Set-Reg $Path 'MSISupported' 'DWord' 1
        $actual=Get-RegValue $Path 'MSISupported'
        if (-not $actual -or $actual.Kind -ne 'DWord' -or [int64]$actual.Value -ne 1) {throw 'проверка записи не пройдена'}
        Log OK ($Title+': MSI записан по явному выбору; действие проверяется после перезагрузки')
    } finally {$script:RegNote=''}
}

function Get-Answers($Sys, [string]$Prof, $Fl, $Ctx, [string]$Mode, [string[]]$Blocks) {
    $A = @{ Mode = $Mode; Blocks = @($Blocks); PowerStyle = 'Adaptive'; GameProfiles = @() }
    if ($Mode -eq 'Max') { $A.PowerStyle = 'Legacy' }
    if ($Mode -eq 'Manual' -and $Blocks -contains 'power') {
        if ((Ask-Opt 'Как настраивать питание?' 'Адаптивное: копия текущей схемы с минимумом CPU 5%, без правок USB/гибернации. Исходный максимум 3.0 остаётся отдельным выбором.' @('Адаптивное', 'Исходное питание 3.0') 1) -eq 2) { $A.PowerStyle = 'Legacy' }
    }
    if ($Blocks -contains 'game-profiles') { $A.GameProfiles = @(Select-GameProfiles $Sys) }
    $manual = ($Mode -eq 'Manual')
    $max = ($Mode -eq 'Max')
    $isPC = ($Prof -ne 'Laptop')

    # 4. Максимальная производительность: только слабый ПК и ноутбук
    $A.MaxPerf = $null
    if ($Blocks -contains 'power' -and $A.PowerStyle -eq 'Legacy' -and $Prof -eq 'Weak') {
        if ($manual) { $A.MaxPerf = ((Ask-Opt 'Максимальная производительность?' "«Да»: схема Ultimate и EPP 0, схема предпочитает производительность. Больше нагрев и шум.`n«Нет»: ядра всё равно не паркуются и минимум процессора 100%, как в Max 2.0." @('Да', 'Нет') 1) -eq 1) }
        else { $A.MaxPerf = $true }
    } elseif ($Blocks -contains 'power' -and $A.PowerStyle -eq 'Legacy' -and $Prof -eq 'Laptop') {
        if ($manual) { $A.MaxPerf = ((Ask-Opt 'Максимальная производительность в игровом режиме?' "В игровом режиме от сети процессор перестаёт сбрасывать частоту: больше нагрев и шум.`nВключается только вместе с игровым режимом и только от розетки, после игры обычная схема." @('Да', 'Нет') 2) -eq 1) }
        else { $A.MaxPerf = $max }
    }

    # 5. Valorant, FACEIT и VBS
    $A.UsesVbs = $true
    if ($Blocks -contains 'security' -or $Blocks -contains 'services') { Ask-Vbs $Sys $Ctx $A }
    $A.VbsOff = $false
    $A.VbsNote = ''
    if ($Blocks -contains 'security' -and -not $A.UsesVbs) {
        if (-not ($Ctx.Vbs.Running -or $Ctx.Vbs.Hvci)) { $A.VbsNote = 'VBS уже выключена' }
        elseif ($Ctx.Vbs.Locked) { $A.VbsNote = 'VBS закреплена в UEFI (BIOS), батник её не трогает' }
        elseif ($manual) { $A.VbsOff = ((Ask-Opt 'Выключить VBS и целостность памяти?' "Больше всего FPS на процессорах без MBEC и GMET (Intel до 7-го поколения, Ryzen до 2000).`nЗащита от вредоносных драйверов станет слабее. Откат включит обратно." @('Да', 'Нет') 1) -eq 1) }
        else { $A.VbsOff = $max }
        if (-not $A.VbsOff -and -not $A.VbsNote) { $A.VbsNote = 'VBS оставлена по ответу' }
    } else { $A.VbsNote = 'VBS не трогаю: Valorant, FACEIT или виртуализация' }

    # 6. Spectre: только Intel до 9 поколения
    $A.Spectre = $null
    if ($Blocks -contains 'security' -and $Ctx.IntelGen -gt 0 -and $Ctx.IntelGen -le 9) {
        if ($manual) { $A.Spectre = ((Ask-Opt ('Защита Spectre и Meltdown (Intel ' + $Ctx.IntelGen + '-го поколения)?') "Выключить: больше скорости на старых Intel, но меньше защиты от атак, например через браузер.`nНа ПК, где только играют, можно выключить." @('Выключить', 'Оставить') 2) -eq 1) }
        else { $A.Spectre = $max }
    }

    # 7. Пауза обновлений: даже в максимуме «Нет» (FACEIT не пускает без обновлений безопасности)
    $A.Pause = $false
    if ($manual -and $Blocks -contains 'security') { $A.Pause = ((Ask-Opt 'Поставить обновления Windows на паузу на 5 недель?' "Потом обновления пойдут сами. Перезагрузки регулируются активными часами и настройками Windows.`nFACEIT не пускает с Windows без обновлений безопасности." @('Да', 'Нет') 2) -eq 1) }

    # 8. Службы
    $A.Svc = @(1,2,3,4,5,6,7,8)
    if ($Blocks -contains 'services') { $A.Svc = @(Ask-Services $Sys) }

    # 9. Исключения Defender
    $A.DefExcl = @()
    if ($Blocks -contains 'defender' -and $Ctx.GameRoots.Count -gt 0) {
        if ($manual) {
            Write-Host ''
            Write-Host '  Нашёл папки с играми:' -ForegroundColor White
            foreach ($r in $Ctx.GameRoots) { Write-Host ('    ' + $r) -ForegroundColor Gray }
            if ((Ask-Opt 'Добавить их в исключения Defender?' 'Меньше подлагиваний при подгрузке. Только эти папки, никаких дисков и «Загрузок».' @('Да', 'Нет') 2) -eq 1) { $A.DefExcl = $Ctx.GameRoots }
        }
    }

    # 10. Мусорные приложения (Xbox попадает в список, если клиент не отметил Xbox в службах)
    $A.ChangeQuality = $max
    if ($manual -and ($Blocks -contains 'nvidia' -or $Blocks -contains 'amd')) { $A.ChangeQuality = Ask 'Менять качество в глобальном профиле драйвера?' 'Влияет на все игры: фильтрация, сглаживание и тесселяция по старому набору 3.0. Можно сохранить эти параметры.' 'Разрешить изменения качества' 'Сохранить качество' 2 }
    $A.RestrictBackground = $max
    if (-not $max -and $Blocks -contains 'startup') { $A.RestrictBackground = ((Ask-Opt 'Фон приложений Windows и Edge' 'Сохранение фона оставляет уведомления и фоновые задачи. Ограничение может остановить их работу.' @('Сохранить фон и уведомления', 'Ограничить фон Windows-приложений и Edge') 1) -eq 2) }
    $A.AppScope = 'CurrentUser'
    if ($manual -and $Blocks -contains 'apps') {
        if ((Ask-Opt 'Для кого удалять выбранные Appx?' 'Все пользователи также удаляет provisioning для новых учётных записей. Возврата данных нет.' @('Только текущий пользователь', 'Все пользователи и provisioning') 1) -eq 2) { $A.AppScope = 'AllUsers' }
    }
    $junk = @()
    if ($Blocks -contains 'apps') { $junk = @(Find-JunkApps (@($A.Svc) -notcontains 3) ($A.AppScope -eq 'AllUsers')) }
    $A.Junk = @()
    if ($junk.Count -gt 0) {
        if ($manual) {
            Write-Host ''
            Write-Host ('  Нашёл встроенные приложения (' + $junk.Count + '): ' + (($junk | ForEach-Object { $_.Title }) -join ', ')) -ForegroundColor White
            $c = Ask-Opt 'Что с ними делать?' 'Store, Калькулятор, Фото, Терминал и панели драйверов не трогаю. Удалённое ставится обратно из Microsoft Store.' @('Удалить все из списка', 'Выбрать номера', 'Не трогать') 3
            if ($c -eq 1) { $A.Junk = $junk }
            elseif ($c -eq 2) {
                $i = 0
                $items = @($junk | ForEach-Object { $i++; [pscustomobject]@{ N = $i; Text = $_.Title; Pre = $false } })
                $pick = @(Ask-Multi 'Номера того, что удалить:' '' $items)
                $A.Junk = @(for ($j = 0; $j -lt $junk.Count; $j++) { if ($pick -contains ($j + 1)) { $junk[$j] } })
            }
        }
    }

    # 11–13. Лёгкие замены, старое меню, OneDrive
    $A.Light = $false
    if ($manual -and $Blocks -contains 'apps') { $A.Light = ((Ask-Opt 'Лёгкие классические замены: старый просмотр фото, Windows Media Player, старый Блокнот?' 'Открываются сразу. Новый Блокнот убираю, только если старый на месте.' @('Да', 'Нет') 1) -eq 1) }
    $A.Menu = $false
    if ($Blocks -contains 'apps' -and $Sys.IsWin11) {
        $A.Menu = $true
        if ($manual) { $A.Menu = ((Ask-Opt 'Старое меню по правой кнопке (без «Показать дополнительные параметры»)?' '' @('Да', 'Нет') 1) -eq 1) }
    }
    $A.OneDrive = $false
    $A.OneDriveNote = ''
    if (-not $Ctx.OneDrive.Installed) { $A.OneDriveNote = 'OneDrive не установлен' }
    elseif ($Ctx.OneDrive.Block) { $A.OneDriveNote = ('удаление не предлагаю: ' + $Ctx.OneDrive.Block) }
    elseif ($manual -and $Blocks -contains 'apps') { $A.OneDrive = ((Ask-Opt 'OneDrive?' 'У многих там файлы, поэтому рекомендую оставить.' @('Удалить', 'Оставить') 2) -eq 1) }

    # 14. Низкая задержка NVIDIA
    $A.NvUltra = $false
    if ($Blocks -contains 'nvidia' -and $Sys.IsNvidia) {
        if ($manual) { $A.NvUltra = ((Ask-Opt 'Режим низкой задержки NVIDIA?' 'В играх с Reflex задержкой управляет сама игра.' @('Вкл', 'Ultra') 1) -eq 2) }
        else { $A.NvUltra = $max }
    }

    # 15–17. Мышь, таймер, частота монитора
    $A.NoAccel = ($Blocks -contains 'input')
    if ($manual -and $Blocks -contains 'input') { $A.NoAccel = ((Ask-Opt 'Выключить акселерацию мыши?' 'Выключается «Повышенная точность установки указателя», мышь двигается одинаково.' @('Да', 'Нет') 1) -eq 1) }
    $A.Timer = $false
    if ($manual -and $Blocks -contains 'timer') { $A.Timer = ((Ask-Opt ('Таймер ' + $BR.Short + ' (dynamic tick)?') "Можно попробовать: у части ПК кадры ровнее, у части разницы нет.`nBitLocker батник сам поставит на паузу на одну перезагрузку." @('Да', 'Нет') 2) -eq 1) }
    else { $A.Timer = $max -and $Blocks -contains 'timer' }
    $A.Monitor = $false
    if ($Blocks -contains 'input' -and $Ctx.MonitorLow) {
        $A.Monitor = $true
        if ($manual) { $A.Monitor = ((Ask-Opt ('Монитор работает на ' + $Sys.Refresh.Current + ' Гц, а умеет ' + $Sys.Refresh.Max + ' Гц. Поставить максимум?') 'Старую частоту запишу в бэкап.' @('Да', 'Нет') 1) -eq 1) }
    }

    $A.FrameLimit=Select-FrameLimit $Sys ([bool]$A.Monitor)
    $A.MemoryCompression='Keep';$A.DisableSysMain=$false;$A.LegacySystem=($Mode -eq 'Max')
    if ($Mode -eq 'Max') { $A.MemoryCompression='Legacy';$A.DisableSysMain=$true }
    if ($manual -and $Blocks -contains 'memory') {
        $i=Ask-Opt 'Сжатие памяти' 'Обычный выбор сохраняет управление Windows. Исходное правило 3.0: включить до 8 ГБ, выключить от 24 ГБ.' @('Оставить как есть','Включить','Выключить','Исходное правило 3.0') 1
        $A.MemoryCompression=@('Keep','On','Off','Legacy')[$i-1]
    }
    if ($manual -and $Blocks -contains 'services' -and $Sys.IsSSD -and [double]$Sys.RamGB -gt 8) {
        $A.DisableSysMain=Ask 'Отключить SysMain?' 'Для SSD само по себе это не требуется. Прежняя возможность 3.0 остаётся для конкретной проблемы с этой службой.' 'Отключить' 'Оставить' 2
    }
    if ($manual -and $Blocks -contains 'system') {
        $A.LegacySystem=Ask 'Применить исходный системный набор 3.0?' 'Win32PrioritySeparation, MMCSS и общий список IFEO. GPU Priority и SFIO Priority в MMCSS системой не используются. Можно сохранить настройки планировщика.' 'Применить исходный набор' 'Сохранить планировщик' 2
    }
    $A.MsiTweaks=$false
    if (($manual -or $max) -and ($Blocks -contains 'video' -or $Blocks -contains 'network')) {
        $A.MsiTweaks=Ask 'Применить эксперимент MSI для GPU и проводной сети?' 'Только для существующего MSISupported=0. Поддержку по имени устройства определить нельзя; после перезагрузки возможны проблемы драйвера. Обычно сохраняй выбор драйвера.' 'Применить эксперимент' 'Сохранить выбор драйвера' 2
    }
    $A.GamePower=$false
    if ($Blocks -contains 'power' -and $A.PowerStyle -eq 'Adaptive') {
        $A.GamePower=Ask 'Подготовить отдельное питание на время игрового режима?' 'Копия стандартной высокой производительности включится по игровому ярлыку только от сети. После игры вернётся текущая схема. Во время режима работает наблюдатель PowerShell.' 'Подготовить' 'Только постоянная схема' 2
    }
    $A.GameDownloadPercent=0
    if (Get-GameDownloadPolicy) {
        if (Ask 'Ограничивать фоновые загрузки Windows во время игрового режима?' 'До 10% измеренной полосы для Delivery Optimization. Не ограничивает Steam/браузер; заданные политики сохраняются. После игры и после входа ограничение возвращается.' 'Ограничивать во время режима' 'Не ограничивать' 2) {$A.GameDownloadPercent=10}
    }

    # 18. Что закрывать в игровом режиме
    $A.GameClose = @()
    if ($manual -and $Ctx.Closable.Count -gt 0) {
        $i = 0
        $items = @($Ctx.Closable | ForEach-Object { $i++; [pscustomobject]@{ N = $i; Text = $_; Pre = $false } })
        $pick = @(Ask-Multi 'Игровой режим: что закрывать при включении?' 'Discord, OBS, браузеры, лаунчеры игр, драйверы, звук и антивирус не закрываю никогда.' $items)
        $A.GameClose = @(for ($j = 0; $j -lt $Ctx.Closable.Count; $j++) { if ($pick -contains ($j + 1)) { $Ctx.Closable[$j] } })
    }

    # 19. Программы
    $A.Progs = @()
    if ($manual -and $Blocks -contains 'programs') { $A.Progs = Ask-Programs $Ctx ($Prof -eq 'Laptop') }
    return $A
}

function Show-Answers($Sys, [string]$Prof, $Fl, $Ctx, $A) {
    $yn = @{ $true='да'; $false='нет' }
    $blocks = @($A.Blocks)
    $L = @('Режим: ' + @{Rec='Рекомендовано';Max='Максимум';Manual='Ручной'}[$A.Mode] + ' · профиль: ' + $ProfileTitle[$Prof])
    if ($blocks -contains 'power' -and $null -ne $A.MaxPerf) { $L += ('Агрессивное питание: ' + $yn[[bool]$A.MaxPerf]) }
    if ($blocks -contains 'security') {
        $L += ('Сохранить совместимость с античитами/виртуализацией: ' + $yn[[bool]$A.UsesVbs] + '; выключить VBS: ' + $yn[[bool]$A.VbsOff])
        if ($null -ne $A.Spectre) { $L += ('Выключить защиту Spectre: ' + $yn[[bool]$A.Spectre]) }
        $L += ('Пауза обновлений: ' + $yn[[bool]$A.Pause])
    } else { $L += 'Защита VBS и Spectre: блок изменения защиты не выбран' }
    if ($blocks -contains 'services') {
        $keep = @($SvcItems | Where-Object { @($A.Svc) -contains $_[0] } | ForEach-Object { $_[1] })
        $L += ('Сохранить функции служб: ' + ($keep -join ', '))
    }
    if ($blocks -contains 'defender') { $L += ('Исключения Defender: ' + @($A.DefExcl).Count) }
    if ($blocks -contains 'apps') {
        $L += ('Область Appx: ' + @{CurrentUser='текущий пользователь';AllUsers='все пользователи и provisioning'}[[string]$A.AppScope])
        $L += ('Удалить выбранных Appx: ' + @($A.Junk).Count)
        $L += ('Классические замены с возможным удалением приложений: ' + $yn[[bool]$A.Light])
        $L += ('Старое меню Windows 11: ' + $yn[[bool]$A.Menu])
        $L += ('Удалить OneDrive: ' + $yn[[bool]$A.OneDrive] + ' ' + $A.OneDriveNote)
    }
    if ($blocks -contains 'nvidia') { $L += ('Низкая задержка NVIDIA: ' + @{ $true='Ultra'; $false='Вкл' }[[bool]$A.NvUltra]) }
    if ($blocks -contains 'amd' -or $blocks -contains 'nvidia') { $L += ('Разрешить глобальные изменения качества картинки: ' + $yn[[bool]$A.ChangeQuality]) }
    if ($blocks -contains 'power') { $L += ('Питание: ' + @{Adaptive='адаптивная копия исходной схемы';Legacy='исходный режим 3.0'}[[string]$A.PowerStyle]) }
    if ($blocks -contains 'input') {
        $L += ('Выключить акселерацию мыши: ' + $yn[[bool]$A.NoAccel])
        $L += ('Поставить максимальную частоту основного монитора: ' + $yn[[bool]$A.Monitor])
    }
    if ($blocks -contains 'timer') { $L += ('Выключить dynamic tick в BCD: ' + $yn[[bool]$A.Timer] + '; принудительный useplatformclock проверяется отдельно') }
    $L += ('Глобальный запрос таймера Windows 11: ' + $yn[$blocks -contains 'global-timer'])
    if ($blocks -contains 'power') { $L+=('Отдельное игровое питание по ярлыку: '+$yn[[bool]$A.GamePower]+' (для исходного режима 3.0 — по его ответам)') }
    if ($blocks -contains 'memory') { $L+=('Сжатие памяти: '+@{Keep='оставить Windows';On='включить';Off='выключить';Legacy='исходное правило 3.0'}[[string]$A.MemoryCompression]) }
    if ($blocks -contains 'services') {$L+=('SysMain: '+@{$true='отключить при условиях исходного набора';$false='оставить'}[[bool]$A.DisableSysMain])}
    if ($blocks -contains 'video' -or $blocks -contains 'network') {$L+=('Эксперимент MSI для существующей настройки: '+$yn[[bool]$A.MsiTweaks])}
    $L += ('Лимит FPS: '+(Get-FrameLimitText $A.FrameLimit))
    $L += ('Фоновые загрузки Windows в игровом режиме: '+$A.GameDownloadPercent+'% (0 — не ограничивать)')
    $L += ('Автоотчёт после входа: ' + $yn[[bool]$A.AfterReportEnabled])
    $L += ('Закрытие программ игровым переключателем: ' + $(if (@($A.GameClose).Count) { $A.GameClose -join ', ' } else { 'ничего' }))
    if ($blocks -contains 'programs') { $L += ('Выбранные утилиты: ' + (@($Programs | Where-Object { @($A.Progs) -contains $_.N } | ForEach-Object { $_.Title }) -join ', ')) }
    Write-Host '  ---------------------------- Проверь ответы ----------------------------' -ForegroundColor White
    foreach ($line in $L) { Write-Host ('    ' + $line) }
    return $L
}

# Максимум: перед проверкой ответов честно пишем, что рискованного включится
function Show-MaxWarning($Sys, $A) {
    $r = @()
    if ($A.MaxPerf -and -not $Sys.IsLaptop) { $r += 'агрессивная схема питания процессора: больше нагрев и шум' }
    if ($A.MaxPerf -and $Sys.IsLaptop) { $r += 'в игровом режиме от сети процессор не сбрасывает частоту: больше нагрев' }
    if ($A.VbsOff) { $r += 'изоляция ядра (VBS) выключится: слабее защита от вредоносных драйверов' }
    if ($A.Spectre) { $r += 'защита Spectre и Meltdown выключится: меньше защиты от атак через браузер' }
    if ($A.Timer) { $r += ('таймер ' + $BR.Short + ' меняет загрузчик (BitLocker на паузу на одну перезагрузку)') }
    if ($r.Count -eq 0) { return }
    Write-Host ''
    Write-Host '  Режим «Максимум» включит:' -ForegroundColor Yellow
    foreach ($x in $r) { Write-Host ('    · ' + $x) -ForegroundColor Yellow }
    Write-Host '  Всё откатывается ярлыком отката. OneDrive и обновления не трогаю даже в максимуме.' -ForegroundColor DarkGray
}

# PLAYSIN BOOST 3.0 · playsin333
# =====================================================================
#  Твики. Каждый пункт: старое значение в бэкап, запись, чтение назад, OK или ERR
# =====================================================================
$ADV = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$CDM = 'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$MM  = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
$IFEO = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'

function Invoke-SystemTweaks($Sys, [string]$Prof, $Fl, $A) {
    $isPC = ($Prof -ne 'Laptop')
    Section 'Система'
    if (-not $A.LegacySystem) { Log SKIP 'Исходный планировщик 3.0 не выбран; параметры Windows сохраняются';return }
    Apply-Reg 'Приоритет активной программы (Win32PrioritySeparation 38)' @(
        'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl|Win32PrioritySeparation|DWord|38'
    )
    # Только 10, никогда 0: меньше 10 Windows считает за 20
    Log INFO 'Исходный MMCSS: GPU Priority и SFIO Priority системой не используются; результат остальных параметров зависит от приложения'
    Apply-Reg 'Исходный набор MMCSS 3.0 (не гарантирует ускорение игр)' @(
        "$MM|SystemResponsiveness|DWord|10",
        "$MM\Tasks\Games|GPU Priority|DWord|8",
        "$MM\Tasks\Games|Priority|DWord|6",
        "$MM\Tasks\Games|Scheduling Category|String|High",
        "$MM\Tasks\Games|SFIO Priority|String|High"
    )
    # «Высокий» (3), не «Реального времени»: иначе игра душит мышь и звук
    Apply-Reg ('Высокий приоритет игр: ' + (($IfeoGames | ForEach-Object { $_ -replace '\.exe$', '' }) -join ', ')) @($IfeoGames | ForEach-Object { "$IFEO\$_\PerfOptions|CpuPriorityClass|DWord|3" })
    Apply-Reg 'Быстрый запуск Windows выкл (драйверы грузятся начисто)' @(
        'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power|HiberbootEnabled|DWord|0'
    )
    if ($isPC) {
        Apply-Reg 'Power Throttling выкл' @('HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling|PowerThrottlingOff|DWord|1')
    } else { Log SKIP 'Power Throttling: ноутбук, не трогаю (нагрев и батарея)' }


}

function Invoke-InterfaceTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Меню и задержки запуска'
    Apply-Reg 'Мгновенные меню, автозагрузка без задержки' @(
        'HKCU\Control Panel\Desktop|MenuShowDelay|String|0',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize|StartupDelayInMSec|DWord|0',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize|WaitForIdleState|DWord|0'
    )

}

function Invoke-AppearanceTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Оформление'
    if (-not $Fl.System) { Log SKIP 'Адаптация для ограниченного CPU/RAM не выбрана'; return }
        Apply-Reg 'Визуальные эффекты на быстродействие (эскизы и сглаживание шрифтов остаются)' @(
            'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects|VisualFXSetting|DWord|3',
            'HKCU\Control Panel\Desktop|UserPreferencesMask|Binary|9012038010000000',
            'HKCU\Control Panel\Desktop|DragFullWindows|String|0',
            'HKCU\Control Panel\Desktop|FontSmoothing|String|2',
            'HKCU\Control Panel\Desktop\WindowMetrics|MinAnimate|String|0',
            "$ADV|TaskbarAnimations|DWord|0",
            "$ADV|ListviewAlphaSelect|DWord|0",
            "$ADV|ListviewShadow|DWord|0",
            "$ADV|IconsOnly|DWord|0",
            'HKCU\Software\Microsoft\Windows\DWM|EnableAeroPeek|DWord|0',
            'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize|EnableTransparency|DWord|0'
        )

}

function Invoke-GroupingTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Группировка служб'
    if (-not $Fl.System) { Log SKIP 'Адаптация для ограниченного CPU/RAM не выбрана'; return }
        Apply-Reg ('Меньше процессов svchost (группировка по объёму памяти ' + $Sys.RamGB + ' ГБ)') @(
            ('HKLM\SYSTEM\CurrentControlSet\Control|SvcHostSplitThresholdInKB|DWord|' + $Sys.RamKB)
        )

}

function Invoke-BrowserMemoryTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Экономия памяти браузеров'
    if (-not $Fl.System) { Log SKIP 'Адаптация для ограниченного CPU/RAM не выбрана'; return }
        Apply-Reg 'Edge и Chrome: сон вкладок и экономия памяти' @(
            'HKLM\SOFTWARE\Policies\Microsoft\Edge|SleepingTabsEnabled|DWord|1',
            'HKLM\SOFTWARE\Policies\Microsoft\Edge|SleepingTabsTimeout|DWord|300',
            'HKLM\SOFTWARE\Policies\Google\Chrome|HighEfficiencyModeEnabled|DWord|1'
        )

}

function Invoke-MemoryTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Память и подкачка'
    $choice=[string]$A.MemoryCompression
    if (-not $choice) { $choice='Keep' }
    try {
        $mm=Get-MMAgent -ErrorAction Stop
        $target=$null
        if ($choice -eq 'On') { $target=$true }
        elseif ($choice -eq 'Off') { $target=$false }
        elseif ($choice -eq 'Legacy') {
            if ([double]$Sys.RamGB -le 8) {$target=$true}
            elseif ([double]$Sys.RamGB -ge 24) {$target=$false}
        }
        if ($null -eq $target) { Log SKIP 'Сжатие памяти: сохраняется управление Windows' }
        elseif ([bool]$mm.MemoryCompression -eq $target) { Log SKIP 'Сжатие памяти уже соответствует выбору' }
        else {
            if (-not $State.ContainsKey('MemoryCompressionOriginal')) {
                $original=[bool]$mm.MemoryCompression
                if ($State.Mmc -eq 'on') {$original=$false} elseif ($State.Mmc -eq 'off') {$original=$true}
                $State.MemoryCompressionOriginal=$original
            }
            $State.Mmc=$(if ($target) {'on'} else {'off'});Save-State
            if ($target) { Enable-MMAgent -MemoryCompression -ErrorAction Stop }
            else { Disable-MMAgent -MemoryCompression -ErrorAction Stop }
            Log OK ('Сжатие памяти: '+$State.Mmc+' по явному выбору, после перезагрузки')
        }
    } catch { Log SKIP ('Сжатие памяти: '+$_.Exception.Message) }

    # Файл подкачки на авто: чинит ручные «оптимизации». Это значение реестра, оно в бэкапе
    try {
        $pf = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'PagingFiles'
        $cur = ''
        if ($pf) { $cur = ((@($pf.Value) | ForEach-Object { [string]$_ }) -join '; ') }
        if ($cur -match '^\?:\\pagefile\.sys$') { Log SKIP 'Файл подкачки: по выбору системы, всё в порядке' }
        else {
            Apply-Reg ('Файл подкачки на авто (было: ' + @{ $true = 'нет файла'; $false = $cur }[[string]::IsNullOrWhiteSpace($cur)] + '), после перезагрузки') @(
                'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management|PagingFiles|MultiString|?:\pagefile.sys'
            )
        }
    } catch { Log ERR ('Файл подкачки: ' + $_.Exception.Message) }


}

function Invoke-StorageTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Параметры NTFS'
    Apply-Reg 'NTFS: без отметок доступа и коротких имён 8.3' @(
        'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem|NtfsDisableLastAccessUpdate|DWord|0x80000001',
        'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem|NtfsDisable8dot3NameCreation|DWord|1'
    )

}

function Invoke-GlobalTimerTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Глобальный запрос таймера Windows 11'
    if ($Sys.IsWin11) {
        Apply-Reg 'Таймер, который запросила игра, действует на всю систему (GlobalTimerResolutionRequests)' @(
            'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel|GlobalTimerResolutionRequests|DWord|1'
        )
    } else { Log SKIP 'GlobalTimerResolutionRequests: пропущено, только Win11' }

}

function Invoke-KeyboardTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Клавиатура'
    Apply-Reg 'Залипание клавиш выкл, быстрый повтор клавиатуры' @(
        'HKCU\Control Panel\Accessibility\StickyKeys|Flags|String|506',
        'HKCU\Control Panel\Accessibility\ToggleKeys|Flags|String|58',
        'HKCU\Control Panel\Accessibility\Keyboard Response|Flags|String|122',
        'HKCU\Control Panel\Keyboard|KeyboardDelay|String|0',
        'HKCU\Control Panel\Keyboard|KeyboardSpeed|String|31'
    )
}

function Save-BcdChange([string]$Name, $Old, $New, [bool]$Fix) {
    if ($State.Bcd.ContainsKey($Name)) { $Old = $State.Bcd[$Name].Old }
    $State.Bcd[$Name] = @{ Old=$Old; New=$New; Fix=$Fix }
    Save-State
}

function Invoke-SecurityTweaks($Sys, $A) {
    Section 'Защита (по ответам)'
    $script:RegNoFix = $true
    if ($A.VbsOff) {
        $vs = Get-VbsState
        if ($vs.Locked) { Log INFO ('VBS закреплена в UEFI (BIOS): батник её не трогает. Выключается в BIOS' + $BR.Plus) }
        else {
            Apply-Reg 'VBS и целостность памяти выкл (после перезагрузки)' @(
                'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard|EnableVirtualizationBasedSecurity|DWord|0',
                'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity|Enabled|DWord|0'
            )
            if (Suspend-BitLockerOnce) {
                try {
                    $old = Get-BcdValue 'hypervisorlaunchtype'
                    if ($old -and $old -match '^(Off|Выкл)') { Log SKIP 'Запуск гипервизора уже выключен' }
                    else {
                        Save-BcdChange 'hypervisorlaunchtype' $old 'Off' $false
        $r = Invoke-Native 'bcdedit.exe' @('/set', '{current}', 'hypervisorlaunchtype', 'off')
                        if ($r.Code -eq 0) { Log OK 'Запуск гипервизора выкл (после перезагрузки)' }
                        else { Log ERR ('hypervisorlaunchtype: ' + $r.Out) }
                    }
                } catch { Log ERR ('Гипервизор: ' + $_.Exception.Message) }
            }
            $State.VbsOff = $true
            Save-State
        }
    } else { Log SKIP $A.VbsNote }
    if ($A.Spectre) {
        Apply-Reg 'Защита Spectre и Meltdown выкл (старый Intel, после перезагрузки)' @(
            'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management|FeatureSettingsOverride|DWord|3',
            'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management|FeatureSettingsOverrideMask|DWord|3'
        )
    } elseif ($null -ne $A.Spectre) { Log SKIP 'Защита Spectre: оставлена по ответу' }
    if ($A.Pause) {
        # Пауза как кнопка в Параметрах: 5 недель, потом обновится само
        $UX = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
        $t0 = (Get-Date).ToUniversalTime()
        $from = $t0.ToString('yyyy-MM-ddTHH:mm:ssZ')
        $till = $t0.AddDays(35).ToString('yyyy-MM-ddTHH:mm:ssZ')
        Apply-Reg ('Обновления Windows на паузе до ' + $t0.AddDays(35).ToLocalTime().ToString('dd.MM.yyyy')) @(
            "$UX|PauseUpdatesStartTime|String|$from",
            "$UX|PauseUpdatesExpiryTime|String|$till",
            "$UX|PauseFeatureUpdatesStartTime|String|$from",
            "$UX|PauseFeatureUpdatesEndTime|String|$till",
            "$UX|PauseQualityUpdatesStartTime|String|$from",
            "$UX|PauseQualityUpdatesEndTime|String|$till"
        )
    } else { Log SKIP 'Пауза обновлений: нет, обновления как обычно' }
    $script:RegNoFix = $false
}

# Схема питания под профиль. Шаблон Ultimate на ноутбуке не используем никогда
$PwrSub = @{
    Cpu = '54533251-82be-4824-96c1-47b60b740d00'; MinCpu = '893dee8e-2bef-41e0-89c6-b55d0929964c'; Cores = '0cc5b647-c1df-4637-891a-dec35c318583'; Epp = '36687f9e-e3a5-4dbf-b1dc-15eb381c6863'
    Disk = '0012ee47-9041-4b5d-9b77-535fba8b1442'; DiskIdle = '6738e2c4-e8a5-4a42-b16a-e040e769756e'
    Pcie = '501a4d13-42af-4429-9fd1-a8218c268e20'; Aspm = 'ee12f906-d277-404b-b6da-e5fa1a576df5'
    Usb = '2a737441-1930-4402-8d77-b2bebba308a3'; UsbSusp = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'
}

function New-OurScheme([string[]]$Bases, [string]$Name, [string]$About) {
    $dup = $null
    $g = $null
    foreach ($b in @($Bases | Where-Object { $_ })) {
        $dup = Invoke-Native 'powercfg.exe' @('/duplicatescheme', $b)
        if ($dup.Code -eq 0 -and $dup.Out -match $GuidRx) { $g = $Matches[0]; break }
    }
    if (-not $g) { throw ('не удалось создать схему: ' + $dup.Out) }
    [void](Invoke-Native 'powercfg.exe' @('/changename', $g, $Name, $About))
    return $g
}

function Set-SchemeAc([string]$Scheme, $Values) {
    $bad = 0
    foreach ($v in $Values) {
        $r = Invoke-Native 'powercfg.exe' @('/setacvalueindex', $Scheme, $v[0], $v[1], [string]$v[2])
        if ($r.Code -ne 0) { $bad++; continue }
        Add-StateList 'PowerSet' ($Scheme + '|' + $v[0] + '|' + $v[1] + '|' + $v[2])
    }
    return $bad
}

function Invoke-Power($Sys, [string]$Prof, $A) {
    Section 'Питание'
    if ($A.PowerStyle -eq 'Adaptive') {
        $State.GamePowerEnabled=$false
        $active = Get-ActiveScheme
        if (-not $active) { throw 'Не определена текущая схема питания' }
        if (-not $State.OldScheme) { $State.OldScheme = $active; Save-State }
        foreach ($oldOwned in @($State.NewScheme, $State.GameScheme)) { if ($oldOwned) { Add-StateList 'OwnedSchemes' $oldOwned } }
        $ours = [string]$State.AdaptiveScheme
        if (-not $ours -or -not (Test-SchemeExists $ours)) { $ours = New-OurScheme @([string]$State.OldScheme, $active) ($BR.Tag + ' Адаптивная') 'Копия текущей схемы; минимум CPU от сети 5%' }
        $State.AdaptiveScheme = $ours; $State.NewScheme = $ours; Add-StateList 'OwnedSchemes' $ours; Save-State
        if ((Set-SchemeAc $ours @(,@($PwrSub.Cpu, $PwrSub.MinCpu, 5))) -gt 0) { throw 'Минимум CPU не поддерживается; схема не включена' }
        $r = Invoke-Native 'powercfg.exe' @('/setactive', $ours)
        if ($r.Code -ne 0 -or (Get-ActiveScheme) -ne $ours) { throw ('Схема не включена: ' + $r.Out) }
        Log OK 'Адаптивная схема: копия исходной схемы, минимум CPU от сети 5%; остальные параметры унаследованы'
        if ($A.GamePower) {
            $game=[string]$State.AdaptiveGameScheme
            if (-not $game -or -not (Test-SchemeExists $game)) {
                $game=New-OurScheme @('8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') ($BR.Tag+' Игра от сети') 'Копия стандартной высокой производительности; только в игровом режиме от сети'
            }
            $State.AdaptiveGameScheme=$game;$State.GameScheme=$game;Add-StateList 'OwnedSchemes' $game;Save-State
            if ((Set-SchemeAc $game @(,@($PwrSub.Cpu,$PwrSub.MinCpu,5))) -gt 0) { throw 'Не удалось подготовить игровое питание; переключение не включено' }
            $State.GamePowerEnabled=$true;Save-State
            Log OK 'Игровое питание готово для ПК/ноутбука: высокая производительность от сети, минимум CPU 5%, после игры возврат'
        } else { Save-State;Log SKIP 'Отдельное игровое питание не выбрано; постоянная схема остаётся активной' }
        return
    }
    try {
        $State.GamePowerEnabled=$false
        $active = Get-ActiveScheme
        $ours = $null
        if ($State.LegacyScheme -and (Test-SchemeExists ([string]$State.LegacyScheme))) { $ours = [string]$State.LegacyScheme }
        elseif ($State.NewScheme -and $State.NewScheme -ne $State.AdaptiveScheme -and (Test-SchemeExists ([string]$State.NewScheme))) { $ours = [string]$State.NewScheme }
        if (-not $State.OldScheme -and $active -and $active -ne $ours) { $State.OldScheme = $active; Save-State }
        $S = $PwrSub
        $common = @(@($S.Cpu, $S.Cores, 100), @($S.Disk, $S.DiskIdle, 0), @($S.Pcie, $S.Aspm, 0))
        if ($Prof -eq 'Laptop') {
            # Из прежней схемы ноутбука: от сети минимум 5%, от батареи всё как было
            if (-not $ours) { $ours = New-OurScheme @([string]$State.OldScheme, $active) ($BR.Tag + ' BOOST Ноутбук') ($BR.Tag + ': быстрее от сети, на батарее как раньше') }
            $State.LegacyScheme = $ours; $State.NewScheme = $ours; Add-StateList 'OwnedSchemes' $ours; Save-State
            $bad = Set-SchemeAc $ours ($common + ,@($S.Cpu, $S.MinCpu, 5))
            $r = Invoke-Native 'powercfg.exe' @('/setactive', $ours)
            if ($r.Code -ne 0) { throw ('не включилась: ' + $r.Out) }
            Log OK ('Схема «' + $BR.Tag + ' BOOST Ноутбук»: из прежней схемы ноутбука, от сети ядра не паркуются и минимум процессора 5%, от батареи всё как было' + @{ $true = ''; $false = (' (' + $bad + ' настройки ноутбук не поддерживает)') }[$bad -eq 0])
            if ($A.MaxPerf) {
                $game = $null
                if ($State.GameScheme -and (Test-SchemeExists ([string]$State.GameScheme))) { $game = [string]$State.GameScheme }
                if (-not $game) { $game = New-OurScheme @($ours) ($BR.Tag + ' BOOST Игровая') ($BR.Tag + ': только в игровом режиме и только от сети') }
                $State.GameScheme = $game;$State.GamePowerEnabled=$true; Add-StateList 'OwnedSchemes' $game; Save-State
                $bad2 = Set-SchemeAc $game ($common + @(@($S.Cpu, $S.MinCpu, 100), @($S.Cpu, $S.Epp, 0)))
                [void](Invoke-Native 'powercfg.exe' @('/setactive', $ours))
                Log OK 'Игровая схема готова: включается только игровым режимом и только от сети, после игры обычная'
            } else { Log SKIP 'Игровая схема ноутбука: по ответу не нужна, игровой режим схему не меняет' }
        } else {
            $ultimate = ($Prof -eq 'Strong') -or [bool]$A.MaxPerf
            if (-not $ours) {
                if ($ultimate) { $ours = New-OurScheme @('e9a42b02-d5df-448d-aa00-03f14749eb61', '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c', $active) ($BR.Tag + ' BOOST') ($BR.Tag + ': максимальная производительность') }
                else { $ours = New-OurScheme @('8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c', $active) ($BR.Tag + ' BOOST') ($BR.Tag + ': высокая производительность') }
            }
            $State.LegacyScheme = $ours; $State.NewScheme = $ours; Add-StateList 'OwnedSchemes' $ours; Save-State
            $vals = $common + @(,@($S.Cpu, $S.MinCpu, 100)) + @(,@($S.Usb, $S.UsbSusp, 0))
            if ($ultimate) { $vals += ,@($S.Cpu, $S.Epp, 0) }
            $bad = Set-SchemeAc $ours $vals
            $r = Invoke-Native 'powercfg.exe' @('/setactive', $ours)
            if ($r.Code -ne 0) { throw ('не включилась: ' + $r.Out) }
            $what = 'ядра не паркуются, минимум процессора 100%'
            if ($ultimate) { $what = 'максимальная: ' + $what + ', EPP 0' }
            Log OK ('Схема «' + $BR.Tag + ' BOOST»: ' + $what + ', диск, PCIe и USB не засыпают' + @{ $true = ''; $false = (' (' + $bad + ' настройки этот ПК не поддерживает)') }[$bad -eq 0])
        }
    } catch { Log ERR ('Схема питания: ' + $_.Exception.Message) }

    if ($Prof -eq 'Laptop') { Log SKIP 'Гибернация: ноутбук, оставлена' }
    elseif (-not $Sys.IsSSD) { Log SKIP 'Гибернация: системный диск HDD, оставлена' }
    else {
        try {
            $hib = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\Power' 'HibernateEnabled'
            $on = ($hib -and [int]$hib.Value -eq 1) -or (Test-Path -LiteralPath ($env:SystemDrive + '\hiberfil.sys'))
            if (-not $on) { Log SKIP 'Гибернация уже выключена' }
            else {
                if ($null -eq $State.HiberWasOn) { $State.HiberWasOn = $true; Save-State }
                $r = Invoke-Native 'powercfg.exe' @('/hibernate', 'off')
                if ($r.Code -eq 0) { Log OK 'Гибернация выкл (освобождено место на SSD)' } else { Log ERR ('Гибернация: ' + $r.Out) }
            }
        } catch { Log ERR ('Гибернация: ' + $_.Exception.Message) }
    }
    if ($Prof -eq 'Laptop') { Log SKIP 'USB-устройства: ноутбук, экономию энергии не трогаю' }
    else {
        $n = Disable-DevicePowerOff @('USB\')
        if ($n -gt 0) { Log OK ('Мышь, клавиатура и USB-хабы не отключаются для экономии энергии (' + $n + ')') } else { Log SKIP 'USB: отключение для экономии энергии уже снято' }
    }
}

function Invoke-Timer($Sys, $A) {
    Section 'Таймер'
    $useClock = $null
    $dyn = $null
    try { $useClock = Get-BcdValue 'useplatformclock'; $dyn = Get-BcdValue 'disabledynamictick' } catch { Log SKIP ('Загрузчик не прочитался: ' + $_.Exception.Message); return }
    $need = @()
    if ($useClock -and $useClock -notmatch '^(No|Нет)$') { $need += 'clock' }
    if ($A.Timer -and -not ($dyn -and $dyn -match '^(Yes|Да)$')) { $need += 'dyn' }
    if (-not $A.Timer) { Log SKIP ('Таймер ' + $BR.Short + ' (dynamic tick): не включаю по ответу') }
    elseif ($need -notcontains 'dyn') { Log SKIP ('Таймер ' + $BR.Short + ': dynamic tick уже выключен') }
    if ($need.Count -eq 0) { if (-not $useClock) { Log SKIP 'Принудительного HPET нет, таймер по умолчанию' }; return }
    if (-not (Suspend-BitLockerOnce)) { return }
    if ($need -contains 'clock') {
        Save-BcdChange 'useplatformclock' $useClock $null $true
        $r = Invoke-Native 'bcdedit.exe' @('/deletevalue', '{current}', 'useplatformclock')
        if ($r.Code -eq 0) { Log OK 'Принудительный HPET (useplatformclock) убран, таймер по умолчанию Windows' }
        else { Log ERR ('useplatformclock: ' + $r.Out) }
    }
    if ($need -contains 'dyn') {
        Save-BcdChange 'disabledynamictick' $dyn 'Yes' $true
        $r = Invoke-Native 'bcdedit.exe' @('/set', '{current}', 'disabledynamictick', 'yes')
        if ($r.Code -eq 0) { Log OK ('Таймер ' + $BR.Short + ': dynamic tick выкл (после перезагрузки)') }
        else { Log ERR ('disabledynamictick: ' + $r.Out) }
    }
}

function Invoke-VideoTweaks($Sys, [string]$Prof, $Fl, $A) {
    Section 'Видеокарта'
    Apply-Reg 'Игровой режим Windows вкл' @(
        'HKCU\Software\Microsoft\GameBar|AutoGameModeEnabled|DWord|1',
        'HKCU\Software\Microsoft\GameBar|AllowAutoGameMode|DWord|1'
    )
    if (-not $A.KeepCapture) {
        Apply-Reg 'Фоновая запись Game Bar выкл' @(
            'HKCU\System\GameConfigStore|GameDVR_Enabled|DWord|0',
            'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR|AppCaptureEnabled|DWord|0',
            'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR|AllowGameDVR|DWord|0'
        )
    }
    $hags=Get-HagsCapability $Sys
    if (-not $hags.Known) { Log SKIP 'HAGS: поддержку драйвера определить не удалось, настройка сохранена' }
    elseif (-not $hags.Supported) { Log SKIP 'HAGS: текущий GPU/драйвер не сообщает поддержку' }
    elseif ($hags.Enabled) { Log SKIP 'HAGS уже включён драйвером' }
    else { Apply-Reg 'Аппаратное планирование GPU (HAGS) вкл, после перезагрузки' @('HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers|HwSchMode|DWord|2') }
    # Оптимизация оконных игр: в значении лежат и другие настройки через «;», меняем только свою часть
    if (-not $Sys.IsWin11) { Log SKIP 'Оптимизация оконных игр: пропущено, только Win11' }
    else {
        try {
            $script:RegNote = 'оптимизация оконных игр'
            $dxKey = 'HKCU\Software\Microsoft\DirectX\UserGpuPreferences'
            $cur = Get-RegValue $dxKey 'DirectXUserGlobalSettings'
            $parts = @()
            if ($cur) { $parts = @(([string]$cur.Value).Split(';') | Where-Object { $_ -and $_ -notmatch '^\s*SwapEffectUpgradeEnable=' }) }
            $parts += 'SwapEffectUpgradeEnable=1'
            Set-Reg $dxKey 'DirectXUserGlobalSettings' 'String' (($parts -join ';') + ';')
            $script:RegNote = ''
            Log OK 'Оптимизация оконных игр включена; результат зависит от игры и режима'
        } catch { Log ERR ('Оптимизация оконных игр: ' + $_.Exception.Message) }
    }
    # Игры на дискретной видеокарте: ноутбук или ПК с двумя видеокартами
    if ($Sys.HasDGpu -and ($Sys.IsLaptop -or $Sys.MultiGpu)) {
        $exes = @(Get-GameExes)
        if ($exes.Count -eq 0) { Log SKIP 'Игры на дискретной видеокарте: известных игр не нашёл' }
        else {
            $script:RegNote = 'игра на дискретной видеокарте'
            $ok = 0
            foreach ($e in $exes) {
                $key='HKCU\Software\Microsoft\DirectX\UserGpuPreferences'
                $old=Get-RegValue $key $e
                $value=Get-GpuPreference ([string]$old.Value) 2
                Set-Reg $key $e 'String' $value
                $back=Get-RegValue $key $e
                if (-not $back -or [string]$back.Value -cne $value) { throw ('Профиль GPU не прошёл проверку: '+$e) }
                $ok++
            }
            $script:RegNote = ''
            Log OK ('Игры на дискретной видеокарте: ' + $ok + ' (' + ((@($exes) | ForEach-Object { Split-Path -Leaf $_ }) -join ', ') + ')')
        }
    }
    # MSI mode: только дискретная и только если сейчас выключен
    if ($Sys.Main -and [string]$Sys.Main.Pnp -match '^PCI\\') {
        $mk = 'HKLM\SYSTEM\CurrentControlSet\Enum\' + $Sys.Main.Pnp + '\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties'
        Set-DeviceMsiIfDeclared $mk ([bool]$A.MsiTweaks) 'MSI mode видеокарты'
    } else { Log SKIP 'MSI mode видеокарты: отдельной видеокарты на PCIe нет' }
}

function Save-NvidiaBackup([string]$Driver) {
    if (-not $Driver) { throw 'Версия драйвера неизвестна: профиль NVIDIA не применяется' }
    if ($State.NvDrs) {
        if ($State.NvDriver -ne $Driver -or -not (Test-NvidiaBackupFiles $DrsBackup)) { throw 'Версия драйвера изменилась или бэкап NVIDIA повреждён; профиль не применяется' }
        return
    }
    $stage = $DrsBackup + '.preparing-' + [guid]::NewGuid().ToString('N')
    try {
        [void][IO.Directory]::CreateDirectory($stage)
        $files = @(Get-ChildItem -LiteralPath $DrsDir -Filter '*.bin' -File -ErrorAction Stop)
        if ($files.Count -eq 0) { throw 'Файлы базы NVIDIA не найдены' }
        $manifest = @()
        foreach ($file in $files) {
            $dest = Join-Path $stage $file.Name
            Copy-Item -LiteralPath $file.FullName -Destination $dest -ErrorAction Stop
            $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            if ((Get-FileHash -LiteralPath $dest -Algorithm SHA256 -ErrorAction Stop).Hash -ne $hash) { throw 'Копия базы NVIDIA не совпадает с исходной' }
            $manifest += @{Name=$file.Name;Hash=$hash}
        }
        Write-JsonAtomic (Join-Path $stage 'manifest.json') @{Schema=1;Driver=$Driver;Files=$manifest}
        if (-not (Test-NvidiaBackupFiles $stage)) { throw 'Проверка бэкапа NVIDIA не пройдена' }
        if (Test-Path -LiteralPath $DrsBackup) { [IO.Directory]::Move($DrsBackup, ($DrsBackup + '.incomplete-' + [guid]::NewGuid().ToString('N'))) }
        [IO.Directory]::Move($stage, $DrsBackup)
        $State.NvDrs=$true; $State.NvDriver=$Driver; Save-State
    } finally { if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue } }
}

function Invoke-Nvidia($Sys, $Fl, $A) {
    Section 'Профиль NVIDIA'
    if (-not $Sys.IsNvidia) { Log SKIP 'Видеокарта не NVIDIA, пропускаю'; return 'skip' }
    if (-not (Test-Path -LiteralPath $DrsDir)) { Log SKIP 'Драйвер NVIDIA не установлен: профиль пропущен'; return 'nodriver' }
    $src = Join-Path $NpiSrc 'nvidiaProfileInspector.exe'
    if (-not (Test-Path -LiteralPath $src)) { Log ERR 'Нет папки nvidia рядом с батником, профиль пропущен'; return 'err' }
    try {
        # Profile Inspector копируем в бэкап: им же пользуются самопроверка и повторный импорт
        [void](New-Item -ItemType Directory -Path $NvDir -Force)
        foreach ($f in @(Get-ChildItem -LiteralPath $NpiSrc -File | Where-Object { $_.Extension -ne '.nip' })) { Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $NvDir $f.Name) -Force }
        $npi = Join-Path $NvDir 'nvidiaProfileInspector.exe'
        $firstBackup = -not $State.NvDrs
        Save-NvidiaBackup ([string]$Sys.Main.DriverVer)
        if ($firstBackup) {
            $before = Export-NvCustom $npi
            if ($before) { Copy-Item -LiteralPath $before -Destination (Join-Path $P3Root 'nvidia-до.nip') -Force; Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue }
        }
        $set = @(Get-NvSettings ([bool]$Fl.Video) ([bool]$A.NvUltra))
        if ($A.FrameLimitOnly) { $set=@(,@('Frame Rate Limiter', 0x10835002, [int]$A.FrameLimit.Value)) }
        if (-not $A.FrameLimitOnly -and -not $A.ChangeQuality) { $set = @($set | Where-Object { $_[0] -match 'Power management|pre-rendered|Low Latency|Shader Cache' }) }
        $nip = Join-Path $NvDir ($BR.Tag + ' BOOST.nip')
        Write-NvNip $nip $set
        $tracked=Merge-NvSettings (ConvertFrom-NvState $State.NvSet) $set
        $State.NvSet = @($tracked | ForEach-Object { '' + $_[1] + '|' + $_[2] + '|' + $_[0] })
        Save-State
        $res = Import-NvAndCheck $npi $nip $set
        if ($A.FrameLimitOnly) {
            if (-not $res.Checked -or $res.Bad.Count -gt 0) { Log ERR 'Лимит FPS NVIDIA записан, но подтвердить его в выгрузке не удалось';return 'err' }
            Log OK ('Общий лимит FPS NVIDIA проверен: '+$A.FrameLimit.Value);return 'ok'
        }
        if ($res.Bad.Count -eq 0 -and $res.Checked) { Log OK ('Профиль NVIDIA применён и проверен: ' + $set.Count + ' настроек (питание макс., низкая задержка ' + @{ $true = 'Ultra'; $false = 'Вкл' }[[bool]$A.NvUltra] + ', кэш шейдеров без лимита)') }
        elseif (-not $res.Checked) { Log OK 'Профиль NVIDIA применён (выгрузка для проверки не получилась, проверить в Панели NVIDIA)' }
        else { Log ERR ('Профиль NVIDIA: не встали ' + ($res.Bad -join ', ')) }
        return 'ok'
    } catch { Log ERR ('Профиль NVIDIA: ' + $_.Exception.Message); return 'err' }
}

function Invoke-NetTweaks($Sys, $A = $null) {
    Section 'Сеть'
    Apply-Reg 'Windows не ограничивает сеть, пока играет звук (NetworkThrottlingIndex)' @("$MM|NetworkThrottlingIndex|DWord|0xffffffff")
    Apply-Reg 'P2P-раздача обновлений другим ПК выкл' @('HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization|DODownloadMode|DWord|0')
    $nics = @(Get-PhysicalNics)
    if ($nics.Count -eq 0) { Log SKIP 'Сетевых карт не нашёл'; return }
    $nicKeys = @('*InterruptModeration', '*FlowControl', '*EEE', 'EEE', 'EEELinkAdvertisement', 'AdvancedEEE', 'EnableGreenEthernet', 'GreenEthernet', 'GigaLite', 'PowerSavingMode', 'ULPMode', '*SelectiveSuspend', 'EnablePowerManagement')
    $wired = @($nics | Where-Object { -not $_.Wifi })
    foreach ($nic in $nics) { if ($nic.Wifi) { Log SKIP ($nic.Desc + ': Wi-Fi не трогаю никогда') } }
    foreach ($nic in $wired) {
        $key = Get-NicClassKey $nic.Guid
        if (-not $key) { Log SKIP ($nic.Desc + ': настройки драйвера не нашлись'); continue }
        $changed = @()
        $script:RegNote = 'сетевая карта'
        foreach ($k in $nicKeys) {
            $v = Get-RegValue $key $k
            if ($null -eq $v -or [string]$v.Value -eq '0') { continue }
            try { Set-Reg $key $k 'String' '0'; $changed += $k } catch {}
        }
        $script:RegNote = ''
        if ($changed.Count -gt 0) { Log OK ($nic.Desc + ': выкл ' + ($changed -join ', ') + ' (после перезагрузки)') }
        else { Log SKIP ($nic.Desc + ': модерация прерываний и энергосбережение уже выключены или их нет у драйвера') }
        $g = '{' + $nic.Guid.Trim('{}') + '}'
        Apply-Reg ($nic.Desc + ': TcpAckFrequency и TCPNoDelay') @(
            ('HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\' + $g + '|TcpAckFrequency|DWord|1'),
            ('HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\' + $g + '|TCPNoDelay|DWord|1')
        )
        if ($nic.Pnp -match '^PCI\\') {
            $mk = 'HKLM\SYSTEM\CurrentControlSet\Enum\' + $nic.Pnp + '\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties'
            Set-DeviceMsiIfDeclared $mk ([bool]$A.MsiTweaks) 'MSI mode проводной сети'
        }
    }
    $pnps = @($wired | ForEach-Object { $_.Pnp } | Where-Object { $_ })
    if ($pnps.Count -gt 0) {
        $n = Disable-DevicePowerOff $pnps
        if ($n -gt 0) { Log OK ('Проводная сетевая: Windows не отключает её для экономии энергии (' + $n + ')') }
    }
}

function Invoke-BackgroundTweaks($Sys, $A, $Ctx) {
    Section 'Телеметрия, реклама, советы'
    Apply-Reg 'Политики диагностических данных и отзывов (уровень зависит от редакции Windows)' @(
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection|AllowTelemetry|DWord|0',
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection|DoNotShowFeedbackNotifications|DWord|1',
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat|AITEnable|DWord|0',
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\System|PublishUserActivities|DWord|0',
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\System|UploadUserActivities|DWord|0',
        'HKCU\Software\Microsoft\Siuf\Rules|NumberOfSIUFInPeriod|DWord|0',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy|TailoredExperiencesWithDiagnosticDataEnabled|DWord|0'
    )
    Log INFO 'Полное отключение диагностических данных доступно не во всех редакциях; запись AllowTelemetry не является проверкой фактической отправки'
    Apply-Reg 'Реклама, рекламный ID, предложения и советы Windows выкл' @(
        'HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo|Enabled|DWord|0',
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo|DisabledByGroupPolicy|DWord|1',
        "$CDM|SilentInstalledAppsEnabled|DWord|0",
        "$CDM|SystemPaneSuggestionsEnabled|DWord|0",
        "$CDM|SoftLandingEnabled|DWord|0",
        "$CDM|PreInstalledAppsEnabled|DWord|0",
        "$CDM|OemPreInstalledAppsEnabled|DWord|0",
        "$CDM|RotatingLockScreenOverlayEnabled|DWord|0",
        "$CDM|SubscribedContent-310093Enabled|DWord|0",
        "$CDM|SubscribedContent-338388Enabled|DWord|0",
        "$CDM|SubscribedContent-338389Enabled|DWord|0",
        "$CDM|SubscribedContent-338393Enabled|DWord|0",
        "$CDM|SubscribedContent-353694Enabled|DWord|0",
        "$CDM|SubscribedContent-353696Enabled|DWord|0",
        "$ADV|ShowSyncProviderNotifications|DWord|0",
        'HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement|ScoobeSystemSettingEnabled|DWord|0',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested|Enabled|DWord|0'
    )
    Apply-Reg 'Bing и веб-подсказки в поиске Пуска выкл' @(
        'HKCU\Software\Policies\Microsoft\Windows\Explorer|DisableSearchBoxSuggestions|DWord|1',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Search|BingSearchEnabled|DWord|0',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Search|CortanaConsent|DWord|0',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings|IsDynamicSearchBoxEnabled|DWord|0'
    )
    if ($Sys.IsWin11) {
        Apply-Reg 'Политики виджетов, прежнего Copilot, Recall и рекомендаций в Пуске' @(
            'HKLM\SOFTWARE\Policies\Microsoft\Dsh|AllowNewsAndInterests|DWord|0',
            'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot|TurnOffWindowsCopilot|DWord|1',
            'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot|TurnOffWindowsCopilot|DWord|1',
            "$ADV|ShowCopilotButton|DWord|0",
            'HKCU\Software\Policies\Microsoft\Windows\WindowsAI|DisableAIDataAnalysis|DWord|1',
            'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI|DisableAIDataAnalysis|DWord|1',
            "$ADV|Start_IrisRecommendations|DWord|0"
        )
        Log INFO 'Отдельное приложение Copilot этими старыми политиками не удаляется; его можно выбрать в разделе приложений'
    } else {
        Apply-Reg '«Новости и интересы» на панели задач выкл' @('HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds|EnableFeeds|DWord|0')
    }

}

function Invoke-StartupTweaks($Sys, $A, $Ctx) {
    Section 'Фон и автозагрузка'
    if ($A.RestrictBackground) {
    Apply-Reg 'Фоновые приложения выкл' @(
        'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications|GlobalUserDisabled|DWord|1',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Search|BackgroundAppGlobalToggle|DWord|0'
    )
    Apply-Reg 'Edge не висит в фоне и не стартует заранее' @(
        'HKLM\SOFTWARE\Policies\Microsoft\Edge|StartupBoostEnabled|DWord|0',
        'HKLM\SOFTWARE\Policies\Microsoft\Edge|BackgroundModeEnabled|DWord|0',
        'HKLM\SOFTWARE\Policies\Google\Chrome|BackgroundModeEnabled|DWord|0'
    )
    } else { Log SKIP 'Фон приложений и Edge сохранён; меняется только выбранная автозагрузка' }
    $keepOd = [bool]$Ctx.OneDrive.Block
    if ($A.ContainsKey('Startup')) { $auto = @($A.Startup) } else { $auto = @(Get-SuggestedStartup $Ctx) }
    if ($auto.Count -eq 0) { Log SKIP 'Нет выбранных записей автозагрузки' }
    foreach ($it in $auto) {
        try { Disable-StartupItem $it; Log OK ('Автозапуск выкл: ' + $it.Title) } catch { Log ERR ('Автозапуск ' + $it.Title + ': ' + $_.Exception.Message) }
    }
    if ($keepOd) { Log SKIP 'OneDrive: автозапуск оставлен, в нём лежат папки пользователя' }

}

function Invoke-TaskTweaks($Sys, $A, $Ctx) {
    Section 'Задачи телеметрии в планировщике'
    $tasks = @(
        '\Microsoft\Windows\Application Experience\|Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Application Experience\|ProgramDataUpdater',
        '\Microsoft\Windows\Application Experience\|MareBackup',
        '\Microsoft\Windows\Application Experience\|StartupAppTask',
        '\Microsoft\Windows\Application Experience\|PcaPatchDbTask',
        '\Microsoft\Windows\Customer Experience Improvement Program\|Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\|UsbCeip',
        '\Microsoft\Windows\Customer Experience Improvement Program\|KernelCeipTask',
        '\Microsoft\Windows\Autochk\|Proxy',
        '\Microsoft\Windows\DiskDiagnostic\|Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Feedback\Siuf\|DmClient',
        '\Microsoft\Windows\Feedback\Siuf\|DmClientOnScenarioDownload',
        '\Microsoft\Windows\Windows Error Reporting\|QueueReporting',
        '\Microsoft\Windows\Maps\|MapsUpdateTask',
        '\Microsoft\Windows\Maps\|MapsToastTask',
        '\Microsoft\Windows\CloudExperienceHost\|CreateObjectTask',
        '\Microsoft\Windows\Power Efficiency Diagnostics\|AnalyzeSystem',
        '\Microsoft\Windows\NetTrace\|GatherNetworkInfo',
        '\Microsoft\Windows\Device Information\|Device',
        '\Microsoft\Windows\Device Information\|Device User',
        '\Microsoft\Windows\PI\|Sqm-Tasks',
        '\Microsoft\Office\|OfficeTelemetryAgentLogOn2016',
        '\Microsoft\Office\|OfficeTelemetryAgentFallBack2016',
        '\Microsoft\Office\|OfficeTelemetryAgentLogOn',
        '\Microsoft\Office\|OfficeTelemetryAgentFallBack'
    )
    $off = 0; $skip = 0
    foreach ($t in $tasks) {
        $p = $t.Split('|')
        $task = Get-ScheduledTask -TaskPath $p[0] -TaskName $p[1] -ErrorAction SilentlyContinue
        if (-not $task -or [string]$task.State -eq 'Disabled') { $skip++; continue }
        Add-StateList 'Tasks' $t
        try { [void](Disable-ScheduledTask -TaskPath $p[0] -TaskName $p[1] -ErrorAction Stop); $off++ } catch { $skip++ }
    }
    if ($off -gt 0) { Log OK ('Задачи телеметрии выкл: ' + $off + ' (остальных нет в системе или уже выключены: ' + $skip + ')') } else { Log SKIP 'Задачи телеметрии: уже выключены или их нет' }

}

function Invoke-ServiceTweaks($Sys, $A, $Ctx) {
    Section 'Службы'
    Disable-Svc @('DiagTrack', 'dmwappushservice', 'WerSvc', 'MapsBroker', 'Fax', 'RemoteRegistry', 'RetailDemo', 'WMPNetworkSvc', 'diagnosticshub.standardcollector.service', 'TrkWks')
    $keep = @($A.Svc)
    if ($keep -contains 1) { Log SKIP 'Печать: оставлена' } else { Disable-Svc @('Spooler') }
    if ($keep -contains 2) { Log SKIP 'Bluetooth: оставлен' } else { Disable-Svc @('bthserv', 'BTAGService', 'BthAvctpSvc') }
    if ($keep -contains 3) { Log SKIP 'Xbox: оставлен' } else { Disable-Svc @('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc') }
    if ($keep -contains 4) { Log SKIP 'Удалённый рабочий стол: оставлен' } else { Disable-Svc @('TermService', 'UmRdpService', 'SessionEnv') }
    if ($keep -contains 5) { Log SKIP 'Биометрия: оставлена' } else { Disable-Svc @('WbioSrvc') }
    if ($keep -contains 6) { Log SKIP 'Геолокация: оставлена' } else { Disable-Svc @('lfsvc') }
    if ($keep -contains 7) { Log SKIP 'Поиск по файлам: оставлен' } else { Disable-Svc @('WSearch') }
    $domain = $false
    try { $domain = [bool](Get-CimInstance Win32_ComputerSystem).PartOfDomain } catch {}
    if ($keep -contains 8 -or $domain) { Log SKIP 'Смарт-карты: оставлены' } else { Disable-Svc @('SCardSvr', 'ScDeviceEnum', 'SCPolicySvc') }
    if ($A.UsesVbs) { Log SKIP 'Hyper-V: службы оставлены (Valorant, FACEIT или виртуализация)' }
    else { Disable-Svc @('HvHost', 'vmickvpexchange', 'vmicguestinterface', 'vmicshutdown', 'vmicheartbeat', 'vmicvmsession', 'vmicrdv', 'vmictimesync', 'vmicvss') }
    # SysMain: на SSD выкл, на HDD и при 8 ГБ и меньше нужен (на нём держится сжатие памяти)
    if (-not $Sys.IsSSD) { Log SKIP 'SysMain: системный диск HDD, оставлен' }
    elseif ($Sys.RamGB -le 8) { Log SKIP 'SysMain: памяти 8 ГБ и меньше, оставлен ради сжатия памяти' }
    elseif ($A.DisableSysMain) { Disable-Svc @('SysMain') }
    else { Log SKIP 'SysMain оставлен: тип накопителя сам по себе не требует отключения' }

}

function Invoke-DefenderTweaks($Sys, $A, $Ctx) {
    Section 'Defender и обновления'
    try {
        $mp = Get-MpPreference -ErrorAction Stop
        if ($null -eq $State.DefenderOld) { $State.DefenderOld = @{ ScanAvgCPULoadFactor = [int]$mp.ScanAvgCPULoadFactor; EnableLowCpuPriority = [bool]$mp.EnableLowCpuPriority }; Save-State }
        Set-MpPreference -ScanAvgCPULoadFactor 25 -EnableLowCpuPriority $true -ErrorAction Stop
        $mp2 = Get-MpPreference -ErrorAction Stop
        if ([int]$mp2.ScanAvgCPULoadFactor -eq 25) { $State.DefenderSet = $true; Save-State; Log OK 'Defender: целевая средняя нагрузка плановой проверки 25%; это не жёсткий лимит CPU' }
        else { Log SKIP 'Defender не принял настройку (защита от подделки или другой антивирус), защита работает как раньше' }
    } catch { Log SKIP ('Defender не активен или недоступен: ' + $_.Exception.Message) }
    if (@($A.DefExcl).Count -gt 0) {
        $added = @()
        foreach ($d in $A.DefExcl) {
            try {
                $have = @((Get-MpPreference -ErrorAction Stop).ExclusionPath)
                if ($have -contains $d) { continue }
                Add-MpPreference -ExclusionPath $d -ErrorAction Stop
                $added += $d
                Add-StateList 'DefExcl' $d
            } catch {}
        }
        if ($added.Count -gt 0) { Log OK ('Исключения Defender (только папки игр): ' + ($added -join '; ')) }
        else { Log SKIP 'Исключения Defender: уже есть или Defender выключен другим антивирусом' }
    } else { Log SKIP 'Исключения Defender: не добавлял' }
    $au=Get-RegValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUOptions'
    if ($au -and [int]$au.Value -eq 4) {
        Apply-Reg 'Политика перезагрузки для уже настроенных плановых обновлений (AUOptions=4)' @(
            'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU|NoAutoRebootWithLoggedOnUsers|DWord|1'
        )
    } else { Log INFO 'Перезагрузки обновлений: сохраняются активные часы Windows; отдельный запрет без AUOptions=4 не обещается' }
}

function Invoke-Apps($Sys, $A, $Ctx) {
    Section 'Приложения'
    $scopeAll = ($A.AppScope -eq 'AllUsers')
    $all = @($A.Junk)
    if ($A.Light -and $Sys.IsWin11) {
        $np = @(Get-AppPackages 'Microsoft.WindowsNotepad' $scopeAll)
        if ($np.Count -gt 0) {
            if (Test-Path -LiteralPath (Join-Path $env:SystemRoot 'System32\notepad.exe')) { $all += [pscustomobject]@{ Name = 'Microsoft.WindowsNotepad'; Title = 'Блокнот (новый)'; Packages = $np; AllUsers = $scopeAll } }
            else { Log SKIP 'Новый Блокнот оставлен: старого notepad.exe в System32 нет' }
        }
    }
    if ($all.Count -eq 0) { Log SKIP 'Удалять нечего (так решили или уже удалено)' }
    else {
        Write-Host '   Удаляю приложения, это может занять пару минут...' -ForegroundColor DarkGray
        foreach ($app in $all) {
            if (Remove-JunkApp $app) { Log OK ('Удалено: ' + $app.Title) } else { Log SKIP ($app.Title + ': Windows не дала удалить') }
        }
    }
    if ($A.Light) {
        if (Enable-ClassicWmp) {
            Log OK 'Windows Media Player (классический) включён'
            $players = @()
            foreach ($s in @('Microsoft.ZuneMusic|Медиаплеер (новый)', 'Microsoft.ZuneVideo|Кино и ТВ')) {
                $p = $s.Split('|')
                $pk = @(Get-AppPackages $p[0] $scopeAll)
                if ($pk.Count -gt 0) { $players += [pscustomobject]@{ Name = $p[0]; Title = $p[1]; Packages = $pk; AllUsers = $scopeAll } }
            }
            foreach ($app in $players) { if (Remove-JunkApp $app) { Log OK ('Удалено: ' + $app.Title) } }
        } else { Log SKIP 'Классический Windows Media Player не включился (редакция N без медиапакета?), новый плеер оставлен' }
        $fa = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'
        Apply-Reg 'Старый просмотр фотографий доступен для JPG, PNG, BMP, GIF' @(@('.jpg', '.jpeg', '.jpe', '.jfif', '.png', '.bmp', '.dib', '.gif', '.ico', '.wdp', '.jxr') | ForEach-Object { $fa + '|' + $_ + '|String|PhotoViewer.FileAssoc.Tiff' })
    } else { Log SKIP 'Лёгкие замены: не нужны по ответу' }
    if ($A.Menu) {
        try {
            $clsid = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
            if (Test-Path -LiteralPath ($clsid + '\InprocServer32')) { Log SKIP 'Старое меню правой кнопки уже включено' }
            else {
                [void](New-Item -Path ($clsid + '\InprocServer32') -Force)
                Set-ItemProperty -LiteralPath ($clsid + '\InprocServer32') -Name '(default)' -Value ''
                $State.ClassicMenu = $true; Save-State
                Log OK 'Старое меню правой кнопки вкл (после перезагрузки)'
            }
        } catch { Log ERR ('Меню правой кнопки: ' + $_.Exception.Message) }
    }
    if ($A.OneDrive) {
        try { Get-Process -Name 'OneDrive' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue } catch {}
        $done = $false
        foreach ($exe in $Ctx.OneDrive.Setups) {
            $odArgs = @('/uninstall')
            if ($exe -match 'Program Files') { $odArgs += '/allusers' }
            try { $pr = Start-Process -FilePath $exe -ArgumentList $odArgs -PassThru -WindowStyle Hidden; if ($pr.WaitForExit(180000)) { $done = $true; break } } catch {}
        }
        if ($done) { $State.OneDriveRemoved = $true; Save-State; Log OK 'OneDrive удалён (файлы на ПК остались в папке OneDrive)' }
        else { Log ERR 'OneDrive не удалился. Руками: Параметры > Приложения > Microsoft OneDrive > Удалить' }
    } else { Log SKIP ('OneDrive: ' + @{ $true = $A.OneDriveNote; $false = 'оставлен' }[[bool]$A.OneDriveNote]) }
}

function Invoke-MouseMonitor($Sys, $A) {
    Section 'Мышь и монитор'
    if ($A.NoAccel) {
        try {
            Apply-Reg 'Акселерация мыши выкл («Повышенная точность установки указателя»)' @(
                'HKCU\Control Panel\Mouse|MouseSpeed|String|0',
                'HKCU\Control Panel\Mouse|MouseThreshold1|String|0',
                'HKCU\Control Panel\Mouse|MouseThreshold2|String|0'
            )
            if (-not ('P3Mouse' -as [type])) { Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class P3Mouse { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(uint a, uint b, int[] c, uint d); }' }
            [void][P3Mouse]::SystemParametersInfo(4, 0, [int[]]@(0, 0, 0), 2)
        } catch { Log ERR ('Акселерация мыши: ' + $_.Exception.Message) }
    } else { Log SKIP 'Акселерация мыши: оставлена как есть' }
    if ($A.Monitor) {
        $rr = $Sys.Refresh
        try {
            if (Set-RefreshRate $rr.Max) {
                $State.Monitor = @{ Old = $rr.Current; New = $rr.Max; W = $rr.W; H = $rr.H }; Save-State
                $now = Get-RefreshRate
                if ($now -and $now.Current -eq $rr.Max) { Log OK ('Частота монитора: ' + $rr.Current + ' > ' + $rr.Max + ' Гц') }
                else { Log ERR ('Частота монитора: Windows приняла, но сейчас ' + $now.Current + ' Гц') }
            } else { Log ERR ('Частота монитора: Windows не дала поставить ' + $rr.Max + ' Гц (кабель или драйвер)') }
        } catch { Log ERR ('Частота монитора: ' + $_.Exception.Message) }
    }
}

function Invoke-Programs($Sys, $A) {
    Section 'Программы'
    $want = @($Programs | Where-Object { @($A.Progs) -contains $_.N })
    if ($want.Count -eq 0) { Log SKIP 'Программы не выбраны'; return @() }
    [void](New-Item -ItemType Directory -Path $ProgDir -Force)
    $note = @('Установщики от ' + $BR.Title + '.')
    if (-not $BR.Client) { $note = @('Установщики от ' + $BR.Pack + '.') }
    [IO.File]::WriteAllText((Join-Path $ProgDir 'ПРОЧИТАЙ.txt'), (($note + '') -join "`r`n"), $Utf8Bom)
    $wg = Get-Winget
    if (-not $wg) { Log INFO 'winget не найден: качаю прямо с сайтов программ' }
    $done = @()
    foreach ($p in $want) {
        Write-Host ('   Ставлю ' + $p.Title + '...') -ForegroundColor DarkGray
        try {
            $how = Install-Program $p $wg
            Log OK ($p.Title + ': ' + $how)
            $done += $p.Title
            Add-StateList 'Programs' $p.Title
        } catch { Log ERR ($p.Title + ': ' + $_.Exception.Message + ' (остальное идёт дальше)') }
    }
    if ($done -contains 'Process Lasso') {
        $n = Stop-Lasso
        Log OK 'Process Lasso выключен до настройки с продавцом (не запущен, автозапуск выкл)'
    }
    return $done
}

function Invoke-Cleanup {
    Section 'Чистка временных файлов'
    [int64]$freed = 0
    foreach ($dir in @($env:TEMP, (Join-Path $env:SystemRoot 'Temp'), (Join-Path $env:SystemRoot 'SoftwareDistribution\Download'))) {
        if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { continue }
        foreach ($i in @(Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue)) {
            if ($env:P3_SELF.StartsWith($i.FullName, [StringComparison]::OrdinalIgnoreCase)) { continue }
            [int64]$size = 0
            try {
                if ($i.PSIsContainer) { $size = [int64](Get-ChildItem -LiteralPath $i.FullName -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum }
                else { $size = $i.Length }
            } catch {}
            try { Remove-Item -LiteralPath $i.FullName -Recurse -Force -ErrorAction Stop; $freed += $size } catch {}
        }
    }
    Log OK ('TEMP и скачанные обновления: удалено ' + [math]::Round($freed / 1MB) + ' МБ (занятые файлы пропущены, это не откатывается)')
}

# Подсказки: батник ничего не меняет, только пишет в итог
function Get-Hints($Sys, [string]$Prof) {
    $h = @()
    Section 'Проверки и подсказки'
    if ($Prof -ne 'Laptop' -and $Sys.RamMHz -gt 0) {
        $limit = 2666
        if ($Sys.RamType -eq 'DDR5') { $limit = 4800 }
        if ($Sys.RamType -eq 'DDR3') { $limit = 1600 }
        $slow = ($Sys.RamType -ne '' -and $Sys.RamMHz -le $limit) -or ($Sys.RamRated -gt 0 -and $Sys.RamMHz -lt $Sys.RamRated - 100)
        if ($slow) {
            Log INFO ('Память работает на ' + $Sys.RamMHz + ' МГц: проверь характеристики модулей и настройки памяти; причина по одной частоте неизвестна')
            $h += ('Память на ' + $Sys.RamMHz + ' МГц: сверь режим с характеристиками модулей; изменение XMP/EXPO требует отдельной проверки стабильности' + $BR.Plus + '.')
        } else { Log OK ('Память: ' + (($Sys.RamType + ' ' + $Sys.RamMHz + ' МГц').Trim()) + ', всё в порядке') }
    }
    try {
        $rr = Get-RefreshRate
        if ($rr -and $rr.Max - $rr.Current -ge 5) { Log INFO ('Монитор на ' + $rr.Current + ' Гц, а умеет ' + $rr.Max + ' Гц'); $h += ('Монитор на ' + $rr.Current + ' Гц: Параметры > Система > Дисплей > Расширенные параметры дисплея > ' + $rr.Max + ' Гц.') }
        elseif ($rr -and $rr.Max -le 60 -and -not $Sys.IsLaptop) { Log INFO 'Монитор отдаёт только 60 Гц'; $h += 'Монитор отдаёт только 60 Гц. Если он на 144+ Гц: кабель DisplayPort (или HDMI 2.0+) и в видеокарту, а не в материнку.' }
        elseif ($rr) { Log OK ('Монитор: ' + $rr.Current + ' Гц, это максимум для ' + $rr.Res) }
    } catch {}
    $sb = $null
    try { $sb = Confirm-SecureBootUEFI -ErrorAction Stop } catch {}
    if ($sb -eq $true) { Log OK 'Secure Boot вкл (нужен Valorant, FACEIT, CoD, Battlefield 6)' }
    elseif ($sb -eq $false) { Log INFO 'Secure Boot выкл'; $h += 'Secure Boot выкл: нужен только для Valorant, FACEIT, CoD и Battlefield 6. Включается в BIOS > Boot/Security > Secure Boot.' }
    else { Log INFO 'Secure Boot недоступен (BIOS в режиме Legacy/CSM)'; $h += 'BIOS в режиме Legacy/CSM: Secure Boot не включить без перевода диска в GPT. Только если клиент сам этого хочет.' }
    $tpmOk = $false
    try {
        $tpm = Get-CimInstance -Namespace 'root/cimv2/Security/MicrosoftTpm' -ClassName Win32_Tpm -ErrorAction Stop | Select-Object -First 1
        if ($tpm -and ([string]$tpm.SpecVersion).StartsWith('2.0') -and $tpm.IsEnabled_InitialValue) { $tpmOk = $true }
    } catch {}
    if ($tpmOk) { Log OK 'TPM 2.0 вкл' } else { Log INFO 'TPM 2.0 не найден или выключен'; $h += 'TPM 2.0 выкл: нужен для Valorant и FACEIT на Windows 11. BIOS > fTPM (AMD) или PTT (Intel).' }
    $vgk = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Services\vgk' 'Start'
    if ($vgk -and [int]$vgk.Value -eq 4) { Log INFO 'Vanguard выключен в службах: Valorant не запустится'; $h += 'Vanguard выключен: удалить Riot Vanguard и запустить Valorant, он поставит заново.' }
    if ($Sys.Main -and $Sys.Main.DriverDate) {
        $days = [int]((Get-Date) - $Sys.Main.DriverDate).TotalDays
        if ($days -gt 120) { Log INFO ('Драйвер видеокарты от ' + $Sys.Main.DriverDate.ToString('dd.MM.yyyy') + ' (' + $days + ' дн.)'); $h += 'Драйвер видеокарты старый: обнови через приложение NVIDIA или AMD Adrenalin (батник драйверы не ставит).' }
        else { Log OK ('Драйвер видеокарты свежий, от ' + $Sys.Main.DriverDate.ToString('dd.MM.yyyy')) }
    }
    try {
        $kinds = @{}
        $onHdd = @()
        foreach ($g in @(Get-GameFolders)) {
            if ($g.Path -notmatch '^([A-Za-z]):') { continue }
            $l = $Matches[1].ToUpper()
            if (-not $kinds.ContainsKey($l)) { $kinds[$l] = Get-DriveKind $l }
            if ($kinds[$l] -eq 'HDD') { $onHdd += ($g.Title + ' (' + $l + ':)') }
        }
        if ($onHdd.Count -gt 0) {
            $games = (@($onHdd | Select-Object -Unique | Select-Object -First 6) -join ', ')
            Log INFO ('Игры на HDD: ' + $games)
            $h += ('Игры на HDD (' + $games + '): дольше грузятся и подлагивают. Если есть место, перенести на SSD.')
        } elseif ($kinds.Count -gt 0) { Log OK 'Игр на HDD нет' }
    } catch {}
    $h += 'Надпись «Некоторыми параметрами управляет ваша организация» может появиться из-за локальных политик BOOST; сама надпись не определяет источник управления.'
    return $h
}

# PLAYSIN BOOST 3.0 · playsin333
# ---------------------------------------------------------------------
#  NVIDIA: выгрузка изменённых профилей и сверка базового профиля с нашим
#  набором. Нужна основному батнику и самопроверке
# ---------------------------------------------------------------------
$NvCode = @'
function Export-NvCustom([string]$Npi) {
    $dir = Split-Path -Parent $Npi
    foreach ($e in @(Get-ChildItem -LiteralPath $dir -Filter 'CustomProfiles_*.nip' -ErrorAction SilentlyContinue)) { Remove-Item -LiteralPath $e.FullName -Force -ErrorAction SilentlyContinue }
    try {
        $pr = Start-Process -FilePath $Npi -ArgumentList '-exportCustomized' -WorkingDirectory $dir -PassThru -WindowStyle Hidden
        if (-not $pr.WaitForExit(60000)) { try { $pr.Kill() } catch {}; return $null }
    } catch { return $null }
    $e = @(Get-ChildItem -LiteralPath $dir -Filter 'CustomProfiles_*.nip' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
    if ($e.Count -gt 0) { return $e[0].FullName }
    return $null
}

function Get-NvBase([string]$Path) {
    $map = @{}
    $x = New-Object System.Xml.XmlDocument
    $x.Load($Path)
    if (-not $x.DocumentElement -or $x.DocumentElement.Name -ne 'ArrayOfProfile') {throw 'Неизвестный формат выгрузки NVIDIA'}
    foreach ($p in @($x.SelectNodes('//Profile'))) {
        if ([string]$p.ProfileName -ne 'Base Profile') { continue }
        foreach ($s in @($p.SelectNodes('Settings/ProfileSetting'))) { $map[[string]$s.SettingID] = [string]$s.SettingValue }
    }
    return $map
}

# Set: @(имя, ID, значение). Checked: выгрузка получилась. Bad: что стоит не так.
# Чего нет в выгрузке, то совпадает со значением драйвера по умолчанию; режим питания должен быть всегда
function Test-NvSet([string]$Npi, $Set) {
    $exp = Export-NvCustom $Npi
    if (-not $exp) { return @{ Checked = $false; Bad = @() } }
    $map = @{}
    try { $map = Get-NvBase $exp } catch { Remove-Item -LiteralPath $exp -Force -ErrorAction SilentlyContinue;return @{Checked=$false;Bad=@()} }
    Remove-Item -LiteralPath $exp -Force -ErrorAction SilentlyContinue
    if ($map.Count -eq 0) {
        $onlyDefault=@($Set | Where-Object { [string]$_[1] -ne [string]0x10835002 -or [int]$_[2] -ne 0 }).Count -eq 0
        if ($onlyDefault) { return @{Checked=$true;Bad=@()} }
        return @{ Checked = $false; Bad = @() }
    }
    $bad = @()
    foreach ($s in $Set) {
        $k = [string]$s[1]
        if ($map.ContainsKey($k)) { if ([string]$map[$k] -ne [string]$s[2]) { $bad += [string]$s[0] } }
        elseif ($k -eq [string]0x10835002 -and [int]$s[2] -ne 0) { $bad += [string]$s[0] }
        elseif ($k -eq '274197361') { $bad += [string]$s[0] }
    }
    return @{ Checked = $true; Bad = $bad }
}

function Import-NvNip([string]$Npi, [string]$Nip) {
    $pr = Start-Process -FilePath $Npi -ArgumentList @(('"' + $Nip + '"'), '-silentImport', '-mergeImport') -WorkingDirectory (Split-Path -Parent $Npi) -PassThru -WindowStyle Hidden
    if (-not $pr.WaitForExit(90000)) { try { $pr.Kill() } catch {}; throw 'Profile Inspector не ответил за 90 секунд' }
    if ($pr.ExitCode -ne 0) {throw ('Profile Inspector завершился с кодом '+$pr.ExitCode)}
}

function Import-NvAndCheck([string]$Npi, [string]$Nip, $Set) {
    Import-NvNip $Npi $Nip
    return (Test-NvSet $Npi $Set)
}

# Из state.json: строки 'ID|значение|имя' обратно в набор
function ConvertFrom-NvState($Lines) {
    $set = @()
    foreach ($l in @($Lines)) {
        $p = ([string]$l).Split('|')
        if ($p.Count -ge 3) { $set += ,@($p[2], [int64]$p[0], [int64]$p[1]) }
    }
    return ,$set
}
'@
. ([scriptblock]::Create($NvCode))

# ---------------------------------------------------------------------
#  Общее для отката, игрового режима и самопроверки (основной батник тоже
#  берёт отсюда ярлыки)
# ---------------------------------------------------------------------
$NestedCode = @'
$GameFile = Join-Path $P3Root 'game.json'
$GameFlag = Join-Path $P3Root 'game-off.flag'
$GameLog  = Join-Path $P3Root 'игровой режим лог.txt'

# Temporary game settings are journaled in game.json, not in the permanent tweak backup.
function Get-GameDownloadPolicy {
    try {
        $cv='HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        $build=Get-RegValue $cv 'CurrentBuildNumber';$edition=Get-RegValue $cv 'EditionID'
        if (-not $build -or [int]$build.Value -lt 17134 -or -not $edition -or [string]$edition.Value -notmatch '^(Professional|Enterprise|Education|IoTEnterprise)') { return $null }
        $admx=Join-Path $env:SystemRoot 'PolicyDefinitions\DeliveryOptimization.admx'
        if (-not (Test-Path -LiteralPath $admx)) { return $null }
        $xml=New-Object Xml.XmlDocument;$xml.XmlResolver=$null;$xml.Load($admx)
        foreach ($name in @('DOPercentageMaxBackgroundBandwidth','PercentageMaxBackgroundBandwidth')) {
            $node=$xml.SelectSingleNode(('//*[@valueName="'+$name+'"]'))
            if ($node) { return @{Path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization';Name=$name} }
        }
    } catch {}
    return $null
}

function Start-GameDownloads($St, $Game) {
    $percent=[int]$St.GameDownloadPercent
    if ($percent -le 0) { return }
    if ($percent -gt 100) { throw 'Недопустимый процент фоновых загрузок в состоянии игрового режима' }
    $policy=Get-GameDownloadPolicy
    if (-not $policy) { Write-Host '   Лимит фоновых загрузок не поддерживается этой редакцией/политиками Windows';return }
    $path=$policy.Path;$name=$policy.Name
    if (Get-RegValue 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\DeliveryOptimization' 'DOPercentageMaxBackgroundBandwidth') { Write-Host '   Загрузки управляются MDM; сохраняю политику';return }
    # Preserve existing management/user policies instead of overriding them on every game launch.
    foreach ($other in @('DOPercentageMaxBackgroundBandwidth','PercentageMaxBackgroundBandwidth','DOMaxBackgroundDownloadBandwidth','MaxBackgroundDownloadBandwidth','DOSetHoursToLimitBackgroundDownloadBandwidth','SetHoursToLimitBackgroundDownloadBandwidth')) {
        if (Get-RegValue $path $other) {Write-Host '   Пропускная полоса уже задана политикой; сохраняю её';return}
    }
    $old=Get-RegValue $path $name
    if ($old) { Write-Host '   Ограничение загрузок уже задано политикой; сохраняю его'; return }
    $domain=$false
    try { $domain=[bool](Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).PartOfDomain } catch { Write-Host '   Не удалось проверить управление ПК; лимит загрузок пропущен'; return }
    if ($domain) { Write-Host '   Доменный ПК: политика загрузок сохраняется'; return }
    Set-StateProp $Game 'DownloadPolicy' ([pscustomobject]@{Path=$path;Name=$name;Existed=$false;Kind=$null;Value=$null;Applied=$percent})
    Write-JsonAtomic $GameFile $Game
    Set-RawReg $path $name 'DWord' $percent
    $back=Get-RegValue $path $name
    if (-not $back -or $back.Kind -ne 'DWord' -or [int64]$back.Value -ne $percent) { throw 'Временный лимит загрузок не прошёл проверку' }
    Write-Host ('   Записана временная политика фоновых загрузок Windows: '+$percent+'% измеренной полосы; фактическую скорость регулирует Windows')
}
function Restore-GameDownloads($Game) {
    $item=$Game.DownloadPolicy
    if (-not $item) { return }
    # Never accept arbitrary registry paths from a stale/corrupt recovery journal.
    $path='HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
    $name='DOPercentageMaxBackgroundBandwidth'
    if ($item.Path -cne $path -or $item.Name -notin @('DOPercentageMaxBackgroundBandwidth','PercentageMaxBackgroundBandwidth') -or [int]$item.Applied -lt 1 -or [int]$item.Applied -gt 100) { throw 'Повреждена запись возврата лимита загрузок' }
    $name=[string]$item.Name
    $cur=Get-RegValue $path $name
    if (-not $cur) { return }
    if ($cur.Kind -ne 'DWord' -or [int64]$cur.Value -ne [int64]$item.Applied) { Write-Host '   Лимит загрузок изменён после BOOST; сохраняю новое значение'; return }
    if ($item.Existed) { Set-RawReg $path $name ([string]$item.Kind) $item.Value }
    else { Remove-RawReg $path $name }
    $back=Get-RegValue $path $name
    if (-not $item.Existed -and $back) { throw 'Не удалось убрать временный лимит загрузок; запись восстановления сохранена' }
    if ($item.Existed -and (-not $back -or (Format-RegData $back.Kind $back.Value) -cne (Format-RegData ([string]$item.Kind) $item.Value))) { throw 'Не удалось вернуть прежний лимит загрузок; запись восстановления сохранена' }
}
function Get-GamePowerScheme($St) {
    $present=$false
    if ($St -is [Collections.IDictionary]) {$present=$St.Contains('GamePowerEnabled')}
    else {$present=$null -ne $St.PSObject.Properties['GamePowerEnabled']}
    if ($present -and -not [bool]$St.GamePowerEnabled) { return '' }
    return [string]$St.GameScheme
}
function Game-Off($St) {
    if (-not (Test-Path -LiteralPath $GameFile)) { return $false }
    $g = Read-Json $GameFile
    if (-not $g -or -not $g.PSObject.Properties['OldScheme']) {throw 'Журнал игрового режима повреждён; файл сохранён для восстановления'}
    Restore-GameDownloads $g
    $game = [string]$St.GameScheme
    if ($g.PSObject.Properties['GameScheme']) {$game=[string]$g.GameScheme}
    if ($game -and (Get-ActiveScheme) -eq $game) {
        $to = [string]$g.OldScheme
        if (-not (Test-SchemeExists $to)) { $to = [string]$St.NewScheme }
        if (-not $to -or -not (Test-SchemeExists $to)) { throw 'Не найдена схема для возврата; состояние игрового режима сохранено' }
        $r = Invoke-Native 'powercfg.exe' @('/setactive', $to)
        if ($r.Code -ne 0 -or (Get-ActiveScheme) -ne $to) { throw 'Не удалось вернуть питание; состояние игрового режима сохранено для повторной попытки' }
    }
    Remove-Item -LiteralPath $GameFile -Force -ErrorAction Stop
    return $true
}

# Раз в 5 секунд: идёт ли игра, не мало ли памяти. Игру закрыли и полминуты её нет: выключаемся
function Undo-MemoryCompression($St) {
    if (-not $St.Mmc) { return }
    $wanted=($St.Mmc -eq 'on')
    $original=(-not $wanted)
    if ($St.PSObject.Properties['MemoryCompressionOriginal'] -or ($St -is [Collections.IDictionary] -and $St.Contains('MemoryCompressionOriginal'))) {$original=[bool]$St.MemoryCompressionOriginal}
    try {
        $current=[bool](Get-MMAgent -ErrorAction Stop).MemoryCompression
        if ($current -eq $original) {Log SKIP 'Сжатие памяти уже соответствует исходному состоянию';return}
        if ($current -ne $wanted -and -not (Ask 'Сжатие памяти менялось после BOOST. Вернуть исходное?' '' 'Вернуть' 'Сохранить новое' 2)) {Log ERR 'Новое состояние сжатия памяти сохранено; исходное остаётся в бэкапе';return}
        if ($original) {Enable-MMAgent -MemoryCompression -ErrorAction Stop}
        else {Disable-MMAgent -MemoryCompression -ErrorAction Stop}
        Log OK 'Сжатие памяти возвращено к исходному состоянию, после перезагрузки'
    } catch {Log ERR ('Сжатие памяти: '+$_.Exception.Message)}
}

function Undo-RtssFrameLimit($St) {
    $saved=$St.RtssFrameLimit
    if (-not $saved) { return }
    try {
        $cur=Get-RtssFrameLimit ([string]$saved.Directory)
        if ($cur -eq [uint32]$saved.Old) { Log SKIP 'RTSS: исходный лимит FPS уже восстановлен'; return }
        if ($cur -ne [uint32]$saved.New) {
            if (-not (Ask 'Лимит RTSS изменён после BOOST. Вернуть исходный?' 'Можно сохранить новое значение; откат останется незавершённым.' 'Вернуть исходный' 'Сохранить новый' 2)) { Log ERR 'RTSS: новое значение сохранено; исходный лимит остаётся в бэкапе';return }
        }
        Set-RtssFrameLimit ([string]$saved.Directory) ([uint32]$saved.Old)
        Log OK ('RTSS: исходный лимит FPS возвращён ('+$saved.Old+')')
    } catch { Log ERR ('RTSS: лимит не возвращён, бэкап сохранён: '+$_.Exception.Message) }
}

function Show-Head([string]$What) {
    Clear-Host
    try { $Host.UI.RawUI.WindowTitle = $BR.Title } catch {}
    Write-Host ''
    Write-Host '  ==================================================================' -ForegroundColor Cyan
    Write-Host ('     ' + $What + ' · ' + $BR.Pack) -ForegroundColor Cyan
    Write-Host '  ==================================================================' -ForegroundColor Cyan
}

function Save-StateObj($St) {
    Write-JsonAtomic $StateFile $St 12
}

function Set-StateProp($St, [string]$Name, $Value) {
    if ($St -is [Collections.IDictionary]) { $St[$Name]=$Value;return }
    if ($St.PSObject.Properties[$Name]) { $St.$Name = $Value } else { $St | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}

# Тип запуска службы через sc.exe: часть служб Windows закрывает от записи в реестр
function Set-SvcStartSc([string]$Path, $Value) {
    if ($Path -notmatch '\\Services\\([^\\]+)$') { return $false }
    $map = @{ 0 = 'boot'; 1 = 'system'; 2 = 'auto'; 3 = 'demand'; 4 = 'disabled' }
    $r = Invoke-Native 'sc.exe' @('config', $Matches[1], 'start=', $map[[int]$Value])
    return ($r.Code -eq 0)
}

# Значение из бэкапа обратно. Если его не было до BOOST, удаляем
function Restore-RegItem($E) {
    if (-not $E.Existed) { Remove-RawReg ([string]$E.Path) ([string]$E.Name); return }
    try { Set-RawReg ([string]$E.Path) ([string]$E.Name) ([string]$E.Kind) $E.Value }
    catch {
        $err = $_
        if ([string]$E.Name -eq 'Start' -and (Set-SvcStartSc ([string]$E.Path) $E.Value)) { return }
        throw $err
    }
}

# То, что поставил BOOST, ещё раз
function Set-RegItemNew($E) {
    try { Set-RawReg ([string]$E.Path) ([string]$E.Name) ([string]$E.NewKind) $E.NewValue }
    catch {
        $err = $_
        if ([string]$E.Name -eq 'Start' -and (Set-SvcStartSc ([string]$E.Path) $E.NewValue)) { return }
        throw $err
    }
}

function Test-RegOriginal($E) {
    $cur = Get-RegValue ([string]$E.Path) ([string]$E.Name)
    if (-not $E.Existed) { return ($null -eq $cur) }
    if ($null -eq $cur) { return $false }
    return ([string]$cur.Kind -eq [string]$E.Kind -and (Format-RegData ([string]$cur.Kind) $cur.Value) -eq (Format-RegData ([string]$E.Kind) $E.Value))
}

function Test-RegItem($E) {
    $cur = Get-RegValue ([string]$E.Path) ([string]$E.Name)
    if ($null -eq $cur) { return $false }
    return ([string]$cur.Kind -eq [string]$E.NewKind -and (Format-RegData ([string]$cur.Kind) $cur.Value) -eq (Format-RegData ([string]$E.NewKind) $E.NewValue))
}

# bcdedit на русской Windows иногда пишет значения по-русски, обратно ставим по-английски
function Convert-BcdWord([string]$V) {
    switch -Regex ($V) {
        '^(Да|Yes)$'   { return 'Yes' }
        '^(Нет|No)$'   { return 'No' }
        '^(Выкл|Off)$' { return 'Off' }
        '^(Авто|Auto)$' { return 'Auto' }
    }
    return $V
}

function Test-BcdEqual($Now, $Want) {
    if ($null -eq $Want -or [string]$Want -eq '') { return ($null -eq $Now) }
    if ($null -eq $Now) { return $false }
    return ((Convert-BcdWord ([string]$Now)) -ieq (Convert-BcdWord ([string]$Want)))
}

function Set-BcdItem([string]$Name, $Value) {
    if ($null -eq $Value -or [string]$Value -eq '') { [void](Invoke-Native 'bcdedit.exe' @('/deletevalue', '{current}', $Name)) }
    else { [void](Invoke-Native 'bcdedit.exe' @('/set', '{current}', $Name, (Convert-BcdWord ([string]$Value)))) }
    return (Test-BcdEqual (Get-BcdValue $Name) $Value)
}

# Значение схемы питания от сети: из реестра, а если его там нет, из powercfg /query (последние две цифры: от сети и от батареи)
function Get-PowerAcAny([string]$Scheme, [string]$Sub, [string]$Setting) {
    $v = Get-PowerAc $Scheme $Sub $Setting
    if ($null -ne $v) { return $v }
    $r = Invoke-Native 'powercfg.exe' @('/query', $Scheme, $Sub, $Setting)
    $hex = @([regex]::Matches($r.Out, '0x([0-9a-fA-F]{8})') | ForEach-Object { $_.Groups[1].Value })
    if ($hex.Count -ge 2) { return [Convert]::ToInt64($hex[$hex.Count - 2], 16) }
    return $null
}

function Test-OnAc {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        return ([string][Windows.Forms.SystemInformation]::PowerStatus.PowerLineStatus -ne 'Offline')
    } catch { return $true }
}

function New-RollbackLink {
    New-Shortcut (Join-Path $Desktop ($RollbackName + '.lnk')) (Join-Path $P3Root ($RollbackName + '.bat')) '' $P3Root ((Join-Path $P3Root 'raven.ico') + ',0') ('Откатить всё, что сделал ' + $BR.Pack) 1
}

# Ярлык запускает задачу планировщика: игровой режим с правами администратора без окна UAC на каждый клик
function New-GameLink {
    New-Shortcut (Join-Path $Desktop ($GameName + '.lnk')) (Join-Path $env:SystemRoot 'System32\schtasks.exe') ('/run /tn "' + $TaskGame + '"') $P3Root ((Join-Path $P3Root 'game.ico') + ',0') 'Игровой режим: клик включает, второй клик выключает' 7
}

# Оперативка: свободно и сколько лежит в кэше ожидания (его можно отдать игре)
$MemCode = '
using System;
using System.Runtime.InteropServices;
public static class P3Mem {
    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    struct TokPriv { public int Count; public long Luid; public int Attr; }
    [DllImport("ntdll.dll")] static extern int NtSetSystemInformation(int infoClass, ref int info, int length);
    [DllImport("advapi32.dll", SetLastError = true)] static extern bool OpenProcessToken(IntPtr h, int acc, out IntPtr tok);
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)] static extern bool LookupPrivilegeValue(string sys, string name, out long luid);
    [DllImport("advapi32.dll", SetLastError = true)] static extern bool AdjustTokenPrivileges(IntPtr tok, bool all, ref TokPriv n, int len, IntPtr p, IntPtr r);
    [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
    public static int PurgeStandby() {
        IntPtr t;
        if (!OpenProcessToken(GetCurrentProcess(), 0x28, out t)) { return -1; }
        TokPriv tp = new TokPriv();
        tp.Count = 1;
        tp.Attr = 2;
        if (!LookupPrivilegeValue(null, "SeProfileSingleProcessPrivilege", out tp.Luid)) { return -2; }
        if (!AdjustTokenPrivileges(t, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero)) { return -3; }
        int cmd = 4;
        return NtSetSystemInformation(80, ref cmd, 4);
    }
}
'

function Get-MemState {
    try {
        $m = Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory -ErrorAction Stop
        $standby = [int64]$m.StandbyCacheCoreBytes + [int64]$m.StandbyCacheNormalPriorityBytes + [int64]$m.StandbyCacheReserveBytes
        return @{ FreeMB = [int]([int64]$m.FreeAndZeroPageListBytes / 1MB); StandbyMB = [int]($standby / 1MB) }
    } catch { return $null }
}

function Clear-Standby {
    try {
        if (-not ('P3Mem' -as [type])) { Add-Type -TypeDefinition $MemCode }
        return ([P3Mem]::PurgeStandby() -eq 0)
    } catch { return $false }
}

# Маленький лог игрового режима в папке бэкапа, чтобы не раздувать лог на рабочем столе
function Write-GameLog([string]$Text) {
    try {
        if ((Test-Path -LiteralPath $GameLog) -and (Get-Item -LiteralPath $GameLog).Length -gt 200KB) {
            $keep = @([IO.File]::ReadAllLines($GameLog, [Text.Encoding]::UTF8) | Select-Object -Last 200)
            [IO.File]::WriteAllText($GameLog, (($BR.Sign, ($keep | Where-Object { $_ -ne $BR.Sign })) -join "`r`n") + "`r`n", $Utf8Bom)
        }
        if (-not (Test-Path -LiteralPath $GameLog)) { [IO.File]::WriteAllText($GameLog, $BR.Sign + "`r`n", $Utf8Bom) }
        [IO.File]::AppendAllText($GameLog, ((Get-Date -Format 'dd.MM.yyyy HH:mm') + '  ' + $Text + "`r`n"), $Utf8Bom)
    } catch {}
}

function Wait-Close([int]$Seconds) {
    Write-Host ''
    Write-Host ('  Окно закроется само через ' + [int]($Seconds / 60) + ' мин. или по любой клавише.') -ForegroundColor DarkGray
    Clear-Keys
    for ($i = 0; $i -lt $Seconds; $i++) {
        try { if ([Console]::KeyAvailable) { [void][Console]::ReadKey($true); return } } catch { return }
        Start-Sleep -Seconds 1
    }
}
'@
. ([scriptblock]::Create($NestedCode))

# ---------------------------------------------------------------------
#  Откат: всё из state.json и registry.json в обратную сторону
# ---------------------------------------------------------------------
$RollbackBody = @'
function Undo-Registry($Rg) {
    Section 'Значения реестра'
    $items = @($Rg.Items | Where-Object { $_ })
    [array]::Reverse($items)
    $conflicts = @($items | Where-Object { -not (Test-RegOriginal $_) -and -not (Test-RegItem $_) })
    $force = $false
    if ($conflicts.Count -gt 0) {
        foreach ($entry in $conflicts) { Log INFO ('После BOOST изменено: ' + $entry.Path + '\' + $entry.Name) }
        $force = Ask 'Вернуть также значения, изменённые после BOOST?' 'По умолчанию такие значения сохраняются. Бэкап останется, откат можно повторить.' 'Вернуть из исходного бэкапа' 'Сохранить последующие изменения' 2
    }
    $groups = [ordered]@{}
    foreach ($e in $items) {
        $note = [string]$e.Note
        if (-not $note) { $note = 'прочие значения' }
        if (-not $groups.Contains($note)) { $groups[$note] = @{ N = 0; Bad = @() } }
        $g = $groups[$note]
        $g.N++
        try {
            if (Test-RegOriginal $e) { continue }
            if (-not $force -and -not (Test-RegItem $e)) { throw 'Значение изменено после BOOST; оставлено по выбору пользователя' }
            Restore-RegItem $e
            if (-not (Test-RegOriginal $e)) { throw 'Значение после отката не совпадает с бэкапом' }
        }
        catch { $g.Bad += ([string]$e.Path + '\' + [string]$e.Name + ': ' + $_.Exception.Message) }
    }
    foreach ($k in $groups.Keys) {
        $g = $groups[$k]
        if ($g.Bad.Count -eq 0) { Log OK ($k + ': как было (' + $g.N + ')') }
        else {
            Log ERR ($k + ': не вернулось ' + $g.Bad.Count + ' из ' + $g.N)
            foreach ($b in $g.Bad) { Log INFO $b }
        }
    }
}

function Undo-Tasks($St) {
    Section 'Задачи Windows'
    $n = 0
    $bad = 0
    foreach ($t in @($St.Tasks | Where-Object { $_ })) {
        $p = ([string]$t).Split('|')
        try { [void](Enable-ScheduledTask -TaskPath $p[0] -TaskName $p[1] -ErrorAction Stop); $n++ }
        catch { if (Get-ScheduledTask -TaskPath $p[0] -TaskName $p[1] -ErrorAction SilentlyContinue) { $bad++ } }
    }
    if ($n -eq 0 -and $bad -eq 0) { Log SKIP 'Задачи планировщика не выключались' }
    elseif ($bad -eq 0) { Log OK ('Задачи планировщика включены обратно (' + $n + ')') }
    else { Log ERR ('Задачи планировщика: не включилось ' + $bad) }
}

function Undo-Power($St) {
    Section 'Питание'
    $owned = @(@($St.OwnedSchemes) + @([string]$St.GameScheme, [string]$St.NewScheme)) | Where-Object { $_ }
    if ($St.OldScheme -or @($owned).Count -gt 0) {
        $active = Get-ActiveScheme
        $change = (@($owned) -contains $active)
        if (-not $active) { Log ERR 'Активная схема неизвестна: свои схемы не удаляю' }
        else {
            $restored = $true
            if ($change) {
                $old = [string]$St.OldScheme
                if (-not $old -or -not (Test-SchemeExists $old)) { $old = '381b4222-f694-41f0-9685-ff5bb260df2e' }
                $r = Invoke-Native 'powercfg.exe' @('/setactive', $old)
                $restored = ($r.Code -eq 0 -and (Get-ActiveScheme) -eq $old)
                if ($restored) { Log OK 'Прежняя схема питания снова включена' }
                else { Log ERR 'Не удалось вернуть прежнюю схему: схемы BOOST оставлены для повторного отката' }
            } else { Log INFO 'Активная схема выбрана вне BOOST; сохраняю её' }
            if ($restored) {
                foreach ($g in @($owned | Select-Object -Unique)) {
                    if ($g -eq (Get-ActiveScheme) -or -not (Test-SchemeExists $g)) { continue }
                    $d = Invoke-Native 'powercfg.exe' @('/delete', $g)
                    if ($d.Code -ne 0 -or (Test-SchemeExists $g)) { Log ERR ('Не удалось удалить схему BOOST: ' + $g) }
                    else { Log OK ('Удалена схема BOOST: ' + $g) }
                }
            }
        }
    } else { Log SKIP 'Схемы питания BOOST не создавались' }
    if ($St.HiberWasOn) {
        $h = Invoke-Native 'powercfg.exe' @('/hibernate', 'on')
        if ($h.Code -eq 0) { Log OK 'Гибернация включена обратно' } else { Log ERR ('Гибернация: ' + $h.Out) }
    }
    $n = 0
    $bad = 0
    $devs = @($St.PowerDevs | Where-Object { $_ })
    if ($devs.Count -gt 0) {
        foreach ($it in @(Get-CimInstance -Namespace 'root/wmi' -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue)) {
            if ($devs -notcontains [string]$it.InstanceName -or $it.Enable) { continue }
            try { Set-CimInstance -InputObject $it -Property @{ Enable = $true } -ErrorAction Stop; $n++ } catch { $bad++ }
        }
        if ($bad -eq 0) { Log OK ('Экономия энергии устройств как была (' + $n + ')') } else { Log ERR ('Экономия энергии: не вернулось у ' + $bad + ' устройств') }
    }
}

function Undo-Bcd($St) {
    Section 'Загрузчик'
    $list = @()
    if ($St.Bcd) { $list = @($St.Bcd.PSObject.Properties) }
    if ($list.Count -eq 0) { Log SKIP 'Загрузчик не менялся'; return }
    if (-not (Suspend-BitLockerOnce)) { Log ERR 'Загрузчик не возвращаю: BitLocker не встал на паузу. Запусти откат ещё раз'; return }
    foreach ($p in $list) {
        try {
            if (Set-BcdItem $p.Name $p.Value.Old) { Log OK ($p.Name + ': как было (после перезагрузки)') }
            else { Log ERR ($p.Name + ': bcdedit не принял') }
        } catch { Log ERR ($p.Name + ': ' + $_.Exception.Message) }
    }
}

function Undo-Nvidia($St) {
    Section 'Видеокарта'
    if (-not $St.NvDrs) { Log SKIP 'Профиль NVIDIA не менялся'; return }
    if (-not (Test-Path -LiteralPath $DrsBackup)) { Log ERR 'Бэкап NVIDIA отсутствует: восстановление не выполнено'; return }
    if (-not (Test-NvidiaBackupFiles $DrsBackup)) { Log ERR 'Бэкап NVIDIA не прошёл проверку целостности'; return }
    $files = @(Get-ChildItem -LiteralPath $DrsBackup -File -Filter '*.bin' -ErrorAction Stop)
    if ($files.Count -eq 0) { Log ERR 'Бэкап NVIDIA пуст: восстановление не выполнено'; return }
    $now = ''
    try { $now = [string](@(Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { [string]$_.Name -match 'NVIDIA' })[0].DriverVersion) } catch {}
    if (-not $now -or -not $St.NvDriver -or $now -ne [string]$St.NvDriver) {
        Log ERR 'Драйвер NVIDIA с тех пор обновили, старые настройки ему не подойдут. Панель NVIDIA > Управление параметрами 3D > «Восстановить»'
        return
    }
    $svc = 'NVDisplay.ContainerLocalSystem'
    try { Stop-Service -Name $svc -Force -ErrorAction Stop -WarningAction SilentlyContinue }
    catch { Log ERR ('Служба NVIDIA не остановлена; базу не заменяю: ' + $_.Exception.Message); return }
    try {
        foreach ($f in $files) {
            $dest = Join-Path $DrsDir $f.Name
            Copy-Item -LiteralPath $f.FullName -Destination $dest -Force -ErrorAction Stop
            if ((Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash) { throw ('Не совпала копия ' + $f.Name) }
        }
        Log OK 'Профиль NVIDIA как был до BOOST'
    } catch { Log ERR ('NVIDIA: ' + $_.Exception.Message) }
    try { Start-Service -Name $svc -ErrorAction Stop -WarningAction SilentlyContinue } catch { Log ERR ('Служба NVIDIA не запущена: ' + $_.Exception.Message) }
}

function Undo-Misc($St) {
    Section 'Defender, память, меню, монитор'
    if ($St.DefenderOld) {
        try { Set-MpPreference -ScanAvgCPULoadFactor ([int]$St.DefenderOld.ScanAvgCPULoadFactor) -EnableLowCpuPriority ([bool]$St.DefenderOld.EnableLowCpuPriority) -ErrorAction Stop; Log OK 'Defender: нагрузка проверки как была' }
        catch { Log SKIP ('Defender сейчас недоступен: ' + $_.Exception.Message) }
    }
    $ex = @($St.DefExcl | Where-Object { $_ })
    if ($ex.Count -gt 0) {
        try { Remove-MpPreference -ExclusionPath $ex -ErrorAction Stop; Log OK ('Наши исключения Defender убраны (' + $ex.Count + '), чужие не трогал') }
        catch { Log ERR ('Исключения Defender: ' + $_.Exception.Message) }
    }
    Undo-MemoryCompression $St
    if ($St.ClassicMenu) {
        try { Remove-Item -LiteralPath 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force -ErrorAction Stop; Log OK 'Меню правой кнопки как в Windows 11 (после перезагрузки)' }
        catch { if (Test-Path -LiteralPath 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}') { Log ERR ('Меню правой кнопки: ' + $_.Exception.Message) } }
    }
    if ($St.Monitor) {
        try {
            $rr = Get-RefreshRate
            if ($rr -and $rr.Current -eq [int]$St.Monitor.New -and $rr.W -eq [int]$St.Monitor.W -and $rr.H -eq [int]$St.Monitor.H) {
                if (Set-RefreshRate ([int]$St.Monitor.Old)) { Log OK ('Частота монитора как была: ' + $St.Monitor.Old + ' Гц') } else { Log ERR 'Частота монитора: Windows не приняла' }
            } else { Log SKIP 'Частоту монитора с тех пор меняли, оставляю как есть' }
        } catch { Log ERR ('Частота монитора: ' + $_.Exception.Message) }
    }
}

function Undo-Info($St) {
    Section 'Что откат не возвращает'
    $apps = @($St.RemovedApps | Where-Object { $_ })
    if ($apps.Count -gt 0) {
        Log INFO ('Удалённые приложения: ' + ($apps -join ', '))
        Log INFO 'Сами они не вернутся: нужные ставятся бесплатно из Microsoft Store (поиск по названию).'
    }
    if ($St.OneDriveRemoved) { Log INFO 'OneDrive удалялся: поставить заново можно с microsoft.com/onedrive, файлы в папке OneDrive на месте.' }
    $pr = @($St.Programs | Where-Object { $_ })
    if ($pr.Count -gt 0) {
        Log INFO ('Программы из меню остались: ' + ($pr -join ', ') + '. Удалить можно в Параметры > Приложения.')
        Log INFO ('Папка «' + (Split-Path -Leaf $ProgDir) + '» на рабочем столе оставлена, её можно удалить руками.')
    }
    Log INFO 'Временные файлы, которые BOOST почистил, не возвращаются (это мусор).'
}

function Main {
    if (-not (Test-Admin)) { Request-Admin; return 3 }
    Set-NoQuickEdit
    Show-Head 'ОТКАТ'
    $St = Read-Json $StateFile
    $Rg = Read-Json $RegFile
    if (-not $St -or $St.RolledBack) {
        Write-Host ''
        Write-Host '  Откатывать нечего: BOOST не запускали или откат уже сделан.' -ForegroundColor Yellow
        Wait-Key
        return 0
    }
    Write-Host ''
    Write-Host ('  Вернёт Windows как было до ' + $BR.Pack + ': каждое значение из бэкапа, службы, задачи,') -ForegroundColor White
    Write-Host '  питание, загрузчик, профиль видеокарты, игровой режим и самопроверку.' -ForegroundColor White
    Write-Host '  Программы из меню и удалённые приложения не возвращает, об этом будет в логе.' -ForegroundColor DarkGray
    if (-not (Ask 'Откатываем?' '' 'Откатить' 'Отмена' 1)) { return 2 }

    Enter-BoostLock
    $St = Read-Json $StateFile; $Rg = Read-Json $RegFile
    if (-not $St -or $St.RolledBack) { Write-Host '  Откат уже выполнен.'; return 0 }
    Section ('Откат · ' + (Get-Date -Format 'dd.MM.yyyy HH:mm'))
    # Игровой режим: открытое окно режима выключится само по флагу
    if (Test-Path -LiteralPath $GameFile) {
        try { [IO.File]::WriteAllText($GameFlag, 'off') } catch {}
        Start-Sleep -Seconds 3
    }
    foreach ($t in @($TaskGame, $TaskReset, $TaskAfter)) { try { Unregister-ScheduledTask -TaskName $t -Confirm:$false -ErrorAction Stop } catch {} }
    Remove-Item -LiteralPath (Join-Path $Desktop ($GameName + '.lnk')) -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $GameFile) {
        try { [void](Game-Off $St) }
        catch { Log ERR ('Возврат временного лимита загрузок не завершён: '+$_.Exception.Message) }
    }
    Remove-Item -LiteralPath $GameFlag -Force -ErrorAction SilentlyContinue
    Log OK 'Игровой режим, его ярлык и задачи, задача самопроверки убраны'

    if ($Rg -and $Rg.Items) { Undo-Registry $Rg } else { Log SKIP 'Значения реестра не менялись' }
    Undo-Tasks $St
    Undo-Power $St
    Undo-Bcd $St
    Undo-Nvidia $St
    Undo-RtssFrameLimit $St
    Undo-Misc $St
    Undo-Info $St

    Write-LogFile ''
    if ($Count.ERR -eq 0) {
        Set-StateProp $St 'RolledBack' $true
        Set-StateProp $St 'RolledBackAt' (Get-Date).ToString('o')
        Save-StateObj $St
        Remove-Item -LiteralPath (Join-Path $Desktop ($RollbackName + '.lnk')) -Force -ErrorAction SilentlyContinue
        Write-LogFile ('Откат готов, ошибок нет. Папка ' + $P3Root + ' с логом осталась.')
        Write-Host ''
        Write-Host '  Откат готов, ошибок нет.' -ForegroundColor Green
    } else {
        Write-LogFile ('Откат прошёл с ошибками: ' + $Count.ERR + '. Ярлык отката оставлен, можно запустить ещё раз.')
        Write-Host ''
        Write-Host ('  Откат прошёл, ошибок: ' + $Count.ERR + '. Ярлык отката оставлен, его можно запустить ещё раз.') -ForegroundColor Yellow
        Write-Host '  Если не поможет: точка восстановления BOOST (Панель управления > Восстановление).' -ForegroundColor DarkGray
    }
    Write-LogFile $BR.Title
    if (Ask 'Перезагрузить компьютер сейчас?' 'Нужно, чтобы всё вернулось.' 'Перезагрузить сейчас' 'Позже' 1) {
        [void](Invoke-Native 'shutdown.exe' @('/r', '/t', '10'))
        Write-Host ''
        Write-Host '   Перезагрузка через 10 секунд...' -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    } else { Wait-Key '  Не забудь перезагрузить компьютер. Нажми любую клавишу, чтобы закрыть окно...' }
    return 0
}

$code = 1
try { $code = Main | Select-Object -Last 1 }
catch {
    Write-Host ('  Ошибка: ' + $_.Exception.Message) -ForegroundColor Red
    Write-LogFile ('[ОШИБ] Откат прерван: ' + $_.Exception.Message)
    Wait-Key
}
Exit-BoostLock
[Environment]::Exit([int]$code)
'@

# ---------------------------------------------------------------------
#  Игровой режим: клик включает, второй клик выключает. Пока включён,
#  окно свёрнуто и следит за игрой; закрыл игру, режим выключился сам
# ---------------------------------------------------------------------
$GameBody = @'
# BOOST_GAME_OPTIONS_V1
# BOOST_GAME_OPTIONS_V2
$NotGames = '^(RiotClient|EpicGamesLauncher|EpicWebHelper|steam|steamwebhelper|steamservice|CrashReportClient|UnrealCEFSubProcess|vgtray|vgc|EasyAntiCheat|EasyAntiCheat_EOS|BEService|Battle\.net|Agent|UnityCrashHandler\d*)$'

function Get-GameProcs($St) {
    $names = @($St.GameProcs | Where-Object { $_ } | ForEach-Object { ([string]$_) -replace '\.exe$', '' })
    $roots = @($St.GameRoots | Where-Object { $_ } | ForEach-Object { ([string]$_).TrimEnd('\') + '\' })
    $hits = @()
    foreach ($p in @(Get-Process -ErrorAction SilentlyContinue)) {
        $n = $p.ProcessName
        if ($n -match $NotGames) { continue }
        if ($names -contains $n -or $n -like 'FiveM*') { $hits += $p; continue }
        if ($roots.Count -eq 0) { continue }
        $path = $null
        try { $path = $p.Path } catch {}
        if (-not $path) { continue }
        foreach ($r in $roots) { if ($path.StartsWith($r, [StringComparison]::OrdinalIgnoreCase)) { $hits += $p; break } }
    }
    return $hits
}

function Test-Islc {
    return (@(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like '*standby list cleaner*' -or $_.ProcessName -like 'ISLC*' }).Count -gt 0)
}

function Game-On($St) {
    # Состояние пишем ДО изменений: окно закроют крестиком, следующий клик всё вернёт
    $game=Get-GamePowerScheme $St
    $before = Get-ActiveScheme
    if ($game -and -not $before) { throw 'Не определена исходная схема питания; игровой режим не запущен' }
    $g = [ordered]@{ Sign = $BR.Sign; On = $true; At = (Get-Date).ToString('o'); OldScheme = $before; GameScheme=$game }
    Write-JsonAtomic $GameFile $g
    Start-GameDownloads $St $g
    if ($St.RtssFrameLimit -and [uint32]$St.RtssFrameLimit.New -gt 0 -and $St.FrameLimit.Backend -eq 'RTSS' -and -not (Get-Process -Name RTSS -ErrorAction SilentlyContinue)) {
        $exe=Join-Path ([string]$St.RtssFrameLimit.Directory) 'RTSS.exe'
        if (Test-Path -LiteralPath $exe) { Start-Process -FilePath $exe -WorkingDirectory ([string]$St.RtssFrameLimit.Directory) -WindowStyle Minimized -ErrorAction Stop }
    }
    $close = @($St.GameClose | Where-Object { $_ })
    if ($close.Count -gt 0) {
        $procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $close -contains $_.ProcessName })
        foreach ($p in $procs) { try { [void]$p.CloseMainWindow() } catch {} }
        if ($procs.Count -gt 0) { Start-Sleep -Seconds 3 }
        foreach ($p in $procs) { try { if ($St.GameForceClose -and -not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction Stop } } catch {} }
        $names = @($procs | ForEach-Object { $_.ProcessName } | Select-Object -Unique)
        if ($names.Count -gt 0) { Write-Host ('   Запрошено закрытие: ' + ($names -join ', ') + '; принудительное: ' + [bool]$St.GameForceClose) -ForegroundColor Green }
        else { Write-Host '   Из списка «что закрывать» ничего не запущено' -ForegroundColor DarkGray }
    }
    if ($game -and (Test-SchemeExists $game) -and (Test-OnAc)) {
        $r = Invoke-Native 'powercfg.exe' @('/setactive', $game)
        if ($r.Code -eq 0) {
            if (Test-OnAc) { Write-Host '   Игровая схема питания включена' -ForegroundColor Green }
            else {
                $back=Invoke-Native 'powercfg.exe' @('/setactive', [string]$g.OldScheme)
                if ($back.Code -ne 0 -or (Get-ActiveScheme) -ne [string]$g.OldScheme) {throw 'Не удалось вернуть питание после отключения сети'}
                Write-Host '   Питание возвращено: питание от батареи' -ForegroundColor Yellow
            }
        } else { Write-Host '   Игровая схема не включилась, играть это не мешает' -ForegroundColor DarkGray }
    }
    if (-not $St.GamePurge) { Write-Host '   Очистка standby-памяти выключена в параметрах режима' -ForegroundColor DarkGray }
    elseif ([double]$St.RamGB -gt 16) { Write-Host '   Память больше 16 ГБ: чистить её не нужно' -ForegroundColor DarkGray }
    elseif (Test-Islc) { Write-Host '   ISLC запущен: память чистит он, режим не дублирует' -ForegroundColor DarkGray }
    else { Write-Host '   Пока идёт игра, память чистится, когда её мало' -ForegroundColor Green }
}

function Watch-Game($St) {
    $purge = ($St.GamePurge -and [double]$St.RamGB -gt 0 -and [double]$St.RamGB -le 16)
    $last = (Get-Date).AddMinutes(-5)
    $seen = $false
    $gone = 0
    $purges = 0
    $tick = 0
    while ($true) {
        if (Test-Path -LiteralPath $GameFlag) { Remove-Item -LiteralPath $GameFlag -Force -ErrorAction SilentlyContinue; return 'вторым кликом по ярлыку' }
        if (-not (Test-Path -LiteralPath $GameFile)) { return 'снаружи' }
        try {
            if ([Console]::KeyAvailable) {
                $k = [Console]::ReadKey($true)
                if ([string]$k.KeyChar -eq '1') { return 'кнопкой в окне' }
            }
        } catch {}
        if ($tick % 5 -eq 0) {
            if ((Get-GamePowerScheme $St) -and (Get-ActiveScheme) -eq (Get-GamePowerScheme $St) -and -not (Test-OnAc)) {
                $saved = Read-Json $GameFile
                if ($saved.OldScheme -and (Test-SchemeExists ([string]$saved.OldScheme))) {
                    $r = Invoke-Native 'powercfg.exe' @('/setactive', ([string]$saved.OldScheme))
                    if ($r.Code -ne 0 -or (Get-ActiveScheme) -ne [string]$saved.OldScheme) { throw 'Не удалось вернуть питание после отключения сети' }
                }
            }
            $games = @(Get-GameProcs $St)
            if ($games.Count -gt 0) {
                if (-not $seen) {
                    $seen = $true
                    Write-Host ('   ' + (Get-Date -Format 'HH:mm') + '  Игра запущена: ' + $games[0].ProcessName) -ForegroundColor Green
                    Write-GameLog ('Игра: ' + $games[0].ProcessName)
                }
                $gone = 0
                if ($purge -and -not (Test-Islc)) {
                    $m = Get-MemState
                    if ($m -and $m.FreeMB -lt 1536 -and $m.StandbyMB -gt 1024 -and ((Get-Date) - $last).TotalSeconds -ge 60) {
                        $last = Get-Date
                        if (Clear-Standby) {
                            $purges++
                            Write-Host ('   ' + (Get-Date -Format 'HH:mm') + '  Память подчищена (' + $purges + '-й раз): было свободно ' + $m.FreeMB + ' МБ') -ForegroundColor Green
                        }
                    }
                }
            } elseif ($seen) {
                $gone++
                if ($gone -ge 6) { return 'сам: игру закрыли' }
            }
        }
        Start-Sleep -Seconds 1
        $tick++
    }
}

function Main {
    $St = Read-Json $StateFile
    # Вход в Windows: режим остался «включён» после перезагрузки, значит он выключен, схема обычная
    if ($env:P3_ARG -eq 'reset') {
        Enter-BoostLock
        if ($St -and (Test-Path -LiteralPath $GameFile)) { [void](Game-Off $St); Write-GameLog 'Вход в Windows: режим остался включённым, выключил, схема обычная' }
        Remove-Item -LiteralPath $GameFlag -Force -ErrorAction SilentlyContinue
        return 0
    }
    if (-not (Test-Admin)) { Request-Admin; return 3 }
    Set-NoQuickEdit
    if (-not $St -or $St.RolledBack) {
        Show-Head 'ИГРОВОЙ РЕЖИМ'
        Write-Host ''
        Write-Host '  BOOST откатан, игровой режим не работает.' -ForegroundColor Yellow
        Start-Sleep -Seconds 4
        return 0
    }
    # Одно окно за раз. Окно уже есть: этот клик выключает режим
    $mx = New-Object System.Threading.Mutex($false, ('Local\' + $BR.Tag + '_GAME'))
    $own = $false
    try { $own = $mx.WaitOne(0) } catch { $own = $true }
    if (-not $own) {
        Show-Head 'ИГРОВОЙ РЕЖИМ'
        try { [IO.File]::WriteAllText($GameFlag, 'off') } catch {}
        $t = 0
        while ((Test-Path -LiteralPath $GameFlag) -and $t -lt 10) { Start-Sleep -Seconds 1; $t++ }
        Write-Host ''
        if (-not (Test-Path -LiteralPath $GameFlag)) { Write-Host '  Игровой режим выключен.' -ForegroundColor Green }
        else {
            Remove-Item -LiteralPath $GameFlag -Force -ErrorAction SilentlyContinue
            Write-Host '  Окно игрового режима не ответило: разверни его на панели задач и нажми [1].' -ForegroundColor Yellow
        }
        Start-Sleep -Seconds 2
        return 0
    }
    Enter-BoostLock
    if (Test-Path -LiteralPath $GameFile) { [void](Game-Off $St); Write-GameLog 'Прошлое окно закрыли крестиком: вернул как было' }
    Show-Head 'ИГРОВОЙ РЕЖИМ'
    Write-Host ''
    Game-On $St
    Write-GameLog 'Включён'
    Write-Host ''
    Write-Host '  ==================================================================' -ForegroundColor Green
    Write-Host '     ИГРОВОЙ РЕЖИМ ВКЛЮЧЁН. Запускай игру.' -ForegroundColor Green
    Write-Host '  ==================================================================' -ForegroundColor Green
    Write-Host '  Окно свернётся и будет следить за игрой. Закроешь игру, режим выключится сам.' -ForegroundColor White
    Write-Host ('  Выключить раньше: ещё раз ярлык «' + $GameName + '» или [1] в этом окне.') -ForegroundColor White
    Write-Host '     [1] Выключить игровой режим' -ForegroundColor Cyan
    Clear-Keys
    Start-Sleep -Seconds 4
    try { [P3Con]::Minimize() } catch {}
    $how = Watch-Game $St
    [void](Game-Off $St)
    Write-GameLog ('Выключен ' + $how)
    Write-Host ''
    Write-Host '  Игровой режим выключен, всё как было.' -ForegroundColor Green
    Start-Sleep -Seconds 2
    try { $mx.ReleaseMutex() } catch {}
    return 0
}

$code = 1
try { $code = Main | Select-Object -Last 1 }
catch {
    Write-Host ('  Ошибка: ' + $_.Exception.Message) -ForegroundColor Red
    try { if ($script:BoostLock) { $s = Read-Json $StateFile; if ($s) { [void](Game-Off $s) } } } catch {}
    Write-GameLog ('Ошибка: ' + $_.Exception.Message)
    Start-Sleep -Seconds 5
}
Exit-BoostLock
[Environment]::Exit([int]$code)
'@

# ---------------------------------------------------------------------
#  Замер «после» и самопроверка: каждое изменение из бэкапа. Сама через
#  5 минут после входа (один раз) или вручную файлом из папки бэкапа
# ---------------------------------------------------------------------
$CheckBody = @'
# BOOST_REPORT_READONLY_V1
# BOOST_REPORT_ONCE_V1
$Chk = @{ Total = 0; Fixed = 0; Boot = 0; Kept = 0; Failed = @() }
$Auto = ($env:P3_ARG -eq 'after')

# ok: стоит как надо; fixed: слетело и вернул; boot: вернул, заработает после перезагрузки; kept: по выбору клиента не трогаю
function Add-Check([string]$Res, [string]$Why) {
    $Chk.Total++
    switch ($Res) {
        'fixed' { $Chk.Fixed++ }
        'boot'  { $Chk.Fixed++; $Chk.Boot++ }
        'kept'  { $Chk.Kept++ }
        'fail'  { $Chk.Failed += $Why }
    }
}

function Get-FailWhy($E, [string]$Err) {
    if ([string]$E.Path -match '\\Policies\\' -and $Err) { return 'политика организации' }
    if ([string]$E.Note -match 'MSI mode|сетев|Adrenalin|Radeon') { return 'драйвер не поддерживает' }
    if ($Err -match 'denied|отказано|запрещ') { return 'Windows защищает' }
    return 'вернула Windows'
}

function Write-Measure($St) {
    Section 'Замер «после» (через 5 минут после входа)'
    $m = Read-Json $MeasureFile
    $since = $null
    if ($St.Finished) { try { $since = [datetime]::Parse([string]$St.Finished) } catch {} }
    $now = Get-Snapshot $since
    if ($m -and $m.Before) {
        $b = $m.Before
        Log INFO ('Загрузка Windows: ' + (Format-Boot $b.BootMs) + ' > ' + (Format-Boot $now.BootMs))
        Log INFO ('Занято памяти в простое: ' + $b.RamUsedMB + ' > ' + $now.RamUsedMB + ' МБ')
        Log INFO ('Процессов в фоне: ' + $b.Procs + ' > ' + $now.Procs)
        Log INFO ('Работающих служб: ' + $b.Services + ' > ' + $now.Services)
    } else {
        Log INFO ('Загрузка Windows: ' + (Format-Boot $now.BootMs) + ', занято памяти ' + $now.RamUsedMB + ' МБ, процессов ' + $now.Procs + ', служб ' + $now.Services)
    }
}

function Check-Registry($Rg) {
    Section 'Значения реестра'
    $groups = [ordered]@{}
    $kept = [ordered]@{}
    foreach ($e in @($Rg.Items | Where-Object { $_ })) {
        if ($null -eq $e.NewKind) { continue }
        $note = [string]$e.Note
        if (-not $note) { $note = 'прочие значения' }
        if (-not $groups.Contains($note)) { $groups[$note] = @{ N = 0; Fixed = 0; Boot = $false; Bad = @() } }
        $g = $groups[$note]
        $g.N++
        if (Test-RegItem $e) { Add-Check 'ok'; continue }
        if (-not $e.Fix) { Add-Check 'kept'; $kept[$note] = $true; continue }
        $err = ''
        try { Set-RegItemNew $e } catch { $err = $_.Exception.Message }
        if (-not $err -and (Test-RegItem $e)) {
            $g.Fixed++
            if ($note -match 'после перезагрузки|MSI mode|HAGS|служба|автозагрузка') { $g.Boot = $true; Add-Check 'boot' } else { Add-Check 'fixed' }
            if ($note -eq 'служба' -and [string]$e.NewValue -eq '4' -and [string]$e.Path -match '\\Services\\([^\\]+)$') { try { Stop-Service -Name $Matches[1] -Force -ErrorAction Stop -WarningAction SilentlyContinue } catch {} }
        } else {
            $why = Get-FailWhy $e $err
            $g.Bad += ([string]$e.Name + ': ' + $why)
            Add-Check 'fail' ($note + ': ' + $why)
        }
    }
    foreach ($k in $groups.Keys) {
        $g = $groups[$k]
        if ($kept.Contains($k) -and $g.Fixed -eq 0 -and $g.Bad.Count -eq 0) { continue }
        if ($g.Bad.Count -gt 0) { Log ERR ($k + ': не принялось ' + $g.Bad.Count + ' из ' + $g.N + ' (' + (($g.Bad | Select-Object -Unique) -join '; ') + ')') }
        elseif ($g.Fixed -gt 0) {
            $t = $k + ': слетело ' + $g.Fixed + ' из ' + $g.N + ', восстановлено'
            if ($g.Boot) { $t += ', заработает после перезагрузки' }
            Log OK $t
        } else { Log OK ($k + ' (' + $g.N + ')') }
    }
    foreach ($k in $kept.Keys) {
        if ($k -match 'паузе') { Log INFO 'Пауза обновлений закончилась или снята, не возвращаю' }
        elseif ($k -match 'VBS') { continue }
        elseif ($k -match 'Spectre') { Log INFO 'Защита Spectre снова включена (Windows или ты сам), не возвращаю' }
        else { Log INFO ($k + ': сейчас стоит иначе, это пункт по твоему выбору, не возвращаю') }
    }
}

function Check-Tasks($St) {
    $list = @($St.Tasks | Where-Object { $_ })
    if ($list.Count -eq 0) { return }
    Section 'Задачи Windows'
    $fixed = 0
    $bad = 0
    foreach ($t in $list) {
        $p = ([string]$t).Split('|')
        $task = Get-ScheduledTask -TaskPath $p[0] -TaskName $p[1] -ErrorAction SilentlyContinue
        if (-not $task -or [string]$task.State -eq 'Disabled') { Add-Check 'ok'; continue }
        try { [void](Disable-ScheduledTask -TaskPath $p[0] -TaskName $p[1] -ErrorAction Stop); $fixed++; Add-Check 'fixed' }
        catch { $bad++; Add-Check 'fail' 'задачи планировщика: Windows защищает' }
    }
    if ($bad -gt 0) { Log ERR ('Задачи телеметрии: не выключилось ' + $bad + ' из ' + $list.Count + ' (Windows защищает)') }
    elseif ($fixed -gt 0) { Log OK ('Задачи телеметрии: Windows включила ' + $fixed + ', выключил снова') }
    else { Log OK ('Задачи телеметрии выключены (' + $list.Count + ')') }
}

function Check-Power($St) {
    Section 'Питание'
    $ours = [string]$St.NewScheme
    if (-not $ours) { return }
    if (-not (Test-SchemeExists $ours)) { Add-Check 'fail' 'схему питания BOOST удалили (запусти BOOST заново)'; Log ERR ('Схема питания ' + $BR.Tag + ' удалена'); return }
    $active = Get-ActiveScheme
    $game = [string]$St.GameScheme
    if ($active -eq $ours -or ($game -and $active -eq $game -and (Test-Path -LiteralPath $GameFile))) { Add-Check 'ok'; Log OK 'Схема питания BOOST включена' }
    else {
        $r = Invoke-Native 'powercfg.exe' @('/setactive', $ours)
        if ($r.Code -eq 0) { Add-Check 'fixed'; Log OK 'Схему питания переключили, вернул схему BOOST'; $active = $ours }
        else { Add-Check 'fail' 'схема питания не включается'; Log ERR ('Схема питания: ' + $r.Out) }
    }
    $fixed = 0
    $bad = 0
    $n = 0
    foreach ($ps in @($St.PowerSet | Where-Object { $_ })) {
        $p = ([string]$ps).Split('|')
        if ($p.Count -lt 4 -or -not (Test-SchemeExists $p[0])) { continue }
        $n++
        $v = Get-PowerAcAny $p[0] $p[1] $p[2]
        if ($null -ne $v -and [int64]$v -eq [int64]$p[3]) { Add-Check 'ok'; continue }
        [void](Invoke-Native 'powercfg.exe' @('/setacvalueindex', $p[0], $p[1], $p[2], $p[3]))
        $v = Get-PowerAcAny $p[0] $p[1] $p[2]
        if ($null -ne $v -and [int64]$v -eq [int64]$p[3]) { $fixed++; Add-Check 'fixed' } else { $bad++; Add-Check 'fail' 'параметр питания: устройство не поддерживает' }
    }
    if ($fixed -gt 0 -and $active) { [void](Invoke-Native 'powercfg.exe' @('/setactive', $active)) }
    if ($n -eq 0) { return }
    if ($bad -gt 0) { Log ERR ('Параметры схемы питания: не принялось ' + $bad + ' из ' + $n + ' (устройство не поддерживает)') }
    elseif ($fixed -gt 0) { Log OK ('Параметры схемы питания: слетело ' + $fixed + ' из ' + $n + ', восстановлено') }
    else { Log OK ('Параметры схемы питания на месте (' + $n + ')') }
    if ($St.HiberWasOn) {
        $hib = Get-RegValue 'HKLM\SYSTEM\CurrentControlSet\Control\Power' 'HibernateEnabled'
        if ($hib -and [int]$hib.Value -eq 1) {
            $r = Invoke-Native 'powercfg.exe' @('/hibernate', 'off')
            if ($r.Code -eq 0) { Add-Check 'fixed'; Log OK 'Гибернацию включили, выключил снова' } else { Add-Check 'fail' 'гибернация: вернула Windows'; Log ERR ('Гибернация: ' + $r.Out) }
        } else { Add-Check 'ok' }
    }
}

function Check-Boot($St) {
    $list = @()
    if ($St.Bcd) { $list = @($St.Bcd.PSObject.Properties | Where-Object { $_.Value.Fix }) }
    if ($list.Count -eq 0) { return }
    Section 'Загрузчик и таймер'
    $need = @()
    foreach ($p in $list) {
        $now = $null
        try { $now = Get-BcdValue $p.Name } catch { Add-Check 'fail' 'загрузчик не читается'; Log ERR ('Загрузчик: ' + $_.Exception.Message); return }
        if (Test-BcdEqual $now $p.Value.New) { Add-Check 'ok'; Log OK ($p.Name + ': как поставил BOOST') } else { $need += $p }
    }
    if ($need.Count -eq 0) { return }
    if (-not (Suspend-BitLockerOnce)) { foreach ($p in $need) { Add-Check 'fail' 'загрузчик: BitLocker не встал на паузу' }; return }
    foreach ($p in $need) {
        if (Set-BcdItem $p.Name $p.Value.New) { Add-Check 'boot'; Log OK ($p.Name + ': слетело, восстановлено, заработает после перезагрузки') }
        else { Add-Check 'fail' ($p.Name + ': вернула Windows'); Log ERR ($p.Name + ': bcdedit не принял') }
    }
}

function Check-Vbs($St, $Rg) {
    if (-not $St.VbsOff) { return }
    Section 'Изоляция ядра (VBS)'
    $v = Get-VbsState
    if (-not $v.Running -and -not $v.Hvci) { Add-Check 'ok'; Log OK 'VBS и целостность памяти выключены'; return }
    Add-Check 'kept'
    if ($v.Locked) { Log INFO ('VBS снова работает и закреплена в BIOS: батник её не трогает' + $BR.Plus); return }
    if ($Auto) { Log INFO 'VBS снова работает (включил ты ради FACEIT или Valorant, или вернула Windows). Не трогаю, выключить снова можно ручной самопроверкой'; return }
    Write-Host ''
    Write-Host '  VBS снова работает, хотя при настройке выбрали «выключить».' -ForegroundColor Yellow
    if ((Ask-Opt 'Что делаем с VBS?' 'Её могли включить ради FACEIT или Valorant, или её вернула Windows.' @('Выключить снова', 'Оставить') 2) -ne 1) { Log INFO 'VBS снова работает, оставлена по твоему выбору'; return }
    $bad = 0
    foreach ($e in @($Rg.Items | Where-Object { $_ -and ([string]$_.Note -match 'VBS') })) { try { Set-RegItemNew $e } catch { $bad++ } }
    if ($St.Bcd -and $St.Bcd.PSObject.Properties['hypervisorlaunchtype'] -and (Suspend-BitLockerOnce)) {
        if (-not (Set-BcdItem 'hypervisorlaunchtype' 'Off')) { $bad++ }
    }
    if ($bad -eq 0) { Log OK 'VBS выключится после перезагрузки (по твоему выбору)' } else { Log ERR 'VBS: не всё принялось, возможно, её держит BIOS' }
}

function Check-Memory($St) {
    if ($St.Mmc -ne 'on' -and $St.Mmc -ne 'off') { return }
    Section 'Сжатие памяти'
    try {
        $on = [bool](Get-MMAgent -ErrorAction Stop).MemoryCompression
        $want = ($St.Mmc -eq 'on')
        if ($on -eq $want) { Add-Check 'ok'; Log OK ('Сжатие памяти ' + @{ $true = 'вкл'; $false = 'выкл' }[$want]); return }
        if ($want) { Enable-MMAgent -MemoryCompression -ErrorAction Stop } else { Disable-MMAgent -MemoryCompression -ErrorAction Stop }
        Add-Check 'boot'
        Log OK 'Сжатие памяти слетело, восстановлено, заработает после перезагрузки'
    } catch { Add-Check 'fail' 'сжатие памяти: вернула Windows'; Log ERR ('Сжатие памяти: ' + $_.Exception.Message) }
}

function Check-Monitor($St) {
    if (-not $St.Monitor) { return }
    Section 'Монитор'
    try {
        $rr = Get-RefreshRate
        if (-not $rr) { return }
        $want = [int]$St.Monitor.New
        if ($rr.W -ne [int]$St.Monitor.W -or $rr.H -ne [int]$St.Monitor.H) { Add-Check 'kept'; Log INFO ('Разрешение с тех пор сменили (' + $rr.Res + '), частоту не трогаю: сейчас ' + $rr.Current + ' Гц'); return }
        if ($rr.Current -eq $want) { Add-Check 'ok'; Log OK ('Частота монитора ' + $want + ' Гц'); return }
        if ((Set-RefreshRate $want) -and (Get-RefreshRate).Current -eq $want) { Add-Check 'fixed'; Log OK ('Частота монитора слетела на ' + $rr.Current + ' Гц, вернул ' + $want + ' Гц') }
        else { Add-Check 'fail' 'частота монитора: кабель или драйвер не дают'; Log ERR ('Частота монитора: Windows не даёт поставить ' + $want + ' Гц') }
    } catch { Add-Check 'fail' 'частота монитора'; Log ERR ('Частота монитора: ' + $_.Exception.Message) }
}

function Check-Nvidia($St) {
    $lines = @($St.NvSet | Where-Object { $_ })
    if ($lines.Count -eq 0) { return }
    Section 'Профиль NVIDIA'
    $npi = Join-Path $NvDir 'nvidiaProfileInspector.exe'
    $nip = Join-Path $NvDir ($BR.Tag + ' BOOST.nip')
    if (-not (Test-Path -LiteralPath $npi) -or -not (Test-Path -LiteralPath $nip)) { Add-Check 'fail' 'профиль NVIDIA: файлы в папке бэкапа удалены'; Log ERR ('Нет Profile Inspector или профиля в ' + $NvDir); return }
    if (-not (Test-Path -LiteralPath $DrsDir)) { Add-Check 'fail' 'драйвер NVIDIA не установлен'; Log ERR 'Драйвер NVIDIA не найден'; return }
    $set = ConvertFrom-NvState $lines
    $res = Test-NvSet $npi $set
    if ($res.Checked -and $res.Bad.Count -eq 0) { Add-Check 'ok'; Log OK ('Профиль NVIDIA на месте (' + $set.Count + ' настроек)'); return }
    try {
        Import-NvNip $npi $nip
        $res2 = Test-NvSet $npi $set
        if ($res2.Checked -and $res2.Bad.Count -eq 0) { Add-Check 'fixed'; Log OK 'Профиль NVIDIA слетел (обычно после обновления драйвера), поставил заново и проверил' }
        elseif (-not $res2.Checked) { Add-Check 'fixed'; Log OK 'Профиль NVIDIA поставлен ещё раз (выгрузка для сверки не получилась)' }
        else { Add-Check 'fail' ('профиль NVIDIA: ' + ($res2.Bad -join ', ') + ': драйвер не поддерживает'); Log ERR ('Профиль NVIDIA: не встали ' + ($res2.Bad -join ', ')) }
    } catch { Add-Check 'fail' 'профиль NVIDIA'; Log ERR ('Профиль NVIDIA: ' + $_.Exception.Message) }
}

function Check-Apps($St) {
    $pk = @($St.RemovedPkgs | Where-Object { $_ })
    $ex = @($St.DefExcl | Where-Object { $_ })
    if ($pk.Count -eq 0 -and $ex.Count -eq 0 -and -not $St.DefenderSet -and -not $St.ClassicMenu) { return }
    Section 'Приложения, Defender, меню'
    $back = @()
    $bad = @()
    foreach ($n in $pk) {
        $allUsers = Test-RemovalAllUsers $St $n
        $have = @(Get-AppPackages $n $allUsers)
        if ($have.Count -eq 0) { Add-Check 'ok'; continue }
        $ok = $true
        foreach ($p in $have) {
            try {
                if ($allUsers) { Remove-AppxPackage -Package $p.PackageFullName -AllUsers -ErrorAction Stop }
                else { Remove-AppxPackage -Package $p.PackageFullName -ErrorAction Stop }
            } catch { $ok = $false }
        }
        $short = ($n -replace '^Microsoft\.', '').Trim('*')
        if ($ok) { $back += $short; Add-Check 'fixed' } else { $bad += $short; Add-Check 'fail' ('приложение ' + $short + ': Windows не даёт удалить') }
    }
    if ($pk.Count -gt 0) {
        if ($bad.Count -gt 0) { Log ERR ('Вернулись и не удаляются: ' + ($bad -join ', ')) }
        if ($back.Count -gt 0) { Log OK ('Windows вернула приложения, удалил снова: ' + ($back -join ', ')) }
        if ($bad.Count -eq 0 -and $back.Count -eq 0) { Log OK ('Удалённые приложения не вернулись (' + $pk.Count + ')') }
    }
    try {
        $mp = Get-MpPreference -ErrorAction Stop
        if ($St.DefenderSet) {
            if ([int]$mp.ScanAvgCPULoadFactor -eq 25) { Add-Check 'ok' }
            else {
                Set-MpPreference -ScanAvgCPULoadFactor 25 -EnableLowCpuPriority $true -ErrorAction Stop
                Add-Check 'fixed'
                Log OK 'Defender: нагрузку проверки сбросили, вернул 25%'
            }
        }
        $have = @($mp.ExclusionPath)
        $miss = @($ex | Where-Object { $have -notcontains $_ })
        foreach ($d in $ex) { if ($have -contains $d) { Add-Check 'ok' } }
        foreach ($d in $miss) {
            try { Add-MpPreference -ExclusionPath $d -ErrorAction Stop; Add-Check 'fixed' } catch { Add-Check 'fail' 'исключение Defender: другой антивирус или политика' }
        }
        if ($ex.Count -gt 0) {
            if ($miss.Count -gt 0) { Log OK ('Исключения Defender: пропало ' + $miss.Count + ', вернул') } else { Log OK ('Исключения Defender на месте (' + $ex.Count + ')') }
        }
    } catch { if ($St.DefenderSet -or $ex.Count -gt 0) { Log SKIP ('Defender сейчас выключен или недоступен: ' + $_.Exception.Message) } }
    if ($St.ClassicMenu) {
        $k = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
        if (Test-Path -LiteralPath $k) { Add-Check 'ok'; Log OK 'Старое меню правой кнопки на месте' }
        else {
            try { [void](New-Item -Path $k -Force); Set-ItemProperty -LiteralPath $k -Name '(default)' -Value ''; Add-Check 'boot'; Log OK 'Старое меню правой кнопки слетело, восстановлено, заработает после перезагрузки' }
            catch { Add-Check 'fail' 'меню правой кнопки'; Log ERR ('Меню правой кнопки: ' + $_.Exception.Message) }
        }
    }
}

function Check-Links {
    Section 'Ярлыки и игровой режим'
    $rb = Join-Path $Desktop ($RollbackName + '.lnk')
    if (Test-Path -LiteralPath $rb) { Add-Check 'ok' }
    else { try { New-RollbackLink; Add-Check 'fixed'; Log OK ('Ярлык «' + $RollbackName + '» пропал, вернул') } catch { Add-Check 'fail' 'ярлык отката'; Log ERR ('Ярлык отката: ' + $_.Exception.Message) } }
    if (-not (Test-Path -LiteralPath (Join-Path $P3Root ($GameName + '.bat')))) { return }
    $task = Get-ScheduledTask -TaskName $TaskGame -ErrorAction SilentlyContinue
    if ($task) { Add-Check 'ok' } else { Add-Check 'fail' 'задачу игрового режима удалили (запусти BOOST заново)'; Log ERR 'Задача игрового режима удалена' }
    $gl = Join-Path $Desktop ($GameName + '.lnk')
    if (Test-Path -LiteralPath $gl) { Add-Check 'ok' }
    elseif ($task) { try { New-GameLink; Add-Check 'fixed'; Log OK ('Ярлык «' + $GameName + '» пропал, вернул') } catch { Add-Check 'fail' 'ярлык игрового режима'; Log ERR ('Ярлык игрового режима: ' + $_.Exception.Message) } }
    if ($task -and (Test-Path -LiteralPath $gl)) { Log OK 'Ярлыки отката и игрового режима на месте, задача игрового режима тоже' }
}

# Проверка после входа только сообщает о расхождениях. Исправление — вручную по блокам.
function Check-RtssFrameLimit($St) {
    $saved=$St.RtssFrameLimit
    if (-not $saved) {Log SKIP 'Лимит RTSS этим паком не менялся';return}
    try {
        $current=Get-RtssFrameLimit ([string]$saved.Directory)
        if ($current -eq [uint32]$saved.New) {Add-Check 'ok' '';Log OK 'Лимит RTSS соответствует сохранённому';return}
        if ($Auto) {Add-Check 'kept' '';Log INFO 'Лимит RTSS отличается; автоматический отчёт его не меняет';return}
        Set-RtssFrameLimit ([string]$saved.Directory) ([uint32]$saved.New)
        Add-Check 'fixed' '';Log OK 'Выбранный лимит RTSS записан и проверен; RTSS должен быть запущен для действия лимита'
    } catch {Add-Check 'fail' $_.Exception.Message;Log ERR ('Лимит RTSS не проверен: '+$_.Exception.Message)}
}

function Show-DriftReport($St, $Rg) {
    $different = 0
    if ($St.RtssFrameLimit) {
        try { if ((Get-RtssFrameLimit ([string]$St.RtssFrameLimit.Directory)) -ne [uint32]$St.RtssFrameLimit.New) { $different++;Log INFO 'Отличается общий лимит RTSS; автоматически не менялся' } }
        catch { Log INFO ('RTSS недоступен: '+$_.Exception.Message) }
    }
    foreach ($e in @($Rg.Items)) {
        if ($null -eq $e -or $null -eq $e.NewKind) { continue }
        try {
            if (-not (Test-RegItem $e)) {
                $different++
                Log INFO ('Отличается: ' + $e.Note + ' — ' + $e.Path + '\' + $e.Name + '; цель: ' + (Format-RegData $e.NewKind $e.NewValue))
            }
        } catch { Log INFO ('Не прочитано: ' + $e.Path + '\' + $e.Name + ': ' + $_.Exception.Message) }
    }
    foreach ($t in @($St.Tasks | Where-Object { $_ })) {
        $parts = ([string]$t).Split('|')
        $task = Get-ScheduledTask -TaskPath $parts[0] -TaskName $parts[1] -ErrorAction SilentlyContinue
        if (-not $task -or [string]$task.State -ne 'Disabled') { $different++; Log INFO ('Отличается или недоступна задача: ' + $t) }
    }
    if ($St.NewScheme -and (Get-ActiveScheme) -ne [string]$St.NewScheme) { $different++; Log INFO 'Активная схема отличается от схемы BOOST; она могла быть изменена вручную.' }
    if ($St.Monitor) {
        $rr = Get-RefreshRate
        if (-not $rr -or $rr.Current -ne [int]$St.Monitor.New) { $different++; Log INFO 'Частота основного монитора отличается или недоступна.' }
    }
    if ($St.Bcd) {
        foreach ($prop in $St.Bcd.PSObject.Properties) {
            if (-not (Test-BcdEqual (Get-BcdValue $prop.Name) $prop.Value.New)) { $different++; Log INFO ('Отличается загрузчик: ' + $prop.Name) }
        }
    }
    if ($St.Mmc) {
        try {
            $mm = Get-MMAgent -ErrorAction Stop
            if ([bool]$mm.MemoryCompression -ne ($St.Mmc -eq 'on')) { $different++; Log INFO 'Сжатие памяти отличается.' }
        } catch { Log INFO ('Сжатие памяти не прочитано: ' + $_.Exception.Message) }
    }
    foreach ($n in @($St.RemovedPkgs | Where-Object { $_ })) {
        try {
            if (@(Get-AppPackages $n (Test-RemovalAllUsers $St $n)).Count -gt 0) { $different++; Log INFO ('Снова установлено приложение: ' + $n + '. Оставлено без изменений.') }
        } catch { Log INFO ('Не удалось проверить приложение ' + $n + ': ' + $_.Exception.Message) }
    }
    if ($St.DefenderSet -or @($St.DefExcl).Count -gt 0) {
        try {
            $mp = Get-MpPreference -ErrorAction Stop
            if ($St.DefenderSet -and [int]$mp.ScanAvgCPULoadFactor -ne 25) { $different++; Log INFO 'Отличается целевая средняя нагрузка Defender.' }
            foreach ($d in @($St.DefExcl)) { if (@($mp.ExclusionPath) -notcontains $d) { $different++; Log INFO ('Нет исключения Defender: ' + $d + '. Не добавлялось.') } }
        } catch { Log INFO ('Defender не прочитан: ' + $_.Exception.Message) }
    }
    if ($St.NvDrs -and @($St.NvSet).Count -gt 0) { Log INFO 'Реестр проверен; профиль NVIDIA проверяется отдельно при выборе блока NVIDIA. Проверка профиля использует временную выгрузку Inspector.' }
    Log INFO ('Отчёт: найдено расхождений ' + $different + '. Настройки не изменялись. Это не замер FPS.')
}

function Start-AutoReport {
    Enter-BoostLock
    try {
        $st = Read-Json $StateFile
        if (-not $st -or $st.RolledBack -or ($st.PSObject.Properties['AfterReportEnabled'] -and -not $st.AfterReportEnabled)) {
            try { Remove-AfterReportTask } catch {}
            return $null
        }
        Set-StateProp $st 'AfterReportEnabled' $false
        Set-StateProp $st 'AfterReportStartedAt' (Get-Date).ToString('o')
        Save-StateObj $st
        try { Remove-AfterReportTask }
        catch { Log INFO ('Задачу отчёта удалить не удалось; повторный запуск отчёта уже запрещён сохранённым состоянием: ' + $_.Exception.Message) }
        return $st
    } finally { Exit-BoostLock }
}


function Main {
    if (-not (Test-Admin)) { Request-Admin; return 3 }
    Set-NoQuickEdit
    Show-Head 'САМОПРОВЕРКА'
    if ($Auto) { $St = Start-AutoReport } else { $St = Read-Json $StateFile }
    if (-not $St -and $Auto) { return 0 }
    $Rg = Read-Json $RegFile
    if (-not $St -or $St.RolledBack) { Write-Host '  Проверять нечего.'; if (-not $Auto) { Wait-Key }; return 0 }
    if ($Auto) { Write-Measure $St }
    Show-DriftReport $St $Rg
    if ($Auto) { Wait-Close 120; return 0 }
    $names = @('Реестр и службы', 'Задачи Windows', 'Питание', 'Загрузчик и таймер', 'VBS', 'Сжатие памяти', 'Монитор', 'NVIDIA', 'Приложения, Defender и меню (область из истории)', 'Ярлыки', 'Лимит FPS в RTSS')
    $n = 0
    $items = @($names | ForEach-Object { $n++; [pscustomobject]@{ N = $n; Text = $_; Pre = $false } })
    $pick = @(Ask-Multi 'Какие блоки проверить с повторным применением?' 'Ничего не выбрано. Повторное применение может заменить твои последующие настройки. Блок приложений повторяет сохранённую область удаления; старые установки 3.0 используют всех пользователей.' $items)
    if ($pick.Count -eq 0) { return 0 }
    if ($pick -contains 9) {
        Write-Host '  Для повторного удаления приложений введи УДАЛИТЬ. Другой ответ отменит исправление.'
        if ((Read-Line) -cne 'УДАЛИТЬ') { return 2 }
    }
    if (-not (Ask 'Повторно применить выбранные блоки?' 'Остальные останутся без изменений.' 'Применить' 'Отмена' 2)) { return 2 }
    Enter-BoostLock
    try {
        $St = Read-Json $StateFile; $Rg = Read-Json $RegFile
        if (-not $St -or $St.RolledBack) { throw 'Состояние BOOST изменилось. Запусти проверку снова.' }
        if ($pick -contains 1) { Check-Registry $Rg }
        if ($pick -contains 2) { Check-Tasks $St }
        if ($pick -contains 3) { Check-Power $St }
        if ($pick -contains 4) { Check-Boot $St }
        if ($pick -contains 5) { Check-Vbs $St $Rg }
        if ($pick -contains 6) { Check-Memory $St }
        if ($pick -contains 7) { Check-Monitor $St }
        if ($pick -contains 8) { Check-Nvidia $St }
        if ($pick -contains 9) { Check-Apps $St }
        if ($pick -contains 10) { Check-Links }
        if ($pick -contains 11) { Check-RtssFrameLimit $St }
        Set-StateProp $St 'Checked' (Get-Date).ToString('o'); Save-StateObj $St
    } finally { Exit-BoostLock }
    Write-Host ('  Повторно применено: ' + $Chk.Fixed + '; ошибок: ' + $Chk.Failed.Count)
    Wait-Key
    return 0
}

$code = 1
try { $code = Main | Select-Object -Last 1 }
catch {
    Write-Host ('  Ошибка: ' + $_.Exception.Message) -ForegroundColor Red
    Write-LogFile ('[ОШИБ] Самопроверка прервана: ' + $_.Exception.Message)
    Wait-Key
}
[Environment]::Exit([int]$code)
'@

# ---------------------------------------------------------------------
#  Установка: скрипты в папку бэкапа, иконки, ярлыки, задачи
# ---------------------------------------------------------------------
$IconRaven = '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'
$IconGame  = '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'

function Q([string]$S) { return ("'" + $S.Replace("'", "''") + "'") }

# Блок подписи из начала этого же файла: он же идёт в начало каждого скрипта в папке бэкапа
function Get-SignBlock {
    $t = [IO.File]::ReadAllText($env:P3_SELF, [Text.Encoding]::UTF8)
    $m = [regex]::Match($t, '(?ms)^:: =+.*?^:: =+[^\r\n]*')
    if ($m.Success) { return @($m.Value -split "\r?\n") }
    return @()
}

function Get-NestedText([string]$Kind, [string]$Body, [bool]$WithNv) {
    $L = New-Object System.Collections.Generic.List[string]
    foreach ($x in @('<# :', '@echo off', 'chcp 65001 >nul', 'set "P3_SELF=%~f0"', 'set "P3_ARG=%~1"', 'powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false); [Console]::InputEncoding = [Console]::OutputEncoding; $OutputEncoding = [Console]::OutputEncoding; iex ([IO.File]::ReadAllText($env:P3_SELF,[Text.Encoding]::UTF8)) } catch { $r=$_; $d=[IO.Path]::Combine([IO.Path]::GetTempPath(),''PLAYSIN-BOOST-error.txt''); $m=$r.ToString()+[Environment]::NewLine+$r.InvocationInfo.PositionMessage+[Environment]::NewLine+$r.ScriptStackTrace; try { [IO.File]::WriteAllText($d,$m,[Text.Encoding]::UTF8) } catch {}; Write-Host $m -ForegroundColor Red; Write-Host (''Error details: ''+$d); exit 1 }"', 'set "P3_EXIT=%errorlevel%"', 'if "%P3_EXIT%"=="1" pause', 'exit /b %P3_EXIT%')) { $L.Add($x) }
    foreach ($x in @(Get-SignBlock)) { $L.Add($x) }
    $L.Add('#>')
    $L.Add('# ' + $BR.Sign.TrimStart(';', ' ') + ' · ' + $Kind)
    $L.Add('$ErrorActionPreference = ''Stop''')
    $L.Add('$ProgressPreference = ''SilentlyContinue''')
    $L.Add('try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}')
    $kv = @()
    foreach ($k in @('Tag', 'Short', 'Pack', 'Title', 'Sign', 'Shop', 'Seller', 'Social', 'Plus')) { $kv += ($k + ' = ' + (Q ([string]$BR[$k]))) }
    $L.Add('$BR = @{ ' + ($kv -join '; ') + '; Client = $' + ([string][bool]$BR.Client).ToLower() + ' }')
    foreach ($n in @('P3Version', 'P3Root', 'Desktop', 'LogName', 'LogPath', 'LogCopy', 'RegFile', 'StateFile', 'MeasureFile', 'DrsBackup', 'NvDir', 'DrsDir', 'RollbackName', 'GameName', 'CheckName', 'ProgDir', 'TaskAfter', 'TaskGame', 'TaskReset', 'GuidRx')) {
        $L.Add('$' + $n + ' = ' + (Q ([string](Get-Variable -Name $n -ValueOnly))))
    }
    $L.Add($CommonCode)
    if ($WithNv) { $L.Add($NvCode) }
    $L.Add($NestedCode)
    $L.Add($Body)
    return (($L -join "`r`n") -replace "(?<!`r)`n", "`r`n")
}

function Write-Readme {
    $t = @(('Здесь хранится бэкап ' + ($BR.Title -replace ' · ', ' ') + '.'), 'Не удаляй эту папку: без неё откат не сработает.', ('Откатить всё: ярлык «' + $RollbackName + '» на рабочем столе.'))
    $t += $BR.Seller # @client
    $t += $BR.Social # @client
    [IO.File]::WriteAllText((Join-Path $P3Root 'ПРОЧИТАЙ.txt'), (($t + '') -join "`r`n"), $Utf8Bom)
}

# Откат, игровой режим и самопроверка в папку бэкапа, ярлык отката: до первой правки
function Install-Nested {
    Section 'Откат и самопроверка'
    [void](New-Item -ItemType Directory -Path $P3Root -Force)
    try {
        [IO.File]::WriteAllBytes((Join-Path $P3Root 'raven.ico'), [Convert]::FromBase64String($IconRaven))
        [IO.File]::WriteAllBytes((Join-Path $P3Root 'game.ico'), [Convert]::FromBase64String($IconGame))
    } catch { Log INFO ('Иконки ярлыков не записались, будут стандартные: ' + $_.Exception.Message) }
    $ok = $true
    $files = @(
        @(($RollbackName + '.bat'), 'откат', $RollbackBody, $false),
        @(($GameName + '.bat'), 'игровой режим', $GameBody, $false),
        @(($CheckName + '.bat'), 'самопроверка', $CheckBody, $true)
    )
    foreach ($f in $files) {
        try {
            $text = Get-NestedText $f[1] $f[2] $f[3]
            $tokens = $null; $errors = $null
            [void][Management.Automation.Language.Parser]::ParseInput($text, [ref]$tokens, [ref]$errors)
            if ($errors.Count -gt 0) { throw 'Скрипт содержит синтаксическую ошибку' }
            $path = Join-Path $P3Root $f[0]
            [IO.File]::WriteAllText($path, $text, $Utf8NoBom)
            if ([IO.File]::ReadAllText($path, [Text.Encoding]::UTF8) -cne $text) { throw 'Проверка записанного скрипта не пройдена' }
        }
        catch { $ok = $false; Log ERR ($f[0] + ': ' + $_.Exception.Message) }
    }
    try { Write-Readme } catch {}
    try { New-RollbackLink; Log OK ('Откат готов заранее: ярлык «' + $RollbackName + '» на рабочем столе, скрипты в ' + $P3Root) }
    catch { Log INFO ('Ярлык отката: ' + $_.Exception.Message + '. Откат можно запустить файлом в ' + $P3Root) }
    return $ok
}

function Register-P3Task([string]$Name, [string]$Exe, [string]$Arg, [bool]$AtLogon, [int]$DelayMin, [string]$Desc) {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $act = New-ScheduledTaskAction -Execute $Exe -Argument $Arg -WorkingDirectory $P3Root
    $pr = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest
    $set = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances Parallel
    $p = @{ TaskName = $Name; Action = $act; Principal = $pr; Settings = $set; Description = $Desc; Force = $true }
    if ($AtLogon) {
        $tr = New-ScheduledTaskTrigger -AtLogOn -User $user
        if ($DelayMin -gt 0) { $tr.Delay = ('PT' + $DelayMin + 'M') }
        $p.Trigger = $tr
    }
    [void](Register-ScheduledTask @p -ErrorAction Stop)
}

# Игровой режим (ярлык и задача) и задача замера «после» с самопроверкой
function Register-GameRecoveryTask($St) {
    if (-not $St.GameScheme -and [int]$St.GameDownloadPercent -le 0) { return }
    $game=Join-Path $P3Root ($GameName+'.bat')
    $ps=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $cmd='$env:P3_SELF='+ (Q $game) + ';$env:P3_ARG=''reset'';& ([scriptblock]::Create([IO.File]::ReadAllText($env:P3_SELF,[Text.Encoding]::UTF8)))'
    $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
    Register-P3Task $TaskReset $ps ('-NoProfile -WindowStyle Hidden -EncodedCommand '+$encoded) $true 0 ($BR.Pack+': возврат временных параметров игрового режима после входа')
}

function Install-Tasks {
    Section 'Ярлыки и задачи'
    $game = Join-Path $P3Root ($GameName + '.bat')
    $check = Join-Path $P3Root ($CheckName + '.bat')
    try {
        Register-P3Task $TaskGame $env:ComSpec ('/c ""' + $game + '""') $false 0 ($BR.Pack + ': игровой режим, ярлык на рабочем столе')
        New-GameLink
        Log OK ('Ярлык «' + $GameName + '»: клик включает, второй клик выключает, без окна UAC')
    } catch { Log ERR ('Игровой режим: ' + $_.Exception.Message) }
    try {
        Register-GameRecoveryTask $State
        if ($State.GameScheme -or [int]$State.GameDownloadPercent -gt 0) { Log OK 'Подготовлен возврат временных параметров игрового режима после входа' }
    } catch { Log ERR ('Сброс игрового режима при входе: '+$_.Exception.Message) }
    try {
        Set-AfterReportTask ([bool]$State.AfterReportEnabled)
        if ($State.AfterReportEnabled) { Log OK 'Автоотчёт включён: один раз через 5 минут после следующего входа, без исправлений' }
        else { Log OK 'Автоотчёт выключен; ранее созданная задача удалена. Ручная самопроверка сохранена' }
    } catch { Log ERR ('Настройка автоотчёта: ' + $_.Exception.Message) }
}

# ---------------------------------------------------------------------
#  Итог: было/стало, что сделать руками, подсказки, последнее окно
# ---------------------------------------------------------------------
function Show-BeforeAfter($Before, $After) {
    Section 'Было / стало'
    $head = '   ' + 'Параметр'.PadRight(28) + 'Было'.PadRight(29) + 'Стало'
    Write-Host $head -ForegroundColor White
    Write-LogFile $head
    foreach ($k in $After.Keys) {
        $b = '?'
        if ($Before -and $Before.Contains($k)) { $b = [string]$Before[$k] }
        $a = [string]$After[$k]
        $line = '   ' + (Get-Cell $k).PadRight(28) + (Get-Cell $b).PadRight(29) + (Get-Cell $a)
        $color = 'Gray'
        if ($a -ne $b) { $color = 'Green' }
        Write-Host $line -ForegroundColor $color
        Write-LogFile $line
    }
    Write-Host '   Часть пунктов заработает после перезагрузки. Ручная самопроверка доступна в меню.' -ForegroundColor DarkGray
}

function Get-ManualNotes($Sys, [string]$NvRes, $Done) {
    $n = @()
    if ($State.FrameLimit -and -not $State.FrameLimitApplied) { $n+=('Лимит FPS '+$State.FrameLimit.Value+' автоматически не применён. Выставь его в игре или панели драйвера; 0 отключает только соответствующий ограничитель.') }
    if ($NvRes -eq 'nodriver') { $n += 'Поставь драйвер NVIDIA (приложение NVIDIA или nvidia.com) и запусти BOOST ещё раз: профиль NVIDIA пропущен.' }
    if ($Sys.IsAmdGpu) { $n += 'Radeon: в Adrenalin включи FreeSync, если монитор его умеет, и выключи Мгновенный повтор, если не пишешь клипы.' }
    if (@($Done) -contains 'Process Lasso') {
        if ($BR.Client) { $n += 'Process Lasso поставлен и выключен до настройки с продавцом, автозапуск включается после настройки.' }
        else { $n += 'Process Lasso поставлен и выключен: автозапуск включить после настройки.' }
    }
    if (@($Done).Count -gt 0) {
        if ($BR.Client) { $n += ('Программы из меню (' + (@($Done) -join ', ') + ') настраивает продавец вместе с тобой. Установщики в папке «' + (Split-Path -Leaf $ProgDir) + '» на рабочем столе.') }
        else { $n += ('Программы из меню (' + (@($Done) -join ', ') + ') поставлены без настройки. Установщики в папке «' + (Split-Path -Leaf $ProgDir) + '» на рабочем столе.') }
    }
    return $n
}

function Show-List([string]$Title, $Items, [string]$Color) {
    $Items = @($Items | Where-Object { $_ })
    if ($Items.Count -eq 0) { return }
    Section $Title
    foreach ($i in $Items) {
        Write-Host ('   · ' + $i) -ForegroundColor $Color
        Write-LogFile ('  · ' + $i)
    }
}

function Show-Final {
    Write-Host ''
    if ($State.RunStatus -eq 'Completed') { Write-Host '  Настройка завершена. Перезагрузи ПК, когда будет удобно.' -ForegroundColor Green }
    else { Write-Host '  Настройка выполнена не полностью. Подробности — в логе; доступен откат.' -ForegroundColor Yellow }
    if ($State.AfterReportEnabled) { Write-Host '  После следующего входа будет один отчёт, затем автоотчёт выключится.' }
    else { Write-Host '  Автоотчёт выключен. Самопроверку можно запустить вручную из меню.' }
    Write-Host ('  Откат: ярлык «' + $RollbackName + '» или пункт в основном BAT.')
    Write-Host ('  Лог: ' + $LogPath)
    Wait-Key
}

# PLAYSIN BOOST 3.0 · playsin333
# ---------------------------------------------------------------------
#  Главный порядок работы
# ---------------------------------------------------------------------
function Invoke-Step([string]$Name, [scriptblock]$Do) {
    try { & $Do } catch { Log ERR ($Name + ': ' + $_.Exception.Message + ' (остальное идёт дальше)') }
}

function Ask-Profile($Sys, [string]$Auto) {
    $prof = $Auto
    $manual = $false
    while ($true) {
        $fl = Get-Flags $Sys $prof $manual
        Show-Profile $Sys $prof $fl
        if ((Ask-Opt 'Всё верно?' '' @('Всё верно', 'Сменить профиль') 1) -eq 1) { return @{ Prof = $prof; Flags = $fl; Manual = $manual } }
        $n = Ask-Opt 'Какой профиль?' '' @('Включить адаптацию CPU/RAM/GPU', 'Без адаптации CPU/RAM/GPU', 'Ноутбук') (@{ Weak = 1; Strong = 2; Laptop = 3 }[$Auto])
        $pick = @('Weak', 'Strong', 'Laptop')[$n - 1]
        if ($Sys.IsLaptop -and $pick -ne 'Laptop') {
            Write-Host ''
            Write-Host '  Это ноутбук. Профиль ПК даст ему питание как у настольного: больше шум, нагрев и троттлинг.' -ForegroundColor Yellow
            if ((Ask-Opt 'Какой профиль оставляем?' '' @('Вернуть «Ноутбук»', 'Всё равно профиль ПК') 1) -eq 1) { $pick = 'Laptop' }
        }
        $prof = $pick
        $manual = ($pick -ne $Auto)
    }
}

function Ask-Mode {
    $h = "Рекомендовано: спрошу только то, что угадать нельзя, остальное как лучше для этого ПК.`nМаксимум: всё, что ускоряет, вместе с рискованным (перед стартом покажу, что именно).`nРучной: спрошу про каждый пункт."
    $n = Ask-Opt 'Как настраиваем?' $h @('Рекомендовано', 'Максимум', 'Ручной') 1
    return @('Rec', 'Max', 'Manual')[$n - 1]
}

function Write-HardwareLog($Sys, [string]$Prof, $Pp, $Lines) {
    Section 'Железо и профиль'
    $dev = 'ПК'
    if ($Sys.IsLaptop) { $dev = 'ноутбук' }
    Write-LogFile ('Устройство: ' + $dev + ' · Windows: ' + $Sys.Name)
    Write-LogFile ('Процессор: ' + $Sys.Cpu)
    $g = $Sys.Gpu
    if ($Sys.Main -and $Sys.Main.VramGB -gt 0) { $g = $g + ' (' + $Sys.Main.VramGB + ' ГБ)' }
    Write-LogFile ('Видеокарта: ' + $g)
    $ram = [string]$Sys.RamGB + ' ГБ'
    if ($Sys.RamMHz -gt 0) { $ram = $ram + ' · ' + (($Sys.RamType + ' ' + $Sys.RamMHz + ' МГц').Trim()) }
    Write-LogFile ('Память: ' + $ram)
    Write-LogFile ('Диск C: ' + $Sys.DiskNote)
    if ($Sys.Refresh) { Write-LogFile ('Монитор: ' + $Sys.Refresh.Current + ' Гц (умеет ' + $Sys.Refresh.Max + ' Гц)') }
    $yn = @{ $true = 'да'; $false = 'нет' }
    $how = ''
    if ($Pp.Manual) { $how = ' (выбран вручную)' }
    Write-LogFile ('Профиль: ' + $ProfileTitle[$Prof] + $how + ' · пункты для слабой видеокарты: ' + $yn[[bool]$Pp.Flags.Video] + ' · для слабого процессора и памяти: ' + $yn[[bool]$Pp.Flags.System])
    Section 'Ответы'
    foreach ($l in $Lines) { Write-LogFile ('  ' + $l) }
}

# Замер «до»: первый замер не перезаписывается при повторном запуске
function Write-MeasureBefore($Sys) {
    Section 'Замер «до»'
    $snap = Get-Snapshot $null
    $lag = Get-LagState $Sys
    if (-not (Test-Path -LiteralPath $MeasureFile)) {
        $m = [ordered]@{ Sign = $BR.Sign; At = (Get-Date).ToString('o'); Before = $snap; Lag = $lag }
        [IO.File]::WriteAllText($MeasureFile, (ConvertTo-Json -InputObject $m -Depth 5), $Utf8NoBom)
    }
    Log INFO ('Процессов в фоне: ' + $snap.Procs + ' · работающих служб: ' + $snap.Services + ' · занято памяти: ' + $snap.RamUsedMB + ' МБ')
    Log INFO ('Программ в автозагрузке: ' + $lag['Автозагрузка, шт.'] + ' · схема питания: ' + $lag['Схема питания'])
    $tm = 'по умолчанию'
    try {
        $parts = @()
        if (Get-BcdValue 'useplatformclock') { $parts += 'HPET принудительно' }
        if (Get-BcdValue 'disabledynamictick') { $parts += 'dynamic tick выкл' }
        if ($parts.Count -gt 0) { $tm = ($parts -join ', ') }
    } catch { $tm = '?' }
    Log INFO ('Таймер: ' + $tm + ' · загрузка Windows: ' + (Format-Boot $snap.BootMs))
    return $lag
}

# Windows даёт одну точку в сутки: на время снимаем ограничение и сразу возвращаем как было
function New-P3RestorePoint {
    Section 'Точка восстановления'
    $key = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
    $old = Get-RegValue $key 'SystemRestorePointCreationFrequency'
    $desc = $BR.Pack + ' ' + (Get-Date -Format 'dd.MM.yyyy HH:mm')
    $made = $false
    $why = ''
    try {
        try { Enable-ComputerRestore -Drive ($env:SystemDrive + '\') -ErrorAction Stop } catch {}
        Set-RawReg $key 'SystemRestorePointCreationFrequency' 'DWord' 0
        Write-Host '   Создаю точку восстановления, это может занять минуту...' -ForegroundColor DarkGray
        Checkpoint-Computer -Description $desc -RestorePointType MODIFY_SETTINGS -ErrorAction Stop -WarningAction SilentlyContinue
        $made = (@(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Where-Object { $_.Description -eq $desc }).Count -gt 0)
    } catch { $why = $_.Exception.Message }
    finally {
        try {
            if ($old) { Set-RawReg $key 'SystemRestorePointCreationFrequency' $old.Kind $old.Value }
            else { Remove-RawReg $key 'SystemRestorePointCreationFrequency' }
        } catch {}
    }
    if ($made) { Log OK ('Точка восстановления «' + $desc + '» создана и найдена в списке'); return $true }
    if (-not $why) { $why = 'в списке точек её нет (защита системы выключена или мало места)' }
    Log INFO ('Точка восстановления не появилась: ' + $why)
    $c = Ask-Opt 'Продолжаем без точки восстановления?' 'Бэкап каждого значения и откат ярлыком работают и без неё.' @('Продолжить', 'Остановиться') 2
    return ($c -eq 1)
}

function Invoke-Setup([string]$Mode, [string]$Preset) {
    Set-ConsoleLook
    if (-not (Test-Admin)) { Request-Admin; return 3 }
    if (-not (Test-SameUser)) { return (Stop-Nothing 'Запусти BOOST из своей учётной записи Windows.') }
    if (-not (Test-Unpacked)) { return (Stop-Nothing 'Сначала распакуй всю папку из архива.') }
    Write-Host ''
    Write-Host '  Смотрю железо, это пара секунд...' -ForegroundColor DarkGray
    $Sys = Get-SystemInfo
    if ($Sys.IsNvidia -and -not (Test-Path -LiteralPath (Join-Path $NpiSrc 'nvidiaProfileInspector.exe'))) {
        return (Stop-Nothing 'Рядом с батником нет папки nvidia. Распакуй архив целиком, чтобы папка nvidia лежала рядом, и запусти снова.')
    }
    $Pp = Ask-Profile $Sys (Get-AutoProfile $Sys)
    $Prof = $Pp.Prof
    $Fl = $Pp.Flags
    $Ctx = Get-Context $Sys $Prof
    while ($true) {
        $script:BoostCatalog = @(Get-BoostPlan $Sys $Preset)
        $plan = @($script:BoostCatalog | Where-Object { $_.Pre })
        if ($Mode -eq 'Manual') { $plan = @(Select-BoostPlan $plan $true) }
        elseif (Ask 'Изменить предложенный набор блоков?' 'Можно оставить автоматический выбор.' 'Изменить' 'Оставить' 2) { $plan = @(Select-BoostPlan $plan $false) }
        if ($plan.Count -eq 0) { return (Stop-Nothing 'Ни один блок не выбран.') }
        $A = Get-Answers $Sys $Prof $Fl $Ctx $Mode @($plan.Id)
        if ($A.FrameLimit) { $plan=@($plan | Where-Object { $_.Id -ne 'frame-limit' })+@([pscustomobject]@{Id='frame-limit';Title='Выбранный лимит FPS';About=(Get-FrameLimitText $A.FrameLimit)}) }
        if ($Mode -eq 'Max') { Show-MaxWarning $Sys $A }
        $startup = @(Get-SuggestedStartup $Ctx)
        if (@($plan.Id) -contains 'startup') { $startup = @(Select-Startup @(Get-StartupItems | Where-Object { $_.Enabled })) }
        $A.Startup = $startup
        if ($Preset -eq 'Gaming') { $A.KeepCapture = Ask 'Сохранять запись и игровые клипы Windows?' 'Нужно для записи через Game Bar. OBS этим параметром не управляется.' 'Сохранить' 'Выключить' 1 }
        elseif ($Mode -eq 'Manual') { $A.KeepCapture = Ask 'Сохранять запись и игровые клипы Windows?' '' 'Сохранить' 'Выключить' 1 }
        elseif ($Preset -eq 'Max') { $A.KeepCapture = $false }
        else { $A.KeepCapture = $true }
        $A.AfterReportEnabled = Ask 'Создавать повторный лог после перезагрузки?' 'Один отчёт через 5 минут после следующего входа. После попытки задача удаляется; повторного лога при каждом включении не будет. Только проверка, без автоматического исправления. Можно отказаться и запускать самопроверку вручную.' 'Да, проверять после входа' 'Нет, только вручную' 2
        $L = Show-Answers $Sys $Prof $Fl $Ctx $A
        Show-BoostPlan $plan $A
        if ($plan.Count -eq 0) { return (Stop-Nothing 'Ни один блок не выбран.') }
        if (@($plan.Id) -contains 'apps' -and (@($A.Junk).Count -gt 0 -or $A.Light -or $A.OneDrive)) {
            Write-Host '  Удаление Appx не откатывается автоматически. Область показана в плане; классические компоненты и OneDrive могут затрагивать систему.' -ForegroundColor Yellow
            Write-Host '  Для разрешения удаления введи УДАЛИТЬ. Любой другой ответ отменяет настройку.'
            if ((Read-Line) -cne 'УДАЛИТЬ') { return (Stop-Nothing 'Удаление не подтверждено.') }
        }
        $c = Ask-Opt 'Начинаем?' 'Проверь блоки и последствия. При ошибке выполнение остановится; откат останется доступен.' @('Начать', 'Выбрать режим и ответить заново', 'Отмена') 1
        if ($c -eq 1) { break }
        if ($c -eq 3) { return (Stop-Nothing 'Отменено.') }
    }

    Enter-BoostLock
    if (Test-Path -LiteralPath $GameFile) {
        $prior=Read-Json $StateFile
        if (-not $prior) {throw 'Состояние прежнего игрового режима не прочитано; новая настройка не запускается'}
        [void](Game-Off $prior)
        Log INFO 'Временные параметры прежнего игрового режима возвращены до новой настройки'
    }
    Protect-BoostDirectory
    $ob = Test-OldBackups
    if ($ob -eq 'exit') { Wait-Key; return 2 }

    # Лог, бэкап и откат: всё до первой правки
    [void](New-Item -ItemType Directory -Path $P3Root -Force)
    if (Test-Path -LiteralPath $LogPath) {
        Write-LogFile ''
        Write-LogFile ('=================== Повторный запуск · ' + (Get-Date -Format 'dd.MM.yyyy HH:mm') + ' ===================')
    }
    Write-LogFile ($BR.Title + ' · лог настройки')
    Write-LogFile ('Дата: ' + (Get-Date -Format 'dd.MM.yyyy HH:mm') + '   Профиль: ' + $ProfileTitle[$Prof] + '   Windows: ' + $Sys.Name)
    Write-LogFile $BR.Seller # @client
    Write-LogFile ('Каждое изменение записано в бэкап ' + $P3Root + ' и откатывается ярлыком «' + $RollbackName + '».')
    Write-HardwareLog $Sys $Prof $Pp $L

    Initialize-Backup
    $ans = @{}
    foreach ($k in $A.Keys) {
        if ($k -eq 'Junk') { $ans[$k] = @($A.Junk | ForEach-Object { $_.Title }) } else { $ans[$k] = $A[$k] }
    }
    $State.Profile = $Prof
    $State.ProfileManual = [bool]$Pp.Manual
    $State.Flags = $Fl
    $State.Mode = $Mode
    $State.Preset = $Preset
    $State.Plan = @($plan | ForEach-Object { $_.Id })
    $State.RunStatus = 'Prepared'
    $State.Results = @()
    $State.AfterReportEnabled = [bool]$A.AfterReportEnabled
    $State.Answers = $ans
    $State.RamGB = $Sys.RamGB
    $State.IsLaptop = [bool]$Sys.IsLaptop
    $State.GameProfiles = @($A.GameProfiles)
    $State.GameDownloadPercent=[int]$A.GameDownloadPercent
    if (-not $State.ContainsKey('GamePurge')) { $State.GamePurge = $false }
    if (-not $State.ContainsKey('GameForceClose')) { $State.GameForceClose = $false }
    $State.GameProcs = @(@($IfeoGames) + @($GameExeNames) | Select-Object -Unique)
    $State.GameProcs = @(@($State.GameProcs) + @($A.GameProfiles | ForEach-Object { [IO.Path]::GetFileName([string]$_.Path) }) | Select-Object -Unique)
    $State.GameRoots = @($Ctx.GameRoots | Where-Object { $_ })
    if ($Mode -eq 'Manual' -or -not $State.ContainsKey('GameClose')) {
    $State.GameClose = @(@($A.GameClose) | Where-Object { $_ } | ForEach-Object { $Closable[$_] } | Where-Object { $_ } | Select-Object -Unique)
    }
    Save-State
    if (-not (Install-Nested)) { throw 'Скрипты восстановления не готовы. Основная настройка не запущена.' }
    $lagBefore = Write-MeasureBefore $Sys
    if (-not (New-P3RestorePoint)) { return (Stop-Nothing ('Остановлено перед первой правкой. Бэкап и откат лежат в ' + $P3Root + '.')) }

    Write-Host ''
    Write-Host '  Настраиваю. Окно не закрывай, это займёт несколько минут.' -ForegroundColor White
    $nv = 'skip'; $done = @()
    $State.RunStatus = 'Applying'; Save-State
    $stepNumber = 0
    foreach ($step in $plan) {
        $stepNumber++
        Write-Host ('  [' + $stepNumber + ' из ' + $plan.Count + '] ' + $step.Title) -ForegroundColor Cyan
        $State.ActiveStep = $step.Id; Save-State
        $beforeErrors = $Count.ERR
        try {
            switch ($step.Id) {
                'system' { Invoke-SystemTweaks $Sys $Prof $Fl $A }
                'interface' { Invoke-InterfaceTweaks $Sys $Prof $Fl $A }
                'appearance' { Invoke-AppearanceTweaks $Sys $Prof $Fl $A }
                'grouping' { Invoke-GroupingTweaks $Sys $Prof $Fl $A }
                'browser-memory' { Invoke-BrowserMemoryTweaks $Sys $Prof $Fl $A }
                'memory' { Invoke-MemoryTweaks $Sys $Prof $Fl $A }
                'storage' { Invoke-StorageTweaks $Sys $Prof $Fl $A }
                'global-timer' { Invoke-GlobalTimerTweaks $Sys $Prof $Fl $A }
                'keyboard' { Invoke-KeyboardTweaks $Sys $Prof $Fl $A }
                'security' { Invoke-SecurityTweaks $Sys $A }
                'power' { Invoke-Power $Sys $Prof $A }
                'network' { Invoke-NetTweaks $Sys $A }
                'privacy' { Invoke-BackgroundTweaks $Sys $A $Ctx }
                'startup' { Invoke-StartupTweaks $Sys $A $Ctx }
                'tasks' { Invoke-TaskTweaks $Sys $A $Ctx }
                'services' { Invoke-ServiceTweaks $Sys $A $Ctx }
                'defender' { Invoke-DefenderTweaks $Sys $A $Ctx }
                'video' { Invoke-VideoTweaks $Sys $Prof $Fl $A }
                'game-profiles' { Invoke-GameProfiles $A.GameProfiles }
                'nvidia' { $nv = Invoke-Nvidia $Sys $Fl $A }
                'amd' { [void](Apply-AmdProfile ([bool]$Fl.Video) ([bool]$Sys.IsLaptop) ([bool]$A.ChangeQuality)) }
                'apps' { Invoke-Apps $Sys $A $Ctx }
                'input' { Invoke-MouseMonitor $Sys $A }
                'timer' { Invoke-Timer $Sys $A }
                'programs' { $done = @(Invoke-Programs $Sys $A) }
                'cleanup' { Invoke-Cleanup }
                'frame-limit' { Invoke-FrameLimit $Sys $A.FrameLimit }
            }
        } catch { Log ERR ($step.Title + ': ' + $_.Exception.Message) }
        $failed = $Count.ERR -gt $beforeErrors
        $State.Results += @{ Id = $step.Id; Title = $step.Title; Status = $(if ($failed) { 'Failed' } else { 'Processed' }); At = (Get-Date).ToString('o') }
        Save-State
        if ($failed) { $State.RunStatus = 'Failed'; Save-State; break }
    }
    # Recovery remains reachable even if one module failed.
    Install-Tasks
    if ($State.RunStatus -ne 'Failed' -and $Count.ERR -eq 0) { $State.RunStatus = 'Completed' } else { $State.RunStatus = 'Failed' }
    $State.ActiveStep = ''; Save-State

    # Итог
    $lagAfter = Get-LagState $Sys
    Show-BeforeAfter $lagBefore $lagAfter
    Show-List 'Что сделать руками' (Get-ManualNotes $Sys ([string]$nv) $done) 'Yellow'
    $hints = @()
    try { $hints = @(Get-Hints $Sys $Prof) } catch {}
    Show-List 'Подсказки' $hints 'Gray'
    $State.Finished = (Get-Date).ToString('o')
    Save-State
    $t = 'Сделано: ' + $Count.OK + ' · пропущено: ' + $Count.SKIP + ' · ошибок: ' + $Count.ERR
    Section 'Итог'
    Write-Host ('   ' + $t) -ForegroundColor White
    Write-LogFile $t
    if ($State.AfterReportEnabled) { Write-LogFile 'Автоотчёт включён один раз: через 5 минут после следующего входа, без повторного применения настроек.' }
    else { Write-LogFile 'Автоотчёт выключен по выбору пользователя. Ручная самопроверка доступна.' }
    if ($Count.ERR -gt 0) { Write-Host '   Были ошибки. Проверь результаты блоков в логе; доступен откат.' -ForegroundColor Yellow }
    Show-Final
    return 0
}

# Меню и план используют оригинальные блоки BOOST 3.0.
function Get-BoostPlan($Sys, [string]$Preset) {
    $rows = @(
        @('system', 'Планировщик и системные параметры', 'Приоритеты Windows/игр, быстрый запуск Windows и Power Throttling. Память, оформление, NTFS и таймер выбираются отдельно.'),
        @('interface', 'Меню и задержка автозапуска', 'Мгновенные меню, снятие задержек запуска программ.'),
        @('appearance', 'Оформление по профилю CPU/RAM', 'Упрощение визуальных эффектов при выбранной адаптации CPU/RAM. Сглаживание и эскизы сохраняются.'),
        @('grouping', 'Группировка служб svchost', 'Порог разделения служб по объёму RAM. Меньше процессов не означает рост FPS.'),
        @('browser-memory', 'Экономия памяти браузеров', 'Сон вкладок Edge, политика экономии памяти Chrome; применяется по профилю CPU/RAM.'),
        @('memory', 'Память и файл подкачки', 'Сжатие памяти по выбору; обычные наборы сохраняют Windows. Подкачка по выбору системы. Оформление и NTFS отдельно.'),
        @('storage', 'Параметры NTFS', 'Отключение отметок доступа и новых коротких имён 8.3. Отдельное действие с откатом значений.'),
        @('global-timer', 'Глобальный запрос таймера Windows 11', 'GlobalTimerResolutionRequests=1. Эксперимент отдельно от таймеров BCD, без гарантии эффекта.'),
        @('keyboard', 'Клавиатура и залипание клавиш', 'Быстрый повтор; отключение вызовов залипания, фильтрации и озвучивания клавиш.'),
        @('security', 'Дополнительные параметры защиты', 'VBS, Spectre и пауза обновлений — только по ответам. Может менять загрузчик.'),
        @('power', 'Питание и USB', 'Адаптивная копия исходной схемы либо исходный режим 3.0 по ответу. Только режим 3.0 меняет USB/гибернацию; возможны нагрев и шум.'),
        @('network', 'Проводная сеть', 'Параметры проводного драйвера, TCP и энергосбережение. MSI по явному выбору. Wi-Fi не меняется. Нужна перезагрузка.'),
        @('privacy', 'Реклама, советы и фон Windows', 'Политики телеметрии, рекламы, поиска, виджетов, Copilot и Recall; фон браузеров и приложений — отдельный блок.'),
        @('startup', 'Автозагрузка и фон приложений', 'Явный выбор записей автозагрузки; фон Windows-приложений и Edge ограничивается отдельным ответом. Возврат через откат.'),
        @('tasks', 'Задачи телеметрии', 'Отключение известных задач Windows и Office с сохранением списка для возврата.'),
        @('services', 'Службы', 'Отключение служебного фона и явно ненужных функций по ответам. Сеть и звук остаются.'),
        @('defender', 'Defender и перезагрузки обновлений', 'Средняя нагрузка плановой проверки, исключения только по выбору; политика перезапуска обновлений.'),
        @('video', 'Игровые параметры Windows и GPU', 'Game Mode, HAGS по возможностям драйвера, оконные игры и выбор GPU. MSI — отдельный эксперимент. Запись клипов — по ответу.'),
        @('game-profiles', 'Профили выбранных игр Windows', 'Выбор EXE, необязательный высокий приоритет и предпочтение GPU. Параметры графики внутри игр не меняются.'),
        @('nvidia', 'Профиль NVIDIA', 'Глобальные параметры драйвера: питание, задержка, фильтрация и кэш. Влияет на все игры.'),
        @('amd', 'Профиль AMD Adrenalin', 'Anti-Lag, Chill, Boost, Enhanced Sync и качество фильтрации. Только найденные ключи драйвера.'),
        @('apps', 'Приложения и классический интерфейс', 'Удаление выбранных Appx, OneDrive, классические программы и меню. Удаление не возвращается автоматически.'),
        @('input', 'Мышь и монитор', 'Акселерация мыши и максимальная доступная частота основного монитора — по ответам.'),
        @('timer', 'Таймеры загрузчика', 'Убирает принудительный useplatformclock; dynamic tick меняется по ответу. Проверка BitLocker, перезагрузка.'),
        @('programs', 'Необязательные программы', 'Существующий установщик выбранных утилит. Установка не откатывается.'),
        @('cleanup', 'Очистка временных файлов', 'TEMP и скачанные обновления. Удалённые файлы не возвращаются.')
    )
    $defaults = @('interface', 'privacy')
    if ($Sys.WeakRam -or $Sys.WeakCpu.Weak) { $defaults += @('appearance', 'browser-memory') }
    if ($Preset -eq 'Light') { $defaults += @('memory', 'startup', 'tasks', 'services', 'defender') }
    if ($Preset -eq 'Gaming') { $defaults += @('video', 'power', 'game-profiles') }
    if ($Preset -eq 'Max') { $defaults = @($rows | ForEach-Object { $_[0] }) }
    $n = 0
    foreach ($row in $rows) {
        if ($row[0] -eq 'nvidia' -and -not $Sys.IsNvidia) { continue }
        if ($row[0] -eq 'amd' -and -not $Sys.IsAmdGpu) { continue }
        $n++
        [pscustomobject]@{ N = $n; Id = $row[0]; Title = $row[1]; About = $row[2]; Pre = ($defaults -contains $row[0]) }
    }
}

function Select-BoostPlan($Current, [bool]$Empty) {
    $ids = @($Current | ForEach-Object { $_.Id })
    $items = @($script:BoostCatalog | ForEach-Object {
        [pscustomobject]@{ N = $_.N; Text = ($_.Title + ': ' + $_.About); Pre = (-not $Empty -and $ids -contains $_.Id) }
    })
    $pick = @(Ask-Multi 'Какие блоки выполнить?' 'В ручном режиме исходно ничего не выбрано. Служебные бэкапы, откат и игровой переключатель готовятся отдельно.' $items)
    return @($script:BoostCatalog | Where-Object { $pick -contains $_.N })
}

function Get-SuggestedStartup($Ctx) {
    $auto = @(Get-StartupItems | Where-Object { $_.Enabled -and (Test-AutoOff $_ ([bool]$Ctx.OneDrive.Block)) })
    foreach ($t in @('MSTeams_8wekyb3d8bbwe|TeamsTfwStartupTask', 'MicrosoftTeams_8wekyb3d8bbwe|TeamsStartupTask')) {
        $parts = $t.Split('|')
        $key = $SysAppData + '\' + $parts[0] + '\' + $parts[1]
        if (@(Get-RegSubKeys $SysAppData) -contains $parts[0] -and -not ($auto | Where-Object { $_.Appr -eq $key })) {
            $state = Get-RegValue $key 'State'
            if ($null -eq $state -or @(2, 4) -contains [int]$state.Value) { $auto += [pscustomobject]@{ Kind='appx';Name=$parts[1];Title='Teams';Command=$parts[0];Appr=$key;Enabled=$true } }
        }
    }
    return $auto
}

function Get-StartupDescription($It) {
    $text = $It.Name + ' ' + $It.Command
    if ($text -match 'SecurityHealth|Defender|antivirus|avp\.exe|avast|kaspersky|eset|ekrn|mbam|malwarebytes|bitdefender|norton|sophos|mcafee|crowdstrike|sentinel|forti|avguard|RtkAud|Realtek|AMDNoise|NVIDIA|igfx|SynTP|iCUE|Armoury|Logi|Razer|Corsair') { return 'Защита или управление оборудованием; исключено из выбора' }
    if ($text -match 'OneDrive|Dropbox|GoogleDrive|YandexDisk') { return 'Синхронизация файлов; отключение остановит запуск синхронизации при входе' }
    if ($text -match 'steam|EpicGames|Battle.net|RiotClient') { return 'Игровой лаунчер; после отключения запускается вручную' }
    if ($text -match 'Discord|Teams|Telegram|WhatsApp|Skype|Zoom') { return 'Связь и уведомления; после отключения программа не стартует при входе' }
    if ($text -match 'Edge|msedge') { return 'Предварительный запуск браузера' }
    return 'Назначение не определено; решение только вручную'
}
function Test-ProtectedStartup($It) {
    return ((Get-StartupDescription $It) -like 'Защита или*')
}
function Select-Startup($Suggested) {
    $entries = @($Suggested | Where-Object { -not (Test-ProtectedStartup $_) })
    if ($entries.Count -eq 0) { return @() }
    $n=0
    $items=@($entries | ForEach-Object { $n++;[pscustomobject]@{ N=$n;Pre=$false;Text=($_.Title+' — '+(Get-StartupDescription $_)+' ['+$_.Appr+'] '+$_.Command) } })
    $pick=@(Ask-Multi 'Что отключить из автозагрузки?' 'Ничего не выбрано. Отключение не удаляет программу. Защита и распознанное управление оборудованием не предлагаются.' $items)
    $n=0;return @($entries | Where-Object { $n++;$pick -contains $n })
}
function Get-GpuPreference([string]$Current, [int]$Value) {
    $parts=@($Current.Split(';') | Where-Object { $_ -and $_ -notmatch '^\s*GpuPreference=' })
    $parts+=('GpuPreference='+$Value)
    return (($parts -join ';')+';')
}
function Select-GameProfiles($Sys) {
    $paths=@(Get-GameExes | Sort-Object -Unique)
    if (Ask 'Добавить свой EXE игры?' 'Файл не будет запускаться. Можно указать исполняемый файл установленной игры.' 'Добавить' 'Пропустить' 2) {
        Write-Host '  Полный путь к EXE (или пустой Enter для отмены):'
        $path=(Read-Line).Trim('"')
        if ($path) {
            if (-not [IO.Path]::IsPathRooted($path) -or [IO.Path]::GetExtension($path) -ine '.exe' -or -not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Нужен полный путь к существующему EXE игры' }
            $paths+=([IO.Path]::GetFullPath($path))
        }
    }
    $paths=@($paths | Sort-Object -Unique)
    if ($paths.Count -eq 0) { Write-Host '  Игры не выбраны.';return @() }
    $n=0;$items=@($paths | ForEach-Object {$n++;[pscustomobject]@{N=$n;Pre=$false;Text=$_}})
    $pick=@(Ask-Multi 'Для каких игр настроить профиль Windows?' 'Пустой выбор ничего не меняет. Это приоритет процесса и выбор GPU, не графические настройки внутри игры.' $items)
    if ($pick.Count -eq 0) { return @() }
    $high=Ask 'Запрашивать высокий приоритет процесса?' 'IFEO применяется по имени EXE, включая одноимённые процессы в других папках. Античит может игнорировать настройку.' 'Высокий' 'Не менять' 2
    $gpu=$false
    if ($Sys.HasDGpu -and ($Sys.IsLaptop -or $Sys.MultiGpu)) { $gpu=Ask 'Предпочитать производительный GPU для выбранных EXE?' 'Остальные параметры профиля Windows сохраняются.' 'Предпочитать' 'Не менять' 1 }
    $n=0
    foreach ($path in $paths) { $n++;if ($pick -contains $n) { [pscustomobject]@{Path=$path;HighPriority=$high;PreferGpu=$gpu} } }
}
function Invoke-GameProfiles($Profiles) {
    foreach ($game in @($Profiles)) {
        if ($game.HighPriority) {
            $exe=[IO.Path]::GetFileName([string]$game.Path)
            Apply-Reg ('Приоритет выбранной игры '+$exe) @("$IFEO\$exe\PerfOptions|CpuPriorityClass|DWord|3")
        }
        if ($game.PreferGpu) {
            $key='HKCU\Software\Microsoft\DirectX\UserGpuPreferences'
            $cur=Get-RegValue $key ([string]$game.Path)
            $script:RegNote='GPU выбранной игры'
            try {
                $value = Get-GpuPreference ([string]$cur.Value) 2
                Set-Reg $key ([string]$game.Path) 'String' $value
                $actual = Get-RegValue $key ([string]$game.Path)
                if (-not $actual -or [string]$actual.Value -cne $value) { throw 'Профиль GPU не прошёл проверку записи' }
            }
            finally { $script:RegNote='' }
        }
    }
}
function Set-GameOptions {
    Enter-BoostLock
    try {
        $st=Read-Json $StateFile
        if (-not $st -or $st.RolledBack) { Write-Host '  Сначала нужна активная установка BOOST.';Wait-Key;return }
        if (Test-Path -LiteralPath $GameFile) {[void](Game-Off $st)}
        $tool = Join-Path $P3Root ($GameName + '.bat')
        if (-not (Test-Path -LiteralPath $tool) -or -not ([IO.File]::ReadAllText($tool, [Text.Encoding]::UTF8).Contains('# BOOST_GAME_OPTIONS_V2'))) { Write-Host '  Сначала обнови служебные скрипты пунктом 9. Настройки режима пока не менялись.'; Wait-Key; return }
        $found=@(Get-ClosableFound | Where-Object { $_ -notmatch 'iCUE|Armoury' })
        $n=0;$items=@($found | ForEach-Object {$n++;[pscustomobject]@{N=$n;Pre=$false;Text=$_}})
        $pick=@(Ask-Multi 'Что закрывать на время игры?' 'Пустой выбор ничего не закрывает. Автоматически обратно программы не запускаются.' $items)
        $close=@();$n=0
        foreach ($name in $found) { $n++;if ($pick -contains $n) {$close+=@($Closable[$name])} }
        $force=$false
        if ($close.Count -gt 0) { $force=Ask 'Принудительно закрывать не ответившие программы?' 'Может привести к потере несохранённых данных. По умолчанию только запрос штатного закрытия.' 'Принудительно' 'Только штатно' 2 }
        $downloads=0
        if (Get-GameDownloadPolicy) {
            if (Ask 'Ограничивать фоновые загрузки Windows во время игрового режима?' 'До 10% измеренной полосы Delivery Optimization. Остальные программы и существующие политики не меняются.' 'Ограничивать' 'Не ограничивать' 2) {$downloads=10}
        }
        $purge=Ask 'Разрешить очистку standby-памяти при её нехватке?' 'Существующий эксперимент для 16 ГБ RAM и меньше. При работающем ISLC не дублируется. Польза не гарантируется.' 'Разрешить' 'Выключить' 2
        if (-not (Ask 'Сохранить настройки игрового режима?' '' 'Сохранить' 'Отмена' 1)) { return }
        Set-StateProp $st 'GameClose' @($close | Select-Object -Unique)
        Set-StateProp $st 'GameForceClose' $force
        Set-StateProp $st 'GamePurge' $purge
        Set-StateProp $st 'GameDownloadPercent' $downloads
        Register-GameRecoveryTask $st
        Save-StateObj $st
        Write-Host '  Параметры сохранены. Программы сейчас не закрывались.' -ForegroundColor Green
        Wait-Key
    } finally { Exit-BoostLock }
}


function Show-BoostPlan($Plan, $A) {
    Write-Host ''
    Write-Host '  ПЛАН НАСТРОЙКИ — выполняются только эти блоки' -ForegroundColor Cyan
    foreach ($step in $Plan) { Write-Host ('  + ' + $step.Title); Write-Host ('    ' + $step.About) -ForegroundColor DarkGray }
    if (@($Plan.Id) -contains 'startup') {
        Write-Host ('  Ограничить фон Windows-приложений и Edge: ' + @{ $true='да'; $false='нет' }[[bool]$A.RestrictBackground])
        Write-Host '  Отключение автозагрузки:'
        foreach ($it in @($A.Startup)) { Write-Host ('    ' + $it.Title + ' — ' + $it.Command) }
        if (@($A.Startup).Count -eq 0) { Write-Host '    Нет выбранных записей.' }
    }
    if (@($Plan.Id) -contains 'apps') {
        Write-Host ('  Область Appx: ' + @{CurrentUser='текущий пользователь';AllUsers='все пользователи и provisioning'}[[string]$A.AppScope])
        foreach ($app in @($A.Junk)) { Write-Host ('  Удалить: ' + $app.Title) -ForegroundColor Yellow }
        if ($A.Light) { Write-Host '  Классические замены: Блокнот/медиаплееры удаляются в выбранной области; включение классических компонентов — системное.' -ForegroundColor Yellow }
        if ($A.OneDrive) { Write-Host '  Удалить OneDrive.' -ForegroundColor Yellow }
    }
    foreach ($path in @($A.DefExcl)) { if (@($Plan.Id) -contains 'defender') { Write-Host ('  Исключение Defender: ' + $path) -ForegroundColor Yellow } }
    if (@($Plan.Id) -contains 'video') { Write-Host ('  Сохранить запись клипов Windows: ' + @{ $true='да'; $false='нет' }[[bool]$A.KeepCapture]) }
    foreach ($game in @($A.GameProfiles)) { Write-Host ('  Игра: ' + $game.Path + '; высокий приоритет по имени EXE: ' + [bool]$game.HighPriority + '; производительный GPU: ' + [bool]$game.PreferGpu) }
    Write-Host ('  Лимит FPS: '+(Get-FrameLimitText $A.FrameLimit))
    Write-Host ('  Фоновые загрузки Windows: '+$A.GameDownloadPercent+'% только в игровом режиме (0 — не ограничивать)')
    Write-Host '  Дополнительно: бэкап исходных значений, попытка точки восстановления, откат и игровой переключатель.'
    Write-Host ('  Повторный лог после входа: ' + @{ $true='да, один раз после следующего входа'; $false='нет, только ручная самопроверка' }[[bool]$A.AfterReportEnabled])
    Write-Host '  Это настройка Windows. FPS и задержку ввода данный отчёт не измеряет.' -ForegroundColor DarkGray
}

function Show-PcReport {
    Write-Host '  ПРОВЕРКА ПК — без изменения настроек и создания бэкапов' -ForegroundColor Cyan
    try {
        $sys = Get-SystemInfo
        $prof = Get-AutoProfile $sys
        Show-Profile $sys $prof (Get-Flags $sys $prof $false)
    } catch { Write-Host ('  Сбор данных оборудования не завершён: ' + $_.Exception.Message) -ForegroundColor Yellow }
    try {
        Write-Host '  Локальные диски:'
        foreach ($d in @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)) {
            Write-Host ('    ' + $d.DeviceID + ' свободно ' + [math]::Round($d.FreeSpace / 1GB, 1) + ' из ' + [math]::Round($d.Size / 1GB, 1) + ' ГБ')
        }
    } catch { Write-Host ('  Диски: данные недоступны. ' + $_.Exception.Message) }
    try {
        Write-Host ('  Активная схема: ' + (Get-SchemeName))
        $pages = @(Get-CimInstance Win32_PageFileUsage -ErrorAction Stop)
        foreach ($pf in $pages) { Write-Host ('  Подкачка: ' + $pf.Name + ', выделено ' + $pf.AllocatedBaseSize + ' МБ') }
        if ($pages.Count -eq 0) { Write-Host '  Активный файл подкачки не найден; проверь настройку и необходимость перезагрузки.' }
    } catch { Write-Host ('  Питание/подкачка: данные недоступны. ' + $_.Exception.Message) }
    try {
        Write-Host '  Автозагрузка (не является полным перечнем служб и задач):'
        foreach ($it in @(Get-StartupItems)) { Write-Host ('    ' + $(if ($it.Enabled) { '[вкл] ' } else { '[выкл] ' }) + $it.Title + ' — ' + $it.Command) }
    } catch { Write-Host ('  Автозагрузка: данные недоступны. ' + $_.Exception.Message) }
    Write-Host '  Частота RAM сама по себе не доказывает отключённый XMP/EXPO. Частота дисплея указана для основного экрана.'
    Write-Host '  Изменения не применялись. Результат в играх проверяется отдельно.' -ForegroundColor Green
    Wait-Key
}

function Open-BoostTool([string]$Kind) {
    $names = @{ rollback = $RollbackName; game = $GameName; check = $CheckName }
    $path = Join-Path $P3Root ($names[$Kind] + '.bat')
    if (-not (Test-Path -LiteralPath $path)) { Write-Host '  После настройки этот инструмент появится здесь.' -ForegroundColor Yellow; Wait-Key; return }
    Start-Process -FilePath $env:ComSpec -ArgumentList ('/c ""' + $path + '""') -Wait
}

function Show-BoostHistory {
    $st = Read-Json $StateFile
    if (-not $st) { Write-Host '  Сохранённой настройки пока нет.'; Wait-Key; return }
    Write-Host ('  Первый запуск: ' + $st.Created)
    $statuses = @{ Prepared='Подготовлен'; Applying='Выполняется'; Completed='Завершён'; Failed='Прерван с ошибкой' }
    $status = [string]$st.RunStatus
    if ($statuses.ContainsKey($status)) { $status = $statuses[$status] }
    if (-not $status) { $status = 'Предыдущая сборка без подробного статуса' }
    Write-Host ('  Статус последнего запуска: ' + $status)
    Write-Host '  Последние запуски (с общим исходным бэкапом):'
    foreach ($date in @($st.Runs | Select-Object -Last 10)) { Write-Host ('    ' + $date) }
    Write-Host ('  Откат выполнен: ' + [bool]$st.RolledBack)
    foreach ($r in @($st.Results)) {
        if ($r) {
            $label = 'Обработан (подробности в логе)'
            if ($r.Status -eq 'Failed') { $label = 'Ошибка' }
            Write-Host ('    ' + $r.Title + ': ' + $label)
        }
    }
    Write-Host ('  Бэкап до первой настройки: ' + $P3Root)
    Write-Host '  Откат общий: он возвращает исходные настройки до первого запуска. Удалённые приложения и файлы сам не возвращает.'
    if (Ask 'Открыть откат?' '' 'Открыть' 'Назад' 2) { Open-BoostTool 'rollback' }
}

function Show-BoostLinks {
    $n = Ask-Opt 'Ссылки автора' '' @('YouTube', 'Telegram', 'Discord', 'Назад') 4
    if ($n -le 3) {
        $links = @('https://www.youtube.com/@plays1n', 'https://t.me/playsin333tgk', 'https://discord.gg/brMD3VYUAu')
        Start-Process -FilePath $links[$n - 1]
    }
}

function Update-InstalledTools {
    Enter-BoostLock
    try {
        $st = Read-Json $StateFile
        if (-not $st -or $st.RolledBack) { Write-Host '  Активная установка BOOST не найдена. Обновлять нечего.'; Wait-Key; return }
        Protect-BoostDirectory
        $saved = Join-Path $P3Root ('scripts-before-' + [guid]::NewGuid().ToString('N'))
        [void][IO.Directory]::CreateDirectory($saved)
        $names = @(($RollbackName + '.bat'), ($GameName + '.bat'), ($CheckName + '.bat'))
        foreach ($name in $names) {
            $path = Join-Path $P3Root $name
            if (-not (Test-Path -LiteralPath $path)) { throw ('Исходный скрипт не найден: ' + $path + '. Обновление не начато.') }
            Copy-Item -LiteralPath $path -Destination (Join-Path $saved $name) -ErrorAction Stop
        }
        if (-not (Install-Nested)) {
            foreach ($name in $names) { Copy-Item -LiteralPath (Join-Path $saved $name) -Destination (Join-Path $P3Root $name) -Force -ErrorAction Stop }
            throw ('Обновление скриптов не удалось; прежние файлы возвращены. Резерв: ' + $saved)
        }
        Write-Host ('  Откат, игровой режим и самопроверка обновлены до ' + $P3Version + '. Настройки Windows и исходный бэкап не менялись.') -ForegroundColor Green
        Write-Host ('  Предыдущие скрипты сохранены: ' + $saved)
        Wait-Key
    } finally { Exit-BoostLock }
}

function Show-ProgramGuides {
    $index = Join-Path (Join-Path $PackDir 'Программы') 'Открыть гайды.html'
    if (-not (Test-Path -LiteralPath $index -PathType Leaf)) { Write-Host '  Распакуй папку Программы рядом с BAT; её отсутствие не мешает оптимизации.'; Wait-Key; return }
    Start-Process -FilePath $index
}

# Keep the external checker's functions and globals out of the BOOST process.
function Get-TweakCheckerStartInfo {
    $path = Join-Path (Join-Path $PackDir 'checker') 'PLAYSIN TWEAK CHECK.bat'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Не найден TWEAK CHECK. Распакуй папку checker рядом с BAT.' }
    $command = @'
$ErrorActionPreference = 'Stop'
try {
    [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false); [Console]::InputEncoding = [Console]::OutputEncoding; $OutputEncoding = [Console]::OutputEncoding;
    & ([scriptblock]::Create([IO.File]::ReadAllText($env:TC_SELF, [Text.Encoding]::UTF8)))
} catch {
    Write-Host ('TWEAK CHECK: ' + $_.Exception.Message) -ForegroundColor Red
    if (-not $env:TC_NOWAIT) { try { [void][Console]::ReadKey($true) } catch {} }
    exit 1
}
'@
    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName = Join-Path $PSHOME 'powershell.exe'
    $start.Arguments = '-NoLogo -NoProfile -OutputFormat Text -EncodedCommand ' + [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $start.UseShellExecute = $false
    $start.WorkingDirectory = $PackDir
    # Pass the literal path through the child environment, never through cmd.exe.
    $start.EnvironmentVariables['TC_SELF'] = $path
    return $start
}

function Show-TweakChecker {
    Write-Host '  TWEAK CHECK проверяет изменения Windows и создаёт отдельный отчёт на рабочем столе.' -ForegroundColor Cyan
    Write-Host '  Настройки не применяются. Оценки чекера не являются замером FPS или задержки.'
    $child = $null
    try {
        $child = [Diagnostics.Process]::Start((Get-TweakCheckerStartInfo))
        $child.WaitForExit()
        if ($child.ExitCode -ne 0) { throw ('Чекер завершился с кодом ' + $child.ExitCode) }
    } catch {
        Write-Host ('  Не удалось выполнить TWEAK CHECK: ' + $_.Exception.Message) -ForegroundColor Yellow
        Wait-Key
    } finally { if ($child) { $child.Dispose(); Set-ConsoleLook } }
}

function Set-AfterReportTask([bool]$Enabled) {
    if ($Enabled) {
        $check = Join-Path $P3Root ($CheckName + '.bat')
        if (-not (Test-Path -LiteralPath $check -PathType Leaf)) { throw 'Скрипт самопроверки не найден. Сначала обнови служебные скрипты пунктом 9.' }
        if (-not ([IO.File]::ReadAllText($check, [Text.Encoding]::UTF8).Contains('# BOOST_REPORT_ONCE_V1'))) { throw 'Сначала обнови служебные скрипты пунктом 9: нужен одноразовый отчёт без автоматического исправления.' }
        Register-P3Task $TaskAfter $env:ComSpec ('/c ""' + $check + '" after"') $true 5 ($BR.Pack + ': один отчёт через 5 минут после следующего входа; без исправления настроек')
        $task = @(Get-AfterReportTask)
        if ($task.Count -ne 1 -or [string]$task[0].State -eq 'Disabled') { throw 'Задача автоотчёта не включилась' }
    } else {
        Remove-AfterReportTask
    }
}
function Set-AfterReportPreference([bool]$Enabled) {
    Enter-BoostLock
    try {
        $st = Read-Json $StateFile
        if (-not $st -or $st.RolledBack) { throw 'Активная установка BOOST не найдена' }
        $previous = @((Get-AfterReportTask) | Where-Object { [string]$_.State -ne 'Disabled' }).Count -gt 0
        try {
            Set-AfterReportTask $Enabled
            Set-StateProp $st 'AfterReportEnabled' $Enabled
            Save-StateObj $st
        } catch {
            $failure = $_
            try { Set-AfterReportTask $previous }
            catch { throw ('Настройка отчёта не завершена; возврат прежней задачи тоже не удался: ' + $_.Exception.Message) }
            throw $failure
        }
    } finally { Exit-BoostLock }
}
function Show-AfterReportOptions {
    $choice = Ask-Opt 'Нужен повторный лог после перезагрузки?' 'Если включено: один отчёт через 5 минут после следующего входа, затем задача удаляется. Можно заново разрешить один отчёт. Настройки сам не исправляет. Ручная самопроверка доступна всегда.' @('Разрешить один отчёт после следующего входа', 'Выключить автоматический отчёт', 'Назад') 3
    if ($choice -eq 3) { return }
    Set-AfterReportPreference ($choice -eq 1)
    Write-Host ('  Автоматический отчёт: ' + @{ $true='включён'; $false='выключен' }[$choice -eq 1]) -ForegroundColor Green
    Wait-Key
}

function Get-BoostPackage([string]$ZipPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $files = @{}; $total = 0L; $prefix = $null
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName.Replace('\','/')
            if ($name -match '^/|:|(^|/)\.\.?(/|$)' -or $name -match '//') { throw 'Недопустимый путь в архиве' }
            $bits = $name.Split('/')
            if ($bits.Count -lt 2) { throw 'Нужна одна корневая папка комплекта' }
            if (-not $prefix) { $prefix = $bits[0] + '/' }
            if (-not $name.StartsWith($prefix, [StringComparison]::Ordinal)) { throw 'В архиве несколько корневых папок' }
            if ($name.EndsWith('/')) { continue }
            $relative = $name.Substring($prefix.Length)
            if ($relative -match '[<>"|?*]' -or @($relative.Split('/') | Where-Object { $_ -match '[. ]$|^(CON|PRN|AUX|NUL|COM[0-9]|LPT[0-9])(\.|$)' }).Count) { throw 'Недопустимое имя файла Windows' }
            if (($entry.ExternalAttributes -shr 16 -band 61440) -eq 40960) { throw 'Ссылки в архиве не поддерживаются' }
            if ($files.ContainsKey($relative)) { throw 'Повторяющийся путь в архиве' }
            $total += $entry.Length
            if ($entry.Length -gt 16MB -or $total -gt 64MB -or $files.Count -ge 500) { throw 'Архив превышает допустимый размер' }
            $files[$relative] = $entry
        }
        if (-not $files.ContainsKey('BOOST-PACKAGE.json') -or -not $files.ContainsKey('SHA256SUMS.txt') -or -not $files.ContainsKey('PLAYSIN BOOST 3.0.bat')) { throw 'Это не обновляемый комплект BOOST: отсутствует манифест' }
        $reader = New-Object IO.StreamReader($files['BOOST-PACKAGE.json'].Open(), [Text.Encoding]::UTF8)
        try { $meta = ConvertFrom-Json ($reader.ReadToEnd()) -ErrorAction Stop } finally { $reader.Dispose() }
        if ($meta.Schema -ne 1 -or $meta.Product -cne 'PLAYSIN BOOST' -or [string]$meta.Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Неверный продукт или версия обновления' }
        $hashes = @{}
        $reader = New-Object IO.StreamReader($files['SHA256SUMS.txt'].Open(), [Text.Encoding]::UTF8)
        try { $lines = $reader.ReadToEnd() -split '\r?\n' } finally { $reader.Dispose() }
        foreach ($line in $lines) {
            if (-not $line) { continue }
            if ($line -notmatch '^([a-fA-F0-9]{64})  (.+)$') { throw 'Повреждён список контрольных сумм' }
            if ($hashes.ContainsKey($Matches[2])) { throw 'Повтор контрольной суммы' }
            $hashes[$Matches[2]] = $Matches[1]
        }
        if ($hashes.Count -ne $files.Count - 1) { throw 'Состав архива не совпадает со списком сумм' }
        foreach ($name in $files.Keys) {
            if ($name -eq 'SHA256SUMS.txt') { continue }
            if (-not $hashes.ContainsKey($name)) { throw ('Нет контрольной суммы: ' + $name) }
            $stream = $files[$name].Open(); $sha = [Security.Cryptography.SHA256]::Create()
            try { $hash = ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','') } finally { $stream.Dispose(); $sha.Dispose() }
            if ($hash -ine $hashes[$name]) { throw ('Повреждён файл: ' + $name) }
        }
        $reader = New-Object IO.StreamReader($files['PLAYSIN BOOST 3.0.bat'].Open(), [Text.Encoding]::UTF8)
        try { $bat = $reader.ReadToEnd() } finally { $reader.Dispose() }
        if ($bat -notmatch '(?m)^\$P3Version\s*=\s*''(\d+\.\d+\.\d+)''\s*\r?$' -or $Matches[1] -cne [string]$meta.Version) { throw 'Версия BAT не совпадает с манифестом' }
        $tokens = $null; $errors = $null
        [void][Management.Automation.Language.Parser]::ParseInput($bat, [ref]$tokens, [ref]$errors)
        if ($errors.Count) { throw 'Обновление содержит синтаксические ошибки PowerShell' }
        return [pscustomobject]@{ Version=[string]$meta.Version; Prefix=$prefix; Hashes=$hashes }
    } finally { $zip.Dispose() }
}
function Install-BoostPackage([string]$ZipPath, [string]$Parent, [string]$CurrentVersion) {
    $meta = Get-BoostPackage $ZipPath
    if ([version]$meta.Version -le [version]$CurrentVersion) { throw 'В архиве такая же или более старая версия' }
    $parentPath = [IO.Path]::GetFullPath($Parent)
    $lock = $null; $stage = $null
    try {
        $lock = [IO.File]::Open((Join-Path $parentPath '.boost-update.lock'), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
        $stage = Join-Path $parentPath ('.boost-stage-' + [guid]::NewGuid().ToString('N'))
        [void][IO.Directory]::CreateDirectory($stage)
        $zip = [IO.Compression.ZipFile]::OpenRead($ZipPath)
        try {
            $seen = @{}; $written = 0L
            foreach ($entry in $zip.Entries) {
                $name = $entry.FullName.Replace('\','/')
                if ($name.EndsWith('/')) { continue }
                if (-not $name.StartsWith($meta.Prefix, [StringComparison]::Ordinal)) { throw 'Архив изменился после проверки' }
                $relative = $name.Substring($meta.Prefix.Length)
                if ($seen.ContainsKey($relative) -or ($relative -ne 'SHA256SUMS.txt' -and -not $meta.Hashes.ContainsKey($relative))) { throw 'Архив изменился после проверки' }
                $seen[$relative] = $true
                $dest = [IO.Path]::GetFullPath((Join-Path $stage $relative))
                if (-not $dest.StartsWith($stage + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Выход за папку обновления запрещён' }
                [void][IO.Directory]::CreateDirectory((Split-Path -Parent $dest))
                $inputStream = $entry.Open(); $outputStream = [IO.File]::Create($dest)
                try {
                    $buffer = New-Object byte[] 65536; $fileBytes = 0L
                    while (($readBytes = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                        $written += $readBytes; $fileBytes += $readBytes
                        if ($written -gt 64MB -or $fileBytes -gt 16MB) { throw 'Превышен размер извлечённого обновления' }
                        $outputStream.Write($buffer, 0, $readBytes)
                    }
                } finally { $inputStream.Dispose(); $outputStream.Dispose() }
            }
        } finally { $zip.Dispose() }
        if ($seen.Count -ne $meta.Hashes.Count + 1) { throw 'Архив изменился после проверки' }
        foreach ($name in $meta.Hashes.Keys) {
            if ((Get-FileHash -LiteralPath (Join-Path $stage $name) -Algorithm SHA256).Hash -ine $meta.Hashes[$name]) { throw ('Проверка извлечённого файла не пройдена: ' + $name) }
        }
        $target = Join-Path $parentPath ('PLAYSIN BOOST ' + $meta.Version)
        if (Test-Path -LiteralPath $target) { throw ('Эта версия уже есть: ' + $target + '. Существующая папка не перезаписана.') }
        [IO.Directory]::Move($stage, $target); $stage = $null
        return (Join-Path $target 'PLAYSIN BOOST 3.0.bat')
    } finally {
        if ($stage -and (Test-Path -LiteralPath $stage)) { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue }
        if ($lock) { $lock.Dispose() }
    }
}
function Receive-BoostUpdateFile([string]$Url, [string]$Destination, [long]$Limit) {
    $current = [uri]$Url
    $tls = [Net.ServicePointManager]::SecurityProtocol
    try {
        [Net.ServicePointManager]::SecurityProtocol = $tls -bor [Net.SecurityProtocolType]::Tls12
        for ($redirect=0; $redirect -le 5; $redirect++) {
            if ($current.Scheme -ne 'https' -or $current.UserInfo) { throw 'Обновления загружаются только по HTTPS без встроенных паролей' }
            $request = [Net.WebRequest]::Create($current)
            $request.AllowAutoRedirect=$false; $request.Timeout=15000; $request.ReadWriteTimeout=15000
            $response = $request.GetResponse()
            try {
                if ([int]$response.StatusCode -ge 300 -and [int]$response.StatusCode -lt 400) { $current=New-Object Uri($current, $response.Headers['Location']); continue }
                if ($response.ContentLength -gt $Limit) { throw 'Файл обновления слишком большой' }
                $stream=$response.GetResponseStream(); $dest=[IO.File]::Create($Destination)
                try {
                    $buffer=New-Object byte[] 65536; $total=0L
                    while (($count=$stream.Read($buffer,0,$buffer.Length)) -gt 0) { $total+=$count; if ($total -gt $Limit) { throw 'Файл обновления слишком большой' }; $dest.Write($buffer,0,$count) }
                } finally { $stream.Dispose(); $dest.Dispose() }
                return
            } finally { $response.Dispose() }
        }
        throw 'Слишком много перенаправлений источника обновления'
    } finally { [Net.ServicePointManager]::SecurityProtocol=$tls }
}
function Get-BoostUpdateSource {
    # An existing per-installation override remains supported; the bundled source travels with updates.
    foreach ($file in @((Join-Path (Split-Path -Parent $PackDir) 'PLAYSIN-BOOST-update-source.json'), (Join-Path $PackDir 'PLAYSIN-BOOST-update-source.json'))) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
        $url = [string](Read-Json $file).ManifestUrl
        $uri = $null
        if (-not [uri]::TryCreate($url, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https' -or $uri.UserInfo) { throw 'В источнике обновлений нужен HTTPS-адрес без встроенного пароля.' }
        # Migrate only the former official channel; retain arbitrary custom sources.
        if ([string]::Equals($url, 'https://raw.githubusercontent.com/playsin333/pc-optimizer/main/boost-release.json', [StringComparison]::OrdinalIgnoreCase)) {
            return 'https://raw.githubusercontent.com/playsin333/playsin-boost/main/boost-release.json'
        }
        return $url
    }
    return $null
}
function Get-OnlineBoostRelease([string]$SourceUrl, [string]$Directory) {
    $manifestPath=Join-Path $Directory 'release.json'
    Receive-BoostUpdateFile $SourceUrl $manifestPath 64KB
    $meta=Read-Json $manifestPath
    if ($meta.Schema -ne 1 -or $meta.Product -cne 'PLAYSIN BOOST' -or [string]$meta.Version -notmatch '^\d+\.\d+\.\d+$' -or [string]$meta.Sha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Неверное описание онлайн-обновления' }
    $archiveUri = $null
    if (-not [uri]::TryCreate([string]$meta.ArchiveUrl, [UriKind]::Absolute, [ref]$archiveUri) -or $archiveUri.Scheme -ne 'https' -or $archiveUri.UserInfo) { throw 'Архив обновления должен загружаться по HTTPS без встроенного пароля.' }
    if ([version]$meta.Version -le [version]$P3Version) { return $null }
    return $meta
}
function Save-OnlineBoostRelease($Release, [string]$Directory) {
    $zipPath=Join-Path $Directory 'update.zip'
    Receive-BoostUpdateFile ([string]$Release.ArchiveUrl) $zipPath 32MB
    if ((Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash -ine $Release.Sha256) { throw 'Архив не совпадает с опубликованной контрольной суммой' }
    $package=Get-BoostPackage $zipPath
    if ($package.Version -cne [string]$Release.Version) { throw 'Сервер и архив указывают разные версии' }
    return $zipPath
}
function Get-OnlineBoostUpdate([string]$SourceUrl, [string]$Directory) {
    $release = Get-OnlineBoostRelease $SourceUrl $Directory
    if (-not $release) { return $null }
    return (Save-OnlineBoostRelease $release $Directory)
}
function Select-BoostUpdateArchive {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog=New-Object Windows.Forms.OpenFileDialog
    try {
        $dialog.Filter='BOOST ZIP (*.zip)|*.zip'
        if ($dialog.ShowDialog() -ne 'OK') { return $null }
        return $dialog.FileName
    } finally { $dialog.Dispose() }
}
function Show-PackUpdater {
    if (-not (Test-Unpacked)) { Write-Host '  Сначала распакуй весь комплект в постоянную папку, затем запускай обновление.'; Wait-Key; return $false }
    $parent=Split-Path -Parent $PackDir
    $temp=Join-Path ([IO.Path]::GetTempPath()) ('boost-update-'+[guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($temp)
    try {
        $source=Get-BoostUpdateSource
        $release=$null; $zipPath=$null
        if ($source) {
            Write-Host '  Проверяю обновления...' -ForegroundColor Cyan
            $checked=$false
            try { $release=Get-OnlineBoostRelease $source $temp; $checked=$true }
            catch { Write-Host ('  Не удалось проверить обновления: '+$_.Exception.Message) -ForegroundColor Yellow }
            if ($checked) {
                if (-not $release) { Write-Host '  У тебя актуальная версия.' -ForegroundColor Green; Wait-Key; return $false }
                Write-Host ('  Текущая версия: '+$P3Version+' → новая: '+$release.Version)
                if (-not (Ask 'Скачать и установить обновление?' 'Пак скачает новую версию и откроет её. Старая папка сохранится; оптимизация повторно не применяется.' 'Обновить' 'Отмена' 2)) { return $false }
                Write-Host '  Скачиваю и проверяю комплект...' -ForegroundColor Cyan
                $zipPath=Save-OnlineBoostRelease $release $temp
            }
        } else { Write-Host '  Интернет-источник ещё не подключён.' -ForegroundColor Yellow }
        if (-not $zipPath) {
            if (-not (Ask 'Установить уже скачанный ZIP?' 'Можно вернуться в меню и проверить интернет-обновление позже.' 'Выбрать ZIP' 'Назад' 2)) { return $false }
            $selected=Select-BoostUpdateArchive
            if (-not $selected) { return $false }
            if ((Get-Item -LiteralPath $selected -ErrorAction Stop).Length -gt 32MB) { throw 'Архив превышает допустимый размер 32 МБ' }
            $zipPath=Join-Path $temp 'update.zip'; Copy-Item -LiteralPath $selected -Destination $zipPath -ErrorAction Stop
            $meta=Get-BoostPackage $zipPath
            Write-Host ('  Текущая версия: '+$P3Version+' → новая: '+$meta.Version)
            if ([version]$meta.Version -le [version]$P3Version) { Write-Host '  В архиве нет более новой версии.'; Wait-Key; return $false }
            if (-not (Ask 'Установить обновление?' 'Старая версия останется в своей папке. Оптимизация повторно не применяется.' 'Установить' 'Отмена' 2)) { return $false }
        }
        $newBat=Install-BoostPackage $zipPath $parent $P3Version
        try { New-Shortcut (Join-Path $Desktop 'PLAYSIN BOOST.lnk') $newBat '' (Split-Path -Parent $newBat) '' 'PLAYSIN BOOST — актуальная установленная версия' }
        catch { Write-Host ('  Ярлык не создан. Новая версия: '+$newBat) -ForegroundColor Yellow }
        $args=@()
        if (Test-Path -LiteralPath $StateFile) {
            try { $st=Read-Json $StateFile; if ($st -and -not $st.RolledBack) { $args=@('9') } }
            catch { Write-Host '  Новая версия установлена, но бэкап состояния не прочитан. Служебные скрипты автоматически не обновляются.' -ForegroundColor Yellow }
        }
        $start=@{FilePath=$newBat;ErrorAction='Stop'}; if ($args.Count) { $start.ArgumentList=$args }
        Start-Process @start
        Write-Host ('  Открыта новая версия: '+$newBat+'; предыдущая сохранена: '+$PackDir)
        return $true
    } catch {
        Write-Host ('  Обновление не завершено: '+$_.Exception.Message) -ForegroundColor Yellow
        Write-Host '  Текущий комплект и бэкап настроек сохранены.'
        Wait-Key
        return $false
    } finally { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
}

function Main {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -or -not [Environment]::Is64BitOperatingSystem) {
        Write-Host '  Нужна Windows 10/11 x64.'; return 1
    }
    Set-ConsoleLook
    $choice = 0
    if ($env:P3_ARG -match '^(1|2|4|5|6|7|9|10|12|13|14)$') { $choice = [int]$env:P3_ARG }
    while ($true) {
        if ($choice -eq 0) {
            Show-Banner
            $choice = Ask-Opt 'Что сделать?' 'Проверка ПК не меняет настройки. Автонастройка предлагает набор, который можно поправить.' @('Настроить автоматически', 'Настроить вручную', 'Проверить ПК', 'История и откат', 'Игровой режим', 'Самопроверка', 'Ссылки автора', 'Выход', 'Обновить служебные скрипты из этой версии', 'Параметры игрового режима', 'Программы и гайды', 'Отчёт после перезагрузки — вкл/выкл', 'Обновить сам пак', 'TWEAK CHECK — проверить изменения Windows') 1
        }
        $env:P3_ARG = [string]$choice
        if (@(1, 2, 4, 5, 6, 9, 10, 12, 13) -contains $choice) {
            if (-not (Test-Admin)) { Request-Admin; return 0 }
            if (-not (Test-SameUser)) { return (Stop-Nothing 'Запусти BOOST из своей учётной записи Windows.') }
        }
        switch ($choice) {
            1 {
                $n = Ask-Opt 'Выбери автоматический набор' 'Все блоки можно посмотреть и изменить перед запуском. Приложения и исключения Defender автоматически не выбираются.' @('Сохранить привычную Windows', 'Максимально облегчить фон', 'Игры и стриминг', 'Расширенный максимум 3.0', 'Назад') 1
                if ($n -le 4) {
                    $preset = @('Keep', 'Light', 'Gaming', 'Max')[$n - 1]
                    $mode = 'Rec'; if ($preset -eq 'Max') { $mode = 'Max' }
                    try { return (Invoke-Setup $mode $preset) } finally { Exit-BoostLock }
                }
            }
            2 { try { return (Invoke-Setup 'Manual' 'Keep') } finally { Exit-BoostLock } }
            3 { Show-PcReport }
            4 { Show-BoostHistory }
            5 { Open-BoostTool 'game' }
            6 { Open-BoostTool 'check' }
            7 { Show-BoostLinks }
            8 { return 0 }
            9 { Update-InstalledTools }
            10 { Set-GameOptions }
            11 { Show-ProgramGuides }
            12 { Show-AfterReportOptions }
            13 { if (Show-PackUpdater) { return 0 } }
            14 { Show-TweakChecker }
        }
        $choice = 0
    }
}


if ($env:P3_NOMAIN -ne '1') {
    $code = 1
    try { $code = Main | Select-Object -Last 1 }
    catch {
        Write-Host ''
        try {
            $errorPath = [IO.Path]::Combine([IO.Path]::GetTempPath(), 'PLAYSIN-BOOST-error.txt')
            $details = $_.ToString() + [Environment]::NewLine + $_.InvocationInfo.PositionMessage + [Environment]::NewLine + $_.ScriptStackTrace
            [IO.File]::WriteAllText($errorPath, $details, [Text.Encoding]::UTF8)
            Write-Host ('  Подробности ошибки: ' + $errorPath) -ForegroundColor Yellow
        } catch {}
        Write-Host ('  Непредвиденная ошибка: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host ('  Настройка прервана. Сохрани лог; откат доступен ярлыком «' + $RollbackName + '» или в папке ' + $P3Root + '.') -ForegroundColor Yellow
        Write-LogFile ('[ОШИБ] Прервано: ' + $_.Exception.Message)
        Wait-Key
        $code = 1
    }
    [Environment]::Exit([int]$code)
}
