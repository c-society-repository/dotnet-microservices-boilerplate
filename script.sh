#!/bin/bash

# Configurações
SUBSCRIPTION_DLQ="nome-da-assinatura-dlq" # Nome da assinatura na DLQ
TOPICO_PRINCIPAL="nome-do-topico-principal" # Nome do tópico principal
PROJETO="nome-do-projeto" # Nome do projeto GCP
LIMIT=100 # Número de mensagens a processar por vez

# Função para consumir e reprocessar mensagens
while true; do
  echo "Puxando mensagens da DLQ..."

  # Puxar mensagens da assinatura
  MESSAGES=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_DLQ" \
    --project="$PROJETO" \
    --limit="$LIMIT" \
    --format="json")

  # Verificar se há mensagens
  if [ -z "$MESSAGES" ] || [ "$MESSAGES" == "[]" ]; then
    echo "Nenhuma mensagem encontrada. Fim do processo."
    break
  fi

  # Processar cada mensagem
  echo "$MESSAGES" | jq -c '.[]' | while read -r message; do
    # Extrair o conteúdo e o ackId
    ACK_ID=$(echo "$message" | jq -r '.ackId')
    DATA=$(echo "$message" | jq -r '.message.data' | base64 --decode)

    echo "Publicando mensagem no tópico principal: $DATA"

    # Publicar a mensagem no tópico principal
    gcloud pubsub topics publish "$TOPICO_PRINCIPAL" \
      --project="$PROJETO" \
      --message="$DATA"

    # Confirmar o recebimento da mensagem
    gcloud pubsub subscriptions ack "$SUBSCRIPTION_DLQ" \
      --project="$PROJETO" \
      --ack-ids="$ACK_ID"
  done
done
