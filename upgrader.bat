@echo off
:: This script launches the PowerShell file in the same directory. This is necessary so that upgrades can be performed simply by double-clicking.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0upgrader.ps1""' -Verb RunAs}"
