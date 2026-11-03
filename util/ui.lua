texts = require('util/texts')
-- UI CONSTANTS
UI_SCALE				= tonumber(trackermenusettings.ui_scale) or 1
FONT_SIZE				= function() return 12 * UI_SCALE end
SUBTAB_FONT_SIZE 		= function() return 0.8 * FONT_SIZE() end
LINE_HEIGHT				= function() return 16 * UI_SCALE end
PADDING					= function() return 8 * UI_SCALE end
SUBTAB_PADDING			= function() return 0.8 * PADDING() end
CHAR_WIDTH				= function() return (FONT_SIZE()/(2*UI_SCALE)) * UI_SCALE end
VISIBLE_ROWS			= 15
-- UI COLORS
UI_BG					= {red = 12, green = 12,  blue = 32,  alpha = 210}
UI_TABBG				= {red = 30, green = 60,  blue = 120,  alpha = 240}
UI_TABBG_SELECTED		= {red = 70, green = 130, blue = 200, alpha = 220}
UI_SUBTABBG				= {red = 75, green = 75,  blue = 100,  alpha = 200}
UI_SUBTABBG_SELECTED	= {red = 70, green = 130, blue = 200, alpha = 220}
UI_SUBTABBG_COMPLETED	= {red = 35, green = 110,  blue = 35,  alpha = 220}
-- UI WINDOW STATE
active_tab				= 1
active_subtab			= 0
scroll					= 0
selected				= 1
maintabs_height			= 0
subtabs_height			= 0
subtabs_initiated 		= false
subtabs_drawn 			= false
-- UI DATA
tabs = {
    {
        name = 'Main',
        items = L{},
		button = {},
    },
    {
        name = 'Story',
        items = L{},
		button = {},
		tabs = {'sandoriamissions', 'bastokmissions', 'windurstmissions', 'zilartmissions', 'copmissions', 'assaults', 'ahturhganmissions', 'campaign', 'wotgmissions', 'acpmissions', 'mkdmissions', 'asamissions', 'soamissions', 'rovmissions', 'tvrmissions', 'sandoria', 'bastok', 'windurst', 'jeuno', 'ahturhgan', 'crystalwar', 'outlands', 'other', 'abyssea', 'adoulin', 'coalition'},
    },
	{
        name = 'Other Content',
        items = L{},
		button = {},
		tabs = {'fishes', 'ergonlocus', 'jobpoints', 'masterlevels', 'combatskills'},
    },
	{
        name = 'Key Items',
        items = L{},
		button = {},
		tabs = {'Permanent_Key_Items', 'Magical_Maps', 'Mounts', 'Active_Effects', 'Abyssea', 'Voidwatch', 'Mog_Garden', 'Claim_Slips', 'atmacite'},
    },
	{
        name = 'Magic',
        items = L{},
		button = {},
		tabs = {'WhiteMagic', 'BlackMagic', 'SummonerPact', 'Ninjutsu', 'BardSong', 'BlueMagic', 'Geomancy', 'Trust', 'CorsairRoll', 'pupattachments'}
    },
	{
        name = 'Warps',
        items = L{},
		button = {},
		tabs = {'homepoints', 'survivalguides', 'waypoints', 'telepoints', 'cavernousmaws', 'lycopodium', 'eschanportals', 'outposts', 'protowaypoints', 'zones', 'abysseaconflux',
		'unknownwarps',
		},
    },
	{
        name = 'Monstrosity',
        items = L{},
		button = {},
		tabs = {'monsterlevels', 'monstervariants', 'racejobinstincts', 'monsterinstincts'},
    },
	{
        name = 'Titles',
        items = L{},
		button = {},
		tabs = {'titles', 'titles_by_content', 'titles_by_content_detailed'},
    },
	{
        name = 'RoE',
        items = L{},
		button = {},
		tabs = {'roe'},
    },
	{
        name = 'Battle Content',
        items = L{},
		button = {},
		tabs = {'mmm_mazecount', 'mmmvouchers','mmmrunes','meebleburrows','sheola','sheolb','sheolc','sheolgaol','vorseals', 'emporox'},
    },
}

subtabs = T{}

