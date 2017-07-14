--
-- statusd_tdd.lua
--
-- Copyright 2012, Olof Johansson <olof@ethup.se>
--

require 'posix'

local tdd_timer
local tdd_delay = 10 * 1000

local function runtests()
	local status = nil
	local home = os.getenv("HOME")
	local runner = home .. '/.notion/tdd-runner'

	if posix.stat(runner, 'type') == 'regular' then
		status = os.execute(runner)
	else
		return nil
	end

	if status == true then
		return true
	else
		return false
	end
end

local function update_tdd()
	local tdd = runtests()
	local status = "skip"
	statusd.inform('tdd_hint', 'hint')

	if tdd == true then
		status = "ok"
		statusd.inform('tdd_hint', 'important')
	elseif tdd == false then
		status = "not ok"
		statusd.inform('tdd_hint', 'critical')
	end

	statusd.inform('tdd', status)
	tdd_timer:set(tdd_delay, update_tdd)
end

tdd_timer = statusd.create_timer()
update_tdd()
