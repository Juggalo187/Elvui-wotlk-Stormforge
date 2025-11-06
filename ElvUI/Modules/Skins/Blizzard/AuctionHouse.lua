local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs, unpack = ipairs, unpack
--WoW API / Variables
local GetAuctionSellItemInfo = GetAuctionSellItemInfo
local GetItemQualityColor = GetItemQualityColor
local PlaySound = PlaySound
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon("Blizzard_AuctionUI", "Skin_Blizzard_AuctionUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.auctionhouse then return end

	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")

	S:HookScript(AuctionFrame, "OnShow", function(self)
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

	S:HandleCloseButton(AuctionFrameCloseButton, AuctionFrame.backdrop)

	local buttons = {
		BrowseSearchButton,
		BrowseResetButton,
		BrowseBidButton,
		BrowseBuyoutButton,
		BrowseCloseButton,
		BidBidButton,
		BidBuyoutButton,
		BidCloseButton,
		AuctionsCreateAuctionButton,
		AuctionsCancelAuctionButton,
		AuctionsStackSizeMaxButton,
		AuctionsNumStacksMaxButton,
		AuctionsCloseButton
	}
	local checkBoxes = {
		IsUsableCheckButton,
		ShowOnPlayerCheckButton
	}
	local editBoxes = {
		BrowseName,
		BrowseMinLevel,
		BrowseMaxLevel,
		BrowseBidPriceGold,
		BrowseBidPriceSilver,
		BrowseBidPriceCopper,
		BidBidPriceGold,
		BidBidPriceSilver,
		BidBidPriceCopper,
		AuctionsStackSizeEntry,
		AuctionsNumStacksEntry,
		StartPriceGold,
		StartPriceSilver,
		StartPriceCopper,
		BuyoutPriceGold,
		BuyoutPriceSilver,
		BuyoutPriceCopper
	}
	local sortTabs = {
		BrowseQualitySort,
		BrowseLevelSort,
		BrowseDurationSort,
		BrowseHighBidderSort,
		BrowseCurrentBidSort,
		BidQualitySort,
		BidLevelSort,
		BidDurationSort,
		BidBuyoutSort,
		BidStatusSort,
		BidBidSort,
		AuctionsQualitySort,
		AuctionsDurationSort,
		AuctionsHighBidderSort,
		AuctionsBidSort
	}

	for _, button in ipairs(buttons) do
		S:HandleButton(button, true)
	end
	for _, checkBox in ipairs(checkBoxes) do
		S:HandleCheckBox(checkBox)
	end
	for _, editBox in ipairs(editBoxes) do
		S:HandleEditBox(editBox)
		editBox:SetTextInsets(1, 1, -1, 1)
	end
	for _, tab in ipairs(sortTabs) do
		tab:StripTextures()
		tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		tab:StyleButton()
	end

	for i = 1, AuctionFrame.numTabs do
		local tab = _G["AuctionFrameTab"..i]
		S:HandleTab(tab)
	end

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]
		tab:StripTextures()

		local highlight = tab:GetHighlightTexture()
		highlight:SetTexture(E.Media.Textures.Highlight)
		highlight:SetInside()
		highlight:SetVertexColor(0.9, 0.9, 0.9, 0.35)
	end

	local frames = {
		["Browse"] = 8,		-- NUM_BROWSE_TO_DISPLAY
		["Auctions"] = 9,	-- NUM_AUCTIONS_TO_DISPLAY
		["Bid"] = 9			-- NUM_BIDS_TO_DISPLAY
	}
	local function itemNameSetVertexColor(self, r, g, b)
		self.parent.highlight:SetVertexColor(r, g, b, 0.35)
		self.parent.itemButton:SetBackdropBorderColor(r, g, b)
	end
	local function itemNameHide(self)
		self.parent.itemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
	for frameName, numButtons in pairs(frames) do
		for i = 1, numButtons do
			local button = _G[frameName.."Button"..i]
			local name = _G[frameName.."Button"..i.."Name"]
			local itemButton = _G[frameName.."Button"..i.."Item"]
			local itemTexture = _G[frameName.."Button"..i.."ItemIconTexture"]
			local highlight = _G[frameName.."Button"..i.."Highlight"]

			button:StripTextures()

			highlight:SetTexture(E.Media.Textures.Highlight)
			highlight:SetInside()

			itemButton:SetTemplate()
			itemButton:StyleButton()
			itemButton:GetNormalTexture():SetTexture("")
			itemTexture:SetTexCoord(unpack(E.TexCoords))
			itemTexture:SetInside()

			button.highlight = highlight
			button.itemButton = itemButton
			name.parent = button

			hooksecurefunc(name, "SetVertexColor", itemNameSetVertexColor)
			hooksecurefunc(name, "Hide", itemNameHide)
		end
	end

	-- Custom Backdrops
	local function createBackdrop(parent)
		local background = CreateFrame("Frame", nil, parent)
		background:SetTemplate("Transparent")
		background:SetFrameLevel(parent:GetFrameLevel() - 1)
		return background
	end

	AuctionFrameBrowse.LeftBackground = createBackdrop(AuctionFrameBrowse)
	AuctionFrameBrowse.RightBackground = createBackdrop(AuctionFrameBrowse)
	AuctionFrameBid.Background = createBackdrop(AuctionFrameBid)
	AuctionFrameAuctions.LeftBackground = createBackdrop(AuctionFrameAuctions)
	AuctionFrameAuctions.RightBackground = createBackdrop(AuctionFrameAuctions)

	-- Browse Frame
	S:HandleDropDownBox(BrowseDropDown)
	S:HandleNextPrevButton(BrowsePrevPageButton, "left", nil, true)
	S:HandleNextPrevButton(BrowseNextPageButton, "right", nil, true)

	BrowseFilterScrollFrame:StripTextures()
	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)

	BrowseScrollFrame:StripTextures()
	S:HandleScrollBar(BrowseScrollFrameScrollBar)

	hooksecurefunc("AuctionFrameFilters_UpdateClasses", function()
		local scrollShown = #OPEN_FILTER_LIST > NUM_FILTERS_TO_DISPLAY

		for i = 1, NUM_FILTERS_TO_DISPLAY do
			_G["AuctionFilterButton"..i]:Width(157)
		end
	end)

	hooksecurefunc("AuctionFrameBrowse_Update", function()
		local scrollShown = BrowseScrollFrame:IsShown()

		for i = 1, NUM_BROWSE_TO_DISPLAY do
			_G["BrowseButton"..i]:Width(scrollShown and 608 or 629)
		end

		BrowseCurrentBidSort:Width(scrollShown and 188 or 209)
	end)

	-- Bid Frame
	BidScrollFrame:StripTextures()
	S:HandleScrollBar(BidScrollFrameScrollBar)

	hooksecurefunc("AuctionFrameBid_Update", function()
		local scrollShown = BidScrollFrame:IsShown()

		for i = 1, NUM_BIDS_TO_DISPLAY do
			_G["BidButton"..i]:Width(scrollShown and 776 or 797)
		end

		BidBidSort:Width(scrollShown and 158 or 179)
	end)

	-- Auctions Frame
	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton:StyleButton(nil, true)

	S:HandleDropDownBox(PriceDropDown)
	S:HandleDropDownBox(DurationDropDown)

	AuctionsScrollFrame:StripTextures()
	S:HandleScrollBar(AuctionsScrollFrameScrollBar)

	AuctionsItemButton:HookScript("OnEvent", function(self, event)
		local normalTexture = self:GetNormalTexture()

		if event == "NEW_AUCTION_UPDATE" and normalTexture then
			normalTexture:SetTexCoord(unpack(E.TexCoords))
			normalTexture:SetInside()

			local _, _, _, quality = GetAuctionSellItemInfo()

			if quality then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc("AuctionFrameAuctions_Update", function()
		local scrollShown = AuctionsScrollFrame:IsShown()

		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			_G["AuctionsButton"..i]:Width(scrollShown and 580 or 601)
		end

		AuctionsBidSort:Width(scrollShown and 203 or 224)
	end)

	-- DressUp Frame
	AuctionDressUpFrame:StripTextures()

	S:HandleCloseButton(AuctionDressUpFrameCloseButton, AuctionDressUpFrame)

	AuctionDressUpModel:CreateBackdrop()
	AuctionDressUpModel.backdrop:SetOutside(AuctionDressUpModel)

	SetAuctionDressUpBackground()
	AuctionDressUpBackgroundTop:SetDesaturated(true)
	AuctionDressUpBackgroundBot:SetDesaturated(true)

	S:HandleRotateButton(AuctionDressUpModelRotateLeftButton)
	S:HandleRotateButton(AuctionDressUpModelRotateRightButton)

	S:HandleButton(AuctionDressUpFrameResetButton)

	AuctionDressUpFrame:SetTemplate("Transparent")

	AuctionDressUpFrame:SetScript("OnShow", function()
		PlaySound("igCharacterInfoOpen")
	end)

	AuctionDressUpFrame:SetScript("OnHide", function()
		PlaySound("igCharacterInfoClose")
	end)

	-- Progress Frame
	AuctionProgressFrame:StripTextures()
	AuctionProgressFrame:SetTemplate("Transparent")

	S:HandleStatusBar(AuctionProgressBar, {1, 0.7, 0})

	S:HandleCloseButton(AuctionProgressFrameCancelButton)

	AuctionProgressBarIcon:CreateBackdrop("Default")
	AuctionProgressBarIcon:SetTexCoord(unpack(E.TexCoords))
end)