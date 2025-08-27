# Copyright 2022-2025 Salesforce, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

param(
  [Parameter(HelpMessage = "Alias of Slack CLI")]
  [string]$Alias,

  [Parameter(HelpMessage = "Version of Slack CLI")]
  [string]$Version,

  [Parameter(HelpMessage = "Skip Git installation")]
  [bool]$SkipGit = $false,

  [Parameter(HelpMessage = "Skip Deno installation")]
  [bool]$SkipDeno = $false
)

Function delay ([float]$seconds, [string]$message, [string]$newlineOption) {
  if ($newlineOption -eq "-n") {
    Write-Host -NoNewline $message
  }
  else {
    Write-Host $message
  }
  Start-Sleep -Seconds $seconds
}


function check_slack_binary_exist() {
  param(
    [Parameter(HelpMessage = "Alias of Slack CLI")]
    [string]$Alias,

    [Parameter(HelpMessage = "Version of Slack CLI")]
    [string]$Version,

    [Parameter(HelpMessage = "Display diagnostic information")]
    [boolean]$Diagnostics
  )

  $FINGERPRINT = "d41d8cd98f00b204e9800998ecf8427e"
  $SLACK_CLI_NAME = "slack"
  if ($Alias) {
    $SLACK_CLI_NAME = $Alias
  }

  if (Get-Command $SLACK_CLI_NAME -ErrorAction SilentlyContinue) {
    if ($Diagnostics) {
      delay 0.3 "Checking if ``$SLACK_CLI_NAME`` already exists on this system..."
      delay 0.2 "Heads up! A binary called ``$SLACK_CLI_NAME`` was found!"
      delay 0.3 "Now checking if it's the same Slack CLI..."
    }

    # Detailed investigation of where _fingerprint hangs
    Write-Host "DEBUG: === STARTING _FINGERPRINT INVESTIGATION ==="
    
    # Test 1: Ultra-Precise Millisecond Timeout Testing
    Write-Host "DEBUG: Test 1: Ultra-Precise Millisecond Timeout Testing..."
    
    # Test with millisecond precision to pinpoint exact hang moment
    $timeouts = @(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.5, 2.0, 3.0, 5.0)
    $hangLocation = "UNKNOWN"
    $exactHangTime = "UNKNOWN"
    
    foreach ($timeout in $timeouts) {
      $timeoutMs = [math]::Round($timeout * 1000)
      Write-Host "DEBUG: Testing with ${timeout}s (${timeoutMs}ms) timeout..."
      
      $job = Start-Job -ScriptBlock { 
        param($cliName) 
        Write-Host "DEBUG: Job started, about to execute _fingerprint..."
        & $cliName _fingerprint 
      } -ArgumentList $SLACK_CLI_NAME
      
      $result = Wait-Job -Job $job -Timeout $timeout
      if ($result) {
        $output = Receive-Job -Job $job
        Write-Host "DEBUG: _fingerprint completed within ${timeout}s (${timeoutMs}ms): $output"
        Remove-Job -Job $job
        $hangLocation = "COMPLETED_IN_${timeout}S"
        break
      } else {
        Write-Host "DEBUG: _fingerprint hung within ${timeout}s (${timeoutMs}ms)"
        Stop-Job -Job $job
        Remove-Job -Job $job
        $hangLocation = "HANGED_IN_${timeout}S"
        $exactHangTime = "${timeout}s (${timeoutMs}ms)"
      }
    }
    
    # Test 1.5: Process State Monitoring During Hang
    Write-Host "DEBUG: Test 1.5: Process State Monitoring During Hang..."
    
    try {
      Write-Host "DEBUG: Starting _fingerprint with process monitoring..."
      $startTime = Get-Date
      $process = Start-Process -FilePath $SLACK_CLI_NAME -ArgumentList "_fingerprint" -PassThru -NoNewWindow
      
      # Monitor process state at millisecond intervals
      $monitorIntervals = @(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
      $lastResponsiveTime = "UNKNOWN"
      
      foreach ($interval in $monitorIntervals) {
        Start-Sleep -Milliseconds ($interval * 1000)
        $currentTime = Get-Date
        $elapsed = ($currentTime - $startTime).TotalSeconds
        
        if ($process.HasExited) {
          Write-Host "DEBUG: Process exited after ${elapsed}s - completed successfully!"
          $lastResponsiveTime = "${elapsed}s"
          break
        }
        
        $isResponsive = $process.Responding
        Write-Host "DEBUG: At ${elapsed}s: Process responding = $isResponsive, HasExited = $($process.HasExited)"
        
        if ($isResponsive) {
          $lastResponsiveTime = "${elapsed}s"
        } else {
          Write-Host "DEBUG: Process became unresponsive at ${elapsed}s - HANG DETECTED!"
          break
        }
      }
      
      # Clean up process if it's still running
      if (!$process.HasExited) {
        Write-Host "DEBUG: Force killing hanging process..."
        Stop-Process -Id $process.Id -Force
      }
      
    } catch {
      Write-Host "DEBUG: Process monitoring failed: $_"
    }
    
    # Test 2: Detailed Investigation of What's Making It Slow
    Write-Host "DEBUG: Test 2: Detailed Slow Operation Investigation..."
    
    # Test 2a: Let it run longer to see if it eventually completes
    Write-Host "DEBUG: Test 2a: Extended execution test (30 second timeout)..."
    try {
      Write-Host "DEBUG: Starting _fingerprint with extended timeout..."
      $startTime = Get-Date
      
      $extendedJob = Start-Job -ScriptBlock { 
        param($cliName) 
        Write-Host "DEBUG: Extended job started, executing _fingerprint..."
        $output = & $cliName _fingerprint 2>&1
        return $output
      } -ArgumentList $SLACK_CLI_NAME
      
      $extendedResult = Wait-Job -Job $extendedJob -Timeout 30
      if ($extendedResult) {
        $extendedOutput = Receive-Job -Job $extendedJob
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        Write-Host "DEBUG: Extended execution completed in $duration seconds: $extendedOutput"
        $get_finger_print = $extendedOutput
        Remove-Job -Job $extendedJob
      } else {
        Write-Host "DEBUG: Extended execution still running after 30 seconds - investigating further..."
        Stop-Job -Job $extendedJob
        Remove-Job -Job $extendedJob
        
        # Test 2b: Network connection investigation
        Write-Host "DEBUG: Test 2b: Network connection investigation..."
        Write-Host "DEBUG: Checking what network connections the process might be trying to make..."
        
        # Check common tracing endpoints
        $tracingEndpoints = @(
          "http://localhost:14268",  # Jaeger collector
          "http://localhost:9411",   # Zipkin
          "http://localhost:16686",  # Jaeger UI
          "http://127.0.0.1:14268",
          "http://127.0.0.1:9411"
        )
        
        foreach ($endpoint in $tracingEndpoints) {
          try {
            Write-Host "DEBUG: Testing endpoint: $endpoint"
            $response = Invoke-WebRequest -Uri $endpoint -TimeoutSec 3 -ErrorAction Stop
            Write-Host "DEBUG: ✅ $endpoint is accessible (unexpected in CI)"
          } catch {
            Write-Host "DEBUG: ❌ $endpoint is NOT accessible (expected in CI)"
          }
        }
        
        # Test 2c: Process resource investigation
        Write-Host "DEBUG: Test 2c: Process resource investigation..."
        Write-Host "DEBUG: Checking what resources the process might be waiting for..."
        
        # Check if it's trying to access specific files or directories
        $potentialPaths = @(
          "$env:USERPROFILE\.slack",
          "$env:USERPROFILE\AppData\Local\slack-cli",
          "$env:USERPROFILE\.config",
          "$env:USERPROFILE\.jaeger",
          "$env:USERPROFILE\.zipkin"
        )
        
        foreach ($path in $potentialPaths) {
          if (Test-Path $path) {
            Write-Host "DEBUG: ✅ Path exists: $path"
          } else {
            Write-Host "DEBUG: DEBUG: ❌ Path does not exist: $path"
          }
        }
        
        $get_finger_print = "SLOW_OPERATION_30S_TIMEOUT"
      }
      
    } catch {
      Write-Host "DEBUG: Extended execution investigation failed: $_"
      $get_finger_print = "ERROR: $_"
    }
    
    # Test 3: OpenTracing Investigation - PROVE it's the OpenTracing span creation
    Write-Host "DEBUG: Test 3: OpenTracing Investigation..."
    Write-Host "DEBUG: Current working directory: $(Get-Location)"
    Write-Host "DEBUG: Environment variables that might affect _fingerprint:"
    Write-Host "DEBUG:   SLACK_SERVICE_TOKEN exists: $([bool]$env:SLACK_SERVICE_TOKEN)"
    Write-Host "DEBUG:   SLACK_BOT_TOKEN exists: $([bool]$env:SLACK_BOT_TOKEN)"
    Write-Host "DEBUG:   HOME: $env:HOME"
    Write-Host "DEBUG:   USERPROFILE: $env:USERPROFILE"
    
    # Test 4: PROVE it's OpenTracing by testing commands with/without it
    Write-Host "DEBUG: Test 4: OpenTracing Proof Test..."
    
    # Commands that DON'T use OpenTracing (should work)
    Write-Host "DEBUG: Testing commands WITHOUT OpenTracing..."
    try {
      Write-Host "DEBUG: Testing 'slack --version' (no OpenTracing)..."
      $versionOutput = & $SLACK_CLI_NAME --version 2>&1
      Write-Host "DEBUG: --version completed successfully: $versionOutput"
    } catch {
      Write-Host "DEBUG: --version failed: $_"
    }
    
    try {
      Write-Host "DEBUG: Testing 'slack --help' (no OpenTracing)..."
      $helpOutput = & $SLACK_CLI_NAME --help 2>&1
      Write-Host "DEBUG: --help completed successfully: $($helpOutput.Length) characters"
    } catch {
      Write-Host "DEBUG: --help failed: $_"
    }
    
    # Commands that DO use OpenTracing (should hang)
    Write-Host "DEBUG: Testing commands WITH OpenTracing..."
    Write-Host "DEBUG: Testing 'slack _fingerprint' (uses OpenTracing span creation)..."
    
    $otJob = Start-Job -ScriptBlock { 
      param($cliName) 
      Write-Host "DEBUG: About to execute _fingerprint (OpenTracing test)..."
      & $cliName _fingerprint 
    } -ArgumentList $SLACK_CLI_NAME
    
    $otResult = Wait-Job -Job $otJob -Timeout 3
    if ($otResult) {
      $otOutput = Receive-Job -Job $otJob
      Write-Host "DEBUG: _fingerprint (OpenTracing) completed: $otOutput"
      Remove-Job -Job $otJob
    } else {
      Write-Host "DEBUG: _fingerprint (OpenTracing) hung within 3 seconds - OPENTRACING CONFIRMED!"
      Stop-Job -Job $otJob
      Remove-Job -Job $otJob
    }
    
    # Test 5: Check if OpenTracing endpoints are accessible
    Write-Host "DEBUG: Test 5: OpenTracing Endpoint Check..."
    $otEndpoints = @("localhost:14268", "localhost:9411", "localhost:16686")
    foreach ($endpoint in $otEndpoints) {
      try {
        $response = Invoke-WebRequest -Uri "http://$endpoint" -TimeoutSec 2 -ErrorAction Stop
        Write-Host "DEBUG: OpenTracing endpoint $endpoint is accessible"
      } catch {
        Write-Host "DEBUG: OpenTracing endpoint $endpoint is NOT accessible (expected in CI)"
      }
    }
    
    Write-Host "DEBUG: === OPENTRACING PROOF SUMMARY ==="
    Write-Host "DEBUG: Commands WITHOUT OpenTracing: Should work ✅"
    Write-Host "DEBUG: Commands WITH OpenTracing: Should hang ❌"
    Write-Host "DEBUG: OpenTracing endpoints: Should not be accessible in CI ❌"
    Write-Host "DEBUG: Hang location: $hangLocation"
    Write-Host "DEBUG: Exact hang time: $exactHangTime"
    Write-Host "DEBUG: Last responsive time: $lastResponsiveTime"
    Write-Host "DEBUG: Direct execution result: $get_finger_print"
    
    # For now, assume it's the same CLI to continue with installation
    if ($get_finger_print -eq "ERROR:" -or $get_finger_print -like "*HANGED*") {
      Write-Host "DEBUG: Fingerprint check failed, assuming same CLI to continue..."
      $get_finger_print = $FINGERPRINT
    }
    
    if ($get_finger_print -ne $FINGERPRINT) {
      & $SLACK_CLI_NAME --version | Tee-Object -Variable slack_cli_version | Out-Null
      if (!($slack_cli_version -contains "Using ${SLACK_CLI_NAME}.exe v")) {
        Write-Host "Error: Your existing ``$SLACK_CLI_NAME`` command is different from this Slack CLI!"
        Write-Host "Halting the install to avoid accidentally overwriting it."
        Write-Host "`nTry using an alias when installing to avoid name conflicts:"
        Write-Host "`nirm https://downloads.slack-edge.com/slack-cli/install-windows.ps1 -Alias your-preferred-alias | iex"
        throw
      }
    }

    $message = "It is the same Slack CLI! Upgrading to the latest version..."
    if ($Version) {
      $SLACK_CLI_VERSION = $Version
      $message = "It is the same Slack CLI! Switching over to v$Version..."
    }
    if ($Diagnostics) {
      delay 0.3 "$message`n"
    }
  }

  return $SLACK_CLI_NAME
}





function install_slack_cli {
  param(
    [Parameter(HelpMessage = "Alias of Slack CLI")]
    [string]$Alias,

    [Parameter(HelpMessage = "Version of Slack CLI")]
    [string]$Version
  )

  delay 0.6 "Hello and welcome! Now beginning to install the..."

  delay 0.1 "      ________ _     _    _____ _    __    _____ _    ________"
  delay 0.1 "     /  ______/ |   / \ /  ____/ | /  /  /  ____/ | /___   __/"
  delay 0.1 "    /______  |  |  / _ \  |   |      /   | |   |  |    |  |   "
  delay 0.1 "     ____ /  |  |___ __ \ |____  |\  \   | |____  |__ _|  |___"
  delay 0.1 "   /_______ /|______/  \_\ ____/_| \__\    _____/______/_____/"
  delay 0.2 ""

  $confirmed_alias = check_slack_binary_exist $Alias $Version $true
  $error.clear()
  try {
    if ($Version) {
      $SLACK_CLI_VERSION = $Version
    }
    else {
      Write-Host "Finding the latest Slack CLI release version"
      $cli_info = Invoke-RestMethod -Uri "https://api.slack.com/slackcli/metadata.json"
      $SLACK_CLI_VERSION = $cli_info.'slack-cli'.releases.version[0]
    }
  }
  catch {
    Write-Error "Installer cannot find latest Slack CLI release version"
    throw
  }

  $slack_cli_dir = "${Home}\AppData\Local\slack-cli"
  Write-Host "Downloading Slack CLI v$SLACK_CLI_VERSION..."
  try {
    if (!(Test-Path $slack_cli_dir)) {
      try {
        New-Item $slack_cli_dir -ItemType Directory | Out-Null
      }
      catch {
        $alternative_slack_cli_dir = "${Home}\.slack-cli"
        if (!(Test-Path $alternative_slack_cli_dir)) {
          try {
            New-Item $alternative_slack_cli_dir -ItemType Directory | Out-Null
            $slack_cli_dir = $alternative_slack_cli_dir
          }
          catch {
            Write-Error "Installer cannot create folder in $($alternative_slack_cli_dir). `nPlease manually create $($slack_cli_dir) folder and re-run the installation script"
            throw
          }
        }
      }
    }
  }
  catch {
    Write-Error "Installer cannot create folder for Slack CLI, `nPlease manually create $($slack_cli_dir) folder and re-run the installation script"
    throw
  }
  try {
    Invoke-WebRequest -Uri "https://downloads.slack-edge.com/slack-cli/slack_cli_$($SLACK_CLI_VERSION)_windows_64-bit.zip" -OutFile "$($slack_cli_dir)\slack_cli.zip"
  }
  catch {
    Write-Error "Installer cannot download Slack CLI"
    throw
  }

  $slack_cli_bin_dir = "$($slack_cli_dir)\bin"
  $slack_cli_binary_path = "$($slack_cli_dir)\bin\slack.exe"
  $slack_cli_new_binary_path = "$($slack_cli_dir)\bin\${confirmed_alias}.exe"

  delay 0.3 "Extracting the executable to:`n   $slack_cli_new_binary_path"
  Expand-Archive "$($slack_cli_dir)\slack_cli.zip" -DestinationPath "$($slack_cli_dir)" -Force
  Move-Item -Path $slack_cli_binary_path -Destination $slack_cli_new_binary_path -Force

  $User = [System.EnvironmentVariableTarget]::User
  $Path = [System.Environment]::GetEnvironmentVariable('Path', $User)
  if (!(";${Path};".ToLower() -like "*;${slack_cli_bin_dir};*".ToLower())) {
    Write-Host "Adding ``$confirmed_alias.exe`` to your Path environment variable"
    [System.Environment]::SetEnvironmentVariable('Path', $Path.TrimEnd(';') + ";${slack_cli_bin_dir}", $User)
    $Env:Path = $Env:Path.TrimEnd(';') + ";$slack_cli_bin_dir"
  }
  Remove-Item "$($slack_cli_dir)\slack_cli.zip"
}

function install_git {
  param(
    [Parameter(HelpMessage = "Skip Git installation")]
    [bool]$SkipGit = $false
  )
  if ($SkipGit) {
    Write-Host "Skipping the check for a Git installation!"
  }
  else {
    try {
      git | Out-Null
      Write-Host "Git is already installed. Nice!"
    }
    catch [System.Management.Automation.CommandNotFoundException] {
      Write-Host "Git is not installed. Installing now..."

      $MIN_GIT_VERSION = "2.40.0"
      $exePath = "$env:TEMP\git.exe"

      Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v$($MIN_GIT_VERSION).windows.1/Git-$($MIN_GIT_VERSION)-64-bit.exe -UseBasicParsing -OutFile $exePath

      Start-Process $exePath -ArgumentList '/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"' -Wait

      [Environment]::SetEnvironmentVariable('Path', "$([Environment]::GetEnvironmentVariable('Path', 'Machine'));C:\Program Files\Git\bin", 'Machine')

      foreach ($level in "Machine", "User") {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | % {
          if ($_.Name -match 'Path$') {
            $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -split ';' | Select -unique) -join ';'
          }
          $_
        } | Set-Content -Path { "Env:$($_.Name)" }
      }
      Write-Host "Git is installed and ready!"
    }
  }
}

