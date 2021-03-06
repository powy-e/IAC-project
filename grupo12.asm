; *********************************************************************************
; * Ficheiro:  grupo_12.asm
; * Descrição: Ficheiro de código Assembly para o PEPE-16 relativo
; * 		   à versão intermédia do projeto de IAC do grupo 12.
; *
; *	Beatriz Gavilan - 102463 - beatrizgavilan@tecnico.ulisboa.pt
; *	Eduardo Nazário - 102415 - eduardo.nazario@tecnico.ulisboa.pt
; *	Miguel Coelho   - 102430 - miguel.pinheiro.coelho@tecnico.ulisboa.pt
; *********************************************************************************


;  Tecla andar para a esquerda:	0
;  Tecla andar para a direita:	2
;  Tecla descer o meteoro:		7
;  Tecla para diminuir display: C
;  Tecla para aumentar display: D

; +------------+
; | CONSTANTES |
; +------------+
TEC_LIN					EQU 0C000H		; Endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H		; Endereço das colunas do teclado (periférico PIN)
NUMERO_LINHAS			EQU 4			; Número de linhas do teclado
MASCARA					EQU 0FH			; Para isolar os 4 bits de menor peso, ao ler as colunas do teclado

TECLA_ESQUERDA			EQU 0H			; Tecla 0
TECLA_DIREITA			EQU 2H			; Tecla 2
TECLA_METEORO_BAIXO		EQU 7H			; Tecla 7
TECLA_START_GAME		EQU 0CH			; Tecla Pausa Jogo
TECLA_PAUSA_JOGO		EQU 0DH			; Tecla Pausa Jogo
TECLA_FIM_JOGO			EQU 0EH			; Tecla Fim Jogo
TECLA_ACABA_JOGO		EQU 10H			; Tecla Acabar o Jogo

DEFINE_LINHA    		EQU 600AH      	; Endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      	; Endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      	; Endereço do comando para escrever um pixel
DEFINE_COR_CANETA  		EQU 6014H      	; Endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      	; Endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃS	 			EQU 6002H      	; Endereço do comando para apagar todos os pixels já desenhados
APAGA_ECRÃ_N	 		EQU 6000H      	; Endereço do comando para apagar todos os pixels já desenhados
SELECIONA_ECRÃ_N		EQU 6004H		; Endereço do comando para selecionar o ecrã
MOSTRA_ECRÃ_N			EQU 6006H		; Endereço do comando para selecionar o ecrã
ESCONDE_ECRÃ_N			EQU 6008H		; Endereço do comando para selecionar o ecrã
SELECIONA_CENARIO_FUNDO EQU 6042H      	; Endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH      	; Endereço do comando para tocar um som


ATRASO					EQU	0020H		; Atraso para limitar a velocidade de movimento

ENDEREÇO_DISPLAY		EQU 0A000H		; Endereço do display (POUT-2)
ENERGIA_INICIAL			EQU	100			; Energia inicial da nave
VALOR_ENERGIA_AUMENTO 	EQU 5			; Valor de energia a aumentar por comando
VALOR_ENERGIA_DIMINUI 	EQU 5			; Valor de energia a diminuir por comando


LINHA_NAVE        		EQU 28        	; Linha base da nave (a meio do ecrã)
COLUNA_INICIAL_NAVE		EQU 30        	; Coluna base da nave (a meio do ecrã)
LINHA_APOS_NAVE         EQU 32         	; Linha após linha final da nave
ALTURA_NAVE             EQU 4			; Altura da nave
LARGURA_NAVE			EQU	5			; Largura da nave
ECRÃ_NAVE 				EQU 4			; Ecrã da nave


LINHA_INICIAL_METEORO   EQU 0			; Linha base do meteoro
COLUNA_METEORO          EQU 44			; Coluna base do meteoro
ALTURA_METEORO_MAU      EQU 5			; Altura do meteoro mau
LARGURA_METEORO_MAU 	EQU 5 			; Largura do meteoro mau

MAX_LINHA       		EQU 31
MIN_COLUNA				EQU  0			; Número da última coluna à esquerda no ecrã
MAX_COLUNA				EQU  64     	; Número da última coluna à direita no ecrã


COR_PIXEL_METEORO       EQU 0FF05H 
COR_PIXEL_MISSIL 		EQU 0FF38H	 	

; Cores dos pixeis da nave
PIXEL_CINZA             EQU 0A578H
PIXEL_CINZENTO_CLARO     EQU 0F888H
PIXEL_CINZENTO_ESCURO    EQU 0F444H
PIXEL_VERMELHO             EQU    0FF00H
PIXEL_LARANJA             EQU    0FF50H
PIXEL_LARANJA2             EQU 0FFA5H
PIXEL_AMARELO             EQU    0FFF0H
PIXEL_AMARELO2             EQU 0FFFAH
PIXEL_VERDE             EQU    0FAF5H
PIXEL_AZUL                 EQU    0F0AFH
PIXEL_PRETO             EQU 0F000H
PIXEL_ROSA                 EQU 0FF7BH
PIXEL_ROXO                EQU 0F64DH
PIXEL_CASTANHO_1        EQU 0F532H
PIXEL_CASTANHO_2        EQU 0F632H
PIXEL_CASTANHO_3        EQU 0F643H
PIXEL_CASTANHO_4        EQU 0FB64H

FUNDO_INICIO			EQU 1
FUNDO_PAUSA				EQU 2
FUNDO_GAME_OVER_METEORO	EQU 4
FUNDO_GAME_OVER_ENERGIA	EQU 3
FUNDO_JOGO				EQU 0
FUNDO_TERMINA_JOGO 		EQU 5


TIPO_METEORO_MAU 		EQU 2 
TIPO_METEORO_BOM		EQU 4
COLUNA 					EQU 0H
LINHA				 	EQU 0H

SOM_PATO_PAO			EQU	0			; Som Bom
SOM_MISSIL_PAO			EQU	1			; Som de colisão com meteoro bom 
SOM_PATO_POMBO			EQU	2			; Som Explosão para quando a nave choca com Meteoro
SOM_MISSIL_POMBO		EQU	3			; Som de colisão com meteoro mau 
SOM_DISPARO_MÍSSIL		EQU	4			; Som de disparo de míssil 
SOM_MORTE_ENERGIA		EQU	5			; Som de disparo de míssil 

; +-------+
; | DADOS | 
; +-------+
	PLACE       1500H
pilha:
	STACK 100H							; espaço reservado para a pilha 
										; (400H bytes, pois são 200H words)
SP_inicial:								; este é o endereço (1400H) com que o SP deve ser 
										; inicializado. O 1.º end. de retorno será 
										; armazenado em 13FEH (1400H-2)

	STACK 100H							; espaço reservado para a pilha
SP_interrupt:
	STACK 100H							; espaço reservado para a pilha
SP_displays:
	STACK 100H							; espaço reservado para a pilha
SP_nave:
	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 1)
