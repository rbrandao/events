--declaração local dos módulos que queremos ter acesso
local socket, dofile, ipairs, next, pairs, string, tonumber, tostring, unpack, gmatch, find, table, print, io, setmetatable, select, assert =
      require("socket"), dofile, ipairs, next, pairs, string, tonumber, tostring, unpack, gmatch, find, table, print, io, setmetatable, select, assert


--definição do modulo events
module(..., package.seeall);

----------------------------------
-- funções "públicas" do módulo --
----------------------------------

------------------------------------------------------------------
-- ev.loop()
--
-- Coloca processo em a de espera por mensagens
------------------------------------------------------------------
function ev.loop()

end

------------------------------------------------------------------
-- ev.send(dest, message, cb)
--
-- Envia mensagem a destinatário
--
-- Parâmetros:
-- dest: endereço do destinatário
-- message: string de caracteres com um trecho de código Lua que é executado pelo destinatário
-- cb: função invocada depois que envio é completado
------------------------------------------------------------------
function ev.send(dest, message, cb)

end



------------------------------------------------------------------
-- ev.id()
--
-- Recupera o identificador do processo
--
-- Retorno: string que pode ser usada por outro processo para enviar msg a ele
------------------------------------------------------------------

function ev.id()

end
