for /R . %%f in (*.lua) do (
	java -jar unluac.jar %%~dpnf.lua > %%~dpnf_dec.lua
	copy /Y %%~dpnf_dec.lua %%~dpnf.lua
	del %%~dpnf_dec.lua
)
pause