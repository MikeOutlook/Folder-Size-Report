<#
.SYNOPSIS
Show the total size of each first-level subfolder under a target folder.

.DESCRIPTION
The script accepts an absolute folder path, scans each immediate subfolder,
calculates its recursive size, sorts the result by size, and prints a clean
report with percentages and a simple visual bar.

.PARAMETER Path
Absolute folder path to scan, for example E:\ or C:\Users\Name\Downloads.

.PARAMETER Top
Optional. Show only the largest N entries after sorting.

.PARAMETER IncludeRootFiles
Optional. Include files that are directly under the target folder as a
separate [Root files] entry.

.PARAMETER NoColor
Optional. Disable colored output.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path 'E:\'

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path 'E:\' -Top 15 -IncludeRootFiles
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path,

    [ValidateRange(0, 100000)]
    [int]$Top = 0,

    [switch]$IncludeRootFiles,

    [switch]$NoColor
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Line {
    param(
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )

    if ($NoColor) {
        Write-Host $Text
        return
    }

    Write-Host $Text -ForegroundColor $Color
}

function Format-Size {
    param([long]$Bytes)

    $units = @('B', 'KB', 'MB', 'GB', 'TB', 'PB')
    [double]$size = $Bytes
    $unitIndex = 0

    while ($size -ge 1024 -and $unitIndex -lt ($units.Count - 1)) {
        $size = $size / 1024
        $unitIndex++
    }

    if ($unitIndex -eq 0) {
        return ('{0} {1}' -f [long]$size, $units[$unitIndex])
    }

    return ('{0:N2} {1}' -f $size, $units[$unitIndex])
}

function Shorten-Text {
    param(
        [string]$Text,
        [int]$Width
    )

    if ($null -eq $Text) {
        return ''.PadRight($Width)
    }

    if ($Text.Length -le $Width) {
        return $Text.PadRight($Width)
    }

    if ($Width -le 3) {
        return $Text.Substring(0, $Width)
    }

    return ($Text.Substring(0, $Width - 3) + '...')
}

function New-Bar {
    param(
        [double]$Fraction,
        [int]$Width = 28
    )

    if ($Fraction -lt 0) {
        $Fraction = 0
    }

    if ($Fraction -gt 1) {
        $Fraction = 1
    }

    $filledWidth = [int][Math]::Round($Fraction * $Width, 0, [MidpointRounding]::AwayFromZero)
    if ($filledWidth -gt $Width) {
        $filledWidth = $Width
    }

    $filled = ''
    if ($filledWidth -gt 0) {
        $filled = '#' * $filledWidth
    }

    return $filled.PadRight($Width, '-')
}

function Get-DirectorySizeResult {
    param([System.IO.DirectoryInfo]$Directory)

    [long]$totalBytes = 0
    [int]$skippedItems = 0

    $stack = New-Object 'System.Collections.Generic.Stack[System.IO.DirectoryInfo]'
    $stack.Push($Directory)

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()

        try {
            foreach ($file in $current.EnumerateFiles()) {
                try {
                    $totalBytes += $file.Length
                }
                catch {
                    $skippedItems++
                }
            }
        }
        catch {
            $skippedItems++
        }

        try {
            foreach ($subDirectory in $current.EnumerateDirectories()) {
                try {
                    if (($subDirectory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                        continue
                    }

                    $stack.Push($subDirectory)
                }
                catch {
                    $skippedItems++
                }
            }
        }
        catch {
            $skippedItems++
        }
    }

    return [pscustomobject]@{
        Bytes   = $totalBytes
        Skipped = $skippedItems
    }
}

function Get-DirectFileSizeResult {
    param([System.IO.DirectoryInfo]$Directory)

    [long]$totalBytes = 0
    [int]$skippedItems = 0

    try {
        foreach ($file in $Directory.EnumerateFiles()) {
            try {
                $totalBytes += $file.Length
            }
            catch {
                $skippedItems++
            }
        }
    }
    catch {
        $skippedItems++
    }

    return [pscustomobject]@{
        Bytes   = $totalBytes
        Skipped = $skippedItems
    }
}

if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Read-Host 'Enter an absolute folder path'
}

if ([string]::IsNullOrWhiteSpace($Path)) {
    throw 'A folder path is required.'
}

$Path = $Path.Trim()
$Path = $Path.Trim('"')

if ($Path -match '^[A-Za-z]:$') {
    $Path = $Path + '\'
}

if (-not [System.IO.Path]::IsPathRooted($Path)) {
    throw 'Please provide an absolute path, for example: E:\ or C:\Users\YourName\Downloads'
}

try {
    $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
}
catch {
    throw ('Folder not found: {0}' -f $Path)
}

if (-not (Test-Path -LiteralPath $resolvedPath -PathType Container)) {
    throw ('The path is not a folder: {0}' -f $resolvedPath)
}

$rootDirectory = [System.IO.DirectoryInfo]::new($resolvedPath)
$childDirectories = @(Get-ChildItem -LiteralPath $resolvedPath -Directory -Force -ErrorAction Stop)

