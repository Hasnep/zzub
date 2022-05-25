#!/usr/bin/env bash
poetry run uvicorn jackbox_test_server:app --host 0.0.0.0 --port 5000
