# 🚀 Guía de Ejecución en VS Code para Windows

## 📍 Tu Ruta del Proyecto
`C:\Users\PC\Documents\PruebaInetum`

---

## ✅ Requisitos Previos

Antes de ejecutar, necesitas tener instalado:

### 1. Ruby (para el backend Rails)
- Descargar de: https://rubyinstaller.org/
- Versión requerida: **3.2 o superior**
- ⚠️ **IMPORTANTE:** Instalar con DevKit
- Verificar instalación: abre PowerShell y ejecuta:
  ```powershell
  ruby --version
  ```
  Debe mostrar algo como: `ruby 3.2.x`

### 2. PostgreSQL (base de datos)
- Descargar de: https://www.postgresql.org/download/windows/
- Versión requerida: **14 o superior**
- Durante la instalación:
  - Configura la contraseña del usuario `postgres` como: `Junio.2021`
  - Recuerda el puerto (por defecto: 5432)
- Verificar instalación:
  ```powershell
  psql --version
  ```

### 3. Node.js (para el frontend Next.js)
- Descargar de: https://nodejs.org/
- Versión requerida: **20 LTS o superior**
- Verificar instalación:
  ```powershell
  node --version
  npm --version
  ```

---

## 🎯 Pasos para Ejecutar desde VS Code

### Opción 1: Usar la Terminal Integrada de VS Code (Recomendado)

#### Paso 1: Abrir Terminal en VS Code

1. En VS Code, presiona: **Ctrl + `** (tecla acento grave)
   - O ve a: **Ver > Terminal**
2. Se abrirá una terminal en la parte inferior

#### Paso 2: Verificar que estás en la carpeta correcta

En la terminal de VS Code, ejecuta:
```powershell
pwd
```

Debe mostrar: `C:\Users\PC\Documents\PruebaInetum`

Si no estás ahí:
```powershell
cd C:\Users\PC\Documents\PruebaInetum
```

#### Paso 3: Instalar Bundler (solo la primera vez)

```powershell
gem install bundler
```

#### Paso 4: Iniciar PostgreSQL

**Opción A - Desde Servicios de Windows:**
1. Presiona `Win + R`
2. Escribe: `services.msc`
3. Busca "postgresql" en la lista
4. Click derecho → "Iniciar"

**Opción B - Desde PowerShell (como Administrador):**
```powershell
Start-Service postgresql*
```

#### Paso 5: Instalar Dependencias

**Backend - Customer Service:**
```powershell
cd customer-service
bundle config set --local path 'vendor/bundle'
bundle install
cd ..
```

**Backend - Order Service:**
```powershell
cd order-service
bundle config set --local path 'vendor/bundle'
bundle install
cd ..
```

**Frontend:**
```powershell
cd frontend
npm install
cd ..
```

#### Paso 6: Configurar Bases de Datos (solo la primera vez)

**Customer Service:**
```powershell
cd customer-service
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
cd ..
```

**Order Service:**
```powershell
cd order-service
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
cd ..
```

#### Paso 7: Ejecutar los Servicios

Ahora necesitas **3 terminales** en VS Code. Para abrir más terminales:
- Click en el icono `+` en el panel de terminal
- O presiona: **Ctrl + Shift + `**

**Terminal 1 - Customer Service:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\customer-service
$env:PORT="3001"
bundle exec rails s -p 3001 -b 0.0.0.0
```

**Terminal 2 - Order Service:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\order-service
$env:PORT="3002"
bundle exec rails s -p 3002 -b 0.0.0.0
```

**Terminal 3 - Frontend:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\frontend
npm run dev
```

#### Paso 8: Acceder a la Aplicación

Después de 20-30 segundos, abre tu navegador y ve a:

🌐 **http://localhost:3000**

¡Deberías ver la aplicación funcionando! 🎉

---

### Opción 2: Usar el Script PowerShell Automatizado

Si ya instalaste todos los requisitos previos:

1. En la terminal de VS Code:
```powershell
cd C:\Users\PC\Documents\PruebaInetum
```

2. Permitir ejecución de scripts (solo la primera vez):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

3. Ejecutar el script:
```powershell
.\start_services.ps1
```

Esto iniciará todo automáticamente en ventanas separadas.

---

## 🎨 Configuración de VS Code (Opcional pero Recomendado)

### Crear Tasks para Ejecutar con un Click

Crea un archivo `.vscode/tasks.json` en la raíz del proyecto:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Customer Service",
      "type": "shell",
      "command": "cd customer-service && $env:PORT='3001' && bundle exec rails s -p 3001",
      "windows": {
        "command": "cd customer-service; $env:PORT='3001'; bundle exec rails s -p 3001"
      },
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "problemMatcher": []
    },
    {
      "label": "Start Order Service",
      "type": "shell",
      "command": "cd order-service && $env:PORT='3002' && bundle exec rails s -p 3002",
      "windows": {
        "command": "cd order-service; $env:PORT='3002'; bundle exec rails s -p 3002"
      },
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "problemMatcher": []
    },
    {
      "label": "Start Frontend",
      "type": "shell",
      "command": "cd frontend && npm run dev",
      "windows": {
        "command": "cd frontend; npm run dev"
      },
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "problemMatcher": []
    },
    {
      "label": "Start All Services",
      "dependsOn": [
        "Start Customer Service",
        "Start Order Service",
        "Start Frontend"
      ],
      "problemMatcher": []
    }
  ]
}
```