-- UI TEXT OBJECT
ui = {}
ui.menu = texts.new('', {
    pos = { x = trackermenusettings.pos.x, y = trackermenusettings.pos.y },
    text = {
        font = 'Arial',
        size = FONT_SIZE(),
        red = 255, green = 255, blue = 255,
    },
    bg = {
        red = UI_BG.red, green = UI_BG.green, blue = UI_BG.blue,
        alpha = UI_BG.alpha,
    },
    padding = PADDING(),
})

-- Vertical scrollbar for the item list.
ui.scrollbar = texts.new('', {
    pos = { x = trackermenusettings.pos.x, y = trackermenusettings.pos.y },
    text = {
        font = 'Arial',
        size = FONT_SIZE(),
        red = 180, green = 180, blue = 180,
    },
    bg = {
        red = UI_BG.red, green = UI_BG.green, blue = UI_BG.blue,
        alpha = 0,
    },
    padding = 0,
    flags = {
        draggable = false,
    },
})
ui.scrollbar:hide()

-- Scrollbar settings
SCROLLBAR_WHEEL_STEP	= 3			-- rows scrolled per mouse wheel notch
SCROLLBAR_WHEEL_INVERT	= false		-- set to true if the wheel scrolls the wrong way
SCROLLBAR_GUTTER		= '   '		-- spaces added after every row so the bar never covers text
SCROLLBAR_HIT_MARGIN	= function() return 6 * UI_SCALE end	-- extra clickable pixels around the bar

-- Scrollbar state
scrollbar_dragging		= false
scrollbar_item_count	= 0
scrollbar_grab			= 0			-- where on the thumb (in rows) it was grabbed
scrollbar_geom			= nil		-- screen geometry of the track, refreshed every frame
scrollbar_last_text		= nil


ui.showcompleted = texts.new('', {
			pos = { x = 0, y = 0},
			text = {
				font = 'Arial',
				size = FONT_SIZE(),
				red = 255, green = 255, blue = 255,
			},
			bg = {
				red = UI_SUBTABBG.red, green = UI_SUBTABBG.green, blue = UI_SUBTABBG.blue,
				alpha = UI_SUBTABBG.alpha,
			},
			padding = PADDING(),
			flags = {
				--right = true,
				--bottom = true,
				draggable = false,
			},
		})
ui.showcompleted:text('Show Completed')
ui.showcompleted:register_event('left_click', function()
	trackermenusettings.showcompleted = not trackermenusettings.showcompleted
	util.addon_log('showcompleted: '..tostring(trackermenusettings.showcompleted))
	trackermenusettings:save()
	xichecklist_updatemenulogs()
	if trackermenusettings.showcompleted then
		ui.showcompleted:bg_color(UI_SUBTABBG_SELECTED.red, UI_SUBTABBG_SELECTED.green, UI_SUBTABBG_SELECTED.blue)
		ui.showcompleted:bg_alpha(UI_SUBTABBG_SELECTED.alpha)
	else
		ui.showcompleted:bg_color(UI_SUBTABBG.red, UI_SUBTABBG.green, UI_SUBTABBG.blue)
		ui.showcompleted:bg_alpha(UI_SUBTABBG.alpha)
	end
end)
ui.showcompleted:hide()

initiate_tabs = function()
	for i, tab in ipairs(tabs) do
		tabs[i].button = texts.new('', {
			pos = { x = ui.menu:pos_x(), y = ui.menu:pos_y()},
			text = {
				font = 'Arial',
				size = FONT_SIZE(),
				red = 255, green = 255, blue = 255,
			},
			bg = {
				red = UI_TABBG.red, green = UI_TABBG.green, blue = UI_TABBG.blue,
				alpha = UI_TABBG.alpha,
			},
			padding = PADDING(),
			flags = {
				draggable = false,
			},
		})
		tabs[i].button:text(tab.name)
		tabs[i].button:register_event('left_click', function()
			if tabs[i].tabs then
				tabs[i].items = L{}
				for idx, tab in ipairs(tabs[i].tabs) do
					append_header(i, tab_logs[tab].name..' (%d/%d)', tab_logs[tab].completed, tab_logs[tab].total)
					if (addonhelptext[tab]) then
						for hi, helptext in pairs(addonhelptext[tab]) do
							append_addonhelp(i, addonhelptext[tab][hi][1], playertracker.talk_to_npc[addonhelptext[tab][hi][2]])
						end
					end
					append_items(tabs[i].items, tab_logs[tab].items)
				end
			end
			active_tab = i
			active_subtab = 0
			selected = 1
			scroll = 0
			subtabs_drawn = false
			draw()
		end)
		if tabs[i].tabs then
			initiate_subtabs(i, tabs[i].tabs)
		end
	end
	subtabs_initiated = true
