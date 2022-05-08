#!/bin/bash
# At first time run the following command (if needed):
# sudo apt install net-tools
netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n