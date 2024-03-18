#!/bin/bash

addgroup teeworlds
adduser \
  --comment "" \
  --home /home/teeworlds \
  --shell /bin/bash \
  --disabled-password \
  --ingroup users teeworlds

