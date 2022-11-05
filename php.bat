@echo off
::设置变量
SET Command=%1
docker exec -i wim_php php %Command%