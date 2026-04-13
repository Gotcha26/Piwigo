@echo off
:: ===========================================================================
:: Piwigo Core - devtools.bat - Tools box project manager
:: ===========================================================================
:: Usage : Double-cliquer sur ce fichier
:: ===========================================================================

REM Se placer à la racine du projet (deux niveaux au-dessus de local\scripts\)
cd /d "%~dp0..\.."

REM Lancer le script partagé avec le .env.db de ce projet
python "D:\Gotcha\Documents\DIY\GitHub\Piwigo\.local\scripts\devtools.py" "%~dp0.env.db"
