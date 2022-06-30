﻿local spiner = {
    create = function()
        return {
            _index = 0,
            _frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
            render_next = function(self)
                self._index = self._index + 1
                return self._frames[self._index % #self._frames + 1]
            end
        }
    end
}

local function make(cmd, args, efm)
    local title = string.format('%s %s', cmd, table.concat(args, ' '))

    local progress = spiner.create()
    local job = require('plenary').job:new({
        command = cmd,
        args = args,
        cwd = vim.loop.cwd(),
        on_stdout = function(_, data)
            vim.schedule(function()
                vim.fn.setqflist({}, 'a', {
                    title = string.format('%s %s', progress:render_next(), title),
                    lines = { data },
                    efm = efm,
                })
            end)
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                vim.notify(string.format('"%s" finished with code: %d', title, exit_code))
                vim.fn.setqflist({}, 'a', {
                    title = title,
                    lines = {}
                })
            end)
        end,
    })

    vim.fn.setqflist({}, 'f')
    vim.cmd('copen')
    job:start()
end

local M = {
    build_efm = '%-ABuild%.%#,%-ZTime%.%#,%-C%.%#,%f(%l\\,%c): %trror %m [%.%#],%f(%l\\,%c): %tarning %m [%.%#],%-G%.%#',
    resharper_inspect_cmd = 'jb InspectCode --absolute-paths --severity=HINT --no-build --format=Text',
    resharper_inspect_efm = ' %#%f:%l %m,%-G%.%#',
}

function M.set_target(path)
    vim.g.dotnet_target = path
    print(string.format('Set dotnet target to: %s', path))
end

function M.get_target()
    return vim.g.dotnet_target or nil
end

function M.set_configuration(value)
    vim.g.dotnet_configuration = value
    print(string.format('Set dotnet configuration to: %s', value))
end

function M.get_configuration()
    return vim.g.dotnet_configuration or 'Debug'
end

function M.set_test_filter()
    local function escape(test_name)
        local s = test_name
        s = string.gsub(s, '\\(', '\\\\(')
        s = string.gsub(s, '\\)', '\\\\)')
        s = string.gsub(s, '"', '\\"')
        return s
    end

    local function explore()
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local config = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        local output = false
        pickers.new(
            {},
            {
                prompt_tilte = 'dotnet tests',
                sorter = config.generic_sorter(),
                finder = finders.new_oneshot_job(
                    {'dotnet', 'test', '-t'},
                    {
                        entry_maker = function(entry)
                            if output and string.find(entry, '^%s+') == nil then
                                output = false
                                return nil
                            end
                            if string.find(entry, '^The following Tests are available:') ~= nil then
                                output = true
                            end

                            if output == false then
                                return nil
                            end

                            return {
                                value = entry,
                                display = entry,
                                ordinal = entry
                            }
                        end
                    }),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry().value
                        vim.g.dotnet_test_filter = escape(selection)
                    end)
                    return true
                end,
            }
        ):find()
    end

    explore()
end

function M.build()
    local target = M.get_target()
    if target == nil then
        print('No target is specified!')
        return
    end

    make(
        'dotnet',
        {
            'build',
            '-c',
            M.get_configuration(),
            target,
        },
        M.build_efm
    )
end

function M.run()
    local target = M.get_target()
    if target == nil then
        print('No target is specified!')
        return
    end

    vim.cmd(string.format('!dotnet run -c %s --project %s', M.get_configuration(), target))
end

function M.test()
    local filter = M.get_filter()
end

function M.inspect(files)
    local target = M.get_target()
    if target == nil then
        print('No target is specified!')
        return
    end

    local output = vim.fn.tempname()

    vim.cmd(
        string.format(
            '!%s --output="%s" --include="%s" %s',
            M.resharper_inspect_cmd,
            output,
            table.concat(files, ';'),
            target
        )
    )

    vim.fn.setqflist({}, 'a', {
        title = 'ReSharper inspection of staged',
        lines = vim.fn.readfile(output),
        efm = M.resharper_inspect_efm,
    })
    vim.cmd('copen')
end

return M
