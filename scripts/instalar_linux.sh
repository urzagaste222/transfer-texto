#!/bin/bash
# Instalador robusto para Linux Mint

set -e

echo "🔄 Instalando Transfer Texto - Servidor..."

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Funciones
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Verificar Python
if ! command -v python3 &> /dev/null; then
    print_warning "Python3 no está instalado. Instalando..."
    sudo apt update
    sudo apt install python3 python3-pip python3-venv -y
fi

# Crear directorios
mkdir -p ~/.local/bin
mkdir -p ~/transfer_texto

# Clonar repositorio
if [ -d ~/transfer_texto/.git ]; then
    print_success "Actualizando repositorio..."
    cd ~/transfer_texto
    git pull
else
    print_success "Descargando repositorio..."
    git clone https://github.com/urzagaste222/transfer-texto.git ~/transfer_texto_temp
    cp -r ~/transfer_texto_temp/* ~/transfer_texto/
    rm -rf ~/transfer_texto_temp
fi

cd ~/transfer_texto

# Verificar si necesitamos entorno virtual
if [ -f "requirements.txt" ] && [ -s "requirements.txt" ]; then
    print_warning "Se detectaron dependencias externas. Usando entorno virtual..."
    
    # Crear entorno virtual
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # Script con entorno virtual
    cat > ~/.local/bin/transfer-server << 'EOF'
#!/bin/bash
cd ~/transfer_texto
source venv/bin/activate
python servidor.py "$@"
EOF
else
    print_success "No se requieren dependencias externas. Usando Python del sistema..."
    
    # Script sin entorno virtual
    cat > ~/.local/bin/transfer-server << 'EOF'
#!/bin/bash
cd ~/transfer_texto
python3 servidor.py "$@"
EOF
fi

chmod +x ~/.local/bin/transfer-server

# Script para background
cat > ~/.local/bin/transfer-server-start << 'EOF'
#!/bin/bash
cd ~/transfer_texto
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    nohup python servidor.py > ~/transfer_texto.log 2>&1 &
else
    nohup python3 servidor.py > ~/transfer_texto.log 2>&1 &
fi
echo "✅ Servidor iniciado en background"
echo "📋 Logs: ~/transfer_texto.log"
echo "🛑 Para detener: pkill -f servidor.py"
EOF
chmod +x ~/.local/bin/transfer-server-start

# Agregar a PATH
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo ""
print_success "¡Instalación completa!"
echo ""
echo "📋 Comandos disponibles:"
echo "   transfer-server              # Iniciar servidor interactivo"
echo "   transfer-server-start        # Iniciar servidor en background"
echo "   pkill -f servidor.py         # Detener servidor"
echo ""
echo "🌐 Tu IP local:"
hostname -I | awk '{print $1}'
echo ""
echo "📱 En Termux, usa: transfer-client"
echo ""
echo "🔄 Recarga tu terminal: source ~/.bashrc"
