package.path = '../?.lua'
require('utils')
require("Serial")
require('tests.test')

--------------------------------------------------------------------------------

local device = "/dev/ttyUSB2"

--------------------------------------------------------------------------------

local dev = arg[1] or device
--serial = Serial:new(dev, 115200)


function test_open_config_close()
    local serial = nil

    ptest()
    passert_periphery_success("open serial", function () serial = Serial:new(dev, 115200); serial:open() end)
    passert("baudrate is 115200", serial.baudrate == 115200)
    passert("port initialised: " .. dev, serial.fd ~= nil)
    
    --passert_periphery_error("invalid baud rate", function () serial = Serial:new{device, baudrate=115200} end, "SERIAL_ERROR_ARG")

end


test_open_config_close()
pokay("Open & Config & Close tests passed.")

