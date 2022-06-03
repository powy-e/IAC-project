; *********************************************************************************
; * Modulo:    grupo.asm
; * Descrição: Ficheiro de código Assembly para o PEPE-16 relativo
; * 		   à versão intermédia do projeto de IAC do grupo xx.
; *********************************************************************************

; +------------+
; | CONSTANTES |
; +------------+
TEC_LIN					EQU 0C000H		; endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H		; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO			EQU 1			; primeira linha a testar (0001b)
MASCARA					EQU 0FH			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 0H			; tecla 0
TECLA_DIREITA			EQU 2H			; tecla 2
TECLA_METEORO_BAIXO		EQU 7H			; tecla 7
TECLA_AUMENTA_DISPLAY 	EQU 0DH			; tecla D
TECLA_DIMINUI_DISPLAY	EQU 0CH			; tecla C

DEFINE_LINHA    		EQU 600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      	; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      	; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      	; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6002H      	; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H      	; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH      	; endereço do comando para tocar um som


ATRASO					EQU	0FFFH		; atraso para limitar a velocidade de movimento do boneco

ENDEREÇO_DISPLAY EQU 0A000H			   	; endereço do display (POUT-2)
ENERGIA_INICIAL	EQU	100				   	; energia inicial da nave
VALOR_ENERGIA_AUMENTO EQU 5			   	; valor de energia a aumentar por comando
VALOR_ENERGIA_DIMINUI EQU 5			   	; valor de energia a diminuir por comando


LINHA_NAVE        		EQU 28        	; linha base do boneco (a meio do ecrã)
COLUNA_INICIAL_NAVE		EQU 30        	; coluna base do boneco (a meio do ecrã)
LINHA_APOS_NAVE         EQU 32         	; linha após linha final da nave
ALTURA_NAVE             EQU 4			; altura da nave
LARGURA_NAVE			EQU	5			; largura do boneco


LINHA_INICIAL_METEORO   EQU 0			; linha base do meteoro
COLUNA_METEORO          EQU 44			; coluna base do meteoro
ALTURA_METEORO_MAU      EQU 5			; altura do meteoro mau
LARGURA_METEORO_MAU 	EQU 5 			; largura do meteoro mau

MAX_LINHA       		EQU 31
MIN_COLUNA				EQU  0			; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA				EQU  63     	; número da coluna mais à direita que o objeto pode ocupar


COR_PIXEL_ROSA		    EQU	0FFAAH		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
COR_PIXEL_LILAS			EQU	0FAAFH		; lilas
COR_PIXEL_METEORO       EQU 0FF05H   	; rosa choque

PIXEL_VERMELHO 			EQU	0FF00H
PIXEL_LARANJA 			EQU	0FF50H
PIXEL_LARANJA2 			EQU 0FFA5H
PIXEL_AMARELO 			EQU	0FFF0H
PIXEL_AMARELO2 			EQU 0FFFAH
PIXEL_VERDE 			EQU	0FAF5H
PIXEL_AZUL 				EQU	0F0AFH


; +-------+
; | DADOS | 
; +-------+
	PLACE       1000H
pilha:
	STACK 200H			; espaço reservado para a pilha 
						; (400H bytes, pois são 200H words)
