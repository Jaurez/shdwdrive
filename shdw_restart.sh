#!/bin/bash

echo -n "" > restart.log

echo "### - Restarting Shdw-Node Service - ###"
sudo systemctl restart shdw-node
echo ""
echo ""

echo "### - Shdw-Node Service Status - ###"
sudo systemctl status shdw-node
echo ""
echo ""

echo "### - Starting Logmonitor Service - ###"
sudo systemctl start logmonitor