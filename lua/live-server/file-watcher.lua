local M = {}
local lfs = require("lfs")
local previous_mod_time = {}


M.check_directory = function(dir)
	local modification_detected = false
	for file in lfs.dir(dir) do
		if file ~= "." and file ~= ".." then
			local path = dir .. "/" .. file
			local attr = lfs.attributes(path)
			if attr.mode == "directory" then
				M.check_directory(path)
			else
				local mod_time = attr.modification_detected
				if previous_mod_time[path] and previous_mod_time[path] ~= mod_time then
					modification_detected = true
				end
				previous_mod_time[path] = mod_time
			end
		end
	end
	return modification_detected
end

return M
