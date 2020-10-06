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
;; SPRITE HEADER
;;

;.macro Sprite _name, _sprite, _dir
;    _name:
;        .dw     _sprite
;        .db     _dir
;.endm

;s_sp_l  = 0
;s_sp_h  = 1
;s_dir   = 2


;; GLOBALS

.globl  _ninja_sp_00
.globl  _ninja_sp_01
.globl  _ninja_sp_02
.globl  _ninja_sp_03
.globl  _ninja_sp_04
.globl  _ninja_sp_05
.globl  _ninja_sp_06
.globl  _ninja_sp_07
.globl  _ninja_sp_12
.globl  _ninja_sp_13
.globl  _ninja_sp_16
.globl  _ninja_sp_17

.globl  _shuriken_sp_0
.globl  _shuriken_sp_1

.globl  _enemigos_sp_0
.globl  _enemigos_sp_1
.globl  _enemigos_sp_2
.globl  _enemigos_sp_3
.globl  _enemigos_sp_4
.globl  _enemigos_sp_5
.globl  _enemigos_sp_6
.globl  _enemigos_sp_7


;; GLOBAL VECTORS

.globl  ninja_run_r
.globl  ninja_run_l
.globl  ninja_calm_r
.globl  ninja_calm_l
.globl  ninja_jump_r
.globl  ninja_jump_l
.globl  shuriken_move
.globl  enemigo_horizontal
.globl  enemigo_vertical

