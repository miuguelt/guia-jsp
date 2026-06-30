@echo off
cd /d "C:\Users\Miguel\Documents\Aplicaciones\_projects\guia-jsp\web"
npx.cmd browser-sync start --server . --files "**/*" --port 8024 --no-open --no-notify > "C:\Users\Miguel\Documents\Aplicaciones\_projects\guia-jsp\logs\browser-sync.log" 2> "C:\Users\Miguel\Documents\Aplicaciones\_projects\guia-jsp\logs\browser-sync_error.log" < NUL
