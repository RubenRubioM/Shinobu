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
;; ENTITY MANAGER
;;
.include "entity.h.s"
.include "cmp/entity.h.s"
.include "man/entity_bala.h.s"
.include "cpctelera.h.s"
.include "sys/input.h.s"
.include "cmp/sprite.h.s"
.include "sys/hud.h.s"
.include "man/nivel.h.s"



_num_entities:: .db 0                   ;; Numero de entidades actualmente
_last_elem_ptr:: .dw _entity_array      ;; Puntero a nuestra ultima entidad

DefineEntityArray _entity_array, max_entities
player_jump: .db #empieza_gravedad
vidas_restantes: .db 3  ;; Vidas del jugador

;; Tabla de saltos
jumptable:
    .db #-5, #-5, #-5, #-5, #-4, #-3, #-3, #-3, #-3, #-3, #-2, #-1
    .db #0, #0, #0, #0
    .db #1, #2, #4, #4, #6, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7, #7
    .db #0x80  ;; Marcamos el final de la jumptable

player_push: .db -1
player_push_direction: .db 0
pushtable:
    .db #2, #2, #2, #3, #4, #4, #4, #4, #4
    .db #0x80
_ptr_enemigo_nivel1:: .dw 0x0000
_ptr_enemigo_nivel2:: .dw 0x0000
_ptr_enemigo_nivel3:: .dw 0x0000
_ptr_enemigo_nivel4:: .dw 0x0000
_ptr_enemigo_nivel5:: .dw 0x0000
_ptr_enemigo_nivel6:: .dw 0x0000

;; =======================================================================
;; INPUTS -> HL
;;        -> A
entityman_setPtrNivel::
    cp #1
    jr z, setNivel1Ptr
    cp #2
    jr z, setNivel2Ptr
    cp #3
    jr z, setNivel3Ptr
    cp #4
    jr z, setNivel4Ptr
    cp #5
    jr z, setNivel5Ptr
    cp #6
    jr z, setNivel6Ptr
    ret	

    setNivel1Ptr:
        ld (_ptr_enemigo_nivel1), hl
        ret
    setNivel2Ptr:
        ld (_ptr_enemigo_nivel2), hl
        ret
    setNivel3Ptr:
        ld (_ptr_enemigo_nivel3), hl
        ret
    setNivel4Ptr:
        ld (_ptr_enemigo_nivel4), hl
        ret
    setNivel5Ptr:
        ld (_ptr_enemigo_nivel5), hl
        ret
    setNivel6Ptr:
        ld (_ptr_enemigo_nivel6), hl
        ret
    ret

entityman_getEnemigosNivel_IY::
    call nivelman_getNivel_A
    cp #1
    jr z, getNivel1
    cp #2
    jr z, getNivel2
    cp #3
    jr z, getNivel3
    cp #4
    jr z, getNivel4
    cp #5
    jr z, getNivel5
    cp #6
    jr z, getNivel6
    ret	

    getNivel1:
        ld iy, (_ptr_enemigo_nivel1)
        ret
    getNivel2:
        ld iy, (_ptr_enemigo_nivel2)
        ret
    getNivel3:
        ld iy, (_ptr_enemigo_nivel3)
        ret
    getNivel4:
        ld iy, (_ptr_enemigo_nivel4)
        ret
    getNivel5:
        ld iy, (_ptr_enemigo_nivel5)
        ret
    getNivel6:
        ld iy, (_ptr_enemigo_nivel6)
        ret
    ret

entityman_getVidas_A::
    ld a, (vidas_restantes)
    ret	
entityman_resetVidas::
    ld a, #3
    ld (vidas_restantes), a
    ret
;; TO-DO: Ponerlo a gameover
entityman_decVida::
    ld a, (vidas_restantes)
    dec a
    ld (vidas_restantes), a
    jr z, game_over  ;; Si las vidas aun no son 0, retornamos
    
        ;; Actualizamos HUD
        call hudsys_update
        ret
    

    ;; Gameover
    game_over:
        call cpct_akp_stop_asm
        ld  de, #_pauseMusic
        call cpct_akp_musicInit_asm
        ld a, #2    ;; 2 es el estado de GameOver
        call inputsys_setEstado
    ret

entityman_getJumpTable_HL::
    ld hl, #jumptable
    ret

entityman_getPlayerJump_HL::
    ld hl, #player_jump
    ret

entityman_getPushTable_HL::
    ld hl, #pushtable
    ret

entityman_getPlayerPush_HL::
    ld hl, #player_push
    ret	

;; INPUTS: A
entityman_setPlayerPush::
    ld (player_push), a
    ret	

entityman_getPlayerPushDirection_A::
    ld a, (player_push_direction)
    ret

;; INPUTS: A
entityman_setPlayerPushDirection::
    ld (player_push_direction), a
    ret	

