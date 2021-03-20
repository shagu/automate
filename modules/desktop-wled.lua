Subscribe("openwrt/device-tracker", function(payload, cache)
  if payload and payload.online then
    local state=nil
  
    -- check for hostname "odin"
    for id, data in pairs(payload.online) do
      for ip, meta in pairs(data) do
        if meta.name == "odin" then
          state = true
        end
      end
    end
    
    if state ~= cache.state then
      cache.state = state
      
      if state then
        Publish("wled/gästezimmer", 100)
        print("Turn WLED: ON")
      else
        Publish("wled/gästezimmer", 0)
        print("Turn WLED: OFF")
      end 
    end
  end
end)
