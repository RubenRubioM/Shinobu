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

.include "cpctelera_functions.h.s"
.include "cmp/sprite.h.s"
.include "man/nivel.h.s"
.include "man/entity_bala.h.s"
.include "man/entity.h.s"

lives_string: .asciz "LIVES"
shurikens_string: .asciz "SHURIKENS"
cero_string: .asciz "0"
uno_string: .asciz "1"
dos_string: .asciz "2"
tres_string: .asciz "3"
easterEgg_string: .asciz "hhhmm!"
easterEgg_string1: .asciz "Down"
easterEgg_string2: .asciz "You"
easterEgg_string3: .asciz "Go!"

color_pausa: .db 0
mostrando_easterEgg: .db 0
mostrando_easterEgg2: .db 0
contador_easterEgg: .db 180
contador_easterEgg2: .db 180

x_lives: .db 0
y_lives: .db 175
x_lives_valor: .db 40
y_lives_valor: .db 175
x_shurikens: .db 0
y_shurikens: .db 190
x_shurikens_valor: .db 40
y_shurikens_valor: .db 190

hudsys_reset_easterEgg::
    ld a, #0
    ld (mostrando_easterEgg), a
    ld (mostrando_easterEgg2), a
    ret

hudsys_init::

    ;; Set up draw char colours before calling draw string
    ld    h, #00        
    ld    l, #04        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ;; Draw LIVES
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    a, (y_lives)
    ld    b, a
    ld    a, (x_lives)
    ld    c, a
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL
    
    
    ld iy, #lives_string
    call cpct_drawStringM0_asm


    ;; Draw SHURIKENS
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    a, (y_shurikens)
    ld    b, a
    ld    a, (x_shurikens)
    ld    c, a
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL
    
    
    ld iy, #shurikens_string
    call cpct_drawStringM0_asm

    call actualizar_valores

    ret

hudsys_update::

    call borrar_valores
    call actualizar_valores
    ret

;; INPUTS: A -> color
hudsys_toggle_pausa::
    ld (color_pausa), a
    ld    de, #0xC000 ;; DE = Pointer to start of the screen
    ld    c, #70               ;; X
    ld    b, #175               ;; Y
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ;Pintamos el 1º cuadro
    ex de,hl
    ld a, (color_pausa)
    ld c, #2 ;; Ancho
    ld b, #16 ;; Alto
    call cpct_drawSolidBox_asm

    ld    de, #0xC000 ;; DE = Pointer to start of the screen
    ld    c, #73               ;; X
    ld    b, #175               ;; Y
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ;Pintamos el 2º cuadro
    ex de,hl
    ld a, (color_pausa)
    ld c, #2 ;; Ancho
    ld b, #16 ;; Alto
    call cpct_drawSolidBox_asm

    ret



borrar_valores:
    ;; Set up draw char colours before calling draw string
    ld    h, #00        
    ld    l, #00        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ;; BORRAMOS VALOR LIVES
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    a, (y_lives_valor)
    ld    b, a
    ld    a, (x_lives_valor)
    ld    c, a
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #uno_string
    call cpct_drawStringM0_asm

    ;; BORRAMOS VALOR LIVES
    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    a, (y_shurikens_valor)
    ld    b, a
    ld    a, (x_shurikens_valor)
    ld    c, a
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #uno_string
    call cpct_drawStringM0_asm

    ret


