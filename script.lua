if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local requests = http_request or request
local inventory = game:GetService("ReplicatedStorage").Remotes.GetInventory:InvokeServer()
local plr = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

getgenv().data = {
    Username = plr.Name, 
    units = {}, 
    Story = "",
    Level = 0,
    Trait_Crystal = 0,
    first_gem = nil,
    risky_dice = 0,
    last_gem = 0,
    time = 0,
    Status = "Lobby",
}

function getunits() 
    local a = {}
    for i,v in pairs(inventory.Units) do
        table.insert(a, v.Type)
    end
    return a
end

function getinfomap()
    local a = 0
    for i,v in pairs(inventory.Chapters) do
        if v.Unlocked == true and i ~= "FooshaVillage_Infinite" and string.find(tostring(i), "FooshaVillage") then
            a = a + 1
        end
    end
    return a
end

while true do 
    wait(5)
    local a,b = pcall(function()
        getgenv().data.units = getunits()
        getgenv().data.Story = getinfomap() .. "/6"
        getgenv().data.Level = inventory.Level
        getgenv().data.time = getgenv().data.time + 1
        
        if getgenv().data.first_gem == nil then
            getgenv().data.first_gem = inventory.Currencies.Gems
        else
            getgenv().data.first_gem = inventory.Currencies.Gems
        end
        
        if getgenv().data.first_gem > getgenv().data.last_gem then
            getgenv().data.first_gem = getgenv().data.last_gem
        end
        
        getgenv().data.last_gem = inventory.Currencies.Gems
        
        if inventory.Items["Trait Crystal"] == nil then
            getgenv().data.Trait_Crystal = 0
        else
            getgenv().data.Trait_Crystal = inventory.Items["Trait Crystal"]
        end  -- Ensure the correct closing of 'if' block

        if inventory.Items["Risky Dice"] == nil then
            getgenv().data.risky_dice = 0
        else
            getgenv().data.risky_dice = inventory.Items["Risky Dice"]
        end  -- Added missing 'end' here

        if game.PlaceId == 17764698696 then
            getgenv().data.Status = "Lobby"
        else
            getgenv().data.Status = "In Game"
        end

        local aa = requests({
            Url = "103.176.24.132:2008",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(getgenv().data)
        })
        print(aa.StatusCode, aa.StatusMessage )
        print(aa.Body)
        writefile(plr.Name..".json", game:GetService("HttpService"):JSONEncode(getgenv().data))
    end)
    print(a, b)
end
