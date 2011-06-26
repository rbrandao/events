require "ev"
-- inicia servico

local ip = ev.init(arg[3])

local nickName = arg[2]

if ( arg[1] == "S" )then
	--se for servidor entao escute as mensagens
	ev.loop()
end

-- anuncia a chegada de um novo usuario à sala
ev.send("all","print(\"*["..ip..":"..arg[3]+1 .."]"..nickName.." has joined the room  \")")

while (1) do
	--lê mensagem do usuario
	local msg = io.read()

	--ve se a mensagem é um comando
	local i,j = string.find(msg,"#")
	--se for um comando
	if ( i==j and i == 1 ) then
		local cmd = string.sub(msg,2,-1)
		--se for o comando exit, então saia
		local k,l = string.find(cmd,"exit")
		if ( k == 1 and l==4 ) then
			-- anuncia a saída
			ev.removeAgent()
			ev.send("all","print(\"*["..ip..":"..arg[3]+1 .."]"..nickName.." has left the room  \")")
			os.exit(1)		
		end
		-- se for um comando de mensagem direcionada então recebe o destinatário e a mensagem
		local dest,x_msg = string.match(cmd,"(.+)\"(.+)\"")
		--envia a msg exclusiva
		ev.send(dest,"print(\"*["..ip..":"..arg[3]+1 .."]"..nickName.." says only to you : ".. x_msg.. "\")")
	else 
		-- envia a mensagem em broadcast
		ev.send("all","print(\"*["..ip..":"..arg[3]+1 .."]"..nickName.." says: ".. msg.. "\")")
	end	 	
	

end
