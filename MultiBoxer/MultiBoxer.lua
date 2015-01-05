local media = LibStub("LibSharedMedia-2.0")
local tmpTaxiSlave = false
local tmpMasterTaxiNode = false
local tmpMasterTaxiNodeTimeSlot = 0
local tmpSelectGossipAvailableQuestSlave = false
local tmpAcceptQuestSlave = false
local tmpSelectGossipOptionSlave = false
local tmpSelectGossipActiveQuestSlave = false
local tmpCompleteQuestSlave = false
local tmpGetQuestRewardSlave = false
local tmpSelectActiveQuestSlave = false
local tmpSelectAvailableQuestSlave = false
local tmpDeclineQuestSlave = false
local tmpLogout = false
local tmpCancelLogout = false
local tmpRetrieveCorpse = false
local tmpAcceptTrade = false
local tmpRepopMe = false



BINDING_HEADER_MULTIBOXER_HEADER = "Multiboxer";
BINDING_NAME_FOLLOWLEADER = "Request Group Follow";
BINDING_NAME_LOGOUTGROUP = "Request Group Logout";
BINDING_NAME_LOGOUTSLAVES = "Request Slaves Logout";

smMultiBoxer = Rock:NewAddon("MultiBoxer",  "LibRockDB-1.0","LibRockEvent-1.0", "LibRockTimer-1.0","LibRockConfig-1.0","LibRockComm-1.0")
local smMultiBoxer, self = smMultiBoxer, smMultiBoxer

smMultiBoxer:SetDatabase("smMultiBoxerDB")

local newList ,unpackDictAndDel = Rock:GetRecyclingFunctions("MultiBoxer", "newList", "unpackDictAndDel")

smMultiBoxer.OnCommReceive = {}

function smMultiBoxer:ToggleLock( v )
	self.db.profile.lock = v
	if self.mainframe then
		if v then
			self.mainframe:RegisterForDrag(nil)
		else
			self.mainframe:RegisterForDrag("LeftButton")
		end
	end
end

local optionsTable_args = {
	
	displaysettings = {
		type = 'group',
		name = "Display settings",
		desc = "",
		args = {
			showxptext = {
				type = "toggle", 
				name = "Show experience text next to xp bar",
				desc = "Show experience text next to xp bar",
				get = function() return self.db.profile.showxptext end,
				set =  function(v) self.db.profile.showxptext = v end,
				order = 1,
			},
			showxppercent = {
				type = "toggle", 
				name = "Show experience percent next to xp bar",
				desc = "Show experience percent next to xp bar",
				get = function() return self.db.profile.showxppercent end,
				set =  function(v) self.db.profile.showxppercent = v end,
				order = 2,
			},
			lock = {
				type = "toggle", 
				name = "Lock GUI frame",
				desc = "Toggles the lock of the GUI frame. You could move the window if unlocked with a alt+leftclick and move",
				get = function() return self.db.profile.lock end,
				set = "ToggleLock",
				order = 3,
			},	
			hidegui = {
				type = "toggle", 
				name = "Hide GUI frame",
				desc = "Toggles the visibility of the Gui",
				get=function() return self.db.profile.hidegui end,
				set=function(v) self.db.profile.hidegui = v end,
				order = 4,
			},		
			texture = {
				type = 'text',
				name = "XPBarTexture",
				desc = "BarTexture",
				validate = media:List('statusbar'),
				get=function() return self.db.profile.texture end,
				set=function(v) self.db.profile.texture = v end,
				order=5,		
			},
			backgroundcolor = {
				type = 'execute',
				name = "Background Color",
				buttonText = "Select background color",
				func = "colorPick",
				desc = "Select background color for mb frame",
				usage = "",
				order=6,
			},
		},
	},	
	whispersettings = {
		type = 'group',
		name = "Whisper redirect settings",
		desc = "",
		args = {
				showredirectsinchat = {
					type = "toggle", 
					name = "Show clickable version of the whisper in Chat",
					desc = "Displays a clickable version of the whisper in the chat (you could click the original author)",
					get = function() return self.db.profile.showredirectsinchat end,
					set =  function(v) self.db.profile.showredirectsinchat = v end,
					order = 0,
				},
				redirectwhispers = {
					type = "toggle", 
					name = "Redirect whispers",
					desc = "Redirect whispers to the defined Main.",
					get = function() return self.db.profile.redirectwhispers end,
					set =  function(v) self.db.profile.redirectwhispers = v end,
					order = 1,
				},
				--[[
				mywhispermaster = {
					type = "string", 
					name = "Defined Main used for whisper redirects",
					desc = "Insert the name of your Main or simple add 'party1' this is the GroupLeader",
					usage = "...",
					get = function() return self.db.profile.mywhispermaster end,
					set =  function(v) self.db.profile.mywhispermaster = v end,
					order = 2,
				},	
				--]]
				redirecttobroadcastonly = {
					type = "toggle", 
					name = "Send redirected whisper only as clickable version do not whisper to Main",
					desc = "Don't whisper to Main broadcast only the whisper (Only works if you in party)",
					get = function() return self.db.profile.redirecttobroadcastonly end,
					set =  function(v) self.db.profile.redirecttobroadcastonly = v end,
					order = 3,
				},			
		},
	},
	sharedgossibsettings = {
		type = 'group',
		name = "Shared Gossip settings",
		desc = "",
		args = {
				autofollowquestgossip = {
					type = "toggle", 
					name = "Shared Quest Gossip",
					desc = "Slaves redo the same steps in the questlog as their leader.",
					get = function() return self.db.profile.autofollowquestgossip end,
					set =  function(v) self.db.profile.autofollowquestgossip = v end,
					order = 0,
				},
				autofollowtaxigossip = {
					type = "toggle", 
					name = "Shared Taxi Gossip",
					desc = "Slaves redo the same steps in the taxi gossip as their leader.",
					get = function() return self.db.profile.autofollowtaxigossip end,
					set =  function(v) self.db.profile.autofollowtaxigossip = v end,
					order = 1,
				},						
				--[[
				myquestsharemaster = {
					type = "string", 
					name = "Defined Main used for Gossip share",
					desc = "Insert the name of your Main or simple add 'party1' this is the GroupLeader",
					usage = "...",
					get = function() return self.db.profile.myquestsharemaster end,
					set =  function(v) self.db.profile.myquestsharemaster = v end,
					order = 2,
				},
				--]]
		},
	},
	followsettings = {
		type = 'group',
		name = "Follow settings",
		desc = "",
		args = {	
				autofollow = {
					type = "toggle", 
					name = "Automatic follow Leader after leaving Combat",
					desc = "After you leaves Combat, MultiBoxer trys to follow the defined Leader.",
					get = function() return self.db.profile.autofollow end,
					set =  function(v) self.db.profile.autofollow = v end,
					order = 0,
				},	

				alertfollowproblems = {
					type = "toggle", 
					name = "Show Raidwarning if Slave can't follow you",
					desc = "Show Raidwarning if Slave can't follow you",
					get = function() return self.db.profile.alertfollowproblems end,
					set =  function(v) self.db.profile.alertfollowproblems = v end,
					order = 1,
				},	
				
				followstop = {
					type = "toggle",
					name = "Play sound when slave stops following you",
					desc = "Play sound when slave stops following you",
					get = function() return self.db.profile.soundwarning end,
					set =  function(v) self.db.profile.soundwarning = v end,
					order = 2,
				},	
				--]]
		},
	},
	mixedsettings = {
		type = 'group',
		name = "Mixed settings",
		desc = "",
		args = {					
				autoacceptinvites = {
					type = "toggle", 
					name = "Auto accept invites from Friends",
					desc = "Auto accept invites from people in your friendslist",
					get = function() return self.db.profile.autoacceptinvites end,
					set =  function(v) self.db.profile.autoacceptinvites = v end,
					order = 0,
				},					
				autoresurrect = {
					type = "toggle", 
					name = "Auto accept resurrects",
					desc = "Auto accept resurections",
					get = function() return self.db.profile.autoresurrect end,
					set =  function(v) self.db.profile.autoresurrect = v end,
					order = 1,
				},	
				autodenyduels = {
					type = "toggle", 
					name = "Decline all incoming duels",
					desc = "Decline all incoming duels",
					get = function() return self.db.profile.autodenyduels end,
					set =  function(v) self.db.profile.autodenyduels = v end,
					order = 2,
				},		
				autorepair = {
					type = "toggle", 
					name = "Auto repair",
					desc = "Automatically repair all inventory items when at merchant",
					get = function() return self.db.profile.autorepair end,
					set =  function(v) self.db.profile.autorepair = v end,
					order = 3,
				},						
				autoacceptquests = {
					type = "toggle", 
					name = "Auto accept Questshares",
					desc = "Auto accepts shared quests or escort quests",
					get = function() return self.db.profile.autoacceptquests end,
					set =  function(v) self.db.profile.autoacceptquests = v end,
					order = 4,
				},
				autosetloottoffa = {
					type = "toggle", 
					name = "Auto set LootMethod to FFA",
					desc = "Auto set LootMethod to FFA",
					get = function() return self.db.profile.autosetloottoffa end,
					set =  function(v) self.db.profile.autosetloottoffa = v end,
					order = 5,
				},			
				allowinventoryrequest = {
					type = "toggle", 
					name = "Allow inventory request from Friends",
					desc = "Allow inventory request from Friends while trading.",
					get = function() return self.db.profile.allowinventoryrequest end,
					set =  function(v) self.db.profile.allowinventoryrequest = v end,
					order = 6,
				},
				synclogout = {
					type = "toggle", 
					name = "Logout with the leader",
					desc = "Logout with the leader.",
					get = function() return self.db.profile.release end,
					set =  function(v) self.db.profile.release = v end,
					order = 7,
				},
				syncrelease = {
					type = "toggle", 
					name = "Release spirit with the leader",
					desc = "Release spirit with the leader.",
					get = function() return self.db.profile.logout end,
					set =  function(v) self.db.profile.logout = v end,
					order = 8,
				},
				retrievecorpse = {
					type = "toggle", 
					name = "Retrieve corpse with the leader",
					desc = "Retrieve corpse with the leader.",
					get = function() return self.db.profile.retrieve end,
					set =  function(v) self.db.profile.retrieve = v end,
					order = 9,
				},
				--[[
				accepttrade = {
					type = "toggle", 
					name = "Auto accept trade with the leader",
					desc = "Auto accept trade with the leader.",
					get = function() return self.db.profile.accepttrade end,
					set =  function(v) self.db.profile.accepttrade = v end,
					order = 10,
				},	
				--]]


				
		},
	},
} 

