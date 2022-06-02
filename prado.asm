; *********************************************************************************
; * IST-UL
; * Modulo:    prado.asm
; * Descrição: Este programa ilustra o movimento de um boneco do ecrã, sob controlo
; *			do teclado, em que o boneco só se movimenta um pixel por cada
; *			tecla carregada (produzindo também um efeito sonoro).
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
TEC_LIN					EQU 0C000H		; endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H		; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO			EQU 1			; linha a testar (4ª linha, 1000b)
MASCARA					EQU 0FH			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 0H			; tecla 0
TECLA_DIREITA			EQU 2H			; tecla 2
TECLA_METEORO_BAIXO		EQU 7H			; tecla 7
TECLA_AUMENTA_DISPLAY 	EQU 0DH			; tecla D
TECLA_DIMINUI_DISPLAY	EQU 0CH			; tecla C

DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH      ; endereço do comando para tocar um som


ATRASO			EQU	0FFFH			   ; atraso para limitar a velocidade de movimento do boneco

ENDEREÇO_DISPLAY EQU 0A000H			   ; endereço do display (POUT-2)
ENERGIA_INICIAL	EQU	100				   ; energia inicial do boneco
VALOR_ENERGIA_AUMENTO EQU 5			   ; valor de aumento da energia
VALOR_ENERGIA_DIMINUI EQU 5			   ; valor de diminuição da energia


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
LARGURA_FIGURAS		EQU	5			; largura do boneco



; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 200H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)

vida:
	WORD ENERGIA_INICIAL 	; guarda a energia inicial do boneco

DEF_NAVE:					; tabela que define a nave 
	WORD		ALTURA_NAVE, LARGURA_FIGURAS
    WORD		0, 0, COR_PIXEL_NAVE, 0, 0
	WORD		COR_PIXEL_NAVE, 0, COR_PIXEL_NAVE, 0, COR_PIXEL_NAVE		; # # #   as cores podem ser diferentes
    WORD		COR_PIXEL_NAVE, COR_PIXEL_NAVE, COR_PIXEL_NAVE, COR_PIXEL_NAVE, COR_PIXEL_NAVE
    WORD		0, COR_PIXEL_NAVE, 0, COR_PIXEL_NAVE, 0

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
PLACE   0                     ; o código tem de começar em 0000H
inicio:
	MOV  [APAGA_AVISO], R1	    ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	    ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			        ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV  SP, SP_inicial	
    CALL inicio_desenha_nave    ; desenha
	CALL inicio_desenha_meteoro_mau
    MOV  R6, LINHA_TECLADO		; inicializa R6 com o valor da primeira linha a ser lida
	CALL inicia_energia_display ; Inicializa display a 100
     

espera_nao_tecla:						; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL teclado						; leitura às teclas dado a linha (R6) anteriormente gravada
	CMP	 R0, -1							; se R0 = -1, nenhuma tecla está a ser premida
	JNZ	 espera_nao_tecla				; espera, enquanto houver tecla uma tecla carregada

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	ADD R6, R6				; linha a testar no teclado
	MOV TEMP, 16
	CMP R6, TEMP
	JNZ espera_tecla_body
	MOV R6, 1
espera_tecla_body:
	CALL teclado			; leitura às teclas
	CMP	 R0, -1
	JZ	 espera_tecla		; espera, enquanto não houver tecla

mover_esquerda:
	CMP	R0, TECLA_ESQUERDA
	JNZ mover_direita
	CALL mover_nave_esquerda
	JMP espera_tecla
mover_direita:
	CMP R0, TECLA_DIREITA
	JNZ baixar_meteoro
	CALL mover_nave_direita
	JMP espera_nao_tecla

baixar_meteoro:
	CMP R0, TECLA_METEORO_BAIXO
	JNZ aumenta_display
	MOV	R9, 0			    ; som com número 0
	MOV [TOCA_SOM], R9		; comando para tocar o som
	CALL mover_meteoro_mau
	JMP espera_nao_tecla

