--[[
    Copyright 2017 Matthew Hesketh <wrxck0@gmail.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local fortune = {}
local mattata = require('mattata')

function fortune:init()
    fortune.commands = mattata.commands(self.info.username):command('fortune').table
    fortune.help = '/fortune - Gets your fortune from a randomly-selected ASCII animal!'
end

function fortune.get_animals()
    local animals = {}
    for n in string.gmatch(
        io.popen('cowsay -l'):read('*all'):match(':(.+)$'),
        '[%S]+'
    )
    do
        table.insert(
            animals,
            n
        )
    end
    return animals
end

function fortune.get_fortune(username)
    return '<pre>' .. mattata.escape_html(
        io.popen(
            string.format(
                '%s -f %s "$(fortune)" && echo "\nvia @%s"',
                math.random(2) == 1
                and 'cowsay'
                or 'cowthink',
                fortune.get_animals()[math.random(#fortune.get_animals())],
                username
            )
        ):read('*all')
    ) .. '</pre>'
end

function fortune:on_inline_query(inline_query, configuration, language)
    return mattata.answer_inline_query(
        inline_query.id,
        mattata.inline_result()
        :id()
        :type('article')
        :title(language['fortune']['1'])
        :input_message_content(
            mattata.input_text_message_content(
                fortune.get_fortune(self.info.username),
                'html'
            )
        )
    )
end

function fortune:on_message(message)
    return mattata.send_message(
        message.chat.id,
        fortune.get_fortune(self.info.username),
        'html'
    )
end

return fortune