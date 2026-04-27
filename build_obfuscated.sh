#!/bin/bash

echo "╔════════════════════════════════════════════╗"
echo "║     BUILD COM OFUSCAÇÃO - PIX MULTI        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

cd ~/pix_multi_final

# Limpar
echo "🧹 Limpando build anterior..."
flutter clean

# Dependencies
echo "📦 Atualizando dependências..."
flutter pub get

# Build ofuscado
echo "🔒 Buildando com ofuscação..."
echo ""
flutter build apk --release \
  --obfuscate \
  --split-debug-info=~/pix_multi_final/symbols

# Verificar
echo ""
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ Build concluído com sucesso!"
    echo ""
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    
    # Copiar para Downloads
    cp build/app/outputs/flutter-apk/app-release.apk ~/Downloads/pix_multi_final_v1.0_obfuscated.apk
    
    echo "📁 APK ofuscado: ~/Downloads/pix_multi_final_v1.0_obfuscated.apk"
    echo "📁 Símbolos: ~/pix_multi_final/symbols/"
    echo ""
    echo "⚠️  GUARDE OS SÍMBOLOS EM LOCAL SEGURO!"
    echo "   Eles são necessários para debug de crashes."
    echo ""
else
    echo "❌ Erro no build! Verifique os logs acima."
    exit 1
fi
