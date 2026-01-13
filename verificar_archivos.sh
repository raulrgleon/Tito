#!/bin/bash
# Script para verificar que todos los archivos Swift existan

echo "Verificando archivos Swift..."
echo ""

missing_files=0

check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ FALTA: $1"
        missing_files=$((missing_files + 1))
    fi
}

echo "=== Archivos principales ==="
check_file "Tito/TitoApp.swift"
check_file "Tito/ContentView.swift"
echo ""

echo "=== Models ==="
check_file "Tito/Models/Preset.swift"
check_file "Tito/Models/StreamConfig.swift"
check_file "Tito/Models/StreamState.swift"
check_file "Tito/Models/Telemetry.swift"
echo ""

echo "=== Services ==="
check_file "Tito/Services/AudioService.swift"
check_file "Tito/Services/CameraService.swift"
check_file "Tito/Services/EncoderService.swift"
check_file "Tito/Services/KeychainService.swift"
check_file "Tito/Services/NetworkMonitor.swift"
check_file "Tito/Services/RTMPService.swift"
echo ""

echo "=== ViewModels ==="
check_file "Tito/ViewModels/OnboardingViewModel.swift"
check_file "Tito/ViewModels/SettingsViewModel.swift"
check_file "Tito/ViewModels/StreamViewModel.swift"
echo ""

echo "=== Views ==="
check_file "Tito/Views/ConnectView.swift"
check_file "Tito/Views/DiagnosticsView.swift"
check_file "Tito/Views/EndView.swift"
check_file "Tito/Views/LiveView.swift"
check_file "Tito/Views/OnboardingView.swift"
check_file "Tito/Views/PreviewView.swift"
echo ""

if [ $missing_files -eq 0 ]; then
    echo "✅ Todos los archivos existen físicamente"
    echo ""
    echo "⚠️  El problema es que NO están agregados al target en Xcode"
    echo ""
    echo "SOLUCIÓN:"
    echo "1. Abre Xcode"
    echo "2. Arrastra las carpetas Models, Services, ViewModels, Views desde Finder al proyecto"
    echo "3. Asegúrate de marcar el target 'Tito'"
else
    echo "❌ Faltan $missing_files archivos"
fi
