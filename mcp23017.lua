---
-- @description Expands the ESP8266's GPIO to 8 more I/O pins via I2C with the MCP23017 I/O Expander
-- MCP23017 Datasheet: http://ww1.microchip.com/downloads/en/DeviceDoc/21919e.pdf
-- Tested on NodeMCU 0.9.5 build 20150213.
-- @date March 02, 2015
-- @author Miguel 
--  GitHub: https://github.com/AllAboutEE 
--  YouTube: https://www.youtube.com/user/AllAboutEE
--  Website: http://AllAboutEE.com
--------------------------------------------------------------------------------

local moduleName = ... 
local M = {}
_G[moduleName] = M 

-- Constant device address.
local MCP23017_ADDRESS = 0x20

-- These address are valid for IOCON.BANK = 0
-- Do not change IOCON.BANK

local MCP23017_IODIRA   = 0x00 -- IO direction (0=output, 1=input(default))
local MCP23017_IODIRB   = 0x01
local MCP23017_IPOLA    = 0x02 -- IO polarity (0=normal, 1=inverse)
local MCP23017_IPOLB    = 0x03
local MCP23017_GPINTENA = 0x04 -- Interrupt on change (0=disable, 1=enable)
local MCP23017_GPINTENB = 0x05
local MCP23017_DEFVALA  = 0x06 -- If GPINTEN=1 and INTCON=1, this register is used
local MCP23017_DEFVALB  = 0x07 --     to set definition of normal pin states
local MCP23017_INTCONA  = 0x08 -- Interrupt control (0=compare to last state
local MCP23017_INTCONB  = 0x09 --     1=compare to DEFFVAL)
local MCP23017_IOCON    = 0x0A -- IO configuration register( bank/mirror/seqop/disslw/haen/odr/intpol/unused)
local MCP23017_IOCON    = 0x0B
local MCP23017_GPPUA    = 0x0C -- Pull-up resistor (0=disabled, 1=enabled)
local MCP23017_GPPUB    = 0x0D
local MCP23017_INTFA    = 0x0E -- Interrupt flag (read only)(0=no interrupt pending, 1=Pin caused interrupt)
local MCP23017_INTFB    = 0x0F
local MCP23017_INTCAPA  = 0x10 -- Interrupt Capture (read only)(value of GPIO at time 
local MCP23017_INTCAPB  = 0x11
local MCP23017_GPIOA    = 0x12 -- Port value (read/write)
local MCP23017_GPIOB    = 0x13
local MCP23017_OLATA    = 0x14 -- Output latch (write)
local MCP23017_OLATB    = 0x15

-- Default value for i2c communication
local id = 0

-- pin modes for I/O direction
M.INPUT = 1
M.OUTPUT = 0

-- pin states for I/O i.e. on/off
M.HIGH = 1
M.LOW = 0

-- Weak pull-up resistor state
M.ENABLE = 1
M.DISABLE = 0

local function write(registerAddress, data)
    i2c.start(id)
    i2c.address(id,MCP23017_ADDRESS,i2c.TRANSMITTER) -- send MCP's address and write bit
    i2c.write(id,registerAddress)
    i2c.write(id,data)
    i2c.stop(id)
end

local function read(registerAddress)
    -- Tell the MCP which register you want to read from
    i2c.start(id)
    i2c.address(id,MCP23017_ADDRESS,i2c.TRANSMITTER) -- send MCP's address and write bit
    i2c.write(id,registerAddress)
    i2c.stop(id)
    i2c.start(id)
    -- Read the data form the register
    i2c.address(id,MCP23017_ADDRESS,i2c.RECEIVER) -- send the MCP's address and read bit
    local data = 0x00
    data = i2c.read(id,1) -- we expect only one byte of data
    i2c.stop(id)

    return string.byte(data) -- i2c.read returns a string so we convert to it's int value
end

function M.begin(address, pinSDA, pinSCL, speed)
    MCP23017_ADDRESS = bit.bor(MCP23017_ADDRESS,address)
    i2c.setup(id,pinSDA,pinSCL,speed)
end

function M.writeGPIOA(dataByte)
    write(MCP23017_GPIOA,dataByte)
end

function M.writeGPIOB(dataByte)
    write(MCP23017_GPIOB,dataByte)
end

function M.readGPIOA()
    return read(MCP23017_GPIOA)
end

function M.readGPIOB()
    return read(MCP23017_GPIOB)
end

function M.writeIODIRA(dataByte)
    write(MCP23017_IODIRA,dataByte)
end

function M.writeIODIRB(dataByte)
    write(MCP23017_IODIRB,dataByte)
end

function M.readIODIRA()
    return read(MCP23017_IODIRA)
end

function M.readIODIRB()
    return read(MCP23017_IODIRB)
end

function M.writeGPPUA(dataByte)
    write(MCP23017_GPPUA,dataByte)
end

function M.writeGPPUB(dataByte)
    write(MCP23017_GPPUB,dataByte)
end

function M.readGPPUA()
    return read(MCP23017_GPPUA)
end

function M.readGPPUB()
    return read(MCP23017_GPPUB)
end

function M.readINTCAPA()
    return read(MCP23017_INTCAPA)
end

function M.readINTCAPB()
    return read(MCP23017_INTCAPB)
end

function M.writeIPOLA(dataByte)
    return write(MCP23017_IPOLA, dataByte)
end

function M.writeIPOLB(dataByte)
    return write(MCP23017_IPOLB, dataByte)
end

function M.writeGPINTENA(dataByte)
    return write(MCP23017_GPINTENA, dataByte)
end

function M.writeGPINTENB(dataByte)
    return write(MCP23017_GPINTENB, dataByte)
end

function M.writeDEFVALA(dataByte)
    return write(MCP23017_DEFVALA, dataByte)
end

function M.writeDEFVALB(dataByte)
    return write(MCP23017_DEFVALB, dataByte)
end

function M.writeINTCONA(dataByte)
    return write(MCP23017_INTCONA, dataByte)
end

function M.writeINTCONB(dataByte)
    return write(MCP23017_INTCONB, dataByte)
end

return M