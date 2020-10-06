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
;; RENDER SYSTEM
;;
.include "cpctelera_functions.h.s"
.include "man/entity.h.s"
.include "man/entity_bala.h.s"
.include "cmp/entity.h.s"
.include "man/collision.h.s"
.include "man/nivel.h.s"
.include "sys/hud.h.s"

decompress_buffer     = 0x3D0
tileset_map           = decompress_buffer + 0
tileset_intro         = decompress_buffer + 2048

intro                 = decompress_buffer + 6656

level1                = decompress_buffer + 7156
level2                = decompress_buffer + 7656
level3                = decompress_buffer + 8156

level4                = decompress_buffer + 8656
level5                = decompress_buffer + 9156
level6                = decompress_buffer + 9656

;; Define one Zero-terminated string to be used later on

uno_string: .asciz "1"
dos_string: .asciz "2"
tres_string: .asciz "3"
cuatro_string: .asciz "4"
cinco_string: .asciz "5"
seis_string: .asciz "6"
siete_string: .asciz "7"
ocho_string: .asciz "8"

has_muerto_string: .asciz "YOU DIED!"
has_ganado_string: .asciz "YOU WIN!"
highest_level: .asciz "HIGHEST LEVEL"
press_G_string: .asciz "PRESS G"
to_restart_string: .asciz "TO RESTART"
out_of_string: .asciz "OUT OF 6"


fin_pintar_fondo: .db 0
fin_pintar_fondo_victoria: .db 0

rendersys_reset_fin_pintar_fondo_muerte::
    ld a, #0
    ld (fin_pintar_fondo), a
    ret

rendersys_reset_fin_pintar_fondo_victoria::
    ld a, #0
    ld (fin_pintar_fondo_victoria), a
    ret

rendersys_intro::
    ld  bc, #0x1414
    ld  de, #20
    ld	hl, #tileset_intro
    call cpct_etm_setDrawTilemap4x8_ag_asm

    ld  hl, #0xC000
    ld  de, #intro
    call cpct_etm_drawTilemap4x8_ag_asm
    
    ;; Set up draw char colours before calling draw string
    ld    h, #00       
    ld    l, #12        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ;; Pintamos el press G to start
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #150
    ld    c, #25   
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #press_G_string
    call cpct_drawStringM0_asm

    ret	


rendersys_init::
    ld  bc, #0x1414
    ld  de, #20
    ld	hl, #tileset_map
    call cpct_etm_setDrawTilemap4x8_ag_asm


    call nivelman_getNivel_A ;; Destroys A
    cp #1
    jr z, nivel1
    cp #2
    jr z, nivel2
    cp #3
    jr z, nivel3
    cp #4
    jr z, nivel4
    cp #5
    jr z, nivel5
    cp #6
    jr z, nivel6


    ret
    
    nivel1:
        ld  hl, #0xC000
        ld  de, #level1
        call cpct_etm_drawTilemap4x8_ag_asm

        ret
    nivel2:
        ld  hl, #0xC000
        ld  de, #level2
        call cpct_etm_drawTilemap4x8_ag_asm

        ret
    nivel3:
        ld  hl, #0xC000
        ld  de, #level3
        call cpct_etm_drawTilemap4x8_ag_asm

        ret
    nivel4:
        ld  hl, #0xC000
        ld  de, #level4
        call cpct_etm_drawTilemap4x8_ag_asm

        ret
    nivel5:
        ld  hl, #0xC000
        ld  de, #level5
        call cpct_etm_drawTilemap4x8_ag_asm

        ret

    nivel6:
        ld  hl, #0xC000
        ld  de, #level6
        call cpct_etm_drawTilemap4x8_ag_asm

        ret	


    
    ret	





