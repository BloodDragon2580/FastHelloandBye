FHABAddon = LibStub("AceAddon-3.0"):NewAddon("FastHelloandBye", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("FastHelloandBye")
local fhabLDB = LibStub("LibDataBroker-1.1"):NewDataObject("FastHelloandBye", {
  type = "data source",
  text = L["FHAB_MMBTooltipTitle"],
  icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
  OnTooltipShow = function(tooltip)
       tooltip:SetText(L["FHAB_MMBTooltipTitle"])
       tooltip:AddLine(L["FHAB_MMBTooltipInfo"], 1, 1, 1)
       tooltip:Show()
  end,
  OnClick = function(self, button)
    if button == "LeftButton" then
      FHABAddon:ToggleMainFrame()
    elseif button == "RightButton" then
      FHABAddon:ShowOptionsFrame()
    end
  end})
local FHABMiniMapButton = LibStub("LibDBIcon-1.0")
--
local _Colors = FHABAddon_GetColors()
local _defaultConfig = FHABAddon_GetDefaultConfig()
local _OffsetX = 16
local _OffsetX_Default = 16
local _OffsetX_Step = 48
local _OffsetY = -32
local _OffsetY_Step = -24

local function addButton(container, identifier, chatType, chatChannel, font, buttonCount)
  local button = CreateFrame("Button", "FHAB_"..identifier.."_Button", container, "FHAB_UIPanelButtonTemplate");
  button:SetPoint("TOPLEFT", container, "TOPLEFT", _OffsetX, _OffsetY)
  button:SetText(L["FHAB_"..identifier.."_Button"])
  button:SetScript("OnClick", function(self)
      FHABAddon_SendMessage(identifier, chatType, chatChannel)
  end)
  button:SetNormalFontObject(font);
  button:SetHighlightFontObject(font);

  if buttonCount % FHABAddon.db.profile.config.buttonsPerRow == 0 then
    _OffsetY = _OffsetY + _OffsetY_Step
    _OffsetX = _OffsetX_Default
  else
    _OffsetX = _OffsetX + _OffsetX_Step
  end
end

function FHABAddon_SendMessage(identifier, chatType, channel)
  local messages

  if identifier == "GuildGreeting" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.guild.greeting)}
  elseif identifier == "GuildFarewell" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.guild.farewell)}
  elseif identifier == "GuildCongratulations" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.guild.congratulations)}
  elseif identifier == "GuildThanks" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.guild.thanks)}
  elseif identifier == "PartyGreeting" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.party.greeting)}
  elseif identifier == "PartyFarewell" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.party.farewell)}
  elseif identifier == "InstanceGreeting" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.instance.greeting)}
  elseif identifier == "InstanceFarewell" then
    messages = {strsplit(",", FHABAddon.db.profile.messages.instance.farewell)}
  end

  SendChatMessage(strtrim(messages[math.random(#messages)]), chatType, nil, channel)
end

function FHABAddon_SetupPopupDialogs()
  StaticPopupDialogs["FHAB_PerformReload"] = {
    text = L["FHAB_PerformReload"],
    button1 = L["FHAB_Yes"],
    button2 = L["FHAB_No"],
    OnAccept = function()
      ReloadUI()
    end,
    OnCancel = function()
      FHABAddon:Print(L["FHAB_NotReloaded"])
    end,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3
  }
end

function FHABAddon_SetupMainFrame()
  FastHelloandBye = _G["FastHelloandBye"] or CreateFrame("Frame", "FastHelloandBye", UIParent, "BackdropTemplate")
  FastHelloandBye:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  });
  FastHelloandBye:SetWidth(224)
  FastHelloandBye:SetHeight(96)
  FastHelloandBye:SetToplevel(true)
  FastHelloandBye:SetPoint("CENTER", "UIParent", "CENTER")
  FastHelloandBye:SetClampedToScreen(true)
  FastHelloandBye:EnableMouse(true)
  FastHelloandBye:SetMovable(true)
  FastHelloandBye:RegisterForDrag("LeftButton")
  FastHelloandBye:SetScript("OnEvent", FastHelloandBye_OnEvent)
  FastHelloandBye:SetScript("OnDragStart", FastHelloandBye.StartMoving)
  FastHelloandBye:SetScript("OnDragStop", FastHelloandBye.StopMovingOrSizing)
  FastHelloandBye:RegisterEvent("PLAYER_LOGIN")
  FastHelloandBye.title = FastHelloandBye:CreateFontString("FastHelloandBye_Title", "OVERLAY", "FastHelloandBye_DisplayListFont")
  FastHelloandBye.title:SetPoint("TOP", 0, -16)
  FastHelloandBye.title:SetText("Make people greet again!")
  FastHelloandBye.close = CreateFrame("Button","FastHelloandBye_Close", FastHelloandBye, "UIPanelCloseButton")
  FastHelloandBye.close:SetPoint("TOPRIGHT", -3, -3)
  FastHelloandBye:Show()
end

function FHABAddon_SetupButtons()
  local buttonCount = 0

  FHABAddon_ApplyLayout(FHABAddon.db.profile.config.layout)

  local buttonsFrame = CreateFrame("Frame", "FHAB_ButtonsFrame", FastHelloandBye)
  buttonsFrame:SetAllPoints()

  local infoGuild = ChatTypeInfo["GUILD"]
  local fontGuild = CreateFont("fontGuild")
  fontGuild:SetTextColor(infoGuild.r, infoGuild.g, infoGuild.b, 1)

  if FHABAddon.db.profile.config.guild.greeting then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildGreeting", "GUILD", "g", fontGuild, buttonCount)
  end
  if FHABAddon.db.profile.config.guild.farewell then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildFarewell", "GUILD", "g", fontGuild, buttonCount)
  end
  if FHABAddon.db.profile.config.guild.congratulations then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildCongratulations", "GUILD", "g", fontGuild, buttonCount)
  end
  if FHABAddon.db.profile.config.guild.thanks then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildThanks", "GUILD", "g", fontGuild, buttonCount)
  end

  local infoParty = ChatTypeInfo["PARTY"]
  local fontParty = CreateFont("fontParty")
  fontParty:SetTextColor(infoParty.r, infoParty.g, infoParty.b, 1)

  if FHABAddon.db.profile.config.party.greeting then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "PartyGreeting", "PARTY", "p", fontParty, buttonCount)
  end
  if FHABAddon.db.profile.config.party.farewell then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "PartyFarewell", "PARTY", "p", fontParty, buttonCount)
  end

  local infoInstance = ChatTypeInfo["INSTANCE_CHAT"]
  local fontInstance = CreateFont("fontInstance")
  fontInstance:SetTextColor(infoInstance.r, infoInstance.g, infoInstance.b, 1)

  if FHABAddon.db.profile.config.instance.greeting then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "InstanceGreeting", "INSTANCE_CHAT", "i", fontInstance, buttonCount)
  end
  if FHABAddon.db.profile.config.instance.farewell then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "InstanceFarewell", "INSTANCE_CHAT", "i", fontInstance, buttonCount)
  end

  FastHelloandBye:Show()
