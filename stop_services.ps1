# Script de PowerShell para detener todos los servicios del proyecto P-Monokera en Windows

Write-Host "🛑 Deteniendo servicios de P-Monokera..." -ForegroundColor Yellow
Write-Host ""

# Detener procesos de Ruby (Rails)
Write-Host "   🛑 Deteniendo servicios Rails..." -ForegroundColor Cyan
$rubyProcesses = Get-Process -Name "ruby" -ErrorAction SilentlyContinue
if ($rubyProcesses) {
    $rubyProcesses | Stop-Process -Force
    Write-Host "   ✅ Servicios Rails detenidos" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  No hay procesos Rails corriendo" -ForegroundColor Gray
}
Write-Host ""

# Detener procesos de Node (Frontend)
Write-Host "   🛑 Deteniendo Frontend..." -ForegroundColor Cyan
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $nodeProcesses | Stop-Process -Force
    Write-Host "   ✅ Frontend detenido" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  No hay procesos Node corriendo" -ForegroundColor Gray
}
Write-Host ""

# Cerrar ventanas de PowerShell minimizadas (opcional)
Write-Host "   🧹 Limpiando ventanas de PowerShell..." -ForegroundColor Cyan
$powershellWindows = Get-Process -Name "powershell" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq "" -and $_.Id -ne $PID }
if ($powershellWindows) {
    $powershellWindows | Stop-Process -Force
    Write-Host "   ✅ Ventanas de PowerShell cerradas" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  No hay ventanas extra de PowerShell" -ForegroundColor Gray
}
Write-Host ""

Write-Host "✅ Todos los servicios han sido detenidos" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Para volver a iniciar los servicios, ejecuta:" -ForegroundColor Cyan
Write-Host "   .\start_services.ps1" -ForegroundColor White
Write-Host ""
