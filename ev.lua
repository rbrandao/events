-- Declaração local dos módulos que queremos ter acesso
local socket, dofile, ipairs, next, pairs, string, tonumber, tostring, unpack, gmatch, find, table, io, setmetatable, select, assert, os =
      require("socket"), dofile, ipairs, next, pairs, string, tonumber, tostring, unpack, gmatch, find, table, io, setmetatable, select, assert, os

-- Definição do modulo events
module(..., package.seeall);

-- Socket do servidor e identificador do agente
local server 		= nil
local myID 		= nil
local debug = false

-- Endereço (host e porta) do nó central
local centralHost	= nil
local centralPort	= nil

-- Lista de agentes ativos
local agents		= { }

----------------------------------
-- funções "públicas" do módulo --
----------------------------------

------------------------------------------------------------------
-- ev.send(dest, message, cb)
--
-- Envia mensagem a destinatário
--
-- Parâmetros:
-- dest: endereço do destinatário. Assim como a API aLua o destino pode ser a string "all"
-- message: string de caracteres com um trecho de código Lua que é executado pelo destinatário
-- cb: função invocada depois que envio é completado
------------------------------------------------------------------
function ev.send(dest, message, cb)
	logger("Enviando mensagem para \"" .. dest .. "\"")

	-- Parsing do destino (host:port)
	if dest ~= "all" then
		local index =  string.find(dest,":")
		local host,port
		if index then
			host = string.sub(dest,1, index-1)
			port = string.sub(dest,index+1,#dest)
		end
		
		-- Conecta no host destino
		local sock = assert(socket.connect(host,port))

		-- Envia mensagem
		ret,err = sock:send(message.."\n")

		if err then
			logger("Erro ao enviar chunk!")
			sock:close()

			return
		end
			
		sock:close()

	elseif dest == "all" then
		-- Enviar mensagem para TODOS os agentes
		retrieveAgents()

		for i=1,#agents do
			-- Descarta o envio para este agente
			if agents[i] ~= myID then
	
				logger("Enviando mensagem para \"" .. agents[i] .. "\"")

				local index =  string.find(agents[i],":")
				local host,port
				if index then
					host = string.sub(agents[i],1, index-1)
					port = string.sub(agents[i],index+1,#agents[i])
				end

				-- Conecta no host destino
				local sock = assert(socket.connect(host,port))
				
				-- Envia mensagem
				ret,err = sock:send(message.."\n")

				if err then
					logger("Erro ao enviar chunk para " .. host .. ":" .. port)
					sock:close()

					return
				end
		
				sock:close()
			end
		end
	end

	-- Chama callback notificando o envio da mensagem
	if cb then
		cb()
	end
end


------------------------------------------------------------------
-- ev.loop()
--
-- Coloca processo em espera por mensagens
------------------------------------------------------------------
function ev.loop()

	-- Publica-se no nó central
	publishAgent()

	while true do
		logger('Aguardando mensagens')

		-- Bloqueia a espera de uma conexao
		local client = server:accept()
		-- Recebe a mensagem
		local msg, err = client:receive('*a')
		
		-- Se nao houve erro executa o codigo
		if not err then
			logger("Executando chunk recebido")

			-- Executa chunk recebido
			f, err = loadstring(msg)

			if not f then
				logger("Erro ao compilar \'chunk\' de " .. client:getsockname() .. ": " .. "\""..err.."\"")
				print("[CHUNK]:\n" .. msg)
			else
				local ret, err = pcall(f)

				if not ret then
					logger("Erro ao executar \'chunk\' de " .. client:getsockname() .. ": " .. "\""..err.."\"")
					print("[CHUNK]:\n" .. msg)
				end
			end

		else
			logger("Erro ao receber mensagem de " .. client:getsockname() .. ": " .. err)
		end
		
		-- Fecha o cliente
		client:close()
	end
end


------------------------------------------------------------------
-- ev.id()
--
-- Recupera o identificador do processo
--
-- Retorno: string que pode ser usada por outro processo para enviar msg a ele
------------------------------------------------------------------
function ev.id()
	return myID
end

------------------------------------------------------------------
-- ev.getAgents()
--
-- Recupera a lista de agentes ativos neste momento
--
-- Retorno: tabela com a lista dos nós registrados no nó central
------------------------------------------------------------------
function ev.getAgents()
	retrieveAgents()
	return agents
end



------------------------------------
-- funções "auxiliares" do módulo --
------------------------------------

------------------------------------------------------------------
-- logger()
--
-- Imprime as mensagens de output concatenadas com o ID do agente
------------------------------------------------------------------
function logger(s)
	if ( debug ) then 
		print('[' .. myID .. '] ' ..  s)
	end 
end

------------------------------------------------------------------
-- publishAgent()
--
-- Pública este agente no nó central. Outros agentes podem recuperar
-- a lista de agentes para envio de chunks
------------------------------------------------------------------
function publishAgent()
	logger("Publicando agente no nó central")
	local sock = assert(socket.connect(centralHost,centralPort))

	-- Envia mensagem
	ret,err = sock:send("addAgent\n")

	if not err then
		ret, err = sock:send(myID .. "\n")
	end

	if err ~= nil then
		logger("Erro ao publicar agente no nó central: " .. err)
		os.exit(1)
	end
	
	logger("Publicação bem sucedida")
end

------------------------------------------------------------------
-- removeAgent()
--
-- Remove este agente do nó central.
------------------------------------------------------------------
function removeAgent()
	logger("Removendo agente do nó central")
	local sock = assert(socket.connect(centralHost,centralPort))

	-- Envia mensagem
	ret,err = sock:send("delAgent\n")

	if not err then
		ret, err = sock:send(myID .. "\n")
	end

	if err ~= nil then
		logger("Erro ao remover agente do nó central: " .. err)
		os.exit(1)
	end
	
	logger("Remoção bem sucedida")
end


------------------------------------------------------------------
-- retrieveAgents()
--
-- Recupera a lista de agentes ativos do nó central.
------------------------------------------------------------------
function retrieveAgents()
	logger("Recuperando lista de agentes do nó central")
	local sock = assert(socket.connect(centralHost,centralPort))

	-- Envia requisição
	ret,err = sock:send("getAgents\n")

	if err then
		logger("Erro ao recuperar lista de agentes do nó central: " .. err)
		os.exit(1)
	end

	agents = {}

	while not err do
		local agent
		agent, err = sock:receive('*l')

		if not err and agent then
			-- Adiciona o agente se não for ele mesmo
			if agent ~= myID then
				logger("Adicionando agente na lista: " .. agent)
				table.insert(agents, agent)
			end
		end
	end

	if err ~= nil and err~='closed' then
		logger("Erro ao recuperar lista de agentes do nó central: " .. err)
		os.exit(1)
	end
	
	logger("Recuperação bem sucedida")

end

------------------------------------------------------------------
-- init()
--
-- Função local para inicialização do agente. A inicialização 
-- consiste em: 
-- 1) abertura do socket servidor para recebimento das mensagens (com a recuperação do IP da interface de rede)
-- 2) criação do identificador do agente (na forma "IP:PORTA")
-- 3) publicação do agente no nó central
------------------------------------------------------------------
function init(port_l) 
	-- Recupera IP da interface de rede (código dependente de plataforma)
	os.execute('ifconfig | grep -v \'127.0.0.1\' | grep -i \"inet \" | awk {\'print $2\'} | cut -d: -f2 > /tmp/evtmp ')
	local f = assert(io.open('/tmp/evtmp', "r"))
	local ip = f:read("*all")
	f:close()
	
	-- Abre socket local
	server = assert(socket.bind(ip	, port_l))
	local ip, port = server:getsockname()
	--ip = socket.dns.toip(socket.dns.gethostname())

	-- Seta flag tcp-nodelay no socket
	server:setoption("tcp-nodelay", true)

	-- Identificador do agente
	myID = ip .. ':' .. port

	logger("Iniciando agente...")

	-- Recupera host e porta do nó central
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

	logger("Agente inicializado!")
	return ip,port
end


