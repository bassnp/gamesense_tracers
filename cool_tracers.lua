local vector = require "vector"
local mp = {"LUA", "B"}

--[[
    Cool bullet tracers, kinda looks like starwars
    https://streamable.com/gkl76m

    Credits: Bassn / bass / hitome56 / uid2515 / not.bass#3945 / big boy paster

    This script is a part of the gamesense framework utilizing the gamesensesical application programming interface created by estk (admin of gamesense.pub) he is also our creator.
    https://gamesense.pub/

    This script is licensed under the MIT license.
    This script is not to be distributed, published, or reproduced in any way without the explicit permission of the author.
    This script should be used in conjunction with the gamesense framework.
    This script will not be used to circumvent the framework.
    This script is not allowed to be used to gain an unfair advantage over the framework.
    This script is is withen and not allowed to be used outside of the framework.

    Any usage of this script is at the user's own risk.

    If you have any questions or concerns about this script, please contact the author.

	-- Generated by GitHub Copilot
]] 

local contains = function(b,c)for d=1,#b do if b[d]==c then return true end end;return false end
local table_visible = function(a,b)for c,d in pairs(a)do if type(a[c])=='table'then for e,d in pairs(a[c])do ui.set_visible(a[c][e],b)end else ui.set_visible(a[c],b)end end end

local tracer = {
	enabled = ui.new_checkbox(mp[1], mp[2], "> Enable Tracers"),
	label   = ui.new_label(mp[1], mp[2], "programered from not.bass#3945"),
	speed   = ui.new_slider  (mp[1], mp[2], "Speed", 1, 25, 15),

	line_size  = ui.new_slider(mp[1], mp[2],       "Line Size",    1, 50,   35, true, "", 1, {[1] = "Off"}),
	line_color = ui.new_color_picker(mp[1], mp[2], "Line Color", 55, 255, 25, 255),

	dot_size  = ui.new_slider(mp[1], mp[2],       "Dot Size",    0,   3,   1, true, "", 1, {[0] = "Off"}),
	dot_color = ui.new_color_picker(mp[1], mp[2], "Dot Color", 255, 255, 255, 175),
}

local shot_list = {}
local function paint()
	local enabled = ui.get(tracer.enabled)
	if #shot_list > 0 then
		for i = 1, #shot_list do
			if shot_list[i] ~= nil then
				shot = shot_list[i]
				if shot.final:dist(shot.pos) > shot.final:dist(shot.start) then
					table.remove(shot_list, i)
					i = i - 1
				else
					local speed = ui.get(tracer.speed)
					local distance_adjustment = 1 / shot.final:dist(shot.start)
					local direction = (shot.slope / 100) * (distance_adjustment * (speed * 500))

					shot.pos = shot.pos + direction
					local x1, y1 = renderer.world_to_screen(shot.pos:unpack())
					
					if ui.get(tracer.line_size) ~= 1 then
						local size = direction * (ui.get(tracer.line_size) / speed)
						local back = shot.pos - size

						if shot.pos:dist(shot.start) < shot.pos:dist(back) then	
							back = shot.start
						end

						local x2, y2 = renderer.world_to_screen(back:unpack())	
						local clr = {ui.get(tracer.line_color)}
						renderer.line(x1, y1, x2, y2, clr[1], clr[2], clr[3], clr[4])
					end
					if ui.get(tracer.dot_size) ~= 0 then
						local size = ui.get(tracer.dot_size)
						local clr = {ui.get(tracer.dot_color)}
						renderer.circle(x1, y1, clr[1], clr[2], clr[3], clr[4], size + 1, 0, 1)
					end
				end
			end
		end
	end
end

local function bullet_impact(data)
	if client.userid_to_entindex(data.userid) == entity.get_local_player() then
		local _final = vector(data.x, data.y, data.z)
		local _start = vector(client.eye_position())
		local _slope = _final - _start
		table.insert(shot_list, {
			final = _final, 
			start = _start, 
			slope = _slope,
			pos = _start,
		})
	end
end

local function handle_ui()
	local enabled = ui.get(tracer.enabled)
	table_visible({tracer.speed, tracer.line_size, tracer.line_color, tracer.dot_size, tracer.dot_color}, enabled)
end
handle_ui()

local handle_callback = function(event, callback, set)
	local set_callback = set and client.set_event_callback or client.unset_event_callback
	set_callback(event, callback)
end

-- I hate being proper and clean  >:(
ui.set_callback(tracer.enabled, function()
	local enabled = ui.get(tracer.enabled)
	handle_callback("paint",         paint,         enabled)
	handle_callback("paint_ui",      handle_ui,     enabled)
	handle_callback("bullet_impact", bullet_impact, enabled)
	handle_ui()
end)
