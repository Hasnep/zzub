#!/usr/bin/env bash

fdfind . | entr -c -r ./run.sh
