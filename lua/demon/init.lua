local M = {}


-- push logic
-- lua require('demon').push('debug-mode', {
-- 	...
-- })


-- vim.keymap.set(...)
-- nvim_get_keymap()
--
--
-- pair (iterates over every key on the table order is not guaranteed)
-- ipair (iterates over numerice keys on the table order is guaranteed)

local find_mapping = function(maps, lhs)
	for _, value in ipairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

M._stack = {}

M.push = function(name, mode, mappings)
	local maps = vim.api.nvim_get_keymap(mode)

	local existing_maps = {}

	for lhs, rhs in pairs(mappings) do
		local existing = find_mapping(maps, lhs)

		if existing then
			existing_maps[lhs] = existing
		end
	end


	for lhs, rhs in pairs(mappings) do
		vim.keymap.set(mode, lhs, rhs)
	end

	M._stack[name] = M._stack[name] or {}

	M._stack[name][mode] = {
		existing = existing_maps,
		mappings = mappings,
	}
end

-- pop logic
-- lua require('demon').pop('debug-mode')

M.pop = function(name, mode)
  local state = M._stack[name][mode]
  M._stack[name][mode] = nil

  for lhs in pairs(state.mappings) do
    if state.existing[lhs] then
      -- Handle mappings that existed
      local og_mapping = state.existing[lhs]

      -- TODO: Handle the options from the table
      vim.keymap.set(mode, lhs, og_mapping.rhs)
    else
      -- Handled mappings that didn't exist
      vim.keymap.del(mode, lhs)
    end
  end
end

M._clear = function()
	M._stack = {}
end

return M
