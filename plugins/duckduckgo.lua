--[[
    Copyright 2017 Matthew Hesketh <wrxck0@gmail.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local duckduckgo = {}
local mattata = require('mattata')
local http = require('socket.http')
local url = require('socket.url')
local json = require('dkjson')

function duckduckgo:init()
    duckduckgo.commands = mattata.commands(self.info.username)
    :command('duckduckgo')
    :command('ddg').table
    duckduckgo.help = '/duckduckgo <query> - Searches DuckDuckGo\'s instant results for the given search query and returns the most relevant result. Alias: /ddg.'
end

function duckduckgo:on_message(message, configuration, language)
    local input = mattata.input(message.text)
    if not input
    then
        return mattata.send_reply(
            message,
            duckduckgo.help
        )
    end
    local jstr, res = http.request('http://api.duckduckgo.com/?format=json&pretty=1&q=' .. url.escape(input))
    if res ~= 200
    then
        return mattata.send_reply(
            message,
            language['errors']['connection']
        )
    end
    local jdat = json.decode(jstr)
    if not jdat.AbstractText
    or jdat.AbstractText == ''
    then
        return mattata.send_reply(
            message,
            language['duckduckgo']['1']
        )
    end
    return mattata.send_message(
        message.chat.id,
        jdat.AbstractText
    )
end

return duckduckgo