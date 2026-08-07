Get-Process | Where-Object { $_.ProcessName -like "*belle*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 800
Set-Location d:\belle_beauty_salon
flutter run -d windows