SP_inicial:				; este é o endereço (1400H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 13FEH (1400H-2)

ENERGIA:
	WORD ENERGIA_INICIAL 	; guarda a energia inicial da nave

DEF_NAVE:					; tabela que define a nave 
	WORD		ALTURA_NAVE, LARGURA_NAVE
    WORD		0, 				0, 				PIXEL_AMARELO2, 0, 				0
	WORD		PIXEL_VERMELHO, 0, 				PIXEL_AMARELO, 	0, 				PIXEL_AZUL
    WORD		PIXEL_VERMELHO, PIXEL_LARANJA, 	PIXEL_AMARELO, 	PIXEL_VERDE, 	PIXEL_AZUL
    WORD		0, 				PIXEL_LARANJA2, 0, 				PIXEL_VERDE, 	0

POSIÇAO_NAVE:
	WORD COLUNA_INICIAL_NAVE

DEF_METEORO_MAU:					; tabela que define o meteoro mau 
	WORD		ALTURA_METEORO_MAU, LARGURA_METEORO_MAU
    WORD		COR_PIXEL_METEORO, 	0, 					0, 					0, 					COR_PIXEL_METEORO
	WORD		COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO
    WORD		0, 					COR_PIXEL_METEORO, 	COR_PIXEL_METEORO, 	COR_PIXEL_METEORO, 	0
   	WORD		COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO
    WORD		COR_PIXEL_METEORO, 	0, 					0, 					0, 					COR_PIXEL_METEORO

POSIÇAO_METEORO:
	WORD LINHA_INICIAL_METEORO

; +--------+
; | CÓDIGO |
; +--------+
PLACE   0                     ; o código tem de começar em 0000H
inicio:
	MOV  [APAGA_AVISO], R1	    			; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	    			; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0			        			; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1		; seleciona o cenário de fundo
	MOV  SP, SP_inicial						; inicializa o SP (stack pointer)
    CALL inicio_desenha_nave    			; desenha a nave na sua posição inicial
	CALL inicio_desenha_meteoro_mau			; desenha o meteoro mau na sua posição inicial
    MOV  R6, LINHA_TECLADO					; inicializa R6 com o valor da primeira linha a ser lida
	CALL inicia_energia_display 			; inicializa o display da energia ao seu valor inicial predefinido (100)
     
; *
; * ESPERA_NAO_TECLA - Executa um ciclo até que nenhuma tecla esteja premida
; * Argumentos:	R0 - valor que define a tecla premida
; *
; *
espera_nao_tecla:							; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL teclado							; leitura às teclas dado a linha (R6) anteriormente gravada
	CMP	 R0, -1								; se R0 = -1, nenhuma tecla está a ser premida 
	JNZ	 espera_nao_tecla					; espera, enquanto houver tecla uma tecla carregada

; *
; * ESPERA_TECLA - Executa um ciclo até que uma tecla seja premida e, consoante a tecla, executa uma operação específica
; * Argumentos:	R0 - valor que define a tecla premida
; *				R6 - valor que define a linha a ser lida
; * 			R9 - valor auxiliar usado para tocar um som quando se baixa um meteoro
; *
espera_tecla:								; neste ciclo espera-se até uma tecla ser premida
	ADD R6, R6								; linha a testar no teclado
	MOV TEMP, 16							; define TEMP como o primeiro valor inválido para as linhas (R6)
	CMP R6, TEMP							; compara o R6 com o seu primeiro valor inválido (16)
	JNZ espera_tecla_body					; caso R6 seja um valor admissível (pertença a (1, 2, 4, 8)), avança para o ciclo
	MOV R6, 1								; caso R6 não seja um valor admissível (igual a 16), faz-se "reset" a R6
											; assim, procede-se a um ciclo em que R6 assume os valores (1, 2, 4, 8)
espera_tecla_body:				
	CALL teclado							; a cada iteração, verifica-se se há alguma tecla premida na linha correspondente ao valor de R6 
											; a rotina "teclado" retorna um valor entre -1 e FH, sendo que
											; todos os valores entre 0H e FH correspondem a teclas e são retornados no caso de se detetar
											; que essa tecla está a ser premida
											; e o valor -1 é retornado no evento de nenhuma tecla estiver a ser premida na linha testada
	CMP	 R0, -1								; caso nenhuma tecla estiver a ser premida na linha indicada por R6, espera
	JZ	 espera_tecla						
											; caso contrário, consoante o valor da tecla premida, chamam-se rotinas específicas
mover_esquerda:				
	CMP	R0, TECLA_ESQUERDA 					; testa se a tecla premida é a tecla correspondente a movimentar a nave para a esquerda
	JNZ mover_direita						; caso não for o caso, procede ao próximo teste
	CALL mover_nave_esquerda				; caso for o caso, chama a rotina "mover_nave_esquerda"
	JMP espera_tecla						; após processar o movimento, torna a ler o input do teclado
											; NOTA: como o movimento da nave é contínua, saltamos para "espera_tecla" em vez de "espera_nao_tecla"
mover_direita:				
	CMP R0, TECLA_DIREITA					; testa se a tecla premida é a tecla correspondente a movimentar a nave para a esquerda
	JNZ baixar_meteoro						; caso não for o caso, procede ao próximo teste
	CALL mover_nave_direita					; caso for o caso, chama a rotina "mover_nave_esquerda"
	JMP espera_tecla						; após processar o movimento, torna a ler o input do teclado
											; NOTA: como o movimento da nave é contínua, saltamos para "espera_tecla" em vez de "espera_nao_tecla"
baixar_meteoro:
	CMP R0, TECLA_METEORO_BAIXO				; testa se a tecla premida é a tecla correspondente a movimentar o meteoro para baixo
	JNZ aumenta_display						; caso não for o caso, procede ao próximo teste
	MOV	R9, 0			    				; caso for o caso, move para R9 o som de código 0
	MOV [TOCA_SOM], R9						; toca esse mesmo som
	CALL mover_meteoro_mau					; e chama a rotina "mover_meteoro_mau"
	JMP espera_nao_tecla					; após processar o movimento, espera que a tecla deixe de ser premida e depois torna a ler o input do teclado

aumenta_display:
	MOV R3, TECLA_AUMENTA_DISPLAY			; testa se a tecla premida é a tecla correspondente a aumentar a energia da nave
	CMP R0, R3								; NOTA: aqui usamos um registo intermédia (R3) uma vez que o valor de TECLA_AUMENTA_DISPLAY excede a gama admitida em constantes
	JNZ diminui_display						; caso não for o caso, procede ao próximo teste
	CALL aumenta_energia_display			; caso for o caso, chama a rotina "aumenta_energia_display"
	JMP espera_nao_tecla					; após processar a operação, espera que a tecla deixe de ser premida e depois torna a ler o input do teclado
diminui_display:
	MOV R3, TECLA_DIMINUI_DISPLAY			; testa se a tecla premida é a tecla correspondente a diminuir a energia da nave
	CMP R0, R3								; NOTA: aqui usamos um registo intermédia (R3) uma vez que o valor de TECLA_DIMINUI_DISPLAY excede a gama admitida em constantes
	JNZ espera_tecla						; caso não for o caso, torna a ler o input do teclado
	CALL diminui_energia_display			; caso for o caso, chama a rotina "diminui_energia_display"
	JMP espera_nao_tecla					; após processar a operação, espera que a tecla deixe de ser premida e depois torna a ler o input do teclado
	
; *
; * ATRASO - Executa um ciclo para implementar um atraso.
; * Argumentos:	R11 - valor que define o atraso
; *
; *
inicio_ciclo_atraso:
	PUSH R11
	MOV R11, ATRASO							
ciclo_atraso:								; ciclo usado para "fazer tempo" entre movimentos sucessivos de naves e meteoros
	SUB	R11, 1								
	JNZ	ciclo_atraso						; espera até que, por subtrações sucessivas, R11 fique a 0
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
	MOV  R2, TEC_LIN   						; endereço do periférico das linhas
	MOV  R3, TEC_COL   						; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6      ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
	AND  R0, R5        ; elimina bits para além dos bits 0-3
	CMP R0, 0			
	JZ teclado_nenhuma_tecla_premida	; caso o valor da coluna lida seja 0 (isto é, não houver nenhuma tecla premida),
										; retorna como valor final da rotina a constante -1 e termina
	CALL formata_linha					; caso haja uma tecla premida, converte o valor da linha lida
										; de (1, 2, 3, 4) para (0, 1, 2, 3)
	CALL formata_coluna					; e faz a mesma operação para o valor da coluna lida
	MOV TEMP, 4							
	MUL R6, TEMP
	ADD R0, R6							; o valor da tecla é definido como sendo:
										; 	tecla = 4 * linha + coluna
	JMP teclado_saida					
teclado_nenhuma_tecla_premida:
	MOV R0, -1
teclado_saida:
	POP R6
	POP	R5
	POP	R3
	POP	R2
	RET

; * (Função auxiliar)
; * FORMATA_LINHA - Converte o valor da linha lida de (1, 2, 4, 8) em (0, 1, 2, 3)
; * Argumentos:	R6 - valor da linha lida em (1, 2, 4, 8)
; *
; * Retorna: 	R6 - valor da linha lida em (0, 1, 2, 3)	
; *
formata_linha:
	MOV TEMP, -1
formata_linha_ciclo:					; para converter o valor da linha lida 
	ADD TEMP, 1							; de (1, 2, 3, 4) para (0, 1, 2, 3)
	SHR R6, 1							; contamos o número de vezes que é preciso fazer SHR ao valor da linha
	CMP R6, 0							; para obter 0
	JNZ formata_linha_ciclo	
	MOV R6, TEMP
	RET

; * (Função auxiliar)
; * FORMATA_COLUNA - Converte o valor da coluna lida de (1, 2, 4, 8) em (0, 1, 2, 3)
; * Argumentos:	R0 - valor da coluna lida em (1, 2, 4, 8)
; *
; * Retorna: 	R0 - valor da coluna lida em (0, 1, 2, 3)	
; *
formata_coluna:
	MOV TEMP, -1
formata_coluna_ciclo:					; para converter o valor da coluna lida 
	ADD TEMP, 1							; de (1, 2, 3, 4) para (0, 1, 2, 3)
	SHR R0, 1							; contamos o número de vezes que é preciso fazer SHR ao valor da linha
	CMP R0, 0							; para obter 0
	JNZ formata_coluna_ciclo
	MOV R0, TEMP
	RET

; *
; * INICIA_ENERGIA_DISPLAY - Inicializa o display de energia
; * Argumentos: R0 - valor inicial da energia da nave
; *

inicia_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [ENERGIA]					;coloca em R0 o valor inicial da energia
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
	POP R0
	RET

; *
; * AUMENTA_ENERGIA_DISPLAY - Aumenta o valor de energia da nave
; * Argumentos: R0 - valor inicial da energia da nave
; *				R1 - nao sei
; *
aumenta_energia_display:
	PUSH R0							;guarda o valor de R0
	PUSH R1							;guarda o valor de R1
	MOV R0, [ENERGIA]					;coloca em R0 o valor inicial da energia
	MOV R1, ENERGIA_INICIAL			
	SUB R1,R0
	CMP R1, VALOR_ENERGIA_AUMENTO	;se a energia for maior que 5, não altera
	JLT exit_aumenta_energia_display  
	ADD R0, 5
	MOV [ENERGIA], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
exit_aumenta_energia_display:
	POP R1 							;restaura o valor de R1
	POP R0							;restaura o valor de R0
	RET

; *
; * DIMINUI_ENERGIA_DISPLAY - Aumenta o valor de energia da nave
; * Argumentos: R0 - valor inicial da energia da nave
; *
diminui_energia_display:
	PUSH R0							;guarda o valor de R0
	MOV R0, [ENERGIA]					;coloca em R0 o valor inicial da energia
	CMP R0, VALOR_ENERGIA_DIMINUI	;se a energia for maior que 5, não altera
	JLT exit_diminui_energia_display  
	SUB R0, 5
	MOV [ENERGIA], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0		;coloca o valor inicial no display
exit_diminui_energia_display:
	POP R0							;restaura o valor de R0
	RET

; *
; * MOVER_NAVE_ESQUERDA - Trata o movimento da nava para a esquerda
; * Argumentos: R5 - valor da menor coluna
; *				R2 - valor da coluna onde a nave se encontra
; * 			R7 - sentido do movimento da nave
; *
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

; *
; * MOVER_NAVE_DIREITA - Trata o movimento da nava para a direita
; * Argumentos: R6 - largura da nave
; * 			R5 - valor da maior coluna
; *				R2 - valor da coluna onde a nave se encontra
; * 			R7 - sentido do movimento da nave
; *
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
	ADD R6, R2                 	; obtém a posiçao da última coluna da nave
	MOV	R5, MAX_COLUNA			; obtem ultima coluna à direita do ecrã
	CMP	R6, R5
	JGT	fim_movimento_direita   ; Caso a nave já ocupe a ultima coluna, não se move 
    MOV R7, 1                  	; Indica o sentido do movimento
    CALL inicio_apaga_nave      ; Apaga a Nave
	CALL desenha_col_seguinte   ; Inicia desenho
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
    MOV R9, LINHA_NAVE			; linha onde começa a nave
    MOV R8, [DEF_NAVE]			; altura da nave que serve como contador de linhas
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
	MOV [POSIÇAO_NAVE], R2		; atualiza a coluna onde começa o desenho da nave
	JMP	inicio_desenha_nave		; vai desenhar o boneco de novo

inicio_desenha_nave:
    ;PUSH R9
    ;PUSH R8
    ;PUSH R4
    MOV R9, LINHA_NAVE          ; linha onde começa a nave
    MOV R8, [DEF_NAVE]			; cópia da altura que serve como contador de linhas
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
         
	SUB R8, 1					;reduz contador das linhas por desenhas
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
	MOV R9, [POSIÇAO_METEORO]	;cópia da linha onde se encontra o meteoro
	MOV R8, [DEF_METEORO_MAU]	;cópia da altura que serve como contador das linhas
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


apaga_meteoro_mau:       		
	MOV R6, COLUNA_METEORO
	MOV	R4, DEF_METEORO_MAU		; endereço da tabela que define o boneco
	MOV	R5, [R4+2]			; obtém a largura do boneco
    JMP apaga_pixels
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0				; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
     ADD  R6, 1             ; próxima coluna
     SUB  R5, 1				; menos uma coluna para tratar
     JNZ  apaga_pixels		; continua até percorrer toda a largura do objeto
	
	ADD R9, 1				;avança para a linha seguinte
    SUB R8, 1				;reduz contador das linhas por apagar
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
desenha_meteoro_mau:       		; desenha o meteoro mau a partir da tabela			
    MOV R1, MAX_LINHA			; obtem o endereço da linha linha do ecrã
	CMP R9, R1					; verifica se a proxima linha do meteoro está fora do ecrã 
	JGT fora_de_linhas			; nesse caso, interrompe o desenho 

	MOV R6, COLUNA_METEORO				; cópia da coluna do meteoro
	MOV	R5, [DEF_METEORO_MAU+2]			; obtém a largura do meteoro
	JMP desenha_pixels_meteoro
desenha_pixels_meteoro:       		
	MOV	R3, [R4]			; obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R6, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels_meteoro      ; continua até percorrer toda a largura do objeto
	ADD R9, 1               ; aumenta a linha
         
	SUB R8, 1				; reduz contador das linhas por desenhar
    JNZ desenha_meteoro_mau
    CALL inicio_ciclo_atraso
    RET
   
