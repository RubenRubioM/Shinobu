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
;; SPRITE
;;

.include "cmp/sprite.h.s"
.include "cmp/entity.h.s"
.include "entity_bala.h.s"

ninja_sprite_index: .db 2
cambio_sprite: .db 6
enemy_sprite_index: .db 2
cambio_sprite_enemy: .db 18


ninja_calm_r:
    .dw _ninja_sp_16
    .dw _ninja_sp_16
    .dw _ninja_sp_16
    .dw _ninja_sp_16
    .dw 0x0000

ninja_calm_l:
    .dw _ninja_sp_17
    .dw _ninja_sp_17
    .dw _ninja_sp_17
    .dw _ninja_sp_17
    .dw 0x0000


ninja_jump_r:
    .dw _ninja_sp_12
    .dw _ninja_sp_12
    .dw _ninja_sp_12
    .dw _ninja_sp_12
    .dw 0x0000


ninja_jump_l:
    .dw _ninja_sp_13
    .dw _ninja_sp_13
    .dw _ninja_sp_13
    .dw _ninja_sp_13
    .dw 0x0000

ninja_run_r: 
    .dw _ninja_sp_00
    .dw _ninja_sp_01
    .dw _ninja_sp_02
    .dw _ninja_sp_03
    .dw 0x0000

ninja_run_l: 
    .dw _ninja_sp_04
    .dw _ninja_sp_05
    .dw _ninja_sp_06
    .dw _ninja_sp_07
    .dw 0x0000

shuriken_move:
    .dw _shuriken_sp_0
    .dw _shuriken_sp_0
    .dw _shuriken_sp_1
    .dw _shuriken_sp_1
    .dw 0x0000


enemigo_horizontal:
    .dw _enemigos_sp_0
    .dw _enemigos_sp_1
    .dw _enemigos_sp_2
    .dw _enemigos_sp_3
    .dw 0x0000


enemigo_vertical:
    .dw _enemigos_sp_4
    .dw _enemigos_sp_5
    .dw _enemigos_sp_6
    .dw _enemigos_sp_7
    .dw 0x0000


;; Cambio de animacion a jugador y bala (en caso de que haya)
;; INPUT -> IX: Puntero a la primera posicion de la entidad de personaje
;; DESTROY -> A, BC, HL, DE
;; ----------------------------
animation_man_update::

    ;; Lo uso para saber recorrer player y bala. Codigo automodificable
    ld	a, #2
    ld	(_entities_animation), a
    
    ld	a, (cambio_sprite)
    dec a                           ;; Decremente el contador
    ld	(cambio_sprite), a
    ret nz                          ;; Si no es 0, no hay cambio de sprite

    ld	a, #6                       ;; Si pasa aqui es porque A=0, lo vuelvo a poner a 6
    ld	(cambio_sprite), a          ;; Guardo el valor de A, en el contador del sprite


    animation_loop:

    ld  l, e_anim_l(ix)             ;; Coge el puntero al array de animaciones
    ld	h, e_anim_h(ix)          
    ld  bc, (ninja_sprite_index)    ;; Coge el index en el que esta el
    ld	b, #0                       ;; Como metemos el index en BC, hay que poner B a 0
    add hl, bc

    ld d, (hl)
    inc hl
    ld e, (hl)

    ld	a, d
    or	e                           ;;Si da 0 es que esta en la última posicion del array = null
    jr	nz, siguiente_sprite

        ;; Hay que volver al primer sprite
        ld  l, e_anim_l(ix)
        ld  h, e_anim_h(ix)
        ld d, (hl)
        inc hl
        ld e, (hl)
        ld e_sp_l(ix), d
        ld e_sp_h(ix), e
        ld a, #2
        ld (ninja_sprite_index), a
        jr	end_animation

    siguiente_sprite:

    ld	e_sp_l(ix), d
    ld	e_sp_h(ix), e

    inc bc                          ;; Incrementamos el index en 2
    inc bc
    
    ld a, (cambio_sprite)           
    ld	(ninja_sprite_index), bc
    ld (cambio_sprite), a

    end_animation:

    ld	a, (_entities_animation)                ;; Decremento el contador
    dec	a
    ld	(_entities_animation), a                ;; Guardo el valor
    cp	#0                              
    jr	z,  end_loop_animation                  ;; Si es 0, no quedan entidades. Volvemos

        ;; Miramos la bala
        ld	bc, #sizeof_e                       ;; Cogemos el tamano de entiddes
        add ix, bc                              ;; Voy a la siguiente entidad
        call	man_entity_bala_getNumBala_A    ;; Miro a ver si hay una bala creada
        cp	#0
        jr	z, end_loop_animation               ;; Si es 0, no hay bala creada, por tanto salgo del bucle

            ;Si hay bala
            jr	animation_loop                  ;; Como si hay bala, vuelvo al bucle para cambiar su sprite

    end_loop_animation:

ret


_entities_animation = .+1                       ;; Contador para recorrer la entidad
ld a, #0




;; Cambio de animacion a jugador y bala (en caso de que haya)
;; INPUT -> IY: Puntero a la primera posicion de la entidad de personaje
;; DESTROY -> A, BC, HL, DE
;; ----------------------------
animation_man_enemy_update::

    ;; Lo uso para saber recorrer player y bala. Codigo automodificable
    ld	a, #2
    ld	(_entities_enemy_animation), a


    ld	a, (cambio_sprite_enemy)
    dec a                           ;; Decremente el contador
    ld	(cambio_sprite_enemy), a
    ret nz                          ;; Si no es 0, no hay cambio de sprite

    ld	a, #12                     ;; Si pasa aqui es porque A=0, lo vuelvo a poner a 12
    ld	(cambio_sprite_enemy), a          ;; Guardo el valor de A, en el contador del sprite

    animation_enemy_loop:

        ld  l, e_anim_l(iy)             ;; Coge el puntero al array de animaciones
        ld	h, e_anim_h(iy)          
        ld  bc, (enemy_sprite_index)    ;; Coge el index en el que esta el
        ld	b, #0                       ;; Como metemos el index en BC, hay que poner B a 0
        add hl, bc

        ld d, (hl)
        inc hl
        ld e, (hl)

        ld	a, d
        or	e                           ;;Si da 0 es que esta en la última posicion del array = null
        jr	nz, siguiente_sprite_enemy

            ;; Hay que volver al primer sprite
            ld  l, e_anim_l(iy)
            ld  h, e_anim_h(iy)
            ld d, (hl)
            inc hl
            ld e, (hl)
            ld e_sp_l(iy), d
            ld e_sp_h(iy), e
            ld a, #2
            ld (enemy_sprite_index), a
            jr	end_animation_enemy

        siguiente_sprite_enemy:

        ld	e_sp_l(iy), d
        ld	e_sp_h(iy), e

        end_animation_enemy:

        ld	a, (_entities_enemy_animation)                ;; Decremento el contador
        dec	a
        ld	(_entities_enemy_animation), a                ;; Guardo el valor
        cp	#0                              
        jr	z,  end_enemy_loop_animation                  ;; Si es 0, no quedan entidades. Volvemos

            ld	bc, #sizeof_e                       ;; Cogemos el tamano de entiddes
            add iy, bc
            jr	animation_enemy_loop

    end_enemy_loop_animation:


            ld  bc, (enemy_sprite_index)
            inc bc
            inc bc
            ld  (enemy_sprite_index), bc

ret

_entities_enemy_animation = .+1                       ;; Contador para recorrer la entidad
ld a, #0