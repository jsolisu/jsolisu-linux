#!/bin/bash
# At first time run the following command (if needed):
# sudo apt install net-tools
netstat -ntu | awk '{print $5}' | sed '1,2d' | cut -d: -f1 | sort | uniq -c | sort -n