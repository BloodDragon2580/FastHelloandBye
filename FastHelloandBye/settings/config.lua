local L = LibStub("AceLocale-3.0"):GetLocale("FastHelloandBye")

local _DefaultLayout = "Default"
local _SingleRowLayout = "SingleRow"
local _SingleColumnLayout = "SingleColumn"
local _TwoColumnsLayout = "TwoColumns"

local function createSlider(parent, name, label, description, minVal, maxVal, valStep, onValueChanged, onShow)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	local editbox = CreateFrame("EditBox", name.."EditBox", slider, "InputBoxTemplate")

	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValue(minVal)
	slider:SetValueStep(1)
	slider.text = _G[name.."Text"]
	slider.text:SetText(label)
	slider.textLow = _G[name.."Low"]
	slider.textHigh = _G[name.."High"]
	slider.textLow:SetText(floor(minVal))
	slider.textHigh:SetText(floor(maxVal))
	slider.textLow:SetTextColor(0.4,0.4,0.4)
	slider.textHigh:SetTextColor(0.4,0.4,0.4)
  slider.tooltipText = label
  slider.tooltipRequirement = description

	editbox:SetSize(50,30)
	editbox:SetNumeric(true)
	editbox:SetMultiLine(false)
	editbox:SetMaxLetters(5)
	editbox:ClearAllPoints()
	editbox:SetPoint("TOP", slider, "BOTTOM", 0, -5)
	editbox:SetNumber(slider:GetValue())
	editbox:SetCursorPosition(0);
	editbox:ClearFocus();
	editbox:SetAutoFocus(false)
  editbox.tooltipText = label
  editbox.tooltipRequirement = description

	slider:SetScript("OnValueChanged", function(self,value)
		self.editbox:SetNumber(floor(value))
		if(not self.editbox:HasFocus()) then
			self.editbox:SetCursorPosition(0);
			self.editbox:ClearFocus();
		end
    onValueChanged(self, value)
	end)

  slider:SetScript("OnShow", function(self,value)
    onShow(self, value)
  end)

	editbox:SetScript("OnTextChanged", function(self)
		local value = self:GetText()

		if tonumber(value) then
			if(floor(value) > maxVal) then
				self:SetNumber(maxVal)
			end

			if floor(self:GetParent():GetValue()) ~= floor(value) then
				self:GetParent():SetValue(floor(value))
			end
		end
	end)

	editbox:SetScript("OnEnterPressed", function(self)
		local value = self:GetText()
		if tonumber(value) then
			self:GetParent():SetValue(floor(value))
				self:ClearFocus()
		end
	end)

	slider.editbox = editbox
	return slider
end

local function createCheckbox(parent, name, label, description, hideLabel, onClick)
  local check = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
  check.label = _G[check:GetName() .. "Text"]
  if not hideLabel then
		check.label:SetText(label)
		check:SetFrameLevel(8)
	end
  check.tooltipText = label
  check.tooltipRequirement = description

  -- events
  check:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    onClick(self, tick and true or false)
  end)

  return check
end

local function createEditbox(parent, name, tooltipTitle, tooltipDescription, width, height, multiline, onTextChanged)
	local editbox	 = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	editbox:SetSize(width, height)
	editbox:SetMultiLine(multiline)
	editbox:SetFrameLevel(9)
	editbox:ClearFocus()
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnTextChanged", function(self)
		onTextChanged(self)
	end)
	editbox:SetScript("OnEnter", function(self, motion)
		FastHelloandBye_ShowTooltip(self, tooltipTitle, tooltipDescription)
	end)
	editbox:SetScript("OnLeave", function(self, motion)
		FastHelloandBye_HideTooltip(self)
	end)

  return editbox
end

local function createLabel(parent, name, text)
	local label = parent:CreateFontString(name, "ARTWORK", "GameFontNormal")
	label:SetText(text)
  return label
end

