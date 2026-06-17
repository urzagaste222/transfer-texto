#!/data/data/com.termux/files/usr/bin/bash
# Instalador para Termux

set -e

echo "🔄 Instalando Transfer Texto - Cliente..."

# Actualizar paquetes
pkg update -y
pkg upgrade -y

# Instalar dependencias
pkg install python git -y

# Crear directorio
mkdir -p ~/.local/bin
mkdir -p ~/transfer_texto

# Clonar o descargar repositorio
if [ -d ~/transfer_texto/.git ]; then
    echo "📦 Actualizando repositorio..."
    cd ~/transfer_texto
    git pull
else
    echo "📦 Descargando repositorio..."
    git clone https://github.com/urzagaste222/transfer-texto.git ~/transfer_texto_temp
    cp -r ~/transfer_texto_temp/* ~/transfer_texto/
    rm -rf ~/transfer_texto_temp
fi

cd ~/transfer_texto

# Instalar dependencias
echo "📦 Instalando dependencias..."
pip install -r requirements.txt || true

# Crear enlaces simbólicos
ln -sf ~/transfer_texto/src/cliente.py ~/.local/bin/transfer-client
chmod +x ~/transfer_texto/src/cliente.py
chmod +x ~/.local/bin/transfer-client

# Agregar a PATH
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Crear alias para acceso rápido
echo "alias tc='transfer-client'" >> ~/.bashrc

echo "✅ Instalación completa!"
echo ""
echo "📋 Comandos disponibles:"
echo "   transfer-client              # Iniciar cliente"
echo "   tc                           # Atajo rápido"
echo ""
echo "📱 Uso:"
echo "   1. Ejecuta: transfer-client"
echo "   2. Ingresa la IP del servidor Linux Mint"
echo "   3. Comienza a enviar mensajes"
