#!/bin/bash

# Localiza onde o script principal está
INSTALL_DIR=$(pwd)
SCRIPT_NAME="rieux_data_upload.sh"
SHELL_RC=""

echo "--- Instalando rieux_data_upload ---"

# Garante permissão de execução
if [ -f "$SCRIPT_NAME" ]; then
    chmod +x "$SCRIPT_NAME"
    echo "✔ Script principal configurado como executável."
else
    echo "✖ Erro: $SCRIPT_NAME não encontrado."
    exit 1
fi

# Detecta o Shell (Mac costuma ser Zsh, Linux costuma ser Bash)
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "⚠ Shell não reconhecido. Adicione manualmente ao seu config."
    exit 1
fi

# Adiciona a função ao config do terminal
LINE_TO_ADD="source $INSTALL_DIR/$SCRIPT_NAME"
if grep -qF "$LINE_TO_ADD" "$SHELL_RC"; then
    echo "ℹ A função já está no seu $SHELL_RC."
else
    echo -e "\n# Rieux Data Upload\n$LINE_TO_ADD" >> "$SHELL_RC"
    echo "✔ Comando adicionado ao $SHELL_RC."
fi

echo "--- Concluído! ---"
echo "Para ativar agora, rode: source $SHELL_RC"
