;;-----------------------------LICENSE NOTICE------------------------------------
; Shinobu is free software: you can redistribute it and/or modify
;     it under the terms of the GNU General Public License as published by
;     the Free Software Foundation, either version 3 of the License, or
;     (at your option) any later version.

;     This program is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;     GNU General Public License for more details.

;     You should have received a copy of the GNU General Public License
;     along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;
;;  INPUT SYSTEM
;;
.include "cpctelera.h.s"
.include "cpctelera_functions.h.s"
.include "keyboard/keyboard.s"
.include "sys/input.h.s"
.include "man/entity_bala.h.s"
.include "man/entity.h.s"
.include "cmp/entity.h.s"
.include "sys/hud.h.s"
.include "man/nivel.h.s"
.include "man/game.h.s"

estado: .db 0       ;; Controla el estado del juego || 0 = juego -- 1 = pausa -- 2 = game over 
sin_presionar_pause: .db 1     ;; 1 si no presiona ninguna tecla, 0 si esta presionando
sin_presionar_space: .db 1     ;; 1 si no presiona ninguna tecla, 0 si esta presionando


;; Menu input
;; DESTROY: HL
;; -------------------------------------------------------------------------------
inputsys_menu_update::

	call    cpct_scanKeyboard_asm

	ld		hl, #Key_G
	call	cpct_isKeyPressed_asm   ;;Cambia los flags si pulsas G
    ret

inputsys_muerto_update::
    call    cpct_scanKeyboard_asm

	ld		hl, #Key_G
	call	cpct_isKeyPressed_asm   ;;Cambia los flags si pulsas G
    ret z

    ;; Lo ha pulsado
    ld a, #1
    call nivelman_setNivel

    ld a, #0
    ld (estado), a

    call man_game_reset
    ret

inputsys_victoria_update::
    call    cpct_scanKeyboard_asm

	ld		hl, #Key_G
	call	cpct_isKeyPressed_asm   ;;Cambia los flags si pulsas G
    ret z

    ;; Lo ha pulsado
    ld a, #1
    call nivelman_setNivel

    ld a, #0
    ld (estado), a

    call man_game_reset
    ret

