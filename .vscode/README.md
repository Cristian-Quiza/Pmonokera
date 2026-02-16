# Configuración de VS Code para P-Monokera

Este archivo `tasks.json` configura tareas automatizadas para VS Code que facilitan el desarrollo del proyecto.

## 🎯 Cómo Usar

### Ejecutar una tarea:

1. Presiona: **Ctrl + Shift + P**
2. Escribe: `Tasks: Run Task`
3. Selecciona la tarea que deseas ejecutar

## 📋 Tareas Disponibles

### 🚀 Iniciar Servicios

- **🎯 Start All Services** - Inicia todos los servicios a la vez
- **🚀 Start Customer Service** - Inicia solo customer-service (puerto 3001)
- **🚀 Start Order Service** - Inicia solo order-service (puerto 3002)
- **🚀 Start Frontend** - Inicia solo el frontend (puerto 3000)

### 📦 Instalar Dependencias

- **📦 Install All Dependencies** - Instala dependencias de todos los servicios
- **📦 Install Customer Service Dependencies** - Solo customer-service
- **📦 Install Order Service Dependencies** - Solo order-service
- **📦 Install Frontend Dependencies** - Solo frontend

### 🗄️ Configurar Bases de Datos

- **🗄️ Setup All Databases** - Crea y migra todas las bases de datos
- **🗄️ Setup Customer Service Database** - Solo customer-service DB
- **🗄️ Setup Order Service Database** - Solo order-service DB

### 🔧 Setup Completo

- **🔧 Complete Setup (First Time)** - Ejecuta TODA la configuración inicial:
  1. Instala todas las dependencias
  2. Configura todas las bases de datos
  3. Carga datos de prueba

### 🧪 Tests

- **🧪 Test Customer Service** - Ejecuta tests de customer-service
- **🧪 Test Order Service** - Ejecuta tests de order-service

### 🧹 Limpiar y Recrear

- **🧹 Clean Customer Service** - Elimina y recrea la BD de customer-service
- **🧹 Clean Order Service** - Elimina y recrea la BD de order-service

## 🎬 Flujo de Trabajo Típico

### Primera Vez:

1. **Ctrl + Shift + P** → "Tasks: Run Task" → **"🔧 Complete Setup (First Time)"**
2. Esperar a que termine (2-3 minutos)
3. **Ctrl + Shift + P** → "Tasks: Run Task" → **"🎯 Start All Services"**
4. Abrir http://localhost:3000

### Uso Diario:

1. Abrir VS Code
2. **Ctrl + Shift + P** → "Tasks: Run Task" → **"🎯 Start All Services"**
3. ¡Empezar a desarrollar!

## 💡 Tips

- Los servicios se ejecutan en paneles dedicados de terminal
- Puedes detenerlos con **Ctrl + C** en cada panel
- Los paneles están agrupados para mejor organización
- Los emojis ayudan a identificar rápidamente cada tarea

## 🪟 Notas para Windows

- Las tareas incluyen comandos específicos para PowerShell
- Funcionan tanto en CMD como en PowerShell
- Se usa `;` en lugar de `&&` para compatibilidad con PowerShell

## 🔗 Documentación Relacionada

- `EJECUTAR_VSCODE.md` - Guía rápida de inicio
- `GUIA_VSCODE_WINDOWS.md` - Guía completa para Windows
- `INSTRUCCIONES_WINDOWS.md` - Instalación de requisitos