actualizar_valores:

    ;; Set up draw char colours before calling draw string
    ld    h, #00       
    ld    l, #13            
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    a, (y_lives_valor)
    ld    b, a
    ld    a, (x_lives_valor)
    ld    c, a
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    call entityman_getVidas_A ;; A = vidas
    cp #0
    jr z, cero_vidas
    cp #1
    jr z, una_vida
    cp #2
    jr z, dos_vidas
    cp #3
    jr z, tres_vidas
    jr actualizar_shurikens

    cero_vidas:
        ld iy, #cero_string
        call cpct_drawStringM0_asm
        jr actualizar_shurikens

    una_vida:
        ld iy, #uno_string
        call cpct_drawStringM0_asm
        jr actualizar_shurikens
        
    dos_vidas:
        ld iy, #dos_string
        call cpct_drawStringM0_asm
        jr actualizar_shurikens
    
    tres_vidas:
        ld iy, #tres_string
        call cpct_drawStringM0_asm
        jr actualizar_shurikens

    ;; ACTUALIZAMOS SHURIKENS
    actualizar_shurikens:

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    a, (y_shurikens_valor)
    ld    b, a
    ld    a, (x_shurikens_valor)
    ld    c, a
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    call man_entity_bala_getBalasRestantes ;; A = Shurikens
    cp #0 
    jr z, cero_shurikens
    cp #1
    jr z, un_shuriken
    cp #2
    jr z, dos_shurikens
    cp #3
    jr z, tres_shurikens
    ret	

    cero_shurikens:
        ld iy, #cero_string
        call cpct_drawStringM0_asm
        ret	
    un_shuriken:
        ld iy, #uno_string
        call cpct_drawStringM0_asm
        ret

    dos_shurikens:
        ld iy, #dos_string
        call cpct_drawStringM0_asm
        ret
    
    tres_shurikens:
        ld iy, #tres_string
        call cpct_drawStringM0_asm
        ret
    ret



hudsys_pintarEasterEgg::
    ld a, #1
    ld (mostrando_easterEgg), a
    ld a, #0x180        ;; Inicializamos temporizador
    ld (contador_easterEgg), a

    ;; Set up draw char colours before calling draw string
    ld    h, #00       
    ld    l, #09        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #170
    ld    c, #53
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #easterEgg_string1
    call cpct_drawStringM0_asm

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #180
    ld    c, #55
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #easterEgg_string2
    call cpct_drawStringM0_asm

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #190
    ld    c, #55    
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #easterEgg_string3
    call cpct_drawStringM0_asm
    ret

hudsys_borrar_easterEgg::
    ld a, (mostrando_easterEgg)
    cp #1
    ret nz  ;; Si no da 0 es que no se esta mostrando el easterEgg

    ld a, (mostrando_easterEgg2)
    cp #1
    call z,hudsys_borrarEasterEgg2
    

    ld a, (contador_easterEgg)
    dec	a
    ld (contador_easterEgg), a
    ret nz

    ;; Llega aqui si desactiva el primer easterEgg
    desacivar_easterEgg:
        ;; Set up draw char colours before calling draw string
        ld    h, #00       
        ld    l, #00        
        call cpct_setDrawCharM0_asm   ;; Set draw char colours

        ld   de, #0xC000 ;; DE = Pointer to start of the screen
        ld    b, #170
        ld    c, #53
        call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

        ld iy, #easterEgg_string1
        call cpct_drawStringM0_asm

        ld   de, #0xC000 ;; DE = Pointer to start of the screen
        ld    b, #180
        ld    c, #55
        call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

        ld iy, #easterEgg_string2
        call cpct_drawStringM0_asm

        ld   de, #0xC000 ;; DE = Pointer to start of the screen
        ld    b, #190
        ld    c, #55    
        call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

        ld iy, #easterEgg_string3
        call cpct_drawStringM0_asm

        ;; Pintamos el 2º easterEgg
        call hudsys_pintarEasterEgg2
    ret

hudsys_pintarEasterEgg2:
    ld a, #1
    ld (mostrando_easterEgg2), a
    ld a, #0x180
    ld (contador_easterEgg2), a

    ;; Set up draw char colours before calling draw string
    ld    h, #00       
    ld    l, #09        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #180
    ld    c, #50
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #easterEgg_string
    call cpct_drawStringM0_asm

    ret

hudsys_borrarEasterEgg2:
    ld a, (contador_easterEgg2)
    dec	a
    ld (contador_easterEgg2), a
    ret nz


    ld a, #0
    ld (mostrando_easterEgg), a

    ld a, #0
    ld (mostrando_easterEgg2), a
    ;; Set up draw char colours before calling draw string
    ld    h, #00       
    ld    l, #00        
    call cpct_setDrawCharM0_asm   ;; Set draw char colours

    ld   de, #0xC000 ;; DE = Pointer to start of the screen
    ld    b, #180
    ld    c, #50
    call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

    ld iy, #easterEgg_string
    call cpct_drawStringM0_asm

    ret