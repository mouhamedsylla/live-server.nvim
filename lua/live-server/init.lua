local M = {}

local llthreads2 = require("llthreads2")

M.start = function(dir)
	local http_thread = llthreads2.new(
		[[
	local dir = ...
    local start_http_server = require("live-server.http-server")
    start_http_server(dir)
]],
		dir
	)

	local ws_thread = llthreads2.new(
		[[
	local dir = ...
    local start_ws_server = require("live-server.websocket-server")
    start_ws_server(dir)
]],
		dir
	)

	http_thread:start()
	ws_thread:start()

	http_thread:join()
	ws_thread:join()
end

return M
