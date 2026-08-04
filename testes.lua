setDefaultTab("Others")

UI.Label("===== TESTE STORAGE =====")

storage.testeStorage = storage.testeStorage or "PADRAO"

addTextEdit("Teste Storage", storage.testeStorage, function(widget, text)
    storage.testeStorage = text
end)

macro(1000, "Mostrar Storage Teste", function()
    print("TESTE STORAGE:", storage.testeStorage)
end)
