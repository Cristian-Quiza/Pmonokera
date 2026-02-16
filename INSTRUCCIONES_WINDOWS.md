# 🪟 Guía de Instalación y Ejecución para Windows

## ⚠️ Importante

Este proyecto fue desarrollado principalmente para Linux/Mac. Para ejecutarlo en Windows, tienes varias opciones:

---

## 📋 Opciones para Windows

### Opción 1: WSL2 (Windows Subsystem for Linux) - **RECOMENDADA** ✅

Esta es la forma más fácil y compatible de ejecutar el proyecto en Windows.

#### Paso 1: Instalar WSL2

```powershell
# Abrir PowerShell como Administrador y ejecutar:
wsl --install
```

Esto instalará Ubuntu por defecto. Reinicia tu computadora cuando se te indique.

#### Paso 2: Configurar WSL2

Después de reiniciar, abre "Ubuntu" desde el menú de inicio y configura tu usuario.

#### Paso 3: Instalar Dependencias en WSL2

```bash
# Actualizar paquetes
sudo apt update && sudo apt upgrade -y

# Instalar Ruby (versión 3.2+)
sudo apt install -y ruby-full build-essential

# Instalar Node.js y npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Instalar PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Instalar Git (si no está instalado)
sudo apt install -y git
```

#### Paso 4: Clonar el Proyecto en WSL2

```bash
# Navegar a tu directorio home en WSL
cd ~

# Clonar el repositorio
git clone https://github.com/Cristian-Quiza/Pmonokera.git
cd Pmonokera

# Seguir las instrucciones normales de Linux
./start_services.sh
```

#### Paso 5: Acceder desde Windows

Una vez que los servicios estén corriendo en WSL2, puedes acceder a ellos desde tu navegador de Windows normalmente:

- Frontend: http://localhost:3000
- Customer Service: http://localhost:3001
- Order Service: http://localhost:3002

---

### Opción 2: Docker (Multiplataforma)

Si tienes Docker Desktop instalado en Windows:

#### Crear docker-compose.yml (pendiente de implementar)

Esta opción requiere crear archivos de Docker que aún no están en el proyecto.

---

### Opción 3: Scripts PowerShell para Windows Nativo

Si prefieres ejecutar directamente en Windows sin WSL, necesitarás:

#### Requisitos Previos:

1. **Ruby para Windows**: https://rubyinstaller.org/
   - Descargar e instalar Ruby 3.2+ con DevKit
   
2. **PostgreSQL para Windows**: https://www.postgresql.org/download/windows/
   - Descargar e instalar PostgreSQL 14+
   - Configurar contraseña: `Junio.2021` para usuario `postgres`
   
3. **Node.js para Windows**: https://nodejs.org/
   - Descargar e instalar Node.js 20+ LTS

#### Scripts PowerShell

He creado scripts PowerShell equivalentes que puedes usar:

**start_services.ps1:**
```powershell
# Ver el archivo start_services.ps1 en el repositorio
.\start_services.ps1
```

**stop_services.ps1:**
```powershell
# Ver el archivo stop_services.ps1 en el repositorio
.\stop_services.ps1
```

---

## 🚀 Inicio Rápido con WSL2 (Recomendado)

### 1. Instalar WSL2

```powershell
# En PowerShell como Administrador
wsl --install
# Reiniciar computadora
```

### 2. Abrir Ubuntu desde el menú de inicio

### 3. Instalar todo lo necesario

```bash
# Script de instalación rápida
sudo apt update
sudo apt install -y ruby-full build-essential nodejs npm postgresql postgresql-contrib git

# Verificar instalaciones
ruby --version    # Debe mostrar 3.0+
node --version    # Debe mostrar 20+
psql --version    # Debe mostrar 14+
```

### 4. Configurar PostgreSQL

```bash
# Iniciar PostgreSQL
sudo service postgresql start

# Configurar contraseña
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Junio.2021';"
```

### 5. Clonar y ejecutar el proyecto

```bash
cd ~
git clone https://github.com/Cristian-Quiza/Pmonokera.git
cd Pmonokera

# Instalar bundler
sudo gem install bundler

# Ejecutar el sistema
./start_services.sh
```

### 6. Abrir en el navegador de Windows

- http://localhost:3000

---

## 📝 Notas Importantes para Windows

### Diferencias de Rutas

En Windows PowerShell:
- ❌ `/home/runner/work/Pmonokera/Pmonokera` NO funciona
- ✅ `C:\Users\TuUsuario\Pmonokera` SÍ funciona

En WSL2 (Ubuntu):
- ✅ `/home/tuusuario/Pmonokera` SÍ funciona
- ✅ Puedes acceder a tus archivos de Windows desde WSL: `/mnt/c/Users/TuUsuario/`

