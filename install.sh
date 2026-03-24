#!/bin/bash

# Pega o caminho absoluto da pasta onde este script install.sh está localizado
# Isso evita erros se o usuário rodar o script de fora da pasta
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPT_NAME="rieux_data_upload.sh"
SHELL_RC=""

echo "--- 🛠️  Configurando rieux_data_upload ---"

# 1. Garante que o script principal existe e é executável
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    echo "✔ Permissões de execução ok."
else
    echo "✖ Erro: Não encontrei $SCRIPT_NAME em $INSTALL_DIR"
    exit 1
fi

# 2. Detecta o Shell do usuário
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "⚠ Shell não reconhecido. Adicione 'source $INSTALL_DIR/$SCRIPT_NAME' manualmente ao seu config."
    exit 1
fi

# 3. Adiciona ao arquivo de configuração (sem duplicar)
LINE_TO_ADD="source $INSTALL_DIR/$SCRIPT_NAME"

if grep -qF "$LINE_TO_ADD" "$SHELL_RC"; then
    echo "ℹ A configuração já existe no seu $SHELL_RC."
else
    # Remove caminhos antigos do mesmo script para evitar conflitos se o usuário moveu a pasta
    sed -i '' "/source.*$SCRIPT_NAME/d" "$SHELL_RC" 2>/dev/null || sed -i "/source.*$SCRIPT_NAME/d" "$SHELL_RC"
    
    echo -e "\n# Rieux Data Upload\n$LINE_TO_ADD" >> "$SHELL_RC"
    echo "✔ Caminho atualizado com sucesso em $SHELL_RC!"
fi

echo "--- ✅ Tudo pronto! ---"
echo "Para ativar agora, rode: source $SHELL_RC"