Después puedes ejecutar:
- **Ctrl + Shift + P** → "Tasks: Run Task" → "Start All Services"

---

## 🔍 Verificar que Todo Funciona

### Verificar los Servicios

Abre nuevas terminales en VS Code y ejecuta:

**Customer Service:**
```powershell
curl http://localhost:3001/customers/1
```

**Order Service:**
```powershell
curl http://localhost:3002/orders
```

**Frontend:**
```powershell
curl http://localhost:3000
```

Todos deberían responder con JSON o HTML.

---

## 🐛 Problemas Comunes y Soluciones

### Error: "ruby no se reconoce como comando"

**Causa:** Ruby no está instalado o no está en el PATH.

**Solución:**
1. Instalar Ruby desde https://rubyinstaller.org/
2. Reiniciar VS Code
3. Verificar: `ruby --version`

### Error: "bundle no se reconoce como comando"

**Solución:**
```powershell
gem install bundler
```

### Error: "PostgreSQL no conecta"

**Solución:**
```powershell
# Verificar si está corriendo
Get-Service postgresql*

# Si no está corriendo, iniciarlo
Start-Service postgresql-x64-14  # (ajusta según tu versión)
```

### Error: "Puerto 3000/3001/3002 ya en uso"

**Solución - Ver qué proceso lo usa:**
```powershell
netstat -ano | findstr :3000
```

**Matar el proceso:**
```powershell
Stop-Process -Id <PID> -Force
```

### Error: "node no se reconoce como comando"

**Solución:**
1. Instalar Node.js desde https://nodejs.org/
2. Reiniciar VS Code
3. Verificar: `node --version`

### Error al instalar gemas nativas (pg, etc)

**Solución:**
Asegúrate de instalar Ruby con DevKit desde RubyInstaller.

---

## 📊 Estructura de Terminales en VS Code

Deberías tener 3 terminales abiertas:

```
Terminal 1: Customer Service (puerto 3001)
Terminal 2: Order Service (puerto 3002)
Terminal 3: Frontend (puerto 3000)
```

Puedes cambiar entre ellas usando el dropdown en el panel de terminal.

---

## 🎯 Resumen de Comandos Rápidos

### Primera Vez (Setup Completo)

```powershell
# 1. Ir a la carpeta
cd C:\Users\PC\Documents\PruebaInetum

# 2. Instalar bundler
gem install bundler

# 3. Instalar dependencias backend
cd customer-service
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec rails db:create db:migrate db:seed
cd ..

cd order-service
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec rails db:create db:migrate db:seed
cd ..

# 4. Instalar dependencias frontend
cd frontend
npm install
cd ..
```

### Ejecución Normal (Después del Setup)

**Terminal 1:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\customer-service
$env:PORT="3001"
bundle exec rails s -p 3001
```

**Terminal 2:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\order-service
$env:PORT="3002"
bundle exec rails s -p 3002
```

**Terminal 3:**
```powershell
cd C:\Users\PC\Documents\PruebaInetum\frontend
npm run dev
```

**Abrir navegador:** http://localhost:3000

---

## 💡 Tips de VS Code

### Atajos Útiles

- **Ctrl + `** - Abrir/cerrar terminal
- **Ctrl + Shift + `** - Nueva terminal
- **Ctrl + Shift + P** - Paleta de comandos
- **Ctrl + B** - Ocultar/mostrar sidebar
- **Ctrl + J** - Ocultar/mostrar panel

### Extensiones Recomendadas

1. **Ruby** (Peng Lv)
2. **Ruby Solargraph** (autocompletado)
3. **ES7+ React/Redux/React-Native snippets**
4. **Prettier** (formateo de código)
5. **PostgreSQL** (manejo de BD)

---

## 🎬 Video Tutorial

Si prefieres video, busca en YouTube:
- "Rails en Windows"
- "Next.js desarrollo en Windows"

---

## ✅ Checklist de Verificación

- [ ] Ruby instalado y funcionando
- [ ] PostgreSQL instalado y corriendo
- [ ] Node.js instalado y funcionando
- [ ] Bundler instalado
- [ ] Dependencias de customer-service instaladas
- [ ] Dependencias de order-service instaladas
- [ ] Dependencias de frontend instaladas
- [ ] Base de datos customer-service creada
- [ ] Base de datos order-service creada
- [ ] Customer Service corriendo en puerto 3001
- [ ] Order Service corriendo en puerto 3002
- [ ] Frontend corriendo en puerto 3000
- [ ] Aplicación accesible en http://localhost:3000

---

## 🆘 ¿Necesitas Más Ayuda?

Si encuentras algún error:

1. Lee el mensaje de error completo
2. Busca el error en esta guía
3. Verifica que todos los requisitos previos estén instalados
4. Reinicia VS Code si es necesario
5. Reinicia PostgreSQL si es necesario

---

**¡Éxito ejecutando el proyecto! 🚀**
