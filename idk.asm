; *********************************************************************************
; * IST-UL
; * Modulo:    lab4-move-boneco.asm
; * Descrição: Este programa ilustra o movimento de um boneco do ecrã, usando um atraso
; *			para limitar a velocidade de movimentação.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo

LINHA_NAVE        		EQU  28        ; linha do boneco (a meio do ecrã))
COLUNA_NAVE			    EQU  30        ; coluna do boneco (a meio do ecrã)
LINHA_APOS_NAVE         EQU 32           ;linha após linha final da nave
ALTURA_NAVE             EQU 4
COR_PIXEL_NAVE		    EQU	0FFAAH		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

LINHA_METEORO           EQU 14
COLUNA_METEORO          EQU 44
LINHA_APOS_METEORO      EQU 19
ALTURA_METEORO_MAU      EQU 5
COR_PIXEL_METEORO       EQU 0FF05H   ;rosa choque

MAX_LINHA       EQU 31
MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	 0F00H   ;0F00H   		; 400H atraso para limitar a velocidade de movimento do boneco

LARGURA_FIGURAS		EQU	5			; largura do boneco

PLACE 1000H
pilha:
	STACK 100H			; espa�o reservado para a pilha 
						; (200H bytes, pois s�o 100H words)
SP_inicial:				; este � o endere�o (1200H) com que o SP deve ser 
						; inicializado. O 1.� end. de retorno ser� 
						; armazenado em 11FEH (1200H-2)

; #######################################################################
; * ZONA DE DADOS 
; #######################################################################
PLACE		0200H				

DEF_NAVE:					; tabela que define a nave 
	WORD		ALTURA_NAVE, LARGURA_FIGURAS
    WORD		0, 0, COR_PIXEL_NAVE, 0, 0
	WORD		COR_PIXEL_NAVE, 0, COR_PIXEL_NAVE, 0, COR_PIXEL_NAVE		; # # #   as cores podem ser diferentes
    WORD		COR_PIXEL_NAVE, COR_PIXEL_NAVE, COR_PIXEL_NAVE, COR_PIXEL_NAVE, COR_PIXEL_NAVE
    WORD		0, COR_PIXEL_NAVE, 0, COR_PIXEL_NAVE, 0


DEF_METEORO_MAU:					; tabela que define o meteoro mau 
	WORD		ALTURA_METEORO_MAU, LARGURA_FIGURAS
    WORD		COR_PIXEL_METEORO, 0, 0, 0, COR_PIXEL_METEORO
	WORD		COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO		; # # #   as cores podem ser diferentes
    WORD		0, COR_PIXEL_METEORO, COR_PIXEL_METEORO, COR_PIXEL_METEORO, 0
   	WORD		COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO
    WORD		COR_PIXEL_METEORO, 0, 0, 0, COR_PIXEL_METEORO

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                

inicio:     ;acho que convem estar no inicio do codigo para o R1 usado aqui nao mudar!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	;MOV	R7, 1			; valor a somar à coluna do boneco, para o movimentar
	MOV  SP, SP_inicial	
     





posição_meteoro_mau:
    MOV R7, 1
	MOV R2, LINHA_METEORO


inicio_desenha_meteoro_mau:
	MOV R9, R2
    MOV R8, [DEF_METEORO_MAU]   ;altura do meteoro mau
    MOV	R4, DEF_METEORO_MAU		; endereço da tabela que define o boneco
    ADD R4, 4           ; endereço da cor do 1º pixel 
    JMP desenha_meteoro_mau


desenha_meteoro_mau:       		; desenha o meteoro mau a partir da tabela			; cópia da coluna do meteoro
	MOV R6, COLUNA_METEORO
	MOV	R5, [DEF_METEORO_MAU+2]			; obtém a largura do meteoro
    JMP desenha_pixels


