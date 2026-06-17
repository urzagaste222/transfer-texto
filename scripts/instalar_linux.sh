#!/bin/bash
# Instalador para Linux Mint

set -e

echo "🔄 Instalando Transfer Texto - Servidor..."

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 no está instalado. Instalando..."
    sudo apt update
    sudo apt install python3 python3-pip -y
fi

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
    git clone https://github.com/TU_USUARIO/transfer-texto.git ~/transfer_texto_temp
    cp -r ~/transfer_texto_temp/* ~/transfer_texto/
    rm -rf ~/transfer_texto_temp
fi

cd ~/transfer_texto

# Instalar dependencias
echo "📦 Instalando dependencias..."
pip3 install --user -r requirements.txt || true

# Crear enlaces simbólicos
ln -sf ~/transfer_texto/src/servidor.py ~/.local/bin/transfer-server
chmod +x ~/transfer_texto/src/servidor.py
chmod +x ~/.local/bin/transfer-server

# Agregar a PATH si no existe
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Crear script de inicio rápido
cat > ~/.local/bin/transfer-server-start << 'EOF'
#!/bin/bash
nohup transfer-server > ~/transfer_texto.log 2>&1 &
echo "✅ Servidor iniciado en background"
echo "📋 Logs: ~/transfer_texto.log"
EOF
chmod +x ~/.local/bin/transfer-server-start

echo "✅ Instalación completa!"
echo ""
echo "📋 Comandos disponibles:"
echo "   transfer-server              # Iniciar servidor interactivo"
echo "   transfer-server-start        # Iniciar servidor en background"
echo "   transfer-server --help       # Mostrar ayuda"
echo ""
echo "🌐 Tu IP local:"
hostname -I | awk '{print $1}'
echo ""
echo "📱 En Termux, usa: transfer-client"
