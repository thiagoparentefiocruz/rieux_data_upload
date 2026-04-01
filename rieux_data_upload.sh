#!/bin/bash

rieux_data_upload() {
    if [ "$#" -ne 2 ]; then
        echo "Uso: rieux_data_upload </caminho/pasta_local> <usuario@rieux:/caminho/pasta_remota>"
        return 1
    fi

    local LOCAL_DIR="$1"
    local REMOTE_DEST="$2"
    local REMOTE_HOST="${REMOTE_DEST%%:*}"
    local REMOTE_DIR="${REMOTE_DEST#*:}"

    echo "🚀 Iniciando pipeline de upload para o Rieux..."

    local OS_TYPE=$(uname -s)
    local CMD_HASH=()
    local CMD_RSYNC=()

    case "$OS_TYPE" in
        Darwin*)
            echo "🍎 Sistema detectado: macOS. Configurando caffeinate e shasum..."
            CMD_HASH=(shasum -a 256)
            CMD_RSYNC=(caffeinate -i rsync -avP)
            ;;
        Linux*)
            echo "🐧 Sistema detectado: Linux/WSL. Configurando sha256sum..."
            CMD_HASH=(sha256sum)
            CMD_RSYNC=(rsync -avP)
            ;;
        *)
            echo "❌ Sistema Operacional '$OS_TYPE' não suportado."
            return 1
            ;;
    esac

    local ORIGINAL_DIR=$(pwd)
    
    echo "---------------------------------------------------"
    echo "Calculando hashes locais (isso pode demorar)..."
    cd "$LOCAL_DIR" || return 1
    rm -f checksums_local.txt
    
    find . -type f ! -path '*/.*' ! -name "checksums_local.txt" -exec "${CMD_HASH[@]}" {} + > checksums_local.txt
    echo "✅ Checksums locais gerados."

    echo "---------------------------------------------------"
    echo "Iniciando transferência segura (rsync)..."
    
    "${CMD_RSYNC[@]}" ./ "$REMOTE_DEST/"

    if [ $? -ne 0 ]; then
        echo "❌ Erro ou interrupção na transferência."
        echo "Basta rodar o comando novamente para retomar de onde parou."
        cd "$ORIGINAL_DIR"
        return 1
    fi
    echo "✅ Transferência concluída."

    echo "---------------------------------------------------"
    echo "Verificando a integridade dos dados no Rieux..."
    
    ssh "$REMOTE_HOST" "cd '$REMOTE_DIR' && sha256sum -c checksums_local.txt"

    if [ $? -eq 0 ]; then
        echo "---------------------------------------------------"
        echo "🎉 SUCESSO! Todos os arquivos foram transferidos e conferidos."
    else
        echo "---------------------------------------------------"
        echo "⚠️ AVISO: A verificação falhou para um ou mais arquivos. Cheque o log."
    fi

    cd "$ORIGINAL_DIR"
}

rieux_data_upload "$@"
