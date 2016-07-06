#!/bin/bash
nodemcu-tool upload --compile --optimize *.lua
nodemcu-tool upload --compile --optimize routes/*.lua
nodemcu-tool upload static/*
nodemcu-tool upload init.lua
