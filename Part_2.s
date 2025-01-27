#
# IAC 2023/2024 k-means
# 
# Grupo: 66
# Campus: Alameda
#
# Autores:
# 109368, Pedro Nunes
# 109762, Andrei Barb
# 109490, Martim Claudino
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:      .word 4,2, 5,1, 5,2, 5,3, 6,2

#Input C
#n_points:    .word 23
#points:      .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16,1, 17,2, 18,6, 20,3, 21,1, 17,4, 21,7, 16,4, 21,6, 19,6, 4,24, 6,24, 8,23, 6,26, 6,26, 6,23, 8,25, 7,26, 7,20, 4,21, 4,10, 2,10, 3,11, 2,12, 4,13, 4,9, 4,9, 3,8, 0,10, 4,10

#input Teste
#n_points:    .word 8   
#points:      .word 0,0, 1,1, 2,2, 10,10, 0,27, 1,26, 6,6, 30,30

# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .zero 128     
k:           .word 3     
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:       .zero 128
lastCentroids:  .zero 128
indexColocado:  .zero 128



#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff, 0xf0e68c, 0xb0e0e6, 0x8a2be2  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    #jal mainSingleCluster
    
    # Chama a funcao principal
    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja e fornecida pelos docentes
# E uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li t0, 31       # MAX = 31
    li t1, 0        # i = 0 
    li a2, white
    
    forCS1:
        bgt t1, t0, endForCS1       # i > MAX
        li t2, 0    # j = 0
        
        forCS2:
            bgt t2, t0, endForCS2   # j > MAX
            
            # definir argumentos printPoint
            add a0, t1, x0
            add a1, t2, x0
            
            jal printPoint
            
            addi t2, t2, 1    # j++
            j forCS2
       
        endForCS2:
            addi t1, t1, 1    # i++
            j forCS1
        
    endForCS1:
        # restaurar ra e pilha
        lw ra, 0(sp)
        addi sp, sp, 4
   
    jr ra

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # verificar se k = 1
    lw t0, k                     # t0 = k
    li t1, 1                     # t1 = 1
    bne t0, t1, kMANYClusters   
    
    kONECluster:
        la t1, points     # t1 = lista pontos
        lw t0, n_points   # t0 = num pontos
        
        li t2, 1         # contador
        la t3, colors
        lw a2, 4(t3)     # a2 = cor
        
        
        forONEPClusters:
            bgt t2, t0, endForONEPClusters  # branch quando contador > num pontos
            
            lw a0, 0(t1)       # a0 = x
            lw a1, 4(t1)       # a1 = y
            
            jal printPoint
            
            addi t2, t2, 1     # contador++
            addi t1, t1, 8     # proximo ponto
            j forONEPClusters
        
        endForONEPClusters:
            j endForPClusters


    kMANYClusters:
        la t0, points           # t0 = points
        lw t1, n_points         # t1 = n_points
        la t2, clusters         # t2 = clusters
        la t3, colors           # t3 = colors
        li t4, 1                # t4 = contador

        forMANYPClusters:
            bgt t4, t1, endForPClusters

            lw t5, 0(t2)           # t5 = index cluster atual
            slli t5, t5, 2         # t5 = cluster atual * 4 (para ter valor em bytes)
            
            add t3, t3, t5         # t3 = colors + cluster atual * 4
            lw a2, 0(t3)           # a2 = cor do cluster

            lw a0, 0(t0)           # a0 = x
            lw a1, 4(t0)           # a1 = y

            jal printPoint
            
            sub t3, t3, t5         # t3 = colors[0] (para voltar ao inicio)
            addi t4, t4, 1         # contador++
            addi t0, t0, 8         # t0++ proximo ponto
            addi t2, t2, 4         # t2++ proximo cluster

            j forMANYPClusters

        endForPClusters:
            # restaurar ra e pilha
            lw ra, 0(sp)
            addi sp, sp, 4
        
        jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, centroids    # t0 = centroids
    lw t1, k            # t1 = k 
    
    li t2, 1            # t2 = contador 
    li a2, black        # a2 = cor
    
    
    forPCentroids:
        bgt t2, t1, endForPCentroids   # branch quando contador > k 
        
        lw a0, 0(t0)                   # a0 = x
        lw a1, 4(t0)                   # a1 = y
        
        jal printPoint
        
        addi t2, t2, 1                 # contador++
        addi t0, t0, 8                 # t0++
        j forPCentroids
        
    endForPCentroids:
        # restaurar ra e pilha
        lw ra, 0(sp)
        addi sp, sp, 4
    
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids: 
    lw a1, n_points         # a1 = n_points
    
    la a2, centroids        # a2 = centroids
    lw a3, k                # a3 = k
    la a4, lastCentroids    # a4 = lastCentroids
    
    li t2, 1                # t2 = i = 1 (contador)
    
    
    # Atualizar lastCentroids
    forLC:
        bgt t2, a3, endForLC
    
        lw a5, 0(a2)            # a5 = Centroids[0]
        sw a5, 0(a4)            # lastCentroids[0] = centroids[0]
        lw a5, 4(a2)            # a5 = Centroids[1]
        sw a5, 4(a4)            # lastCentroids[1] = centroids[1]

        addi t2, t2, 1          # i++   aumentar contador
        addi a2, a2, 8          # a2++  proximo centroid
        addi a4, a4, 8          # a4++  proximo lastCentroid
        j forLC
    
    endForLC:
        # restaurar centroids e contador
        la a2, centroids      # a2 = centroids
        li t2, 1              # t2 = i = 1 (contador para os centroides)

    # Calcular novos centroids
    for1:
        bgt t2, a3, endFor1   # branch quando contador i > k 
        
        la a0, points         # a0 = points
        la a4, clusters       # a4 = clusters

        li t3, 0              # t3 = sumx = 0
        li t4, 0              # t4 = sumy = 0
        li t5, 1              # t5 = j = 1 (contador para os pontos)
        li s7, 0              # s7 = n_points do cluster[j] = 0
        
        for2:
            bgt t5, a1, endFor2     # branch quando j > n_points

            # vericar se ponto pertence ao cluster[i]
            if:
                lw t6, 0(a4)            # t6 = cluster[j]
                
                # como comecamos o contador a 1, mas guardamos os valores a comecar em 0, temos de subtrair 1                  
                addi t2, t2, -1       
                
                bne t6, t2, endIf       # se cluster[j] != i, passar para o proximo ponto

                lw s2, 0(a0)            # s2 = x
                lw s3, 4(a0)            # s3 = y

                add t3, t3, s2          # sumx += x
                add t4, t4, s3          # sumy += y
                addi s7, s7, 1          # n_points++

            endIf:
                addi t2, t2, 1          # i++  aumentar contador porque subtraimos 1 para comparar
                addi t5, t5, 1          # j++  aumentar contador
                addi a0, a0, 8          # a0++ proximo ponto
                addi a4, a4, 4          # a4++ proximo cluster
                j for2


        endFor2:
            # calcular novo centroide
            beq s7, x0, endFor1  # se n_points == 0, passar para o proximo cluster 

            div t3, t3, s7       # X = sumx / n_points
            div t4, t4, s7       # Y = sumy / n_points

            sw t3, 0(a2)         # centroids[i] = X
            sw t4, 4(a2)         # centroids[i] = Y

            addi t2, t2, 1       # i++  aumentar contador
            addi a2, a2, 8       # a2++ proximo centroid
            j for1

    endFor1:
        jr ra
            

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    # guardar ra 
    addi sp, sp, -4
    sw ra, 0(sp)
    
    #1. Coloca k=1 (caso nao esteja a 1)
    la t0, k
    li t1, 1
    sw t1, 0(t0)

    #2. cleanScreen
    jal cleanScreen
    
    #3. printClusters
    jal printClusters
    
    #4. calculateCentroids
    jal calculateCentroids
    
    #5. printCentroids
    jal printCentroids
     
    # restaurar ra
    lw ra, 0(sp)
    addi sp, sp, 4
    
    jr ra


