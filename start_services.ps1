# Script de PowerShell para iniciar todos los servicios del proyecto P-Monokera en Windows
# Ejecutar desde la raíz del proyecto

Write-Host "🚀 Iniciando servicios de P-Monokera en Windows..." -ForegroundColor Green
Write-Host ""

# Verificar si estamos en la carpeta correcta
if (-Not (Test-Path "customer-service") -or -Not (Test-Path "order-service") -or -Not (Test-Path "frontend")) {
    Write-Host "❌ Error: No se encontraron las carpetas del proyecto." -ForegroundColor Red
    Write-Host "   Asegúrate de ejecutar este script desde la carpeta raíz del proyecto P-Monokera" -ForegroundColor Yellow
    exit 1
}

# Verificar PostgreSQL
Write-Host "1️⃣ Verificando PostgreSQL..." -ForegroundColor Cyan
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($pgService) {
    if ($pgService.Status -ne "Running") {
        Write-Host "   Iniciando PostgreSQL..." -ForegroundColor Yellow
        Start-Service $pgService.Name -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
    Write-Host "   ✅ PostgreSQL está corriendo" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  No se encontró el servicio de PostgreSQL" -ForegroundColor Yellow
    Write-Host "   Asegúrate de que PostgreSQL esté instalado" -ForegroundColor Yellow
}
Write-Host ""

# Verificar Ruby
Write-Host "2️⃣ Verificando Ruby..." -ForegroundColor Cyan
$rubyVersion = ruby --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Ruby encontrado: $rubyVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Ruby no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "   Descarga Ruby desde: https://rubyinstaller.org/" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Verificar Node.js
Write-Host "3️⃣ Verificando Node.js..." -ForegroundColor Cyan
$nodeVersion = node --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Node.js encontrado: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Node.js no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "   Descarga Node.js desde: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Instalar dependencias de customer-service
Write-Host "4️⃣ Instalando dependencias de customer-service..." -ForegroundColor Cyan
Push-Location customer-service
if (-Not (Test-Path "vendor\bundle")) {
    Write-Host "   📦 Instalando gemas..." -ForegroundColor Yellow
    bundle config set --local path 'vendor/bundle'
    bundle install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Error instalando dependencias de customer-service" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}
Write-Host "   ✅ Dependencias de customer-service instaladas" -ForegroundColor Green
Pop-Location
Write-Host ""

# Instalar dependencias de order-service
Write-Host "5️⃣ Instalando dependencias de order-service..." -ForegroundColor Cyan
Push-Location order-service
if (-Not (Test-Path "vendor\bundle")) {
    Write-Host "   📦 Instalando gemas..." -ForegroundColor Yellow
    bundle config set --local path 'vendor/bundle'
    bundle install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Error instalando dependencias de order-service" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}
Write-Host "   ✅ Dependencias de order-service instaladas" -ForegroundColor Green
Pop-Location
Write-Host ""

# Instalar dependencias de frontend
Write-Host "6️⃣ Instalando dependencias de frontend..." -ForegroundColor Cyan
Push-Location frontend
if (-Not (Test-Path "node_modules")) {
    Write-Host "   📦 Instalando paquetes npm..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Error instalando dependencias de frontend" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}
Write-Host "   ✅ Dependencias de frontend instaladas" -ForegroundColor Green
Pop-Location
Write-Host ""

# Crear/migrar bases de datos
Write-Host "7️⃣ Configurando bases de datos..." -ForegroundColor Cyan
Push-Location customer-service
Write-Host "   📦 Customer Service database..." -ForegroundColor Yellow
bundle exec rails db:create db:migrate db:seed 2>$null
Pop-Location

Push-Location order-service
Write-Host "   📦 Order Service database..." -ForegroundColor Yellow
bundle exec rails db:create db:migrate db:seed 2>$null
Pop-Location
Write-Host "   ✅ Bases de datos configuradas" -ForegroundColor Green
Write-Host ""

# Iniciar Customer Service
Write-Host "8️⃣ Iniciando Customer Service (puerto 3001)..." -ForegroundColor Cyan
Push-Location customer-service
$env:PORT = "3001"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; `$env:PORT='3001'; bundle exec rails s -p 3001 -b 0.0.0.0" -WindowStyle Minimized
Pop-Location
Write-Host "   ✅ Customer Service iniciado" -ForegroundColor Green
Write-Host ""

# Iniciar Order Service
Write-Host "9️⃣ Iniciando Order Service (puerto 3002)..." -ForegroundColor Cyan
Push-Location order-service
$env:PORT = "3002"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; `$env:PORT='3002'; bundle exec rails s -p 3002 -b 0.0.0.0" -WindowStyle Minimized
Pop-Location
Write-Host "   ✅ Order Service iniciado" -ForegroundColor Green
Write-Host ""

# Iniciar Frontend
Write-Host "🔟 Iniciando Frontend (puerto 3000)..." -ForegroundColor Cyan
Push-Location frontend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; npm run dev" -WindowStyle Minimized
Pop-Location
Write-Host "   ✅ Frontend iniciado" -ForegroundColor Green
Write-Host ""

Write-Host "⏳ Esperando que los servicios se inicialicen (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
Write-Host ""

Write-Host "🎉 ¡Servicios iniciados!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 URLs:" -ForegroundColor Cyan
Write-Host "   - Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   - Customer Service API: http://localhost:3001" -ForegroundColor White
Write-Host "   - Order Service API: http://localhost:3002" -ForegroundColor White
Write-Host ""
Write-Host "🛑 Para detener todos los servicios:" -ForegroundColor Yellow
Write-Host "   .\stop_services.ps1" -ForegroundColor White
Write-Host ""
Write-Host "💡 Los servicios están corriendo en ventanas minimizadas de PowerShell" -ForegroundColor Cyan
Write-Host "   Puedes restaurarlas desde la barra de tareas si necesitas ver los logs" -ForegroundColor Cyan
Write-Host ""

# Intentar abrir el navegador
Write-Host "🌐 Abriendo navegador..." -ForegroundColor Cyan
Start-Sleep -Seconds 5
Start-Process "http://localhost:3000"
