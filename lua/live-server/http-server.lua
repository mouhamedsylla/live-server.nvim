local M = {}
local socket = require("socket")
local port = 5000

local function inject_js(content)
	local js_script = [[
    <script>
        var ws = new WebSocket("ws://localhost:5001/ws");
        ws.onmessage = function(event) {
            if (event.data === "reload") {
                location.reload();
            }
        };
    </script>]]
	return content:gsub("</body>", js_script .. "</body>")
end

local function serve_file(client, file_path)
	local file = io.open(file_path, "rb")
	if not file then
		client:send("HTTP/1.1 404 Not Found\r\n\r\n")
		return
	end

	local content = file:read("*a")
	file:close()

	if file_path:match("%.html$") then
		content = inject_js(content)
	end

	client:send("HTTP/1.1 200 OK\r\n")
	client:send("Content-Length: " .. #content .. "\r\n")
	client:send("\r\n")
	client:send(content)
end

local function handle_client(client, directory)
	local request = client:receive("*l")
	local method, path = request:match("^(%u+)%s+(/.-)%s+HTTP/1%.1$")
	if method == "GET" then
		if path == "/" then
		M.start = function(dir)
	print("Starting HTTP server in directory: " .. dir)
end	path = "/index.html"
		end

		local file_path = directory .. path
		serve_file(client, file_path)
	else
		client:send("HTTP/1.1 405 Method Not Allowed\r\n\r\n")
	end
	client:close()
end

M.start = function(directory)
	local server = assert(socket.bind("*", port))
	server:settimeout(0)

	while true do
		local client = server:accept()
		if client then
			client:settimeout(10)
			handle_client(client, directory)
		end
		socket.sleep(0.01)
	end
end

return M
