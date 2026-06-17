#!/data/data/com.termux/files/usr/bin/bash
# Instalador para Termux (versión robusta)

set -e

echo "🔄 Instalando Transfer Texto - Cliente..."

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Actualizar paquetes
echo "📦 Actualizando repositorios..."
pkg update -y
pkg upgrade -y

# Instalar dependencias
echo "📦 Instalando dependencias..."
pkg install python git -y

# En Termux, instalar también estos paquetes útiles
pkg install termux-api -y  # Para notificaciones
pkg install openssl -y     # Para seguridad

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

# En Termux, Python no tiene el problema de "externally-managed"
# pero igual usamos entorno virtual por consistencia
if [ -f "requirements.txt" ] && [ -s "requirements.txt" ]; then
    print_warning "Instalando dependencias..."
    pip install --upgrade pip
    pip install -r requirements.txt || true
fi

# Crear script del cliente
cat > ~/.local/bin/transfer-client << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/transfer_texto
python cliente.py "$@"
EOF

chmod +x ~/.local/bin/transfer-client

# Crear script para enviar texto rápido
cat > ~/.local/bin/transfer-send << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Uso: transfer-send "IP" "Mensaje"
if [ $# -lt 2 ]; then
    echo "Uso: transfer-send IP MENSaje"
    echo "Ejemplo: transfer-send 192.168.1.100 'Hola desde Termux'"
    exit 1
fi
echo "$2" | nc -q 1 "$1" 5000
EOF
chmod +x ~/.local/bin/transfer-send

# Agregar a PATH
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Crear atajos
echo "alias tc='transfer-client'" >> ~/.bashrc
echo "alias ts='transfer-send'" >> ~/.bashrc

echo ""
print_success "¡Instalación completa!"
echo ""
echo "📋 Comandos disponibles:"
echo "   transfer-client              # Iniciar cliente interactivo"
echo "   tc                           # Atajo rápido para cliente"
echo "   transfer-send IP 'Mensaje'   # Enviar texto rápido"
echo "   ts IP 'Mensaje'              # Atajo para enviar"
echo ""
echo "📱 Uso:"
echo "   1. Ejecuta: transfer-client"
echo "   2. Ingresa la IP del servidor Linux Mint"
echo "   3. Comienza a enviar mensajes"