self.options = { 
	name = "MultiBoxer",
	desc = "Tool to do some things to help you multiboxing",
	type = 'group',
	icon = [[Interface\Icons\INV_Gizmo_SuperSapperCharge]],
	args = function()
		local t = newList()
		for k,v in pairs(optionsTable_args) do
			t[k] = v
		end
		return "@dict", unpackDictAndDel(t)
	end 
}

self:SetConfigTable(self.options)
self:SetConfigSlashCommand("/multiboxer", "/mb")
self.options.extraArgs.active = nil

function smMultiBoxer:OnInitialize()
	self:SetDefaultCommPriority("ALERT")
	self:SetCommPrefix("MultiBoxer")
end

function smMultiBoxer:colorPick()
	local R,G,B = self.mainframe:GetBackdropColor();
	ColorPickerFrame.previousValues = {R, G, B}
	ColorPickerFrame: Show();
	ColorPickerFrame.frameStrata = FULLSCREEN_DIALOG;
	ColorPickerFrame.hasOpacity = False;
	ColorPickerFrame.func = gotColor;
	ColorPickerFrame.cancelFunc = cancelColor;
end

function gotColor()
	local R,G,B = ColorPickerFrame:GetColorRGB();
	self.mainframe:SetBackdropColor(R,G,B,.9);
	self.db.profile.backgroundRed = R;
	self.db.profile.backgroundGreen = G;
	self.db.profile.backgroundBlue = B;
end

function cancelColor(prevvals)
	local R,G,B = unpack(prevvals);
	self.mainframe:SetBackdropColor(R,G,B,.9);
	self.db.profile.backgroundRed = R;
	self.db.profile.backgroundGreen = G;
	self.db.profile.backgroundBlue = B;
end

