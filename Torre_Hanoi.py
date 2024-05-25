def torre_de_hanoi(n, origem, destino, auxiliar):
    if n== 1:
        print(f"Mova o disco 1 de {origem} para {destino}")
        return
    torre_de_hanoi(n - 1, origem, auxiliar, destino)
    print(f"Mova o disco {n} de {origem} para {destino}")
    torre_de_hanoi(n - 1, auxiliar, destino, origem)

n_discos = 3
torre_de_hanoi(n_discos, "A", "C", "B")