### PostgreSQL en Windows

Si instalaste PostgreSQL en Windows nativo:

1. **Iniciar servicio:**
   - Buscar "Servicios" en el menú de inicio
   - Encontrar "postgresql-x64-14" (o versión instalada)
   - Click derecho → Iniciar

2. **O desde PowerShell como Administrador:**
   ```powershell
   Start-Service postgresql-x64-14
   ```

### Ruby en Windows

Después de instalar Ruby:

```powershell
# Verificar instalación
ruby --version

# Instalar bundler
gem install bundler

# En cada servicio Rails
cd customer-service
bundle install

cd ..\order-service
bundle install
```

### Node.js en Windows

```powershell
# Verificar instalación
node --version
npm --version

# En el frontend
cd frontend
npm install
```

---

## 🛠️ Scripts de Inicio para Windows PowerShell

### start_services.ps1

Ejecutar desde PowerShell en la carpeta del proyecto:

```powershell
# Permitir ejecución de scripts (una sola vez, como Administrador)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecutar el script
.\start_services.ps1
```

### stop_services.ps1

```powershell
.\stop_services.ps1
```

---

## 🔍 Verificar que Todo Funciona

### En WSL2 o Windows nativo

```bash
# (WSL2) o PowerShell (Windows)

# Verificar PostgreSQL
# WSL2:
sudo service postgresql status
# Windows (como Admin):
Get-Service postgresql*

# Verificar servicios corriendo
# WSL2:
ps aux | grep rails
ps aux | grep next
# Windows:
Get-Process | Where-Object {$_.ProcessName -like "*ruby*"}
Get-Process | Where-Object {$_.ProcessName -like "*node*"}

# Probar APIs
curl http://localhost:3001/customers/1
curl http://localhost:3002/orders
curl http://localhost:3000
```

---

## 🐛 Problemas Comunes en Windows

### Error: "No se encuentra la ruta"

**Problema:** Estás en PowerShell tratando de usar rutas de Linux.

**Solución:** 
- Opción A: Usa WSL2 (recomendado)
- Opción B: Cambia a rutas de Windows: `cd C:\Users\TuUsuario\Pmonokera`

### Error: "bundler no encontrado"

**Problema:** Ruby no instalado o no en PATH.

**Solución:**
```powershell
# Instalar bundler
gem install bundler

# Si no funciona, reinstalar Ruby con RubyInstaller
```

### Error: "PostgreSQL no conecta"

**Problema:** PostgreSQL no está corriendo.

**Solución Windows:**
```powershell
# Como Administrador
Start-Service postgresql-x64-14
```

**Solución WSL2:**
```bash
sudo service postgresql start
```

### Error: "Puerto ya en uso"

**Problema:** Otro proceso usa el puerto 3000, 3001 o 3002.

**Solución Windows:**
```powershell
# Ver qué proceso usa el puerto
netstat -ano | findstr :3000

# Matar proceso por PID (reemplaza 1234 con el PID real)
Stop-Process -Id 1234 -Force
```

**Solución WSL2:**
```bash
# Ver qué proceso usa el puerto
lsof -i :3000

# Matar proceso por PID
kill -9 <PID>
```

---

## ✅ Recomendación Final

**Para Windows, la mejor opción es WSL2** porque:

1. ✅ Es nativo de Windows 10/11
2. ✅ Ejecuta Linux sin virtualización pesada
3. ✅ Acceso completo a archivos de Windows
4. ✅ Puedes usar herramientas de Windows (navegador, VS Code, etc.)
5. ✅ Compatibilidad 100% con el proyecto
6. ✅ No requiere modificar el código
7. ✅ Mejor rendimiento que máquinas virtuales

---

## 📚 Recursos Adicionales

- [Documentación oficial de WSL2](https://docs.microsoft.com/en-us/windows/wsl/)
- [RubyInstaller para Windows](https://rubyinstaller.org/)
- [PostgreSQL para Windows](https://www.postgresql.org/download/windows/)
- [Node.js para Windows](https://nodejs.org/)

---

## 🎯 Pasos Resumidos (WSL2 - Recomendado)

1. Abrir PowerShell como Administrador
2. `wsl --install`
3. Reiniciar
4. Abrir Ubuntu
5. `sudo apt update && sudo apt install -y ruby-full nodejs npm postgresql git`
6. `sudo service postgresql start`
7. `sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Junio.2021';"`
8. `cd ~ && git clone https://github.com/Cristian-Quiza/Pmonokera.git`
9. `cd Pmonokera && sudo gem install bundler`
10. `./start_services.sh`
11. Abrir http://localhost:3000 en Windows

**¡Listo! 🎉**
