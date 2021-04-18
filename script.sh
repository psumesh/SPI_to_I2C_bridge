#!/bin/bash
echo "commit_message : "
read commit_message

git status
git add .
git commit -m commit_message
git push https://github.com/psumesh/SPI_to_I2C_bridge.git master