if ($childDirectories.Count -eq 0) {
    Write-Line ('=' * 88) ([ConsoleColor]::DarkCyan)
    Write-Line 'Folder Size Report' ([ConsoleColor]::Cyan)
    Write-Line ('Path      : {0}' -f $resolvedPath)
    Write-Line ('Scanned   : 0 folders')
    Write-Line ('Generated : {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
    Write-Line ('=' * 88) ([ConsoleColor]::DarkCyan)
    Write-Line 'No subfolders were found under the target path.' ([ConsoleColor]::Yellow)
    return
}

$results = New-Object System.Collections.Generic.List[object]
$directoryCount = $childDirectories.Count

for ($index = 0; $index -lt $directoryCount; $index++) {
    $childDirectory = $childDirectories[$index]
    $percentComplete = [int](($index / [Math]::Max($directoryCount, 1)) * 100)

    Write-Progress -Activity 'Scanning folder sizes' -Status ('[{0}/{1}] {2}' -f ($index + 1), $directoryCount, $childDirectory.Name) -PercentComplete $percentComplete

    $sizeResult = Get-DirectorySizeResult -Directory $childDirectory

    $results.Add([pscustomobject]@{
            Name    = $childDirectory.Name
            FullName = $childDirectory.FullName
            Bytes   = $sizeResult.Bytes
            Skipped = $sizeResult.Skipped
        })
}

Write-Progress -Activity 'Scanning folder sizes' -Completed

$rootFileResult = $null
if ($IncludeRootFiles) {
    $rootFileResult = Get-DirectFileSizeResult -Directory $rootDirectory

    if ($rootFileResult.Bytes -gt 0) {
        $results.Add([pscustomobject]@{
                Name    = '[Root files]'
                FullName = $resolvedPath
                Bytes   = $rootFileResult.Bytes
                Skipped = $rootFileResult.Skipped
            })
    }
}

$sortedResults = @($results | Sort-Object -Property @{ Expression = 'Bytes'; Descending = $true }, @{ Expression = 'Name'; Descending = $false })
$allResults = $sortedResults

if ($Top -gt 0) {
    $sortedResults = @($sortedResults | Select-Object -First $Top)
}

$totalBytes = ($allResults | Measure-Object -Property Bytes -Sum).Sum
if ($null -eq $totalBytes) {
    $totalBytes = 0
}

$maxNameLength = (($sortedResults | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum)
if ($null -eq $maxNameLength) {
    $maxNameLength = 10
}

$nameWidth = [Math]::Max(18, [Math]::Min(38, $maxNameLength + 2))
$rankWidth = 4
$sizeWidth = 12
$shareWidth = 7
$barWidth = 28
$separator = ('=' * 88)

$totalSkipped = ($allResults | Measure-Object -Property Skipped -Sum).Sum
if ($null -eq $totalSkipped) {
    $totalSkipped = 0
}

Write-Line $separator ([ConsoleColor]::DarkCyan)
Write-Line 'Folder Size Report' ([ConsoleColor]::Cyan)
Write-Line ('Path      : {0}' -f $resolvedPath)
Write-Line ('Scanned   : {0} folders' -f $directoryCount)
if ($Top -gt 0 -and $Top -lt $allResults.Count) {
    Write-Line ('Showing   : Top {0} folders' -f $Top)
}
Write-Line ('Total size: {0}' -f (Format-Size -Bytes $totalBytes))
Write-Line ('Generated : {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
if ($totalSkipped -gt 0) {
    Write-Line ('Notice    : {0} inaccessible item(s) were skipped.' -f $totalSkipped) ([ConsoleColor]::Yellow)
}
Write-Line $separator ([ConsoleColor]::DarkCyan)

$header = ('{0}  {1}  {2}  {3}  {4}' -f
    '#'.PadRight($rankWidth),
    'Folder'.PadRight($nameWidth),
    'Size'.PadLeft($sizeWidth),
    'Share'.PadLeft($shareWidth),
    'Visual')
Write-Line $header ([ConsoleColor]::White)
Write-Line ('-' * $header.Length) ([ConsoleColor]::DarkGray)

for ($index = 0; $index -lt $sortedResults.Count; $index++) {
    $item = $sortedResults[$index]
    if ($totalBytes -gt 0) {
        $share = $item.Bytes / [double]$totalBytes
    }
    else {
        $share = 0
    }

    $sizeText = Format-Size -Bytes $item.Bytes
    $shareText = ('{0,6:N1}%' -f ($share * 100))
    $barText = New-Bar -Fraction $share -Width $barWidth

    $row = ('{0}  {1}  {2}  {3}  {4}' -f
        ($index + 1).ToString().PadLeft($rankWidth),
        (Shorten-Text -Text $item.Name -Width $nameWidth),
        $sizeText.PadLeft($sizeWidth),
        $shareText.PadLeft($shareWidth),
        $barText)

    if ($NoColor) {
        Write-Host $row
        continue
    }

    if ($index -eq 0) {
        Write-Host $row -ForegroundColor Green
    }
    elseif ($share -ge 0.2) {
        Write-Host $row -ForegroundColor Yellow
    }
    else {
        Write-Host $row
    }
}

Write-Line $separator ([ConsoleColor]::DarkCyan)