### randomIndex
# Gera um numero aleatorio entre 0 e n_points-1.
# Argumentos: nenhum
# Retorno: a0: index aleatorio

#OPTIMIZATION:
# A funcao randomIndex foi criada para gerar um index da lista de pontos, 
# ao inves de escolher um valor aleatorio da matriz.
# Isto garante que todos os centroides vao ter pontos asscociados, 
# melhorando a eficiencia e eficacia do algoritmo (menos iteracoes, e melhor logica).

randomIndex:
    lw t3, n_points     # t3 = n_points
    
    li a7, 30           # a7 = 30 (syscall para Time_msec)
    ecall
    
    remu a0, a0, t3     # a0 = a0 % n_points (para o index nao ultrapassar o tamanho da lista de pontos)
    jr ra


### initializeCentroids
# Inicializa os centroides com k pontos escolhidos pseudo-aleatoriamente.
# Argumentos: nenhum
# Retorno: nenhum

#OPTIMIZATION (linhas 439-453):                                       
# Certeficamo-nos que o centroide gerado de forma pseudo-aleatoria nao foi gerado anteriormente.
# Para isso, criamos um vetor indexColocado que guarda os indices dos pontos que ja foram escolhidos
# para ser centroides, e verificamos se o ponto que acabou de ser escolhido para ser centroide, ja tinha sido escolhido.
# Se sim, voltamos a escolher um ponto, ate que seja escolhido um ponto que ainda nao tenha sido escolhido.
# Isto melhora a eficacia do algoritmo, pois evita que sejam escolhidos centroides iguais.

