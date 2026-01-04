<#
.SYNOPSIS
    Distributes APK to Firebase App Distribution

.DESCRIPTION
    Uploads an APK file to Firebase App Distribution for testing.
    Auto-detects APK path and Firebase app ID if not provided.

.PARAMETER ApkPath
    Path to APK file. If empty, auto-detects from build/app/outputs/flutter-apk/app-release.apk

.PARAMETER AppId
    Firebase app ID. If empty, extracts from firebase.json

.PARAMETER ReleaseNotes
    Release notes text or file path (prefix with @ for file: @CHANGELOG.md)

.PARAMETER Groups
    Comma-separated tester group aliases (default: internal-testers)

.PARAMETER DryRun
    Preview actions without executing upload

.PARAMETER VerboseOutput
    Enable verbose Firebase CLI output

.EXAMPLE
    .\distribute-apk.ps1
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ApkPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$AppId = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ReleaseNotes = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Groups = "internal-testers",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"
$StartTime = Get-Date

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Write-Step {
    param(
        [int]$Step,
        [int]$Total,
        [string]$Message
    )
    Write-Host "`n[Step $Step/$Total] $Message..." -ForegroundColor Cyan
}

function Test-FirebaseCli {
    Write-Log "Checking Firebase CLI installation..."
    try {
        $null = firebase --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Firebase CLI is installed" "SUCCESS"
            return $true
        }
    }
    catch {
        Write-Log "Firebase CLI not found" "ERROR"
        Write-Log "Install: npm install -g firebase-tools" "ERROR"
        return $false
    }
    return $false
}

function Test-FirebaseAuth {
    Write-Log "Checking Firebase authentication..."
    if ($env:FIREBASE_TOKEN) {
        Write-Log "Using FIREBASE_TOKEN from environment" "SUCCESS"
        return $true
    }
    
    try {
        $null = firebase login:list 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Authenticated with Firebase" "SUCCESS"
            return $true
        }
    }
    catch {
        Write-Log "Firebase authentication required" "ERROR"
        Write-Log "Run: firebase login" "ERROR"
        return $false
    }
    return $false
}
    
function Get-ApkPath {
    param([string]$CustomPath)
    
    Write-Log "Resolving APK path..."
    if ($CustomPath -and (Test-Path $CustomPath)) {
        Write-Log "Using custom APK: $CustomPath" "SUCCESS"
        return $CustomPath
    }
    
    $defaultPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $defaultPath) {
        Write-Log "Found APK: $defaultPath" "SUCCESS"
        return $defaultPath
    }
    
    Write-Log "APK not found at: $defaultPath" "ERROR"
    Write-Log "Build APK first: flutter build apk --release" "ERROR"
    exit 3
}

function Get-FirebaseAppId {
    param([string]$CustomAppId)
    
    Write-Log "Resolving Firebase app ID..."
    if ($CustomAppId) {
        Write-Log "Using custom app ID: $CustomAppId" "SUCCESS"
        return $CustomAppId
    }
    
    # 1. Try firebase.json (supports multiple FlutterFire CLI structures)
    if (Test-Path "firebase.json") {
        try {
            $json = Get-Content "firebase.json" -Raw | ConvertFrom-Json
            $appId = $null
            
            if ($json.flutter.dart."lib/firebase_options.dart".platforms.android.appId) {
                $appId = $json.flutter.dart."lib/firebase_options.dart".platforms.android.appId
            }
            elseif ($json.flutter.dart."lib/firebase_options.dart".android.appId) {
                $appId = $json.flutter.dart."lib/firebase_options.dart".android.appId
            }
            elseif ($json.flutter.platforms.android.default.appId) {
                $appId = $json.flutter.platforms.android.default.appId
            }

            if ($appId) {
                Write-Log "Extracted app ID from firebase.json: $appId" "SUCCESS"
                return $appId
            }
        }
        catch {
            Write-Log "Warning: Failed to parse firebase.json" "WARNING"
        }
    }

    # 2. Fallback: google-services.json (Standard Android Firebase config)
    $gsPath = "android/app/google-services.json"
    if (Test-Path $gsPath) {
        try {
            $gs = Get-Content $gsPath -Raw | ConvertFrom-Json
            $appId = $gs.client[0].client_info.mobilesdk_app_id
            if ($appId) {
                Write-Log "Extracted app ID from google-services.json: $appId" "SUCCESS"
                return $appId
            }
        }
        catch {
            Write-Log "Warning: Failed to parse google-services.json" "WARNING"
        }
    }
    
    Write-Log "Firebase App ID not found. Provide it via -AppId or check configuration files." "ERROR"
    exit 4
}

