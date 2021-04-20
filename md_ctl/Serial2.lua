require('utils')
local M = require 'posix.termio'
local F = require 'posix.fcntl'
local U = require 'posix.unistd'
local band, bor = bit.band, bit.bor -- see utils


Serial = {}

function Serial:new(device, baudrate)
  local i_flag, o_flag, c_flag, l_flag, i_speed, o_speed, cc = 0,0,0,0,0,0,0
  local obj = {}
  obj.parity = "odd"
  obj.xonxoff = false
  obj.rtscts = true
  obj.stopbits = 1
  obj.baudrate = baudrate
  obj.fd = -1

  -- Setup parity
  if obj.parity ~= "none" then
    i_flag = bit.bor(i_flag, M.INPCK, M.ISTRIP)
  end

  -- Setup xonxoff
  if xonxoff then
    i_flag = bit.bor(i_flag, M.IXON, M.IXOFF)
  end

  --[[ CFLAG ]]
  --===========
  
  -- Enable receiver, ignore modem control lines
  c_flag = bit.bor(M.CREAD, M.CLOCAL)

  -- Setup data bits
  c_flag = bit.bor(c_flag, M.CS8)

  -- Setup parity
  if obj.parity == "even" then
    c_flag = bit.bor(c_flag, M.PARENB)
  elseif parity == "odd" then
    c_flag = bit.bor(c_flag, M.PARENB, M.PARODD)
  end

  -- Setup stop bits
  if obj.stopbits == 2 then
    c_flag = bit.bor(c_flag, M.CSTOPB)
  end

  -- Setup rtscts
  if obj.rtscts then
    c_flag = bit.bor(c_flag, M.CRTSCTS)
  end

  -- Setup baud rate
  c_flag = bit.bor(c_flag, 0x1008)

  --[[ ISPEED, OSPEED ]]
  --====================
  -- ispeed
  ispeed = 0x1008

  -- ospeed
  ospeed = 0x1008

  function obj:open()
    local fds, err, errnum = F.open(device, bit.bor(F.O_RDWR, F.O_NOCTTY))
    if not fds then
      print('Could not open serial port ' .. device .. ':', err, ':', errnum)
      os.exit(1)
    else
      self.fd = fds

      --[[ SET TTY ATTRIBUTES ]]
      --========================

      ok, errmsg = M.tcsetattr(self.fd, 0, {
         cflag = c_flag,
         iflag = i_flag,
         oflag = o_flag,
         lflag = l_flag,
         ispeed = i_speed,
         ospeed = o_speed,
         cc = {
            [M.VTIME] = 0,
            [M.VMIN] = 1,
         }
      })
      if not ok then error (err) end
    end
    return self.fd
  end


  function obj:read(fd, length, timeout)
    local data = ""
    chunk, err, errcode = U.read(fd, 128)
    if not chunk then error (err) end
    print(chunk)
  end

  function obj:write()
      
  end

  function obj:close()
    local ok, errmsg = U.close(self.fd)
    if not ok then error (errmsg) end
  end

  setmetatable(obj, self)
  self.__index = self; return obj

end

local serial = Serial:new("/dev/ttyS1", 115200)
local fd = serial:open()
serial:read(fd, 128, 1000)
serial:close()