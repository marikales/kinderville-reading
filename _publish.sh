#!/usr/bin/env bash
# Публикация вики «Чтение по Мельниковой».
# Источник правды по КОНТЕНТУ страниц — мастер-папка ниже (там же лежат _source-* и
# внутренние заметки, которые НА САЙТ НЕ идут). Навигацию (_sidebar.md, README.md,
# index.html) правим прямо здесь, в репозитории сайта.
#
# Синхронизируется ТОЛЬКО белый список: пронумерованные страницы NN-*.md,
# КРОМЕ 06 (внутренняя записка «развилки на Марику» — не для публики).
# Никакие _source-*, _BRIEF, _SESSION-PARK и т.п. не копируются.
#
# Запуск:  bash _publish.sh          # синк + показать diff
#          bash _publish.sh --push   # синк + commit + push на GitHub Pages
set -euo pipefail

MASTER="$HOME/kinderville-y12/melnikova"
SITE="$(cd "$(dirname "$0")" && pwd)"
EXCLUDE="06-otkrytye-vhody-i-razvilki.md"

echo "Мастер: $MASTER"
echo "Сайт:   $SITE"
n=0
for f in "$MASTER"/[0-9][0-9]-*.md; do
  base="$(basename "$f")"
  [ "$base" = "$EXCLUDE" ] && { echo "  пропуск (внутреннее): $base"; continue; }
  if ! cmp -s "$f" "$SITE/$base"; then
    cp "$f" "$SITE/$base"; echo "  обновлено: $base"; n=$((n+1))
  fi
done
echo "Изменено страниц: $n"

cd "$SITE"
if [ "${1:-}" = "--push" ]; then
  git add -A
  git commit -m "publish: синк контента из мастера" || { echo "нечего коммитить"; exit 0; }
  git push origin main
  echo "Опубликовано → https://marikales.github.io/kinderville-reading/"
else
  echo "--- git status ---"; git status -s
  echo "(запусти с --push, чтобы опубликовать)"
fi