function Invoke-WithRetry {
    param(
        [scriptblock]$Command,
        [int]$MaxRetries = 3,
        [int]$InitialDelay = 5
    )
    
    $attempt = 1
    $delay = $InitialDelay
    
    while ($attempt -le $MaxRetries) {
        if ($attempt -gt 1) {
            Write-Log "Retry attempt $attempt/$MaxRetries..." "WARNING"
        }
        
        try {
            & $Command
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
            throw "Command failed with exit code $LASTEXITCODE"
        }
        catch {
            $errorMsg = $_.Exception.Message
            if ($attempt -lt $MaxRetries) {
                Write-Log "Error: $errorMsg - waiting $delay seconds..." "WARNING"
                Start-Sleep -Seconds $delay
                $delay *= 2
                $attempt++
            }
            else {
                Write-Log "Max retries reached. Last error: $errorMsg" "ERROR"
                exit 5
            }
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Firebase APK Distribution" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Validate prerequisites
Write-Step 1 5 "Validating prerequisites"
if (-not (Test-FirebaseCli)) { exit 1 }
if (-not (Test-FirebaseAuth)) { exit 2 }

# Step 2: Resolve APK path
Write-Step 2 5 "Resolving APK path"
$resolvedApkPath = Get-ApkPath -CustomPath $ApkPath

# Validate APK file
$apkFile = Get-Item $resolvedApkPath
if ($apkFile.Length -eq 0) {
    Write-Log "APK file is empty" "ERROR"
    exit 3
}

# Step 3: Extract Firebase app ID
Write-Step 3 5 "Extracting Firebase app ID"
$resolvedAppId = Get-FirebaseAppId -CustomAppId $AppId

# Step 4: Build Firebase command
Write-Step 4 5 "Preparing distribution command"

$firebaseCmd = "firebase appdistribution:distribute `"$resolvedApkPath`""
$firebaseCmd += " --app `"$resolvedAppId`""
# $firebaseCmd += " --groups `"$Groups`""

if ($ReleaseNotes) {
    if ($ReleaseNotes.StartsWith("@")) {
        $notesFile = $ReleaseNotes.Substring(1)
        if (Test-Path $notesFile) {
            $firebaseCmd += " --release-notes-file `"$notesFile`""
            Write-Log "Release notes from file: $notesFile" "SUCCESS"
        }
        else {
            $firebaseCmd += " --release-notes `"Release notes file not found`""
        }
    }
    else {
        $firebaseCmd += " --release-notes `"$ReleaseNotes`""
    }
}

if ($env:FIREBASE_TOKEN) {
    $firebaseCmd += " --token `"$env:FIREBASE_TOKEN`""
}

if ($VerboseOutput) {
    $firebaseCmd += " --debug"
}

Write-Log "Target groups: $Groups"

if ($DryRun) {
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "  DRY RUN MODE - Preview Only" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow
    Write-Host "Would execute:" -ForegroundColor Yellow
    Write-Host $firebaseCmd -ForegroundColor Gray
    Write-Host "`nNo upload performed`n" -ForegroundColor Yellow
    exit 0
}

# Step 5: Execute upload with retry
Write-Step 5 5 "Uploading to Firebase App Distribution"
Write-Log "Starting upload... (this may take a few minutes)"

Invoke-WithRetry -Command {
    Invoke-Expression $firebaseCmd
}

$duration = (Get-Date) - $StartTime
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Distribution Successful!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
Write-Host "Duration: $($duration.TotalSeconds) seconds" -ForegroundColor Gray
Write-Host "Testers will receive notification shortly.`n" -ForegroundColor Green

exit 0
