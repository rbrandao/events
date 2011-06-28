require "ev"

-- Funções de callback que serão chamadas após envio
function func1()
	print("Callback1 chamada!")
end

function func2()
	print("Callback2 chamada!")
end


-- Tabela com todos os agentes ativos no momento
local agents = ev.getAgents()

-- Identificador deste agente
local myID = ev.id()

-- Verifica se existem outros agentes ativos
if #agents == 0 then
	print("Não há agentes disponíveis!")
	os.exit(1)
end

-- Testa envio para todos os agentes
--ev.send("all", "print(\"hello world!\")", func1)

-- Testa envio apenas para o primeiro agente da lista
--ev.send(agents[1], "n = 50", func2)
--ev.send(agents[1], "print(string.format(\"meuID=%s n=%d\", ev.id(),n))", func2)
--ev.send(agents[1], "ev.send(\""..myID.."\", 'print('teste')')")

prog = [[

msg="teste1"

ev.send("all", string.format("print('%s: %s')", ev.id(), msg))

]]

ev.send(agents[1], prog, func2)
ev.send(agents[1], "ev.send('all', 'print(ev.id() .. \": teste 2\")')", func2)




