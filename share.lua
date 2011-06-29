require "ev"
-- inicia servico

local ip = ev.init(arg[3])

local nickName = arg[2]

files = {}

function startserver(fileName,ip_id,port_id)
	
	local client = socket.connect(ip_id, port_id)


	local ip_d,port_d = client:getpeername()
	print ( ev.id() ..": Conexao estabelecida "..ip_d..":"..port_d ) 
	local incomingFile = assert(io.open(fileName, "rb"))
	
	print(client:send( incomingFile:read('*all') ))
	
		
	print ( "Conexao finalizada "..ip_d..":"..port_d ) 
	client:close()

	incomingFile:close()

end

function plugclient(fileName)

	server = assert(socket.bind(ip,arg[3]+1))
	
	local client = server:accept()
		
	--arquivo que será baixado
	local downloadFile = assert(io.open(fileName..".download", "wb"))

	if client~=nil then
	
			local s,err,partial=client:receive('*a')
			--local s,err=client:receive('*a')
			if s==nil then
				if partial and #partial>0 then
					downloadFile:write(partial)
				end

				if err == 'closed' then
					--print('Cliente ' .. arg[4] .. ', Arquivo transferido: ' .. arg[3])
				else
					print('Cliente ' .. ev.id() .. ', Erro recebendo arquivo: '..err)
				end
		
			end

		downloadFile:write(s)
		
		client:close()

		downloadFile:close()
	
	end
	server:close()
end

if ( arg[1] == "S" )then
	
	socket = require("socket")

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
			index = string.find(param,"@")

			file_toget = string.sub(param,1,index-1)
			
			id_server = string.sub(param,index+1,-1)
			
			index = string.find(id_server,":") -- separa porta de ip

			ip_server = string.sub(id_server,1,index-1)
			
			port_server = string.sub(id_server,index+1,-1)
			
			ev.send(ip..":".. arg[3]+1 ,"plugclient(\'".. file_toget .."\')" )
			--os.execute("sleep 4")
	
			ev.send(id_server,"startserver(\'".. file_toget .."\',\'".. ip .."\',\'"..arg[3]+2 .."\')")		
									
		end
	
	elseif cmd == "exit" then
		
		ev.send("all","print(\"*["..ip..":"..arg[3]+1 .."] is offline  \")")
		ev.send(ip..":"..arg[3]+1,"ev.removeAgent()")
		ev.send(ip..":"..arg[3]+1,"os.exit(1)")
		ev.removeAgent()
		os.exit(1)
	end
			

end




