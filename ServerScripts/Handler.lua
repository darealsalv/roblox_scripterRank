local playersCooldowns = {}
local absModule = require(game.ReplicatedStorage.Modules.Abilities)

game.ReplicatedStorage.Events.Ability.OnServerEvent:Connect(function(plr, passedChar, ability, extraInfo)
	for i, Table in playersCooldowns do
		if Table[1] == plr and Table[2] == ability then return end
	end

	local infoToInsert = {
		plr,
		ability
	}

	table.insert(playersCooldowns, infoToInsert)

	task.spawn(function()
		task.wait(ability.Cooldown)
		table.remove(playersCooldowns, table.find(playersCooldowns, infoToInsert))
	end)

	local abilityTable

	for i, char in absModule.Abilities do
		if i == passedChar then

			for ii, abilityTable in char do
				if ii == ability then
					abilityTable.ServerFunction(ability, extraInfo)
					break
				end
			end

			break
		end
	end
end)

game.ReplicatedStorage.Events.ChangeCharacter.OnServerEvent:Connect(function(plr, charRequested)
	-- can add check to see if player owns character or if player has perms to custom set their char

	if absModule.Abilities[charRequested] then
		game.ReplicatedStorage.Events.ChangeCharacter:FireClient(plr, charRequested)
	end
end)
