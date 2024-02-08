----------------------------------------------------------------------
-- ezLCD Serial Communications simple application example
--
-- Created  01/27/2024  -  Jacob Christ
----------------------------------------------------------------------

-- 0=Main UART (default)
-- 1=Second UART
-- 2=USB Virtual Comm Port
-- 3=ESP32 UART0
-- 4=Third UART (SE-2023 RS232)

debug_port = 2
stop_lua = 0
-- Event Handelers
-- Serial Port Event
function DebugPortReceiveFunction(byte)
	ez.SerialTx(byte, debug_port, 1)
	if byte == string.byte("b")  then
		ez.SerialTx("Found b", debug_port, 80)
		stop_lua = 1
	end
end

ez.Cls(ez.RGB(255,0,255))

-- open the RS-232 port
ez.SerialOpen("DebugPortReceiveFunction", debug_port)

-- Main
while 1 do
	-- Wait 10 seconds for USB to enumerate
	ez.Wait_ms(2500)
	ez.Cls(ez.RGB(255,0,0))
	ez.Wait_ms(2500)
	ez.Cls(ez.RGB(0,255,0))
	ez.SerialTx("**********************************************************************\r\n", debug_port, 80)
	ez.SerialTx("* EarthLCD Serial Communications Scale\r\n", debug_port, 80)
	ez.SerialTx("**********************************************************************\r\n", debug_port, 80)
	ez.SerialTx(ez.FirmVer .. "\r\n", debug_port, 80)
	ez.SerialTx(ez.LuaVer .. "\r\n", debug_port, 80)
	ez.SerialTx("S/N: " .. ez.SerialNo .. "\r\n", debug_port, 80)
	ez.SerialTx(ez.Width .. "x" .. ez.Height .. "\r\n", debug_port, 80)
	if stop_lua == 1 then
		ez.SerialTx("Lua Stopped\r\n", debug_port, 80)
		ez.Cls(ez.RGB(0,0,0))
		ez.SerialClose(debug_port)
		break
	end
end

