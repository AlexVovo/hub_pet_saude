#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$PWD/data/datasus}"
mkdir -p "$TARGET_DIR"

echo "Downloading DATASUS public folders to: $TARGET_DIR"

lftp -e "
  set ftp:ssl-allow no
  set net:timeout 30
  mirror /dissemin/publicos/painel_oncologia $TARGET_DIR/painel_oncologia
  quit
" ftp://ftp.datasus.gov.br

lftp -e "
  set ftp:ssl-allow no
  set net:timeout 30
  mirror /dissemin/publicos/SIASUS/200801_/Dados $TARGET_DIR/SIASUS/200801_/Dados
  quit
" ftp://ftp.datasus.gov.br

lftp -e "
  set ftp:ssl-allow no
  set net:timeout 30
  mirror /dissemin/publicos/SIHSUS/200801_/Dados $TARGET_DIR/SIHSUS/200801_/Dados
  quit
" ftp://ftp.datasus.gov.br

echo "DATASUS sources fetched to $TARGET_DIR"