end

initiate_subtabs = function(activetab, subtabslist)
	tabs[activetab].subtabs = {}
	for i, tab in ipairs(subtabslist) do
		tabs[activetab].subtabs[i] = {}
		tabs[activetab].subtabs[i].active_tab = activetab
		tabs[activetab].subtabs[i].button = texts.new('', {
			pos = {x = 0, y = 0},
			text = {
				font = 'Arial',
				size = FONT_SIZE(),
				red = 255, green = 255, blue = 255,
			},
			bg = {
				red = UI_SUBTABBG.red, green = UI_SUBTABBG.green, blue = UI_SUBTABBG.blue,
				alpha = UI_SUBTABBG.alpha,
			},
			padding = PADDING(),
			flags = {
				draggable = false,
			},
		})
		tabs[activetab].subtabs[i].button:text(defaulttab_logs[tab].name)
		tabs[activetab].subtabs[i].tab = tab
		tabs[activetab].subtabs[i].button:register_event('left_click', function()
			tabs[activetab].items = L{}
			append_header(activetab, tab_logs[tab].name..' (%d/%d)', tab_logs[tab].completed, tab_logs[tab].total)
			if (addonhelptext[tab]) then
				for i, helptext in pairs(addonhelptext[tab]) do
					append_addonhelp(activetab, addonhelptext[tab][i][1], playertracker.talk_to_npc[addonhelptext[tab][i][2]])
				end
			end
			append_items(tabs[activetab].items, tab_logs[tab].items)
			active_subtab = i
			selected = 1
			scroll = 0
			subtabs_drawn = false
			draw()
		end)
	end
end

draw_tabs = function()
	local total_xextent, total_yextent = 0, 0
	local xextent, yextent = 0, 0
	for i, tab in ipairs(tabs) do
		tabs[i].button:pos(ui.menu:pos_x()+total_xextent, ui.menu:pos_y())
		tabs[i].button:visible(ui.menu:visible())
		tabs[i].button:size(FONT_SIZE())
		tabs[i].button:pad(PADDING())
		if active_tab == i then
			tabs[i].button:bg_color(UI_TABBG_SELECTED.red, UI_TABBG_SELECTED.green, UI_TABBG_SELECTED.blue)
			tabs[i].button:bg_alpha(UI_TABBG_SELECTED.alpha)
		else
			tabs[i].button:bg_color(UI_TABBG.red, UI_TABBG.green, UI_TABBG.blue)
			tabs[i].button:bg_alpha(UI_TABBG.alpha)
		end
		xextent, yextent = tabs[i].button:extents()
		total_xextent = total_xextent + xextent
	end
	ui.width = total_xextent
	maintabs_height = yextent
end

