-- ShardCapPlus.lua
SHARDCAPPLUS_CAP_VALUE=12;
SHARDCAPPLUS_SPAM=false; 

function delShards(cap)
    local total_shards = 0
    -- Calculate total number of Soul Shards across all bags
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if shardTest(bag, slot) then
                local _, itemCount = GetContainerItemInfo(bag, slot)
                total_shards = total_shards + itemCount
            end
        end
    end

    -- Display total shards found if spam is enabled
    if SHARDCAPPLUS_SPAM == true then
        DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Total [Soul Shard] found: " .. total_shards)
    end

    -- Delete shards if total exceeds the cap
    if total_shards > cap then
        local done = false
        for bag = 0, 4 do
            if done then break end
            for slot = 1, GetContainerNumSlots(bag) do
                if done then break end
                if shardTest(bag, slot) then
                    local _, itemCount = GetContainerItemInfo(bag, slot)
                    if SHARDCAPPLUS_SPAM == true then
                        DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Deleting " .. GetContainerItemLink(bag, slot) .. " with " .. itemCount .. " shards from bag: " .. bag .. " slot: " .. slot)
                    end
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                    total_shards = total_shards - itemCount
                    if total_shards <= cap then
                        done = true
                    end
                end
            end
        end
    end
end

function shardTest(b, s)
	-- Soul Shards have itemID = 6265
	local shardID = 6265;
	
	-- GetContainerItemLink returns a long string, where the item's ID is part of the string. 
	-- Returns "nil" if empty bag slot, which we don't like, since we save it to local itemLink 
	-- So we have to handle that
	local itemLink
	
	if GetContainerItemLink(b,s) == nil then
		itemLink = 'noitem'
	else
		itemLink = GetContainerItemLink(b,s)
	end 
		
	-- Test if a given item is a shard with LUA's string.find(x,y) function.
	if string.find(itemLink, shardID) then
		--DEFAULT_CHAT_FRAME:AddMessage("------> Is shard: " .. itemLink .. "<------")
		return true
	else
		--DEFAULT_CHAT_FRAME:AddMessage("Not shard: " .. itemLink)
		return false
	end
end

-- Events to listen for:
local f = CreateFrame'Frame'
f:RegisterEvent'BAG_UPDATE'
f:RegisterEvent'PLAYER_REGEN_ENABLED'

-- Check if something is in the bags and check if player exited combat.
local combat, bag = nil, nil
f:SetScript('OnEvent', function()
	-- DEFAULT_CHAT_FRAME:AddMessage("registered")
	if event == "BAG_UPDATE" then
		bag = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		combat = true
	end

	if bag and combat then
		bag, combat = nil, nil
		delShards(SHARDCAPPLUS_CAP_VALUE);
	end
end)

function ShardCapPlus_IsInteger(n)
	-- Returns true if n is an integer.
	if tonumber(n) ~= math.floor(tonumber(n)) then
		return false
	else
		return true
	end
end

function ShardCapPlus_PrintCap()
	-- Correct spelling of shard/shards in case the user sets the cap to 1.
	-- xD smiley face.
	str = "ShardCapPlus - Current cap is "..SHARDCAPPLUS_CAP_VALUE.." shard";
	if SHARDCAPPLUS_CAP_VALUE ~= 1 then 
		str = str.."s"
	end 
	DEFAULT_CHAT_FRAME:AddMessage(str..".");
end

function ShardCapPlus_PrintInfo()
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Change cap: /shardcapplus <number> ... For example: /shardcapplus 5");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Show cap: /shardcapplus");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Notifications: /shardcapplus spam");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Manual delete: /shardcapplus delete");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Deletes when you exit combat. Deletes from backpack first. Put your soulbag in your last bag slot, like a normal person. Cheers.");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Website: www.github.com/dogmax/ShardCapPlus");
end

function ShardCapPlus_ToggleSpam()
	local msg ="ShardCapPlus - Notifications ";

	if SHARDCAPPLUS_SPAM == true then 
		SHARDCAPPLUS_SPAM = false; 
		msg = msg.."disabled."; 
	else 
		SHARDCAPPLUS_SPAM = true; 
		msg = msg.."enabled.";
	end 
	DEFAULT_CHAT_FRAME:AddMessage(msg.." To change it: /shardcapplus spam");
end

function ShardCapPlus(parameter) 
	if parameter == '' then
		ShardCapPlus_PrintCap();
		DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - Change cap: /shardcapplus <number> ... For example: /shardcapplus 5");
		DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - More information type: /shardcapplus info");
	end

	if parameter == "info" then
		DEFAULT_CHAT_FRAME:AddMessage("--- --- --- --- --- ---");
		ShardCapPlus_PrintInfo();
	end
	
	-- toggle spam 
	if parameter == "spam" then
		ShardCapPlus_ToggleSpam();
	end 
	
	-- check if parameter is a number (this if clause seems weird, but it's not)
	if type(tonumber(parameter)) == "number" then
		-- If parameter is a number, check for integer
		if ShardCapPlus_IsInteger(parameter) then
			-- If it IS an integer, we set the new value for SHARDCAPPLUS_CAP_VALUE..., account for negative numbers. 
			SHARDCAPPLUS_CAP_VALUE = math.abs(parameter); 
			ShardCapPlus_PrintCap();
		else 
			-- If it is NOT and integer, we tell them to type /shardcapplus info for more information or something... 
			DEFAULT_CHAT_FRAME:AddMessage("ShardCapPlus - You must use an integer for example 1 or 5 or 28.");
		end 
	end
	
	if parameter == "delete" then
		delShards(SHARDCAPPLUS_CAP_VALUE)
	end
end

SLASH_SHARDCAPPLUS1 = '/shardcapplus'
SlashCmdList["SHARDCAPPLUS"] = ShardCapPlus