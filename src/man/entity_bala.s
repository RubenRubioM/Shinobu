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
;; BALA ENTITY MANAGER
;;

.include    "cmp/entity.h.s"
.include    "man/entity.h.s"
.include    "sys/sfx_control.h.s"
.include    "cpctelera.h.s"
.include    "sys/hud.h.s"

.module     entity_bala_manager


_num_entities_bala:: .db 0
_bala_ptr:: .dw 0x0000
_balas_restantes:: .db 3

man_entity_bala_recargar::
    ld a, #3
    ld (_balas_restantes), a
    ret

man_entity_bala_reset::
    ld a, #0
    ld (_num_entities_bala), a
    ld hl, #0x0000
    ld (_bala_ptr), hl
    

    ret	

man_entity_bala_update::
    ld hl, #_bala_ptr
    cp #0x0000
    ret z   ;; Si el puntero es 0x0000 es que no hay bala y devolvemos

    ;; Movemos la bala
    ld ix, (_bala_ptr)
    ld a, e_x(ix)
    add	e_vx(ix)
    ;; Comprobamos si se pasa de los limites para resetearla
    cp #75
    call z, man_entity_bala_reset  ;; Si no da 0 es que no ha llegado al limite derecho
    ret z
    cp #3
    call z, man_entity_bala_reset
    ret z
        ld	e_x(ix), a
        

    ret

;;
;; CAMBIA: A, DE, HL, BC
;; OUTPUT:
;;      HL -> Devuelve el puntero a bala

man_entity_bala_init::
    
    ;; Poner valores de array a 0
    ld	    a, #0
    ld      (_bala_ptr), a
    ld      (_num_entities_bala), a
    
    ;; BEWARE! No poner codigo aqui

man_entity_bala_getPtrHL::

    ld	    hl, (#_bala_ptr)
    ret

;; Devuelve en IX un puntero a la bala (comprobado que funciona)
man_entity_bala_getPtrIX::
    ld ix, (_bala_ptr)
    ret

man_entity_bala_getNumBala_A::

    ld	    a,(_num_entities_bala)
    ret


;; INPUT:
;;      IX -> Puntero a la nueva entidad a anadir
;; DESTROYS: A, HL, IX, IY

man_entity_bala_add::
    ;; Si no te quedan balas pues no disparas, asi de simple
    ld a, (_balas_restantes)
    cp #0
    ret z

    ;; QUEDAN BALAS
    
    ;; Copia el puntero que me dan en IX en el 
    ;; lugar donde apunta HL

    ld	    hl, (_bala_ptr)
    ld__a_ixh
    ld	    h, a
    inc	    hl
    ld__a_ixl
    ld	    l, a
    ld	    (_bala_ptr), hl

    ;; HL apunta a la bala
    ld      iy, (_bala_ptr)
    call	entityman_getEntityArray_IX

    ld	a, e_x(ix)              ;; A = player.x
    ld  e_x(iy), a              ;; bala.x =
    ld	a, e_y(ix)              ;; A = player.y
    ld b, a                     ;; B = A = player.y
    ld a, e_h(ix)               ;; A = player.height
    srl a                       ;; A = player.height/2
    add b                       ;; A = A + B = player.height/2 + player.y
    ld	e_y(iy), a              ;; Posicion Y de la bala = A
    ld  a, e_vx(ix)             ;; A = velocidad del player
    ld  e_vx(iy), a             ;; Velocidad de la bala = A 

    ;; Decrementamos el numero de balas
    ld a, (_balas_restantes)
    dec a
    ld (_balas_restantes), a

    ;; ACTUALIZAMOS HUD
    call hudsys_update
    
    ;; Pongo a 1 que hay bala
    ld a,(_num_entities_bala)
    inc a
    ld (_num_entities_bala), a
    
    call shuriken_SFX

    ret

man_entity_bala_getBalasRestantes::
    ld a, (_balas_restantes)
    ret