initializeCentroids:
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, centroids    # t0 = centroids
    lw t1, k            # t1 = k
    li t2, 1            # t2 = i = 1 (contador)
    la t4, points       # t4 = points
    

    forIC:
        bgt t2, t1, endForIC        # branch quando i > k
        
        jal randomIndex             # a0 = retorno de randomIndex

        li s1, 1                    # s1 = j = 1 variavel que percorre indexColocado
        la s2, indexColocado        # s2 = indexColocado
        
        forIC2:
            bge s1, t2, endForIC2   # branch quando j >= i

            lw s3, 0(s2)            # s3 = indexColocado[j]
            beq a0, s3, forIC       # se indexColocado[j] == a0, escolher outro index
            addi s1, s1, 1          # j++  aumentar contador
            addi s2, s2, 4          # s2++ proximo indexColocado
            j forIC2

        endForIC2:

        sw a0, 0(s2)        # indexColocado[j] = a0
        
        slli a0, a0, 3      # a0 = a0 * 8 (para ter valor em bytes)
        add t4, t4, a0      # t4 = points + a0 (para aceder ao ponto correspondente)

        lw t5, 0(t4)        # t5 = x
        lw t6, 4(t4)        # t6 = y

        sw t5, 0(t0)        # centroids[i] = x
        sw t6, 4(t0)        # centroids[i] = y

        sub t4, t4, a0      # t4 = points (para voltar ao inicio)
        addi t0, t0, 8      # t0++ proximo centroid
        addi t2, t2, 1      # i++  aumentar contador
        
        j forIC

    endForIC:
        # restaurar ra e pilha
        lw ra, 0(sp)
        addi sp, sp, 4

    jr ra


### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t0, a0, a2        # t0 = x0 - x1
    bltz t0, moduloX      # branch se t0 < 0 para calcular o modulo
    j continueX           # se nao, continuar
    
    moduloX:
        neg t0, t0        # t0 = -t0

    continueX:
        sub t1, a1, a3    # t1 = y0 - y1
        bltz t1, muduloY  # branch se t1 < 0 para calcular o modulo
        j continueY       # se nao, continuar

    muduloY:
        neg t1, t1        # t1 = -t1

    continueY:
        add a0, t0, t1    # a0 = |x0 - x1| + |y0 - y1|

    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # criar pilha e guardar ra, a0, a1
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    
    la t2, centroids       # t2 = centroids
    lw t3, k               # t3 = numero de centroides   
    
    lw a2, 0(t2)           # a2 = x do centroide 0
    lw a3, 4(t2)           # a3 = y do centroide 0

    jal manhattanDistance
    
    mv s2, a0              # s2 = distancia do ponto ao centroide 0
    addi s3, x0, 0         # s3 = index do centroide mais proximo
    
    addi t2, t2, 8         # proximo centroide

    li t4, 2               # t2 = index do proximo centroide
    
    forNC:
        bgt t4, t3, endForNC        # branch quando index > numero de centroides
        
        lw a2, 0(t2)                # a2 = x do centroide
        lw a3, 4(t2)                # a3 = y do centroide

        lw a1, 8(sp)                # a1 = y do ponto
        lw a0, 4(sp)                # a0 = x do ponto

        jal manhattanDistance

        blt a0, s2, atualizarNC     # se distancia < distancia anterior, atualizar cluster mais proximo

        addi t4, t4, 1              # index++ aumentar contador
        addi t2, t2, 8              # proximo centroide

        j forNC
        
        atualizarNC:
            # como comecamos o contador a 2, mas guardamos os valores a comecar em 0, temos de subtrair 1
            addi t4, t4, -1         
            
            mv s2, a0               # s2 = distancia do ponto ao centroide
            mv s3, t4               # s3 = index do centroide mais proximo
            addi t4, t4, 2          # index++ aumentar contador (aumentamos 2 porque subtraimos 1 anteriormente)
            addi t2, t2, 8          # proximo centroide
            j forNC
    
    endForNC:
        
        mv a0, s3                   # a0 = index do centroide mais proximo (retornar)
        
        # restaurar ra e pilha
        lw ra, 0(sp)
        addi sp, sp, 12

    jr ra


