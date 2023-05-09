cmd = vim.cmd

function loadrequire(module)
    local function requiref(module)
        require(module)
    end
    return pcall(requiref,module)
end

require('plugins')


require('vars')
require('keybindings')