function smMultiBoxer:OnEnable()
	self:AddEventListener("AUTOFOLLOW_BEGIN")
	self:AddEventListener("AUTOFOLLOW_END")

	self:AddEventListener("TRADE_SHOW")
	self:AddEventListener("BAG_UPDATE")
	self:AddEventListener("TRADE_CLOSED")
	self:AddEventListener("CHAT_MSG_WHISPER")
	
	self:AddEventListener("PARTY_INVITE_REQUEST")
	
	self:AddEventListener("CHAT_MSG_COMBAT_XP_GAIN")
	self:AddEventListener("PLAYER_LEVEL_UP","CHAT_MSG_COMBAT_XP_GAIN")
	self:AddEventListener("PLAYER_XP_UPDATE","CHAT_MSG_COMBAT_XP_GAIN")
	self:AddEventListener("PLAYER_ENTERING_WORLD","CHAT_MSG_COMBAT_XP_GAIN")

	self:AddEventListener("PLAYER_REGEN_ENABLED")
	
	self:AddEventListener("TAXIMAP_OPENED");

	self:AddEventListener("UI_ERROR_MESSAGE")
	self:AddEventListener("SYSMSG")
	self:AddEventListener("UI_INFO_MESSAGE")

	self:AddEventListener("RESURRECT_REQUEST")
	
	self:AddEventListener("DUEL_REQUESTED")
	self:AddEventListener("MERCHANT_SHOW")
		
	self:AddEventListener("QUEST_DETAIL")
	self:AddEventListener("QUEST_ACCEPT_CONFIRM")
			
	hooksecurefunc("TakeTaxiNode",TakeTaxiNodeHook)
	--hooksecurefunc("AcceptTrade",AcceptTradeHook)
	hooksecurefunc("Logout",LogoutHook)	
	hooksecurefunc("CancelLogout",CancelLogoutHook)
	hooksecurefunc("RepopMe",RepopMeHook)
	hooksecurefunc("RetrieveCorpse",RetrieveCorpseHook)
	
	
	hooksecurefunc("SelectGossipOption",SelectGossipOptionHook)	
	hooksecurefunc("SelectGossipActiveQuest",SelectGossipActiveQuestHook)
	hooksecurefunc("SelectGossipAvailableQuest",SelectGossipAvailableQuestHook)
	hooksecurefunc("SelectActiveQuest",SelectActiveQuestHook)
	hooksecurefunc("SelectAvailableQuest",SelectAvailableQuestHook)
	hooksecurefunc("AcceptQuest",AcceptQuestHook)	
	hooksecurefunc("CompleteQuest",CompleteQuestHook)
	hooksecurefunc("GetQuestReward",GetQuestRewardHook)	
	hooksecurefunc("DeclineQuest",DeclineQuestHook)	
	
	--hooksecurefunc("GetQuestLogTimeLeft",GetQuestLogTimeLeftHook)	

	self:AddCommListener("MultiBoxer", "GROUP")
	self:AddCommListener("MultiBoxer", "WHISPER")


	if (self.db.profile.accepttrade == nil) then
		self.db.profile.accepttrade = true
	end

	if (self.db.profile.repopme == nil) then
		self.db.profile.repopme = true
	end
	
	if (self.db.profile.logout == nil) then
		self.db.profile.logout = true
	end

	if (self.db.profile.release == nil) then
		self.db.profile.release = true
	end	
	
	if (self.db.profile.retrieve == nil) then
		self.db.profile.retrieve = true
	end	
	
	if (self.db.profile.soundwarning == nil) then
		self.db.profile.soundwarning = true
	end	

	if (self.db.profile.texture == nil) then
		self.db.profile.texture = "Minimalist"
	end		

	self:SetupFrames();

	self:AddRepeatingTimer("MultiBoxerScheduleErrorFade", 0.5, "UpdateSlaveList")
	self:AddRepeatingTimer("MultiBoxerScheduleCheckLootMethod", 12, "CheckLootMethod")
end

--[[
	============================================== Hooked Functions ================================================
]]

--[[
	TakeTaxiNode
]]

function AcceptTradeHook() 
	if tmpAcceptTrade == false then
		--DEFAULT_CHAT_FRAME:AddMessage("Hook Trade")
		self:SendCommMessage("GROUP", "ACCEPTTRADE")
	end
	tmpAcceptTrade = false	
end



function RetrieveCorpseHook() 
	if tmpRetrieveCorpse == false then
		--DEFAULT_CHAT_FRAME:AddMessage("Hook RETRIEVE")
		self:SendCommMessage("GROUP", "RETRIEVE")
	end
	tmpRetrieveCorpse = false	
end

function RepopMeHook() 
	if tmpRepopMe == false then
		--DEFAULT_CHAT_FRAME:AddMessage("Hook RepopMeHook")
		self:SendCommMessage("GROUP", "REPOPME")
	end
	tmpRepopMe = false	
end

function LogoutHook() 
	if tmpLogout == false then
		--DEFAULT_CHAT_FRAME:AddMessage("Hook Logout")
		self:SendCommMessage("GROUP", "LOGOUT", "BUTTON")
	end
	tmpLogout = false	
end

function CancelLogoutHook() 
	if tmpCancelLogout == false and not IsShiftKeyDown() then
		self:SendCommMessage("GROUP", "CANCELLOGOUT")
	end	
	tmpCancelLogout = false
end

function TakeTaxiNodeHook(index) 
	if (tmpTaxiSlave == false) then
		local nodename = TaxiNodeName(index)
		--self:DebugMsg("SentBroadcast "..index.." : "..nodename)
		self:SendCommMessage("GROUP", "TAKETAXI",index,nodename)
	end
	tmpTaxiSlave = false
end

