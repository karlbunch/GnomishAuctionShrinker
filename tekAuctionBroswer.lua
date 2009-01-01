
local NUM_ROWS, BOTTOM_GAP = 14, 25
local ROW_HEIGHT = math.floor((305-BOTTOM_GAP)/NUM_ROWS)
local TEXT_GAP = 4
local noop = function() end


local function GSC(cash)
	if not cash then return end
	local g, s, c = floor(cash/10000), floor((cash/100)%100), cash%100
	if g > 0 then return string.format("|cffffd700%d.|cffc7c7cf%02d.|cffeda55f%02d", g, s, c)
	elseif s > 0 then return string.format("|cffc7c7cf%d.|cffeda55f%02d", s, c)
	else return string.format("|cffc7c7cf%d", c) end
end


---------------------
--      Panel      --
---------------------

local panel = CreateFrame("Frame", nil, AuctionFrameBrowse)
panel:SetWidth(605) panel:SetHeight(305)
panel:SetPoint("TOPLEFT", 188, -103)


-- Hide default panels
for i=1,8 do
	local butt = _G["BrowseButton"..i]
	butt:Hide()
	butt.Show = butt.Hide
end


local bidbutt, buybutt = BrowseBidButton, BrowseBuyoutButton

local scrollbar, upbutt, downbutt = BrowseScrollFrameScrollBar, BrowseScrollFrameScrollBarScrollUpButton, BrowseScrollFrameScrollBarScrollDownButton
scrollbar.RealSetValue, scrollbar.RealSetMinMaxValues, scrollbar.RealSetValueStep = scrollbar.SetValue, scrollbar.SetMinMaxValues, scrollbar.SetValueStep
scrollbar.SetValue, scrollbar.SetMinMaxValues, scrollbar.SetValueStep = noop, noop, noop

local nextbutt, prevbutt, counttext = BrowseNextPageButton, BrowsePrevPageButton, BrowseSearchCountText
nextbutt:SetParent(panel)
nextbutt:SetWidth(24) nextbutt:SetHeight(24)
nextbutt:ClearAllPoints()
nextbutt:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
nextbutt:Show()
nextbutt.RealShow, nextbutt.RealHide, nextbutt.RealEnable, nextbutt.RealDisable = nextbutt.Show, nextbutt.Hide, nextbutt.Enable, nextbutt.Disable
nextbutt.Show, nextbutt.Hide, nextbutt.Enable, nextbutt.Disable = noop, noop, noop, noop
nextbutt:GetRegions():Hide()

prevbutt:SetParent(panel)
prevbutt:SetWidth(24) prevbutt:SetHeight(24)
prevbutt:ClearAllPoints()
prevbutt:SetPoint("RIGHT", nextbutt, "LEFT")
prevbutt:Show()
prevbutt.RealShow, prevbutt.RealHide, prevbutt.RealEnable, prevbutt.RealDisable = prevbutt.Show, prevbutt.Hide, prevbutt.Enable, prevbutt.Disable
prevbutt.Show, prevbutt.Hide, prevbutt.Enable, prevbutt.Disable = noop, noop, noop, noop
prevbutt:GetRegions():Hide()

counttext:SetParent(panel)
counttext:ClearAllPoints()
counttext:SetPoint("RIGHT", prevbutt, "LEFT")
counttext:Show()
counttext.Hide = counttext.Show


local Update, UpdateArrows
local function OnMouseWheel(self, value) scrollbar:RealSetValue(scrollbar:GetValue() - value*10) end
local function RowOnClick(self)
	if IsAltKeyDown() then
		SetSelectedAuctionItem("list", self.index)
		PlaceAuctionBid("list", self.index, (select(9, GetAuctionItemInfo("list", self.index))))
		CloseAuctionStaticPopups()
	elseif IsModifiedClick() then HandleModifiedItemClick(self.link)
	else
		if GetCVarBool("auctionDisplayOnCharacter") then DressUpItemLink(self.link) end
		SetSelectedAuctionItem("list", self.index)
		CloseAuctionStaticPopups() -- Close any auction related popups
		Update()
	end
end
local function IconOnEnter(self)
	if not self.row.index then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetAuctionItem("list", self.row.index)

	GameTooltip_ShowCompareItem()

	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end
local function HideTooltip() GameTooltip:Hide() end