entityman_getEntityArray_IX::
    ld ix, #_entity_array
    ret	

;; Devuelve el numero de entidades que tenemos  (getNumEntities)
entityman_getNumEntities_A::
    ld a,(_num_entities)
    ret	






;; CREATE
;; ----------------------------
;; INPUT
;; HL: Pointer to entity intializer bytes
entityman_create::


    ld de, (_last_elem_ptr)
    ld bc, #sizeof_e

    ;ld__ixh_d
    ;ld__ixl_e

    ldir

    ;; Aumentamos el numero de entidades
    ld a,(_num_entities)
    inc a
    ld (_num_entities),a

    ;; 
    ld hl, (_last_elem_ptr)
    ld bc, #sizeof_e
    add hl, bc
    ld (_last_elem_ptr), hl

    ;; Para mirar el tipo del nuevo que acabo de meter
    ;; necesito meterlo al registro IX

    

    ;ld	    a, e_tipo(ix)
    ;cp	    #2
    ;call	z, man_entity_bala_add

    ret

;; INPUT:   IX -> Primera posicion de la entidad del personaje
;;          DE -> Puntero a la animacion
;; ---------------------------------
entityman_cambio_animacion:
    ld	e_anim_h(ix), d
    ld  e_anim_l(ix), e
ret	

;; MOVE RIGHT
;; INPUT: IX -> Primera posicion de la entidad del personaje
;; DESTROY: A, BC, HL
;; ---------------------------------
entityman_move_right::
    ld a, #1
    ld e_vx(ix), a
    ld a, e_vx(ix)      ;; A = vx
    ld b, a             ;; B = vx
    ld a, e_x(ix)       ;; A = x
    add b               ;; A = A + B (x + vx)
    ld c, a             ;; C = A
    ld a, e_w(ix)       ;; A = player.width
    add c               ;; A = (nueva x) + width
    cp #77
    ret z               ;; Si llega a X = 80, no lo movemos mas
    
    ld a, c             ;; A = x + vx
    ld e_x(ix), a       ;; Actualizo el valor e_x(ix)

    ;; Cambio la animacion
    ld	de, #ninja_run_r
    call entityman_cambio_animacion

    ;; Cambio el sprite al primero de la animacion
    ;ld  de, (ninja_run_r)
    ;call entityman_cambio_first_sprite

ret


;; MOVE LEFT
;; INPUT: IX -> Primera posicion de la entidad del personaje
;; DESTROY: A, B
;; ---------------------------------
entityman_move_left::
    ld a, #-1    
    ld e_vx(ix), a      ;; Cambiamos su valor a negativo
    ld a, e_vx(ix)      ;; A = vx
    ld b, a             ;; B = vx
    ld a, e_x(ix)       ;; A = x
    add b               ;; A = A + B
    cp #3
    ret z               ;; Si esta en X = 0, no lo movemos mas
    
    ld e_x(ix), a       ;; Actualizo el valor e_x(ix)


    ;; Cambio la animacion
    ld	de, #ninja_run_l
    call entityman_cambio_animacion

    ;; Cambio el sprite al primero de la animacion
    ;ld  de, (ninja_run_l)
    ;call entityman_cambio_first_sprite

ret


;; INPUT: IX -> Primera posicion de la entidad del personaje
;; DESTROY: A, DE
;; ---------------------------------
entityman_calm::

    ld  a, e_vx(ix)
    cp	#-1
    jr	z, calm_izquierda

    ;; Cambio la animacion
    ld	de, #ninja_calm_r
    call entityman_cambio_animacion

    ;; Cambio el sprite al primero de la animacion
    ;ld  de, (ninja_calm_r)
    ;call entityman_cambio_first_sprite
    ret

    calm_izquierda:

    ;; Cambio la animacion
    ld	de, #ninja_calm_l
    call entityman_cambio_animacion

    ;; Cambio el sprite al primero de la animacion
    ;ld  de, (ninja_calm_l)
    ;call entityman_cambio_first_sprite

ret


;; INPUT: IX -> Primera posicion de la entidad del personaje
;; DESTROY: A, DE
;; ---------------------------------
entityman_jump::

    ld  a, e_vx(ix)
    cp	#-1
    jr	z, jump_izquierda

    ;; Cambio la animacion
    ld	de, #ninja_jump_r
    call entityman_cambio_animacion

    ;; Cambio el sprite al primero de la animacion
    ;ld  de, (ninja_jump_r)
    ;call entityman_cambio_first_sprite
    ret

    jump_izquierda:

    ;; Cambio la animacion
    ld	de, #ninja_jump_l
    call entityman_cambio_animacion
    ;; Cambio el sprite al primero de la animacion
    ;ld  de, (ninja_jump_l)
    ;call entityman_cambio_first_sprite
ret