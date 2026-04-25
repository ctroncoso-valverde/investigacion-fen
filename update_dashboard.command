#!/bin/bash
# update_dashboard.command
# Actualiza el dashboard FEN: backup → reemplazo → push a GitHub
# Ejecutar con doble-clic en Finder o desde Terminal

REPO=~/Documents/Repositorio/Investigacion-FEN
BACKUPS=$REPO/_backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=================================================="
echo "  Dashboard FEN — Actualización"
echo "=================================================="
echo ""

# Ir al repo
cd "$REPO" || { echo "Error: no se encontró el repo en $REPO"; exit 1; }

# Crear carpeta de backups
mkdir -p "$BACKUPS"

# Verificar que hay archivos nuevos en Downloads
INDEX_DL=~/Downloads/index.html
PANEL_DL=~/Downloads/panel_investigacion.html

if [ ! -f "$INDEX_DL" ] && [ ! -f "$PANEL_DL" ]; then
  echo "⚠  No se encontró ningún archivo nuevo en ~/Downloads/"
  echo "   Genera primero los archivos desde el panel de administración."
  echo ""
  read -p "Presiona Enter para salir..."
  exit 1
fi

# Backup y reemplazo de index.html
if [ -f "$INDEX_DL" ]; then
  echo "→ index.html:"
  cp "$REPO/index.html" "$BACKUPS/index_$TIMESTAMP.html" 2>/dev/null && echo "  Backup guardado en _backups/index_$TIMESTAMP.html"
  mv "$INDEX_DL" "$REPO/index.html"
  echo "  Archivo reemplazado"
else
  echo "→ index.html: sin cambios"
fi

# Backup y reemplazo de panel_investigacion.html
if [ -f "$PANEL_DL" ]; then
  echo "→ panel_investigacion.html:"
  cp "$REPO/panel_investigacion.html" "$BACKUPS/panel_$TIMESTAMP.html" 2>/dev/null && echo "  Backup guardado en _backups/panel_$TIMESTAMP.html"
  mv "$PANEL_DL" "$REPO/panel_investigacion.html"
  echo "  Archivo reemplazado"
else
  echo "→ panel_investigacion.html: sin cambios"
fi

echo ""

# Mostrar diff
echo "Cambios a subir:"
git diff --stat
echo ""

# Confirmación
read -p "¿Confirmas el push a GitHub? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Push cancelado. Los archivos locales ya fueron reemplazados."
  echo "Para volver atrás, usa los archivos en _backups/"
  exit 0
fi

# Push
git add index.html panel_investigacion.html 2>/dev/null
git add index.html 2>/dev/null
git commit -m "Update dashboard - $TIMESTAMP"
git push origin main

echo ""
echo "✓ Push exitoso. GitHub Pages actualiza en ~1-2 minutos."
echo ""
