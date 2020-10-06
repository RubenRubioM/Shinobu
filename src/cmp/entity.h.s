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
;; ENTITY COMPONENT HEADER
;;


max_entities == 24
max_entities_bala == 1
fin_del_salto == 12
empieza_gravedad == 18

;; MACROS
.macro DefineEntityAnnonimous _tipo, _x, _y,_ax,_ay, _vx, _vy, _w, _h, _statusAI, _sprite, _animation, _pos1X, _pos2X, _pos1Y, _pos2Y, _vivo    ;; Orden al crear la estructura
    .db _tipo ;; Tipo
    .db _x ;; X de la entidad
    .db _y ;; Y de la entidad
    .db _ax
    .db _ay
    .db _w ;; Anchura
    .db _h ;; Altura
    .db _vx;; Velocidad en X
    .db _vy;; Velocidad en y
    .db 0x00, 0x00 ;; Posicion IA
    .db _statusAI ;; Estado IA
    .db _statusAI ;; Estado IA
    .db 0 ;;Paso de patrulla
    .dw _sprite ;; Puntero a sprite
    .dw _animation  ;;Puntero a la animacion (array de sprites)
    .db _pos1X
    .db _pos2X
    .db _pos1Y
    .db _pos2Y
    .db _vivo
.endm

.macro DefineEntity _name, _tipo, _x, _y,_ax,_ay, _vx, _vy, _w, _h, _statusAI, _sprite, _animation, _pos1X, _pos2X, _pos1Y, _pos2Y, _vivo
    _name::
        DefineEntityAnnonimous  _tipo,_x, _y,_ax,_ay, _vx, _vy, _w, _h, _statusAI, _sprite, _animation, _pos1X, _pos2X, _pos1Y, _pos2Y, _vivo
.endm

e_tipo = 0
e_x = 1
e_y = 2
e_ax = 3
e_ay = 4
e_w = 5
e_h = 6
e_vx = 7
e_vy = 8
e_ai_x = 9
e_ai_y = 10
e_ai_status = 11
e_ai_prestatus = 12
e_ai_patrol_step = 13
e_sp_l = 14
e_sp_h = 15
e_anim_l = 16
e_anim_h = 17
e_ai_patrolX_pos1 = 18
e_ai_patrolX_pos2 = 19
e_ai_patrolY_pos1 = 20
e_ai_patrolY_pos2 = 21
e_vivo = 22
sizeof_e = 23

;; Estados IA
e_ai_status_noAI = 0
e_ai_status_standby = 1
e_ai_status_moveto = 2
e_ai_status_torreta = 3
e_ai_status_patrol = 4


.macro DefineEntityArray _name, _N
    _name::
    .rept _N
        DefineEntityAnnonimous 0xDE,0xAD,0xDE,0xAD,0xDE,0xAD,0xDE,0xAD,0xDE,0xDE,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000, 0xDE       ;;Estos valores son para diferenciarlo en el codigo y no ser solo 0
    .endm
.endm