function FHABAddon_SetupOptionsUI()
  FHABAddon.optionsFrame = CreateFrame("Frame", "FHAB_Options", InterfaceOptionsFramePanelContainer)
  FHABAddon.optionsFrame.name = L["FHAB_Title"]
	FHABAddon.optionsFrame:SetAllPoints()
	HideUIPanel(FHABAddon.optionsFrame)

  local title = FHABAddon.optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 10, -10)
	title:SetText(L["FHAB_Title"])

	-- layout
	do
		local layoutLabel = createLabel(FHABAddon.optionsFrame, "layoutLabel", L["FHAB_SetLayout"])
		layoutLabel:SetPoint("TOPLEFT", title, 0, -30)

		FHABAddon.layoutDropdown = CreateFrame("Frame", "FHABLayoutDropdown", FHABAddon.optionsFrame, "UIDropDownMenuTemplate")
		FHABAddon.layoutDropdown:SetPoint("TOPLEFT", layoutLabel, -16, -14)
		UIDropDownMenu_SetWidth(FHABAddon.layoutDropdown, 150)
		UIDropDownMenu_Initialize(FHABAddon.layoutDropdown, function(frame, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			info.func = FHABAddon_SetLayout
			info.text, info.arg1 = L["FHAB_Layout_Default"], _DefaultLayout
			UIDropDownMenu_AddButton(info)
			info.text, info.arg1 = L["FHAB_Layout_SingleRow"], _SingleRowLayout
			UIDropDownMenu_AddButton(info)
			info.text, info.arg1 = L["FHAB_Layout_SingleColumn"], _SingleColumnLayout
			UIDropDownMenu_AddButton(info)
			info.text, info.arg1 = L["FHAB_Layout_TwoColumns"], _TwoColumnsLayout
			UIDropDownMenu_AddButton(info)
		end)
		UIDropDownMenu_SetText(FHABAddon.layoutDropdown, L["FHAB_Layout_"..FHABAddon.db.profile.config.layout])
	end

	do
		local minimapButtonCheckbox = createCheckbox(
	    FHABAddon.optionsFrame,
	    "FHAB_MinimapButton_Checkbox",
	    L["FHAB_MinimapButton"],
	    L["FHAB_MinimapButton_Desc"],
			false,
	    function(self, value)
	      FHABAddon:ToggleMinimapButton()
	    end
		)
		minimapButtonCheckbox:SetChecked(not FHABAddon.db.profile.minimapButton.hide)
	  minimapButtonCheckbox:SetPoint("TOPLEFT", layoutLabel, 300, 0)
	end

	do
		local guildGreetingLabel = createLabel(FHABAddon.optionsFrame, "guildGreetingLabel", L["FHAB_GuildGreeting"])
		guildGreetingLabel:SetPoint("TOPLEFT", layoutLabel, 0, -70)

	  local guildGreetingCheckbox = createCheckbox(
	    FHABAddon.optionsFrame,
	    "FHAB_GuildGreeting_Checkbox",
	    L["FHAB_GuildGreeting"],
	    L["FHAB_EnableButton_Desc"],
			true,
	    function(self, value)
	      FHABAddon.db.profile.config.guild.greeting = value
	      FHABAddon.needReload = true
	    end
		)
	  guildGreetingCheckbox:SetChecked(FHABAddon.db.profile.config.guild.greeting)
	  guildGreetingCheckbox:SetPoint("TOPLEFT", guildGreetingLabel, 0, -14)

		local guildGreetingEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_GuildGreeting_EditBox",
			L["FHAB_GuildGreeting"],
			L["FHAB_GuildGreeting_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.guild.greeting = self:GetText()
			end
		)
		guildGreetingEditBox:SetText(FHABAddon.db.profile.messages.guild.greeting)
		guildGreetingEditBox:SetPoint("TOPLEFT", guildGreetingCheckbox, 30, 3)
	end

	do
		local guildFarewellLabel = createLabel(FHABAddon.optionsFrame, "guildFarewellLabel", L["FHAB_GuildFarewell"])
		guildFarewellLabel:SetPoint("TOPLEFT", guildGreetingLabel, 300, 0)

		local guildFarewellCheckbox = createCheckbox(
			FHABAddon.optionsFrame,
			"FHAB_GuildFarewell_Checkbox",
			L["FHAB_GuildFarewell"],
			L["FHAB_EnableButton_Desc"],
			true,
			function(self, value)
				FHABAddon.db.profile.config.guild.farewell = value
				FHABAddon.needReload = true
			end
		)
		guildFarewellCheckbox:SetChecked(FHABAddon.db.profile.config.guild.farewell)
		guildFarewellCheckbox:SetPoint("TOPLEFT", guildFarewellLabel, 0, -14)

		local guildFarewellEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_GuildFarewell_EditBox",
			L["FHAB_GuildFarewell"],
			L["FHAB_GuildFarewell_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.guild.farewell = self:GetText()
			end
		)
		guildFarewellEditBox:SetText(FHABAddon.db.profile.messages.guild.farewell)
		guildFarewellEditBox:SetPoint("TOPLEFT", guildFarewellCheckbox, 30, 3)
	end

	do
		local guildCongratulationsLabel = createLabel(FHABAddon.optionsFrame, "guildCongratulationsLabel", L["FHAB_GuildCongratulations"])
		guildCongratulationsLabel:SetPoint("TOPLEFT", guildGreetingLabel, 0, -50)

	  local guildCongratulationsCheckbox = createCheckbox(
	    FHABAddon.optionsFrame,
	    "FHAB_GuildCongratulations_Checkbox",
	    L["FHAB_GuildCongratulations"],
	    L["FHAB_EnableButton_Desc"],
			true,
	    function(self, value)
	      FHABAddon.db.profile.config.guild.congratulations = value
	      FHABAddon.needReload = true
	    end
		)
	  guildCongratulationsCheckbox:SetChecked(FHABAddon.db.profile.config.guild.congratulations)
	  guildCongratulationsCheckbox:SetPoint("TOPLEFT", guildCongratulationsLabel, 0, -14)

		local guildCongratulationsEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_GuildCongratulations_Editbox",
			L["FHAB_GuildCongratulations"],
			L["FHAB_GuildCongratulations_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.guild.congratulations = self:GetText()
			end
		)
		guildCongratulationsEditBox:SetText(FHABAddon.db.profile.messages.guild.congratulations)
		guildCongratulationsEditBox:SetPoint("TOPLEFT", guildCongratulationsCheckbox, 30, 3)
	end

	do
		local guildThanksLabel = createLabel(FHABAddon.optionsFrame, "guildThanksLabel", L["FHAB_GuildThanks"])
		guildThanksLabel:SetPoint("TOPLEFT", guildCongratulationsLabel, 300, 0)

		local guildThanksCheckbox = createCheckbox(
			FHABAddon.optionsFrame,
			"FHAB_GuildThanks_Checkbox",
			L["FHAB_GuildThanks"],
			L["FHAB_EnableButton_Desc"],
			true,
			function(self, value)
				FHABAddon.db.profile.config.guild.thanks = value
				FHABAddon.needReload = true
			end
		)
		guildThanksCheckbox:SetChecked(FHABAddon.db.profile.config.guild.thanks)
		guildThanksCheckbox:SetPoint("TOPLEFT", guildThanksLabel, 0, -14)

		local guildThanksEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_GuildThanks_Editbox",
			L["FHAB_GuildThanks"],
			L["FHAB_GuildThanks_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.guild.thanks = self:GetText()
			end
		)
		guildThanksEditBox:SetText(FHABAddon.db.profile.messages.guild.thanks)
		guildThanksEditBox:SetPoint("TOPLEFT", guildThanksCheckbox, 30, 3)
	end


	do
		local partyGreetingLabel = createLabel(FHABAddon.optionsFrame, "partyGreetingLabel", L["FHAB_PartyGreeting"])
		partyGreetingLabel:SetPoint("TOPLEFT", guildCongratulationsLabel, 0, -70)

	  local partyGreetingCheckbox = createCheckbox(
	    FHABAddon.optionsFrame,
	    "FHAB_PartyGreeting_Checkbox",
	    L["FHAB_PartyGreeting"],
	    L["FHAB_EnableButton_Desc"],
			true,
	    function(self, value)
	      FHABAddon.db.profile.config.party.greeting = value
	      FHABAddon.needReload = true
	    end
		)
	  partyGreetingCheckbox:SetChecked(FHABAddon.db.profile.config.party.greeting)
	  partyGreetingCheckbox:SetPoint("TOPLEFT", partyGreetingLabel, 0, -14)

		local partyGreetingEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_PartyGreeting_EditBox",
			L["FHAB_PartyGreeting"],
			L["FHAB_PartyGreeting_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.party.greeting = self:GetText()
			end
		)
		partyGreetingEditBox:SetText(FHABAddon.db.profile.messages.party.greeting)
		partyGreetingEditBox:SetPoint("TOPLEFT", partyGreetingCheckbox, 30, 3)
	end

	do
		local partyFarewellLabel = createLabel(FHABAddon.optionsFrame, "partyFarewellLabel", L["FHAB_PartyFarewell"])
		partyFarewellLabel:SetPoint("TOPLEFT", partyGreetingLabel, 300, 0)

		local partyFarewellCheckbox = createCheckbox(
			FHABAddon.optionsFrame,
			"FHAB_PartyFarewell_Checkbox",
			L["FHAB_PartyFarewell"],
			L["FHAB_EnableButton_Desc"],
			true,
			function(self, value)
				FHABAddon.db.profile.config.party.farewell = value
				FHABAddon.needReload = true
			end
		)
		partyFarewellCheckbox:SetChecked(FHABAddon.db.profile.config.party.farewell)
		partyFarewellCheckbox:SetPoint("TOPLEFT", partyFarewellLabel, 0, -14)

		local partyFarewellEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_PartyFarewell_EditBox",
			L["FHAB_PartyFarewell"],
			L["FHAB_PartyFarewell_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.party.farewell = self:GetText()
			end
		)
		partyFarewellEditBox:SetText(FHABAddon.db.profile.messages.party.farewell)
		partyFarewellEditBox:SetPoint("TOPLEFT", partyFarewellCheckbox, 30, 3)
	end

	do
		local instanceGreetingLabel = createLabel(FHABAddon.optionsFrame, "instanceGreetingLabel", L["FHAB_InstanceGreeting"])
		instanceGreetingLabel:SetPoint("TOPLEFT", partyGreetingLabel, 0, -70)

	  local instanceGreetingCheckbox = createCheckbox(
	    FHABAddon.optionsFrame,
	    "FHAB_InstanceGreeting_Checkbox",
	    L["FHAB_InstanceGreeting"],
	    L["FHAB_EnableButton_Desc"],
			true,
	    function(self, value)
	      FHABAddon.db.profile.config.instance.greeting = value
	      FHABAddon.needReload = true
	    end
		)
	  instanceGreetingCheckbox:SetChecked(FHABAddon.db.profile.config.instance.greeting)
	  instanceGreetingCheckbox:SetPoint("TOPLEFT", instanceGreetingLabel, 0, -14)

		local instanceGreetingEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_InstanceGreeting_EditBox",
			L["FHAB_InstanceGreeting"],
			L["FHAB_InstanceGreeting_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.instance.greeting = self:GetText()
			end
		)
		instanceGreetingEditBox:SetText(FHABAddon.db.profile.messages.instance.greeting)
		instanceGreetingEditBox:SetPoint("TOPLEFT", instanceGreetingCheckbox, 30, 3)
	end

	do
		local instanceFarewellLabel = createLabel(FHABAddon.optionsFrame, "instanceFarewellLabel", L["FHAB_InstanceFarewell"])
		instanceFarewellLabel:SetPoint("TOPLEFT", instanceGreetingLabel, 300, 0)

		local instanceFarewellCheckbox = createCheckbox(
			FHABAddon.optionsFrame,
			"FHAB_InstanceFarewell_Checkbox",
			L["FHAB_InstanceFarewell"],
			L["FHAB_EnableButton_Desc"],
			true,
			function(self, value)
				FHABAddon.db.profile.config.instance.farewell = value
				FHABAddon.needReload = true
			end
		)
		instanceFarewellCheckbox:SetChecked(FHABAddon.db.profile.config.instance.farewell)
		instanceFarewellCheckbox:SetPoint("TOPLEFT", instanceFarewellLabel, 0, -14)

		local instanceFarewellEditBox = createEditbox(
			FHABAddon.optionsFrame,
			"FHAB_InstanceFarewell_EditBox",
			L["FHAB_InstanceFarewell"],
			L["FHAB_InstanceFarewell_Desc"],
			240,
			30,
			false,
			function(self)
				FHABAddon.db.profile.messages.instance.farewell = self:GetText()
			end
		)
		instanceFarewellEditBox:SetText(FHABAddon.db.profile.messages.instance.farewell)
		instanceFarewellEditBox:SetPoint("TOPLEFT", instanceFarewellCheckbox, 30, 3)
	end


  InterfaceOptions_AddCategory(FHABAddon.optionsFrame);
end

function FHABAddon_SetLayout(newValue)
	FHABAddon.db.profile.config.layout = newValue.arg1
	FHABAddon.needReload = true
	UIDropDownMenu_SetText(FHABAddon.layoutDropdown, newValue.value)
	CloseDropDownMenus()
end

function FHABAddon_ApplyLayout(layout)
  if layout == _SingleRowLayout then
    FHABAddon.db.profile.config.layout = _SingleRowLayout
    FHABAddon.db.profile.config.buttonsPerRow = 8
    FastHelloandBye_Title:SetText(L["FHAB_Title"])
    FastHelloandBye:SetSize(416, 72)
  elseif layout == _SingleColumnLayout then
    FHABAddon.db.profile.config.layout = _SingleColumnLayout
    FHABAddon.db.profile.config.buttonsPerRow = 1
    FastHelloandBye_Title:SetText(L["FHAB_Title_Short"])
    FastHelloandBye:SetSize(80, 240)
  elseif layout == _TwoColumnsLayout then
    FHABAddon.db.profile.config.layout = _TwoColumnsLayout
    FHABAddon.db.profile.config.buttonsPerRow = 2
    FastHelloandBye_Title:SetText(L["FHAB_Title_Short"])
    FastHelloandBye:SetSize(128, 144)
  else
    FHABAddon.db.profile.config.layout = _DefaultLayout
    FHABAddon.db.profile.config.buttonsPerRow = 4
    FastHelloandBye_Title:SetText(L["FHAB_Title"])
    FastHelloandBye:SetSize(224, 96)
  end
end
