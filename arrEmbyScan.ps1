##### Settings
$logDir = "C:\logs"
$embyServer = "https://my.emby.server:8920"
$apiKey = "18f149bb0f5844hy5806e64143388f5"
#####

if ($env:sonarr_episodefile_path -or $env:radarr_movie_path) {
   $timeScriptRun = Get-Date -Format 'yyyyMMddTHHmmssffff'
   $timeReadable = Get-Date
   $logPath = "$($logDir)\$($timeScriptRun).log"
   Add-Content $logPath "Run Time: $($timeReadable)"
   if ($env:sonarr_episodefile_path) {
      $fullPath = $env:sonarr_episodefile_path
      $itemPath = Split-Path $env:sonarr_episodefile_path
   }
   if ($env:radarr_movie_path) {
      $fullPath = $env:radarr_movie_path
      $itemPath = Split-Path $env:radarr_movie_path
   }
   Add-Content $logPath "Full Path: $($fullPath)"
   Add-Content $logPath "Item Path: $($itemPath)"
   $itemPathJson = $fullPath | ConvertTo-Json
   $tries = 0
   $pathExists = $False
   while ($pathExists -eq $False) {
      $pathExists = Test-Path -LiteralPath $fullPath
      Start-Sleep 5
      $tries++
      if ($tries -ge 200) {
         Add-Content $logPath "File was not detected after $($tries) checks"
         exit
      }
   }
   Start-Sleep 30
   $url = "$($embyServer)/emby/Library/Media/Updated?api_key=$($apiKey)"
   Add-Content $logPath "URL: $($url)"
   $postBody = @"
{
   "Updates":[
      {
         "path":$($itemPathJson),
         "updateType":"Created"
      }
   ]
}
"@
   Add-Content $logPath "Post Body: $($postBody)"
   $requestOut = Invoke-WebRequest -Uri $url -Method POST -Body $postBody -ContentType "application/json" -UseBasicParsing
   Add-Content $logPath $requestOut
   Add-Content $logPath "Complete"
}