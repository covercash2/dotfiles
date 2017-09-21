#!/bin/bash

debug_port=9222
host_port=3000

chromium --remote-debugging-port=$debug_port https://localhost:$host_port
