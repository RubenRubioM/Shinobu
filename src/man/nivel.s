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

nivel: .db #1
nivel_max: .db #1

nivelman_getNivel_A::
    ld a, (nivel)
    ret

;; INPUTS: A
nivelman_setNivel::
    ld (nivel), a
    ret

nivelman_incNivel::
    ld a, (nivel)
    inc a
    ld (nivel), a
    ret

nivelman_decNivel::
    ld a, (nivel)
    dec a
    ld (nivel), a
    ret

nivelman_updateNivelMax::
    ;; Si nivel > nivel_max
    ld a, (nivel_max)
    ld b, a
    ld a, (nivel)

    sub b   ;; A = nivel - nivelmax
    ret c

        ;; Actualizamos nivel maximo
        ld a, (nivel)
        ld (nivel_max), a
    ret

nivelman_getNivelMax_A::
    ld a, (nivel_max)
    ret

nivelman_restart_nivelMax::
    ld a, #0
    ld (nivel_max), a
    ret