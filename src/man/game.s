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
;; GAME MANAGER
;;
;------------------------------------------------------------------------------------------------------------------------INCLUDES
.include "cpctelera_functions.h.s"
.include "man/entity.h.s"
.include "man/entity_bala.h.s"
.include "man/menu.h.s"
.include "man/collision.h.s"
.include "man/nivel.h.s"
.include "man/sprite.h.s"
.include "sys/hud.h.s"
.include "sys/input.h.s"
.include "sys/physics.h.s"
.include "sys/render.h.s"
.include "sys/ai_control.h.s"
.include "cmp/entity.h.s"
.include "cmp/sprite.h.s"
;--------------------------------------------------------------------------------------------------------------------------------

;; ----------------------------
;; GLOBALES
;; ----------------------------
.globl _ingameMusic
.globl _ninja_sp_16
.globl _shuriken_sp_0

;; ----------------------------
;; DEFINICION DE ENTIDADES
;; ----------------------------
;------------------------------------------------------------------------------------------------------------------------DEFINICION DE JUGADOR Y SU BALA
DefineEntity player,     0,  30, 100,30,120, 1, 1, 4, 16, e_ai_status_noAI, #_ninja_sp_16, #ninja_calm_r, 0 ,0, 0 ,0, 1
DefineEntity shuriken,     2,   0,   0, 0, 0,0,0, 2,  4, e_ai_status_noAI, #_shuriken_sp_0, #shuriken_move, 0 ,0, 0 ,0, 1
;------------------------------------------------------------------------------------------------------------------------DEFINICION DE ENEMGIGOS
;-----------------------------------------------------------------------------------------------------------NIVEL 1
DefineEntity unseen1_nivel1,     1,  0, 0,0,0, 0, 0, 0, 0, e_ai_status_standby, #_enemigos_sp_0, #enemigo_horizontal, 0 ,0, 0 ,0, 0
DefineEntity unseen2_nivel1,     1,  0, 0,0,0, 0, 0, 0, 0, e_ai_status_standby, #_enemigos_sp_4, #enemigo_vertical, 0 ,0, 0 ,0, 0
;-----------------------------------------------------------------------------------------------------------NIVEL 2
DefineEntity unseen1_nivel2,     1,  24, 75,24,75, 0, 0, 0, 0, e_ai_status_standby, #_enemigos_sp_0, #enemigo_horizontal, 24 ,40, 75 ,75, 0
DefineEntity unseen2_nivel2,     1,  24, 110,24,110, 0, 0, 0, 0, e_ai_status_standby, #_enemigos_sp_0, #enemigo_horizontal, 24 ,40, 110 ,110, 0
;-----------------------------------------------------------------------------------------------------------NIVEL 3
DefineEntity odokuro_nivel3,     1,  12, 20,12,20, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_0, #enemigo_horizontal, 12 ,28, 20 ,20, 1
DefineEntity oni_nivel3,         1,  30, 52,30,52, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_4, #enemigo_vertical, 30 ,30, 52 ,111, 1
;-----------------------------------------------------------------------------------------------------------NIVEL 4
DefineEntity odokuro_nivel4,     1,  24, 79,24,79, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_0, #enemigo_horizontal, 24 ,40, 79 ,79, 1
DefineEntity oni_nivel4,         1,  66, 35,66,35, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_4, #enemigo_vertical, 66 ,66, 35 ,99, 1
;-----------------------------------------------------------------------------------------------------------NIVEL 5
DefineEntity odokuro_nivel5,     1,  30, 96,30,96, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_0, #enemigo_horizontal, 30 ,60, 96 ,96, 1
DefineEntity oni_nivel5,         1,  40, 10,40,10, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_4, #enemigo_vertical, 40 ,40, 10 ,36, 1
;-----------------------------------------------------------------------------------------------------------NIVEL 6
DefineEntity oni_nivel6,     1,  40, 96,40,96, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_4, #enemigo_vertical, 40 ,40, 96 ,144, 1
DefineEntity oni2_nivel6,         1,  40, 26,40,26, 0, 0, 4, 16, e_ai_status_standby, #_enemigos_sp_4, #enemigo_vertical, 40 ,40, 26,90, 1

