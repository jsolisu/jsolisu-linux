#!/bin/bash
grep '^sudo:.*$' /etc/group | cut -d: -f4