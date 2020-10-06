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

.include "collision.h.s"
.include "nivel.h.s"

_num_entities_obs:: .db 0
_num_entities_obs_nivel1:: .db 0
_num_entities_obs_nivel2:: .db 0
_num_entities_obs_nivel3:: .db 0
_num_entities_obs_nivel4:: .db 0
_num_entities_obs_nivel5:: .db 0
_num_entities_obs_nivel6:: .db 0
_num_entities_obs_nivel7:: .db 0
_num_entities_obs_nivel8:: .db 0
_num_entities_obs_nivel9:: .db 0
_ptr_obs_nivel1:: .dw 0x0000
_ptr_obs_nivel2:: .dw 0x0000
_ptr_obs_nivel3:: .dw 0x0000
_ptr_obs_nivel4:: .dw 0x0000
_ptr_obs_nivel5:: .dw 0x0000
_ptr_obs_nivel6:: .dw 0x0000
_ptr_obs_nivel7:: .dw 0x0000
_ptr_obs_nivel8:: .dw 0x0000
_ptr_obs_nivel9:: .dw 0x0000
_last_elem_ptr_obs:: .dw _entity_array_obs      ;; Puntero a nuestra ultima entidad


DefineEntityArrayObstacles _entity_array_obs, max_entities_obs


;;                          ADD NIVELES
;; =======================================================================
;; Aumenta en 1 los obstaculos
;;INPUTS -> HL
collisionman_addObstaclePorNivel:
    ld a, (hl)
    cp #1
    jr z, addNivel1
    cp #2
    jr z, addNivel2
    cp #3
    jr z, addNivel3
    cp #4
    jr z, addNivel4
    cp #5
    jr z, addNivel5
    cp #6
    jr z, addNivel6
    cp #7
    jr z, addNivel7
    cp #8
    jr z, addNivel8
    cp #9
    jr z, addNivel9
    ret	

    addNivel1:
        ld a, (_num_entities_obs_nivel1)
        inc a
        ld (_num_entities_obs_nivel1), a
        ret
    addNivel2:
        ld a, (_num_entities_obs_nivel2)
        inc a
        ld (_num_entities_obs_nivel2), a
        ret
    addNivel3:
        ld a, (_num_entities_obs_nivel3)
        inc a
        ld (_num_entities_obs_nivel3), a
        ret
    addNivel4:
        ld a, (_num_entities_obs_nivel4)
        inc a
        ld (_num_entities_obs_nivel4), a
        ret
    addNivel5:
        ld a, (_num_entities_obs_nivel5)
        inc a
        ld (_num_entities_obs_nivel5), a
        ret
    addNivel6:
        ld a, (_num_entities_obs_nivel6)
        inc a
        ld (_num_entities_obs_nivel6), a
        ret
    addNivel7:
        ld a, (_num_entities_obs_nivel7)
        inc a
        ld (_num_entities_obs_nivel7), a
        ret
    addNivel8:
        ld a, (_num_entities_obs_nivel8)
        inc a
        ld (_num_entities_obs_nivel8), a
        ret
    addNivel9:
        ld a, (_num_entities_obs_nivel9)
        inc a
        ld (_num_entities_obs_nivel9), a
        ret
    ret

;;                          FIN ADD NIVELES
;; =======================================================================


;;                          GET NIVELES ENTITIES
;; =======================================================================
;; Devuelve el numero de entidades que tenemos  (getNumEntities)
collisionman_getNumObstacles_A::
    ld a,(_num_entities_obs)
    ret	

collisionman_getNumObstaclesNivel_A::
    call nivelman_getNivel_A
    cp #1
    jr z, getNivel1obs
    cp #2
    jr z, getNivel2obs
    cp #3
    jr z, getNivel3obs
    cp #4
    jr z, getNivel4obs
    cp #5
    jr z, getNivel5obs
    cp #6
    jr z, getNivel6obs
    cp #7
    jr z, getNivel7obs
    cp #8
    jr z, getNivel8obs
    cp #9
    jr z, getNivel9obs
    ret	

    getNivel1obs:
        ld a, (_num_entities_obs_nivel1)
        ret
    getNivel2obs:
        ld a, (_num_entities_obs_nivel2)
        ret
    getNivel3obs:
        ld a, (_num_entities_obs_nivel3)
        ret
    getNivel4obs:
        ld a, (_num_entities_obs_nivel4)
        ret
    getNivel5obs:
        ld a, (_num_entities_obs_nivel5)
        ret
    getNivel6obs:
        ld a, (_num_entities_obs_nivel6)
        ret
    getNivel7obs:
        ld a, (_num_entities_obs_nivel7)
        ret
    getNivel8obs:
        ld a, (_num_entities_obs_nivel8)
        ret
    getNivel9obs:
        ld a, (_num_entities_obs_nivel9)
        ret
    ret




;;                          FINAL GET NIVELES ENTITIES
;; =======================================================================

collisionman_getObstaclesNivel_IY::
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
    cp #7
    jr z, getNivel7
    cp #8
    jr z, getNivel8
    cp #9
    jr z, getNivel9

    ret	

    getNivel1:
        ld iy, (_ptr_obs_nivel1)
        ret
    getNivel2:
        ld iy, (_ptr_obs_nivel2)
        ret
    getNivel3:
        ld iy, (_ptr_obs_nivel3)
        ret
    getNivel4:
        ld iy, (_ptr_obs_nivel4)
        ret
    getNivel5:
        ld iy, (_ptr_obs_nivel5)
        ret
    getNivel6:
        ld iy, (_ptr_obs_nivel6)
        ret
    getNivel7:
        ld iy, (_ptr_obs_nivel7)
        ret
    getNivel8:
        ld iy, (_ptr_obs_nivel8)
        ret
    getNivel9:
        ld iy, (_ptr_obs_nivel9)
        ret
    ret

;;                          SET NIVELES POINTERS
;; =======================================================================
;; INPUTS -> HL
;;        -> A
collisionman_setPtrNivel::
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
    cp #7
    jr z, setNivel7Ptr
    cp #8
    jr z, setNivel8Ptr
    cp #9
    jr z, setNivel9Ptr
    ret	

    setNivel1Ptr:
        ld (_ptr_obs_nivel1), hl
        ret
    setNivel2Ptr:
        ld (_ptr_obs_nivel2), hl
        ret
    setNivel3Ptr:
        ld (_ptr_obs_nivel3), hl
        ret
    setNivel4Ptr:
        ld (_ptr_obs_nivel4), hl
        ret
    setNivel5Ptr:
        ld (_ptr_obs_nivel5), hl
        ret
    setNivel6Ptr:
        ld (_ptr_obs_nivel6), hl
        ret
    setNivel7Ptr:
        ld (_ptr_obs_nivel7), hl
        ret
    setNivel8Ptr:
        ld (_ptr_obs_nivel8), hl
        ret
    setNivel9Ptr:
        ld (_ptr_obs_nivel9), hl
        ret
    ret
;; CREATE
;; ----------------------------
;; INPUT
;; HL: Pointer to entity intializer bytes
collisionman_create::


    ld de, (_last_elem_ptr_obs)
    ld bc, #sizeof_e_obs

    ldir

    ;; Aumentamos el numero de entidades
    ld a,(_num_entities_obs)
    inc a
    ld (_num_entities_obs),a
    ld hl, (_last_elem_ptr_obs)
    call collisionman_addObstaclePorNivel ;; Destroys: A

    ;; 
    ld hl, (_last_elem_ptr_obs)
    ld bc, #sizeof_e_obs
    add hl, bc
    ld (_last_elem_ptr_obs), hl



    ret