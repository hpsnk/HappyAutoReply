-- Author      : Matthew Enthoven (Alias: Blacksen)

-- [防脚本检测]请在聊天频道回答以下问题的答案:333+444=? ,剩余回答时间为:300秒，超时会被强制下线，连续多次超时会被封号。

-- local testMsg1 = "|cff3DAEFF[防脚本检测]请在聊天频道回答以下问题的答案:|cffFFD800"
local testMsg1 = "[防脚本检测]请在聊天频道回答以下问题的答案:"
local testMsg2 = "=? ,剩余回答时间为:300秒，超时会被强制下线，连续多次超时会被封号。"

-------------------------------------------------------
LOGGER = {}
TARGET_MSG_1 = "防脚本检测"
TARGET_MSG_2 = "请在聊天频道回答以下问题的答案"
TARGET_MSG_3 = "剩余回答时间"
TARGET_MSG_4 = "请在聊天频道回答以下问题的答案:|cffFFD800"

TARGET_MSG_INVITE_CHECK = "555"
TARGET_MSG_INVITE_APPLY = "666"

AUTO_FOLLOW_PLAYER_NAME = "";
AUTO_FOLLOW_START_MSG   = "111";
AUTO_FOLLOW_STOP_MSG    = "222";

HAR_ACTIVE_FLAG = true;
TRACE_FLAG = false;

HappyAutoReplyDataPerCharDB = {}
-------------------------------------------------------

SLASH_HAR1 = "/har";
SLASH_HAR2 = "/happyar";
SlashCmdList["HAR"] = function(msg)
	local cmd, arg = string.split(" ", msg, 2);
	cmd = cmd:lower()

	if cmd == "show" then
		HAR_MainFrame:Show();

	elseif cmd == "hide" then
		HAR_MainFrame:Hide();

	elseif cmd == "on" then
		HAR_ACTIVE_FLAG = true;
		HappyAutoReplyDataPerCharDB.active = true;
		print("[HappyAutoReply]Active=" .. tostring(HAR_ACTIVE_FLAG) .. "." );

	elseif cmd == "off" then
		HAR_ACTIVE_FLAG = false;
		HappyAutoReplyDataPerCharDB.active = false;
		print("[HappyAutoReply]Active=" .. tostring(HAR_ACTIVE_FLAG) .. "." );

	elseif cmd == "trace" then
		if TRACE_FLAG then
			TRACE_FLAG = false;
			HappyAutoReplyDataPerCharDB.trace = false;
		else
			TRACE_FLAG = true;
			HappyAutoReplyDataPerCharDB.trace = true;
		end
		print("[HappyAutoReply]Trace=" .. tostring(TRACE_FLAG) .. "." );

	elseif cmd == "dump" then
		HAR_dumpLog();

	elseif cmd == "" then
		-- print("|cFFFF0000Raid Invite Organizer|r:");
		print("/har cmd");
		print("---->show  - shows the main frame.")
		print("---->hide  - hide the main frame.")
		print("---->on    - 开启自动回答验证功能")
		print("---->off   - 关闭自动回答验证功能")
		print("---->trace - switch trace flag.")
		print("---->dump  - dump all logs.")
		print("---->xxx   - switch trace flag.")
		print("[HappyAutoReply]Active=" .. tostring(HAR_ACTIVE_FLAG) .. "." );
		print("[HappyAutoReply]Trace =" .. tostring(TRACE_FLAG) .. "." );
		

	else
		-- LOGGER.debug("arg=" .. arg);
		SendChatMessage(testMsg1 .. cmd .. testMsg2);
		-- print("" .. msg .. " is not a valid command for /har");
	end
end

function HAR_EventHandler(self, event, ...)
	LOGGER.trace("receive event= " .. event .. ".");

	if event == "CHAT_MSG_WHISPER" then
		local msg, author, theRest = ...;
		LOGGER.trace("receive WHISPER message. msg=" .. msg .. ".");
		if HAR_checkTargetMessage(msg) then
			LOGGER.debug("---->check this message!");
			HAR_saveLog("CHAT_MSG_WHISPER", author, msg);
		end

	elseif event == "CHAT_MSG_SAY" then
		local msg, sendPlayerName = ...;
		LOGGER.trace("receive SAY message. msg=" .. msg .. ".");
		if HAR_checkTargetMessage(msg) then
			LOGGER.debug("---->check this message from "..sendPlayerName..".");
			HAR_saveLog("CHAT_MSG_SAY", sendPlayerName, msg);
			HAR_sloveQuestion(msg);
		end

	elseif event == "CHAT_MSG_SYSTEM" then
		local msg = ...;
		LOGGER.trace("receive SYSTEM message. msg=" .. msg .. ".");
		if HAR_checkTargetMessage(msg) then
			LOGGER.debug("---->check this message!");
			HAR_sloveQuestion(msg);
			HAR_saveLog("CHAT_MSG_SYSTEM", "SYSTEM", msg);
		end

	elseif event == "PARTY_INVITE_REQUEST" then
		local playerName = ...;
		LOGGER.trace(playerName .. " invite you into a party.");
		AUTO_FOLLOW_PLAYER_NAME = playerName;
		AcceptGroup();

	elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		local msgText, playerName = ...;
		LOGGER.trace("receive PARTY message. msg=" .. msgText .. ".");
		if HAR_isStartFllowMsg(playerName, msgText) then
			LOGGER.trace("  start follow by >>" .. playerName .. "<<.");
			HAR_followStart();

		elseif HAR_isStopFllowMsg(playerName, msgText) then
			LOGGER.trace("  stop follow by >>" .. playerName .. "<<.");
			HAR_followStop();

		end
	end
