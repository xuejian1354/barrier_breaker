require "luci.fs"
require "luci.sys"
require "luci.util"

local inits = { }

f = SimpleForm("rc", translate("UartSocket Configuration"),
	translate("This is the content of /etc/uartsocket.conf. Edit it if you want changed."))

t = f:field(TextValue, "rcs")
t.rmempty = true
t.rows = 20

function t.cfgvalue()
	return luci.fs.readfile("/etc/uartsocket.conf") or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.rcs then
			luci.fs.writefile("/etc/uartsocket.conf", data.rcs:gsub("\r\n", "\n"))
			luci.sys.call("killall uartsocket >/dev/null")
			luci.sys.call("/usr/local/bin/uartsocket &")
		end
	end
	return true
end

return f

