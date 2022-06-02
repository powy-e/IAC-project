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
COLUNA_INICIAL_NAVE		EQU  30        ; coluna do boneco (a meio do ecrã)
LINHA_APOS_NAVE         EQU 32         ;linha após linha final da nave
ALTURA_NAVE             EQU 4
COR_PIXEL_NAVE		    EQU	0FFAAH		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

LINHA_INICIAL_METEORO   EQU 0
COLUNA_METEORO          EQU 44
ALTURA_METEORO_MAU      EQU 5
COR_PIXEL_METEORO       EQU 0FF05H   ;rosa choque

MAX_LINHA       EQU 31
MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	 5000H   ;0F00H   		; 400H atraso para limitar a velocidade de movimento do boneco

LARGURA_FIGURAS		EQU	5			; largura do boneco


COR_PIXEL_VERDE	EQU	0FAFAH
COR_PIXEL_AZUL	EQU	0FAFFH
COR_PIXEL_LILAS	EQU	0FAAFH

VERMELHO EQU	0FF00H
LARANJA EQU	0FF50H
LARANJA2 EQU 0FFA5H
AMARELO EQU	0FFF0H
AMARELO2 EQU 0FFFAH
VERDE EQU	0FAF5H
AZUL EQU	0F0AFH
LILAS EQU	0FAAFH

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
    WORD		0, 0, AMARELO2, 0, 0
	WORD		VERMELHO, 0, AMARELO, 0, AZUL		; # # #   as cores podem ser diferentes
    WORD		VERMELHO, LARANJA, AMARELO, VERDE, AZUL
    WORD		0, LARANJA2, 0, COR_PIXEL_VERDE, 0


POSIÇAO_NAVE:
	WORD COLUNA_INICIAL_NAVE


DEF_METEORO_MAU:					; tabela que define o meteoro mau 
	WORD		ALTURA_METEORO_MAU, LARGURA_FIGURAS
    WORD		COR_PIXEL_METEORO, 0, 0, 0, COR_PIXEL_METEORO
	WORD		COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO		; # # #   as cores podem ser diferentes
    WORD		0, COR_PIXEL_METEORO, COR_PIXEL_METEORO, COR_PIXEL_METEORO, 0
   	WORD		COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO, 0, COR_PIXEL_METEORO
    WORD		COR_PIXEL_METEORO, 0, 0, 0, COR_PIXEL_METEORO

POSIÇAO_METEORO:
	WORD LINHA_INICIAL_METEORO

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                

inicio:
    MOV  [APAGA_AVISO], R1	    ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	    ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			        ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV  SP, SP_inicial	
    CALL inicio_desenha_meteoro_mau    ; desenha
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    CALL mover_meteoro_mau
    JMP fim
     

fim:
    JMP fim


mover_nave_esquerda:		            ; Vê se o boneco chegou ao limite esquerdo
    PUSH R9
    PUSH R8
    PUSH R7
    PUSH R6
    PUSH R5
    PUSH R4
    PUSH R3
    PUSH R2
	MOV	R5, MIN_COLUNA          ; Guarda a Coluna Limite em R5
	MOV R2, [POSIÇAO_NAVE]      ; Vai buscar a Coluna onde a Nave se encontra
	CMP	R2, R5                  ; Verifica se a nave se encontra nessa coluna
	JLE	fim_movimento_esquerda  ; Caso se verifique acaba o movimento    
	MOV R7, -1                  ; Indica o sentido do movimento
    CALL inicio_apaga_nave      ; Apaga a Nave
    CALL desenha_col_seguinte   ;inicia desenho
fim_movimento_esquerda:
    POP R2
    POP R3
    POP R4
    POP R5
    POP R6
    POP R7
    POP R8
    POP R9
    RET


mover_nave_direita:		
    PUSH R9
    PUSH R8
    PUSH R7
    PUSH R6
    PUSH R5
    PUSH R4
    PUSH R3
    PUSH R2
	MOV	R6, [DEF_NAVE+2]	; obtém a largura do boneco (primeira WORD da tabela)
	MOV R2, [POSIÇAO_NAVE]   ; Vai buscar a Linha onde a Nave se encontra
	ADD R6, R2                 ; obtém a posiçao da ultima coluna
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JGT	fim_movimento_direita   ; Caso se verifique acaba o movimento 
    MOV R7, 1                  ; Indica o sentido do movimento
    CALL inicio_apaga_nave      ; Apaga a Nave
	CALL desenha_col_seguinte   ;inicia desenho
fim_movimento_direita:
    POP R2
    POP R3
    POP R4
    POP R5
    POP R6
    POP R7
    POP R8
    POP R9
    RET



