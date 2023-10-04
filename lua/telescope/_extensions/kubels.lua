local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
	error('Please install nvim-telescope/telescope.nvim if you want to use this plugin.')
end

local opts = require("telescope.themes").get_dropdown {}

local kubels = function()
  local kls = require("kubels")
  kls.setup(opts)
end

return telescope.register_extension {
	exports = {
		kubels =  kubels 
	}
}
