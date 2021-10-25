#!/bin/sh

if [ -f "$CUST_SHELL_FILE" ]; then
  sh "$CUST_SHELL_FILE"
fi

ehforwarderbot
