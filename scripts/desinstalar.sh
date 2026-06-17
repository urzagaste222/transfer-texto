#!/bin/bash
# Desinstalador

echo "🗑️ Desinstalando Transfer Texto..."

# Eliminar archivos
rm -rf ~/transfer_texto
rm -f ~/.local/bin/transfer-server
rm -f ~/.local/bin/transfer-client
rm -f ~/.local/bin/transfer-server-start

# Eliminar aliases (opcional)
# sed -i '/transfer-server/d' ~/.bashrc
# sed -i '/transfer-client/d' ~/.bashrc

echo "✅ Desinstalación completa!"