--
--[[
	Quest Share Hooks
]]
function SelectGossipAvailableQuestHook(index)
	--self:DebugMsg("SelectGossipAvailableQuestHook "..index)
	if (tmpSelectGossipAvailableQuestSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","SelectGossipAvailableQuest",index)
	end
	tmpSelectGossipAvailableQuestSlave = false
end

function AcceptQuestHook()
	--self:DebugMsg("AcceptQuestHook ")
	if (tmpAcceptQuestSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","AcceptQuest")
	end
	tmpAcceptQuestSlave = false
end

function SelectGossipOptionHook(index)
	--self:DebugMsg("SelectGossipOptionHook "..index)
	if (tmpSelectGossipOptionSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","SelectGossipOption",index)
	end
	tmpSelectGossipOptionSlave = false
end

function SelectGossipActiveQuestHook(index)
	--self:DebugMsg("SelectGossipActiveQuestHook "..index)
	if (tmpSelectGossipActiveQuestSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","SelectGossipActiveQuest",index)
	end
	tmpSelectGossipActiveQuestSlave = false
end

function CompleteQuestHook()
	--self:DebugMsg("CompleteQuestHook ")
	if (tmpCompleteQuestSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","CompleteQuest")
	end
	tmpCompleteQuestSlave = false
end

function GetQuestRewardHook(index)
	--self:DebugMsg("GetQuestRewardHook "..index)
	if (tmpGetQuestRewardSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","GetQuestReward",index)
	end
	tmpGetQuestRewardSlave = false
end

function SelectActiveQuestHook(index)
	--self:DebugMsg("SelectActiveQuestHook "..index)
	if (tmpSelectActiveQuestSlave == false) then
		local questtitle = GetActiveTitle(index)
		self:SendCommMessage("GROUP", "QUESTSHARE","SelectActiveQuest",index,questtitle)
	end
	tmpSelectActiveQuestSlave = false
end

function DeclineQuestHook()
	--self:DebugMsg("DeclineQuestHook ")
	if (tmpDeclineQuestSlave == false) then
		self:SendCommMessage("GROUP", "QUESTSHARE","DeclineQuest")
	end
	tmpDeclineQuestSlave = false
end

function SelectAvailableQuestHook(index)
	--self:DebugMsg("SelectAvailableQuestHook "..index)
	if (tmpSelectAvailableQuestSlave == false) then
		local questtitle = GetAvailableTitle(index)
		self:SendCommMessage("GROUP", "QUESTSHARE","SelectAvailableQuest",index,questtitle)
	end
	tmpSelectAvailableQuestSlave = false
end

--[[
function GetQuestLogTimeLeftHook() 
self:DebugMsg("GetQuestLogTimeLeftHook ")	
	questDescription, questObjectives = GetQuestLogQuestText();
	QuestLogObjectivesText:SetText("Blubber\n"..questObjectives.."\n\n--");
	local questID = GetQuestLogSelection();
	local questTitle = GetQuestLogTitle(questID);
	
	self:SendCommMessage("GROUP", "REQ	QUESTSTATUS",questtitle)
end
]]

--[[
	============================================== EVENTS ================================================
]]

--[[
	sharedbags
]]

function smMultiBoxer:TRADE_SHOW()
	self:SendCommMessage("WHISPER", UnitName("npc"), "GETBAGS")
end

function smMultiBoxer:TRADE_CLOSED()
	if (self.containerframe) then
		self.containerframe:Hide()
	end
end

function smMultiBoxer:BAG_UPDATE()
	if TradeFrame:IsVisible() then 
		self:SendBags(UnitName("npc"))
	end
end


--[[
	Broadcast  Xp Gain
]]
function smMultiBoxer:CHAT_MSG_COMBAT_XP_GAIN()
	local XP = UnitXP("player")
	local XPMax = UnitXPMax("player")
	self:SendCommMessage("GROUP", "XPGAIN", floor( XP / (XPMax / 100) ),XP,XPMax)
end
	
--[[
	Follow Broadcast (send target user to other players)
]]
function smMultiBoxer:AUTOFOLLOW_BEGIN(ns, event, unit)
	self:SendCommMessage("GROUP", "FOLLOW", unit)
end
function smMultiBoxer:AUTOFOLLOW_END()
	self:SendCommMessage("GROUP", "FOLLOW", nil)
end

--[[
	Automatic Quest accept (from share and escort)
]]
function smMultiBoxer:QUEST_DETAIL()
	if (self.db.profile.autoacceptquests) then
		if (UnitIsPlayer("npc")) then
			self:DebugMsg("Accepting Quest "..GetTitleText().." from "..UnitName("npc"))
			tmpAcceptQuestSlave = true
			AcceptQuest();
		end
	end
end

function smMultiBoxer:QUEST_ACCEPT_CONFIRM()
	if (self.db.profile.autoacceptquests) then
		tmpAcceptQuestSlave = true
		AcceptQuest();
	end
end


--[[
	autorepair
]]

function smMultiBoxer:MERCHANT_SHOW()
	if (self.db.profile.autorepair) then
		if not CanMerchantRepair() then return end

		local cost = GetRepairAllCost()
		if cost > 0 then
			local money = GetMoney()
			if money > cost then
				RepairAllItems()
			else
				--cant do that no mony :D
			end
		end
	end
end


--[[
	autodenyduels
]]

function smMultiBoxer:DUEL_REQUESTED()
	if (self.db.profile.autodenyduels) then
		CancelDuel();
		StaticPopup_Hide("DUEL_REQUESTED")
	end
end


--[[
	Automatic resurrect accept
]]
function smMultiBoxer:RESURRECT_REQUEST()
	if (self.db.profile.autoresurrect) then
		--AcceptResurrect();
		for i=1,STATICPOPUP_NUMDIALOGS do
			local frame = getglobal("StaticPopup"..i)
			if frame:IsShown() then
				--DEFAULT_CHAT_FRAME:AddMessage(frame.which)
				if frame.which == "RESURRECT_NO_TIMER"  then
					getglobal("StaticPopup"..i.."Button1"):Click();
				end
			end
		end
	end
end

--[[
	Broadcast UI errors to other clients
]]
function smMultiBoxer:UI_ERROR_MESSAGE()
	self:SendCommMessage("GROUP", "UIERROR",arg1, 1.0, 0.1, 0.1)
end 
function smMultiBoxer:UI_INFO_MESSAGE()
	self:SendCommMessage("GROUP", "UIERROR",arg1, 1.0, 1.0, 0.0)
end 
function smMultiBoxer:SYSMSG()
	self:SendCommMessage("GROUP", "UIERROR",arg1, arg2, arg3, arg4)
end 

--[[
	Automatic Follow Leader after Combat ends
]]
function smMultiBoxer:PLAYER_REGEN_ENABLED()
	--local leader = LazyMultibox_ReturnLeaderUnit()
	--if UnitIsUnit("player", leader) then
		self:SendCommMessage("GROUP", "FOLLOWREQUEST", "EVENT")
	--end
end

function smMultiBoxer:TAXIMAP_OPENED()
	
	local time = GetTime()
	if not tmpMasterTaxiNode then return end

	if tmpMasterTaxiNodeTimeSlot > time then
		for i=1,NumTaxiNodes() do
			if(TaxiNodeName(i) == tmpMasterTaxiNode) then
				TakeTaxiNode(i)
				break
			end
		end
	end	

	tmpMasterTaxiNodeTimeSlot = 0
	tmpMasterTaxiNode = false
end


--[[
	Automatic accept Invites if sender is in friendslist
]]
function smMultiBoxer:PARTY_INVITE_REQUEST()
	if (self.db.profile.autoacceptinvites) then
		local accept = false
		ShowFriends()
		for i=1, GetNumFriends() do
			local friendName = GetFriendInfo(i)
			if arg1 == friendName then
				accept = true
				break
			end
		end	
		
		if accept then
			if GetNumPartyMembers() == 0 then
				AcceptGroup()
				StaticPopup_Hide("PARTY_INVITE")
			end
		end
	end
end

--[[
	Silent Whisper redirect
]]

function smMultiBoxer:CHAT_MSG_WHISPER()
	if ( self.db.profile.redirectwhispers ) then
		local msg = "";
		local cleanmsg = "";
		--
		if(arg6 == "GM") then
			msg = "Sent by <GM>["..arg2.."]: "..arg1
			cleanmsg = "|cff20ff20<GM>[|Hplayer:"..arg2..":"..arg11.."|h"..arg2.."|h] whispers: "..arg1
		else
			msg = "Sent by ["..arg2.."]: "..arg1
			cleanmsg = "|cff20ff20[|Hplayer:"..arg2..":"..arg11.."|h"..arg2.."|h] whispers: "..arg1
		end
		local leader = LazyMultibox_ReturnLeaderUnit()
		local rname = UnitName(leader);
		if (rname == nil) then
			return
		end
		
		self:SendCommMessage("GROUP", "REDIRECTWHISPER",cleanmsg)
		if (self.db.profile.redirecttobroadcastonly) then
			--
		else
			SendChatMessage(msg , "WHISPER", nil, rname);
		end
	end
end

--[[
	============================================== ADDON CHANNEL COMMUNICATION  ================================================
]]


function smMultiBoxer.OnCommReceive:FOLLOWREQUEST(prefix, distribution, sender, mode)
	if (sender == UnitName("player")) then return end
	if not LazyMultibox_IsLeaderUnit(sender) then return end
	
	if (mode == "KEY" or mode == "EVENT" and self.db.profile.autofollow) then
		local leader = LazyMultibox_ReturnLeaderUnit()
		if CheckInteractDistance(leader, 4) then
			FollowUnit(leader);
		else
			self:SendCommMessage("GROUP", "FOLLOWLOST","(Out of range)")
		end
	end
	
end


function smMultiBoxer.OnCommReceive:ACCEPTTRADE(prefix, distribution, sender)
	
	if (sender == UnitName("player")) then return end
	if not LazyMultibox_IsLeaderUnit(sender) then return end
	
	if (self.db.profile.accepttrade) then
	--DEFAULT_CHAT_FRAME:AddMessage("ReceiveTrade")
		tmpAcceptTrade = true
		--AcceptTrade()
		TradeFrameTradeButton:Click()
	end
end

function smMultiBoxer.OnCommReceive:RETRIEVE(prefix, distribution, sender)
	if (sender == UnitName("player")) then return end
	if not LazyMultibox_IsLeaderUnit(sender) then return end

	if (self.db.profile.retrieve) then
		tmpRetrieveCorpse = true
		--RetrieveCorpse()
		for i=1,STATICPOPUP_NUMDIALOGS do
			local frame = getglobal("StaticPopup"..i)
			if frame:IsShown() then
				--DEFAULT_CHAT_FRAME:AddMessage(frame.which)
				if frame.which == "RECOVER_CORPSE"  then
					getglobal("StaticPopup"..i.."Button1"):Click();
				end
			end
		end
		
	end
end

function smMultiBoxer.OnCommReceive:REPOPME(prefix, distribution, sender)
	if (sender == UnitName("player")) then return end
	if not LazyMultibox_IsLeaderUnit(sender) then return end
	--DEFAULT_CHAT_FRAME:AddMessage("OnCommReceive:REPOPME")
	if (self.db.profile.repopme) then
		tmpRepopMe = true
		--RepopMe()
		for i=1,STATICPOPUP_NUMDIALOGS do
			local frame = getglobal("StaticPopup"..i)
			if frame:IsShown() then
				--DEFAULT_CHAT_FRAME:AddMessage(frame.which)
				if frame.which == "DEATH"  then
					getglobal("StaticPopup"..i.."Button1"):Click();
				end
			end
		end
	end
end

function smMultiBoxer.OnCommReceive:LOGOUT(prefix, distribution, sender, mode)
	if (sender == UnitName("player")) then return end
	if not LazyMultibox_IsLeaderUnit(sender) then return end
	
	if (mode == "KEY" or self.db.profile.logout and mode == "BUTTON") then
		tmpLogout = true
		Logout()
	end
end

function smMultiBoxer.OnCommReceive:CANCELLOGOUT(prefix, distribution, sender)
	if (sender == UnitName("player")) then return end
	if not LazyMultibox_IsLeaderUnit(sender) then return end
	if (self.db.profile.logout) then
		tmpCancelLogout = true
		for i=1,STATICPOPUP_NUMDIALOGS do
			local frame = getglobal("StaticPopup"..i)
			if frame:IsShown() then
				if frame.which == "CAMP"  then
					getglobal("StaticPopup"..i.."Button1"):Click();
				end
			end
		end
	end
end

--[[
	QuestShare
]]
function smMultiBoxer.OnCommReceive:QUESTSHARE(prefix, distribution, sender)
	if (sender == UnitName("player")) then return end
	
	if (self.db.profile.autofollowquestgossip) then
		local leader = LazyMultibox_ReturnLeaderUnit()
		local rname = UnitName(leader);
		if (rname == nil) then
			return
			--rname = self.db.profile.myquestsharemaster;
		end
		
		if (rname ~= sender) then return end
		
		if (clickmethod == "SelectActiveQuest") then
			--self:DebugMsg(">>"..clickmethod..":"..questid.." .... "..questtitle)
			tmpSelectActiveQuestSlave = true
			SelectActiveQuest(questid)
		end
		if (clickmethod == "SelectAvailableQuest") then
			--self:DebugMsg(">>"..clickmethod..":"..questid.." .... "..questtitle)
			tmpSelectAvailableQuestSlave = true
			SelectAvailableQuest(questid)
		end	
		if (clickmethod == "AcceptQuest") then
			--self:DebugMsg(">>"..clickmethod)
			tmpAcceptQuestSlave = true
			AcceptQuest()
		end	
		if (clickmethod == "DeclineQuest") then
			--self:DebugMsg(">>"..clickmethod)
			tmpDeclineQuestSlave = true
			DeclineQuest()
		end	
		if (clickmethod == "CompleteQuest") then
			--self:DebugMsg(">>"..clickmethod)
			tmpCompleteQuestSlave = true
			CompleteQuest()
		end	
		if (clickmethod == "GetQuestReward") then
			--self:DebugMsg(">>"..clickmethod)
			tmpGetQuestRewardSlave = true
			GetQuestReward(questid)
		end
		if (clickmethod == "SelectGossipAvailableQuest") then
			--self:DebugMsg(">>"..clickmethod..":"..questid.." .... "..questtitle)
			tmpSelectGossipAvailableQuestSlave = true
			SelectGossipAvailableQuest(questid)
		end	
		if (clickmethod == "SelectGossipOption") then
			--self:DebugMsg(">>"..clickmethod..":"..questid.." .... "..questtitle)
			tmpSelectGossipOptionSlave = true
			SelectGossipOption(questid)
		end	
		if (clickmethod == "SelectGossipActiveQuest") then
			--self:DebugMsg(">>"..clickmethod..":"..questid.." .... "..questtitle)
			tmpSelectGossipActiveQuestSlave = true
			SelectGossipActiveQuest(questid)
		end	
	end
end
--[[
	TakeTaxiNode
]]
function smMultiBoxer.OnCommReceive:TAKETAXI(prefix, distribution, sender, nodeid,nodename)
	--DEFAULT_CHAT_FRAME:AddMessage("Taxi saved1 "..nodename)
	if (sender == UnitName("player")) then return end
	if (nodename == nil) then return end
	
	--DEFAULT_CHAT_FRAME:AddMessage("Taxi saved2.4 ")
	if (self.db.profile.autofollowtaxigossip) then
		local leader = LazyMultibox_ReturnLeaderUnit()
		if not leader then end
			
		local rname = UnitName(leader);
		if (rname ~= sender) then return end
			
		--DEFAULT_CHAT_FRAME:AddMessage("Taxi saved3 "..nodename)
		tmpTaxiSlave = true
		tmpMasterTaxiNode = nodename
		tmpMasterTaxiNodeTimeSlot = GetTime() + 30

	end
end

--[[
	Display XPGain from slaves
]]
function smMultiBoxer.OnCommReceive:XPGAIN(prefix, distribution, sender, xpperc, xp, xpmax)
	local f = self.mainframe
	if not f then return end
	--DEFAULT_CHAT_FRAME:AddMessage("geting xp from "..sender.." "..xpperc.."%")
	for i=1, 4 do
		local b = f.slaves[i];
		if (b.unitname == sender) then
			b.xpval = xpperc
			b.xp = xp
			b.xpmax = xpmax
		end
	end
end

					
--[[
	Display Redirected Whispers normal
]]
function smMultiBoxer.OnCommReceive:FOLLOWLOST(prefix, distribution, sender,reason)
	if ( self.db.profile.alertfollowproblems ) then
		RaidNotice_AddMessage( RaidWarningFrame, sender.." can't follow you "..reason, ChatTypeInfo["RAID_WARNING"] );
		PlaySound("RaidWarning");
	end
end					
--[[
	Display Redirected Whispers normal
]]
function smMultiBoxer.OnCommReceive:REDIRECTWHISPER(prefix, distribution, sender, msg)
	local f = self.mainframe
	if not f then return end
	
	if ( self.db.profile.showredirectsinchat ) then
		if (sender ~= UnitName("player")) then
			DEFAULT_CHAT_FRAME:AddMessage(sender..": "..msg)
		end
	end
end

--[[
	Display UI error MSG
]]
function smMultiBoxer.OnCommReceive:UIERROR(prefix, distribution, sender, msg,r,g,b)
	local f = self.mainframe
	if not f then return end
	
	if (sender ~= UnitName("player")) then
		--DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20got ui Error from "..sender.." ---> "..msg)
		for i=1, 4 do
			local b = f.slaves[i];
			if (b.unitname == sender) then
				if (r == nil) then
					r = 1.0
					g = 0
					b = 0
				end
				b.text_err:SetText(msg);
				b.text_err:SetTextColor(r,g,b)
				b.text_err:SetAlpha(1);
			end
		end		
	end
end

--[[
	Got a Ping from another user
]]
function smMultiBoxer.OnCommReceive:PING(prefix, distribution, sender, ping)
	self:UpdateSlaveList();
end

--[[
	Update Follow status
]]
function smMultiBoxer.OnCommReceive:FOLLOW(prefix, distribution, sender, unit)
	local f = self.mainframe
	if not f then return end

	--DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20got FOLLOW from "..sender)
	if (unit == nil) then
		--DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20got FOLLOW ends")
		for i=1, 4 do
			local b = f.slaves[i];
			if (b.unitname == sender) then
				b.followunit = nil
			end
		end
	else
		--DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20got FOLLOW starts for "..unit)
		for i=1, 4 do
			local b = f.slaves[i];
			if (b.unitname == sender) then
				b.followunit = unit
				b.followunit_previous = true
			end
		end		
	end
	
	self:UpdateSlaveList();
end

--[[
	Bag Share
]]
function smMultiBoxer.OnCommReceive:GETBAGS(prefix, distribution, sender)
	if TradeFrame:IsVisible() then 
		if (self.db.profile.allowinventoryrequest) then
			self:DebugMsg(sender.." requested my bags")
			local accept = false
			ShowFriends()
			for i=1, GetNumFriends() do
				local friendName = GetFriendInfo(i)
				if sender == friendName then
					accept = true
					break
				end
			end	
			
			if accept then
				self:SendBags(sender)
			end
		end
	end
end

function smMultiBoxer.OnCommReceive:MYBAGSINIT(prefix, distribution, sender,allslots)
	if TradeFrame:IsVisible() then 
		self:SetupContainerFrames(allslots)
		self.containerframe.text_name:SetText(sender)
		SetPortraitTexture(self.containerframe.icon, "npc");
	end
end

function smMultiBoxer.OnCommReceive:MYBAGS(prefix, distribution, sender,itemnum,itemCount,bagID,slotID,link)
	--self:DebugMsg(sender.." send me his bags"..itemnum)
	if TradeFrame:IsVisible() then 
		local b = getglobal("SharedContainerFrameButton"..itemnum);
		if (link) then
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(link);
			if (itemTexture) then
				SetItemButtonTexture(b,itemTexture)
				SetItemButtonCount(b,itemCount)	
			end
			b.bagID = bagID
			b.slotID = slotID
			b.link = link
			b:SetScript("OnClick", function() self:SharedBagsButtonClick(b) end)
			b:SetScript("OnLeave", function() GameTooltip:Hide(); ResetCursor(); end)
			b:SetScript("OnEnter", function() self:SharedBagsButtonEnter() end)
			b:Show();
		else
			b:Hide();
		end
	else
		if (self.containerframe) then
			self.containerframe:Hide()
		end	
	end
end

function smMultiBoxer.OnCommReceive:MYBAGSTRADETOGGLE(prefix, distribution, sender,bagID,slotID)
	ClearCursor()
    for i = 1, 6 do
		if not GetTradePlayerItemLink(i) then	
			PickupContainerItem(bagID,slotID)
			ClickTradeButton(i)
			return
		end
	end
end

--[[
	============================================== Main Functions  ================================================
]]

function smMultiBoxer:SharedBagsButtonClick(button) 
	if TradeFrame:IsVisible() then 
		self:SendCommMessage("WHISPER", UnitName("npc"), "MYBAGSTRADETOGGLE",button.bagID,button.slotID)
	end
end

function smMultiBoxer:SharedBagsButtonEnter() 
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	GameTooltip:ClearLines();
	GameTooltip:SetHyperlink(this.link)
	CursorUpdate();
end

function smMultiBoxer:SendBags(sender)
	if TradeFrame:IsVisible() then 
		local allslots = 0
		for bagID=0,4 do
			local numberOfSlots = GetContainerNumSlots(bagID)
			allslots = allslots + numberOfSlots
		end	
		
		self:SendCommMessage("WHISPER", sender, "MYBAGSINIT",allslots)
		
		local itemnum = 1
		for bagID=0,4 do
			local numberOfSlots = GetContainerNumSlots(bagID)
			for i=1,numberOfSlots do
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bagID, i);
				local link = GetContainerItemLink(bagID, i);
				local mylink;
				if (link) then
					local found = string.find(link, "item:[-]*%d+:[-]*%d+:[-]*%d+:[-]*%d+:[-]*%d+:[-]*%d+:[-]*%d+:[-]*%d+")
					if ( found ) then
						mylink = string.sub(link, found );
					end		
				end
				self:SendCommMessage("WHISPER", sender, "MYBAGS",itemnum,itemCount,bagID,i,mylink)
				itemnum = itemnum + 1
			end
		end	
	end
end	

function smMultiBoxer:DebugMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20MultiBoxer: "..msg)
end

--[[
	check lootmethiod
]]
function smMultiBoxer:CheckLootMethod()
	if (self.db.profile.autosetloottoffa) then
		if (IsPartyLeader()) then
			if GetNumPartyMembers() > 0 then
				lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
				if (lootmethod ~= "freeforall") then
					SetLootMethod("freeforall")
				end
			end
		end
	end
end

--[[
	Update Gui
]]
function smMultiBoxer:UpdateSlaveList()
	local f = self.mainframe;
	if not f then return end

	if (self.db.profile.hidegui) then
		f:Hide()
		return
	end
	
	if (UnitInParty("player") and LazyMultibox_IsLeaderUnit(UnitName("player"))) then
		f:Show()
	else
		f:Hide()
		return
	end	
	
	--DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20got UpdateSlaves ")
	for i=1, 4 do
		local b = f.slaves[i];
		if (UnitExists("party"..i)) then
			--DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20got UpdateSlaves "..UnitName("party"..i))
			if (b.followunit == nil) then
				b.text_info:SetText(UnitName("party"..i))
				if (UnitAffectingCombat("party"..i)) then
					b.text_info:SetTextColor(220,220,220)
				else
					b.text_info:SetTextColor(255,0,0)
					--DEFAULT_CHAT_FRAME:AddMessage(UnitName("party"..i))
				end
				if b.followunit_previous then
					b.followunit_previous = nil
					if( self.db.profile.soundwarning ) then
						self:AddTimer("SoundWarning", 0.25, smMultiBoxer.PlayWarning)
					end	
				end
			else
				b.text_info:SetText(UnitName("party"..i).." -> "..b.followunit)
				b.text_info:SetTextColor(0,255,0)
				self:RemoveTimer("SoundWarning")
			end
			b.unitname = UnitName("party"..i);
			local a = b.text_err:GetAlpha();
			a = a - 0.1;
			if (a < 0) then
				a = 0;
			end
			b.text_err:SetAlpha(a);
			
			local string_xp = "";
			
			if (b.xpval == nil) then
				b.xpBar:SetValue(0)
				b.xpBar.bg:Hide()
				b.text_xp:SetText("")
			else
				b.xpBar:SetValue(b.xpval)
				b.xpBar.bg:Show()
				if(self.db.profile.showxptext) then				
					--b.text_xp:SetText(b.xp.." / "..b.xpmax)	
					string_xp = b.xp.." / "..b.xpmax
				else
					--b.text_xp:SetText("")
					string_xp = ""
				end
				if(self.db.profile.showxppercent) then				
					--b.text_xp:SetText(b.text_xp:GetText().." ("..b.xpval.."%) ")
					string_xp = string_xp.." ("..b.xpval.."%) "
				end
			end
			b.text_xp:SetText(string_xp)
		else
			b.text_info:SetText("")
			b.unitname = "unk"
			b.text_err:SetAlpha(0);
			b.xpBar:SetValue(0)
			b.xpBar.bg:Hide()
		end
	end

end

function smMultiBoxer:OnDisable()
    -- Called when the addon is disabled
end


function smMultiBoxer:OnUpdate()

end

function smMultiBoxer:SendMultiBoxerPing()
	self:SendCommMessage("GROUP", "PING", 1)
end

function smMultiBoxer:SavePosition()
	local f = self.mainframe
	if not f then return end

	local s = f:GetEffectiveScale()
		
	self.db.profile.posx = f:GetLeft() * s
	self.db.profile.posy = f:GetTop() * s	
end

function smMultiBoxer:RestorePosition()
	local x = self.db.profile.posx
	local y = self.db.profile.posy

	if not x or not y then return end

	local f = self.mainframe
	if not f then return end
	local s = f:GetEffectiveScale()

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
end

function smMultiBoxer:SetupFrames()
	-- GUI
	local versionText = "MultiBoxer Master Frame"

	media:Register("statusbar", "Minimalist", "Interface\\Addons\\Proximo\\Textures\\Minimalist")
	
	local f = CreateFrame("Frame", nil, UIParent)
	f:Hide()
	f:SetMovable(true)
	f:SetScript("OnUpdate", function() self:OnUpdate() end)
	f:SetWidth(350)
	f:SetHeight(100)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	f:SetAlpha(1)
	f:SetScale(1)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function() if not InCombatLockdown() and IsAltKeyDown() then this:StartMoving() end end)
	f:SetScript("OnDragStop", function() if not InCombatLockdown() then this:StopMovingOrSizing() self:SavePosition() end end)

	f.text = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	f.text:SetText(versionText)
	f.text:SetPoint("CENTER", f, "TOP",0, -7)
	f.text:SetJustifyH("LEFT")
	f.text:SetJustifyV("TOP")


	f.slaves={}
	for i=1,4 do
		local b=CreateFrame("Button", "Slave"..i, f, "SecureActionButtonTemplate")
		
		b.unitname = "unk"
		b.followunit = nil
		b.followunit_previous = nil
		
		b:SetHeight(20)
		b:SetWidth(150)
		b:ClearAllPoints()
		if i==1 then
			b:SetPoint("TOP",f,"TOP", 0, -20)
		else
			b:SetPoint("TOP",f.slaves[i-1],"BOTTOM", 0,0)
		end
		
		
		b.text_info = f:CreateFontString(nil,"OVERLAY","GameFontNormal")
		b.text_info:SetText("Slave"..i)
		b.text_info:SetPoint("LEFT", b, "TOP", -170, 0)
		b.text_info:SetJustifyH("LEFT")
		b.text_info:SetJustifyV("TOP")

		b.text_xp = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		b.text_xp:SetText("")
		b.text_xp:SetPoint("LEFT", b, "TOP", -20, -10)
		b.text_xp:SetJustifyH("LEFT")
		b.text_xp:SetJustifyV("TOP")

		--b.text_xp_overlay = f:CreateFontString(nil,"HIGHLIGHT","GameFontNormal")
		--b.text_xp_overlay:SetText("")
		--b.text_xp_overlay:SetPoint("TOPLEFT", b, "TOPLEFT", -95, -10)
		--b.text_xp_overlay:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -95, 5)
		--b.text_xp_overlay:SetJustifyH("CENTER")
		--b.text_xp_overlay:SetJustifyV("TOP")

		b.xpBar = CreateFrame("StatusBar", "xpBar", b)
		b.xpBar:ClearAllPoints()
		b.xpBar:SetPoint("TOPLEFT",b,"TOPLEFT", -95, -10)
		b.xpBar:SetPoint("BOTTOMRIGHT",b,"BOTTOMRIGHT",-95,5)
		b.xpBar:SetStatusBarTexture(media:Fetch('statusbar', self.db.profile.texture))
		b.xpBar:SetMinMaxValues(0, 100)
		b.xpBar:SetValue(0)		
	
		b.xpBar.bg = b.xpBar:CreateTexture(nil, "BACKGROUND")
		b.xpBar.bg:ClearAllPoints()
		b.xpBar.bg:SetAllPoints(b.xpBar)
		b.xpBar.bg:SetTexture(media:Fetch('statusbar', self.db.profile.texture))
		b.xpBar.bg:SetVertexColor(0.3, 0.3, 0.3)
		b.xpBar.bg:SetAlpha(0.3)
		b.xpBar.bg:Hide();

		
		b.text_err = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		b.text_err:SetText("")
		b.text_err:SetPoint("LEFT", b, "TOP", -20, 0)
		b.text_err:SetJustifyH("LEFT")
		b.text_err:SetJustifyV("TOP")		
		
		b.icon = b:CreateTexture(nil, "ARTWORK")
		b.icon:ClearAllPoints()
		b.icon:SetHeight(20)
		b.icon:SetWidth(20)
		b.icon:SetPoint("TOPLEFT",b,"TOPLEFT",-1,0)
		table.insert(f.slaves,b)
	end
	f:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
	if (self.db.profile.backgroundRed == nil or self.db.profile.backgroundBlue == nil or self.db.profile.backgroundGreen == nil) then
		f:SetBackdropColor(1,1,1,.9)
	else
		f:SetBackdropColor(self.db.profile.backgroundRed,self.db.profile.backgroundGreen,self.db.profile.backgroundBlue,.9);
	end
	self.mainframe = f	
	
	if self.db.profile.lock then
		self.mainframe:RegisterForDrag(nil)
	end		
	
	self.mainframe:SetScale(1)
	self.mainframe:SetAlpha(0.75)
	
	self:RestorePosition()
	
 --  DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20UpdateAll: setup done");
end

function smMultiBoxer:SetupContainerFrames(allslots)
	
	-- Shared Bags and Co:
	local fcontainer = self.containerframe
	local txhead
	
	if (self.containerframe == nil) then
		fcontainer = CreateFrame("Frame","SharedContainerFrame", UIParent)
		fcontainer:SetWidth(256)
		fcontainer:SetHeight(512)	
		fcontainer:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		fcontainer:EnableMouse(true)
		fcontainer:SetMovable(true)
		fcontainer:RegisterForDrag("LeftButton")
		fcontainer:SetScript("OnDragStart", function() if not InCombatLockdown() and IsAltKeyDown() then this:StartMoving() end end)
		fcontainer:SetScript("OnDragStop", function() if not InCombatLockdown() then this:StopMovingOrSizing() end end)

		fcontainer.text_name = fcontainer:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		fcontainer.text_name:SetText("TEST")
		fcontainer.text_name:SetPoint("LEFT", fcontainer, "TOP", -18, -15)
		fcontainer.text_name:SetJustifyH("LEFT")
		fcontainer.text_name:SetJustifyV("TOP")

		local txicon = fcontainer:CreateTexture(nil,"BACKGROUND")
		SetPortraitTexture(txicon, "player");
		txicon:ClearAllPoints()
		txicon:SetPoint("TOPLEFT", fcontainer,"TOPRIGHT",-185,-2)
		txicon:SetWidth(40)
		txicon:SetHeight(40)
		fcontainer.icon = txicon
		
		txhead = fcontainer:CreateTexture(nil,"ARTWORK")
		txhead:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components")
		txhead:ClearAllPoints()
		txhead:SetPoint("TOPRIGHT", fcontainer,nil,0,0)
		txhead:SetWidth(256)
		txhead:SetHeight(88)		
		txhead:SetTexCoord(0, 1, 0.00390625, 0.18496875)
		
		fcontainer.head = txhead
	end
	
	txhead = fcontainer.head
	
	--self:DebugMsg("we need "..allslots.." slots in bags")
	local middlerowsneeded = ceil((allslots-4) / 4)
	local middlerowsneededrows = ceil(middlerowsneeded / 6)
	--self:DebugMsg("we need "..middlerowsneeded.." in middle rows")
	--self:DebugMsg("we need "..middlerowsneededrows.." middle rows")
	
	local firstRowTexCoordOffset = 0.353515625
	local rowHeight = 41
	local lasttxmiddle = txhead
	
	for i=1,20 do
		local tmp = getglobal("SharedContainerFrameMiddle"..i)
		if (tmp) then
			tmp:Hide()
		end
	end
	
	for i=1,middlerowsneededrows do
		local rowsCur = 0
		local height = 0
		if (middlerowsneeded > 6) then
			rowsCur = 6
			height = ( rowsCur*rowHeight ) + firstRowTexCoordOffset	
		else
			rowsCur = middlerowsneeded
			height = ( rowsCur*rowHeight ) - 9	
		end
		middlerowsneeded = middlerowsneeded - rowsCur
		local txmiddle = getglobal("SharedContainerFrameMiddle"..i)
		if (txmiddle == nil) then
			txmiddle = fcontainer:CreateTexture("SharedContainerFrameMiddle"..i,"ARTWORK")
		end
		txmiddle:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components")
		txmiddle:ClearAllPoints()
		txmiddle:SetPoint("TOP", lasttxmiddle,"BOTTOM",0,0)
		txmiddle:SetHeight(height)
		txmiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/512 + firstRowTexCoordOffset) )
		txmiddle:SetWidth(256)
		txmiddle:Show()
		lasttxmiddle = txmiddle		
	end

	
	
	local txbottom = getglobal("SharedContainerFrameBottom")
	if (txbottom == nil) then	
		txbottom = fcontainer:CreateTexture("SharedContainerFrameBottom","ARTWORK")
	end
	txbottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components")
	txbottom:ClearAllPoints()
	txbottom:SetPoint("TOP", lasttxmiddle,"BOTTOM",0,0)
	txbottom:SetTexCoord(0, 1, 0.330078125, 0.349609375)	
	txbottom:SetWidth(256)
	txbottom:SetHeight(10)	
	
	for itemnum=1,200 do
		local b = getglobal("SharedContainerFrameButton"..itemnum)
		if (b) then
			b:Hide()
		end
	end
	
	local itemnum = 1
	for row=1,ceil((allslots) / 4) do
		for item=1,4 do
			local b = getglobal("SharedContainerFrameButton"..itemnum)
			if (b == nil) then
				b = CreateFrame("Button", "SharedContainerFrameButton"..itemnum, fcontainer, "ItemButtonTemplate")
			end
			b:SetPoint("TOPLEFT", fcontainer, "TOPLEFT", 43+(41*item), (-41*row) - 5)
			itemnum = itemnum + 1
			b:Hide()
			--local texture = GetContainerItemInfo(0, 0);
			--SetItemButtonTexture(b,texture)
			--SetItemButtonCount(b,row)
		end	
	end
	
	if (self.containerframe == nil) then
		self.containerframe = fcontainer
	end

	self.containerframe:Show();	
end


function smMultiBoxer:FollowRequest()
	self:SendCommMessage("GROUP", "FOLLOWREQUEST", "KEY")
end

function smMultiBoxer:GroupLogoutRequestBind()
	self:SendCommMessage("GROUP", "LOGOUT", "KEY")
	self:AddTimer(0.25, smMultiBoxer.LogoutRequestExecute)
end

function smMultiBoxer:SlavesLogoutRequestBind()
	self:SendCommMessage("GROUP", "LOGOUT", "KEY")
end


function smMultiBoxer:LogoutRequestExecute()
	Logout()
end

function smMultiBoxer:PlayWarning()
	PlaySound("RaidWarning");
end