draw_subtabs = function()
	if subtabs_initiated and subtabs_drawn then return end
	local total_xextent, total_yextent = 0, maintabs_height+PADDING()
	local xextent, yextent = 0, 0
	local lines = 0
	hide_subtabs()
	if tabs[active_tab].subtabs then
		lines = 1
		for i, tab in pairs(tabs[active_tab].subtabs) do
			tabs[active_tab].subtabs[i].button:pos(ui.menu:pos_x()+total_xextent, ui.menu:pos_y()+total_yextent)
			local tabname = tabs[active_tab].subtabs[i].tab
			tabs[active_tab].subtabs[i].button:text(defaulttab_logs[tabname].name .. ' (%d/%d)':format(tab_logs[tabname].completed, tab_logs[tabname].total))
			tabs[active_tab].subtabs[i].button:visible(ui.menu:visible())
			tabs[active_tab].subtabs[i].button:size(SUBTAB_FONT_SIZE())
			tabs[active_tab].subtabs[i].button:pad(SUBTAB_PADDING())
			xextent, yextent = tabs[active_tab].subtabs[i].button:extents()
			total_xextent = total_xextent + xextent + 7
			if active_subtab == i then
				tabs[active_tab].subtabs[i].button:bg_color(UI_SUBTABBG_SELECTED.red, UI_SUBTABBG_SELECTED.green, UI_SUBTABBG_SELECTED.blue)
				tabs[active_tab].subtabs[i].button:bg_alpha(UI_SUBTABBG_SELECTED.alpha)
			else
				if (tab_logs[tabname].completed >= tab_logs[tabname].total) and (tab_logs[tabname].total > 0) then
					tabs[active_tab].subtabs[i].button:bg_color(UI_SUBTABBG_COMPLETED.red, UI_SUBTABBG_COMPLETED.green, UI_SUBTABBG_COMPLETED.blue)
					tabs[active_tab].subtabs[i].button:bg_alpha(UI_SUBTABBG_COMPLETED.alpha)
				else
					tabs[active_tab].subtabs[i].button:bg_color(UI_SUBTABBG.red, UI_SUBTABBG.green, UI_SUBTABBG.blue)
					tabs[active_tab].subtabs[i].button:bg_alpha(UI_SUBTABBG.alpha)
				end
			end
			if total_xextent > ui.width then
				total_xextent = xextent + 7
				lines = lines + 1
				total_yextent = total_yextent + yextent + 3
				tabs[active_tab].subtabs[i].button:pos(ui.menu:pos_x(), ui.menu:pos_y()+total_yextent)
			end
		end
	end
	subtabs_height = (lines > 0 ) and total_yextent or 0
	local menuexextent, menuyextent = ui.menu:extents()
	local showcompletedxextent, showcompletedextent = ui.showcompleted:extents()
	ui.showcompleted:pos(trackermenusettings.pos.x+menuexextent-showcompletedxextent, trackermenusettings.pos.y+menuyextent-showcompletedextent)
	ui.showcompleted:visible(ui.menu:visible())
end

hide_subtabs = function()
	for i, tab in ipairs(tabs) do
		if tabs[i].subtabs then
			for ti, tab in pairs(tabs[i].subtabs) do
				tabs[i].subtabs[ti].button:hide()
			end
		end
	end
	ui.showcompleted:hide()
	subtabs_height = 0
end

append_items = function(dst, src)
    if type(dst) ~= 'table' or type(src) ~= 'table' then
        return
    end
    for _, item in ipairs(src) do
		dst:append(item)
    end
end

format_item = function(item)
	local text = item.text
	local menucolor = item.completed and '(0,255,0)' or '(255,255,0)'
	if item.obtainmethod ~= nil then
		local obtainmethod = '\\cs(255,255,255)[' .. item.obtainmethod .. ']\\cr\\cs'..menucolor
		if item.category == 'Titles' then
			text = obtainmethod..' '..text
		else
			text = text..' '..obtainmethod
		end
	end
	text = '\\cs'..menucolor..text..'\\cr'
	
	-- Tag rows that have a bg-wiki page (click the row to open it)
	if get_wiki_url(item) then
		text = text..' \\cs(100,180,255)[wiki]\\cr'
	end
	
	return text
end

append_maintab = function(text, ...)
	local args = {...}
	local menulinecolor = (args[1]==args[2]) and '(0,255,0)' or '(255,255,0)'
	tabs[1].items:append(util.list_item(nil, '\\cs'..menulinecolor..'-'..text:format(...)..'\\cr'))
end

append_header = function(tab, text, ...)
	args = {...}
	local menulinecolor = (args[1]==args[2]) and '(0,255,0)' or '(255,255,255)'
	text = '==== '..text..' ===='
	tabs[tab].items:append(util.list_item(nil, '\\cs'..menulinecolor..text:format(...)..'\\cr'))
	if args[2] == 0 then
		tabs[tab].items:append(util.list_item(nil, '\\cs(235,0,0)You must zone to update.\\cr'))
	end
end

append_addonhelp = function(tab, text, condition)
	if not (condition and trackermenusettings.showcompleted) then
		append_items(tabs[tab].items, {util.list_item('Addon Help', '\\cs(235,0,0)'..text..'\\cr', condition)})
	end
end