;; INPUT:
;; IX: Pointer to first entity to render
;; A : Number of entities to render
rendersys_update_collision::
    

    call collisionman_getObstaclesNivel_IY
    call collisionman_getNumObstaclesNivel_A
    _renloopcollision:
    push af  ;; Nos guardamos A porque las funciones de cpctelera lo modifica

    ld    de, #0xC000 ;; DE = Pointer to start of the screen
    ld    c, e_x_obs(iy)                ;; X
    ld    b, e_y_obs(iy)                ;; Y
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ;Pintamos el sprite
    ex de,hl
    ld a, e_col_obs(iy)
    ld c, e_w_obs(iy) ;; Ancho
    ld b, e_h_obs(iy) ;; Alto
    call cpct_drawSolidBox_asm
    jp siguiente_entidad_obs

    siguiente_entidad_obs:
        pop af
        dec	a
        ret z ;; No quedan entidades entonces hacemos ret
    
        ld bc, #sizeof_e_obs  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
        add iy, bc           ;; Sumamos a IY el tamaño de una entidad para pasar a la siguiente (#sizeof_e)

        jr _renloopcollision



;; INPUT:
;; IX: Pointer to first entity to render
;; A : Number of entities to render
rendersys_update::

    call hudsys_borrar_easterEgg        ;; Comprobamos si borramos ya el easterEgg
    call entityman_getEntityArray_IX    ;; Mete en IX entity_array en apuntando a la primera posicion
    
    ld a, #2
    ld	(_render_player_bala), a
    
    _renloop:

        ;; Si es de tipo 1 (bounding box) no se dibuja
        ld a, e_tipo(ix)
        cp #1
        jr z, dibujo_bounding_box
        cp #2                           ;; Es bala?
        jr z, comprobar_puntero


;; ================================================================================
;; Parte para Sprites
        dibujo_sprite:

        ;; Erase Previous Instance
        ld de, #0xC000
        ld 	c, e_ax(ix)
        ld	b, e_ay(ix)
        call cpct_getScreenPtr_asm
        
        ex de,hl
        ld a, #00
        ld c, e_w(ix) ;; Ancho
        ld b, e_h(ix) ;; Alto
        call cpct_drawSolidBox_asm

        ld    de, #0xC000 ;; DE = Pointer to start of the screen
        ld    c, e_x(ix)                ;; X
        ld    b, e_y(ix)                ;; Y
        call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

        ;Pintamos el sprite
        ex de,hl
        ld l, e_sp_l(ix)
        ld h, e_sp_h(ix)
        ld c, e_w(ix) ;; Ancho
        ld b, e_h(ix) ;; Alto
        call cpct_drawSprite_asm

            ld  a, e_x(ix)
            ld  e_ax(ix), a
            ld  a, e_y(ix)
            ld	e_ay(ix), a

        jp siguiente_entidad

;; ================================================================================
;; PARTE PARA DIBUJAR BOXES
;; ================================================================================      
        dibujo_bounding_box:

        ld    de, #0xC000 ;; DE = Pointer to start of the screen
        ld    c, e_x(ix)                ;; X
        ld    b, e_y(ix)                ;; Y
        call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

        ;Pintamos el sprite
        ex de,hl
        ld a, e_sp_l(ix)
        ld c, e_w(ix) ;; Ancho
        ld b, e_h(ix) ;; Alto
        call cpct_drawSolidBox_asm

            ld  a, e_x(ix)
            ld  e_ax(ix), a
            ld  a, e_y(ix)
            ld	e_ay(ix), a

        jp siguiente_entidad


        comprobar_puntero:
            call    man_entity_bala_getNumBala_A
            cp	    #0
            jr      nz, dibujo_sprite
            jp      siguiente_entidad

;; ================================================================================
;; Avanzamos de entidad
;; ================================================================================
        siguiente_entidad:
            ld  a, (_render_player_bala)
            dec	a
            ld (_render_player_bala), a
            jr z, renderizar_enemigos ;; No quedan entidades entonces renderizamos enemigos
        
            ld bc, #sizeof_e  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
            add ix, bc           ;; Sumamos a IX el tamaño de una entidad para pasar a la siguiente (#sizeof_e)

            jp _renloop

        ;; Aqui termina de renderizar Player y bala
        renderizar_enemigos:
        call render_enemigos_por_nivel
    ret

_render_player_bala = .+1
ld	a, #0

render_enemigos_por_nivel:
    ld a, #2
    ld	(_render_enemigos), a
    call entityman_getEnemigosNivel_IY

    _enemy_loop:
        ;; Comprobamos si esta vivo
        ld a, e_vivo(iy)
        cp #0
        jr z, siguiente_enemigo



            ;; Erase Previous Instance
            ld de, #0xC000
            ld 	c, e_ax(iy)
            ld	b, e_ay(iy)
            call cpct_getScreenPtr_asm
            
            ex de,hl
            ld a, #00
            ld c, e_w(iy) ;; Ancho
            ld b, e_h(iy) ;; Alto
            call cpct_drawSolidBox_asm

        ;; Pintamos
        ld    de, #0xC000 ;; DE = Pointer to start of the screen
        ld    c, e_x(iy)                ;; X
        ld    b, e_y(iy)                ;; Y
        call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

        ;Pintamos el sprite
        ex de,hl
        ld l, e_sp_l(iy)
        ld h, e_sp_h(iy)
        ld c, e_w(iy) ;; Ancho
        ld b, e_h(iy) ;; Alto
        call cpct_drawSprite_asm

            ld  a, e_x(iy)
            ld  e_ax(iy), a
            ld  a, e_y(iy)
            ld	e_ay(iy), a

        siguiente_enemigo:
            ld  a, (_render_enemigos)
            dec	a
            ld (_render_enemigos), a
            ret z ;; No quedan entidades entonces hacemos ret
        
            ld bc, #sizeof_e  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
            add iy, bc           ;; Sumamos a IY el tamaño de una entidad para pasar a la siguiente (#sizeof_e)

            jr _enemy_loop
    ret	

_render_enemigos = .+1
ld	a, #0


;; INPUTS: IY -> Enemigo
rendersys_borrar_enemigo::

    ;; Erase Previous Instance
    ld de, #0xC000
    ld 	c, e_ax(iy)
    ld	b, e_ay(iy)
    call cpct_getScreenPtr_asm
    
    ex de,hl
    ld a, #00
    ld c, e_w(iy) ;; Ancho
    ld b, e_h(iy) ;; Alto
    call cpct_drawSolidBox_asm
    ret




rendersys_draw_muerte::
    ld a, (fin_pintar_fondo)
    cp #1
    jr z, pintar_string
        call rendersys_pintar_fondo
        ld a, #1
        ld (fin_pintar_fondo), a

    pintar_string:
        ld iy, #has_muerto_string
        call rendersys_draw_string_victoria_muerte

    ret

    

;; INPUTS: IY -> string
rendersys_draw_string_victoria_muerte:
    ;; Set up draw char colours before calling draw string
    ld    h, #00       
    ld    l, #09        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #20
    ld    c, #25
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    call cpct_drawStringM0_asm


    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #50
    ld    c, #15
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #highest_level
    call cpct_drawStringM0_asm
    
    ;; Pintamos el press G to start

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #120
    ld    c, #25   
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #press_G_string
    call cpct_drawStringM0_asm

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #140
    ld    c, #20   
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #to_restart_string
    call cpct_drawStringM0_asm

    ;; Pintamos out of 8
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #70
    ld    c, #30 
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #out_of_string
    call cpct_drawStringM0_asm

    ;; Set up draw char colours before calling draw string
    ld    h, #15        
    ld    l, #00        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ;; Pintamos el nivel maximo
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #70
    ld    c, #22   
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL



    call nivelman_getNivelMax_A ;; Destroys A
    cp #1
    jr z, nivelMax1
    cp #2
    jr z, nivelMax2
    cp #3
    jr z, nivelMax3
    cp #4
    jr z, nivelMax4
    cp #5
    jr z, nivelMax5
    cp #6
    jr z, nivelMax6
    cp #7
    jr z, nivelMax7
    cp #8
    jr z, nivelMax8


    nivelMax1:
        ld iy, #uno_string
        call cpct_drawStringM0_asm

        ret

    nivelMax2:
        ld iy, #dos_string
        call cpct_drawStringM0_asm
        ret
    
    nivelMax3:
        ld iy, #tres_string
        call cpct_drawStringM0_asm
        ret
    
    nivelMax4:
        ld iy, #cuatro_string
        call cpct_drawStringM0_asm
        ret

    nivelMax5:
        ld iy, #cinco_string
        call cpct_drawStringM0_asm
        ret

    nivelMax6:
        ld iy, #seis_string
        call cpct_drawStringM0_asm
        ret

    nivelMax7:
        ld iy, #siete_string
        call cpct_drawStringM0_asm
        ret

    nivelMax8:
        ld iy, #ocho_string
        call cpct_drawStringM0_asm
        ret
    ret

rendersys_pintar_fondo::
    ld hl, #0xC000
    loop_pintar:

        ld (hl), #0x0000
        inc hl
        ld a, l
        cp #0xFF
        jr nz, loop_pintar
        ld a, h
        cp #0xFF
        jr nz, loop_pintar

    
    ret

rendersys_draw_victoria::

    ld a, (fin_pintar_fondo_victoria)
    cp #1
    jr z, pintar_string_victoria
        call rendersys_pintar_fondo
        ld a, #1
        ld (fin_pintar_fondo_victoria), a

    pintar_string_victoria:
        ld iy, #has_ganado_string
        call rendersys_draw_string_victoria_muerte

    ret