end

function HAR_MainFrame_OnLoad()
	HAR_MainFrame:SetScript("OnEvent", HAR_EventHandler);
	HAR_MainFrame:RegisterEvent("CHAT_MSG_PARTY");
	HAR_MainFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER");
	HAR_MainFrame:RegisterEvent("CHAT_MSG_SAY");
	HAR_MainFrame:RegisterEvent("CHAT_MSG_SYSTEM");
	HAR_MainFrame:RegisterEvent("CHAT_MSG_WHISPER");
	HAR_MainFrame:RegisterEvent("PARTY_INVITE_REQUEST");

	print("HappyAutoReply Load complete!");
end

function LOGGER.debug(msg)
	print("[har][debug]" .. msg);
end

function LOGGER.trace(msg)
	if TRACE_FLAG then
		print("[har][trace]" .. msg);
	end
end

function HAR_checkTargetMessage(msg)
	msg = string.upper(msg);
	if (string.find(msg, TARGET_MSG_1) and string.find(msg, TARGET_MSG_2)) then
		return true;
	end
	return false;
end

function HAR_sloveQuestion(msg)
	local posA1, posA2
	if (string.find(msg, TARGET_MSG_4)) then
		posA1, posA2 = string.find(msg, TARGET_MSG_4);
		posA2 = posA2 + 1;
	else
		posA1, posA2 = string.find(msg, TARGET_MSG_2);
		posA2 = posA2 + 2;
	end

	local posB1 = string.find(msg, "=", posA2)

	-- start pos = find + 2 (skip fullspace character and :)
	-- end   pos = find - 1 (skip =)
	local subString = string.sub(msg, posA2, posB1-1)
	LOGGER.debug(">"..subString.."<");

	local val1,operate,val2 = string.match(subString, "(%d+)([%+%-%*/])(%d+)")

	LOGGER.debug( val1 );
	LOGGER.debug( operate );
	LOGGER.debug( val2 );

	local numberVal1 = tonumber(val1)
	local numberVal2 = tonumber(val2)

	local numberAnswer
	if operate == "+" then
		numberAnswer = numberVal1 + numberVal2
	elseif operate == "-" then
		numberAnswer = numberVal1 - numberVal2
	elseif operate == "*" then
		numberAnswer = numberVal1 * numberVal2
	elseif operate == "/" then
		numberAnswer = numberVal1 / numberVal2
	end
	
	LOGGER.debug( "=" );
	LOGGER.debug( numberAnswer );

	if HAR_ACTIVE_FLAG then
		SendChatMessage(tostring(numberAnswer));		
	end
end

function HAR_isStartFllowMsg(playerName, msgText)
	if playerName == AUTO_FOLLOW_PLAYER_NAME and msgText == AUTO_FOLLOW_START_MSG then
		return true;
	end
	return false;
end

function HAR_isStopFllowMsg(playerName, msgText)
	if playerName == AUTO_FOLLOW_PLAYER_NAME and msgText == AUTO_FOLLOW_STOP_MSG then
		return true;
	end
	return false;
end

function HAR_followStart()
	for i = 1, 5 do
		local strUnitId = "party"..i;
		LOGGER.debug("  check " .. strUnitId)
		local strUnitName = UnitName(strUnitId);
		if strUnitName == nil then
			break;
		end
		LOGGER.debug(strUnitId.."="..strUnitName..".");
		if strUnitName == AUTO_FOLLOW_PLAYER_NAME then
			FollowUnit(strUnitId);
		end
	end
end

function HAR_followStop()
	FollowUnit( "player" );
	FollowUnit( "none" );
end

function HAR_dumpLog()
	LOGGER.trace( "dump logs." )

	local logSize = #HappyAutoReplyDataPerCharDB.log;
	for i = 1, logSize, 1 do
		local log = HappyAutoReplyDataPerCharDB.log[i];
		LOGGER.debug( "idx=" .. i .. ", datetime=" .. log.datetime .. ", event=" .. log.event .. ", sender=" .. log.sender .. ", text=" .. log.text );
	end
end

function HAR_saveLog(event, sender, msg)
	if HappyAutoReplyDataPerCharDB.log == nil then
		HappyAutoReplyDataPerCharDB.log = {}
	end
	local checkMsg = {};
	checkMsg.datetime = date();
	checkMsg.event = event;
	checkMsg.sender = sender;
	checkMsg.text = msg;

	local logSize = #HappyAutoReplyDataPerCharDB.log;
	if (logSize>5) then
		HappyAutoReplyDataPerCharDB.log[1] = HappyAutoReplyDataPerCharDB.log[2];
		HappyAutoReplyDataPerCharDB.log[2] = HappyAutoReplyDataPerCharDB.log[3];
		HappyAutoReplyDataPerCharDB.log[3] = HappyAutoReplyDataPerCharDB.log[4];
		HappyAutoReplyDataPerCharDB.log[4] = HappyAutoReplyDataPerCharDB.log[5];
		HappyAutoReplyDataPerCharDB.log[5] = checkMsg;
	else
		local idx = logSize + 1
		HappyAutoReplyDataPerCharDB.log[idx] = checkMsg;
	end

end
