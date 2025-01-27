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
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16,1, 17,2, 18,6, 20,3, 21,1, 17,4, 21,7, 16,4, 21,6, 19,6, 4,24, 6,24, 8,23, 6,26, 6,26, 6,23, 8,25, 7,26, 7,20, 4,21, 4,10, 2,10, 3,11, 2,12, 4,13, 4,9, 4,9, 3,8, 0,10, 4,10



# Valores de centroids e k a usar na 1a parte do projeto:
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
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
# Limpa todos os pontos do ecr?
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li t0, 31    # MAX = 31
    li t1, 0     # i = 0
    li a2, white
    
    forCS1:
        bgt t1, t0, endForCS1
        li t2, 0    # j = 0
        
        forCS2:
            bgt t2, t0, endForCS2
            
            # definir argumentos printPoint
            add a0, t1, x0
            add a1, t2, x0
            
            jal printPoint
            
            addi t2, t2, 1    # j++
            j forCS2
       
        endForCS2:
            addi t1, t1, 1
            j forCS1
        
    endForCS1:
        lw ra, 0(sp)
        addi sp, sp, 4
   
    jr ra

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
 
    la t1, points     # t1 = lista pontos
    lw t0, n_points   # t0 = num pontos
    
    li t2, 1         # contador
    la t3, colors
    lw a2, 4(t3)
    
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    forPClusters:
        bgt t2, t0, endForPClusters
        
        lw a0, 0(t1)
        lw a1, 4(t1)
        
        jal printPoint
        
        addi t2, t2, 1
        addi t1, t1, 8
        j forPClusters
    
    endForPClusters:
        # restaurar ra
        lw ra, 0(sp)
        addi sp, sp, 4
    
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    
    la t0, centroids    # t0 = centroids
    lw t1, k            # t1 = k
    
    li t2, 1            # t2 = contador 
    li a2, black        # a2 = cor
    
    # criar pilha e guardar ra
    addi sp, sp, -4
    sw ra, 0(sp)

    forPCentroids:
        bgt t2, t1, endForPCentroids
        lw a0, 0(t0)
        lw a1, 4(t0)
        
        jal printPoint
        
        addi t2, t2, 1      # contador++
        addi t0, t0, 8      # t0++
        j forPCentroids
        
    endForPCentroids:
        # restaurar ra
        lw ra, 0(sp)
        addi sp, sp, 4
    
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids: 
    la t0, points       # t0 = points
    lw t1, n_points     # t1 = n_points
    la a2, centroids    # a2 = centroids
    
    li t2, 0    # t2 = sumx
    li t3, 0    # t3 = sumy
    
    li t4, 1    # t4 = i 
    
    forCC:
        bgt t4, t1, endForCC
        lw t5, 0(t0)    # t5 = x
        lw t6, 4(t0)    # t6 = y
        
        add t2, t2, t5    # sumx += x
        add t3, t3, t6    # sumy += y
        addi t4, t4, 1    # i++
        addi t0, t0, 8
        j forCC
    
    endForCC:
        div t2, t2, t1    # sumx = sumx / n_points
        div t3, t3, t1    # sumy = sumy / n_points
        
        sw t2, 0(a2)
        sw t3, 4(a2)
    
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