aumenta_display:
	MOV R3, TECLA_AUMENTA_DISPLAY
	CMP R0, R3
	JNZ diminui_display
	CALL aumenta_energia_display
	JMP espera_nao_tecla
diminui_display:
	MOV R3, TECLA_DIMINUI_DISPLAY
	CMP R0, R3
	JNZ espera_tecla
	CALL diminui_energia_display
	JMP espera_nao_tecla		
	
; *
; * ATRASO - Executa um ciclo para implementar um atraso.
; * Argumentos:   R11 - valor que define o atraso
; *
; *
inicio_ciclo_atraso:
	PUSH R11
	MOV R11, ATRASO
ciclo_atraso:			;;usado para meteoros e naves
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP R11
	RET 


; *
; * TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor da tecla lida
; * Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
; *
; * Retorna: 	R0 - valor (em hexadecimal) da tecla premida (em formato 0, 1, 2, ..., F)
; *				NOTA: Caso nenhuma tecla esteja premida, R0 fica a -1.	
; *
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	PUSH 	R6
	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
	MOV  R3, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6      ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
	AND  R0, R5        ; elimina bits para além dos bits 0-3
	CMP R0, 0
	JZ teclado_nenhuma_tecla_premida
	CALL formata_linha
	CALL formata_coluna
	MOV TEMP, 4
	MUL R6, TEMP
	ADD R0, R6
	JMP teclado_saida
teclado_nenhuma_tecla_premida:
	MOV R0, -1
teclado_saida:
	POP R6
	POP	R5
	POP	R3
	POP	R2
	RET

formata_linha:
	MOV TEMP, -1
formata_linha_ciclo:
	ADD TEMP, 1
	SHR R6, 1
	CMP R6, 0
	JNZ formata_linha_ciclo
	MOV R6, TEMP
	RET

formata_coluna:
	MOV TEMP, -1
formata_coluna_ciclo:
	ADD TEMP, 1
	SHR R0, 1
	CMP R0, 0
	JNZ formata_coluna_ciclo
	MOV R0, TEMP
	RET

;#######################
;	DISPLAYYYY
;
;	DISPLAYYY
;#######################

inicia_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [vida]					;coloca em R0 o valor inicial da energia
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
	POP R0
	RET

aumenta_energia_display:
	PUSH R0							;guarda o valor de R0
	PUSH R1							;guarda o valor de R1
	MOV R0, [vida]					;coloca em R0 o valor inicial da energia
	MOV R1, ENERGIA_INICIAL			
	SUB R1,R0
	CMP R1, VALOR_ENERGIA_AUMENTO	;se a energia for maior que 5, não altera
	JLT exit_aumenta_energia_display  
	ADD R0, 5
	MOV [vida], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
exit_aumenta_energia_display:
	POP R1 							;restaura o valor de R1
	POP R0							;restaura o valor de R0
	RET

diminui_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [vida]					;coloca em R0 o valor inicial da energia
	CMP R0, VALOR_ENERGIA_DIMINUI	;se a energia for maior que 5, não altera
	JLT exit_diminui_energia_display  
	SUB R0, 5
	MOV [vida], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
exit_diminui_energia_display:
	POP R0							;restaura o valor de R0
	RET

;##############################

; NAVE

;##############################


mover_nave_esquerda:		    ; Vê se o boneco chegou ao limite esquerdo
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
	MOV	R6, [DEF_NAVE+2]		; obtém a largura do boneco (primeira WORD da tabela)
	MOV R2, [POSIÇAO_NAVE]   	; Vai buscar a Linha onde a Nave se encontra
	ADD R6, R2                 	; obtém a posiçao da ultima coluna
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JGT	fim_movimento_direita   ; Caso se verifique acaba o movimento 
    MOV R7, 1                  	; Indica o sentido do movimento
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


;##################

; METEOROS UWU

;##################




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
	ADD R2, 1				; para desenhar objeto na coluna seguinte (direita ou esquerda)
    MOV R1, MAX_LINHA
    CMP R2, R1
    JGT fora_de_linhas
	MOV [POSIÇAO_METEORO], R2
    JMP inicio_desenha_meteoro_mau
fora_de_linhas:
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
   
