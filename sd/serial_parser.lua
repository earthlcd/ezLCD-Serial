----------------------------------------------------------------------
-- ezLCD Serial Break Example
--
-- This example demonstrates how to use the serial port to stop the
-- Lua script.  The script will run until a "b" is received on the
-- serial port.  The script will then stop.
--
-- Created  01/27/2024  -  Jacob Christ
----------------------------------------------------------------------

-- Set debug_port to one of thsee Serial Port Numbers:
-- 0=Main UART (default, USART2 on ezLCD-5035)
-- 1=Second UART (USART3 on ezLCD-5035)
-- 2=USB Virtual Comm Port
-- 3=ESP32 UART0
-- 4=Third UART (SE-2023 RS232)
debug_port = 2 -- USB Virtual Comm Port


CommandBuffer = ""		-- Used to hold incomming characters until we see an end of line
CommandFound = false 	-- Flag to indicate when we have received a command
Command = "" 			-- Command to parse in the parser
-----------------------
-- Event Handelers
-----------------------
-- Serial Port Event
function DebugPortReceiveFunction(byte)
	-- ez.SerialTx(byte, debug_port, 1) -- Uncomment to echo character back as they are received
	if byte == 13 or byte == 10 then
		if string.len(CommandBuffer) > 0 then
			Command = CommandBuffer
			CommandBuffer = ""
			CommandFound = true

			-- ez.SetXY(0,0)
			print("Command:" .. Command .. "\r\n")
			ez.SerialTx("Command:" .. Command .. "\r\n", debug_port, 80)
		end
	else
		CommandBuffer = CommandBuffer .. string.char(byte)
	end
end

-----------------------
-- Main
-----------------------

ez.Cls(ez.RGB(255,0,255))
-- Make the font a blue-ish white color
ez.SetColor(ez.RGB(200,200,255))
print("serial_parser.lua")
print("")
print("  Commands:")
print("    about, red, green, blue, break")

-- open the RS-232 port
ez.SerialOpen("DebugPortReceiveFunction", debug_port)

-- Main
while 1 do
	-- ez.SerialTx("looping...\r\n", debug_port, 80)
	-- ez.Cls(ez.RGB(255,0,255))
	-- ez.Wait_ms(2500)

	if CommandFound == true then
		if Command == "about" then
			ez.SerialTx("**********************************************************************\r\n", debug_port, 80)
			ez.SerialTx("* EarthLCD Serial Communications Break Example\r\n", debug_port, 80)
			ez.SerialTx("**********************************************************************\r\n", debug_port, 80)
			ez.SerialTx(ez.FirmVer .. "\r\n", debug_port, 80)
			ez.SerialTx(ez.LuaVer .. "\r\n", debug_port, 80)
			ez.SerialTx("S/N: " .. ez.SerialNo .. "\r\n", debug_port, 80)
			ez.SerialTx(ez.Width .. "x" .. ez.Height .. "\r\n", debug_port, 80)
		end
		if Command == "red" then
			ez.Cls(ez.RGB(255,0,0)) -- Change the screen color to red
		end
		if Command == "green" then
			ez.Cls(ez.RGB(0,255,0)) -- Change the screen color to green
		end
		if Command == "blue" then
			ez.Cls(ez.RGB(0,0,255)) -- Change the screen color to green
		end
		if Command == "hello" then
			ez.SerialTx("back at ya\r\n", debug_port, 80)
		end
		if Command == "break" then
			ez.SerialTx("Lua Stopped\r\n", debug_port, 80)
			ez.Cls(ez.RGB(0,0,0))
			break
		end
		CommandFound = false
	end
end

-- Clear the screen
ez.Cls(ez.RGB(0,0,0))
-- Make the font a blue-ish white color
ez.SetColor(ez.RGB(200,200,255))
print("Exiting serial_parser.lua")

ez.SerialTx("Exited main loop\r\n", debug_port, 80)
ez.SerialClose(debug_port)

