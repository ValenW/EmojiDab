local myUserDefault = cc.UserDefault:getInstance()

if not myUserDefault:getBoolForKey("nofirst") then
    myUserDefault:setBoolForKey("nofirst", true)
    myUserDefault:setIntegerForKey("firstGame", 1)
    myUserDefault:setIntegerForKey("level", 1)
    myUserDefault:setIntegerForKey("exp", 0)
    myUserDefault:setIntegerForKey("coin", 200)
    myUserDefault:setIntegerForKey("best", 0)
    
    myUserDefault:setIntegerForKey("theme", 1)
    myUserDefault:setIntegerForKey("head", 1)
    myUserDefault:setIntegerForKey("lock", 1)
    myUserDefault:setIntegerForKey("music", 1)
    
    myUserDefault:setIntegerForKey("skin1", 1)
    for i = 2, 8 do
        myUserDefault:setIntegerForKey("skin"..i, 0)
    end
    for i = 1, 8 do
        myUserDefault:setIntegerForKey("best"..i, 0)
    end
end

local MyConfig = class("MyConfig")

MyConfig.iurl = "https://itunes.apple.com/app/id1138608200"
MyConfig.aurl = "https://play.google.com/store/apps/details?id=org.skydomain.emojidab"
MyConfig.shareWord = "I've got %d points in Emoji Dab! Can anyone dab further than me?"

MyConfig.themeNum = 8
MyConfig.coinPerChange = 50
MyConfig.coinPerSkin = 300
MyConfig.coinPerAD = 100
MyConfig.skinLvs = {0, 1, 1, 1, 1, 1, 2, 2}
MyConfig.skinPer = { {300, 99}, {1000, 199} }

MyConfig.productID = {
    c300 = "org.skydomain.emojidab.c300",
    allskins = "org.skydomain.emojidab.allskins",
    noad = "org.skydomain.emojidab.noad",
    s1 = "org.skydomain.emojidab.s1",
    s2 = "org.skydomain.emojidab.s2",
    s3 = "org.skydomain.emojidab.s3",
    s4 = "org.skydomain.emojidab.s4",
    s5 = "org.skydomain.emojidab.s5",
    s6 = "org.skydomain.emojidab.s6",
    s7 = "org.skydomain.emojidab.s7"
}

MyConfig.maxLevel = 7
MyConfig.Mask = {
    width = 5,
    height = 5
}
MyConfig.Puts = {}
MyConfig.Puts.types = { {{0, 0}}, {{0, 1}, {0, 0}}, {{0, 0}, {1, 0}} }
MyConfig.userfile = myUserDefault

MyConfig.userfile.get = function (key)
	return myUserDefault:getIntegerForKey(key)
end

MyConfig.userfile.set = function (key, value)
    myUserDefault:setIntegerForKey(key, value)
    myUserDefault:flush()
end

MyConfig.userfile.add = function (key, added)
	local before = MyConfig.userfile.get(key)
	MyConfig.userfile.set(key, before + added)
end

return MyConfig
