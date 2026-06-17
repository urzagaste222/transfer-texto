#!/bin/bash
# Desinstalador completo para Transfer Texto
# Compatible con todas las versiones

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_error() { echo -e "${RED}❌ $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

echo "🗑️ Desinstalando Transfer Texto..."
echo "========================================"

# 1. Detener procesos en ejecución
echo "🔍 Buscando procesos en ejecución..."
if pgrep -f "servidor.py" > /dev/null; then
    print_warning "Servidor en ejecución. Deteniendo..."
    pkill -f servidor.py 2>/dev/null || true
    sleep 1
    print_success "Servidor detenido"
else
    print_success "No hay procesos en ejecución"
fi

# 2. Eliminar directorio principal
echo "📁 Eliminando archivos del programa..."
if [ -d ~/transfer_texto ]; then
    rm -rf ~/transfer_texto
    print_success "Eliminado: ~/transfer_texto"
else
    print_warning "No encontrado: ~/transfer_texto"
fi

# 3. Eliminar directorio temporal (si existe)
if [ -d ~/transfer_texto_temp ]; then
    rm -rf ~/transfer_texto_temp
    print_success "Eliminado: ~/transfer_texto_temp"
fi

# 4. Eliminar enlaces simbólicos y scripts
echo "🔗 Eliminando comandos..."
scripts_to_remove=(
    "transfer-server"
    "transfer-server-start"
    "transfer-server-stop"
    "transfer-client"
    "transfer-status"
    "transfer-logs"
)

for script in "${scripts_to_remove[@]}"; do
    if [ -f ~/.local/bin/$script ]; then
        rm -f ~/.local/bin/$script
        print_success "Eliminado: ~/.local/bin/$script"
    fi
done

# También eliminar cualquier archivo transfer-* en .local/bin
if ls ~/.local/bin/transfer-* 2>/dev/null >/dev/null; then
    rm -f ~/.local/bin/transfer-*
    print_success "Eliminados todos los scripts transfer-*"
fi

# 5. Eliminar archivos de historial y logs
echo "📝 Eliminando archivos de datos..."
data_files=(
    "~/transfer_texto_historial.txt"
    "~/transfer_texto.log"
    "~/transfer_texto_error.log"
    "~/transfer_texto.pid"
    "~/transfer_texto_buffer.json"
)

for file in "${data_files[@]}"; do
    # Expandir ~ manualmente
    file_expanded=$(eval echo $file)
    if [ -f "$file_expanded" ]; then
        rm -f "$file_expanded"
        print_success "Eliminado: $file"
    fi
done

# 6. Eliminar alias del .bashrc
echo "🔧 Limpiando archivos de configuración..."
if [ -f ~/.bashrc ]; then
    # Crear backup
    cp ~/.bashrc ~/.bashrc.backup
    print_success "Backup creado: ~/.bashrc.backup"
    
    # Eliminar líneas relacionadas con transfer
    sed -i '/transfer-server/d' ~/.bashrc
    sed -i '/transfer-client/d' ~/.bashrc
    sed -i '/transfer-texto/d' ~/.bashrc
    sed -i '/transfer-/d' ~/.bashrc
    
    print_success "Alias eliminados de ~/.bashrc"
fi

# 7. Eliminar del .zshrc (si existe)
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup
    sed -i '/transfer-/d' ~/.zshrc
    print_success "Alias eliminados de ~/.zshrc"
fi

# 8. Limpiar PATH personalizado (si solo estaba para transfer)
if grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    # Verificar si hay otros scripts en .local/bin
    if [ -z "$(ls -A ~/.local/bin 2>/dev/null)" ]; then
        # Si .local/bin está vacío, podemos preguntar si eliminar la línea
        print_warning "El directorio ~/.local/bin está vacío"
        read -p "¿Eliminar ~/.local/bin y la entrada del PATH? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            sed -i '/export PATH="$HOME\/.local\/bin:$PATH"/d' ~/.bashrc
            rmdir ~/.local/bin 2>/dev/null || true
            print_success "~/.local/bin eliminado del PATH"
        fi
    fi
fi

# 9. Preguntar si eliminar el entorno virtual del sistema (pipx)
if command -v pipx &> /dev/null; then
    if pipx list | grep -q "transfer-texto"; then
        print_warning "Se detectó instalación con pipx"
        read -p "¿Eliminar también la instalación de pipx? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            pipx uninstall transfer-texto 2>/dev/null || true
            print_success "Instalación pipx eliminada"
        fi
    fi
fi

# 10. Resumen final
echo ""
echo "========================================"
print_success "¡Desinstalación completada!"
echo ""
echo "📋 Resumen de acciones:"
echo "   ✓ Procesos detenidos"
echo "   ✓ Archivos eliminados"
echo "   ✓ Scripts removidos"
echo "   ✓ Alias limpiados"
echo "   ✓ Configuración restaurada"
echo ""
echo "⚠️ Para aplicar los cambios:"
echo "   source ~/.bashrc"
echo "   o"
echo "   exec bash"
echo ""
echo "🔄 Si quieres reinstalar:"
echo "   curl -sL https://raw.githubusercontent.com/urzagaste222/transfer-texto/main/scripts/instalar_linux.sh | bash"
