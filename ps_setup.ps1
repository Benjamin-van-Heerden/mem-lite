#Requires -Version 5.1
param(
    [switch]$Update
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/Benjamin-van-Heerden/mem-lite.git"
$CloneDir = Join-Path $env:TEMP "mem-lite-setup-$PID"
$TargetDir = Get-Location
$CoreEndTag = "</core_instructions>"

# Clone the repo
Write-Host "[*] Fetching latest mem-lite templates..."
git clone --depth 1 --quiet $RepoUrl $CloneDir

$TemplateAgents = Join-Path $CloneDir "AGENTS.md"
$TemplateCommands = Join-Path (Join-Path $CloneDir "agent_rules") "commands"

try {

function Prompt-WithDefault {
    param(
        [string]$Message,
        [string]$Default
    )
    $result = Read-Host "$Message [$Default]"
    if ([string]::IsNullOrWhiteSpace($result)) { return $Default }
    return $result
}

function Render-Template {
    param([string]$Content)
    $Content = $Content -replace '\$dev_branch', $script:DevBranch
    $Content = $Content -replace '\$prod_branch', $script:ProdBranch
    $Content = $Content -replace '\$test_branch', $script:TestBranch
    return $Content
}

function Detect-Branches {
    $script:DevBranch = "dev"
    $script:ProdBranch = "main"
    $script:TestBranch = "test"

    $agentsPath = Join-Path $TargetDir "AGENTS.md"
    foreach ($line in (Get-Content $agentsPath)) {
        $stripped = $line.Trim()
        if (-not $stripped.StartsWith("- ``")) { continue }
        if ($stripped -match '`([^`]+)`') {
            $branch = $Matches[1]
        } else {
            continue
        }
        if ($stripped -like "*the main working branch*") {
            $script:DevBranch = $branch
        } elseif ($stripped -like "*production branch*") {
            $script:ProdBranch = $branch
        } elseif ($stripped -like "*test/staging branch*") {
            $script:TestBranch = $branch
        }
    }
}

function Ensure-GitignoreEntry {
    param([string]$Entry)
    $gitignore = Join-Path $TargetDir ".gitignore"
    if (Test-Path $gitignore) {
        $content = Get-Content $gitignore -Raw
        if ($content -split "`n" | Where-Object { $_.Trim() -eq $Entry }) {
            return $false
        }
        Add-Content $gitignore "`n$Entry"
    } else {
        Set-Content $gitignore $Entry
    }
    return $true
}

function Create-Directories {
    $dirs = @(
        "agent_rules/commands"
        "agent_rules/docs"
        "agent_rules/docs/core"
        "agent_rules/spec"
        "agent_rules/spec/completed"
        "agent_rules/spec/abandoned"
        "agent_rules/log"
        "agent_rules/memories"
        "agent_rules/todos"
        "agent_rules/todos/claimed"
        "agent_rules/tmp"
    )
    foreach ($dir in $dirs) {
        $path = Join-Path $TargetDir $dir
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
}

function Copy-Commands {
    $script:CommandChanges = @()
    $srcFiles = Get-ChildItem -Path $TemplateCommands -Filter "*.md" | Sort-Object Name

    foreach ($srcFile in $srcFiles) {
        $content = Get-Content $srcFile.FullName -Raw
        $rendered = Render-Template $content
        $dstFile = Join-Path (Join-Path $TargetDir "agent_rules") "commands" | Join-Path -ChildPath $srcFile.Name

        if ($Update) {
            if (Test-Path $dstFile) {
                $current = Get-Content $dstFile -Raw
                if ($current -eq $rendered) { continue }
                $script:CommandChanges += "Updated: agent_rules/commands/$($srcFile.Name)"
            } else {
                $script:CommandChanges += "Added: agent_rules/commands/$($srcFile.Name)"
            }
        }

        Set-Content -Path $dstFile -Value $rendered -NoNewline
        if (-not $Update) {
            Write-Host "  [+] agent_rules/commands/$($srcFile.Name)"
        }
    }

    if ($Update) {
        # Remove commands that no longer exist in templates
        $existingFiles = Get-ChildItem -Path (Join-Path (Join-Path $TargetDir "agent_rules") "commands") -Filter "*.md" -ErrorAction SilentlyContinue
        foreach ($existing in $existingFiles) {
            if (-not (Test-Path (Join-Path $TemplateCommands $existing.Name))) {
                Remove-Item $existing.FullName
                $script:CommandChanges += "Removed (no longer in template): agent_rules/commands/$($existing.Name)"
            }
        }

        foreach ($change in $script:CommandChanges) {
            Write-Host "  - $change"
        }
    }
}

function Setup-AgentsMd {
    $agentsFile = Join-Path $TargetDir "AGENTS.md"
    $templateContent = Get-Content $TemplateAgents -Raw
    $rendered = Render-Template $templateContent

    if ($Update) {
        $existing = Get-Content $agentsFile -Raw
        $userContent = ""
        $endIdx = $existing.IndexOf($CoreEndTag)
        if ($endIdx -ge 0) {
            $userContent = $existing.Substring($endIdx + $CoreEndTag.Length)
        }
        $newAgents = $rendered
        if ($userContent.Trim().Length -gt 0) {
            $newAgents = "$rendered`n$userContent"
        }
        if ($existing -ne $newAgents) {
            Set-Content -Path $agentsFile -Value $newAgents -NoNewline
            Write-Host "  - Updated: AGENTS.md (core instructions)"
            $script:AgentsChanged = $true
        }
    } else {
        $existingUserContent = ""
        if (Test-Path $agentsFile) {
            $existingUserContent = Get-Content $agentsFile -Raw
            Write-Host ""
            Write-Host "[*] Existing AGENTS.md found -- appending your content after core instructions"
            $rendered = "$rendered`n$existingUserContent"
        }
        Set-Content -Path $agentsFile -Value $rendered -NoNewline
        Write-Host "  [+] AGENTS.md"
    }
}

function Setup-ClaudeFile {
    $claudeFile = Join-Path $TargetDir "CLAUDE.md"
    $agentsFile = Join-Path $TargetDir "AGENTS.md"
    if (-not (Test-Path $claudeFile)) {
        Copy-Item $agentsFile $claudeFile
        if ($Update) {
            Write-Host "  - Created: CLAUDE.md (copy of AGENTS.md)"
            $script:ClaudeChanged = $true
        } else {
            Write-Host "  [+] CLAUDE.md (copy of AGENTS.md)"
        }
    } elseif ($Update -and $script:AgentsChanged) {
        Copy-Item $agentsFile $claudeFile -Force
        Write-Host "  - Updated: CLAUDE.md (re-copied from AGENTS.md)"
        $script:ClaudeChanged = $true
    } elseif (-not $Update) {
        Write-Host "  [+] CLAUDE.md already exists"
    }
}

function Create-PlaceholderFiles {
    $script:PlaceholderChanges = @()
    $placeholders = @{
        "project_description.md" = "TODO: Describe your project here"
        "project_actions.md"     = "TODO: Add project-specific onboarding actions here"
    }
    foreach ($filename in $placeholders.Keys) {
        $filepath = Join-Path $TargetDir "agent_rules" $filename
        if (-not (Test-Path $filepath)) {
            Set-Content -Path $filepath -Value $placeholders[$filename]
            if ($Update) {
                $script:PlaceholderChanges += "Created: agent_rules/$filename"
            } else {
                Write-Host "  [+] agent_rules/$filename"
            }
        }
    }

    if ($Update) {
        foreach ($change in $script:PlaceholderChanges) {
            Write-Host "  - $change"
        }
    }
}

function Flatten-Logs {
    $logDir = Join-Path (Join-Path $TargetDir "agent_rules") "log"
    if (-not (Test-Path $logDir)) { return }

    $subdirs = Get-ChildItem -Path $logDir -Directory -ErrorAction SilentlyContinue
    foreach ($subdir in $subdirs) {
        $logFiles = Get-ChildItem -Path $subdir.FullName -Filter "*.md" -ErrorAction SilentlyContinue
        foreach ($logFile in $logFiles) {
            $dest = Join-Path $logDir $logFile.Name
            if (-not (Test-Path $dest)) {
                Move-Item $logFile.FullName $dest
                Write-Host "  - Moved: agent_rules/log/$($subdir.Name)/$($logFile.Name) -> agent_rules/log/$($logFile.Name)"
            } else {
                Remove-Item $logFile.FullName
                Write-Host "  - Removed duplicate: agent_rules/log/$($subdir.Name)/$($logFile.Name)"
            }
        }
        if ((Get-ChildItem $subdir.FullName | Measure-Object).Count -eq 0) {
            Remove-Item $subdir.FullName
            Write-Host "  - Removed empty directory: agent_rules/log/$($subdir.Name)/"
        }
    }
}

# ── Main ──

if ($Update) {
    $agentsPath = Join-Path $TargetDir "AGENTS.md"
    $commandsPath = Join-Path (Join-Path $TargetDir "agent_rules") "commands"

    if (-not (Test-Path $agentsPath) -or -not (Test-Path $commandsPath)) {
        Write-Host "[!] mem light is not initialized here. Run this script without -Update first."
        exit 1
    }

    Detect-Branches

    $script:AgentsChanged = $false
    $script:ClaudeChanged = $false
    $script:CommandChanges = @()
    $script:PlaceholderChanges = @()
    $gitignoreChanged = $false

    Write-Host ""
    Copy-Commands
    Flatten-Logs
    Create-Directories
    if (Ensure-GitignoreEntry "agent_rules/tmp/") {
        Write-Host "  - Updated: .gitignore (added agent_rules/tmp/)"
        $gitignoreChanged = $true
    }
    Create-PlaceholderFiles
    Setup-AgentsMd
    Setup-ClaudeFile

    if ($script:CommandChanges.Count -eq 0 -and
        $script:PlaceholderChanges.Count -eq 0 -and
        -not $script:AgentsChanged -and
        -not $script:ClaudeChanged -and
        -not $gitignoreChanged) {
        Write-Host "[OK] Mem light is up to date. No changes needed."
    } else {
        Write-Host ""
        Write-Host "[OK] Update complete."
    }
} else {
    $agentsPath = Join-Path $TargetDir "AGENTS.md"
    $commandsPath = Join-Path (Join-Path $TargetDir "agent_rules") "commands"

    if ((Test-Path $agentsPath) -and (Test-Path $commandsPath)) {
        Write-Host "[!] mem light appears to already be initialized here."
        Write-Host "Use -Update to update existing files."
        exit 1
    }

    # Show branches
    try {
        $branches = git branch --format='%(refname:short)' 2>$null
    } catch {
        $branches = @()
    }
    if ($branches) {
        Write-Host ""
        Write-Host "Existing branches:"
        foreach ($branch in $branches) {
            Write-Host "  - $branch"
        }
        Write-Host ""
    }

    $script:DevBranch = Prompt-WithDefault "Which branch is your development branch?" "dev"

    if ($branches -notcontains $script:DevBranch) {
        $createIt = Read-Host "Branch '$($script:DevBranch)' doesn't exist. Create it? [Y/n]"
        if ([string]::IsNullOrWhiteSpace($createIt) -or $createIt -match '^[Yy]$') {
            git switch -c $script:DevBranch
            Write-Host "[+] Created and switched to branch '$($script:DevBranch)'"
        } else {
            Write-Host "[!] Cannot proceed without a development branch."
            exit 1
        }
    }

    $script:ProdBranch = Prompt-WithDefault "Which branch is your production branch?" "main"
    $script:TestBranch = Prompt-WithDefault "Which branch is your test/staging branch?" "test"

    Write-Host ""
    Write-Host "[*] Creating agent_rules/ directory..."
    Create-Directories
    Copy-Commands
    Ensure-GitignoreEntry "agent_rules/tmp/" | Out-Null
    Create-PlaceholderFiles
    Setup-AgentsMd
    Setup-ClaudeFile

    Write-Host ""
    Write-Host "[OK] mem light initialized with dev branch: $($script:DevBranch)"
    Write-Host ""
    Write-Host "Start a session with: 'Get onboarded' or 'Let''s get to work'"
}

} finally {
    # Clean up the cloned repo
    if (Test-Path $CloneDir) {
        Remove-Item -Recurse -Force $CloneDir
    }
}
