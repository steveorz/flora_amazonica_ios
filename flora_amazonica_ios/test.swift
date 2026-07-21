enum Habito: String {
    case arbol
    case palmera
    case arbusto
    case liana
    case hierba
}
let h = Habito(rawValue: "arbol")
print(h == .arbol)
