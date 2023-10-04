local has_telescope, _ = pcall(require, 'telescope')

if not has_telescope then
	error('Please install nvim-telescope/telescope.nvim if you want to use this plugin.')
end

return telescope.register_extension {
	exports = {
		kube_nvim = require("kubels").setup(require("telescope.themes").get_dropdown {})
	}
}
