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
LINHA_TECLADO			EQU 8			; linha a testar (4ª linha, 1000b)
MASCARA					EQU 0FH			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 0			; tecla 0
TECLA_DIREITA			EQU 2			; tecla 2
TECLA_METEORO_BAIXO		EQU 7			; tecla 7
TECLA_AUMENTA_DISPLAY 	EQU 13 			; tecla D
TECLA_DIMINUI_DISPLAY	EQU 12			; tecla C

DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH      ; endereço do comando para tocar um som

LINHA        	EQU  16        		   ; linha do boneco (a meio do ecrã))
COLUNA			EQU  30        		   ; coluna do boneco (a meio do ecrã)

MIN_COLUNA		EQU  0				   ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        		   ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	0FFFH			   ; atraso para limitar a velocidade de movimento do boneco

LARGURA			EQU	5				   ; largura do boneco
COR_PIXEL		EQU	0FF00H			   ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

ENDEREÇO_DISPLAY EQU 0A000H			   ; endereço do display (POUT-2)
ENERGIA_INICIAL	EQU	100				   ; energia inicial do boneco
VALOR_ENERGIA_AUMENTO EQU 5			   ; valor de aumento da energia
VALOR_ENERGIA_DIMINUI EQU 5			   ; valor de diminuição da energia

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)

vida:
	WORD ENERGIA_INICIAL 	; guarda a energia inicial do boneco
							
DEF_BONECO:					; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL		; # # #   as cores podem ser diferentes
     

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
							; à última da pilha
                            
    MOV  [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0							; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	 R7, 1							; valor a somar à coluna do boneco, para o movimentar
	MOV  R6, LINHA_TECLADO				; inicializa R6 com o valor da primeira linha a ser lida
	CALL inicia_energia_display
     
posição_boneco:
    MOV  R1, LINHA						; linha do boneco
    MOV  R2, COLUNA						; coluna do boneco
	MOV	 R4, DEF_BONECO					; endereço da tabela que define o boneco

espera_nao_tecla:						; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL teclado						; leitura às teclas dado a linha (R6) anteriormente gravada
	CMP	 R0, -1							; se R0 = -1, nenhuma tecla está a ser premida
	JNZ	 espera_nao_tecla				; espera, enquanto houver tecla uma tecla carregada

mostra_boneco:
	CALL desenha_boneco					; desenha o boneco a partir da tabela

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	ROL R6, 1				; linha a testar no teclado
	CALL teclado			; leitura às teclas
	CMP	 R0, -1
	JZ	 espera_tecla		; espera, enquanto não houver tecla
	
	MOV	R9, 0			    ; som com número 0
	MOV [TOCA_SOM], R9		; comando para tocar o som
mover_esquerda:
	CMP	R0, TECLA_ESQUERDA
	JNZ mover_direita
	MOV R7, -1 				; vai deslocar para a esquerda
	JMP ve_limites
mover_direita:
	CMP R0, TECLA_DIREITA
	JNZ aumenta_display
	MOV R7, +1 				; vai deslocar para a direita
	JMP ve_limites
;baixar_meteoro:
;	CMP R0, TECLA_METEORO_BAIXO
;	JNZ aumenta_display
;	CALL posicao_meteoro_mau
;	JMP espera_nao_tecla
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
	
ve_limites:
	PUSH R6
	MOV	R6, [R4]			; obtém a largura do boneco
	CALL	testa_limites		; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ	espera_tecla		; se não é para movimentar o objeto, vai ler o teclado de novo
	POP R6

move_boneco:
	CALL	apaga_boneco		; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)

	JMP	mostra_boneco		; vai desenhar o boneco de novo


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  apaga_pixels      ; continua até percorrer toda a largura do objeto
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET


; *
; * ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; * Argumentos:   R1 - linha
; *               R2 - coluna
; *               R3 - cor do pixel (em formato ARGB de 16 bits)
; *
; *
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; *
; * ATRASO - Executa um ciclo para implementar um atraso.
; * Argumentos:   R11 - valor que define o atraso
; *
; *
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; *
; * TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
; *			   impede o movimento (força R7 a 0)
; * Argumentos:	R2 - coluna em que o objeto está
; * 			R6 - largura do boneco
; * 			R7 - sentido de movimento do boneco (valor a somar à coluna
; *				em cada movimento: +1 para a direita, -1 para a esquerda)
; *
; * Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; *
testa_limites:
	PUSH	R5
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	MOV R7, +1 			;im dumb
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	MOV R7, -1 			; im dumb
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R5
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

inicia_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [vida]					;coloca em R0 o valor inicial da energia
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
	POP R0
	RET

aumenta_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [vida]					;coloca em R0 o valor inicial da energia
	CMP R0, VALOR_ENERGIA_AUMENTO	;se a energia for maior que 5, não altera
	JLT exit_aumenta_energia_display  
	ADD R0, 5
	MOV [vida], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
	POP R0							;restaura o valor de R0
exit_aumenta_energia_display:
	RET

diminui_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [vida]					;coloca em R0 o valor inicial da energia
	CMP R0, VALOR_ENERGIA_DIMINUI	;se a energia for maior que 5, não altera
	JLT exit_diminui_energia_display  
	SUB R0, 5
	MOV [vida], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
	POP R0							;restaura o valor de R0
exit_diminui_energia_display:
	RET