end

function FastHelloandBye_Button_OnEnter(self, motion)
  if self then
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(L[self:GetName().."_Tooltip"])
    GameTooltip:Show()
  end
end

function FastHelloandBye_Button_OnLeave(self, motion)
  GameTooltip:Hide()
end

function FastHelloandBye_ShowTooltip(self, title, description)
  if self then
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(title)
    GameTooltip:AddLine(description, 1, 1, 1, true)
    GameTooltip:Show()
  end
end

function FastHelloandBye_HideTooltip(self)
  GameTooltip:Hide()
end

function FHABAddon:ToggleMainFrame()
  if FastHelloandBye:IsVisible() then
    HideUIPanel(FastHelloandBye)
  else
    ShowUIPanel(FastHelloandBye)
  end
end

function FHABAddon:ShowOptionsFrame()
  InterfaceOptionsFrame_OpenToCategory(L["FHAB_Title"])
  InterfaceOptionsFrame_OpenToCategory(L["FHAB_Title"])
end

function FHABAddon:ToggleMinimapButton()
  self.db.profile.minimapButton.hide = not self.db.profile.minimapButton.hide
  if self.db.profile.minimapButton.hide then
    FHABMiniMapButton:Hide("FastHelloandBye")
  else
    FHABMiniMapButton:Show("FastHelloandBye")
  end
end

function FHABAddon:PrintColored(msg, color)
  FHABAddon:Print("|cff" .. color .. msg .. "|r")
end

function FHABAddon:OnOptionHide()
   if (self.needReload) then
     self.needReload = false
     StaticPopup_Show("FHAB_PerformReload")
   end
end

function FHABAddon:DoReload()
  self.needReload = false
  StaticPopup_Show("FHAB_PerformReload")
end

SLASH_RELOADUI1 = "/rl";
SlashCmdList.RELOADUI = ReloadUI;

function FHABAddon:ChatCommands(msg)
	local msg, msgParam = strsplit(" ", msg, 2)

  FHABAddon:ShowOptionsFrame()
end

function FHABAddon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("FastHelloandByeDB", _defaultConfig, true) -- by default all chars use default profile
  self.needReload = false

  self.db.RegisterCallback(self, "OnProfileChanged", "DoReload");
  self.db.RegisterCallback(self, "OnProfileCopied", "DoReload");
  self.db.RegisterCallback(self, "OnProfileReset", "DoReload");

  FHABAddon_SetupOptionsUI();
  FHABAddon:SecureHookScript(self.optionsFrame, "OnHide", "OnOptionHide")

  profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("FHABProfiles", profileOptions)
  profileSubMenu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FHABProfiles", "Profiles", L["FHAB_Title"])

  FHABMiniMapButton:Register("FastHelloandBye", fhabLDB, self.db.profile.minimapButton)

  FHABAddon:RegisterChatCommand("fhab", "ChatCommands")
  FHABAddon:RegisterChatCommand("fasthelloandbye", "ChatCommands")

  FHABAddon_SetupPopupDialogs()

  FHABAddon_SetupMainFrame()
end

function FastHelloandBye_OnEvent(self, event, ...)
  if event == "PLAYER_LOGIN" then
    FHABAddon_SetupButtons()
  end
end
