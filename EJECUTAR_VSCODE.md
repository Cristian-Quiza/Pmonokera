# 🚀 INICIO RÁPIDO - Ejecutar Proyecto en VS Code

## 📍 Tu Configuración
- **Sistema:** Windows
- **Ruta:** `C:\Users\PC\Documents\PruebaInetum`
- **Editor:** VS Code

---

## ⚡ Opción 1: Ejecución Automática (MÁS FÁCIL)

### Paso 1: Abrir Terminal en VS Code

Presiona: **Ctrl + `** (acento grave)

### Paso 2: Verificar que estás en la carpeta correcta

```powershell
pwd
```

Debe mostrar: `C:\Users\PC\Documents\PruebaInetum`

### Paso 3: Ejecutar el script automático

```powershell
# Permitir scripts (solo la primera vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecutar
.\start_services.ps1
```

El script hará TODO automáticamente:
- ✅ Verificar PostgreSQL
- ✅ Instalar dependencias
- ✅ Crear bases de datos
- ✅ Iniciar los 3 servicios
- ✅ Abrir el navegador

**Espera 30 segundos y ve a:** http://localhost:3000

---

## ⚡ Opción 2: Usar Tasks de VS Code (CON UN CLICK)

### Primera Vez - Setup Completo:

1. Presiona: **Ctrl + Shift + P**
2. Escribe: "Tasks: Run Task"
3. Selecciona: **"🔧 Complete Setup (First Time)"**
4. Espera a que termine (puede tomar 2-3 minutos)

### Después del Setup - Iniciar Servicios:

1. Presiona: **Ctrl + Shift + P**
2. Escribe: "Tasks: Run Task"
3. Selecciona: **"🎯 Start All Services"**

¡Ya está! Abre http://localhost:3000

---

## ⚡ Opción 3: Manual (3 Terminales)

### Primera Vez - Instalar Dependencias:

**Terminal 1:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum
gem install bundler

cd customer-service
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec rails db:create db:migrate db:seed
```

**Terminal 2:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\order-service
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec rails db:create db:migrate db:seed
```

**Terminal 3:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\frontend
npm install
```

### Después del Setup - Ejecutar:

Abre 3 terminales en VS Code (Click en `+` en el panel de terminal):

**Terminal 1 - Customer Service:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\customer-service
$env:PORT="3001"
bundle exec rails s -p 3001
```

**Terminal 2 - Order Service:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\order-service
$env:PORT="3002"
bundle exec rails s -p 3002
```

**Terminal 3 - Frontend:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\frontend
npm run dev
```

**Abrir:** http://localhost:3000

---

## 🔧 Si NO Tienes los Requisitos Instalados

### 1. Verificar qué tienes instalado:

```powershell
ruby --version    # Debe mostrar 3.2+
node --version    # Debe mostrar 20+
psql --version    # Debe mostrar 14+
```

### 2. Si falta algo, instalar:

- **Ruby:** https://rubyinstaller.org/ (con DevKit)
- **Node.js:** https://nodejs.org/
- **PostgreSQL:** https://www.postgresql.org/download/windows/
  - ⚠️ Contraseña: `Junio.2021`

### 3. Después de instalar, reinicia VS Code

---

## ✅ Verificar que Funciona

### Test 1: Customer Service
```powershell
curl http://localhost:3001/customers/1
```

Debe responder con JSON del cliente.

### Test 2: Order Service
```powershell
curl http://localhost:3002/orders
```

Debe responder con un array de órdenes.

### Test 3: Frontend
Abrir en navegador: http://localhost:3000

Debe mostrar el "Sistema de Órdenes".

---

## 🐛 Problemas Comunes

### "ruby no se reconoce"
➡️ Instalar Ruby y reiniciar VS Code

### "PostgreSQL no conecta"
➡️ Iniciar servicio:
```powershell
Start-Service postgresql*
```

### "Puerto ya en uso"
➡️ Ver qué lo usa y matarlo:
```powershell
netstat -ano | findstr :3000
Stop-Process -Id <PID> -Force
```

---

## 📋 Orden Recomendado

1. ✅ Verificar requisitos instalados
2. ✅ Abrir terminal en VS Code
3. ✅ Ejecutar `.\start_services.ps1`
4. ✅ Esperar 30 segundos
5. ✅ Abrir http://localhost:3000
6. ✅ ¡Disfrutar! 🎉

---

## 🆘 ¿Más Ayuda?

- Ver: `GUIA_VSCODE_WINDOWS.md` (guía completa)
- Ver: `INSTRUCCIONES_WINDOWS.md` (instalación detallada)
- Ver: `.vscode/tasks.json` (configuración de tasks)

---

**¡Éxito! 🚀**
