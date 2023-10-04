local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local state = require("telescope.actions.state")
local actions = require("telescope.actions")

local _pstate;
local delimiter = "/"

local function parts(input)
	local parts = {}
	for part in string.gmatch(input, "[^" .. delimiter .. "]+") do
		table.insert(parts, part)
	end
	return {
		value = input,
		parts = parts
	}
end

local function cli(cmd)
	local handle = io.popen(cmd)
	if(handle == nil) then
		return
	end

	local result = handle:read("*a")
	handle:close()
	return result
end

local function get_kube_contexts()
	local contexts = cli("kubectl config get-contexts -o name")
	local result = {}
	for context in contexts:gmatch("%S+") do
		table.insert(result, context)
	end
	return result
end

local function get_kube_pods(namespace)
	local pods = cli("kubectl get pods -o name -n " .. namespace)
	local result = {}
	for pod in pods:gmatch("%S+") do
		table.insert(result, parts(pod).parts[2])
	end
	return result
end

local function get_kube_namespaces()
	local namespaces = cli("kubectl get namespaces -o name")
	local result = {}
	for namespace in namespaces:gmatch("%S+") do
		table.insert(result, parts(namespace).parts[2])
	end
	return result
end

local pod_picker = function(opts, pods, namespace)
	return pickers.new(opts, {
		prompt_title = "Kube Pods",
		finder = finders.new_table {
			results = pods
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)	
			map("i", "<CR>", function(prompt_bufnr)
				local selection = state.get_selected_entry(prompt_bufnr)
				if selection then
					if _pstate == "pod" then
						local cmd = "kubectl describe pod " .. selection.value .. " -n " .. namespace;
						actions.close(prompt_bufnr)
						local output = cli(cmd)
						local new_bufnr = vim.api.nvim_create_buf(false, true)
						vim.api.nvim_set_current_buf(new_bufnr)
					    vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, vim.split(output, "\n"))
					end
			    end
			end)
		return true
	end
	})
end


local namespace_picker = function(opts, namespaces)
	return pickers.new(opts, {
		prompt_title = "Kube Namespaces",
		finder = finders.new_table {
			results = namespaces
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)	
			map("i", "<CR>", function(prompt_bufnr)
				local selection = state.get_selected_entry(prompt_bufnr)
				if selection then
					if _pstate == "namespace" then
						_pstate = "pod"
						local pods = get_kube_pods(selection.value)
						pod_picker(opts, pods, selection.value):find()
					end
				end
			end)

		return true
	end
	})
end


local context_picker =	function(opts, contexts)
	return pickers.new(opts, {
		prompt_title = "Kube Contexts",
		finder = finders.new_table {
			results = contexts
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)	
			map("i", "<CR>", function(prompt_bufnr)
				local selection = state.get_selected_entry(prompt_bufnr)
				if selection then
					if _pstate == "context" then
						cli("kubectl config use-context " .. selection.value)
						_pstate = "namespace"
						local namespaces = get_kube_namespaces()
						namespace_picker(opts, namespaces):find()
					end
				end
			end)

		return true
	end
	})
end

local setup = function(opts)
	opts = opts or {}
	_pstate = "context"
	local contexts = get_kube_contexts()
	context_picker(opts, contexts):find()
end

return {
	setup = setup
}
-- kube_nvim(require("telescope.themes").get_dropdown {})
