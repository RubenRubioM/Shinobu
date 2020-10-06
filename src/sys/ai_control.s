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
.include "man/entity.h.s"
.include "cmp/entity.h.s"
.include "man/collision.h.s"
.include "man/nivel.h.s"
.module sys_ai_control

velocidad: .db #1

sys_ai_control_init::
    ld (_ent_array_ptr), ix
    ret



sys_ai_control_update::

    ld  a, (velocidad)
    cp	#4
    jr	z, _velocidad

    inc a
    ld  (velocidad), a
    ret

_velocidad:
    ld  a, #1
    ld  (velocidad), a

    call entityman_getNumEntities_A
    ld (_ent_counter), a

_ent_array_ptr = . + 2
    ld ix, #0x0000

_loop:

    ld  a, e_ai_status(ix)
    cp  #e_ai_status_noAI
    jr  z, _no_AI_ent

_AI_ent:
    cp  #e_ai_status_standby
    call z, sys_ai_standby

    cp  #e_ai_status_moveto
    call z, sys_ai_moveto

    cp  #e_ai_status_patrol
    call z, sys_ai_patrol

_no_AI_ent:


_ent_counter = . +1
    ld  a, #0
    dec a
    ret z

    ld  (_ent_counter), a
    ld  de, #sizeof_e
    add ix, de

    jr	_loop



;-------------IA DE PATRULLA-------------
sys_ai_standby::
    ld	e_ai_x(ix), #1
    ld  iy, #0x0000

    ld	e_ai_patrol_step(ix), #0
    ld  e_ai_prestatus(ix), #e_ai_status_standby
    ld  e_ai_status(ix), #e_ai_status_patrol
    
    ret

sys_ai_moveto::
    ld	a, e_ai_x(ix)
    sub	e_x(ix)
    jr	nc, _objx_greater_or_equal

_objx_lesser:
        ld a, #-1    
        ld e_vx(ix), a      ;; Cambiamos su valor a negativo
        ld a, e_vx(ix)      ;; A = vx
        ld b, a             ;; B = vx
        ld a, e_x(ix)       ;; A = x
        add b               ;; A = A + B
        ld e_x(ix), a       ;; Actualizo el valor e_x(ix)

        jr	_endif_x
_objx_greater_or_equal:
        jr	z, _arrived_x

        ld a, #1
        ld e_vx(ix), a
        ld a, e_vx(ix)      ;; A = vx
        ld b, a             ;; B = vx
        ld a, e_x(ix)       ;; A = x
        add b               ;; A = A + B (x + vx)
        ld c, a             ;; C = A
        ld a, e_w(ix)       ;; A = player.width
        add c               ;; A = (nueva x) + width
        ld a, c             ;; A = x + vx
        ld e_x(ix), a       ;; Actualizo el valor e_x(ix)

        jr	_endif_x
_arrived_x:
        ld	e_vx(ix), #0
_endif_x:

    ld	a, e_ai_y(ix)
    sub	e_y(ix)
    jr	nc, _objy_greater_or_equal

_objy_lesser:
        ld a, #-1    
        ld e_vy(ix), a      ;; Cambiamos su valor a negativo
        ld a, e_vy(ix)      ;; A = vx
        ld b, a             ;; B = vx
        ld a, e_y(ix)       ;; A = x
        add b               ;; A = A + B
        ld e_y(ix), a       ;; Actualizo el valor e_x(ix)

        jr	_endif_y
_objy_greater_or_equal:
        jr	z, _arrived_y

        ld a, #1
        ld e_vy(ix), a
        ld a, e_vy(ix)      ;; A = vx
        ld b, a             ;; B = vx
        ld a, e_y(ix)       ;; A = x
        add b               ;; A = A + B (x + vx)
        ld c, a             ;; C = A
        ld a, e_h(ix)       ;; A = player.width
        add c               ;; A = (nueva x) + width
        ld a, c             ;; A = x + vx
        ld e_y(ix), a       ;; Actualizo el valor e_x(ix)

        jr	_endif_y
_arrived_y:
        ld	e_vy(ix), #0

        ld  a, e_vx(ix)
        or  a
        jr  nz, _endif_y
        
        ld	a, e_ai_prestatus(ix)
        ld	e_ai_status(ix), a
        ld	e_ai_prestatus(ix), #e_ai_status_moveto
_endif_y:

    ret





sys_ai_patrol::
    ld  a, e_ai_patrol_step(ix)
    cp	#0
    jr	z, _step0
    cp	#1
    jr	z, _step1
    
_step0:
    ld  a, e_ai_patrolX_pos1(ix)
    ld	e_ai_x (ix), a
    ld  a, e_ai_patrolY_pos1(ix)
    ld	e_ai_y (ix), a

    ld	e_ai_prestatus(ix), #e_ai_status_patrol
    ld	e_ai_status(ix), #e_ai_status_moveto
    ld  e_ai_patrol_step(ix), #1
    ret

_step1:
    ld  a, e_ai_patrolX_pos2(ix)
    ld	e_ai_x (ix), a
    ld  a, e_ai_patrolY_pos2(ix)
    ld	e_ai_y (ix), a
    
    ld	e_ai_prestatus(ix), #e_ai_status_patrol
    ld	e_ai_status(ix), #e_ai_status_moveto
    ld  e_ai_patrol_step(ix), #0
    ret