;------------------------------------------------------------------------------------------------------------------------DEFINICION DE MAPAS
;-----------------------------------------------------------------------------------------------------------NIVEL 1
;PLATAFORMA DE INICIO
DefineEntityObstacle plataforma1_nivel1,  1,    0,  144,  48, 12, #0xF0, 0
;PLATAFORMA DE INICIO 2
DefineEntityObstacle plataforma2_nivel1,  1,   48,  144,  28, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 1
DefineEntityObstacle plataforma3_nivel1,  1,   16,   104,  12, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 2 MINI
DefineEntityObstacle plataforma4_nivel1,  1,   36,   72,   4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 3
DefineEntityObstacle plataforma5_nivel1,  1,   48,   40,  12, 12, #0xF0, 0
;-----------------------------------------------------------------------------------------------------------NIVEL 2
;PLATAFORMA DE INICIO
DefineEntityObstacle plataforma1_nivel2,  2,    0,  144,  36, 12, #0xF0, 0
;TRAMPA AL LADO DE PLATAFORMA DE INICIO
DefineEntityObstacle trampa1_nivel2,  2,   48,  138,  28, 17, #0xFF, 1
;PLATAFORMA DE ESCALADA 1
DefineEntityObstacle plataforma2_nivel2,  2,    0,  112,  16, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 2 (ARRIBA DE LA PLATAFORMA DE ESCALADA 1)
DefineEntityObstacle plataforma3_nivel2,  2,    0,   78,  12, 13, #0xF0, 0
;PLATAFORMA DE ESCALADA 3 (DERECHA DE LAS PLATAFORMAS DE ESCALADA 1 Y 2)
DefineEntityObstacle plataforma4_nivel2,  2,   24,   86,  18, 13, #0xF0, 0
;PLATAFORMA DE ESCALADA 4 (MINI)
DefineEntityObstacle plataforma5_nivel2,  2,   52,   64,   4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 5 (ARRIBA DE LA MINI)
DefineEntityObstacle plataforma6_nivel2,  2,   68,   40,   8, 11, #0xF0, 0
;-----------------------------------------------------------------------------------------------------------NIVEL 3
;TRAMPA GIGANTE
DefineEntityObstacle trampa1_nivel3, 3,    0,  138,  44, 16, #0xFF, 1
;PLATAFORMA DE INICIO
DefineEntityObstacle plataforma1_nivel3, 3,    60,  136,  16, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 1
DefineEntityObstacle plataforma2_nivel3, 3,    36,   111,  16, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 2 (IZQUIERDA DE LA 1)
DefineEntityObstacle plataforma3_nivel3, 3,   12,   87,  16, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 3 (ARRIBA DE LA 1)
DefineEntityObstacle plataforma4_nivel3, 3,   36,   64,   16, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 3 (ARRIBA DE LA 1)
DefineEntityObstacle plataforma5_nivel3, 3,   12,   40,   16, 12, #0xF0, 0
;-----------------------------------------------------------------------------------------------------------NIVEL 4
;PLATAFORMA DE INICIO
DefineEntityObstacle plataforma2_nivel4, 4,    46,  144,  12, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 1
DefineEntityObstacle plataforma3_nivel4, 4,    36,   118,  8, 13, #0xF0, 0
;PLATAFORMA DE ESCALADA 2
DefineEntityObstacle plataforma4_nivel4, 4,    52,   103,  4, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 3
DefineEntityObstacle plataforma5_nivel4, 4,    60,   87,  4, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 4
DefineEntityObstacle plataforma6_nivel4, 4,    24,   103,  4, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 5
DefineEntityObstacle plataforma7_nivel4, 4,    16,   87,  4, 12, #0xF0, 0
;PLATAFORMA DE ESCALADA 6 MINI
DefineEntityObstacle plataforma8_nivel4, 4,   4,   64,  4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 7
DefineEntityObstacle plataforma9_nivel4, 4,    20,   47,  12, 12, #0xF0, 0
;TRAMPA 1
DefineEntityObstacle trampa1_nivel4, 4,   36,   58,   8, 22, #0xFF, 1
;PLATAFORMA DE ESCALADA 8
DefineEntityObstacle plataforma10_nivel4, 4,   48,   47,   12, 12, #0xF0, 0
;-----------------------------------------------------------------------------------------------------------NIVEL 5
;PLATAFORMA DE INICIO
DefineEntityObstacle plataforma1_nivel5, 5,    11,  152,  14, 12, #0xF0, 0
;PLATAFORMA AL LADO DE INICIO
DefineEntityObstacle plataforma2_nivel5, 5,   4,  120,  8, 12, #0xF0, 0
;PRIMERA PLATAFORMA DE TRAMPA
DefineEntityObstacle trampa1_nivel5, 5,    20,  106,  8, 22, #0xFF, 1
;PLATAFORMA GRANDE
DefineEntityObstacle plataforma3_nivel5, 5,    28,  112,  40, 12, #0xF0, 0
;PLATAFORMA ESCALADA 1
DefineEntityObstacle plataforma4_nivel5, 5,   72,   95,  4, 16, #0xF0, 0
;PLATAFORMA ESCALADA 2
DefineEntityObstacle plataforma5_nivel5, 5,   60,   80,  4, 12, #0xF0, 0
;TRAMPA ESCALADA 1
DefineEntityObstacle trampa2_nivel5, 5,   52,   73,  6, 22, #0xFF, 1
;PLATAFORMA ESCALADA 3
DefineEntityObstacle plataforma6_nivel5, 5,   48,   64,  4, 12, #0xF0, 0
;TRAMPA ESCALADA 2
DefineEntityObstacle trampa3_nivel5, 5,   40,   58,  6, 21, #0xFF, 1
;PLATAFORMA ESCALADA 4
DefineEntityObstacle plataforma7_nivel5, 5,   36,   48,  4, 12, #0xF0, 0
;TRAMPA ESCALADA 3
DefineEntityObstacle trampa4_nivel5, 5,   28,   42,  6, 22, #0xFF, 1
;-----------------------------------------------------------------------------------------------------------NIVEL 6
;PLATAFORMA DE INICIO
DefineEntityObstacle plataforma1_nivel6,  6,   20,  144,  4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 1
DefineEntityObstacle plataforma2_nivel6,  6,   32,  128,  4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 2
DefineEntityObstacle plataforma3_nivel6,  6,   48,  120,  4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 4
DefineEntityObstacle plataforma5_nivel6,  6,   52,  80,  4, 8, #0xF0, 0
;PLATAFORMA DE ESCALADA 5
DefineEntityObstacle plataforma6_nivel6,  6,   32,  56,  4, 8, #0xF0, 0
;TRAMPA 1
DefineEntityObstacle trampa1_nivel6,  6,   0,  0,  7, 160, #0xFF, 1
;TRAMPA 2
DefineEntityObstacle trampa2_nivel6,  6,   6,  11,  25, 6, #0xFF, 1
;TRAMPA 3
DefineEntityObstacle trampa3_nivel6,  6,   48,  11,  29, 6, #0xFF, 1
;TRAMPA 4
DefineEntityObstacle trampa4_nivel6,  6,   73,  0,  7, 160, #0xFF, 1
;JOYA
DefineEntityObstacle joya_nivel6,     6,   32,  0,  16, 8, #0xF0, 0