;; INPUTS: IX => puntero a inicio del array de entidades
;; DESTROY: A, HL, BC
;; -------------------------------------------------------------------------------
inputsys_update::

    ;; Lo uso para saber si en algun momento se ha pulsado una tecla de aqui
    ld	a, #0
    ld	(_tecla_pulsada), a
    
    ;; Scan the whole keyboard
    call cpct_scanKeyboard_asm

    ;; Comprobamos que el estado este a 0 (que esta jugando)
    ld a, (estado)  ;; A = estado
    cp #0       ;; A - 0
    jp nz, check_pause      ;; Si es algo distinto a 0 salta a comprobar si le quieres quitar el pausa y ya
    
    ;; Si esta siendo empujado no podra moverse
    call entityman_getPlayerPush_HL
    ld a, (hl)
    cp #-1
    jr nz, chech_space
    ;; CHECK P
    ;; ---------------------------
    ld hl,#Key_P
    call cpct_isKeyPressed_asm 
    jr nz, p_pressed
    ld hl,#Key_T
    call cpct_isKeyPressed_asm 
    jr nz, p_pressed
    ld hl,#Joy0_Right
    call cpct_isKeyPressed_asm 
    jr nz, p_pressed
    jr p_not_pressed 

        ;; P is pressed
        p_pressed:
        call entityman_move_right
        ld	a, #1
        ld (_tecla_pulsada), a


    p_not_pressed:

    ;; CHECK O
    ;; ---------------------------
    ld hl,#Key_O
    call cpct_isKeyPressed_asm 
    jr nz, o_pressed
    ld hl,#Key_R
    call cpct_isKeyPressed_asm 
    jr nz, o_pressed
    ld hl,#Joy0_Left
    call cpct_isKeyPressed_asm 
    jr nz, o_pressed
    jr o_not_pressed

        ;; O is pressed
        o_pressed:
        call entityman_move_left
        ld	a, #1
        ld (_tecla_pulsada), a

    o_not_pressed:

    ;; CHECK Q
    ;; ---------------------------
    ld hl,#Key_Q
    call cpct_isKeyPressed_asm 
    jr nz, q_pressed
    ld hl,#Key_G
    call cpct_isKeyPressed_asm 
    jr nz, q_pressed
    ld hl,#Joy0_Fire1
    call cpct_isKeyPressed_asm 
    jr nz, q_pressed
    jr q_not_pressed

        ;; Q is pressed
        q_pressed:
        ld	a, #1
        ld (_tecla_pulsada), a
        call    entityman_jump

        call entityman_getPlayerJump_HL
        ld a, (hl)
        cp #-1          ;; Salto activado = 0
        ret nz

        ;;Activar salto
        ld a, #0
        ld (hl), a
        
    q_not_pressed:


    chech_space:
    ;; CHECK SPACE
    ;; ---------------------------
    ld hl,#Key_Space
    call cpct_isKeyPressed_asm 
    jr nz, space_pressed 
    ld hl,#Key_F
    call cpct_isKeyPressed_asm
    jr nz, space_pressed
    ld hl,#Joy0_Fire2
    call cpct_isKeyPressed_asm
    jr nz, space_pressed
    jr space_not_pressed

        ;; Comprobamos si la variable esta a 0, si lo está retornamos directamente
        space_pressed:
        ld a, (sin_presionar_space)
        cp #0
        jr z,check_pause   ;; Si A = 0 es que esta presionando teclas

        ;; Space presionado
        ld	a, #1
        ld (_tecla_pulsada), a

        ld	bc, #sizeof_e
        add	ix, bc
        ld	a, e_tipo(ix);
        cp  #2
        jr	z, comprobar_pintar_bala
        jr	check_pause

        comprobar_pintar_bala:
            call	man_entity_bala_getNumBala_A
            cp	    #0
            call	z, man_entity_bala_add

            ;; Ponemos la variable como que esta presionando una tecla
            ld a, #0
            ld (sin_presionar_space), a
            jr check_pause

        
    space_not_pressed:
    ;; Si llega aqui es que no presiona space
    ld a, #1
    ld (sin_presionar_space), a

    ;; =================================
    ;; A partir de aqui teclas con CD
    ;; =================================
    ;; Uso esta etiqueta para que si esta en pausa no mueva nada pero pueda quitar el pausa
    check_pause:
    
    ;;Check ESC pressed
    ld hl,#Key_Esc ;;ESC constant value
    call cpct_isKeyPressed_asm 
    jr z, esc_not_pressed 

        ;; ESC is pressed
        esc_pressed:
        ld	a, #1
        ld (_tecla_pulsada), a
        ;; Comprobamos si la variable esta a 0, si lo está retornamos directamente
        ld a, (sin_presionar_pause)
        cp #0
        ret z   ;; Si A = 0 es que esta presionando teclas

        ;; Ponemos la variable como que esta presionando una tecla
        ld a, #0
        ld (sin_presionar_pause), a
        
        ;; Comprobamos cual es el estado que tiene
        ld a, (estado)  ;; A = estado
        cp #0       ;; Si es 0 entonces lo ponemos a 1 y viceversa
        jr z, poner_pausa   ;; Salta si estado = 0

            ;; Estaba ya en pausa, ponemos el estado a 0 (juego)
            reanudar_partida:
            ld a, #0
            ld (estado), a
            ld a, #0x00 ;; A = color de fondo para borrar el pausa
            call hudsys_toggle_pausa
            ret

        ;; Esta jugando, ponemos el estado a 1 (pausa)
        poner_pausa:
            ld a, #1
            ld (estado), a
            ld a, #0xFF ;; A = color blanco para pintar pausa
            call hudsys_toggle_pausa
            ret
        
    esc_not_pressed:

    ;; Si llega hasta aqui es que no presiona ninguna tecla

    ld a, #1
    ld (sin_presionar_pause), a

    ld a, (_tecla_pulsada)
    cp #1
    ret z

    call entityman_getPlayerJump_HL
    ld a, (hl)
    cp #-1          ;; Salto activado = 0
    ret nz
    call    entityman_calm    

    ret

_tecla_pulsada = .+1
ld a, #0




;; INPUTS: A
inputsys_setEstado::
    ld (estado), a
    ret	
    
inputsys_getEstado_HL::
    ld hl, #estado
    ret