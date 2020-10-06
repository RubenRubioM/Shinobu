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


.include "cpctelera.h.s"
.include "cpctelera_functions.h.s"
.include "sys/physics.h.s"
.include "sys/render.h.s"
.include "man/entity.h.s"
.include "sys/input.h.s"
.include "man/game.h.s"
.include "cmp/entity.h.s"

.area _DATA 
.area _CODE

decompress_buffer     = 0x3D0
maxsize               = 0x27AC
decompress_buffer_end = decompress_buffer + maxsize - 1

options_game:
    ld c, #0
    call cpct_setVideoMode_asm          ;; Modo video 0 -> 1 byte = 2 pixeles

    ld	hl, #_palette
    ld de, #16                      ;; Cantidad de colores
    call cpct_setPalette_asm        ;; CAMBIO DE PALETA
    
    ret

_main::
    call	cpct_disableFirmware_asm

    ld      hl, #_shinobu_pack_end
    ld      de, #decompress_buffer_end
    call    cpct_zx7b_decrunch_s_asm

    call    options_game
    call	man_game_init                       ;; Game

    loop:
        call inputsys_getEstado_HL
        ld a, (hl)
        cp #1
        jr z, estado_pausa
        cp #2
        jr z, estado_muerte
        cp #3
        jr z, estado_victoria
        
        call    man_game_render
        call    man_game_update
        call    cpct_waitVSYNC_asm
        call    cpct_akp_musicPlay_asm

        jr loop
        estado_pausa:
            call entityman_getEntityArray_IX    ;; Mete en IX entity_array en apuntando a la primera posicion
            call inputsys_update
            jr loop

        estado_muerte:
            call    cpct_akp_musicPlay_asm
            call rendersys_draw_muerte
            call inputsys_muerto_update
            jr loop

        estado_victoria:
            call    cpct_akp_musicPlay_asm
            call rendersys_draw_victoria
            call inputsys_victoria_update
            jr loop
