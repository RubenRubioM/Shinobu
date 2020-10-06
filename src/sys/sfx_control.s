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

.module sys_sfx_control

shuriken_SFX::
    ld  de, #_shurikenSFX
    call cpct_akp_SFXInit_asm

    ld hl, #0x0F01
    ld de, #0x0008
    ld bc, #0x0000
    ld a, #3
    call cpct_akp_SFXPlay_asm

dead_enemy_SFX::
    ld  de, #_shurikenSFX
    call cpct_akp_SFXInit_asm

    ld hl, #0x0F01
    ld de, #0x0050
    ld bc, #0x0000
    ld a, #3
    call cpct_akp_SFXPlay_asm

ret