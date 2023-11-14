#Schedule script

for(;;) {
 try {
  # invoke the worker script
  $PathScript = pwd
  powershell C:\serversize.ps1 -WindowStyle Hidden

 }
 catch {
  Write-Output "Error"
 }

 # Time Interval to wait in Seconds
 Start-Sleep 60
}