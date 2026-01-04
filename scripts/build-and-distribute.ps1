<#
.SYNOPSIS
    Builds the Flutter APK and distributes it to Firebase App Distribution.

.DESCRIPTION
    This script automates the full pipeline:
    1. Runs tests (optional)
    2. Builds the release APK
    3. Distributes the APK to Firebase App Distribution using distribute-apk.ps1

.PARAMETER ReleaseNotes
    The release notes for this version. Use @filename to read from a file.

.PARAMETER Groups
    Comma-separated list of tester groups. Defaults to 'testers'.

.PARAMETER SkipTests
    If set, skips running the test suite before building.

.PARAMETER DryRun
    If set, performs a dry run (no actual build or distribution).

.PARAMETER VerboseOutput
    If set, enables debug output.

.EXAMPLE
    .\scripts\build-and-distribute.ps1 -ReleaseNotes "New features added" -Groups "internal-beta"
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$ReleaseNotes = "Manual build from $(Get-Date -Format 'yyyy-MM-dd HH:mm')",

    [Parameter(Mandatory = $false)]
    [string]$Groups = "testers",

    [switch]$SkipTests,
    [switch]$DryRun,
    [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"
$StartTime = Get-Date

Write-Host "=== Starting Build and Distribution Pipeline ===" -ForegroundColor Cyan

# 1. Run Tests
if (-not $SkipTests) {
    Write-Host "`n[Step 1/3] Running tests..." -ForegroundColor Yellow
    if ($DryRun) {
        Write-Host "[DryRun] Would run: .\scripts\ci_all.ps1" -ForegroundColor Gray
    } else {
        try {
            & ".\scripts\ci_all.ps1"
            Write-Host "Tests passed successfully." -ForegroundColor Green
        } catch {
            Write-Error "Tests failed. Aborting pipeline."
            exit 1
        }
    }
} else {
    Write-Host "`n[Step 1/3] Skipping tests as requested." -ForegroundColor Gray
}

# 2. Build APK
Write-Host "`n[Step 2/3] Building Release APK..." -ForegroundColor Yellow
if ($DryRun) {
    Write-Host "[DryRun] Would run: flutter build apk --release" -ForegroundColor Gray
} else {
    try {
        $buildProcess = Start-Process flutter -ArgumentList "build", "apk", "--release" -Wait -PassThru -NoNewWindow
        if ($buildProcess.ExitCode -ne 0) {
            Write-Error "Flutter build failed with exit code $($buildProcess.ExitCode). Aborting pipeline."
            exit 2
        }
        Write-Host "Build completed successfully." -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during build: $_"
        exit 2
    }
}

# 3. Distribute APK
Write-Host "`n[Step 3/3] Distributing APK to Firebase..." -ForegroundColor Yellow
$distArgs = @{}
if ($ReleaseNotes) { $distArgs["ReleaseNotes"] = $ReleaseNotes }
if ($Groups) { $distArgs["Groups"] = $Groups }
if ($DryRun) { $distArgs["DryRun"] = $true }
if ($VerboseOutput) { $distArgs["VerboseOutput"] = $true }

try {
    & ".\scripts\distribute-apk.ps1" @distArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Distribution failed with exit code $LASTEXITCODE."
        exit 3
    }
} catch {
    Write-Error "Distribution failed: $_"
    exit 3
}

$Duration = (Get-Date) - $StartTime
Write-Host "`n=== Pipeline Completed Successfully in $($Duration.Minutes)m $($Duration.Seconds)s ===" -ForegroundColor Cyan