-- UI HELPERS
inside = function(mx, my, x, y, width, h)
	return mx >= x and mx <= x + width
		and my >= y and my <= y + h
end

clamp_scroll = function(count)
	if selected < scroll + 1 then
		scroll = selected - 1
	elseif selected > scroll + VISIBLE_ROWS then
		scroll = selected - VISIBLE_ROWS
	end
	scroll = math.max(0, math.min(scroll, count - VISIBLE_ROWS))
end

get_max_scroll = function()
	return math.max(0, scrollbar_item_count - VISIBLE_ROWS)
end

-- Scroll the list and keep the '>' marker inside the visible rows
-- (otherwise clamp_scroll() would pull the view back to the marker).
set_scroll = function(new_scroll)
	scroll = math.max(0, math.min(get_max_scroll(), new_scroll))
	selected = math.max(scroll + 1, math.min(selected, scroll + VISIBLE_ROWS))
end

-- The scrollbar is a second text object that uses the same font, size and line
-- structure as the menu (it starts with the same number of empty lines as the
-- menu has lines before the first item). Its rows therefore line up exactly with
-- the item rows, whatever the font metrics are.
update_scrollbar = function(count, prefix_lines)
	scrollbar_item_count = count

	local max_scroll = get_max_scroll()
	if max_scroll <= 0 or not ui.menu:visible() then
		ui.scrollbar:hide()
		scrollbar_dragging = false
		scrollbar_geom = nil
		return
	end

	-- Thumb size is proportional to the visible part of the list.
	local thumb_len = math.floor(VISIBLE_ROWS * VISIBLE_ROWS / count + 0.5)
	thumb_len = math.max(1, math.min(VISIBLE_ROWS - 1, thumb_len))
	local thumb_top = math.floor(scroll / max_scroll * (VISIBLE_ROWS - thumb_len) + 0.5)

	local thumb_color = scrollbar_dragging and '255,255,255' or '200,200,200'
	local rows = {}
	for row = 0, VISIBLE_ROWS - 1 do
		if row >= thumb_top and row < thumb_top + thumb_len then
			rows[#rows + 1] = '\\cs(' .. thumb_color .. ')█\\cr'
		else
			rows[#rows + 1] = '\\cs(100,100,100)│\\cr'
		end
	end
	local bar = ('\n'):rep(prefix_lines) .. table.concat(rows, '\n')

	ui.scrollbar:size(FONT_SIZE())
	if bar ~= scrollbar_last_text then
		ui.scrollbar:text(bar)
		scrollbar_last_text = bar
	end

	local bar_w, bar_h = ui.scrollbar:extents()
	local menu_x, menu_y = ui.menu:pos()
	local menu_w = ui.menu:extents()
	-- Right edge of the bar = right edge of the menu content (inside the gutter).
	local bar_x = menu_x + menu_w - PADDING() - bar_w
	local bar_y = menu_y + PADDING()
	ui.scrollbar:pos(bar_x, bar_y)
	ui.scrollbar:show()

	local line_h = bar_h / (prefix_lines + VISIBLE_ROWS)
	scrollbar_geom = {
		x = bar_x,
		w = bar_w,
		top = bar_y + prefix_lines * line_h,	-- y of the first track row
		line_h = line_h,
		thumb_len = thumb_len,
		margin = SCROLLBAR_HIT_MARGIN(),
	}
end

scrollbar_hit = function(mx, my)
	local g = scrollbar_geom
	if not g or not ui.scrollbar:visible() then return false end
	return mx >= g.x - g.margin and mx <= g.x + g.w + g.margin
		and my >= g.top and my <= g.top + g.line_h * VISIBLE_ROWS
end

-- Convert the mouse position into a scroll value (thumb follows the mouse).
scrollbar_set_from_mouse = function(mouse_y)
	local g = scrollbar_geom
	local max_scroll = get_max_scroll()
	if not g or max_scroll <= 0 then return end
	local travel = VISIBLE_ROWS - g.thumb_len
	local thumb_top = (mouse_y - g.top) / g.line_h - scrollbar_grab
	set_scroll(math.floor(thumb_top / travel * max_scroll + 0.5))
end

-- The generic drag code of the texts library must not grab the menu when the
-- click is on the scrollbar (the scrollbar lies on top of the menu).
texts.click_filter = function(mx, my)
	return scrollbar_hit(mx, my)
end

-- Which bg-wiki page (if any) belongs to a row of the current tab.
--   Titles        : titles_links[title name]
--   Other Content : Types of Fishes Caught -> the fish item page, Ergon Locus -> the Ergon Locus page
local wiki_base = 'https://www.bg-wiki.com/ffxi/'
local wiki_sets = {}

local in_log = function(logname, text)
	local log = tab_logs[logname]
	if not log or type(log.items) ~= 'table' then return false end
	local cache = wiki_sets[logname]
	if not cache or cache.src ~= log.items then
		cache = {src = log.items, names = {}}
		for _, it in ipairs(log.items) do cache.names[it.text] = true end
		wiki_sets[logname] = cache
	end
	return cache.names[text] == true
end

local wiki_encode = function(name)
	name = name:gsub(' ', '_')
	return (name:gsub('[^%w_%-%.~,:%(%)]', function(c) return ('%%%02X'):format(c:byte()) end))
end

get_wiki_url = function(item)
	if not item or not item.text or not tabs[active_tab] then return nil end
	local tabname = tabs[active_tab].name
	if tabname == 'Titles' then
		return titles_links and titles_links[item.text] or nil
	elseif tabname == 'Other Content' then
		local sub = (active_subtab > 0) and tabs[active_tab].tabs[active_subtab] or nil
		if (sub == nil or sub == 'fishes') and in_log('fishes', item.text) then
			return wiki_base .. wiki_encode(item.text)
		elseif (sub == nil or sub == 'ergonlocus') and in_log('ergonlocus', item.text) then
			return wiki_base .. 'Ergon_Locus'
		end
	end
	return nil
end

open_wiki_url = function(name, url)
	windower.add_to_chat(160, '[XIchecklist] '..name..' -> '..url)
	if windower.open_url then
		windower.open_url(url)
	else
		windower.copy_to_clipboard(url)
		windower.add_to_chat(160, '[XIchecklist] open_url unavailable: link copied to clipboard')
	end
end

-- Click on a title row -> open its bg-wiki page.
-- If the click lands one row too high/low on your setup, tweak WIKI_CLICK_Y_OFFSET (pixels).
WIKI_CLICK_Y_OFFSET	= 0
WIKI_DEBUG			= false	-- //xic wikidebug toggles it
draw_rows			= {}		-- item shown on each visible row (refreshed every draw)
draw_prefix_lines	= 0		-- number of lines before the first item row
wiki_press			= nil		-- where the left button went down

handle_title_click = function(x, y)
	local _, menu_y = ui.menu:pos()
	local line_h = (scrollbar_geom and scrollbar_geom.line_h) or LINE_HEIGHT()
	local row = math.floor((y - (menu_y + PADDING() + WIKI_CLICK_Y_OFFSET)) / line_h) - draw_prefix_lines + 1
	local item = draw_rows[row]
	if WIKI_DEBUG then windower.add_to_chat(160, ('[wiki] click y=%d row=%d item=%s'):format(y, row, item and tostring(item.text) or 'nil')) end
	local url = item and get_wiki_url(item)
	if url then
		open_wiki_url(item.text, url)
	end
end

draw = function()
	local text = ''
	if ui.width then
		text = text .. '\n'.. '─':rep((PADDING()/CHAR_WIDTH())+(ui.width/(2*CHAR_WIDTH()))) .. '\n'
	else
		text = text .. '\n────────────────────────────────────────────────────────────────\n'
	end
	if subtabs_height > 0 then
		text = text .. ('\n'):rep(subtabs_height/LINE_HEIGHT()-1)
	end
	-- List
	local items = tabs[active_tab].items
	if (trackermenusettings.showcompleted == false) then
		items = items:filter(function(item)
			return item.completed == false
		end)
	end
	local count = items:length()
	if count == 0 then
		-- add active_tab helper text here
		--items = {'\\cs(128,128,128)Change zones to update Quests / Campaigns / Warps / Monstrosity \\cr', '\\cs(128,128,128)Check the README or "//xic help" to register NPC-related data \\cr'}
		items = {util.list_item(nil, '\\cs(128,128,128)Change zones to update Quests / Campaigns / Warps / Monstrosity \\cr \n \\cs(128,128,128)Check the README or "//xic help" to register NPC-related data \\cr')}
		count = 1
	end
	clamp_scroll(count)
	-- number of lines before the first item (the scrollbar needs it to line up)
	local _, prefix_lines = text:gsub('\n', '')
	draw_prefix_lines = prefix_lines
	draw_rows = {}
	for i = 1, VISIBLE_ROWS do
		local idx = i + scroll
		if items[idx] then
			draw_rows[i] = items[idx]
			text = text .. (idx == selected and '\\cs(255,0,0)> ' or '  ') .. format_item(items[idx]) .. '\\cr' .. SCROLLBAR_GUTTER .. '\n'
		end
	end
	ui.menu:text(text)
	ui.menu:pos(trackermenusettings.pos.x, trackermenusettings.pos.y)
	update_scrollbar(count, prefix_lines)
	local menuexextent, menuyextent = ui.menu:extents()
	local showcompletedxextent, showcompletedextent = ui.showcompleted:extents()
	ui.showcompleted:pos(trackermenusettings.pos.x+menuexextent-showcompletedxextent, trackermenusettings.pos.y+menuyextent-showcompletedextent)
	--ui.showcompleted:show()
end

initiate_tabs()

-------------------------------------------------
windower.register_event('prerender', function()
	draw_tabs()
	draw_subtabs()
	draw()
	if not subtabs_drawn then
		coroutine.sleep(0.1)
		subtabs_drawn = true
	end
end)

ui.menu:register_event('drag', function()
	subtabs_drawn = false
	draw_tabs()
	draw_subtabs()
end)

windower.register_event('mouse', function(type, x, y, delta, blocked)
    -- Wiki click detection. Done first and WITHOUT looking at 'blocked': the texts library
    -- (draggable window) consumes the click, so later checks would never see it.
    if ui.menu:visible() then
        if type == 1 then
            wiki_press = ui.menu:hover(x, y) and {x = x, y = y} or nil
            if WIKI_DEBUG then windower.add_to_chat(160, ('[wiki] press %d,%d hover=%s blocked=%s'):format(x, y, tostring(ui.menu:hover(x, y)), tostring(blocked))) end
        elseif type == 2 and wiki_press then
            local p = wiki_press
            wiki_press = nil
            if math.abs(x - p.x) <= 3 and math.abs(y - p.y) <= 3 then
                handle_title_click(x, y)
            end
        end
    end

    if blocked or (ui.menu:visible() == false) then
        if type == 2 then scrollbar_dragging = false end
        return
    end

    local px, py = ui.menu:pos()
    if (px ~= trackermenusettings.pos.x) or (py ~= trackermenusettings.pos.y) then
        trackermenusettings.pos.x = px
        trackermenusettings.pos.y = py
        trackermenusettings:save()
    end

    -- Left button pressed on the scrollbar: grab the thumb, or jump there.
    if type == 1 and scrollbar_hit(x, y) then
        local g = scrollbar_geom
        local max_scroll = get_max_scroll()
        local travel = VISIBLE_ROWS - g.thumb_len
        local thumb_top = scroll / max_scroll * travel
        local rel = (y - g.top) / g.line_h
        if rel >= thumb_top and rel <= thumb_top + g.thumb_len then
            scrollbar_grab = rel - thumb_top		-- keep the grab point under the cursor
        else
            scrollbar_grab = g.thumb_len / 2		-- click on the track: centre the thumb there
        end
        scrollbar_dragging = true
        scrollbar_set_from_mouse(y)
        return true
    end

    -- Mouse moved while dragging the thumb.
    if type == 0 and scrollbar_dragging then
        scrollbar_set_from_mouse(y)
        return true
    end

    -- Left button released.
    if type == 2 and scrollbar_dragging then
        scrollbar_dragging = false
        return true
    end

    -- Mouse wheel over the menu.
    if type == 10 and get_max_scroll() > 0 and ui.menu:hover(x, y) then
        local direction = (delta > 0) and -1 or 1			-- wheel up = list up
        if SCROLLBAR_WHEEL_INVERT then direction = -direction end
        set_scroll(scroll + direction * SCROLLBAR_WHEEL_STEP)
        return true
    end
end)
