local m, s = ...

local api = require "luci.passwall.api"

if not api.is_finded("trojan-go") then
	return
end

local option_prefix = "trojan_go_"

local function option_name(name)
	return option_prefix .. name
end

local function rm_prefix_cfgvalue(self, section)
	if self.option:find(option_prefix) == 1 then
		return m:get(section, self.option:sub(1 + #option_prefix))
	end
end
local function rm_prefix_write(self, section, value)
	if self.option:find(option_prefix) == 1 then
		m:set(section, self.option:sub(1 + #option_prefix), value)
	end
end

local encrypt_methods_ss_aead = {
	"chacha20-ietf-poly1305",
	"aes-128-gcm",
	"aes-256-gcm",
}

-- [[ Trojan-Go ]]

s.fields["type"]:value("Trojan-Go", translate("Trojan-Go"))

o = s:option(Value, "trojan_go_port", translate("Listen Port"))
o.datatype = "port"

o = s:option(DynamicList, "trojan_go_uuid", translate("ID") .. "/" .. translate("Password"))
for i = 1, 3 do
	o:value(api.gen_uuid(1))
end

o = s:option(Flag, "trojan_go_tls", translate("TLS"))
o.default = 0
o.validate = function(self, value, t)
	if value then
		local type = s.fields["type"]:formvalue(t) or ""
		if value == "0" and type == "Trojan-Go" then
			return nil, translate("Original Trojan only supported 'tls', please choose 'tls'.")
		end
		if value == "1" then
			local ca = s.fields["trojan_go_tls_certificateFile"]:formvalue(t) or ""
			local key = s.fields["trojan_go_tls_keyFile"]:formvalue(t) or ""
			if ca == "" or key == "" then
				return nil, translate("Public key and Private key path can not be empty!")
			end
		end
		return value
	end
end

o = s:option(FileUpload, "trojan_go_tls_certificateFile", translate("Public key absolute path"), translate("as:") .. "/etc/ssl/fullchain.pem")
o.default = m:get(s.section, "tls_certificateFile") or "/etc/config/ssl/" .. arg[1] .. ".pem"
o:depends({ trojan_go_tls = true })
o.validate = function(self, value, t)
	if value and value ~= "" then
		if not nixio.fs.access(value) then
			return nil, translate("Can't find this file!")
		else
			return value
		end
	end
	return nil
end

o = s:option(FileUpload, "trojan_go_tls_keyFile", translate("Private key absolute path"), translate("as:") .. "/etc/ssl/private.key")
o.default = m:get(s.section, "tls_keyFile") or "/etc/config/ssl/" .. arg[1] .. ".key"
o:depends({ trojan_go_tls = true })
o.validate = function(self, value, t)
	if value and value ~= "" then
		if not nixio.fs.access(value) then
			return nil, translate("Can't find this file!")
		else
			return value
		end
	end
	return nil
end

o = s:option(Flag, "trojan_go_tls_sessionTicket", translate("Session Ticket"))
o.default = "0"
o:depends({ trojan_go_tls = true })

o = s:option(ListValue, "trojan_go_transport", translate("Transport"))
o:value("original", translate("Original"))
o:value("ws", "WebSocket")
o.default = "original"

o = s:option(ListValue, "trojan_go_plugin_type", translate("Transport Plugin"))
o:value("plaintext", "Plain Text")
o:value("shadowsocks", "ShadowSocks")
o:value("other", "Other")
o.default = "plaintext"
o:depends({ trojan_go_tls = false, trojan_go_transport = "original" })

o = s:option(Value, "trojan_go_plugin_cmd", translate("Plugin Binary"))
o.placeholder = "eg: /usr/bin/v2ray-plugin"
o:depends({ trojan_go_plugin_type = "shadowsocks" })
o:depends({ trojan_go_plugin_type = "other" })

o = s:option(Value, "trojan_go_plugin_option", translate("Plugin Option"))
o.placeholder = "eg: obfs=http;obfs-host=www.baidu.com"
o:depends({ trojan_go_plugin_type = "shadowsocks" })
o:depends({ trojan_go_plugin_type = "other" })

o = s:option(DynamicList, "trojan_go_plugin_arg", translate("Plugin Option Args"))
o.placeholder = "eg: [\"-config\", \"test.json\"]"
o:depends({ trojan_go_plugin_type = "shadowsocks" })
o:depends({ trojan_go_plugin_type = "other" })

o = s:option(Value, "trojan_go_ws_host", translate("WebSocket Host"))
o:depends({ trojan_go_transport = "ws" })

o = s:option(Value, "trojan_go_ws_path", translate("WebSocket Path"))
o:depends({ trojan_go_transport = "ws" })

o = s:option(Flag, "trojan_go_ss_aead", translate("Shadowsocks secondary encryption"))
o.default = "0"

o = s:option(ListValue, "trojan_go_ss_aead_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods_ss_aead) do o:value(v, v) end
o.default = "aes-128-gcm"
o:depends("trojan_go_ss_aead", true)

o = s:option(Value, "trojan_go_ss_aead_pwd", translate("Password"))
o.password = true
o:depends("trojan_go_ss_aead", true)

o = s:option(Flag, "trojan_go_tcp_fast_open", translate("TCP Fast Open"))
o.default = "0"

o = s:option(Flag, "trojan_go_remote_enable", translate("Enable Remote"), translate("You can forward to Nginx/Caddy/V2ray/Xray WebSocket and more."))
o.default = "1"
o.rmempty = false

o = s:option(Value, "trojan_go_remote_address", translate("Remote Address"))
o.default = "127.0.0.1"
o:depends({ trojan_go_remote_enable = true })

o = s:option(Value, "trojan_go_remote_port", translate("Remote Port"))
o.datatype = "port"
o.default = "80"
o:depends({ trojan_go_remote_enable = true })

o = s:option(Flag, "trojan_go_log", translate("Log"))
o.default = "1"

o = s:option(ListValue, "trojan_go_loglevel", translate("Log Level"))
o.default = "2"
o:value("0", "all")
o:value("1", "info")
o:value("2", "warn")
o:value("3", "error")
o:value("4", "fatal")
o:depends({ trojan_go_log = true })

for key, value in pairs(s.fields) do
	if key:find(option_prefix) == 1 then
		if not s.fields[key].not_rewrite then
			s.fields[key].cfgvalue = rm_prefix_cfgvalue
			s.fields[key].write = rm_prefix_write
		end

		local deps = s.fields[key].deps
		if #deps > 0 then
			for index, value in ipairs(deps) do
				deps[index]["type"] = "Trojan-Go"
			end
		else
			s.fields[key]:depends({ type = "Trojan-Go" })
		end
	end
end
