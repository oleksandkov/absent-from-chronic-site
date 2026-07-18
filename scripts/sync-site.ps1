[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Source,

    [string]$Destination = (Join-Path $PSScriptRoot "..\_site"),

    [switch]$Apply,

    [switch]$AllowDelete
)

$ErrorActionPreference = "Stop"

function Resolve-Directory([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label directory does not exist: $Path"
    }

    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\', '/')
}

function Get-SiteInventory([string]$Root) {
    $inventory = @{}
    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($Root.Length + 1).Replace('\', '/')
        $inventory[$relativePath] = [pscustomobject]@{
            FullName = $_.FullName
            Hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            Length = $_.Length
        }
    }
    return $inventory
}

$sourceRoot = Resolve-Directory $Source "Source"
$destinationRoot = Resolve-Directory $Destination "Destination"

if ($sourceRoot -eq $destinationRoot) {
    throw "Source and destination must be different directories."
}

$requiredFiles = @("index.html", "content/index.html", "search.json")
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $relativePath) -PathType Leaf)) {
        throw "Source is not a complete generated site; missing $relativePath"
    }
}

$forbiddenFiles = Get-ChildItem -LiteralPath $sourceRoot -Recurse -File | Where-Object {
    $_.Extension -in @(".R", ".Rmd", ".qmd", ".parquet", ".sqlite", ".db") -or
    $_.FullName -match '[\\/](data-private|_cache|\.git)([\\/]|$)'
}
if ($forbiddenFiles) {
    $paths = ($forbiddenFiles.FullName | ForEach-Object { $_.Substring($sourceRoot.Length + 1) }) -join ", "
    throw "Source contains files that must not be published: $paths"
}

$privateReferences = Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Include *.html,*.json,*.css,*.js |
    Select-String -SimpleMatch "data-private" |
    Select-Object -First 10
if ($privateReferences) {
    $locations = ($privateReferences | ForEach-Object {
        "$($_.Path.Substring($sourceRoot.Length + 1)):$($_.LineNumber)"
    }) -join ", "
    Write-Warning "Generated site contains textual data-private references. Review if unexpected: $locations"
}

$sourceFiles = Get-SiteInventory $sourceRoot
$destinationFiles = Get-SiteInventory $destinationRoot

$added = @($sourceFiles.Keys | Where-Object { -not $destinationFiles.ContainsKey($_) } | Sort-Object)
$changed = @($sourceFiles.Keys | Where-Object {
    $destinationFiles.ContainsKey($_) -and $sourceFiles[$_].Hash -ne $destinationFiles[$_].Hash
} | Sort-Object)
$deleted = @($destinationFiles.Keys | Where-Object { -not $sourceFiles.ContainsKey($_) } | Sort-Object)

Write-Output "Source:      $sourceRoot"
Write-Output "Destination: $destinationRoot"
Write-Output "Added:       $($added.Count)"
Write-Output "Changed:     $($changed.Count)"
Write-Output "Deleted:     $($deleted.Count)"

foreach ($relativePath in $added) { Write-Output "ADD    $relativePath" }
foreach ($relativePath in $changed) { Write-Output "CHANGE $relativePath" }
foreach ($relativePath in $deleted) { Write-Output "DELETE $relativePath" }

if (-not $Apply) {
    Write-Output "Dry run only. Re-run with -Apply to synchronize."
    exit 0
}

if ($deleted.Count -gt 0 -and -not $AllowDelete) {
    throw "The sync would delete $($deleted.Count) file(s). Review the dry run and use -AllowDelete if intentional."
}

foreach ($relativePath in @($added) + @($changed)) {
    $destinationPath = Join-Path $destinationRoot $relativePath
    $destinationDirectory = Split-Path $destinationPath -Parent
    if (-not (Test-Path -LiteralPath $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }
    Copy-Item -LiteralPath $sourceFiles[$relativePath].FullName -Destination $destinationPath -Force
}

foreach ($relativePath in $deleted) {
    Remove-Item -LiteralPath (Join-Path $destinationRoot $relativePath) -Force
}

$remainingDifferences = & $PSCommandPath -Source $sourceRoot -Destination $destinationRoot
if ($LASTEXITCODE -ne 0 -or $remainingDifferences -notcontains "Added:       0" -or
    $remainingDifferences -notcontains "Changed:     0" -or $remainingDifferences -notcontains "Deleted:     0") {
    throw "Post-sync hash verification failed."
}

Write-Output "Sync complete. Source and destination hashes match."