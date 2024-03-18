#!/bin/bash
set -euo pipefail

if ! grep -q '^teeworlds:' /etc/passwd
then
  addgroup teeworlds
  adduser \
    --comment "" \
    --home /home/teeworlds \
    --shell /bin/bash \
    --disabled-password \
    --ingroup users teeworlds
fi

if ! grep -q '^chiller:' /etc/passwd
then
  addgroup admin
  useradd \
    --shell /bin/bash \
    --create-home \
    --groups admin \
    --home-dir /home/chiller chiller
fi

printf '[*] done all users created.\n'

