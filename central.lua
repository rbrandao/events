-- load namespace
local socket = require("socket")

-- Recupera host e porta do arquivo de propriedades
local f = assert(io.open('ev.properties', "r"))
local str = f:read("*all")
f:close()
for key,value in string.gmatch(str, "(%w+)%s*=%s*(%w+[^\n]*)") do 
	if key == "host" then
		centralHost = value
	elseif key == "port" then
		centralPort = value
	end
end

-- Cria socke TCP
local server = assert(socket.bind(centralHost, centralPort))
local ip, port = server:getsockname()

local agents = { }

print("Nó central em execução na porta: " .. ip .. ":" .. port .. "\n")

-- Fica em loop aguardando requisicoes
while 1 do
	-- Bloqueia a espera de clientes
	local client = server:accept()

	-- Recebe requisicoes
	local line, err = client:receive('*l')
	
	print("\nAtendendo cliente: " .. client:getsockname() .. " CMD=" .. line)


	if not err then
		if line == "getAgents" then

			-- Envia lista de agentes
			for i=1,#agents do
				client:send(agents[i] .. "\n")
			end

		elseif line == "delAgent" then
			-- Recebe identificador do agente a ser removido
			local line, err = client:receive('*l')
			for i=1,#agents do
				if agents[i] == line then
					
					table.remove(agents,i)
				end
			end

			print("Removendo agente: " .. line)

		elseif line == "addAgent" then
			-- Recebe identificador do novo agente
			local line, err = client:receive('*l')
			table.insert(agents, line)

			print("Adicionando novo agente: " .. line)
		end
	else
		print("Erro ao receber requisição: " .. err)
	end

	-- Fecha socket do cliente
	client:close()

	-- Imprime tabela de agentes
	print("Agentes ativos:")
	table.foreach(agents,print)
end
