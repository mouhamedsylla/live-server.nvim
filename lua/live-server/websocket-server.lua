local M = {}
local http_server = require("http.server")
local websocket = require("http.websocket")
local check_directory = require("file_watcher")

local ws_clients = {}
local running = true

local function notify_clients()
	for _, ws in ipairs(ws_clients) do
		ws:send("reload")
	end
end

M.ws = function(directory)
	local server = assert(http_server.listen({
		host = "0.0.0.0",
		port = 5001,
		onstream = function(server, stream)
			local req = stream:get_headers()
			local path = req:get(":path")

			if path == "/ws" then
				local ws = websocket.new_from_stream(stream, req)
				ws:accept()
				table.insert(ws_clients, ws)
				ws:on_close(function()
					for i, client in ipairs(ws_clients) do
						if client == ws then
							table.remove(ws_clients, i)
							break
						end
					end
				end)
			else
				stream:respond_with_status(404)
			end
		end,
	}))

	assert(server:listen())

	while running do
		server:step(1)
		if check_directory(directory) then
			notify_clients()
		end
	end
end

return M
