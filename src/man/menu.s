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
;; MENU
;;

.include "sys/input.h.s"
.include "sys/render.h.s"
.include "cpctelera_functions.h.s"

;;
;; Bucle de comprobacion de tecla MENU
;; ----------------------------
man_menu_control::

    _loopMenu:
    call    cpct_waitVSYNC_asm
    call    cpct_akp_musicPlay_asm
    call    inputsys_menu_update    ;; Funcion de input del menu
    jr  	z, man_menu_control     ;; Mientras no pulses G, estara en bucle
    ret