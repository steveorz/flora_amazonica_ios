import Foundation

let habito = "Árbol"
let dtoHabito = "árbol"
let dtoHabito2 = "arbol"
let dtoHabito3 = "Arbol"

func norm(_ s: String) -> String {
    return s.folding(options: .diacriticInsensitive, locale: Locale(identifier: "es_ES")).lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}

print(norm(habito) == norm(dtoHabito))
print(norm(habito) == norm(dtoHabito2))
print(norm(habito) == norm(dtoHabito3))

print("norm habito:", norm(habito))
print("norm dtoHabito:", norm(dtoHabito))
