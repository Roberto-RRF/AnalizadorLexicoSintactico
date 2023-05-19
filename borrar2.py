import random

# Funcion que recibe una lista de listas y revisa si se cruzan las reinas en diagonal, vertical y horizontal
def se_cruzan(lista):

    # Verificamos si se cruzan en la misma fila
    for fila in lista:
        if fila.count(1) > 1:
            return True
    # Verificamos si se cruzan en la misma columna
    for i in range(0,8):
        for j in range(0,8):
            if lista[i][j] == 1:
                for k in range(0,8):
                    if lista[k][j] == 1 and k != i:
                        return True

    n_filas = len(lista)
    n_columnas = len(lista[0]) if lista else 0
    num1 = 1
    num2 = 1

    for i in range(n_filas):
        for j in range(n_columnas):
            if lista[i][j] == num1:
                # Verificar diagonal principal hacia abajo
                for k in range(1, min(n_filas - i, n_columnas - j)):
                    if lista[i + k][j + k] == num2:
                        return True
                # Verificar diagonal principal hacia arriba
                for k in range(1, min(i + 1, j + 1)):
                    if lista[i - k][j - k] == num2:
                        return True
                # Verificar diagonal secundaria hacia abajo
                for k in range(1, min(n_filas - i, j + 1)):
                    if lista[i + k][j - k] == num2:
                        return True
                # Verificar diagonal secundaria hacia arriba
                for k in range(1, min(i + 1, n_columnas - j)):
                    if lista[i - k][j + k] == num2:
                        return True

    return False

tablero = [
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
]

copia = [
    [1,0,0,0,0,0,0,0],
    [0,0,0,0,1,0,0,0],
    [0,0,0,0,0,0,0,1],
    [0,0,0,0,0,1,0,0],
    [0,0,1,0,0,0,0,0],
    [0,0,0,0,0,0,1,0],
    [0,1,0,0,0,0,0,0],
    [0,0,0,1,0,0,0,0],
] # Respuesta correcta


for i in range(0,4426165368):
    print(i)
    copia = [
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
]

    # Ponemos 8 reinas alazar en el tablero
    for i in range(0,8):
        copia[i][random.randint(0,7)] = 1
        if not se_cruzan(copia):
            break

print(copia)








        
                        

 



