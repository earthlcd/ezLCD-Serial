----------------------------------------------------------------------
-- ezLCD Serial Communications test application example
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
	result = ez.PutPictFile(0, 0, "/Serial/background.jpg")
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
		weight_max = 0.0
	end

	ez.Button(id, event)
	str = "id=" .. tostring(id) ..  ", event=" .. tostring(event)
	ez.SerialTx(str .. "\r\n", 80, debug_port)

end 

fn = 14
font_height = 240 / 8 -- = 30

weight = 0.0
tare = 0
update_tare = true
update_max = true
weight_max = -10000.0
pin = 0

-- Wait 10 seconds for USB to enumerate
-- ez.Wait_ms(10000)

-- open the RS-232 port
ez.SerialOpen("DebugPortReceiveFunction", debug_port)
ez.SerialTx("**********************************************************************\r\n", 80, debug_port)
ez.SerialTx("* EarthLCD Load Cell Scale\r\n", 80, debug_port)
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

ez.SerialTx("ez.I2CopenMaster\r\n", 80, debug_port)
result = ez.I2CopenMaster()

ez.SerialTx("NAU7802_isConnected\r\n", 80, debug_port)
result = NAU7802_isConnected()

ez.SerialTx("NAU7802_begin\r\n", 80, debug_port)
result = NAU7802_begin(true) -- return boolean


local graph_xmin = 10
local graph_xmax = 310
local graph_x = graph_xmin

local graph_ymid = 150
local graph_ymin =  81
local graph_ymax = 230
local graph_y = graph_ymid
local last_graph_x = graph_x
local last_graph_y = graph_y

while 1 do
	-- If a new weight is available then read it and update the screen
	if NAU7802_available() == true then
		local raw_weight
		raw_weight = NAU7802_getReading()
		-- Convert the intenger weight to a floating point value
		local weight_new = (raw_weight - tare) + .0

		-- Scale the weight (need to add calibration here)
		-- NIST Tractable Calibration (National Institute of Squats and Treadmills)
		weight_new = weight_new / 1000.0 * 0.909090909 / 93.5 -- load = 0.909090909, reading with load
		-- Add a low pass filter to suppress ADC noise
		weight = weight * 0.7 + weight_new * 0.3

		-- If the update_tare button was pressed then calculate a new tare.
		if update_tare == true then
			update_tare = false
			tare = raw_weight
			str = "tare=" .. tostring(tare) .. ", weight=" .. string.format("%0.1f", weight)
			ez.SerialTx(str .. "\r\n", 80, debug_port)
		end

		-- If update_clear button is pressed then clear the screen
		if update_max == true then
			titleScreen(fn)
		end
		if weight > weight_max or update_max == true then
			update_max = false
			weight_max = weight
			printBox(10, 40, 200, ez.RGB(0xee, 0xf2, 0xe8), ez.RGB(0x3e, 0x56, 0x22), font_height, "MAX: " .. string.format("%0.1f", weight_max))
			printBox(175, 40, 200, ez.RGB(0xee, 0xf2, 0xe8), ez.RGB(0x3e, 0x56, 0x22), font_height, "kg")
		end

		-- Draw the current weight on the screen
		printBox(74, 10, 175, ez.RGB(0xee, 0xf2, 0xe8), ez.RGB(0x3e, 0x56, 0x22), font_height, string.format("%0.1f", weight))
		printBox(175, 10, 200, ez.RGB(0xee, 0xf2, 0xe8), ez.RGB(0x3e, 0x56, 0x22), font_height, "kg")

		-- Offset weight to center of Y on graph
		graph_y = graph_ymid - math.floor(weight * 40)
		-- Limit graph y value to extents of y-axis on the graph
		if graph_y > graph_ymax then
			graph_y = graph_ymax
		end
		if graph_y < graph_ymin then
			graph_y = graph_ymin
		end
		-- Draw the weight graph on the screen
		-- ez.Plot( graph_x , graph_y, ez.RGB(0x3e, 0x56, 0x22) )
		ez.Line(last_graph_x, last_graph_y, graph_x, graph_y, ez.RGB(0x3e, 0x56, 0x22) )
		last_graph_x = graph_x
		last_graph_y = graph_y

		-- advance the x axis
		graph_x = graph_x + 1
		-- Limit graph x00 value to extents of x-axis on the graph
		if graph_x >= graph_xmax then
			graph_x = graph_xmin
			last_graph_x = graph_x
		end
	end
end