;; ----------------------------
;; CODIGO
;; ----------------------------
;------------------------------------------------------------------------------------------------------------------------FUNCION INICIAL
man_game_init::

;;                  MUSICA Y SFX
;; ===========================================================================
    ld  de, #_pauseMusic
    call cpct_akp_musicInit_asm

    call    man_entity_bala_init
    call    entityman_getEntityArray_IX
    call    sys_ai_control_init

    ;;
    ;; El menu entra en bucle hasta que pulses G de Game
    ;; ----------------------------
    call rendersys_intro
    call man_menu_control

    call cpct_akp_stop_asm
    ld  de, #_ingameMusic
    call cpct_akp_musicInit_asm
    ;; Init systems
    call rendersys_init

;------------------------------------------------------------------------------------------------------------------------CREACION DE JUGADOR Y SU BALA
    ;; Creamos al player
    ld    hl, #player
    call entityman_create
    ;; Creamos el shuriken
    ld    hl, #shuriken
    call entityman_create
;------------------------------------------------------------------------------------------------------------------------CREACION DE ENEMIGOS

;;                  ENEMIGOS NIVEL 1
;; ===========================================================================
    ld a, #1
    call entityman_setPtrNivel

    ld    hl, #unseen1_nivel1
    call entityman_create

    ld    hl, #unseen2_nivel1
    call entityman_create

