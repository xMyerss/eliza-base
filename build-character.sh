#!/bin/bash

# Variables iniciales (con valores predeterminados)
name=""
bio=""
lore=""
topics=""
adjectives=""
messageExamples=""
postExamples=""
modelProvider="google"
plugins=""
clients=""

# Procesar argumentos
for arg in "$@"; do
  case $arg in
    --name=*)
      name="${arg#*=}"
      shift
      ;;
    --bio=*)
      bio="${arg#*=}"
      shift
      ;;
    --lore=*)
      lore="${arg#*=}"
      shift
      ;;
    --topics=*)
      topics="${arg#*=}"
      shift
      ;;
    --adjectives=*)
      adjectives="${arg#*=}"
      shift
      ;;
    --messageExamples=*)
      messageExamples="${arg#*=}"
      shift
      ;;
    --postExamples=*)
      postExamples="${arg#*=}"
      shift
      ;;
    --modelProvider=*)
      modelProvider="${arg#*=}"
      shift
      ;;
    --plugins=*)
      plugins="${arg#*=}"
      shift
      ;;
    --clients=*)
      clients="${arg#*=}"
      shift
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# Validar parámetros obligatorios
if [ -z "$name" ]; then
  echo "Error: --name argument is required"
  exit 1
fi

# Función para convertir listas separadas por comas a formato JSON
format_list() {
  echo "$1" | tr ',' '\n' | sed 's/^/    "/;s/$/"/' | paste -sd, -
}

# Formatear listas
bioFormatted=$(format_list "$bio")
loreFormatted=$(format_list "$lore")
topicsFormatted=$(format_list "$topics")
adjectivesFormatted=$(format_list "$adjectives")
postExamplesFormatted=$(format_list "$postExamples")
pluginsFormatted=$(format_list "$plugins")
clientsFormatted=$(format_list "$clients")

# Mensajes de ejemplo formateados (si no se pasan, usa predeterminados)
if [ -z "$messageExamples" ]; then
  messageExamplesFormatted=$(cat <<EOF
[
    {
      "user": "{{user1}}",
      "content": {
        "text": "Hey $name, can you help me?"
      }
    },
    {
      "user": "$name",
      "content": {
        "text": "Sure, what's the issue?"
      }
    }
]
EOF
)
else
  messageExamplesFormatted=$(format_list "$messageExamples")
fi

# Generar el JSON completo
json=$(cat <<EOF
{
  "name": "$name",
  "plugins": [
    $pluginsFormatted
  ],
  "clients": [
    $clientsFormatted
  ],
  "modelProvider": "$modelProvider",
  "settings": {
    "secrets": {},
    "voice": {
      "model": "en_US-hfc_female-medium"
    }
  },
  "system": "Roleplay and generate interesting on behalf of $name.",
  "bio": [
    $bioFormatted
  ],
  "lore": [
    $loreFormatted
  ],
  "messageExamples": $messageExamplesFormatted,
  "postExamples": [
    $postExamplesFormatted
  ],
  "topics": [
    $topicsFormatted
  ],
  "style": {
    "all": [
      "very short responses",
      "never use hashtags or emojis",
      "response should be short, punchy, and to the point",
      "don't say ah yes or oh or anything",
      "don't offer help unless asked, but be helpful when asked",
      "don't ask rhetorical questions, its lame",
      "use plain american english language",
      "SHORT AND CONCISE"
    ],
    "chat": [],
    "post": []
  },
  "adjectives": [
    $adjectivesFormatted
  ]
}
EOF
)

# Crear el directorio y guardar el archivo
mkdir -p characters
echo "$json" > "characters/${name}.json"

echo "Character JSON created at characters/${name}.json"
