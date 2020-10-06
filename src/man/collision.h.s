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

;; COLLISION HEADER

.globl collisionman_create
.globl collisionman_getObstaclesNivel_IY
.globl collisionman_getNumObstacles_A
.globl collisionman_getNumObstaclesNivel_A
.globl collisionman_setPtrNivel



max_entities_obs == 50

;; MACROS
.macro DefineEntityAnnonimousObstacle _nivel, _x, _y, _w, _h, _color, _danyo    ;; Orden al crear la estructura
    .db _nivel ;; Nivel
    .db _x ;; X de la entidad
    .db _y ;; Y de la entidad
    .db _w ;; Anchura
    .db _h ;; Altura
    .db _color ;; Puntero a sprite
    .db _danyo ;; 1 = hace daño
.endm

.macro DefineEntityObstacle _name, _nivel, _x, _y, _w, _h, _color, _danyo
    _name::
        DefineEntityAnnonimousObstacle  _nivel, _x, _y, _w, _h, _color, _danyo
.endm

e_nivel_obs = 0
e_x_obs = 1
e_y_obs = 2
e_w_obs = 3
e_h_obs = 4
e_col_obs = 5
e_dan_obs = 6
sizeof_e_obs = 7

.macro DefineEntityArrayObstacles _name, _N
    _name::
    .rept _N
        DefineEntityAnnonimousObstacle 0xDE,0xAD,0xDE,0xAD,0xDE,0xAD,0xDE       ;;Estos valores son para diferenciarlo en el codigo y no ser solo 0
    .endm
.endm