### updateClusters
# Atualiza o vetor clusters, atribuindo a cada ponto o index do centroide mais proximo.
# Argumentos: nenhum
# Retorno: nenhum

updateClusters:
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    
    la t0, points               # t0 = points
    lw t1, n_points             # t1 = n_points
    la t2, clusters             # t2 = clusters
    
    li t3, 1                    # t3 = i
    
    forUC:
        bgt t3, t1, endForUC    # branch quando i > n_points
        
        lw a0, 0(t0)            # a0 = x
        lw a1, 4(t0)            # a1 = y
        
        # aumentar pilha e guardar t2, t3, t0, t1
        addi sp, sp, -16
        sw t2, 0(sp)
        sw t3, 4(sp)
        sw t0, 8(sp)
        sw t1, 12(sp)

        jal nearestCluster
        
        # restaurar t2, t3, t0, t1       
        lw t1, 12(sp)
        lw t0, 8(sp)
        lw t3, 4(sp)
        lw t2, 0(sp)
        addi sp, sp, 16
        
        sw a0, 0(t2)        # cluster[i] = nearestCluster(x, y)
        
        addi t3, t3, 1      # i++  aumentar contador
        addi t0, t0, 8      # t0++ proximo ponto
        addi t2, t2, 4      # t2++ proximo cluster
        j forUC
    
    endForUC:
        # restaurar ra e pilha
        lw ra, 0(sp)
        addi sp, sp, 4
    
    jr ra


### vericarMudancaCentroids
# Verifica se os centroides mudaram.
# Argumentos: nenhum
# Retorno: 
# a0: 1 se os centroides mudaram, 0 se nao mudaram
vericarMudancaCentroids:
    la t0, lastCentroids                # t0 = lastCentroids
    la t1, centroids                    # t1 = centroids
    lw t2, k                            # t2 = k
    li t3, 1                            # t3 = j = 1 (contador)

    forVerifica:
        bgt t3, t2, parar           # branch quando j > k

        lw t4, 0(t0)                    # t4 = X de lastCentroids[j]
        lw t5, 0(t1)                    # t5 = X de centroids[j]
        bne t4, t5, continuar      # se X de lastCentroids[j] != X de centroids[j], continuar a algoritmo

        lw t4, 4(t0)                    # t4 = Y de lastCentroids[j]
        lw t5, 4(t1)                    # t5 = Y de centroids[j]
        bne t4, t5, continuar      # se Y de lastCentroids[j] != Y de centroids[j], continuar a algoritmo

        addi t3, t3, 1                  # j++  aumentar contador
        addi t0, t0, 8                  # t0++ proximo centroide de lastCentroids
        addi t1, t1, 8                  # t1++ proximo centroide de centroids
        j forVerifica

    continuar:
        li a0, 1                        # a0 = 1 (centroides mudaram)
        jr ra

    parar:
        li a0, 0                        # a0 = 0 (centroides nao mudaram)
        jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # criar pilha e guardar ra
    addi sp,sp 4
    sw ra, 0(sp)

    lw s4, L        # s4 = L
    li s5, 1        # s5 = i = 1 (contador)

    jal initializeCentroids
  
    forMKM:
        bgt s5, s4, endForMKM        # branch quando i > L
        
        jal cleanScreen
                
        jal updateClusters
        
        jal calculateCentroids

        # Verificar se os centroides mudaram
        jal vericarMudancaCentroids
        beq a0, x0, endForMKM        # se centroides nao mudaram, terminar (a0 = 0)

        jal printClusters
        
        jal printCentroids

        addi s5, s5, 1               # i++  aumentar contador
        j forMKM
    
    endForMKM:
        jal printClusters
        jal printCentroids
        
        # restaurar ra e pilha
        lw ra, 0(sp)
        addi sp, sp, -4
    jr ra