local rows = {}
for i=1,NUM_ROWS do
	local row = CreateFrame("Button", nil, panel)
	row:SetHeight(ROW_HEIGHT)
	row:SetPoint("LEFT")
	row:SetPoint("RIGHT")
	if i == 1 then row:SetPoint("TOP")
	else row:SetPoint("TOP", rows[i-1], "BOTTOM") end
	row:SetScript("OnClick", RowOnClick)
	row:SetScript("OnMouseWheel", OnMouseWheel)
	row:EnableMouseWheel()
	row:Disable()
	rows[i] = row

	row:SetHighlightTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	row:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.578125)

	local icon = CreateFrame("Button", nil, row)
	icon:SetScript("OnEnter", IconOnEnter)
	icon:SetScript("OnLeave", HideTooltip)
	icon:SetWidth(ROW_HEIGHT-2) icon:SetHeight(ROW_HEIGHT-2)
	icon:SetPoint("LEFT", row, TEXT_GAP, 0)
	icon.row = row
	row.icon = icon

	local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	name:SetWidth(155) name:SetHeight(ROW_HEIGHT)
	name:SetPoint("LEFT", icon, "RIGHT", TEXT_GAP, 0)
	name:SetJustifyH("LEFT")
	row.name = name

	local min = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	min:SetWidth(23)
	min:SetPoint("LEFT", name, "RIGHT", TEXT_GAP, 0)
	min:SetJustifyH("RIGHT")
	row.min = min

	local ilvl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	ilvl:SetWidth(33)
	ilvl:SetPoint("LEFT", min, "RIGHT", TEXT_GAP, 0)
	ilvl:SetJustifyH("RIGHT")
	row.ilvl = ilvl

	local owner = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	owner:SetWidth(75) owner:SetHeight(ROW_HEIGHT)
	owner:SetPoint("LEFT", ilvl, "RIGHT", TEXT_GAP, 0)
	owner:SetJustifyH("RIGHT")
	row.owner = owner

	local timeleft = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	timeleft:SetWidth(45)
	timeleft:SetPoint("LEFT", owner, "RIGHT", TEXT_GAP, 0)
	timeleft:SetJustifyH("RIGHT")
	row.timeleft = timeleft

	local bid = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bid:SetWidth(65)
	bid:SetPoint("LEFT", timeleft, "RIGHT", TEXT_GAP, 0)
	bid:SetJustifyH("RIGHT")
	row.bid = bid

	local buyout = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	buyout:SetWidth(65)
	buyout:SetPoint("LEFT", bid, "RIGHT", TEXT_GAP, 0)
	buyout:SetJustifyH("RIGHT")
	row.buyout = buyout

	local unit = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	unit:SetWidth(65)
	unit:SetPoint("LEFT", buyout, "RIGHT", TEXT_GAP, 0)
	unit:SetJustifyH("RIGHT")
	row.unit = unit

	local qty = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qty:SetWidth(23)
	qty:SetPoint("LEFT", unit, "RIGHT", TEXT_GAP, 0)
	qty:SetJustifyH("RIGHT")
	row.qty = qty
end


-----------------------
--      Updater      --
-----------------------

local orig = QueryAuctionItems
function QueryAuctionItems(...) scrollbar:RealSetValue(0); return orig(...) end

