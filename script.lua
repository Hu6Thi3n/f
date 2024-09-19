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

local function sendMessageToServer(data)
    local Url = 'http://103.176.24.132:2008/sendMessage'
    
    local jsonData = HttpService:JSONEncode(data)  -- Convert Lua table to JSON

    local Response = requests {
        Method = 'POST',
        Url = Url,
        Headers = {
            ['Content-Type'] = 'application/json',  -- Set the content type to JSON
        },
        Body = jsonData,  -- Send the JSON data
    }

    print("Server Response Status: " .. Response.StatusCode)
    if Response.StatusCode ~= 200 then 
        print("Failed to send the message. Server responded with: " .. Response.Body)
        return false 
    end

    print("Message sent successfully!")
    return Response.Body
end

while true do 
    wait(5)
    local success, err = pcall(function()
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
        
        getgenv().data.Trait_Crystal = inventory.Items["Trait Crystal"] or 0
        getgenv().data.risky_dice = inventory.Items["Risky Dice"] or 0
        
        if game.PlaceId == 17764698696 then
            getgenv().data.Status = "Lobby"
        else
            getgenv().data.Status = "In Game"
        end

        sendMessageToServer(getgenv().data)  -- Gửi dữ liệu đến máy chủ

        writefile(plr.Name..".json", HttpService:JSONEncode(getgenv().data))
    end)
    print(success, err)
end
