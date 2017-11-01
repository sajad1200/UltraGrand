serpent = require("serpent")
redis = require("redis")
socket = require("socket")
URL = require("socket.url")
http = require("socket.http")
https = require("ssl.https")
ltn12 = require("ltn12")
json = (loadfile "./libs/JSON.lua")()
JSON = (loadfile "./libs/dkjson.lua")()
redis = redis.connect("127.0.0.1", 6379)
http.TIMEOUT = 10
--------------------------------------------------------------------------------
sudo_users = {226283662,378393503}
bot_id = 378393503
day = 86400
ch_id = -100056843787
Token = 'توکن'
--------------------------------------------------------------------------------
function Run()
print('\27[93m>Developer:\27[39m'..' '..'@GrandDev')
end
--------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- vardump(data)
  --vardump(arg)
end
--------------------------------------------------------------------------------
  function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
--------------------------------------------------------------------------------
function is_owner(msg) 
  local hash = redis:sismember('owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
--------------------------------------------------------------------------------
function is_mod(msg) 
  local hash = redis:sismember('mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) then
return true
else
return false
end
end 
--------------------------------------------------------------------------------
function is_banned(chat,user)
   local hash =  redis:sismember('banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function is_gban(chat,user)
   local hash =  redis:sismember('gbaned',user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
  function is_filter(msg, value)
  local hash = redis:smembers('filters:'..msg.chat_id_)
  if hash then
    local names = redis:smembers('filters:'..msg.chat_id_)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg) then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
  end
--------------------------------------------------------------------------------
function is_muted(chat,user)
   local hash =  redis:sismember('mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function do_notify (user, msg)
	local n = notify.Notification.new(user, msg)
	n:show ()
end
--------------------------------------------------------------------------------
local function UpTime()
  local uptime = io.popen("uptime"):read("*all")
  days = uptime:match("up %d+ days")
  hours = uptime:match(",  %d+:")
  minutes = uptime:match(":%d+,")
    sec = uptime:match(":%d+ up")
  if hours then
    hours = hours
  else
    hours = ""
  end
  if days then
    days = days
  else
    days = ""
  end
  if minutes then
    minutes = minutes
  else
    minutes = ""
  end
  days = days:gsub("up", "")
  local a_ = string.match(days, "%d+")
  local b_ = string.match(hours, "%d+")
  local c_ = string.match(minutes, "%d+")
   local d_ = string.match(sec, "%d+")
  if a_ then
    a = a_
  else
    a = 0
  end
  if b_ then
    b = b_
  else
    b = 0
  end
  if c_ then
    c = c_
  else
    c = 0
  end
    if d_ then
    d = d_
  else
    d = 0
  end
return a..'روز و '..b..' ساعت و '..c..' دقیقه و '..d..' ثانیه'
end
--------------------------------------------------------------------------------
function getChats(offset_order, offset_chat_id, limit, cb, cmd)
  if not limit or limit > 20 then
    limit = 20
  end
  tdcli_function ({
    ID = "GetChats",
    offset_order_ = offset_order or 9223372036854775807,
    offset_chat_id_ = offset_chat_id or 0,
    limit_ = limit
  }, cb or dl_cb, cmd)
end
--------------------------------------------------------------------------------
function deleteMessagesFromUser(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function sendRequest(request_id, chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, callback, extra)
  tdcli_function({
    ID = request_id,
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = input_message_content
  }, callback or dl_cb, extra)
end
--------------------------------------------------------------------------------
function string:starts(text)
  return text == string.sub(self, 1, string.len(text))
end
--------------------------------------------------------------------------------
function download_to_file(url, file_name)
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local response
  if url:starts("https") then
    options.redirect = false
    response = {
      https.request(options)
    }
  else
    response = {
      http.request(options)
    }
  end
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then
    return nil
  end
  file_name = file_name or get_http_file_name(url, headers)
  local file_path = "data/" .. file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------------------------------------------------------------------------------
function checkChatInviteLink(link, cb, cmd)
  tdcli_function ({
    ID = "CheckChatInviteLink",
    invite_link_ = link
  }, cb or dl_cb, cmd)
end
--------------------------------------------------------------------------------
function run_bash(CMD)
  local cmd = io.popen(CMD)
  local result = cmd:read("*all")
  return result
end
--------------------------------------------------------------------------------
function get_file(file_name)
  local respbody = {}
  local options = {
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local file_path = "data/" .. file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------------------------------------------------------------------------------
function getChatId(chat_id)
  local chat = {}
  local chat_id = tostring(chat_id)

  if chat_id:match('^-100') then
    local channel_id = chat_id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = chat_id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  return chat
end
--------------------------------------------------------------------------------
function OpenChat(chat_id, cb)
  tdcli_function ({
    ID = "OpenChat",
    chat_id_ = chat_id
  }, cb or dl_cb, nil)
end
--------------------------------------------------------------------------------
function editMessageText(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)

  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getUser(user_id,cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
--------------------------------------------------------------------------------
function forwardMessages(chat_id, from_chat_id, message_ids, disable_notification)
  tdcli_function ({
    ID = "ForwardMessages",
    chat_id_ = chat_id,
    from_chat_id_ = from_chat_id,
    message_ids_ = message_ids, -- vector
    disable_notification_ = disable_notification,
    from_background_ = 1
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    }
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function editMessageText(chat_id, message_id, reply_markup, text, disable_web_page_preview)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {}
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
--------------------------------------------------------------------------------
function reportChannelSpam(channel_id, user_id, message_ids)
  tdcli_function ({
    ID = "ReportChannelSpam",
    channel_id_ = getChatId(channel_id).ID, 
    user_id_ = user_id, 
    message_ids_ = message_ids 
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
--------------------------------------------------------------------------------
function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
   getChannelMembers(channel, 0, 'Bots', limit,cb)
    end 
getChannelFull(channel,callback_admins)
end
function getUser(user_id,cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
--------------------------------------------------------------------------------
function getChannelFull(channel_id,cb)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, cb, nil)
end
--------------------------------------------------------------------------------
function channel_get_kicked(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.kicked_count_
   getChannelMembers(channel, 0, 'Kicked', limit,cb)
    end
  getChannelFull(channel,callback_admins)
end
--------------------------------------------------------------------------------
function addChatMember(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function migrateGroupChatToChannelChat(chat_id)
  tdcli_function ({
    ID = "MigrateGroupChatToChannelChat",
    chat_id_ = chat_id
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function channel_get_admins(channel,cb)
  local function callback_admins(extra,result,success)
    limit = result.administrator_count_
    if tonumber(limit) > 0 then
    getChannelMembers(channel, 0, 'Administrators', limit,cb)
     else return reply_to(channel, 0, 1,'ربات ادمین گروه نشده است !', 1, 'md') end
    end
  getChannelFull(channel,callback_admins)
end
--------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit,cb)
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, cb, nil)
end
--------------------------------------------------------------------------------
function getChatHistory(chat_id, from_message_id, offset, limit,cb)
  tdcli_function ({
    ID = "GetChatHistory",
    chat_id_ = chat_id,
    from_message_id_ = from_message_id,
    offset_ = offset,
    limit_ = limit
  }, cb, nil)
end
--------------------------------------------------------------------------------
function up_time()
  local url = "http://api.timezonedb.com/v2/get-time-zone?"
for i , i_val in pairs(my.time.Parameter) do
    url = url.. i .. '=' .. i_val .. '&'
end
    local dat , suc = performRequest(url)
    local tab = JSON.decode(dat)
    local x = tab.formatted:split(' ')
    local y = x[2]:split(':')
    my.time.h = y[1]
    my.time.m = y[2]
    my.time.s = y[3]
end
--------------------------------------------------------------------------------
function unpin(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end  
--------------------------------------------------------------------------------
   function SendMetion(chat_id, user_id, msg_id, text, offset, length)
local tt = redis:get('endmsg') or ''
  tdcli_function ({
        ID = "SendMessage",
        chat_id_ = chat_id,
        reply_to_message_id_ = msg_id,
        disable_notification_ = 0,
        from_background_ = 1,
        reply_markup_ = nil,
        input_message_content_ = {
          ID = "InputMessageText",
          text_ = text..'\n\n'..tt,
          disable_web_page_preview_ = 1,
        clear_draft_ = 0,
          entities_ = {[0]={
          ID="MessageEntityMentionName",
          offset_=offset,
          length_=length,
          user_id_=user_id
          },
          },
        },
    }, dl_cb, nil)
  end
--------------------------------------------------------------------------------
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
--------------------------------------------------------------------------------
function getInputMessageContent(file, filetype, caption)
  if file:match("/") or file:match(".") then
    infile = {
      ID = "InputFileLocal",
      path_ = file
    }
  elseif file:match("^%d+$") then
    infile = {
      ID = "InputFileId",
      id_ = file
    }
  else
    infile = {
      ID = "InputFilePersistentId",
      persistent_id_ = file
    }
  end
  local inmsg = {}
  local filetype = filetype:lower()
  if filetype == "animation" then
    inmsg = {
      ID = "InputMessageAnimation",
      animation_ = infile,
      caption_ = caption
    }
  elseif filetype == "audio" then
    inmsg = {
      ID = "InputMessageAudio",
      audio_ = infile,
      caption_ = caption
    }
  elseif filetype == "document" then
    inmsg = {
      ID = "InputMessageDocument",
      document_ = infile,
      caption_ = caption
    }
  elseif filetype == "photo" then
    inmsg = {
      ID = "InputMessagePhoto",
      photo_ = infile,
      caption_ = caption
    }
  elseif filetype == "sticker" then
    inmsg = {
      ID = "InputMessageSticker",
      sticker_ = infile,
      caption_ = caption
    }
  elseif filetype == "video" then
    inmsg = {
      ID = "InputMessageVideo",
      video_ = infile,
      caption_ = caption
    }
  elseif filetype == "voice" then
    inmsg = {
      ID = "InputMessageVoice",
      voice_ = infile,
      caption_ = caption
    }
  end
  return inmsg
end
---------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
--------------------------------------------------------------------------------
function na(arg,data)
    -- vardump(data)
data.title_ = title
end
--------------------------------------------------------------------------------
 function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  
  return P
end
--------------------------------------------------------------------------------
function send_file(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, document, caption, cb, cmd)
  local input_message_content = {
    ID = "InputMessageDocument",
    document_ = getInputFile(document),
    caption_ = caption
  }
  sendRequest("SendMessage", chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end
--------------------------------------------------------------------------------
function deleteMessagesFromUser(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getMe(cb)
  tdcli_function ({
    ID = "GetMe",
  }, cb, nil)
end
--------------------------------------------------------------------------------
function reply_to(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode,msg)
local tt = redis:get('endmsg') or ''
  local TextParseMode = getParseMode(parse_mode)
  local entities = {}
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text..'\n\n'..tt,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = entities,
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getChat(chat_id, dl_cb, cmd)
  tdcli_function ({
    ID = "GetChat",
    chat_id_ = chat_id
  }, dl_cb, cmd)
end
--------------------------------------------------------------------------------
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end
--------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function priv(chat,user)
  local owner = redis:sismember('owners:'..chat,user)
  local mod = redis:sismember('mods:'..chat,user)
 if tonumber(SUDO) == tonumber(user) or mod or owner then
   return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      reply_to(msg.chat_id_, msg.id_, 1, '▪ *شما نمیتوانید دیگر مدیران را اخراج کنید!*', 'md')
    else
  changeChatMemberStatus(chat, user, "Kicked")
    end
  end
--------------------------------------------------------------------------------
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
reply_to(msg.chat_id_, msg.id_, 1,'▪ شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #بن کنید !', 1, 'md')
    else
  changeChatMemberStatus(chat, user, "Kicked")
  redis:sadd('banned'..chat,user)
  local t = '▪ کاربر '..user..' از گروه #بن شد !'
  SendMetion(msg.chat_id_, user, msg.id_, t, 8, string.len(user))
  end
  end
--------------------------------------------------------------------------------
function banall(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      reply_to(msg.chat_id_, msg.id_, 1,'▪ شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #محروم کنید !', 1, 'md')
    else
  changeChatMemberStatus(chat, user, "Kicked")
  redis:sadd('gbaned',user)
  local t = '▪ کاربر '..user..' از تمام گروه های ربات #محروم شد !'
  SendMetion(msg.chat_id_, user, msg.id_, t, 8, string.len(user))
  end
  end
--------------------------------------------------------------------------------
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      reply_to(msg.chat_id_, msg.id_, 1, '▪ شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #بی_صدا کنید', 'md')
    else
  redis:sadd('mutes'..chat,user)
  local t = '▪ کاربر '..user..' در گروه #بی_صدا شد !'
  SendMetion(msg.chat_id_, user, msg.id_, t, 8, string.len(user))
  end
  end
--------------------------------------------------------------------------------
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   redis:srem('banned'..chat,user)
  local t = '▪ کاربر '..user..' در گروه #انبن شد !'
  SendMetion(msg.chat_id_, user, msg.id_, t, 8, string.len(user))
  end
--------------------------------------------------------------------------------
function unbanall(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   redis:srem('gbaned',user)
  local t = '▪ کاربر '..user..' از #محرومبت تمام گروه های ربات خارج شد !'
  SendMetion(msg.chat_id_, user, msg.id_, t, 8, string.len(user))
  end
--------------------------------------------------------------------------------
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   redis:srem('mutes'..chat,user)
  local t = '▪ کاربر '..user..' در گروه #با_صدا شد !'
  SendMetion(msg.chat_id_, user, msg.id_, t, 8, string.len(user))
  end
--------------------------------------------------------------------------------
function settings(msg,value,lock) 
local hash = 'settings:'..msg.chat_id_..':'..value
  if value == 'file' then
      text = 'فایل'
   elseif value == 'keyboard' then
    text = 'کیبورد شیشه ای'
  elseif value == 'links' then
    text = 'لینک'
  elseif value == 'spam' then
    text = 'اسپم'
  elseif value == 'tag' then
    text = 'تگ'
elseif value == 'fosh' then
    text = 'فحش'
elseif value == 'cmd' then
    text = 'دستورات'
  elseif value == 'emoji' then
    text = 'ایموجی'
elseif value == 'flood' then
    text = 'پیام مکرر'
elseif value == 'join' then
    text = 'جوین'
  elseif value == 'edit' then
    text = 'ادیت'
   elseif value == 'game' then
    text = 'بازی ها'
    elseif value == 'username' then
    text = 'یوزرنیم(@)'
   elseif value == 'pin' then
    text = 'پین کردن پیام'
    elseif value == 'photo' then
    text = 'عکس'
    elseif value == 'gif' then
    text = 'گیف'
    elseif value == 'video' then
    text = 'فیلم'
elseif value == 'selfvideo' then
    text = 'فیلم سلفی'
    elseif value == 'audio' then
    text = 'ویس'
    elseif value == 'music' then
    text = 'اهنگ'
    elseif value == 'text' then
    text = 'متن'
    elseif value == 'sticker' then
    text = 'استیکر'
    elseif value == 'contact' then
    text = 'مخاطب'
    elseif value == 'forward' then
    text = 'فوروارد'
    elseif value == 'persian' then
    text = 'گفتمان فارسی'
    elseif value == 'english' then
    text = 'گفتمان انگلیسی'
    elseif value == 'bot' then
    text = 'ربات(Api)'
    elseif value == 'tgservice' then
    text = 'پیغام ورود،خروج'
    else return false
    end
  if lock then
redis:set(hash,true)
reply_to(msg.chat_id_, msg.id_, 1, '▪ قفل '..text..' فعال شد.',1,'md')
else
  redis:del(hash)
reply_to(msg.chat_id_, msg.id_, 1, '▪ قفل '..text..' غیر فعال شد.',1,'md')
end
end
--------------------------------------------------------------------------------
function is_lock(msg,value)
local hash = 'settings:'..msg.chat_id_..':'..value
 if redis:get(hash) then
    return true 
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function warn(msg,chat,user)
  local type = redis:hget("warn:"..msg.chat_id_,"swarn")
  if type == "kick" then
    kick(msg,chat,user)
local text = '▪ کاربر '..user..' به دلیل دریافت اخطار بیش از حد #کیک شد !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
    end
  if type == "ban" then
local text = '▪ کاربر '..user..' به دلیل دریافت اخطار بیش از حد #بن شد !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
changeChatMemberStatus(chat, user, "Kicked")
redis:sadd('banned'..chat,user)
  end
	if type == "mute" then
local text = '▪ کاربر '..user..' به دلیل دریافت اخطار بیش از حد #بی_صدا شد !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
redis:sadd('mutes'..msg.chat_id_,user)
      end
	end
--------------------------------------------------------------------------------
function trigger_anti_spam(msg)
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
local text = '▪ کاربر '..msg.sender_user_id_..' به دلیل ارسال پیام مکرر از گروه بن شد\nو تمام پیام هایش پاک شد'
SendMetion(msg.chat_id_, msg.sender_user_id_, msg.id_, text, 8, string.len(msg.sender_user_id_))
deleteMessagesFromUser(msg.chat_id_, msg.sender_user_id_)
changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  redis:sadd('banned'..msg.chat_id_,msg.sender_user_id_)
  end
end
--------------------------------------------------------------------------------
function forwardMessages(chat_id, from_chat_id, message_ids, disable_notification)
  tdcli_function ({
    ID = "ForwardMessages",
    chat_id_ = chat_id,
    from_chat_id_ = from_chat_id,
    message_ids_ = message_ids, -- vector
    disable_notification_ = disable_notification,
    from_background_ = 1
  }, dl_cb, nil)
end

--------------------------------------------------------------------------------
function televardump(msg,value)
  local text = json:encode(value)
  reply_to(msg.chat_id_, msg.id_, 1, text, 'md')
  end
--------------------------------------------------------------------------------
function run(msg,data)
function get_gp(arg,data)
   --vardump(data)
  --televardump(msg,data)


    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
--------------------------------------------------------------------------------
local text = msg.content_.text_ or  msg.content_.caption_
  text = text:lower()
--------------------------------------------------------------------------------
if msg.content_.ID == "MessageText" then
  msg_type = 'text'
end
--------------------------------------------------------------------------------
if is_sudo(msg) then
if text:match('^leave(-100)(%d+)$') then
       reply_to(msg.chat_id_,msg.id_,1,'▪ ربات با موفقیت از گروه '..text:match('leave(.*)')..' خارج شد.',1,'md')
       reply_to(text:match('leave(.*)'),0,1,"▪ ربات به دلایلی گروه را ترک میکند\nبرای اطلاعات بیشتر میتوانید با @GrandDev در ارتباط باشید.",1,'md')
     changeChatMemberStatus(text:match('leave(.*)'), bot_id, "Left")
  end
--------------------------------------------------------------------------------
  if text:match('^plan1(-100)(%d+)$') then
       local timeplan1 = 2592000
       redis:setex("charged:"..text:match('plan1(.*)'),timeplan1,true)
       reply_to(msg.chat_id_,msg.id_,1,'▪ پلن 1 با موفقیت برای گروه '..text:match('plan1(.*)')..' فعال شد\nاین گروه تا 30 روز دیگر اعتبار دارد! ( 1 ماه )',1,'md')
       reply_to(text:match('plan1(.*)'),0,1,"ربات با موفقیت فعال شد و تا 30 روز دیگر اعتبار دارد!",1,'md')
  end
--------------------------------------------------------------------------------
if text:match('^plan2(-100)(%d+)$') then
      local timeplan2 = 7776000
       redis:setex("charged:"..text:match('plan2(.*)'),timeplan2,true)
       reply_to(msg.chat_id_,msg.id_,1,'▪ پلن 2 با موفقیت برای گروه '..text:match('plan2(.*)')..' فعال شد\nاین گروه تا 90 روز دیگر اعتبار دارد! ( 3 ماه )',1,'md')
       reply_to(text:match('plan2(.*)'),0,1,"ربات با موفقیت فعال شد و تا 90 روز دیگر اعتبار دارد! ( 3 ماه )",1,'md')
  end
--------------------------------------------------------------------------------
  if text:match('^plan3(-100)(%d+)$') then
       redis:set("charged:"..text:match('plan3(.*)'),true)
       reply_to(msg.chat_id_ ,msg.id_,1,'▪ پلن 3 با موفقیت برای گروه '..text:match('plan3(.*)')..' فعال شد\nاین گروه به صورت نامحدود شارژ شد!',1,'md')
       reply_to(text:match('plan3(.*)'),0,1,"ربات بدون محدودیت فعال شد ! ( نامحدود )",1,'md')
         
  end
--------------------------------------------------------------------------------
   if text:match('^join(-100)(%d)$') then

addChatMember(text:match('join(.*)'), 335267337, 10)

 reply_to(msg.chat_id_,msg.id_,1,'▪ rبا موفقیت تورو به گروه '..text:match('join(.*)')..' اضافه کردم.',1,'md')
      
    end
  end
--------------------------------------------------------------------------------
  --[[if chat_type == 'user' and not is_sudo(msg) then
    local text = 'برای خرید ربات روی این متن کلیک نماییید.'
SendMetion(msg.chat_id_, 335267337, msg.id_, text, 27, 0)
    end]]--
--------------------------------------------------------------------------------
  if chat_type == 'super' then
      NUM_MSG_MAX = redis:get('floodmax'..msg.chat_id_) or 5
      TIME_CHECK = redis:get('floodtime'..msg.chat_id_) or 3
if is_lock(msg,'flood') then
if not is_mod(msg) then
	local post_count = tonumber(redis:get('floodc:'..msg.sender_user_id_..':'..msg.chat_id_) or 0)
	if post_count > tonumber(redis:get('floodmax'..msg.chat_id_) or 5) then

         trigger_anti_spam(msg)
 end
	redis:setex('floodc:'..msg.sender_user_id_..':'..msg.chat_id_, tonumber(redis:get('floodtime'..msg.chat_id_) or 3), post_count+1)
end
end
--------------------------------------------------------------------------------
  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 redis:set('pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 redis:set('pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
-----------------------------------------------------------------------
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
--------------------------------------------------------------------------------
    
     -- lock tgservice
      if is_lock(msg,'tgservice') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
-- lock join
      if is_lock(msg,'join') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
     changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
          end
        end
    -- lock pin
    if is_owner(msg) then else
      if is_lock(msg,'pin') then
        if msg.content_.ID == 'MessagePinMessage' then
      reply_to(msg.chat_id_, msg.id_, 1, 'قفل پین فعال است \n شما اجازه پین کردن پیامی را ندارید',1, 'md')
       unpin(msg.chat_id_)
          local PinnedMessage = redis:get('pinned'..msg.chat_id_)
          if PinnedMessage then
            pin(msg.chat_id_, tonumber(PinnedMessage),0)
            end
          end
        end
      end
      if is_mod(msg) then
        else
        -- lock link
        if is_lock(msg,'links') then
          if text then
       local is_link = text:find("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:find("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:find("[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or text:find("[Tt].[Mm][Ee]/")
            if is_link then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [links]")
              end
            end
        end
        -- lock username
        if is_lock(msg,'username') then
          if text then
        if text:find("@") then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [username]")
        end
            end
        end
        -- lock tag
        if is_lock(msg,'tag') then
          if text then
        if text:find("#") then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Tag]")
        end
            end
        end
        -- lock forward
        if is_lock(msg,'forward') then
		if msg.forward_info_ ~= false then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [forward]")
          end
          end
        -- lock photo
        if is_lock(msg,'photo') then
          if msg.content_.ID == 'MessagePhoto' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Photo]")
          end
        end 
        -- lock file
        if is_lock(msg,'file') then
          if msg.content_.ID == 'MessageDocument' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [File]")
          end
        end
      -- lock file
        if is_lock(msg,'keyboard') then
       if tonumber(msg.via_bot_user_id_) ~= 0 then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [keyboard]")
          end
        end 
      -- lock game
        if is_lock(msg,'game') then
          if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Game]")
          end
        end 
        -- lock music 
        if is_lock(msg,'audio') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [audio]")
            end
          end
        -- lock voice 
        if is_lock(msg,'voice') then
          if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Voice]")
            end
          end
        -- lock gif
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Gif]")
            end
          end 
        -- lock contact
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Contact]")
            end
          end
        -- lock video 
        if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Video]")
           end
          end
        if is_lock(msg,'fosh') then
local is_fosh_msg = text:find("کیر") or text:find("کس") or text:find("کون") or text:find("85") or text:find("جنده") or text:find("ننه") or text:find("ننت") or text:find("مادر") or text:find("قهبه") or text:find("گایی") or text:find("سکس") or text:find("kir") or text:find("kos") or text:find("kon") or text:find("nne") or text:find("nnt")
  if is_fosh_msg then
    delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Fosh]")
  end
end
        if is_lock(msg,'emoji') then
  local is_emoji_msg = text:find("😀") or text:find("😬") or text:find("😁") or text:find("😂") or  text:find("😃") or text:find("😄") or text:find("😅") or text:find("☺️") or text:find("🙃") or text:find("🙂") or text:find("😊") or text:find("😉") or text:find("😇") or text:find("😆") or text:find("😋") or text:find("😌") or text:find("😍") or text:find("😘") or text:find("😗") or text:find("😙") or text:find("😚") or text:find("🤗") or text:find("😎") or text:find("🤓") or text:find("🤑") or text:find("😛") or text:find("😏") or text:find("😶") or text:find("😐") or text:find("😑") or text:find("😒") or text:find("🙄") or text:find("🤔") or text:find("😕") or text:find("😔") or text:find("😡") or text:find("😠") or text:find("😟") or text:find("😞") or text:find("😳") or text:find("🙁") or text:find("☹️") or text:find("😣") or text:find("😖") or text:find("😫") or text:find("😩") or text:find("😤") or text:find("😲") or text:find("😵") or text:find("😭") or text:find("😓") or text:find("😪") or text:find("😥") or text:find("😢") or text:find("🤐") or text:find("😷") or text:find("🤒") or text:find("🤕") or text:find("😴") or text:find("💋") or text:find("❤️")
  if is_emoji_msg then
    delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [emoji]")
  end
end
       -- lock selfvideo 
        if is_lock(msg,'selfvideo') then
         if msg.content_.ID == "MessageUnsupported" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Selfvideo]")
           end
          end
        -- lock text 
        if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Text]")
            end
          end
        -- lock persian 
        if is_lock(msg,'persian') then
          if text:find('[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Persian]")
            end 
        end
        -- lock english 
        if is_lock(msg,'english') then
          if text:find('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [english]")
            end 
end
        -- lock bot
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
print("kick [Lock] [bot]")
              end
            end
          end
      end

-- check mutes
      local muteall = redis:get('muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [All]")
      end
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [MuteUser]")
      end
-- check bans
if msg.sender_user_id_ then
OpenChat(msg.chat_id_)
end
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      end
if msg.sender_user_id_ and is_gban(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_gban(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      end
-- welcome
    local status_welcome = (redis:get('status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
			    if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) then
     function wlc(extra,result,success)
        if redis:get('welcome:'..msg.chat_id_) then
        t = redis:get('welcome:'..msg.chat_id_)
        else
        t = 'سلام <name>\nبه گروه خوش اومدی !'
        end
      local t = t:gsub('<name>',result.first_name_)
          reply_to(msg.chat_id_, msg.id_, 1, t, 1, 'md')
          end
        getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      if redis:get('welcome:'..msg.chat_id_) then
        t = redis:get('welcome:'..msg.chat_id_)
        else
               t = 'سلام <name>\nبه گروه خوش اومدی !'
        end
      local t = t:gsub('<name>',msg.content_.members_[0].first_name_)
             reply_to(msg.chat_id_, msg.id_, 1, t, 1, 'md')
      end
        end
          end
      end
      -- locks
--------------------------------------------------------------------------------
     if text and is_mod(msg) then
      local lock = text:match('^lock pin$') or text:match('^قفل پین$')
       local unlock = text:match('^unlock pin$') or text:match('^بازكردن پين$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end 
--------------------------------------------------------------------------------
local lock = text:match('^lock links$') or text:match('^قفل لینک$')
       local unlock = text:match('^unlock links$') or text:match('^بازکردن لینک$')
      if lock then
          settings(msg,'links','lock')
          end
        if unlock then
          settings(msg,'links')
        end
     
--------------------------------------------------------------------------------
local lock = text:match('^lock fosh$') or text:match('^قفل فحش$')
       local unlock = text:match('^unlock fosh$') or text:match('^بازكردن فحش$')
      if lock then
          settings(msg,'fosh','lock')
          end
        if unlock then
          settings(msg,'fosh')
        end 
--------------------------------------------------------------------------------
local lock = text:match('^lock emoji$') or text:match('^قفل ایموجی$')
       local unlock = text:match('^unlock emoji$') or text:match('^بازکردن ایموجی$')
      if lock then
          settings(msg,'emoji','lock')
          end
        if unlock then
          settings(msg,'emoji')
        end
     
--------------------------------------------------------------------------------
local lock = text:match('^lock join$') or text:match('^قفل جوین$')
       local unlock = text:match('^unlock join$') or text:match('^بازكردن جوين$')
      if lock then
          settings(msg,'join','lock')
          end
        if unlock then
          settings(msg,'join')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock flood$') or text:match('^قفل فلود$')
       local unlock = text:match('^unlock flood$') or text:match('^بازكردن فلود$')
      if lock then
          settings(msg,'flood','lock')
          end
        if unlock then
          settings(msg,'flood')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock tag$') or text:match('^قفل تگ$')
       local unlock = text:match('^unlock tag$') or text:match('^بازكردن تگ$')
      if lock then
          settings(msg,'tag','lock')
          end
        if unlock then
          settings(msg,'tag')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock edit$') or text:match('^قفل ادیت$')
       local unlock = text:match('^unlock edit$') or text:match('^بازکردن ادیت$')
      if lock then
          settings(msg,'edit','lock')
          end
        if unlock then
          settings(msg,'edit')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock file$') or text:match('^قفل فایل$')
       local unlock = text:match('^unlock file$') or text:match('^بازكردن فايل$')
      if lock then
          settings(msg,'file','lock')
          end
        if unlock then
          settings(msg,'file')
        end

local lock = text:match('^lock cmd$') or text:match('^قفل دستورات$')
       local unlock = text:match('^unlock cmd$') or text:match('^بازكردن دستورات$')
      if lock then
          settings(msg,'cmd','lock')
          end
        if unlock then
          settings(msg,'cmd')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock keyboard$') or text:match('^قفل کیبورد اینلاین$')
       local unlock = text:match('^unlock keyboard$') or text:match('^بازكردن كيبورد اينلاين$')
      if lock then
          settings(msg,'keyboard','lock')
          end
        if unlock then
          settings(msg,'keyboard')
        end
       
 --------------------------------------------------------------------------------
local lock = text:match('^lock game$') or text:match('^قفل بازی$')
       local unlock = text:match('^unlock game$') or text:match('^بازكردن بازی$')
      if lock then
          settings(msg,'game','lock')
          end
        if unlock then
          settings(msg,'game')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock username$') or text:match('^قفل یوزرنیم$')
       local unlock = text:match('^unlock username$') or text:match('^بازكردن يوزرنيم$')
      if lock then
          settings(msg,'username','lock')
          end
        if unlock then
          settings(msg,'username')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock photo$') or text:match('^قفل عکس$')
       local unlock = text:match('^unlock photo$') or text:match('^بازكردن عكس$')
      if lock then
          settings(msg,'photo','lock')
          end
        if unlock then
          settings(msg,'photo')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock gifs$') or text:match('^قفل گیف$')
       local unlock = text:match('^unlock gifs$') or text:match('^بازكردن گيف$')
      if lock then
          settings(msg,'gif','lock')
          end
        if unlock then
          settings(msg,'gif')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock video$') or text:match('^قفل فیلم$')
       local unlock = text:match('^unlock video$') or text:match('^بازكردن فيلم$')
      if lock then
          settings(msg,'video','lock')
          end
        if unlock then
          settings(msg,'video')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock selfvideo$') or text:match('^قفل فیلم سلفی$')
       local unlock = text:match('^unlock selfvideo$') or text:match('^بازكردن فيلم سلفي$')
      if lock then
          settings(msg,'selfvideo','lock')
          end
        if unlock then
          settings(msg,'selfvideo')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock voice$') or text:match('^قفل ویس$')
       local unlock = text:match('^unlock voice$') or text:match('^بازكردن ويس$')
      if lock then
          settings(msg,'voice','lock')
          end
        if unlock then
          settings(msg,'voice')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock audio$') or text:match('^قفل اهنگ$')
       local unlock = text:match('^unlock audio$') or text:match('^بازكردن اهنگ$')
      if lock then
          settings(msg,'music','lock')
          end
        if unlock then
          settings(msg,'music')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock text$') or text:match('^قفل متن$')
       local unlock = text:match('^unlock text$') or text:match('^بازكردن متن$')
      if lock then
          settings(msg,'text','lock')
          end
        if unlock then
          settings(msg,'text')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock sticker$') or text:match('^قفل استیکر$')
       local unlock = text:match('^unlock sticker$') or text:match('^بازكردن استيكر$')
      if lock then
          settings(msg,'sticker','lock')
          end
        if unlock then
          settings(msg,'sticker')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock contacts$') or text:match('^قفل مخاطب$')
       local unlock = text:match('^unlock contacts$') or text:match('^بازكردن مخاطب$')
      if lock then
          settings(msg,'contact','lock')
          end
        if unlock then
          settings(msg,'contact')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock fwd$') or text:match('^قفل فوروارد$')
       local unlock = text:match('^unlock fwd$') or text:match('^بازكردن فوروارد$')
      if lock then
          settings(msg,'forward','lock')
          end
        if unlock then
          settings(msg,'forward')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock tgservice$') or text:match('^قفل سرویس تلگرام$')
       local unlock = text:match('^unlock tgservice$') or text:match('^بازكردن سروس تلگرام$')
      if lock then
          settings(msg,'tgservice','lock')
          end
        if unlock then
          settings(msg,'tgservice')
        end
       
   --------------------------------------------------------------------------------
local lock = text:match('^lock english$') or text:match('^قفل انگلیسی$')
       local unlock = text:match('^unlock english$') or text:match('^بازكردن انگليسي$')
      if lock then
          settings(msg,'english','lock')
          end
        if unlock then
          settings(msg,'english')
        end
       
   --------------------------------------------------------------------------------
local lock = text:match('^lock persian$') or text:match('^قفل فارسی$')
       local unlock = text:match('^unlock persian$') or text:match('^بازكردن فارسي$')
      if lock then
          settings(msg,'persian','lock')
          end
        if unlock then
          settings(msg,'persian')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock bots$') or text:match('^قفل ربات$')
       local unlock = text:match('^unlock bots$') or text:match('^بازكردن ربات$')
      if lock then
          settings(msg,'bot','lock')
          end
        if unlock then
          settings(msg,'bot')
        end
      end 
   
--------------------------------------------------------------------------------
    if text then
      if is_sudo(msg) then
--------------------------------------------------------------------------------
------تنظیم لقب", "setrank")
 if text:match('^setrank (.*)') then
        local rank = text:match('setrank (.*)')
        function setrank(extra, result, success)
        redis:set('ranks:'..result.sender_user_id_, rank)
local text = '▪ لقب کاربر '..result.sender_user_id_..' به '..rank..' تغیر یافت'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 12, string.len(result.sender_user_id_))
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
          getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),setrank)  
          end
        end
--------------------------------------------------------------------------------
 if text:match('^rank$') or text:match('^لقب$') then
  function getrank(extra, result, success)
       local rank =  redis:get('ranks:'..result.sender_user_id_) or 'ست نشده'
reply_to(msg.chat_id_, msg.id_, 1,''..rank..'',1,'md') 
end
if tonumber(msg.reply_to_message_id_) == 0 then
else 
getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),getrank)  
        end
end
--------------------------------------------------------------------------------
   if text:match('^setend (.*)') then
            local endmsg = text:match('^setend (.*)')
redis:set('endmsg',endmsg)
        reply_to(msg.chat_id_, msg.id_, 1,'*> انجام شد !*', 1, 'md')
            end
--------------------------------------------------------------------------------
if text:match('^gplist$') or text:match('^لیست گروه ها$') then
local list = redis:smembers("UltraGrandgp")
          local t = '▪ *لیست گروه های ربات:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - {`"..v.."`}\n" 
          end
          if #list == 0 then
          t = '▪ *لیست گروه های ربات خالی میباشد!*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
if text == 'del end' then
redis:del('endmsg',endmsg)
        reply_to(msg.chat_id_, msg.id_, 1,'*> انجام شد !*', 1, 'md')
            end
--------------------------------------------------------------------------------
------محروم", "gban")
        if text == 'gban' then
		if msg.reply_to_message_id_ == 0 then
        local user = msg.sender_user_id_
        else
        function banreply(extra, result, success)
        banall(msg,msg.chat_id_,result.sender_user_id_)
          end
		  end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
		      if text:match('^gban (%d+)') then
        banall(msg,msg.chat_id_,text:match('^gban (%d+)'))
        end
--------------------------------------------------------------------------------
      if text:match('^gban @(.*)') then
        local username = text:match('gban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            banall(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,banusername)
        end
--------------------------------------------------------------------------------
------رفع محروميت", "ungban")
        if text == 'ungban' then
		if msg.reply_to_message_id_ == 0 then
        local user = msg.sender_user_id_
		else
        function unbanreply(extra, result, success)
        unbanall(msg,msg.chat_id_,result.sender_user_id_)
          end
		  end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end	
--------------------------------------------------------------------------------
      if text:match('^ungban (%d+)') then
        unbanall(msg,msg.chat_id_,text:match('ungban (%d+)'))
        end
      if text:match('^ungban @(.*)') then
        local username = text:match('ungban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unbanall(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,unbanusername)
        end
--------------------------------------------------------------------------------
       if text == 'leave' or text == 'لفت'then
            changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
          end
--------------------------------------------------------------------------------
if text == 'bc' or text == 'ارسال' and tonumber(msg.reply_to_message_id_) > 0 then
          function cb(a,b,c)
          local text = b.content_.text_
          local list = redis:smembers("UltraGrandgp")
          for k,v in pairs(list) do
        reply_to(v, 0, 1, text,1, 'md')
          end
          end
          getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),cb)
          end
--------------------------------------------------------------------------------
        if text == 'fbc' or text == 'فوروارد' and tonumber(msg.reply_to_message_id_) > 0 then
          function cb(a,b,c)
          local list = redis:smembers("UltraGrandgp")
          for k,v in pairs(list) do
          forwardMessages(v, msg.chat_id_, {[0] = b.id_}, 1)
          end
          end
          getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),cb)
          end
--------------------------------------------------------------------------------
if text == 'msg_id'or text == 'ايدي پيام' then
function msgid(extra, result, success)
 reply_to(msg.chat_id_, msg.id_, 1,'`'..result.id_..'`', 1, 'md')
end
 if tonumber(msg.reply_to_message_id_) == 0 then
 else
 getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),msgid)
end
end
--------------------------------------------------------------------------------
if text == 'ليست افراد محروم' or text == 'gbanlist' then
          local list = redis:smembers('gbaned')
          local t = '▪ *لیست افراد محروم از گروه های ربات:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '▪ *لیست افراد محروم از گروه های ربات خالی میباشد!*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
if text:match("^add$") or text:match("^فعال$") and is_sudo(msg) then
if redis:sismember('add', msg.chat_id_) then
reply_to(msg.chat_id_, msg.id_, 1, '▪ گروه [`'..data.title_..'`] از قبل در لیست گروه های تحت مدیریت ربات است !', 1, 'md')
else
redis:sadd('add', msg.chat_id_)
redis:set("groupc:"..msg.chat_id_,true)
reply_to(msg.chat_id_, msg.id_, 1, '▪ گروه [`'..data.title_..'`] به لیست گروه های تحت مدیریت ربات اضافه شد !', 1, 'md')
       end
end
--------------------------------------------------------------------------------
if text:match("^rem$") or text:match("^حذف$") and is_sudo(msg) then
if not redis:sismember('add', msg.chat_id_) then
reply_to(msg.chat_id_, msg.id_, 1, '▪ گروه [`'..data.title_..'`] در لیست گروه های تحت مدیریت ربات نیست !', 1, 'md')
else
redis:srem('add', msg.chat_id_)
redis:del("groupc:"..msg.chat_id_,true)
reply_to(msg.chat_id_, msg.id_, 1, '▪ گروه [`'..data.title_..'`] از لیست گروه های تحت مدیریت ربات حذف شد !', 1, 'md')
end
end
--------------------------------------------------------------------------------
------شارژ", "charge")
if text:match('^charge (%d+)$') then 
          local gp = text:match('charge (%d+)')
		 local time = gp * day
		   redis:setex("groupc:"..msg.chat_id_,time,true)
 reply_to(msg.chat_id_, msg.id_, 1,'▪ ربات با موفقیت تنظیم شد\nمدت فعال بودن ربات در گروه به '..text:match('charge (.*)')..' روز دیگر تنظیم شد...',1,'md') 
end
--------------------------------------------------------------------------------
------تنظيم مالک", "setowner")
        if text:match("^setowner$") then
          function prom_reply(extra, result, success)
        redis:sadd('owners:'..msg.chat_id_,result.sender_user_id_)
         local text = '▪ کاربر '..result.sender_user_id_..' به مقام #مالک_گروه ارتقا یافت !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
--------------------------------------------------------------------------------
        if text:match('^setowner (%d+)') then
          local user = text:match('setowner (%d+)')
          redis:sadd('owners:'..msg.chat_id_,user)
local text = '▪ کاربر '..user..' به مقام #مالک_گروه ارتقا یافت !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
        end
--------------------------------------------------------------------------------
------حذف مالك", "deowner")
        if text:match("^delowner$") then
        function prom_reply(extra, result, success)
        redis:srem('owners:'..msg.chat_id_,result.sender_user_id_)
local text = '▪ کاربر '..result.sender_user_id_..' از لیست #مالکین_گروه حذف شد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
--------------------------------------------------------------------------------
        if text:match('^delowner (%d+)') then
          local user = text:match('deowner (%d+)')
         redis:srem('owners:'..msg.chat_id_,user)
        local text = '▪ کاربر '..result.sender_user_id_..' از لیست #مالکین_گروه حذف شد !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
      end
        end
--------------------------------------------------------------------------------
      if text == 'clean owners' or text == 'clean ownerlist' then
        redis:del('owners:'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ *لیست #مالکین_گروه با موفقیت حذف شد. *', 1, 'md')
        end
--------------------------------------------------------------------------------
  if text == 'init' or text == 'بروز' and is_sudo(msg) then
       dofile('./bot.lua') 
io.popen("rm -rf .telegram-cli/data/animation/*")
io.popen("rm -rf .telegram-cli/data/audio/*")
io.popen("rm -rf .telegram-cli/data/document/*")
io.popen("rm -rf .telegram-cli/data/photo/*")
io.popen("rm -rf .telegram-cli/data/sticker/*")
io.popen("rm -rf .telegram-cli/data/temp/*")
io.popen("rm -rf .telegram-cli/data/video/*")
io.popen("rm -rf .telegram-cli/data/voice/*")
io.popen("rm -rf .telegram-cli/data/profile_photo/*")
reply_to(msg.chat_id_, msg.id_, 1,'*▪ سیستم ربات بروز شد !*\n▪ حافظه کش ربات پاکسازی شد !', 1, 'md')
  end
--------------------------------------------------------------------------------
	    if text:match("^stats$") and is_sudo(msg) then
   local upt = UpTime()
local gps = redis:scard("UltraGrandgp")
	local users = redis:scard("usersbot")

					reply_to(msg.chat_id_, msg.id_, 1, "▪ امار ربات الترا گرند :\n\n▪ کاربران : <code>"..users.."</code>\n▪ گروه ها : <code>"..gps.."</code>\n▪ آپتایم : "..upt.."", 1, 'html')
	end 
--------------------------------------------------------------------------------
     if is_owner(msg) then
        if text == 'clean bots' or text == 'حذف ربات ها' then
      local function cb(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          kick(msg,msg.chat_id_,bots[i].user_id_)
          end
        end
       channel_get_bots(msg.chat_id_,cb)
       end
--------------------------------------------------------------------------------
------تنظیم لینک", "setlink")
          if text:match('^setlink (.*)/joinchat/(.*)') and is_owner(msg) then
  local l = {string.match(text, '^setlink (.*)/joinchat/(.*)')}
  redis:set('grouplink'..msg.chat_id_,"https://t.me/joinchat/"..l[2])
  reply_to(msg.chat_id_, msg.id_, 1,'▪ #لینک گروه اپدیت شد !', 1, 'md')
end
--------------------------------------------------------------------------------
          if text == 'clean link' or text == 'حذف لینک' then
            redis:del('grouplink'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ لینک گروه #حذف شد !', 1, 'md')
            end
--------------------------------------------------------------------------------
------تنظیم قوانین", "setrules")
if text:match('^setrules (.*)') then
            local rules = text:match('setrules (.*)')
if (#rules > 500) or (#rules < 10) then
			if #rules > 500 then
				stats = "_تعداد حروف متن خود را جهت تنظیم قوانین کاهش دهید._"
			else
				stats = "_تعداد حروف متن خود را جهت تنظیم قوانین افزایش دهید._"
			end
			text = "▪ محدوده تعداد کاراکتر ها برای تنظیم قوانین گروه از `10` تا `500` کاراکتر میباشد!\nتعداد کاراکتر های متن شما : `"..#rules.."`\n"..stats
			reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
            redis:set('grouprules'..msg.chat_id_, rules)
    reply_to(msg.chat_id_, msg.id_, 1,'▪ #قوانین گروه اپدیت شد !', 1, 'md')
            end
end
--------------------------------------------------------------------------------
          if text == 'clean rules' or text == 'حذف قوانین' then
            redis:del('grouprules'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ قوانین گروه #حذف شد !', 1, 'md')
            end
--------------------------------------------------------------------------------
------تنظیم اسم", "setname")
            if text:match('^setname (.*)') then
            local name = text:match('^setname (.*)')
            changeChatTitle(msg.chat_id_, name)
            end
--------------------------------------------------------------------------------
        if text:match("^wlc on$") then
          redis:set('status:welcome:'..msg.chat_id_,'enable')
          reply_to(msg.chat_id_, msg.id_, 1,'▪ *ارسال پیام خوش آمدگویی فعال شد.*', 1, 'md')
          end
--------------------------------------------------------------------------------
        if text:match("^wlc off$") then
          redis:set('status:welcome:'..msg.chat_id_,'disable')
          reply_to(msg.chat_id_, msg.id_, 1,'▪ *ارسال پیام خوش آمدگویی غیرفعال شد.*', 1, 'md')
          end
--------------------------------------------------------------------------------
------تنظیم پیام خوش امد گویی", "setwelcome")
        if text:match('^setwelcome (.*)') then
          local welcome = text:match('^setwelcome (.*)')
          redis:set('welcome:'..msg.chat_id_,welcome)
           local t = '▪ *پیغام خوش آمدگویی با موفقیت ذخیره شد.*'
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
          end
--------------------------------------------------------------------------------
        if text == 'rest welcome' then
          redis:del('welcome:'..msg.chat_id_,welcome)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ *پیغام خوش آمدگویی بازنشانی گردید و به حالت پیشفرض تنظیم شد.*', 1, 'md')
          end
--------------------------------------------------------------------------------
        if text == 'لیست مالکان' or text == 'ownerlist' then
          local list = redis:smembers('owners:'..msg.chat_id_)
          local t = '▪ *لیست مالکین گروه:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '▪ *لیست مالکان گروه خالی میباشد!*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
------تنظیم ناظر", "promote")
    if text == 'promote' then
        function prom_reply(extra, result, success)
        redis:sadd('mods:'..msg.chat_id_,result.sender_user_id_)
local text = '▪ کاربر '..result.sender_user_id_..' به مقام #ناظر_گروه ارتقا یافت !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
--------------------------------------------------------------------------------
        if text:match('^promote @(.*)') then
        local username = text:match('^promote @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        redis:sadd('mods:'..msg.chat_id_,result.id_)
        local text = '▪ کاربر '..result.id_..' به مقام #ناظر_گروه ارتقا یافت !'
            else 
reply_to(msg.chat_id_, msg.id_, 1,'▪ *کاربر مورد نظر یافت نشد*', 1, 'md')
            end
SendMetion(msg.chat_id_, result.id_, msg.id_, text, 8, string.len(result.id_))
          end
        resolve_username(username,promreply)
        end
--------------------------------------------------------------------------------
        if text:match('^promote (%d+)') then
          local user = text:match('promote (%d+)')
          redis:sadd('mods:'..msg.chat_id_,user)
        local text = '▪ کاربر '..user..' به مقام #ناظر_گروه ارتقا یافت !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
      end
--------------------------------------------------------------------------------
------حذف ناظر", "demote")
        if text == 'demote' then
        function prom_reply(extra, result, success)
        redis:srem('mods:'..msg.chat_id_,result.sender_user_id_)
local text = '▪ کاربر '..result.sender_user_id_..' از لیست #ناظران_گروه حذف شد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
--------------------------------------------------------------------------------
        if text:match('^demote @(.*)') then
        local username = text:match('^demote @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        redis:srem('mods:'..msg.chat_id_,result.id_)
local text = '▪ کاربر '..result.id_..' از لیست #ناظران_گروه حذف شد !'
            else 
            reply_to(msg.chat_id_, msg.id_, 1,'▪ *کاربر مورد نظر یافت نشد*', 1, 'md')
            end
           SendMetion(msg.chat_id_, result.id_, msg.id_, text, 8, string.len(result.id_))
          end
        resolve_username(username,demreply)
        end
--------------------------------------------------------------------------------
     if text == 'clean deleted' or text == "حذف دلیت اکانتی ها" and is_owner(msg) then
 local function deleteaccounts(extra, result)
    for k,v in pairs(result.members_) do 
local function cleanaccounts(extra, result)
if not result.first_name_ then
changeChatMemberStatus(msg.chat_id_, result.id_, "Kicked")
end
end
getUser(v.user_id_, cleanaccounts, nil)
 end 
reply_to(msg.chat_id_, msg.id_, 1,'▪ کاربران #دیلیت_اکانت شده از گروه حذف شد !', 1, 'md')
  end 
  tdcli_function ({ID = "GetChannelMembers",channel_id_ = getChatId(msg.chat_id_).ID,offset_ = 0,limit_ = 1096500}, deleteaccounts, nil)
  end
--------------------------------------------------------------------------------
if text == 'clean kicked' or text == "حذف لیست مسدود ها" and is_owner(msg) then
    local function removeblocklist(extra, result)
      if tonumber(result.total_count_) == 0 then 
        reply_to(msg.chat_id_, msg.id_, 0,'▪ کاربری در لیست مسدودی گروه شما قرار ندارد.', 1, 'md')
      else
      local x = 0
      for x,y in pairs(result.members_) do
        x = x + 1
        changeChatMemberStatus(msg.chat_id_, y.user_id_, 'Left', dl_cb, nil)
  end
    reply_to(msg.chat_id_, msg.id_, 0,'▪ تمامی کاربران لیست مسدودی گروه گروه حذف شد', 1, 'md')
    end
 end
  getChannelMembers(msg.chat_id_, 0, 'Kicked', 200, removeblocklist, {chat_id_ = msg.chat_id_, msg_id_ = msg.id_}) 
  end   
--------------------------------------------------------------------------------
if text:match('^demote (%d+)') then
          local user = text:match('demote (%d+)')
         redis:srem('mods:'..msg.chat_id_,user)
local text = '▪ کاربر '..user..' از لیست #ناظران_گروه حذف شد !'
SendMetion(msg.chat_id_, user, msg.id_, text, 8, string.len(user))
      end
  end
      end
--------------------------------------------------------------------------------
    if not redis:get("groupc:"..msg.chat_id_) and is_owner(msg) then
      
local link = redis:get('grouplink'..msg.chat_id_) 
or '--'
local text = 'این گروه فعال نشده است روی این متن کلیک کنید و از سازنده خریداری بفرمایید.'
  SendMetion(msg.chat_id_, 226283662, msg.id_, text, 0, 74)
	  
reply_to(226283662,0,1,'شارژ این گروه به اتمام رسید \nایدی : '..msg.chat_id_..'\nنام گروه : '..data.title_..'\nلینک : '..link..'\n\n\nدر صورتی که میخواهید ربات این گروه را ترک کند از دستور زیر استفاده کنید\n\n/leave'..msg.chat_id_..'\nبرای جوین دادن توی این گروه میتونی از دستور زیر استفاده کنی:\n/join'..msg.chat_id_..'\n_________________\nدر صورتی که میخواهید گروه رو دوباره شارژ کنید میتوانید از کد های زیر استفاده کنید...\n\n*برای شارژ 1 ماهه:*\n/plan1'..msg.chat_id_..'\n\n*برای شارژ 3 ماهه:*\n/plan2'..msg.chat_id_..'\n\n*برای شارژ نامحدود:*\n/plan3'..msg.chat_id_..'', 1, 'md')
        changeChatMemberStatus(msg.chat_id_, 378393503, "Left")
	   end
--------------------------------------------------------------------------------
	if text == 'expire' or text == "انقضا" and is_owner(msg) then
    local ex = redis:ttl("groupc:"..msg.chat_id_)
       if ex == -1 then
		reply_to(msg.chat_id_, msg.id_, 1,'▪ تاریخ انقضا برای گروه شما ثبت نشده است و مدت زمان گروه شما نامحدود میباشد', 1, 'md')
       else
        local expire = math.floor(ex / day ) + 1
			reply_to(msg.chat_id_, msg.id_, 1,"▪ ["..expire.."] روز تا پایان مدت زمان انتقضا گروه باقی مانده است.", 1, 'md') 
       end
    end
--------------------------------------------------------------------------------
   if is_mod(msg) then
      local function getsettings(value)
       if value == "charge" then
       local ex = redis:ttl("groupc:"..msg.chat_id_)
      if ex == -1 then
        return "نامحدود"
       else
        local d = math.floor(ex / day ) + 1
        return "["..d.."] روز !"
       end
elseif value == 'muteall' then
        local h = redis:ttl('muteall'..msg.chat_id_)
       if h == -1 then
        return 'فعال'
				elseif h == -2 then
			  return 'غیرفعال'
       else
        return "تا ["..h.."] ثانیه دیگر فعال است"
       end
        elseif value == 'welcome' then
        local hash = redis:get('status:welcome:'..msg.chat_id_)
        if hash == 'enable' then
         return 'فعال'
          else
          return 'غیرفعال'
          end
        elseif is_lock(msg,value) then
           return 'فعال'
          else
          return 'غیرفعال'
       end
        end
      if text:match("^setting$") or text:match("^تنظیمات$") then
        local setting = 'تنظيمات گروه '..data.title_..' عبارتند از : '
..'\n'
..'\n\n▪ قفل رگبار : '..getsettings('flood')..''
..'\n\n▪ تعداد رگبار : '..NUM_MSG_MAX..''
..'\n\n▪ زمان رگبار :  '..TIME_CHECK..''
..'\n\n▪ قفل لینک : '..getsettings('links')..''
..'\n\n▪ قفل فوروارد : '..getsettings('forward')..''
..'\n\n▪ قفل تگ : '..getsettings('tag')..''
..'\n\n▪ قفل یوزرنیم : '..getsettings('username')..''
..'\n\n▪ قفل فحش : '..getsettings('fosh')..''
..'\n\n▪ قفل ایموجی : '..getsettings('emoji')..''
..'\n\n▪ قفل مخاطب : '..getsettings('contact')..''
..'\n\n▪ قفل سنجاق : '..getsettings('pin')..''
..'\n\n▪ قفل چت : '..getsettings('muteall')..''
..'\n\n▪ قفل دستورات : '..getsettings('cmd')..''
..'\n\n▪ قفل ربات : '..getsettings('bot')..''
..'\n\n▪ قفل بازی : '..getsettings('game')..''
..'\n\n▪ قفل فارسی : '..getsettings('persian')..''
..'\n\n▪ قفل انگلیسی : '..getsettings('english')..''
..'\n\n▪ قفل ادیت : '..getsettings('edit')..''
..'\n\n▪ قفل پیام‌سرویسی : '..getsettings('tgservice')..''
..'\n\n▪ قفل اينلاين : '..getsettings('keyboard')..''
..'\n\n▪ قفل استیکر : '..getsettings('sticker')..''
..'\n\n▪ قفل عکس : '..getsettings('photo')..''
..'\n\n▪ قفل ویس : '..getsettings('voice')..''
..'\n\n▪ قفل فیلم‌سلفی : '..getsettings('selfvideo')..''
..'\n\n▪ قفل فیلم : '..getsettings('video')..''
..'\n\n▪ قفل گیف : '..getsettings('gif')..''
..'\n\n▪ قفل اهنگ : '..getsettings('audio')..''
..'\n\n▪ قفل فایل : '..getsettings('file')..''
..'\n\n▪ قفل متن : '..getsettings('text')..''
..'\n\n▪ خوش‌‌آمدگویی : '..getsettings('welcome')..''
..'\n\n▪ مهلت ربات : '..getsettings('charge')..''
reply_to(msg.chat_id_, msg.id_, 1,setting, 1, 'html')
end
--------------------------------------------------------------------------------
      --[[if text:match("^menu$") or text:match("^منو$") then
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 302333716,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(msg.chat_id_),
      offset_ = 0
    }, inline, nil)
       end]]--
--------------------------------------------------------------------------------
	if text:match('^موزیک (.*)') then
        local MusicName = text:match('موزیک (.*)')
 function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[math.random(#data.results_)].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 117678843,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(MusicName),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
	if text:match('^عکس (.*)') then
        local photo = text:match('عکس (.*)')
 function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[math.random(#data.results_)].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 109158646,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(photo),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
	if text:match('^گیف (.*)') then
        local gif = text:match('گیف (.*)')
 function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[math.random(#data.results_)].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 140267078,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(gif),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
if text == 'nerkh' or text == 'نرخ' then
local nr = [[
Nerkh Bot [UltraGrand](http://telegram.me/UltraGrand)
1 Mah ≈> 5 Toman
3 Mah ≈> 7 Toman
5 Mah ≈> 10 Toman
Na mahdod => 15 Toman
[Admin](http://telegram.me/GrandDev)
[Report](http://telegram.me/GrandDevBot)
[Channel](http://telegram.me/GrandTeam)
]]
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 346856492,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = nr,
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
------تنظیم فلود", "setflood")
if text:match('^setflood (%d+)$') then
          redis:set('floodmax'..msg.chat_id_,text:match('setflood (.*)'))
          reply_to(msg.chat_id_, msg.id_, 1,'▪ *حداکثر پیام تشخیص ارسال پیام مکرر تنظیم شد به:* [*'..text:match('setflood (.*)')..'*]', 1, 'md')
        end
--------------------------------------------------------------------------------
------تنظیم زمان فلود", "setfloodtime")
        if text:match('^setfloodtime (%d+)$') then
          redis:set('floodtime'..msg.chat_id_,text:match('setfloodtime (.*)'))
          reply_to(msg.chat_id_, msg.id_, 1,'▪ *حداکثر زمان تشخیص ارسال پیام مکرر تنظیم شد به:* [*'..text:match('setfloodtime (.*)')..'*]', 1, 'md')
        end
--------------------------------------------------------------------------------
if text:match("^link$") or text:match("^لینک$") then
local link = redis:get('grouplink'..msg.chat_id_) 
if not redis:get('grouplink'..msg.chat_id_) then
reply_to(msg.chat_id_, msg.id_, 1, '▪ *لینک ورود به گروه تنظیم نشده.*\n*ثبت لینک جدید با دستور*\n*/setlink* <i>لینک</i>', 1, 'md')
else
local text = '[لینک گروه '..data.title_..']('..link..')'
function viabold(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 107705060,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = text,
      offset_ = 0
    }, viabold, nil)
end
end
--------------------------------------------------------------------------------
if text == 'rules' or text == 'قوانین' then
          local rules = redis:get('grouprules'..msg.chat_id_) 
          if rules then
        reply_to(msg.chat_id_, msg.id_, 1, ' '..rules, 1, 'md')
            else
        reply_to(msg.chat_id_, msg.id_, 1, '▪ *قوانین گروه تنظیم نشده.*\n*ثبت قوانین جدید با دستور*\n*/setrules* <i>قوانین</i>', 1, 'md')
            end
          end
--------------------------------------------------------------------------------
        if text == 'muteall' or text == 'قفل گروه' then
          redis:set('muteall'..msg.chat_id_,true)
        reply_to(msg.chat_id_, msg.id_, 1, '▪ *گروه با موفقیت تعطیل شد*', 1, 'md')
          end
--------------------------------------------------------------------------------
------قفل گروه", "muteall")
if text:match('^(muteall) (.*) (.*) (.*)$') then
  local mutematch = {string.match(text, '^(muteall) (.*) (.*) (.*)$')}
  local hour = string.gsub(mutematch[2], 'h', '')
  local num1 = tonumber(hour) * 3600
  local minutes = string.gsub(mutematch[3], 'm', '')
  local num2 = tonumber(minutes) * 60
  local second = string.gsub(mutematch[4], 's', '')
  local num3 = tonumber(second)
  local num4 = tonumber(num1 + num2 + num3)
  local hash = 'muteall'..msg.chat_id_
  redis:setex(hash, num4, true)
  reply_to(msg.chat_id_, msg.id_, 1, '▪ *تعطیلی گروه با موفقیت فعال شد برای :*\n*'..hour..'* ساعت و\n*'..minutes..'* دقیقه و\n*'..second..'* ثانیه', 1, 'md')
end
--------------------------------------------------------------------------------
        if text == 'unmuteall' or text == 'بازکردن گروه' then
          redis:del('muteall'..msg.chat_id_)
        reply_to(msg.chat_id_, msg.id_, 1, '▪ *تعطیلی گروه با موفقیت غیرفعال شد*', 1, 'md')
          end
--------------------------------------------------------------------------------
        if text == 'muteall stats' then
          local status = redis:ttl('muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = '▪ زمانی برای غیرفعال شدن تعطیلی گروه تعین نشده'
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
            else
          t = '▪ *'..status..'* *ثانیه دیگر تا غیرفعال شدن تعطیلی گروه مانده است*'
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
          end
          end
--------------------------------------------------------------------------------
    if text == 'بن لیست' or text == 'banlist' then
          local list = redis:smembers('banned'..msg.chat_id_)
          local t = '▪ *لیست افراد بن شده از گروه:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '▪ *لیست افراد بت شده از گروه خالی میباشد.*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
      if text == 'حذف بن لیست' or text == 'clean banlist' then
        redis:del('banned'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ لیست افراد #بن شده خالی شد', 1, 'md')
        end
--------------------------------------------------------------------------------
        if text == 'لیست بی صدا' or text == 'mutelist' then
          local list = redis:smembers('mutes'..msg.chat_id_)
          local t = '▪ *لیست کاربران بی صدا* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '▪ لیست افراد بی صدا شده خالی است !'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end      
--------------------------------------------------------------------------------
      if text == 'حذف لیست بی صدا' or text == 'clean mutelist' then
        redis:del('mutes'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ لیست افراد #بی صدا شده خالی شد', 1, 'md')
        end
--------------------------------------------------------------------------------
if text:match('^warnmax (%d+)') then
local num = text:match('^warnmax (%d+)')
if 2 > tonumber(num) or tonumber(num) > 30 then
reply_to(msg.chat_id_, msg.id_, 1,'▪ عددی بزرگتر از 2 و کوچکتر از 30 وارد کنید !', 1, 'md')
else
redis:hset("warn:"..msg.chat_id_ ,"warnmax" ,num)
reply_to(msg.chat_id_, msg.id_, 1, '▪ تعداد اخطار به '..num..' بار تنظیم شد ! ', 1, 'md')
end
end
if is_owner(msg) then
if text == 'setwarn kick' then
redis:hset("warn:"..msg.chat_id_ ,"swarn",'kick') 
reply_to(msg.chat_id_, msg.id_, 1,'▪ وضعیت اخطار بر روی حالت #اخراج تنظیم شد !', 1, 'html')
elseif text == 'setwarn ban' then
redis:hset("warn:"..msg.chat_id_ ,"swarn",'ban') 
reply_to(msg.chat_id_, msg.id_, 1,'▪ وضعیت اخطار بر روی حالت #بن تنظیم شد !', 1, 'html')
elseif text == 'setwarn mute' then
redis:hset("warn:"..msg.chat_id_ ,"swarn",'mute') 
reply_to(msg.chat_id_, msg.id_, 1,'▪ وضعیت اخطار بر روی حالت #بی_صدا تنظیم شد !', 1, 'html')
end
end
if text == 'warn' and tonumber(msg.reply_to_message_id_) > 0 then
		function warn_by_reply(extra, result, success)
if priv(msg.chat_id_,result.sender_user_id_) then
      reply_to(msg.chat_id_, msg.id_, 1,'▪ شما نمیتوانید به ( ناظران , مالکان , سازندگان ) اخطار دهدید !', 1, 'md')
    else
		local nwarn = tonumber(redis:hget("warn:"..result.chat_id_,result.sender_user_id_) or 0)
	    local wmax = tonumber(redis:hget("warn:"..result.chat_id_ ,"warnmax") or 3)
		if nwarn == wmax then
	    redis:hset("warn:"..result.chat_id_,result.sender_user_id_,0)
         warn(msg,msg.chat_id_,result.sender_user_id_)
		 else 
		redis:hset("warn:"..result.chat_id_,result.sender_user_id_,nwarn + 1)
local text = '▪ کاربر '..result.sender_user_id_..' به دلیل عدم رعایت قوانین ('..(nwarn + 1)..'/'..wmax..') #اخطار دریافت کرد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
		end  
end
		end 
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),warn_by_reply)
	end
if text == 'unwarn' and tonumber(msg.reply_to_message_id_) > 0 then
		function unwarn_by_reply(extra, result, success)
if priv(msg.chat_id_,result.sender_user_id_) then
    else
if not redis:hget("warn:"..result.chat_id_,result.sender_user_id_) then
local text = '▪ کاربر '..result.sender_user_id_..' هیچ اخطاری ندارد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
local warnhash = redis:hget("warn:"..result.chat_id_,result.sender_user_id_)
else redis:hdel("warn:"..result.chat_id_,result.sender_user_id_,0)
local text = '▪ کاربر '..result.sender_user_id_..' تمام اخطار هایش پاک شد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
end
 end
end
getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unwarn_by_reply)
end
------کیک", "kick")
      if text == 'kick' and tonumber(msg.reply_to_message_id_) > 0 then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
--------------------------------------------------------------------------------
      if text:match('^kick (%d+)') then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
        end
      if text:match('^kick @(.*)') then
        local username = text:match('kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,kick_username)
        end
--------------------------------------------------------------------------------
------بن", "ban")
        if text == 'ban' and tonumber(msg.reply_to_message_id_) > 0 then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
--------------------------------------------------------------------------------
      if text:match('^ban (%d+)') then
        ban(msg,msg.chat_id_,text:match('ban (%d+)'))
        end
      if text:match('^ban @(.*)') then
        local username = text:match('ban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,banusername)
        end
--------------------------------------------------------------------------------
------انبن", "unban")
      if text == 'unban' and tonumber(msg.reply_to_message_id_) > 0 then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
--------------------------------------------------------------------------------
      if text:match('^unban (%d+)') then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
        end
      if text:match('^unban @(.*)') then
        local username = text:match('unban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,unbanusername)
        end
--------------------------------------------------------------------------------
------بی صدا", "mute")
        if text == 'mute' and tonumber(msg.reply_to_message_id_) > 0 then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
--------------------------------------------------------------------------------
      if text:match('^mute (%d+)') then
        mute(msg,msg.chat_id_,text:match('mute (%d+)'))
        end
      if text:match('^mute @(.*)') then
        local username = text:match('mute @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,muteusername)
        end
--------------------------------------------------------------------------------
------حذف بی صدا", "unmute")
      if text == 'unmute' and tonumber(msg.reply_to_message_id_) > 0 then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
--------------------------------------------------------------------------------
      if text:match('^unmute (%d+)') then
        unmute(msg,msg.chat_id_,text:match('unmute (%d+)'))
        end
      if text:match('^unmute @(.*)') then
        local username = text:match('unmute @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,unmuteusername)
        end
--------------------------------------------------------------------------------
------دعوت", "invite")
         if text == 'invite' and tonumber(msg.reply_to_message_id_) > 0 then
        function inv_by_reply(extra, result, success)
        addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
--------------------------------------------------------------------------------
      if text:match('^invite (%d+)') then
        addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text:match('^invite @(.*)') then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,invite_username)
        end
--------------------------------------------------------------------------------
------حذف", "rmsg")
    if text:match('^rmsg (%d+)$') then
        local limit = tonumber(text:match('^rmsg (%d+)$'))
        if limit > 1000 then
        reply_to(msg.chat_id_, msg.id_, 1, '▪ تعداد پیام وارد شده از حد مجاز (1000 پیام) بیشتر است !', 1, 'md')
          else
         function cb(a,b,c)
        local msgs = b.messages_
        for i=1 , #msgs do
          delete_msg(msg.chat_id_,{[0] = b.messages_[i].id_})
        end
        end
        getChatHistory(msg.chat_id_, 0, 0, limit + 1,cb)
        reply_to(msg.chat_id_, msg.id_, 1, '▪ (*'..limit..'*)پیام اخیر گرو پاک شد', 1, 'md')
        end
        end
--------------------------------------------------------------------------------
------حذف همه", "rmsg all")
  if text:match('^rmsg all$') then
       local function delete_msgs_pro(arg,data)
local delall = data.members_
            if not delall[0] then
    reply_to(msg.chat_id_, msg.id_, 1, 'EeeeeeeeE', 1, 'md')
      else

 for k, v in pairs(data.members_) do  
                deleteMessagesFromUser(msg.chat_id_, v.user_id_)
end

      reply_to(msg.chat_id_, msg.id_, 1, '▪ پیام های گروه با موفقیت حذف شدند', 1, 'md')
           end
           end
tdcli_function ({
                    ID = "GetChannelMembers",
                    channel_id_ = getChatId(msg.chat_id_).ID,
                    filter_ = {
                      ID = "ChannelMembersRecent"
                    },
                    offset_ = 0,
                    limit_ = 10000
                  }, delete_msgs_pro, nil)
                tdcli_function ({
                    ID = "GetChannelMembers",
                    channel_id_ = getChatId(msg.chat_id_).ID,
                    filter_ = {
                      ID = "ChannelMembersKicked"
                    },
                    offset_ = 0,
                    limit_ = 10000
                  }, delete_msgs_pro, nil)
end
--------------------------------------------------------------------------------
      if tonumber(msg.reply_to_message_id_) > 0 then
    if text == "del" then
        delete_msg(msg.chat_id_,{[0] = tonumber(msg.reply_to_message_id_),msg.id_})
    end
        end
--------------------------------------------------------------------------------
    if text == 'modlist' or text == 'لیست ناظران' then
          local list = redis:smembers('mods:'..msg.chat_id_)
          local t = '▪ *لیست ناظران گروه:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '▪ *ناظر برای این گروه ثبت نشده است.*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
      if text == 'clean modlist' or text == 'حذف لیست ناظران' then
        redis:del('mods:'..msg.chat_id_)

          reply_to(msg.chat_id_, msg.id_, 1,'▪ لیست ناظران گروه #حذف شد !', 1, 'md')
        end
--------------------------------------------------------------------------------
------فیلتر", "filter")
      if text:match('^filter +(.*)') then
        local w = text:match('^filter +(.*)')
         redis:sadd('filters:'..msg.chat_id_,w)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ ('..w..') *به لیست کلمات فیلتر شده اضاف شد!*', 1, 'md')
       end
--------------------------------------------------------------------------------
------حذف فیلتر", "rw")
      if text:match('^rw +(.*)') then
        local w = text:match('^rw +(.*)')
         redis:srem('filters:'..msg.chat_id_,w)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ ('..w..') *از لیست کلمات فیلتر شده پاک شد!*', 1, 'md')
       end
--------------------------------------------------------------------------------
      if text == 'clean filterlist' or text == 'حذف فیلتر لیست' and is_mod(msg) then
        redis:del('filters:'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'▪ لیست کلمات #فیلتر شده خالی شد !', 1, 'md')
        end
   if text == 'filterlist' or text == 'لیست کلمات فیلتر شده' then
          local list = redis:smembers('filters:'..msg.chat_id_)
          local t = '▪ *لیست کلمات فیلتر شده:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '▪ *فیلتر لیست خالی است.*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
  if text == 'config admin' then
       local function cb(extra,result,success)
        local list = result.members_
            for k,v in pairs(list) do
redis:sadd('mods:'..msg.chat_id_,v.user_id_)
end
reply_to(msg.chat_id_, msg.id_, 1, '▪ تمامی ادمین های گروه به لیست ناظران گروه اضافه گردید', 1, 'md')
          end
       channel_get_admins(msg.chat_id_,cb)
      end
--------------------------------------------------------------------------------
if text == "upchat" and is_sudo(msg) then
 migragrateGroupChatToChannelChat(msg.chat_id_)
reply_to(msg.chat_id_, msg.id_, 1, '▪ انجام شد', 1, 'md')
end
--------------------------------------------------------------------------------------------------------------------------------------------
if text == 'addkick' then
        local function cb(extra,result,success)
        local list = result.members_
            for k,v in pairs(list) do
addChatMember(msg.chat_id_, v.user_id_, 50, dl_cb, nil)
                    end
         reply_to(msg.chat_id_, msg.id_, 1, '▪ تمام اعضا ریمو شده گروه به گروه اد شدند', 1, 'md')
          end
       channel_get_kicked(msg.chat_id_,cb)
      end
--------------------------------------------------------------------------------
    if msg_type == 'text' then
        if text then
      if text:match('^id @(.*)') then
        local username = text:match('^id @(.*)')
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '`'..result.id_..'`'
            else 
            text = '▪ *کاربر مورد نظر یافت نشد!*'
            end
           reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
          end
        resolve_username(username,id_by_username)
        end 
--------------------------------------------------------------------------------
			if text == 'pin' or text == 'پین' and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
end
--------------------------------------------------------------------------------
if text == 'unpin' or text == 'ان پین' and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
       unpin(msg.chat_id_)
end
--------------------------------------------------------------------------------
if text == 'report' or text == 'ریپورت' then
      function rep(extra, result, success)
  if priv(msg.chat_id_,result.sender_user_id_) then
reply_to(msg.chat_id_, msg.id_, 1,'▪ شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #ریپورت کنید !', 1, 'md')
else
       reportChannelSpam(msg.chat_id_, result.sender_user_id_, {[0] = msg.id_})
local text = '▪ کاربر '..result.sender_user_id_..' ریپورت شد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
end
end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),rep)
      end
        end
--------------------------------------------------------------------------------
if text == 'gpinfo' and is_mod(msg) then
 function gpinfo(arg,data)
    -- vardump(data)
reply_to(msg.chat_id_, msg.id_, 1, '▪ نام گروه : '..data.title_..'\n▪ ادمین ها : *'..data.administrator_count_..'*\n▪ مسدود شدها : *'..data.kicked_count_..'*\n▪ اعضا : *'..data.member_count_..'*\n', 1, 'md')
end
  getChannelFull(msg.chat_id_, gpinfo, nil)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
        if text:match('whois (%d+)') then
              local id = text:match("whois (%d+)")
            local text = 'برای مشاهده اطلاعات کاربر کلیک کنید.'
			--{"👤 برای مشاهده کاربر کلیک کنید!","Click to view User 👤"}
            tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=36, user_id_=id}}}}, dl_cb, nil)
              end
--------------------------------------------------------------------------------
        if text == "id" then
      function id_by_reply(extra, result, success)
        reply_to(msg.chat_id_, msg.id_, 1, '`'..result.sender_user_id_..'`', 1, 'md')
        end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),id_by_reply)
      end
        end

          end
        end
      end
--------------------------------------------------------------------------------
if text == "ping" or text == "پینگ" then
local text = 'PONG'
SendMetion(msg.chat_id_, msg.sender_user_id_, msg.id_, text, 0, 4)
end
--------------------------------------------------------------------------------
	  redis:incr("allmsg")
	  if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not redis:sismember("UltraGrandgp",msg.chat_id_) then  
            redis:sadd("UltraGrandgp",msg.chat_id_)
			 -- redis:incrby("g:pa")
        end
        elseif id:match('^(%d+)') then
        if not redis:sismember("usersbot",msg.chat_id_) then
            redis:sadd("usersbot",msg.chat_id_)
			--redis:incrby("pv:mm")
        end
        else
        if not redis:sismember("UltraGrandgp",msg.chat_id_) then
            redis:sadd("UltraGrandgp",msg.chat_id_)
			 -- redis:incrby("g:pa")
        end
     end
    end
--------------------------------------------------------------------------------
  if text == "help" or text == "راهنما" and is_mod(msg) then
help = [[
▫️ راهنمای ربات التراگرند 😐💪

➖➖➖➖➖➖➖➖➖➖➖➖➖

/settings
🔸دریافت تنظیمات گروه

/me
🔹دریافت اعطلاعات خود

/setrules [قوانین]
🔸تنظیم قوانین گروه

/rules 
🔹دریافت قوانین گروه

/promote [username/reply/user-id]
🔸تنظیم ناظر

/demote [username/reply/user-id]
🔹حذف ناظران

/ownerlist
🔸دریافت لیست مدیران 

/modlist
🔹لیست ناظران

/setlink [لینک]
🔸تنظیم لینک گروه

/link 
🔹دریافت لینک گروه

/kick [username/reply/user-id]
🔸حذف کاربر 

/clean modlist
🔹حذف لیست ناظران

/clean deleted
?حذف کاربران دلیت اکانت شده

/clean welcome 
🔹حذف پیام خوش اومد گویی

/clean bots 
🔸حذف همه ربات ها

/clean mutelist 
🔹حذف میوت لیست

/clean filterlist 
🔸حذف فیلتر لیست

/addkicked
🔹اد افراد حذف شده

/welcome on
🔸فعال کردن پیام خوش اومد گویی

/welcome off
🔹غیر فعال کردن پیام خوش اومد گویی

/setwelcome متن
🔸تنظیم پیام خوش اومد گویی

/muteall 
🔹قفل کردن گروه

/unmuteall 
?غیرفعال کردن قفل گروه

/muteall [عدد]
🔹قفل گروه (زمانی)


/mutelist
🔸دریافت لیست کاربرانسایلنت شده


/unmute [username/reply/user-id]
🔹حذف کاربر از لیست سایلنت ها


/mute [username/reply/user-id]
🔸سایلنت کردن یک فرد 

/filter کلمه
🔹اضافه کردن کلمه به لیست فیلتر ها

/rw کلمه
🔸حذف کلمه از لیست فیلتر لیست

/filterlist 
🔹لیست کلمات فیلتر شده

/rmsg all
🔸حذف تمام پیام های گروه

/rmsg [عدد]
🔹حذف پیام 

/setflood [عدد]
🔸تنظیم حساسیت فلود

/setfloodtime [عدد]
🔹 تنظیم حساسیت فلود بر حسب زمان

/lock/unlock [links|username|sticker|contact|english|persian|forward|photo|video|gif|music|audio|text|keyboard|tgservice|pin|join|selfvideo|spam|tag]
🔸برای قفل کردن Lock links
🔹برای باز کردن Unlock links
➖➖➖➖➖➖➖➖➖➖➖➖➖➖
]]
reply_to(msg.chat_id_, msg.id_, 1, help, 1, 'md')
end
--------------------------------------------------------------------------------
 if text == 'myrank' then
       local rank =  redis:get('ranks:'..msg.sender_user_id_) or '▪ ست نشده'
reply_to(msg.chat_id_, msg.id_, 1,''..rank..'',1,'md') 
end
if text:match("^ربات$") then
if redis:get('ranks:'..msg.sender_user_id_) then
local rank =  redis:get('ranks:'..msg.sender_user_id_) 
reply_to(msg.chat_id_, msg.id_, 1,'😊 جانم '..rank..' ؟',1,'md') 
else
          local p = {"چه عجب","جونز؟","جانم","ها؟","چیه همش صدام میکنی 😐"}
          reply_to(msg.chat_id_, msg.id_, 1,''..p[math.random(#p)]..'', 1, 'html')
      end
end
if text:match("^بای$") or text:match("^خدافظ$") then
if redis:get('ranks:'..msg.sender_user_id_) then
local rank =  redis:get('ranks:'..msg.sender_user_id_) 
reply_to(msg.chat_id_, msg.id_, 1,'🍃 فعلا '..rank..' ',1,'md') 
else
          local p = {"🍃 فعلا"}
          reply_to(msg.chat_id_, msg.id_, 1,''..p[math.random(#p)]..'', 1, 'html')
      end
end
if text:match("^سلام$") or text:match("^هلو$") or text:match("^س$") or text:match("^های$") then
if redis:get('ranks:'..msg.sender_user_id_) then
local rank =  redis:get('ranks:'..msg.sender_user_id_) 
reply_to(msg.chat_id_, msg.id_, 1,'😊 سلام '..rank..' ',1,'md') 
else
          local p = {"علیکه سلام😕"}
          reply_to(msg.chat_id_, msg.id_, 1,''..p[math.random(#p)]..'', 1, 'html')
      end
end
--------------------------------------------------------------------------------
    if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
if text:match("^me$") or text:match("^من$") then
if tonumber(msg.reply_to_message_id_) == 0 then
local ranks = redis:get('ranks:'..msg.sender_user_id_) or 'ست نشده'
if is_sudo(msg) then
            rank = 'سودو'
            elseif is_owner(msg) then
            rank = 'مالک گروه'
            elseif is_mod(msg) then
            rank = 'ناظر گروه'
            else
            rank = 'کاربر عادی'
          end
	   local function getpro(extra, result, success)
 if result.photos_[0] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'▪ شناسه شما : '..msg.sender_user_id_..' \n▪ مقام شما :'..rank..'\n▪ لقب شما : '..ranks..'')
      else
local photos = '/root/not.jpg'
sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, photos,'▪ شناسه شما : '..msg.sender_user_id_..' \n▪ مقام شما :'..rank..'\n▪ لقب شما : '..ranks..'')
   end
end
    tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
	end
end
end
end
--------------------------------------------------------------------------------
if text:match("^id$") or text:match("^ایدی$") and msg.reply_to_message_id == 0  then
function GetID(msg)
function id(arg,data)
    -- vardump(data)
reply_to(msg.chat_id_, msg.id_, 1, 'شناسه گروه '..data.title_..' : \n\n`'..msg.chat_id_:gsub('-100','')..'`', 1, 'md')
end
getChat(msg.chat_id_, id, nil) 
end
local url , res = https.request('https://api.telegram.org/bot'..Token..'/getchatmember?chat_id='..ch_id..'&user_id='..msg.sender_user_id_)
		data = json:decode(url)
		if res ~= 200 or data.result.status == "left" or data.result.status == "kicked" then
				reply_to(msg.chat_id_, msg.id_, 1,[[سلام دوست عزیز به نظر میرسد که در کانال ربات عضو نیستید پس از شما تقاضا میشود که در کانال جوین شوید
@GrandTeam]], 1, 'md')
		elseif data.ok then
			GetID(msg)
	else
		GetID(msg)
	end
end
end
getChat(msg.chat_id_, get_gp, nil) 
end
--------------------------------------------------------------------------------
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
     run(data.message_,data)
  elseif (data.ID == "UpdateMessageEdited") then
    data = data
    local function edited_cb(extra,result,success)
      run(result,data)
    end
--------------------------------------------------------------------------------
getMessage(data.chat_id_, data.message_id_,edited_cb)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
getChats(9223372036854775807, 0, 20, dl_cb, nil)
end
end
--------------------------------------------------------------------------------
Run()
--------------------------------------------------------------------------------