inicio_apaga_nave:	
    MOV R9, LINHA_NAVE
    MOV R8, [DEF_NAVE]
	JMP apaga_linha_nave
apaga_linha_nave:       		; desenha o boneco a partir da tabela
	MOV	R6, [POSIÇAO_NAVE]		; cópia da coluna do boneco
	MOV	R4, DEF_NAVE		    ; endereço da tabela que define o boneco
	MOV	R5, [R4+2]			    ; obtém a largura do boneco
	JMP apaga_pixels_nave
apaga_pixels_nave:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			        ; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R9	    ; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	    ; altera a cor do pixel na linha e coluna selecionadas
    ADD  R6, 1                  ; próxima coluna
    SUB  R5, 1			        ; menos uma coluna para tratar
    JNZ  apaga_pixels_nave		; continua até percorrer toda a largura do objeto
	ADD R9, 1                   ; Passa à linha seguinte
    SUB R8, 1                   ; Reduz o contador das linhas a desenhar
	JNZ apaga_linha_nave        ; Continua o loop  
    RET


desenha_col_seguinte:
	MOV R2, [POSIÇAO_NAVE]
	ADD	R2, R7			        ; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV [POSIÇAO_NAVE], R2
	JMP	inicio_desenha_nave		; vai desenhar o boneco de novo

inicio_desenha_nave:
    ;PUSH R9
    ;PUSH R8
    ;PUSH R4
    MOV R9, LINHA_NAVE          ;linha da nave
    MOV R8, [DEF_NAVE]
    MOV	R4, DEF_NAVE		    ; endereço da tabela que define a nave
    ADD R4, 4			        ; endereço da cor do 1º pixel (4 porque a largura e altura são words)
    JMP desenha_linha_nave

desenha_linha_nave:       		; desenha a nave a partir da tabela
	MOV	R6, [POSIÇAO_NAVE]		; cópia da coluna da nave
	MOV	R5, [DEF_NAVE+2]		; obtém a largura do boneco
    JMP desenha_pixels_nave
    
desenha_pixels_nave:       		; desenha os pixels da figura a partir da tabela correspondente
	MOV	R3, [R4]			    ; obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	    ; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	    ; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			        ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R6, 1                  ; próxima coluna
    SUB  R5, 1			        ; menos uma coluna para tratar
    JNZ  desenha_pixels_nave    ; continua até percorrer toda a largura do objeto
	ADD R9, 1                   ; aumenta a linha
         
	SUB R8, 1
    JNZ desenha_linha_nave
	
	CALL inicio_ciclo_atraso
    ;POP R4
    ;POP R8
    ;POP R9
	RET





;;BURUh




mover_meteoro_mau:	
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R8
    PUSH R9
	MOV R9, [POSIÇAO_METEORO]	;cópia da linha do meteoro
	MOV R8, [DEF_METEORO_MAU]
    CALL apaga_meteoro_mau

fim_movimento_meteoro:
    POP R9
    POP R8
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET


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
    CALL inicio_ciclo_atraso
    JMP linha_seguinte


linha_seguinte:
	MOV R2, [POSIÇAO_METEORO]
	ADD R2, 1			; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV [POSIÇAO_METEORO], R2
    MOV R1, MAX_LINHA
    CMP R9, R1
    JLE inicio_desenha_meteoro_mau
    RET



inicio_desenha_meteoro_mau:
	MOV R9, [POSIÇAO_METEORO]
    MOV R8, [DEF_METEORO_MAU]   ;altura do meteoro mau
    MOV	R4, DEF_METEORO_MAU		; endereço da tabela que define o boneco
    ADD R4, 4           ; endereço da cor do 1º pixel 
    JMP desenha_meteoro_mau


desenha_meteoro_mau:       		; desenha o meteoro mau a partir da tabela			; cópia da coluna do meteoro
	MOV R6, COLUNA_METEORO
	MOV	R5, [DEF_METEORO_MAU+2]			; obtém a largura do meteoro
    JMP desenha_pixels_meteoro


desenha_pixels_meteoro:       		; desenha os pixels da figura a partir da tabela correspondente
	MOV	R3, [R4]			; obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R6, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels_meteoro      ; continua até percorrer toda a largura do objeto
	ADD R9, 1               ; aumenta a linha
         
	SUB R8, 1
    JNZ desenha_meteoro_mau
    CALL inicio_ciclo_atraso
    RET
    


inicio_ciclo_atraso:
	PUSH R11
	MOV R11, ATRASO
ciclo_atraso:	;;usado para meteoros e naves
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP R11
	RET 




