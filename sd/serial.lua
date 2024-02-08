----------------------------------------------------------------------
-- ezLCD Serial Communications Example
--
-- Created  01/27/2024  -  Jacob Christ
----------------------------------------------------------------------


function printLine(font_height, line, str) -- Show a title sequence for the program
	local x1, y1, x2, y2
	-- Display Size -> 320x240 

	-- Erase Old Weight
	x1 = 0
	y1 = font_height * line
	x2 = 320
	y2 = font_height * line + font_height

	-- ez.BoxFill(x1,y1, x2,y2, ez.RGB(bg,bg,bg)) -- X, Y, Width, Height, Color
	ez.BoxFill(x1,y1, x2,y2, ez.RGB(0x17, 0x28, 0x15)) -- X, Y, Width, Height, Color

	-- Display Line
	-- ez.SetColor(ez.RGB(0,0,255))
	ez.SetColor(ez.RGB(0xee, 0xf2, 0xe8))
	ez.SetFtFont(fn, font_height * 0.70) -- Font Number, Height, Width
	ez.SetXY(x1, y1)
	print(str)
	-- ez.Wait_ms(200)
end

function printBox(x1, y1, x2, fg, bg, font_height, str) -- Show a title sequence for the program
	-- Erase Old Weight
	local y2 = y1 + font_height

	ez.BoxFill(x1,y1, x2,y2, bg) -- X, Y, Width, Height, Color

	-- Display Line
	ez.SetColor(fg)
	ez.SetFtFont(fn, font_height * 0.70) -- Font Number, Height, Width
	ez.SetXY(x1, y1)
	print(str)
end

function titleScreen(fn) -- Show a title sequence for the program
	local result
	ez.Cls(ez.RGB(0,0,0))

	ez.SetAlpha(255)
	ez.SetXY(0, 0)
	result = ez.PutPictFile(0, 0, "/Serial/background.bmp")
	ez.SerialTx("result=".. tostring(result) .. "\r\n", 80, debug_port) -- doesn't work

	printBox(240, 7, 300, ez.RGB(0x17, 0x28, 0x15), ez.RGB(0x95, 0xb4, 0x6a), font_height, "TARE")
	printBox(230, 42, 300, ez.RGB(0x17, 0x28, 0x15), ez.RGB(0x95, 0xb4, 0x6a), font_height, "CLEAR")
	printBox(74, 10, 175, ez.RGB(0xee, 0xf2, 0xe8), ez.RGB(0x3e, 0x56, 0x22), font_height, "Initializing...")

end


function readPin(fn, pin) -- Show a title sequence for the program
	printLine(font_height, 2, string.format("%0.0f", pin ) )
	-- ez.SetXY(x1 + 50, y1)
	-- print(string.format("%0.2f", ez.Pin(pin) ))
end

function display_pause()
	-- for i= 9,0,-1 do
	-- 	printLine(font_height, 1, string.format("%d", i) )
	-- 	ez.Wait_ms(100)
	-- end
	-- ez.Wait_ms(250)
end

debug_port = 0
update_tare = false
update_max = false

-- Event Handelers
-- Serial Port Event
function DebugPortReceiveFunction(byte)
	ez.SerialTx(byte, 1, debug_port)
end

-- Define the Button Event Handler
function ProcessButtons(id, event)
	-- TODO: Insert your button processing code here
	-- Display the image which corresponds to the event
	if id == 0 then
		update_tare = true
	end
	if id == 1 then
		update_max = true
	end

	ez.Button(id, event)
	str = "id=" .. tostring(id) ..  ", event=" .. tostring(event)
	ez.SerialTx(str .. "\r\n", 80, debug_port)

end 

fn = 14
font_height = 240 / 8 -- = 30

pin = 0

-- Wait 10 seconds for USB to enumerate
-- ez.Wait_ms(10000)

-- open the RS-232 port
ez.SerialOpen("DebugPortReceiveFunction", debug_port)
ez.SerialTx("**********************************************************************\r\n", 80, debug_port)
ez.SerialTx("* EarthLCD Serial Communications Example\r\n", 80, debug_port)
ez.SerialTx("**********************************************************************\r\n", 80, debug_port)
ez.SerialTx(ez.FirmVer .. "\r\n", 80, debug_port)
ez.SerialTx(ez.LuaVer .. "\r\n", 80, debug_port)
ez.SerialTx("S/N: " .. ez.SerialNo .. "\r\n", 80, debug_port)
ez.SerialTx(ez.Width .. "x" .. ez.Height .. "\r\n", 80, debug_port)

-- Setup button(s)
ez.Button(0, 1, -1, -11, -1, 210,  0, 110, 35) -- Tare button
ez.Button(1, 1, -1, -11, -1, 210, 35, 110, 35) -- Clear button
ez.Button(2, 1, -1, -11, -1, 0, 0, 50, 40)     -- Menu
ez.Button(3, 1, -1, -11, -1, 0, 80, 320, 150)  -- Plot Area


-- Start to receive button events
ez.SetButtonEvent("ProcessButtons")

-- Main
titleScreen(fn)
-- ez.Wait_ms(500)

while 1 do
	-- If the update_tare button was pressed then calculate a new tare.
	if update_tare == true then
		update_tare = false
	end

	-- If update_clear button is pressed then clear the screen
	if update_max == true then
		titleScreen(fn)
	end
end