;;                  ENEMIGOS NIVEL 2
;; ===========================================================================
    ld a, #2
    call entityman_setPtrNivel

    ld hl, #unseen1_nivel2
    call entityman_create

    ld hl, #unseen2_nivel2
    call entityman_create

;;                  ENEMIGOS NIVEL 3
;; ===========================================================================
    ld a, #3
    call entityman_setPtrNivel

    ld hl, #odokuro_nivel3
    call entityman_create

    ld hl, #oni_nivel3
    call entityman_create

;;                  ENEMIGOS NIVEL 4
;; ===========================================================================
    ld a, #4
    call entityman_setPtrNivel

    ld hl, #odokuro_nivel4
    call entityman_create

    ld hl, #oni_nivel4
    call entityman_create

;;                  ENEMIGOS NIVEL 5
;; ===========================================================================
    ld a, #5
    call entityman_setPtrNivel

    ld hl, #odokuro_nivel5
    call entityman_create

    ld hl, #oni_nivel5
    call entityman_create

;;                  ENEMIGOS NIVEL 6
;; ===========================================================================
    ld a, #6
    call entityman_setPtrNivel

    ld hl, #oni_nivel6
    call entityman_create

    ld hl, #oni2_nivel6
    call entityman_create


;;                  OBSTACULOS NIVEL 1
;; ===========================================================================
    ;;Cargamos el puntero a obstaculos nivel 1
    ld hl, #plataforma1_nivel1
    ld a, #1
    call collisionman_setPtrNivel

    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma1_nivel1
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #plataforma2_nivel1
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #plataforma3_nivel1
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #plataforma4_nivel1
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma5_nivel1
    call collisionman_create

;; ===========================================================================


;;                  OBSTACULOS NIVEL 2
;; ===========================================================================
    ;;Cargamos el puntero a obstaculos nivel 2
    ld hl, #plataforma1_nivel2
    ld a, #2
    call collisionman_setPtrNivel

    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma1_nivel2
    call collisionman_create
    ;TRAMPA GIGANTE
    ld    hl, #trampa1_nivel2
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #plataforma2_nivel2
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #plataforma3_nivel2
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #plataforma4_nivel2
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma5_nivel2
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 5
    ld    hl, #plataforma6_nivel2
    call collisionman_create

;; ===========================================================================


;;                  OBSTACULOS NIVEL 3
;; ===========================================================================
    ;;Cargamos el puntero a obstaculos nivel 1
    ld hl, #trampa1_nivel3
    ld a, #3
    call collisionman_setPtrNivel

    ;PLATAFORMA DE INICIO
    ld    hl, #trampa1_nivel3
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #plataforma1_nivel3
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #plataforma2_nivel3
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #plataforma3_nivel3
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma4_nivel3
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma5_nivel3
    call collisionman_create

;; ===========================================================================


;;                  OBSTACULOS NIVEL 4
;; ===========================================================================
    ;;Cargamos el puntero a obstaculos nivel 1
    ld hl, #plataforma2_nivel4
    ld a, #4
    call collisionman_setPtrNivel

    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma2_nivel4
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #plataforma3_nivel4
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #plataforma4_nivel4
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma5_nivel4
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma6_nivel4
    call collisionman_create
        ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma7_nivel4
    call collisionman_create
        ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma8_nivel4
    call collisionman_create
            ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma9_nivel4
    call collisionman_create
                ;PLATAFORMA DE ESCALADA 4
    ld    hl, #trampa1_nivel4
    call collisionman_create
                ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma10_nivel4
    call collisionman_create