local offset, timeframes = 0, {"<30m", "30m-2h", "2-12hr", ">12hr"}
function Update(self, event)
	local selected = GetSelectedAuctionItem("list")
	AuctionFrame.buyoutPrice = nil
	bidbutt:Disable()
	buybutt:Disable()

	for i,row in pairs(rows) do
		local index = offset + i
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyout, bidAmount, highBidder, owner = GetAuctionItemInfo("list", index)
		local displayedBid = bidAmount == 0 and minBid or bidAmount
		local requiredBid = bidAmount == 0 and minBid or bidAmount + minIncrement
		if requiredBid >= MAXIMUM_BID_PRICE then buyoutPrice = requiredBid end -- Lie about our buyout price

		if name then
			local color = ITEM_QUALITY_COLORS[quality]
			local link = GetAuctionItemLink("list", index)
			local _, _, _, iLevel, _, _, _, maxStack = GetItemInfo(link)
			local duration = GetAuctionItemTimeLeft("list", index)

			row.icon:SetNormalTexture(texture)
			row.name:SetText(name)
			row.name:SetVertexColor(color.r, color.g, color.b)
			row.min:SetText(level ~= 1 and level)
			row.ilvl:SetText(iLevel)
			row.owner:SetText(owner)
			row.timeleft:SetText(timeframes[duration])
			row.bid:SetText(GSC(minBid) or "----")
			row.buyout:SetText(buyout > 0 and GSC(buyout) or "----")
			row.unit:SetText(buyout > 0 and maxStack > 1 and GSC(buyout/count) or "----")
			row.qty:SetText(maxStack > 1 and count)
			row:Enable()

			row.index, row.link = index, link
		else
			row.icon:SetNormalTexture(nil)
			row.name:SetText()
			row.min:SetText()
			row.ilvl:SetText()
			row.owner:SetText()
			row.timeleft:SetText()
			row.bid:SetText()
			row.buyout:SetText()
			row.unit:SetText()
			row.qty:SetText()
			row:Disable()

			row.index, row.link = nil
		end

		if selected and index == selected then
			row:LockHighlight()

			MoneyInputFrame_SetCopper(BrowseBidPrice, requiredBid) -- Set bid
			if not highBidder and owner ~= UnitName("player") and GetMoney() >= MoneyInputFrame_GetCopper(BrowseBidPrice) and MoneyInputFrame_GetCopper(BrowseBidPrice) <= MAXIMUM_BID_PRICE then bidbutt:Enable() end

			if buyout > 0 and buyout >= minBid then
				if GetMoney() >= buyout or (highBidder and GetMoney()+bidAmount >= buyout) then
					buybutt:Enable()
					AuctionFrame.buyoutPrice = buyout
				end
			end
		else
			row:UnlockHighlight()
		end
	end

	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
	local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1
	local itemsMax = itemsMin + numBatchAuctions - 1

	if totalAuctions == 0 then
		BrowseSearchCountText:Hide()
		prevbutt:RealHide()
		nextbutt:RealHide()
	else
		BrowseSearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions)
		BrowseSearchCountText:Show()
		prevbutt:RealShow()
		nextbutt:RealShow()
		if numBatchAuctions-NUM_ROWS <= 0 then
			scrollbar:Disable()
			upbutt:Disable()
			downbutt:Disable()
		else
			scrollbar:Enable()
			scrollbar:RealSetMinMaxValues(0, numBatchAuctions-NUM_ROWS)
			scrollbar:RealSetValueStep(1)
		end
	end

	if AuctionFrameBrowse.page == 0 then prevbutt:RealDisable() else prevbutt:RealEnable() end
	if AuctionFrameBrowse.page == (math.ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1) then nextbutt:RealDisable() else nextbutt:RealEnable() end

	UpdateArrows()
end

panel:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
panel:SetScript("OnEvent", Update)
panel:SetScript("OnShow", Update)


-------------------------
--      Scrolling      --
-------------------------

panel:SetScript("OnMouseWheel", OnMouseWheel)
panel:EnableMouseWheel()
scrollbar:SetScript("OnValueChanged", function(self, value, ...)
	offset = value
	local min, max = self:GetMinMaxValues()
	if value == min then upbutt:Disable() else upbutt:Enable() end
	if value == max then downbutt:Disable() else downbutt:Enable() end
	Update()
end)
upbutt:SetScript("OnClick", function() scrollbar:RealSetValue(scrollbar:GetValue() - 10); PlaySound("UChatScrollButton") end)
downbutt:SetScript("OnClick", function() scrollbar:RealSetValue(scrollbar:GetValue() + 10); PlaySound("UChatScrollButton") end)


-----------------------
--      Headers      --
-----------------------

local row = rows[1]

local function AnchorSort(butt, left, right, loffset)
	right, loffset = right or left, loffset or (-TEXT_GAP/2 - 1)
	butt:ClearAllPoints()
	butt:SetPoint("TOP", AuctionFrameBrowse, "TOP", 0, -82)
	butt:SetPoint("LEFT", left, "LEFT", loffset, 0)
	butt:SetPoint("RIGHT", right, "RIGHT", TEXT_GAP/2 + 1, 0)
	butt.SetWidth = noop
end

