require "ev"
-- inicia servico

local ip = ev.init(arg[3])

local nickName = arg[2]

files = {}

if ( arg[1] == "S" )then
	--se for servidor entao escute as mensagens
	ev.loop()
end



-- anuncia a chegada de um novo usuario à sala
ev.send("all","print(\"*["..ip..":"..arg[3]+1 .."] is online  \")")

while (true) do

	io.write("#")
	local line = io.read()

	local cmd,param = string.match(line,"(.+)%s(.*)")
	
	if cmd == "publish" then
		ev.send(ip..":"..arg[3]+1,"table.insert(files,{ path=\'"..param.."\'})")
		ev.send("all","print(\'\\n* "..param.."\'..\'  @  "..ip..":"..arg[3]+1 .. "\')")		
	elseif cmd == "get" then
		if (param == "list") then
			ev.send("all","for i=1,#files do ev.send(\'"..ip..":".. arg[3]+1 .. "\',\'print(\"\'.. files[i].path ..\'@\'.. ev.id() ..\'\")\') end")
		else
			local index = string.find(line,"@")			
			--ev.send(ip..":"..arg[3]+1,"")
			print(index)
					
		end
	
	elseif cmd == "exit" then
		ev.send("all","print(\"*["..ip..":"..arg[3]+1 .."] is offline  \")")
		ev.send(ip..":"..arg[3]+1,"ev.removeAgent()")
		ev.send(ip..":"..arg[3]+1,"os.exit(1)")
		ev.removeAgent()
		os.exit(1)
	end
			

end




