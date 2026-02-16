# 🚀 Inicio Rápido para Windows

## ¿Estás en Windows y no sabes cómo ejecutar el proyecto?

### ✅ Solución Rápida: WSL2 (Recomendado)

1. **Abrir PowerShell como Administrador**
   - Click derecho en el botón de Windows
   - Seleccionar "Windows PowerShell (Administrador)"

2. **Instalar WSL2:**
   ```powershell
   wsl --install
   ```

3. **Reiniciar tu computadora**

4. **Abrir Ubuntu desde el menú de inicio**

5. **Instalar dependencias:**
   ```bash
   sudo apt update
   sudo apt install -y ruby-full build-essential nodejs npm postgresql postgresql-contrib git
   sudo gem install bundler
   ```

6. **Configurar PostgreSQL:**
   ```bash
   sudo service postgresql start
   sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Junio.2021';"
   ```

7. **Clonar y ejecutar:**
   ```bash
   cd ~
   git clone https://github.com/Cristian-Quiza/Pmonokera.git
   cd Pmonokera
   ./start_services.sh
   ```

8. **Abrir en tu navegador de Windows:**
   http://localhost:3000

---

## 🔴 El Error que Estás Viendo

Si ves este error:
```
cd : No se encuentra la ruta de acceso 'C:\home\runner\work\Pmonokera\Pmonokera' porque no existe.
```

**Significa:** Estás intentando ejecutar comandos de Linux en PowerShell de Windows.

**Solución:** 
- Opción A: Usa WSL2 (instrucciones arriba) ✅ RECOMENDADO
- Opción B: Usa los scripts de PowerShell (`.\start_services.ps1`)

---

## 📝 Alternativa: Scripts PowerShell (Windows Nativo)

Si no quieres usar WSL2:

1. **Instalar requisitos:**
   - Ruby: https://rubyinstaller.org/ (versión 3.2+ con DevKit)
   - PostgreSQL: https://www.postgresql.org/download/windows/
   - Node.js: https://nodejs.org/

2. **Clonar el proyecto:**
   ```powershell
   cd C:\Users\TuUsuario
   git clone https://github.com/Cristian-Quiza/Pmonokera.git
   cd Pmonokera
   ```

3. **Permitir scripts PowerShell:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Ejecutar:**
   ```powershell
   .\start_services.ps1
   ```

---

## 🆘 ¿Necesitas Ayuda?

Ver documentación completa en: [INSTRUCCIONES_WINDOWS.md](INSTRUCCIONES_WINDOWS.md)

---

## ⚡ ¿Por Qué WSL2 es Mejor?

- ✅ **Gratis** y viene con Windows 10/11
- ✅ **Rápido** - rendimiento casi nativo
- ✅ **Compatible 100%** - corre Linux dentro de Windows
- ✅ **Fácil** - un comando para instalarlo
- ✅ **No requiere** modificar el código del proyecto

---

## 🎯 Resumen Ultra-Rápido

```powershell
# En PowerShell como Admin:
wsl --install

# Reiniciar

# En Ubuntu:
sudo apt install -y ruby-full nodejs npm postgresql git
sudo service postgresql start
git clone https://github.com/Cristian-Quiza/Pmonokera.git
cd Pmonokera && sudo gem install bundler && ./start_services.sh

# Abrir: http://localhost:3000
```

**¡Ya está! 🎉**