local sorts = {
	buyout     = {"duration", "quantity", "name", "level", "quality", "bid", "buyout"},
	buyout_rev = {     false,       true,  false,    true,     false, false,    false},
	quantity     = {"duration", "buyoutthenbid", "name", "level", "quality", "quantity"},
	quantity_rev = {     false,           false,  false,    true,     false,      false},
}
local function SortAuctions(self)
	local existingSortColumn, existingSortReverse = GetAuctionSort("list", 1) -- change the sort as appropriate
	local oppositeOrder = false
	if existingSortColumn and existingSortColumn == self.sortcolumn then oppositeOrder = not existingSortReverse end

	SortAuctionClearSort("list") -- clear the existing sort.

	local revs = sorts[self.sortcolumn.."_rev"]
	for i,column in ipairs(sorts[self.sortcolumn]) do -- set the columns
		local reverse = revs[i]
		if i == #revs and existingSortColumn and existingSortColumn == self.sortcolumn and (not not existingSortReverse) == reverse then reverse = not reverse end
		SortAuctionSetSort("list", column, reverse)
	end

	AuctionFrameBrowse_Search() -- apply the sort
end

local function MakeSortButton(text, sortcolumn)
	local butt = CreateFrame("Button", nil, AuctionFrameBrowse)
	butt:SetHeight(19)

	butt:SetNormalFontObject(GameFontHighlightSmall)
	butt:SetText(text)

	local fs = butt:GetFontString()
	fs:ClearAllPoints()
	fs:SetPoint("LEFT", butt, "LEFT", 8, 0)

	local left = butt:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(5) left:SetHeight(19)
	left:SetPoint("TOPLEFT")
	left:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
	left:SetTexCoord(0, 0.078125, 0, 0.59375)

	local right = butt:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(4) right:SetHeight(19)
	right:SetPoint("TOPRIGHT")
	right:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
	right:SetTexCoord(0.90625, 0.96875, 0, 0.59375)

	local middle = butt:CreateTexture(nil, "BACKGROUND")
	middle:SetHeight(19)
	middle:SetPoint("LEFT", left, "RIGHT")
	middle:SetPoint("RIGHT", right, "LEFT")
	middle:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
	middle:SetTexCoord(0.078125, 0.90625, 0, 0.59375)

	butt:SetNormalTexture("Interface\\Buttons\\UI-SortArrow")
	local normtext = butt:GetNormalTexture()
	normtext:ClearAllPoints()
	normtext:SetPoint("LEFT", fs, "RIGHT", 0, -2)
	normtext:SetWidth(9) normtext:SetHeight(8)
	normtext:SetTexCoord(0, 0.5625, 0, 1)
	normtext:Hide()
	butt.arrow = normtext

	butt:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
	local highlight = butt:GetHighlightTexture()
	highlight:ClearAllPoints()
	highlight:SetPoint("LEFT")
	highlight:SetPoint("RIGHT")
	highlight:SetHeight(24)

	butt.sortcolumn = sortcolumn
	if sortcolumn then butt:SetScript("OnClick", SortAuctions) else butt:Disable() end

	return butt
end

local ilvlsort = MakeSortButton("iLvl")
local buyoutsort = MakeSortButton("Buyout", "buyout")
local unitsort = MakeSortButton("Unit BO")
local qtysort = MakeSortButton("#", "quantity")

AnchorSort(BrowseQualitySort, row.icon, row.name, -TEXT_GAP - 2)
AnchorSort(BrowseLevelSort, row.min)
AnchorSort(BrowseHighBidderSort, row.owner)
AnchorSort(BrowseDurationSort, row.timeleft)
AnchorSort(BrowseCurrentBidSort, row.bid)
AnchorSort(ilvlsort, row.ilvl)
AnchorSort(buyoutsort, row.buyout)
AnchorSort(unitsort, row.unit)
AnchorSort(qtysort, row.qty)

BrowseDurationSort:SetText("Time")
BrowseCurrentBidSort:SetText("Bid")
ilvlsort:SetText("iLvl")
buyoutsort:SetText("Buyout")
unitsort:SetText("Unit BO")

local function UpdateArrow(butt)
	local primaryColumn, reversed = GetAuctionSort("list", 1)
	if butt.sortcolumn == primaryColumn then
		butt.arrow:Show()
		butt.arrow:SetTexCoord(0, 0.5625, reversed and 1 or 0, reversed and 0 or 1)
	else butt.arrow:Hide() end
end

function UpdateArrows()
	UpdateArrow(buyoutsort)
	UpdateArrow(qtysort)
end


LibStub("tekKonfig-AboutPanel").new(nil, "tekAuctionBroswer")
