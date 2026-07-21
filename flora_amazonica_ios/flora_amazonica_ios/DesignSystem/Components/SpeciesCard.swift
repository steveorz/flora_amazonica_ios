import SwiftUI

enum SpeciesCardVariant {
    case lista, galeria, mini
}

/// Tarjeta de especie. NO usa Liquid Glass: va sobre fondo neutro
/// porque es contenido principal, no acción flotante.
struct SpeciesCard: View {
    let especie: Especie
    var variant: SpeciesCardVariant = .lista

    var body: some View {
        switch variant {
        case .lista:    listaView
        case .galeria:  galeriaView
        case .mini:     miniView
        }
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(especie.habito.color.opacity(0.18))
            .overlay(
                Image(systemName: "leaf.fill")
                    .foregroundStyle(especie.habito.color)
                    .font(.system(size: 22))
            )
    }

    private var listaView: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail.frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: 4) {
                Text(especie.nombreCientifico)
                    .font(.body.italic())
                    .lineLimit(1)
                Text(especie.familia)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if !especie.nombreLocal.isEmpty {
                    Text(especie.nombreLocal)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)
            EstadoBadge(estado: especie.estado)
        }
        .padding(.vertical, 8)
    }

    private var galeriaView: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnail.aspectRatio(1, contentMode: .fit)
            Text(especie.nombreCientifico)
                .font(.subheadline.italic())
                .lineLimit(1)
            Text(especie.familia)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var miniView: some View {
        HStack(spacing: 8) {
            thumbnail.frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(especie.nombreCientifico)
                    .font(.subheadline.italic())
                    .lineLimit(1)
                Text(especie.familia)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
