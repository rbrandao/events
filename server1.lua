--[[
	PUC-RIO
	INF2545 - Sistemas Distribuídos 
	
	1 - Servidor Interativo
	Server1.lua

	arg[1] = porta do servidor
	arg[2] = arquivo servido
]]--



socket = require("socket")

local server = assert(socket.bind("*",arg[1]))



print("Servidor1: Executando na porta " .. arg[1])

while true do

	local client = server:accept()
	local ip_d,port_d = client:getpeername()
	print ( "Servidor1: Conexao estabelecida "..ip_d.."  "..port_d ) 
	local incomingFile = assert(io.open(arg[2], "rb"))
	
	local i = client:send( incomingFile:read('*all') )
	
		
	print ( "Servidor1: Conexao finalizada "..ip_d.."  "..port_d ) 
	client:close()

	incomingFile:close()
	

end

print("Servidor1: Tchau!")
