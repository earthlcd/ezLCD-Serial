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
-- 0=Main UART (default)
-- 1=Second UART
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

-- open the RS-232 port
ez.SerialOpen("DebugPortReceiveFunction", debug_port)

-- Main
while 1 do
	if CommandFound == true then
		if Command == "break" then
			ez.SerialTx("Lua Stopped\r\n", debug_port, 80)
			ez.Cls(ez.RGB(0,0,0))
			break
		end
		CommandFound = false
	end
end

ez.SerialTx("Exited main loop\r\n", debug_port, 80)
ez.SerialClose(debug_port)