SP_inicial_teclado_1:					; este é o endereço (2400H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 2)
SP_inicial_teclado_2:					; este é o endereço (2600H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 3)
SP_inicial_teclado_3:					; este é o endereço (2800H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 4)
SP_inicial_teclado_4:					; este é o endereço (3000H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "pausa" (linha 1)
SP_inicial_pausa:

	STACK 100H							; espaço reservado para a pilha do processo "Meteoro"
SP_Meteoro:								; este é o endereço (3200H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "míssil"
SP_míssil:

	STACK 100H							; espaço reservado para a pilha do processo "morte" (linha 1)
SP_inicial_morte:						; este é o endereço (3400H) com que o SP deste processo deve ser inicializado


SP_TECLADO:
	WORD SP_inicial_teclado_1
	WORD SP_inicial_teclado_2
	WORD SP_inicial_teclado_3
	WORD SP_inicial_teclado_4


evento_mover_nave:
	LOCK 0H   							; lock para mover nave

evento_energia:
	LOCK 0H								; lock para a energia

evento_morte:
	LOCK 0H

evento_mover_meteoros:
	LOCK 0H								; lock para mover meteoros

evento_mover_míssil:
	LOCK 0H								; lock para mover mísseis

evento_disparar_míssil:
	LOCK 0H								; lock para disparar mísseis

tab_int:
	WORD rot_int_0						; rotina de interrupção 0
	WORD rot_int_1						; rotina de interrupção 1
	WORD rot_int_2						; rotina de interrupção 2
	

LOCK_GAMESTATE_PAUSED:
	LOCK 0H
WORD_GAMESTATE_PAUSED:
	WORD 0H

LOCK_PRINCIPAL:
	LOCK 0H								; lock para o programa principal 

TECLA_CARREGADA:
	LOCK 0 								; LOCK usado para o teclado comunicar aos restantes processos que tecla detetou
										; uma vez por cada tecla carregada

TECLA_CONTINUA:
	LOCK 0								; LOCK usado para o teclado comunicar aos restantes processos que tecla detetou,
										; enquanto a tecla estiver carregada

interrupções:
	WORD 0								; LOCK usado para o teclado comunicar aos restantes processos que tecla detetou,
										; enquanto a tecla estiver carregada



ENERGIA:
	WORD ENERGIA_INICIAL 				; guarda a energia inicial da nave

DEF_NAVE:                                ; tabela que define a nave 
    WORD        ALTURA_NAVE, LARGURA_NAVE
    WORD        0,                 PIXEL_PRETO,   PIXEL_AMARELO, PIXEL_PRETO,   0
    WORD        0,                 PIXEL_LARANJA, PIXEL_LARANJA, PIXEL_LARANJA, 0
    WORD        PIXEL_AMARELO,     PIXEL_AMARELO, PIXEL_AMARELO, PIXEL_AMARELO, PIXEL_AMARELO
    WORD        0,              PIXEL_AMARELO, PIXEL_AMARELO, PIXEL_AMARELO, 0


POSIÇAO_NAVE:
	WORD COLUNA_INICIAL_NAVE

interrupt_stop:
	WORD 0

LINHA_ATUAL_MISSIL:	; Define a linha atual do míssil (começa na linha da nave)
	WORD LINHA_NAVE		



DEF_METEORO_1X1:
	WORD		1, 1
    WORD		PIXEL_CINZA


DEF_METEORO_2X2:
	WORD		2, 2
    WORD		PIXEL_CINZA, PIXEL_CINZA
    WORD		PIXEL_CINZA, PIXEL_CINZA


DEF_METEORO_3X3_BOM:
    WORD        3, 3
    WORD        PIXEL_CASTANHO_1, PIXEL_CASTANHO_1, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_2, PIXEL_CASTANHO_3, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_2, PIXEL_CASTANHO_2, PIXEL_CASTANHO_1
    
DEF_METEORO_3X3_MAU:
    WORD        3, 3
    WORD        0, PIXEL_CINZENTO_CLARO, PIXEL_AMARELO
    WORD        PIXEL_CINZENTO_ESCURO, PIXEL_CINZENTO_ESCURO, 0
    WORD        0, PIXEL_ROSA, 0


DEF_METEORO_4X4_BOM:
    WORD        4, 4
    WORD        0,             PIXEL_CASTANHO_2, PIXEL_CASTANHO_1, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_2, PIXEL_CASTANHO_3, PIXEL_CASTANHO_2, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_3, PIXEL_CASTANHO_4, PIXEL_CASTANHO_3, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_3, PIXEL_CASTANHO_3, PIXEL_CASTANHO_1, 0
    
DEF_METEORO_4X4_MAU:
    WORD        4, 4
    WORD        0, 0, PIXEL_CINZENTO_CLARO, PIXEL_AMARELO
    WORD        PIXEL_CINZENTO_ESCURO, PIXEL_CINZENTO_ESCURO, PIXEL_CINZENTO_ESCURO, 0
    WORD        0,                     PIXEL_CINZENTO_CLARO, PIXEL_CINZENTO_CLARO,     0
    WORD        0, PIXEL_ROSA, 0, 0


DEF_METEORO_5X5_BOM:                        ; tabela que define o meteoro bom 
    WORD        5, 5
    WORD        0,                 PIXEL_CASTANHO_2, PIXEL_CASTANHO_2, PIXEL_CASTANHO_1, 0
    WORD        PIXEL_CASTANHO_2, PIXEL_CASTANHO_3, PIXEL_CASTANHO_3, PIXEL_CASTANHO_2, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_4, PIXEL_CASTANHO_4, PIXEL_CASTANHO_4, PIXEL_CASTANHO_3, PIXEL_CASTANHO_1
	WORD        PIXEL_CASTANHO_4, PIXEL_CASTANHO_4, PIXEL_CASTANHO_4, PIXEL_CASTANHO_3, PIXEL_CASTANHO_1
    WORD        PIXEL_CASTANHO_4, PIXEL_CASTANHO_4, PIXEL_CASTANHO_4, PIXEL_CASTANHO_2, 0 		


DEF_METEORO_5X5_MAU:                        ; tabela que define o meteoro mau 
    WORD        5, 5
    WORD        0, 0, PIXEL_CINZENTO_CLARO, PIXEL_PRETO, 0
    WORD        0, 0, PIXEL_CINZENTO_CLARO, PIXEL_AMARELO, PIXEL_AMARELO
    WORD        PIXEL_CINZENTO_ESCURO, PIXEL_CINZENTO_ESCURO, PIXEL_CINZENTO_ESCURO, PIXEL_ROXO, 0
	WORD        0, PIXEL_CINZENTO_ESCURO, PIXEL_CINZENTO_CLARO, PIXEL_CINZENTO_CLARO, 0
    WORD        0, 0, PIXEL_ROSA, 0, 0



TABELA_METEOROS:
	WORD TIPO_METEORO_MAU, DEF_METEORO_1X1, COLUNA, LINHA
	WORD TIPO_METEORO_BOM, DEF_METEORO_1X1, COLUNA, LINHA
	WORD TIPO_METEORO_MAU, DEF_METEORO_1X1, COLUNA, LINHA
	WORD TIPO_METEORO_MAU, DEF_METEORO_1X1, COLUNA, LINHA

TABELA_LINHAS_EVOLUÇÃO_METEOROS:
	WORD 3,  DEF_METEORO_2X2, 	  DEF_METEORO_2X2
	WORD 6,  DEF_METEORO_3X3_MAU, DEF_METEORO_3X3_BOM
	WORD 9,  DEF_METEORO_4X4_MAU, DEF_METEORO_4X4_BOM
	WORD 12, DEF_METEORO_5X5_MAU, DEF_METEORO_5X5_BOM


DEF_EXPLOSÃO_METEORO_MAU:
    WORD        5, 5
    WORD        PIXEL_VERMELHO,     0,                     PIXEL_VERMELHO,             0,                     PIXEL_VERMELHO
    WORD        0,                     PIXEL_LARANJA,     0,                             PIXEL_LARANJA,     0
    WORD        PIXEL_VERMELHO,     0,                     PIXEL_AMARELO,             0,                     PIXEL_VERMELHO
    WORD        0,                     PIXEL_LARANJA,     0,                             PIXEL_LARANJA,     0
    WORD        PIXEL_VERMELHO,     0,                     PIXEL_VERMELHO,             0,                     PIXEL_VERMELHO

DEF_EXPLOSÃO_METEORO_BOM:
    WORD        5, 5
    WORD        0,                 PIXEL_CASTANHO_2, 0, PIXEL_CASTANHO_1, 0
    WORD        PIXEL_CASTANHO_2, 0, PIXEL_CASTANHO_3, 0, PIXEL_CASTANHO_1
    WORD        0, PIXEL_CASTANHO_4, 0, PIXEL_CASTANHO_3, 0
    WORD        PIXEL_CASTANHO_4, 0, PIXEL_CASTANHO_4, 0, PIXEL_CASTANHO_1
    WORD        0, PIXEL_CASTANHO_4, 0, PIXEL_CASTANHO_2, 0  


; +--------+
; | CÓDIGO |
; +--------+
PLACE   0                     			; O código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial					; Inicializa o SP (stack pointer)
	MOV  BTE, tab_int					; Inicializa a tabela de interrupções
	MOV  [APAGA_AVISO], R1	    		; Apaga o aviso de nenhum cenário selecionado 
    MOV  [APAGA_ECRÃS], R1	    		; Apaga todos os pixels já desenhados 
	MOV	 R1, FUNDO_INICIO			    ; Cenário de fundo inicial
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; Seleciona o cenário de fundo


	MOV  R11, NUMERO_LINHAS				; Inicializa R11 com o valor da primeira linha a ser lida
loop_teclados:							; Loop que chama o processo de teclado
	SUB R11, 1							; Decrementa pois a linha é de 0 a 3
	CALL teclado						; Cria uma instância do teclado
	CMP R11, 0							; Verifica se a linha é a ultima
	JNZ loop_teclados					; Se não for, então volta ao loop


	CALL processo_displays				; Processo com lógica dos displays
	CALL processo_nave					; Processo com lógica da nave
	CALL processo_meteoro				; Processo com lógica dos meteoros
	CALL processo_interrupções			; Processo de que gere as interrupções
	CALL processo_mísseis				; Processo com lógica dos mísseis
	;CALL processo_pausa
	;CALL processo_morte
	;CALL mísseis

	MOV	 R1, FUNDO_INICIO			    ; Cenário de fundo inicial
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; Seleciona o cenário de fundo
start_game:
	CALL esconde_ecrãs					; Esconde todos os ecrãs
	MOV R3, [TECLA_CARREGADA]			; Fica no Lock até uma tecla ser clicada
	MOV R7, 0
	MOV [TECLA_CONTINUA], R7			; Indica ao teclado que a tecla é para ser pressionada 1 só vez
	MOV R4, TECLA_START_GAME			
	CMP R3, R4							; Verifica se a tecla clicada é a START_GAME
	JNZ start_game						; Se não for, então volta ao loop

	;MOV  [APAGA_AVISO], R1	    		; Apaga o aviso de nenhum cenário selecionado 
	MOV R1, FUNDO_JOGO					; Cenário de fundo Jogo
	MOV [SELECIONA_CENARIO_FUNDO], R1	; Seleciona o cenário de fundo
	MOV R1, 100							; Energia a 100%
	MOV [ENERGIA], R1					; Inicializa a energia a 100
	CALL inicia_energia_display
	CALL recomeçar_meteoros				; Coloca os meteoros numa posição pseudo-aleatória
	CALL mostra_ecrãs					; Mostra todos os ecrãs




;	EI0 								; Ativa a interrupção 0
;	EI1 								; Ativa a interrupção 1
;   EI

	MOV R7, 0
	MOV [interrupt_stop], R7				; Liga as interrupções
	MOV R7, 1
	MOV [interrupções], R7				; Liga as interrupções
espera_movimento:						; Espera até o teclado ler algo
	MOV R3, [TECLA_CARREGADA]			; Fica no Lock até a tecla ser pressionada

mover_p_esquerda:						; Move a nave para a esquerda
	CMP R3, TECLA_ESQUERDA
	JNZ mover_p_direita
	MOV R9, -1
	CALL inicio_ciclo_atraso
	MOV [evento_mover_nave] , R9
	JMP tecla_é_continua
mover_p_direita:
	MOV R7, TECLA_DIREITA
	CMP R3, R7
	JNZ tecla_missil
	CALL inicio_ciclo_atraso
	MOV R9, 1
	MOV [evento_mover_nave] , R9
	JMP tecla_é_continua
tecla_missil:
	MOV R7, 1
	CMP R3, R7
	JNZ pausa_jogo
	MOV [evento_disparar_míssil] , R9
pausa_jogo:
	MOV R7, TECLA_PAUSA_JOGO
	CMP R3, R7
	JNZ fim_jogo
	MOV R4, 0
	MOV [TECLA_CONTINUA], R4			; Indica ao teclado que a tecla é para ser pressionada 1 só vez
	JMP inicio_cenário_de_pausa
fim_jogo:
	MOV R7, TECLA_FIM_JOGO
	CMP R3, R7
	JNZ acaba_jogo
	MOV R7, FUNDO_TERMINA_JOGO
	MOV [SELECIONA_CENARIO_FUNDO], R7	; Seleciona o cenário de fundo
	MOV R7, 0
	MOV [TECLA_CONTINUA], R7
	MOV R7, 1
	MOV [interrupt_stop], R7
	JMP start_game
acaba_jogo:
	MOV R7, TECLA_ACABA_JOGO
	CMP R3, R7
	JNZ nao_tecla
	MOV R7, 0
	MOV [TECLA_CONTINUA], R7
	MOV R7, 1
	MOV [interrupt_stop], R7
	JMP start_game
nao_tecla:
tecla_é_continua:
	MOV R7, 1
	MOV [TECLA_CONTINUA], R7
	JMP espera_movimento
tecla_n_continua:
	MOV R7, 0
	MOV [TECLA_CONTINUA], R7
	JMP espera_movimento
inicio_cenário_de_pausa:
	CALL esconde_ecrãs					; Esconde todos os ecrãs
	MOV R4, 1
	MOV [interrupt_stop], R4			; Desliga as interrupções
	MOV R4, FUNDO_PAUSA					; Cenário de fundo Pausa
	MOV [SELECIONA_CENARIO_FUNDO], R4	; Seleciona o cenário de fundo
	MOV R4, 0							; Tecla Não Continua
cenário_de_pausa:
	MOV R3, [TECLA_CARREGADA]			; Fica no Lock até uma tecla ser clicada
	MOV [TECLA_CONTINUA], R4			; Indica ao teclado que a tecla é para ser pressionada 1 só vez (R4 = 0)
	CMP R3, R7							; Verifica se a tecla clicada é a START_GAME
	JNZ cenário_de_pausa				; Se não for, então volta ao loop
	MOV R7, FUNDO_JOGO					; Cenário de fundo Pausa
	MOV [SELECIONA_CENARIO_FUNDO], R7	; Seleciona o cenário de fundo
	CALL mostra_ecrãs					; Mostra todos os ecrãs
	MOV [interrupt_stop], R4			; Liga as interrupções
	JMP espera_movimento





esconde_ecrãs:						; Esconde os ecrãs
	PUSH R1							; Guarda o valor de R1
	MOV R1, 5						; Número de ecrãs a esconder
ciclo_esconde_ecrãs:
	SUB R1,1						; Decrementa o index do ecrã a esconder
	MOV [ESCONDE_ECRÃ_N], R1		; Esconde o ecrã
	CMP R1, 0						; Verifica se o index do ecrã a esconder é 0
	JNZ ciclo_esconde_ecrãs			; Se não for, então volta ao loop
	POP R1							; Restaura o valor de R1
	RET 


mostra_ecrãs:						; Esconde os ecrãs
	PUSH R1							; Guarda o valor de R1
	MOV R1, 5						; Número de ecrãs a esconder
ciclo_mostra_ecrãs:
	SUB R1,1						; Decrementa o index do ecrã a mostrar
	MOV [MOSTRA_ECRÃ_N], R1			; Mostra o ecrã
	CMP R1, 0						; Verifica se o index do ecrã a mostrar é 0
	JNZ ciclo_mostra_ecrãs			; Se não for, então volta ao loop
	POP R1							; Restaura o valor de R1
	RET 








PROCESS SP_nave
processo_nave:
inicialização:
	MOV R0, ECRÃ_NAVE				; R0 recebe o ecrã da nave					
	MOV [SELECIONA_ECRÃ_N], R0	
	MOV R2, COLUNA_INICIAL_NAVE		; R2 recebe a coluna inicial da nave
	MOV R4, 0
	CALL desenha_col_offset			; Desenha a coluna de offset
loop_nave:
	MOV R0, ECRÃ_NAVE				; R0 recebe o ecrã da nave					
	MOV [SELECIONA_ECRÃ_N], R0	
	MOV R4, [evento_mover_nave]		; R4 recebe o evento de mover a nave
	CMP R4, 0
	JLT nave_para_esquerda
nave_para_direita:
	MOV	R6, [DEF_NAVE+2]			; Obtém a largura da nave (2º elemento da tabela DEF_NAVE)
	MOV R2, [POSIÇAO_NAVE]   		; Vai buscar a Coluna onde a Nave se encontra
	ADD R6, R2                 		; Obtém a posiçao da última coluna da nave
	MOV	R5, MAX_COLUNA				; Obtem ultima coluna à direita do ecrã i
	CMP	R6, R5						; Verifica se a ultima coluna da nave ja se encontra na Coluna Limite Direito
	JGE	fim_mover   				; Caso a nave já ocupe a ultima coluna, não se move 
	JMP mover
nave_para_esquerda:
	MOV	R5, MIN_COLUNA          	; Guarda a Coluna do Limite Esquerdo em R4
	MOV R2, [POSIÇAO_NAVE]      	; Vai buscar a Coluna onde a Nave se encontra
	CMP	R2, R5                  	; Verifica se a nave se encontra na coluna limite
	JLE	fim_mover 					; Se sim, não se pode mover   
mover:
	CALL inicio_apaga_nave      	; Apaga o Ecrã da NAVE apagando a Nave
    CALL desenha_col_offset   		; Chama a rotina que desenha da Nave
	MOV R10, 4						; R10 recebe o número de meteoros
ver_colisões:
	SUB R10, 1						; Decrementa o número de meteoros
	JN fim_mover 					; Se não houver mais meteoros, para de verificar
	MOV R11, R10					; Copia R10 para R11 
	SHL R11, 3						; Multiplica por 8 encontrando a posição na tabela
	MOV R5, TABELA_METEOROS			; R5 recebe o inicio da tabela de meteoros
	ADD R11, R5						; R11 recebe Linha da Tabela de Meteoros
	CALL colisões_nave				; Chama a rotina que verifica se há colisão
	CMP R5, TIPO_METEORO_MAU		; Verifica se há colisão
	JNZ ver_colisões				; Se não, continua a verificar
fim_mover:
	JMP loop_nave
	


; *
; * INICIO_APAGA_NAVE - Apaga a nave, começando por obter a posição 
; *  da nave e apagando-a linha a linha, num ciclo.
; *
inicio_apaga_nave:
	PUSH R9	
	PUSH R8	
	PUSH R6								; Guarda todos os registos utilizados
	PUSH R5
	PUSH R3
	MOV R3,	ECRÃ_NAVE					; R3 recebe a coluna onde a nave se encontra
	MOV [SELECIONA_ECRÃ_N], R3
    MOV R9, LINHA_NAVE					; obtém a linha onde começa a nave
    MOV R8, [DEF_NAVE]					; obtém a altura da nave que serve como contador de linhas
	MOV	R3, 0			        		; para apagar, a cor do pixel é 0
	JMP apaga_linha_nave
apaga_linha_nave:		
	MOV	R6, [POSIÇAO_NAVE]				; cópia da coluna da nave
	MOV	R5, [DEF_NAVE+2]				; obtém a largura da nave
apaga_pixels_nave:       				
	MOV  [DEFINE_LINHA], R9	    		; seleciona a linha
	MOV  [DEFINE_COLUNA], R6			; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	    		; altera a cor do pixel na linha e coluna selecionadas
    ADD  R6, 1                  		; Passa à próxima coluna
    SUB  R5, 1			        		; Reduz o contador de colunas por apagar
    JNZ  apaga_pixels_nave				; Continua até percorrer toda a largura do objeto
	ADD R9, 1                   		; Passa à linha seguinte
    SUB R8, 1                   		; Reduz o contador das linhas por apagar
	JNZ apaga_linha_nave        		; Vai apagar a próxima linha da nave
	POP R3
	POP R5
	POP R6								; Repõe todos os registos utilizados
	POP R8
	POP R9
    RET


; *
; * COLISÕES_NAVE - Deteta Colisões com a Nave.
; * Argumetos: R11 - Linha da Tabela de Meteoros
; *			   R10 - Index do meteoro
; * Retorna: R5 - Evento de Colisão 0 - Não houve colisão caso contrário passa o tipo de meteoro
colisões_nave:
	PUSH R3
	PUSH R4
	PUSH R11
	MOV	R5, LINHA_NAVE					; R5 recebe a Linha onde a nave  encontra
	MOV R4, [R11 + 6]					; R4 recebe a Linha onde se encontra o Meteoro
	MOV R3, [R11 + 2]					; Endereço da Tabela que define Meteoro
	MOV R3, [R3]						; R3 recebe a Altura/Largura do Meteoro (São sempre iguais)
	ADD R4, R3							; Adiciona a Altura do Meteoro à Linha do Meteoro
	CMP R4, R5							; Verifica se a nave se encontra abaixo da linha do meteoro
	JLE não_colide						; Se não, não há colisão
	MOV R5, [POSIÇAO_NAVE]				; R5 recebe a Coluna onde a nave se encontra
	MOV R4, [R11 + 4]					; R4 recebe a Coluna do Meteoro
	ADD R4, R3							; Adiciona a largura do meteoro à coluna do meteoro
	CMP R5, R4							; Verifica se a esquerda da nave se encontra à esquerda da coluna direita do meteoro
	JGE não_colide						; Se não, não há colisão
	ADD R5, LARGURA_NAVE				; Adiciona a largura da nave à coluna da nave
	SUB R4, R3							; Subtrai a largura do meteoro à coluna do meteoro
	CMP R5, R4							; Verifica se a direita da nave se encontra à direita da coluna esquerda do meteoro
	JLE não_colide						; Se não, não há colisão
	MOV R5, [R11]						; Se há colisão, R5 recebe o tipo de meteoro
	CMP R5, TIPO_METEORO_BOM
	JNZ colisão_mau
colisão_bom:
	MOV R6, SOM_PATO_PAO					; Põe o index do barulho bom em R6
	MOV [TOCA_SOM], R6					; Toca o barulho bom
	MOV R6, 1							; Muda o valor de R6 para 1
	MOV [evento_energia], R6			; Aumenta a energia
	CALL apaga_meteoro
	MOV R6, TABELA_METEOROS					
	SUB R11, R6 						; Argumento para decisões_novo_meteoro
	CALL decisões_novo_meteoro
	JMP fim_colisões_nave
colisão_mau:
	MOV R6, SOM_PATO_POMBO			; Põe o index do barulho bom em R6
	MOV [TOCA_SOM], R6					; Toca o barulho bom
	MOV R6, 2
	MOV [interrupções], R6
	MOV R6, TECLA_ACABA_JOGO			; Muda o valor de R6 para 1
	MOV [TECLA_CARREGADA], R6			; Aumenta a energia
	MOV R7, FUNDO_GAME_OVER_METEORO     ; Imagem de Game over
	MOV [SELECIONA_CENARIO_FUNDO], R7	; Seleciona a imagem de Game over
	CALL apaga_meteoro
	MOV R6, 1
	MOV [interrupt_stop], R6
	JMP fim_colisões_nave
não_colide:
	MOV R5, 0							; Se não há colisão, R5 recebe 0
fim_colisões_nave:
	POP R11
	POP R4
	POP R3
	RET
	


; ******************************************************	
; *				  Rotinas de Interrupção	 		   *
; ******************************************************	

	
; *
; * Rotina de interrupção relativa ao pino 0 (Meteoros)
; *
rot_int_0:								
	PUSH R0
	MOV R0, [interrupt_stop]				; Se o jogo está em pausa ou terminado, o LOCK "evento_mover_meteoros" não é ativado.
	CMP R0, 1
	JZ rot_int_0_fim
	MOV  [evento_mover_meteoros], R0		; Desbloqueia o evento de mover meteoros (R0 não é importante)
rot_int_0_fim:
	POP R0
	RFE


; *
; * Rotina de interrupção relativa ao pino 1 (Míssil)
; *
rot_int_1:								
	PUSH R0
	MOV R0, [interrupt_stop]			; Se o jogo está em pausa ou terminado, o LOCK "evento_mover_míssil" não é ativado.
	CMP R0, 1
	JZ rot_int_1_fim
	MOV [evento_mover_míssil], R0		; Desbloqueia o evento de mover mísseis
rot_int_1_fim:
	POP R0
	RFE

; *
; * Rotina de interrupção relativa ao pino 2 (Energia)
; *
rot_int_2:
	PUSH R0
	MOV R0, [interrupt_stop]			; Se o jogo está em pausa ou terminado, o LOCK "evento_energia" não é ativado.
	CMP R0, 1
	JZ rot_int_2_fim
	MOV R0, -1
	MOV [evento_energia], R0			; Desbloqueia o evento de variar a energia (diminui)
rot_int_2_fim:
	POP R0
	RFE




; *
; * [Processo]
; *
; * processo_interrupções - Liga as interrupções e mantém-nas enquanto o jogo está a correr.
; *
PROCESS SP_interrupt
processo_interrupções:
	WAIT
	MOV R1, [interrupções]
	CMP R1, 0
	JZ processo_interrupções
	CMP R1, 2
	JZ desligar_int
ligar_int:
	EI0
	EI1
	EI2
	EI
	JMP restart_interrupt
desligar_int:
	DI
	DI0
	DI1
	DI2
restart_interrupt:	
	MOV R0, 0
	MOV [interrupções], R0
	JMP processo_interrupções

PROCESS SP_displays
processo_displays:
loop_displays:
	MOV R0 , [evento_energia]			; Carrega o valor da variável evento_energia
	CMP R0, 0							; Verifica se o valor é 0
	JLT diminuir_displays				; Se for inferior, diminui o valor do displays
	CALL aumenta_energia_display		; Caso contra
	JMP loop_displays
diminuir_displays:
	CALL diminui_energia_display
	JMP loop_displays
;bloqueia_displays:
;	RET


;PROCESS SP_inicial_teclado_1
; * [Processo]
; *
; * TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor da tecla lida
; * Argumentos:	R11 - linha a testar (em formato 1, 2, 4 ou 8)
; *
PROCESS SP_inicial_teclado_1
teclado:
	MOV  R2, TEC_LIN   					; Endereço do periférico das linhas
	MOV  R3, TEC_COL   					; Endereço do periférico das colunas
	MOV  R5, MASCARA   					; Para isolar os 4 bits de menor peso, ao ler as colunas do teclado

	MOV  R1, R11						; Número da linha a testar (R11 vem em formato (0, 1, 2, 3))
	SHL  R1, 1
	MOV  R10, SP_TECLADO
	MOV  SP, [R10 + R1]

	MOV  R6, 1 
loop_fix_linha:
	CMP  R11, 0
	JZ end_fix_linha
	SHL  R6, 1
	SUB  R11, 1
	JMP loop_fix_linha
end_fix_linha:
	MOV  R1, R6

espera_tecla:							; Neste ciclo, espera-se até uma tecla ser premida

	WAIT 								; Este ciclo é potencialmente bloqueante, pelo que tem de
										; ter um ponto de fuga (aqui pode comutar para outro processo)

	MOVB [R2], R1 						; Escrever no periférico de saída (linhas)
	MOVB R0, [R3]      					; Ler do periférico de entrada (colunas)
	AND  R0, R5        					; Elimina bits para além dos bits 0-3
	CMP R0, 0							; Verifica se foi detetada alguma tecla carregada
	JZ espera_tecla						; Se nenhuma tecla for premida, repete

	CALL formata_tecla					; Converte o valor da linha e o da coluna no valor da tecla lida
										; (retorna um valor entre 0H e FH, consoante o valor da tecla lida)
	MOV [TECLA_CARREGADA], R0			; Informa quem estiver bloqueado neste LOCK que uma tecla foi carregada

	MOV R7, [TECLA_CONTINUA]			; Informa quem estiver bloqueado neste LOCK que uma tecla está a ser carregada
	CMP R7, 0							; Se a tecla lida não for a tecla de continuar, então é a tecla de sair
	JNZ espera_tecla
espera_nao_tecla:						; Neste ciclo, espera-se até NENHUMA tecla estar premida

	YIELD								; Este ciclo é potencialmente bloqueante, pelo que tem de
										; ter um ponto de fuga (aqui pode comutar para outro processo)

	CALL formata_tecla					; Converte o valor da linha e o da coluna no valor da tecla lida
										; (retorna um valor entre 0H e FH, consoante o valor da tecla lida)

	MOVB [R2], R1 						; Escrever no periférico de saída (linhas)
	MOVB R0, [R3]      					; Ler do periférico de entrada (colunas)
	AND  R0, R5        					; Elimina bits para além dos bits 0-3
	CMP R0, 0							; Verfica se há uma tecla premida
	JNZ espera_nao_tecla				; Se ainda houver uma tecla premida, repete

	JMP espera_tecla					; Inicia-se um ciclo infinito, uma vez que o programa
										; nunca deve parar de verificar inputs do teclado
										; (enquanto o jogo não estiver pausado ou parado)





; *
; * ATRASO - Executa um ciclo para implementar um atraso.
; * Argumentos:	R11 - valor que define o atraso
; *
; *

inicio_ciclo_atraso:
	PUSH R11
	MOV R11, ATRASO							
ciclo_atraso:							; Ciclo usado para "fazer tempo" entre movimentos sucessivos de naves e meteoros
	SUB	R11, 1
	YIELD								
	JNZ	ciclo_atraso					; Espera até que, por subtrações sucessivas, R11 fique a 0
	POP R11
	RET




; **************************************	
; *				  Display	 		   *
; **************************************	


; *
; * INICIA_ENERGIA_DISPLAY - Inicializa o display de energia
; *  Inicia o Display com o valor da energia que está na memória 
; *

inicia_energia_display:
	PUSH R0								; Guarda o valor de R0
	PUSH R4								; Guarda o valor de R4
	MOV R0, [ENERGIA]					; Coloca em R0 o valor inicial da energia
	CALL energia_para_decimal			; Converte o valor da energia para decimal
	MOV [ENDEREÇO_DISPLAY], R4			; Coloca o valor inicial no display
	POP R0								; Repõe o valor de R0			
	POP R4								; Repõe o valor de R4
	RET

; *
; * AUMENTA_ENERGIA_DISPLAY - Aumenta o valor de energia da nave
; *  Usa a memória para calcular e guardar o valor da energia
; *   e dá output para o Display 
; *
aumenta_energia_display:
	PUSH R0								; Guarda o valor de R0
	PUSH R1								; Guarda o valor de R1
	PUSH R4 							; Guarda o valor de R4
	MOV R0, [ENERGIA]					; Coloca em R0 o valor inicial da energia
	MOV R1, ENERGIA_INICIAL			
	SUB R1,R0
	CMP R1, VALOR_ENERGIA_AUMENTO		; Se a energia for maior que 5, não altera
	JLT exit_aumenta_energia_display
	ADD R0, 5
	MOV [ENERGIA], R0					; Guarda energia na memória
	CALL energia_para_decimal			; Converte a energia para decimal
	MOV [ENDEREÇO_DISPLAY], R4			; Coloca o valor inicial no display
exit_aumenta_energia_display:
	POP R4 								; Restaura o valor de R4
	POP R1 								; Restaura o valor de R1
	POP R0								; Restaura o valor de R0
	RET

; *
; * DIMINUI_ENERGIA_DISPLAY - Aumenta o valor de energia da nave
; *  Usa a memória para calcular e guardar o valor da energia
; *   e dá output para o Display 
; *
diminui_energia_display:
	PUSH R0								; Guarda o valor de R0
	PUSH R4								; Guarda o valor de R4
	MOV R0, [ENERGIA]					; Coloca em R0 o valor inicial da energia
subtrai_energia:
	SUB R0, 5 
	MOV [ENERGIA], R0					; Guarda energia na memória
	CALL energia_para_decimal			; Converte a energia para decimal
	MOV [ENDEREÇO_DISPLAY], R4			; Coloca o valor inicial no display
	CMP R0, 0
	JNZ exit_diminui_energia_display
	MOV R0, SOM_MORTE_ENERGIA 			; Som quando pato morre por energia
	MOV [TOCA_SOM], R0					; Som quando nave morre por energia
	MOV R0, FUNDO_GAME_OVER_ENERGIA
	MOV [SELECIONA_CENARIO_FUNDO], R0 
	MOV R0, TECLA_ACABA_JOGO
	MOV [TECLA_CARREGADA], R0
exit_diminui_energia_display: 
	POP R4								; Restaura o valor de R4
	POP R0								; Restaura o valor de R0
	RET


; *
; * ENERGIA_PARA_DECIMAL - Converte o valor de hexadeximal para decimal
; * Argumentos: R0 - energia em hexadecimal
; *
; * Retorna:    R4 - energia em decimal  
energia_para_decimal:
	PUSH R0								; Guarda o valor de R0
	PUSH R1								; Guarda o valor de R1
	PUSH R2								; Guarda o valor de R2
	PUSH R3								; Guarda o valor de R3
	MOV R4, 0							; Inicializa o valor da energia a 0
	MOV R2, 10							; Inicializa o valor de R2 a 10
	MOV R1, 1000						; Coloca em R1 (fator) o valor 1000
ciclo_energia_para_decimal:
	MOD R0, R1   						; Calcula o resto da divisão
	MOV R3, R0							; Copia o valor o resto da divisão para R3
	DIV R1, R2							; Divide o fator por 10
	DIV R3, R1							; Divide o resto da divisão pelo fator
	SHL R4, 4							; Passa ao Próximo digito
	OR  R4, R3							; Adiciona o resto ao valor da energia
	CMP R1, R2							; Se o fator for <10, sai da rotina
	JGE ciclo_energia_para_decimal
	POP R3								; Restaura o valor de R3
	POP R2								; Restaura o valor de R2
	POP R1								; Restaura o valor de R1
	POP R0								; Restaura o valor de R0
	RET


; *
; * DESENHA_COL_OFFSET - Desenha a nave na posição (coluna) desejada, começando por 
; *  obter a sua posição e desenhando-a, linha a linha, num ciclo.
; * Argumentos: R2 - Coluna onde a nave se encontra
; *				R4 - offset (descreve o sentido do movimento ou a não existência do mesmo)
; *
desenha_col_offset:
    PUSH R9
    PUSH R8
	PUSH R6
	PUSH R5								; Guarda todos os registos utilizados
    PUSH R4
	PUSH R2
	ADD	R2, R4			        		; Altera a coluna consoante o sentido do movimento 
	MOV [POSIÇAO_NAVE], R2				; Atualiza a coluna onde começa o desenho da nave
    MOV R9, LINHA_NAVE          		; Obtém a linha onde começa a nave
    MOV R8, [DEF_NAVE]					; Cópia da altura (contador de linhas)
    MOV	R4, DEF_NAVE		    		; Endereço da tabela que define a nave
    ADD R4, 4			        		; Endereço da cor do 1º pixel 
desenha_linha_nave:       				
	MOV	R6, [POSIÇAO_NAVE]				; Cópia da coluna da nave
	MOV	R5, [DEF_NAVE+2]				; Obtém a largura da nave (contador de colunas)
desenha_pixels_nave:       				
	MOV	R2, [R4]			    		; Obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	    		; Seleciona a linha
	MOV  [DEFINE_COLUNA], R6			; Seleciona a coluna
	MOV  [DEFINE_PIXEL], R2	    		; Altera a cor do pixel na linha e coluna selecionadas
	ADD	 R4, 2			        		; Endereço da cor do próximo pixel 
    ADD  R6, 1                  		; Passa à próxima coluna
    SUB  R5, 1			        		; Reduz o contador de colunas por tratar
    JNZ  desenha_pixels_nave    		; Continua até percorrer toda a largura do objeto
	ADD R9, 1                   		; Aumenta a linha
	SUB R8, 1							; Reduz contador das linhas por desenhar
    JNZ desenha_linha_nave				; Vai desenhar a próxima linha da nave		
	POP R2
	POP R4
    POP R5								; Repõe todos os registos utilizados
	POP R6
	POP R8
    POP R9
	RET



; * (Rotina auxiliar)
; * FORMATA_TECLA - Converte o valor da linha lida e da coluna lida no valor da tecla lida (0H até FH)
; * Argumentos: R1 - valor da linha lida em (1, 2, 4, 8)
; *				R0 - valor da coluna lida em (1, 2, 4, 8)
; *
; * Retorna:    R0 - valor da tecla lida em (0, 1, 2, 3)   
; *
formata_tecla:
	PUSH R1
	CALL formata_linha					; caso haja uma tecla premida, converte o valor da linha lida
										; de (1, 2, 3, 4) para (0, 1, 2, 3)
	CALL formata_coluna					; e faz a mesma operação para o valor da coluna lida
	MOV TEMP, 4
	MUL R1, TEMP
	ADD R0, R1							; O valor da tecla é definido como sendo:
										; 	tecla = 4 * linha + coluna
	POP R1
	RET



; * (Função auxiliar)
; * FORMATA_LINHA - Converte o valor da linha lida de (1, 2, 4, 8) em (0, 1, 2, 3)
; * Argumentos: R1 - valor da linha lida em (1, 2, 4, 8)
; *
; * Retorna:    R1 - valor da linha lida em (0, 1, 2, 3)   
; *
formata_linha:
   MOV TEMP, -1
formata_linha_ciclo:                    ; Para converter o valor da linha lida
   ADD TEMP, 1                         	; de (1, 2, 3, 4) para (0, 1, 2, 3)
   SHR R1, 1                           	; contamos o número de vezes que é preciso fazer SHR ao valor da linha
   CMP R1, 0                           	; para obter 0
   JNZ formata_linha_ciclo
   MOV R1, TEMP
   RET
 
; * (Função auxiliar)
; * FORMATA_COLUNA - Converte o valor da coluna lida de (1, 2, 4, 8) em (0, 1, 2, 3)
; * Argumentos: R0 - valor da coluna lida em (1, 2, 4, 8)
; *
; * Retorna:    R0 - valor da coluna lida em (0, 1, 2, 3)  
; *
formata_coluna:
   MOV TEMP, -1
formata_coluna_ciclo:                   ; Para converter o valor da coluna lida
   ADD TEMP, 1                         	; de (1, 2, 3, 4) para (0, 1, 2, 3)
   SHR R0, 1                           	; contamos o número de vezes que é preciso fazer SHR ao valor da linha
   CMP R0, 0                          	; para obter 0
   JNZ formata_coluna_ciclo
   MOV R0, TEMP
   RET

;; **************************************	
;; *				 Meteoros  	 		*
;; **************************************	









; *
; * [Processo]
; *
; * PROCESSO_METEORO - Cria e movimenta os meteoros ao longo do jogo, quando a interrupção 0 é ativada pelo relógio dos meteoros.
; *
PROCESS SP_Meteoro
processo_meteoro:	
	;MOV R6, [interrupções]
inicialização_processo_meteoro:
	MOV R4, 0 							; desenhar pela primeira vez sem movimentar
	MOV R10, 3							; Número de meteoros a desenhar -1
	JMP ciclo_processo_meteoro
;ideias: contador que decide quantos meteoros existem dependendo das vezes que se moveram; ou somehow fases
inicio_ciclo_processo_meteoro:
	MOV R0, [evento_mover_meteoros]		; quando o lock é ativado pelo relógio, o meteoro move-se
	MOV R4, 1 							; indicador do número de linhas que cada meteoro desce (sempre 1 exceto no início)
	MOV R10, 3							; Número de meteoros a desenhar -1 | R10 vai ser o Index do meteoro
ciclo_processo_meteoro:
	MOV R11, R10
	SHL R11, 3							; valor a somar para obter linha da tabela correspondente ao meteoro
	CALL apaga_meteoro
	CALL linha_seguinte
	MOV R5, TABELA_METEOROS
	ADD R11, R5
	CALL colisões_nave
	CMP R5, 0							
	JNZ ciclo_processo_meteoro			; caso colida
continuação_ciclo:
	SUB R10, 1
	JN inicio_ciclo_processo_meteoro
	JMP ciclo_processo_meteoro





; * LINHA_SEGUINTE - Desenha o meteoro na posição desejada (1 linha abaixo), começando por 
; *  obter a sua posição e desenhando-o, linha a linha, num ciclo.
; * Argumentos:  R4 - offset (descreve o sentido do movimento ou a não existência do mesmo)
; * 			 R11 - Valor a somar à tabela de meteoros para obter o tipo do meteoro a apagar 
; * 			 R10 - Número do ecrã do meteoro a apagar
; * (ou seja, a linha da tabela que lhe corresponde)
linha_seguinte:
	PUSH R1
	PUSH R2
	PUSH R3 
	PUSH R4
	PUSH R5								; Guarda todos os registos utilizados
	PUSH R6
	PUSH R7						
	PUSH R8
	PUSH R9
	PUSH R11
	MOV [SELECIONA_ECRÃ_N], R10			; Seleciona o Ecrã do Meteoro
	ADD R11, 2							; Obtém valor a somar para obter endereço para a tabela que define o meteoro a desenhar
	MOV R2, R11							
	ADD R2, 4							; Valor a somar para obter linha do ecrã do meteoro
	MOV R9, TABELA_METEOROS
	ADD R2, R9							; Obtém endereço para a linha do meteoro
	MOV R9, [R2]						; Vai buscar a linha do meteoro à memória
	ADD R9, R4							; Obtém a linha seguinte onde desenhar o meteoro	(0 se for a primeira vez a desenhar)
	MOV [R2], R9						; Atualiza a linha inicial do meteoro
evolução_meteoro:
	MOV R7, 11
	CMP R9, R7							; Se estiver numa linhaa superior a 11 não há evolução
	JGT inicio_desenha_meteoro
	MOV R7, R9							; Copia linha inicial do meteoro para R7
	ADD R7, 1							; Soma-lhe 1 para verificar se será igual às linhas de evolução após lhes ser adicionado 1 a todas, pois ficam múltiplas de 3
	MOV R4, R7							; Copia esse valor para R4
	MOV R2, 3
	MOD R4, R2							; Se a linha onde está não for múltipla de 3, não há evolução
	JNZ inicio_desenha_meteoro
	DIV R7, R2							; Obtém número da linha do meteoro na tabela de evolução
	SUB R7, 1							; Converte número da linha (1 a 4) para índice (0 a 3)
	MOV R2, 6
	MUL R7, R2							; Obtém valor a somar ao endereço da tabela de evolução para obter endereço da linha da tabela correspondente
	MOV R2, TABELA_METEOROS
	ADD R2, R11							; Obtém endereço para a tabela que define o meteoro a desenhar
	MOV R4, [R2-2]						; Verifica o tipo de meteoro (bom ou mau)
	ADD R7, R4							; Soma 2 se for meteoro mau e 4 se for bom para obter valor a somar à tabela de evolução para obter endereço do novo desenho
	MOV R4, TABELA_LINHAS_EVOLUÇÃO_METEOROS
	MOV R4, [R7+R4]						; Obtém o endereço do novo desenho para o meteoro
	MOV [R2], R4						; Atualiza o endereço do desenho do meteoro na tabela de meteoros
inicio_desenha_meteoro:
    MOV R7, TABELA_METEOROS
	MOV R4, [R7+R11]					; Obtém o endereço da tabela que define o meteoro
	MOV R8, [R4]   						; Obtém a altura do meteoro
    ADD R4, 4           				; Obtém o endereço da cor do 1º pixel 
	MOV R1, MAX_LINHA					; Obtém o endereço da última linha do ecrã
	CMP R9, R1							; Verifica se a próxima linha do meteoro está fora do ecrã 
	JGT meteoro_fora_do_ecrã			; Nesse caso, interrompe o desenho, pois todo o meteoro já ultrapassou o ecrã 
desenha_meteoro:       						
    MOV R1, MAX_LINHA					; Obtém o endereço da última linha do ecrã
	CMP R9, R1							; Verifica se a próxima linha do meteoro está fora do ecrã 
	JGT acaba_desenho_meteoro			; Nesse caso, interrompe o desenho, pois o resto do meteoro já ultrapassou o ecrã 
	MOV R6, R11
	ADD R6, 2							; valor a somar ao endereço da tabela para obter coluna do meteoro
	MOV R6, [R7+R6]						; Cópia da primeira coluna do meteoro
	MOV R5, [R7+R11]					; Obtém o endereço da tabela que define o meteoro
	MOV	R5, [R5+2]						; Obtém a largura do meteoro
desenha_pixels_meteoro:       		
	MOV	R3, [R4]						; Obtém a cor do próximo pixel 
	MOV [DEFINE_LINHA], R9				; Seleciona a linha
	MOV [DEFINE_COLUNA], R6				; Seleciona a coluna
	MOV [DEFINE_PIXEL], R3				; Altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2							; Obtém endereço da cor do próximo pixel 
    ADD R6, 1               			; Passa à próxima coluna
    SUB R5, 1							; Reduz o contador de colunas por desenhar
    JNZ desenha_pixels_meteoro 			; Continua até percorrer toda a largura do objeto
	ADD R9, 1               			; Avança para a linha seguinte
	SUB R8, 1							; Reduz o contador das linhas por desenhar
    JNZ desenha_meteoro					; Vai desenhar a próxima linha do meteoro
acaba_desenho_meteoro:
	POP R11
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5								; Repõe todos os registos
	POP R4
	POP R3
	POP R2
	POP R1
	RET
meteoro_fora_do_ecrã:
	SUB R11, 2							; Valor a somar à tabela de meteoros para obter o tipo do meteoro a reiniciar
	CALL decisões_novo_meteoro			; Atualiza a posição do meteoro para uma pseudo-aleatória
	JMP acaba_desenho_meteoro



; *
; * APAGA_METEORO - Rotina que apaga o meteoro mau, apagando o ecrã correspondente ao seu índice.
; * Argumentos: R10 - Índice do meteoro.
; *				
apaga_meteoro:
	MOV [APAGA_ECRÃ_N], R10				; Apaga o Ecrã do Meteoro
    RET

; * DECISÕES_NOVO_METEORO - Rotina chamada sempre que uma nave inimiga é destruída, um meteoro bom colide com o rover 
; * 	ou qualquer deles se perde no fundo, para definir os parâmetros do novo meteoro (posição, tipo e desenho).
; * Argumento: 	R11- Valor a somar para aceder ao endereço da tabela que define o tipo de meteoro a criar.
decisões_novo_meteoro:
	PUSH R0
	PUSH R3
	PUSH R4
	PUSH R10
	PUSH R11
inicio_decisões:
	MOV  R3, TEC_COL   					; Endereço do periférico das colunas
	MOVB R0, [R3]      					; Ler do periférico de entrada (colunas)
	SHR R0, 5							; Isolar os bits 5 a 7
	MOV R3, 8							
	MUL R0, R3							; Para dar uma coluna multipla de 8 | R0 = Coluna 
	MOV R10, 3							; R10 = Indices de meteoros						
teste_posição_ideal:
	MOV R4, R10 						; Copia o indice
	SHL R4, 3							; Obtém a posição na tabela
	MOV R3, TABELA_METEOROS
	ADD R4, R3							; Obtém o endereço da tabela
	MOV R4, [R4+4]						; Obtém a coluna a partir da tabela
	CMP R0, R4							; Compara a coluna com a coluna do meteoro
	JZ inicio_decisões
	SUB R10, 1							; Decrementa o indice
	JNN teste_posição_ideal
inicialização_novo_meteoro:
	MOV R3, R11							; R3 = Linha na tabela do meteoro que está a ser gerado
	ADD R3, 2						
	MOV R4, DEF_METEORO_1X1
	MOV R10, TABELA_METEOROS
	ADD R3, R10
	MOV [R3], R4						; guarda o endereço para a tabela do meteoro 1x1 no novo meteoro
	ADD R3, 2							; obtém valor a somar ao endereço da tabela de meteoros para obter a coluna do meteoro
	MOV [R3], R0						; escreve na memória a coluna do meteoro novo
	ADD R3, 2
	MOV R4, 0
	MOV [R3], R4						; novo meteoro surgirá na linha 0
	MOV R4, 16
	CMP R0, R4
	JLE escolha_meteoro_bom				; definição semi-aleatória do tipo do meteoro
escolha_meteoro_mau:
	MOV R4, TIPO_METEORO_MAU			; atualiza o tipo de meteoro (mau)
	ADD R11, R10
	MOV [R11], R4
	JMP fim_decisões_novo_meteoro
escolha_meteoro_bom:
	MOV R4, TIPO_METEORO_BOM			; atualiza o tipo de meteoro (bom)
	ADD R11, R10
	MOV [R11], R4
fim_decisões_novo_meteoro:
	POP R11
	POP R10
	POP R4
	POP R3
	POP R0
	RET




; **************************************
; *				 Mísseis	 		   *
; **************************************


;PROCESS SP_míssil
; * [Processo]
; *
; * PROCESSO_MÍSSEIS - Cria o míssil disparado pela nave (quando a tecla 1 é premida), e movimenta-o quando
; *  a interrupção 1 (do relógio dos mísseis) ativa a LOCK "evento_mover_míssil". Verifica também se o míssil atingiu algum meteoro, 
; *  desencadeando, nesse caso, os acontecimentos associados (possível subida da energia, efeitos sonoros e visuais, etc).
; *
PROCESS SP_míssil
processo_mísseis:						; Controla os mísseis
inicio_processo_mísseis:
	MOV R0, [evento_disparar_míssil]	; Lock para quando começar o evento
	MOV R0, -1
	MOV [evento_energia], R0
	MOV R3, 13							; Contador de movimentos do míssil (máximo é 12) - 
inicialização_míssil:					; 		    - definido como 13 para comparar com 0
	MOV R0, SOM_DISPARO_MÍSSIL			; Som do disparo do míssil
	MOV [TOCA_SOM], R0					; Toca o som do disparo do míssil
	MOV R2, LINHA_NAVE
	MOV [LINHA_ATUAL_MISSIL], R2
	MOV R1, [POSIÇAO_NAVE]				; Obtém a coluna da nave
	ADD R1, 2							; Obtém a coluna do meio da nave, de onde sai o míssil
ciclo_mísseis:
	CALL desenha_míssil
inicio_verifica_colisão:
	MOV R10, 4							; contador dos meteoros com que se vai avaliar a existência de colisão
	MOV R2, [LINHA_ATUAL_MISSIL]		; Obtém a linha onde se encontra o míssil
verifica_colisão:
	SUB R10, 1							; R10 assume o índice do meteoro que se vai avaliar (argumento para a rotina linha_seguinte caso haja colisão)
	JN não_houve_colisão
	MOV R6, TABELA_METEOROS				; Aponta para a tabela de meteoros
	MOV R5, R10							; Copia o índice do meteoro que vai ser avaliado 
	SHL R5, 3							; Obtém valor a somar à tabela de meteoros para obter o tipo do meteoro 
	ADD R6, R5							; Obtém o endereço para o tipo de meteoro
	MOV R7, [R6+6]						; Obtém a linha inicial do meteoro com indíce R10
	MOV R5, [R6+4]						; Obtém a coluna inicial do meteoro com indíce R4
	CMP R1, R5							; Compara a coluna do míssil com a coluna inicial do meteoro
	JLT verifica_colisão				; Se a coluna do míssil for menor que a inicial do meteoro, não há colisão (verifica próximo meteoro)
	MOV R9, [R6+2]						; Obtém o endereço para a definição do desenho do meteoro
	MOV R11, [R9]						; Obtém a largura do meteoro
	SUB R11, 1
	ADD R5, R11							; Obtém a coluna final do meteoro, somando a largura - 1 à inicial
	ADD R7, R11							; Obtém a linha final do meteoro, somando a altura - 1 à inicial 
	CMP R2, R7							; Compara a linha atual do míssil com a última linha do meteoro
	JGT verifica_colisão				; Se a linha do míssil for inferior, não pode haver colisão (verifica próximo meteoro)
	CMP R1, R5							; Compara a coluna do míssil com a última coluna do meteoro
	JGT verifica_colisão				; Se a coluna do míssil for maior que a última do meteoro, não há colisão (verifica próximo meteoro)
	JMP houve_colisão
não_houve_colisão:
	SUB R3, 1							; Diminui contador de movimentos
	JZ fim_ciclo_mísseis				; Atingiu o limite de movimentos
	MOV TEMP, [evento_mover_míssil]
	CALL apaga_míssil
	JMP ciclo_mísseis
fim_ciclo_mísseis:
	CALL apaga_míssil
	JMP inicio_processo_mísseis
houve_colisão:
	MOV R5, [R6]						; Obtém o tipo do meteoro
	CMP R5, TIPO_METEORO_MAU			; Compara o tipo do meteoro com o tipo de meteoro mau
	JZ colisão_meteoro_mau
	MOV R0, SOM_MISSIL_PAO				; Som colisão com um meteoro bom
	MOV [TOCA_SOM], R0
	MOV R5, DEF_EXPLOSÃO_METEORO_BOM	; Aponta para a definição da explosão do meteoro bom
rot_destruição:
	CALL apaga_míssil	 
	CALL apaga_meteoro					; apaga metero de indíce R10	
	MOV R4, 0							; offset 0 para não alterar a posição do meteoro (argumento para a rotina linha_seguinte)
	MOV R11, R6							; Copia o endereço do tipo do meteoro 
	MOV [R11+2], R5						; Atualiza endereço da definição do meteoro para a do meteoro explodido
	MOV R6, TABELA_METEOROS
	SUB R11, R6							; Obtém valor a somar à tabela de meteoros para obter o endereço do tipo de meteoro (argumento para a rotina linha_seguinte)
	CALL linha_seguinte
	CALL decisões_novo_meteoro
	JMP inicio_processo_mísseis
colisão_meteoro_mau:
	MOV R5, DEF_EXPLOSÃO_METEORO_MAU	; Aponta para a definição da explosão do meteoro mau
	MOV R0, SOM_MISSIL_POMBO				; Som colisão com um meteoro mau
	MOV [TOCA_SOM], R0
	MOV R0, 1
	MOV [evento_energia], R0			; Desbloqueia o evento de variar a energia (aumenta)
	JMP rot_destruição



; * DESENHA_MÍSSIL - Desenha o míssil no ecrã na linha seguinte (ou pela primeira vez, usando como linha inicial a última)
; * Argumentos - R1 - coluna onde o míssil se desloca
; * 
desenha_míssil:
	PUSH R2
	PUSH R3
	MOV R2, ECRÃ_NAVE					; Carrega o ecrã da nave em R2
	MOV [SELECIONA_ECRÃ_N], R2			; Seleciona o ecrã para desenhar o míssil
	MOV R2, [LINHA_ATUAL_MISSIL]		; Obtém a linha onde se encontra o míssil
	SUB R2, 1	
	MOV [LINHA_ATUAL_MISSIL], R2		; Atualiza a linha onde se encontrará o míssil
	MOV R3, COR_PIXEL_MISSIL
	MOV [DEFINE_LINHA], R2				; Seleciona a linha
	MOV [DEFINE_COLUNA], R1				; Seleciona a coluna
	MOV [DEFINE_PIXEL], R3				; Altera a cor do pixel na linha e coluna selecionadas
	POP R3
	POP R2
	RET

; * APAGA_MÍSSIL - Apaga o míssil do ecrã.
; * Argumentos: R1 - coluna onde o míssil se desloca
; * 
apaga_míssil:
	PUSH R3
	PUSH R2
	MOV R2, ECRÃ_NAVE					; Carrega o ecrã da nave em R2
	MOV [SELECIONA_ECRÃ_N], R2			; Seleciona o ecrã para desenhar o míssil
	MOV R2, [LINHA_ATUAL_MISSIL]		; Obtém a linha onde se encontra o míssil
	MOV R3, 0
	MOV [DEFINE_LINHA], R2				; Seleciona a linha
	MOV [DEFINE_COLUNA], R1				; Seleciona a coluna
	MOV [DEFINE_PIXEL], R3				; Apaga o míssil na linha e coluna selecionadas
	POP R2
	POP R3
	RET



recomeçar_meteoros:
    PUSH R11
    PUSH R10
    MOV R10, 3
ciclo_recomeça_meteoros:
    MOV R11, R10
    SHL R11, 3
    CALL decisões_novo_meteoro
    CALL apaga_meteoro
    SUB R10, 1
    JNN ciclo_recomeça_meteoros
    POP R10
    POP R11
    RET