desenha_pixels:       		; desenha os pixels da figura a partir da tabela correspondente
	MOV	R3, [R4]			; obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R6, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	ADD R9, 1               ; aumenta a linha
         
	SUB R8, 1
    JNZ desenha_meteoro_mau
	MOV	R11, ATRASO		; atraso para limitar a velocidade de movimento do boneco	
    CALL ciclo_atraso
    JMP inicio_apaga_meteoro_mau




    

inicio_apaga_meteoro_mau:	
	MOV R9, R2	;cópia da linha do meteoro
	MOV R8, [DEF_METEORO_MAU]
    JMP apaga_meteoro_mau

apaga_meteoro_mau:       		; desenha o boneco a partir da tabela
    MOV R6, COLUNA_METEORO
	MOV	R4, DEF_METEORO_MAU		; endereço da tabela que define o boneco
	MOV	R5, [R4+2]			; obtém a largura do boneco
    JMP apaga_pixels

apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
     ADD  R6, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  apaga_pixels		; continua até percorrer toda a largura do objeto
	
	ADD R9, 1
    SUB R8, 1
	JNZ apaga_meteoro_mau
    CALL ciclo_atraso
    JMP linha_seguinte


linha_seguinte:
	ADD R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)
    MOV R1, MAX_LINHA
    CMP R9, R1
    JLE inicio_desenha_meteoro_mau
	;RET????=?


    








posição_nave:
    MOV  R2, COLUNA_NAVE		; coluna da nave
    JMP inicio_desenha_nave


inicio_desenha_nave:
    MOV R9, LINHA_NAVE      ;linha da nave
    MOV R8, [DEF_NAVE]
    MOV	R4, DEF_NAVE		; endereço da tabela que define a nave
    ADD R4, 4			; endereço da cor do 1º pixel (4 porque a largura e altura são words)
    JMP desenha_nave


desenha_nave:       		; desenha a nave a partir da tabela
	MOV	R6, R2			; cópia da coluna da nave
	MOV	R5, [DEF_NAVE+2]			; obtém a largura do boneco
    JMP desenha_pixels_nave
    
    
desenha_pixels_nave:       		; desenha os pixels da figura a partir da tabela correspondente
	MOV	R3, [R4]			; obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R6, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels_nave      ; continua até percorrer toda a largura do objeto
	ADD R9, 1               ; aumenta a linha
         
	SUB R8, 1
    JNZ desenha_nave

	MOV	R11, ATRASO		; atraso para limitar a velocidade de movimento do boneco	
	CALL ciclo_atraso
	JMP inicio_apaga_nave


ciclo_atraso:	;;usado para meteoros e naves
	SUB	R11, 1
	JNZ	ciclo_atraso
	RET 


inicio_apaga_nave:	

    MOV R9, LINHA_NAVE
    MOV R8, [DEF_NAVE]
	JMP apaga_nave

apaga_nave:       		; desenha o boneco a partir da tabela
	MOV	R6, R2			; cópia da coluna do boneco
	MOV	R4, DEF_NAVE		; endereço da tabela que define o boneco
	MOV	R5, [R4+2]			; obtém a largura do boneco
	JMP apaga_pixels_nave



;;;apaga pixels

apaga_pixels_nave:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
     ADD  R6, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  apaga_pixels_nave		; continua até percorrer toda a largura do objeto
	
	ADD R9, 1
    SUB R8, 1
	JNZ apaga_nave

testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JLE	inverte_para_direita

testa_limite_direito:		; vê se o boneco chegou ao limite direito
	MOV	R6, [DEF_NAVE+2]	; obtém a largura do boneco (primeira WORD da tabela)
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JGT	inverte_para_esquerda
	JMP	coluna_seguinte	; entre limites. Mnatém o valor do R7

inverte_para_direita:
	MOV	R7, 1			; passa a deslocar-se para a direita
	JMP	coluna_seguinte

inverte_para_esquerda:
	MOV	R7, -1			; passa a deslocar-se para a esquerda
	
coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)

	JMP	inicio_desenha_nave		; vai desenhar o boneco de novo

;;
anda_para_cima_ou_esquerda:
	MOV	R7, -1			; passa a deslocar-se para a direita






