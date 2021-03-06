--[[
    Copyright 2017 Matthew Hesketh <wrxck0@gmail.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local optout = {}
local mattata = require('mattata')
local redis = require('mattata-redis')

function optout:init()
    optout.commands = mattata.commands(self.info.username)
    :command('optout')
    :command('optin').table
    optout.help = '/optout - Removes currently-stored information about you from mattata\'s database and prevents the storing of future sensitive data (such as messages stored with /save). To re-enable this, and opt-in to the collecting of this data, use /optin.'
end

function optout:on_message(message, configuration, language)
    if message.text:match('^[/!#]optin')
    then
        redis:del('user:' .. message.from.id .. ':opt_out')
        return mattata.send_reply(
            message,
            language['optout']['1']
        )
    end
    redis:set(
        'user:' .. message.from.id .. ':opt_out',
        true
    )
    return mattata.send_reply(
        message,
        language['optout']['2']
    )
end

return optout