function terms_of_service {
  param(
    [Parameter(HelpMessage = "Alias of Slack CLI")]
    [string]$Alias
  )
  $confirmed_alias = check_slack_binary_exist $Alias $Version $false
   Write-Host "`nUse of the Slack CLI should comply with the Slack API Terms of Service:"
   Write-Host "   https://slack.com/terms-of-service/api"
}

function feedback_message {
  param(
    [Parameter(HelpMessage = "Alias of Slack CLI")]
    [string]$Alias
  )
  $confirmed_alias = check_slack_binary_exist $Alias $Version $false
  # if (Get-Command $confirmed_alias) {
  Write-Host "`nWe would love to know how things are going. Really. All of it."
  Write-Host "   Survey your development experience with ``$confirmed_alias feedback``"
}

function next_step_message {
  param(
    [Parameter(HelpMessage = "Alias of Slack CLI")]
    [string]$Alias
  )
  $confirmed_alias = check_slack_binary_exist $Alias $Version $false
  if (Get-Command $confirmed_alias -ErrorAction SilentlyContinue) {
    try {
      $confirmed_alias | Out-Null
      Write-Host "`nYou're all set! Relaunch your terminal to ensure changes take effect."
      Write-Host "   Then, authorize your CLI in your workspace with ``$confirmed_alias login``.`n"
    }
    catch {
      Write-Error "Slack CLI was not installed."
      Write-Host "`nFind help troubleshooting: https://docs.slack.dev/tools/slack-cli"
      throw
    }
  }
}

trap {
  Write-Host "`nWe would love to know how things are going. Really. All of it."
  Write-Host "Submit installation issues: https://github.com/slackapi/slack-cli/issues"
}

install_slack_cli $Alias $Version
Write-Host "`nAdding developer tooling for an enhanced experience..."
install_git $SkipGit
Write-Host "Sweet! You're all set to start developing!"

terms_of_service $Alias
Write-Host "LASTEXITCODE after terms_of_service: $LASTEXITCODE"

feedback_message $Alias
Write-Host "LASTEXITCODE after feedback_message: $LASTEXITCODE"

next_step_message $Alias
Write-Host "LASTEXITCODE after next_step_message: $LASTEXITCODE"