;; ===========================================================================


;;                  OBSTACULOS NIVEL 5
;; ===========================================================================
    ;;Cargamos el puntero a obstaculos nivel 1
    ld hl, #plataforma1_nivel5
    ld a, #5
    call collisionman_setPtrNivel

    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma1_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #plataforma2_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #trampa1_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #plataforma3_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma4_nivel5
    call collisionman_create
    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma5_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #trampa2_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #plataforma6_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #trampa3_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma7_nivel5
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #trampa4_nivel5
    call collisionman_create

;; ===========================================================================


;;                  OBSTACULOS NIVEL 6
;; ===========================================================================
    ;;Cargamos el puntero a obstaculos nivel 1
    ld hl, #plataforma1_nivel6
    ld a, #6
    call collisionman_setPtrNivel

    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma1_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #plataforma2_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #plataforma3_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #plataforma5_nivel6
    call collisionman_create
    ;PLATAFORMA DE INICIO
    ld    hl, #plataforma6_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 1
    ld    hl, #trampa1_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 2
    ld    hl, #trampa2_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 3
    ld    hl, #trampa3_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #trampa4_nivel6
    call collisionman_create
    ;PLATAFORMA DE ESCALADA 4
    ld    hl, #joya_nivel6
    call collisionman_create

;;                  HUD
;; ===========================================================================
    call hudsys_init

ret

;------------------------------------------------------------------------------------------------------------------------FUNCION UPDATE
man_game_update::
    call z, sys_ai_control_update

    call entityman_getEntityArray_IX    ;; Mete en IX entity_array en apuntando a la primera posicion
    call inputsys_update

    call man_entity_bala_update         ;; Actualiza la posicion de la bala

    call entityman_getEntityArray_IX    ;; Mete en IX entity_array en apuntando a la primera posicion        
    call physicssys_update              ;; Actualiza valores de Y del entity_array

    call entityman_getEntityArray_IX
    call animation_man_update           ;; Cambia el sprite del jugador
    
    call entityman_getEnemigosNivel_IY
    call animation_man_enemy_update

    ret

;------------------------------------------------------------------------------------------------------------------------FUNCION RENDER
man_game_render::
    ;; De momento esto funciona porque solo usamos 0 y 1
    call rendersys_update                ;; Borra los dos personajes

;;                  DEBUG
;; ===========================================================================
    ;; Pintar colisiones en modo DEBUG
    ;call collisionman_getObstaclesNivel_IY
    ;call collisionman_getNumObstaclesNivel_A
    ;call rendersys_update_collision

    ret

man_game_reset::
    ld  de, #_ingameMusic
    call cpct_akp_musicInit_asm

    ;; Esto es necesario para que el gameover funcione varias veces
    call rendersys_reset_fin_pintar_fondo_muerte
    call rendersys_reset_fin_pintar_fondo_victoria
    call rendersys_pintar_fondo

    ;; Reiniciamos por si se estaba mostrando el easterEgg
    call hudsys_reset_easterEgg
    ;; Reiniciamos shurikens
    call man_entity_bala_recargar
    call man_entity_bala_reset

    ;; Reiniciamos vidas y jugador
    call nivelman_restart_nivelMax
    call entityman_resetVidas
    call entityman_getEntityArray_IX

    ld a, #30
    ld e_x(ix), a
    ld a, #120
    ld e_y(ix), a
    
    ;; Repintamos mapa
    call rendersys_init
    call hudsys_init

    ;; Reseteamos vidas de los enemigos
    call entityman_getNumEntities_A
    call entityman_getEntityArray_IX

    _loop_reset_enemigos:
        push af
        ld a, e_w(ix)
        cp #0           ;; Si no tiene width es que no tiene vida
        jr z, siguiente_entidad

            ;; Ponemos su vida a 1
            ld a, #1
            ld e_vivo(ix), a

        siguiente_entidad:
            pop af
            dec	a
            ret z
        
            ld bc, #sizeof_e  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
            add ix, bc           ;; Sumamos a IX el tamaño de una entidad para pasar a la siguiente (#sizeof_e)

            jp _loop_reset_enemigos

    ret