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
;; PHYSICS SYSTEM
;;
.area _DATA
.area _CODE

.include "cpctelera.h.s"
.include "cpctelera_functions.h.s"
.include "man/entity.h.s"
.include "cmp/entity.h.s"
.include "man/collision.h.s"
.include "man/nivel.h.s"
.include "man/entity_bala.h.s"
.include "sys/hud.h.s"
.include "sys/sfx_control.h.s"

numero_enemigos: .db 2
numero_obs: .db 0
colisiona_abajo: .db 0      ;; 0 = no colisiona abajo || 1 = colisiona abajo


;; INPUT:
;; IX: Pointer to first entity to render
physicssys_update::
    ;; TODO: comprobaremos aqui que nivel estamos para meter en IY los obstaculos
    ;; de momento esta al comienzo de comprobar_colisiones_player_obstacles
    call check_win
    call comprobar_cambio_nivel
    call comprobar_salto
    call update_push
    call comprobar_colisiones_player_obstacles
    call comprobar_colision_bala_obstacles
    call comprobar_colision_bala_enemigos
    call comprobar_colision_player_enemigos
    ret

check_win:
    call nivelman_getNivel_A
    cp #6
    jp z, in_level6
    
    ret

    in_level6:
        call entityman_getEntityArray_IX
        ld a, e_y(ix)
        cp #10
        jp z, win

        ret

        win:
            call cpct_akp_stop_asm
            ld  de, #_pauseMusic
            call cpct_akp_musicInit_asm
            ld a, #3
            call inputsys_setEstado
            ret





update_push:
    call entityman_getEntityArray_IX
    call entityman_getPlayerPush_HL ;; HL apunta a player_push
    ld a, (hl)
    cp #-1 
    ret z ;; Si es -1 no esta siendo empujado

    ;;Valor del empuje
    call entityman_getPushTable_HL
    ld c, a ;; C = player_push
    ld b, #0
    add hl, bc   ;; HL += BC (Para aumentar la pushtable a la siguiente posicion)

    ;; Comprobar final del push
    ld a, (hl) ;; A = pushtable
    cp #0x80 ;; Comprobamos si esta al final
    jr nz, hacer_push

        acabar_push:
        ld a, #-1
        call entityman_setPlayerPush
        ret
        
    ;; Hacer salto
    hacer_push:
        ;; Comprobmos hacia que direccion esta siendo empujado
        call entityman_getPlayerPushDirection_A
        cp #1
        jr z, hacia_derecha

            ;; Va hacia la izquierda
            call entityman_getPushTable_HL
            ld a, (hl)
            ld c, a ;; C = player_push
            ld b, #0
            add hl, bc   ;; HL += BC (Para aumentar la pushtable a la siguiente posicion)
            ld b, a ;; B = pushTable
            ld a, e_x(ix) ;; A = player.x
            sub b         ;; A -= B
            ;; Comprobamos que no choque con las paredes, si es menor que 4 ya no se mueve
            cp #4
            jr c, acabar_push
            ld e_x(ix), a ;; Actualizamos variable

            jr incrementar_index

        hacia_derecha:
        call entityman_getPushTable_HL
        ld a, (hl)
        ld c, a ;; C = player_push
        ld b, #0
        add hl, bc   ;; HL += BC (Para aumentar la pushtable a la siguiente posicion)
        ld b, a ;; B = pushTable
        ld a, e_x(ix) ;; A = player.x
        add b         ;; A += B
        ;; Comprobamos que no choque con las paredes, si es menor que 4 ya no se mueve
        cp #76
        jr nc, acabar_push
        ld e_x(ix), a ;; Actualizamos variable

    ;; Incrementamos player_push index
    incrementar_index:
    call entityman_getPlayerPush_HL
    ld a, (hl)       ;; A = player_push
    inc a
    ld (hl), a
    ret	


;; INPUTS: IX (player)
;;         IY (enemy)
empezar_push:
    ld a, #0
    call entityman_setPlayerPush
    ;;if(enemy.x > player.x) ->empujamos hacia la izquierda (-1)
    ;; enemy.x - player.x > 0

    ld a, e_x(iy)   ;; A = enemy.y
    sub e_x(ix)
    jr c, push_derecha

        ;; Push izquierda
        ld a, #-1
        call entityman_setPlayerPushDirection
        ret

    push_derecha:
    ld a, #1
    call entityman_setPlayerPushDirection
    ret	

reposicionar_por_danyo:
    ;; Reposicionamso y cambiamos vida
    ld a, #30
    ld e_x(ix), a
    ld a, #120
    ld e_y(ix), a
    call entityman_decVida

    ;; Lo ponemos en el nivel 1
    ld a, #1
    call nivelman_setNivel
    call rendersys_init
    call hudsys_init
    ;; TO-DO pintar hmmm!!! cuando te hacen daño
    call hudsys_pintarEasterEgg


    ret


comprobar_cambio_nivel:
    call entityman_getEntityArray_IX
    ld a, e_y(ix)
    cp #6
    jr nc, comprobar_limite_por_debajo
        call nivelman_incNivel      ;; Incrementamos nivel
        call reposicionar_inicio_nivel
        call rendersys_init  ;; Dibujamos siguiente nivel
        call man_entity_bala_recargar ;; Recargamos balas
        call hudsys_init
        call nivelman_updateNivelMax
        ;; MOMENTANEO
        ;call rendersys_update_collision
        ret

    comprobar_limite_por_debajo:
    cp #155
    ret c ;; Si no da carry es que es menor de 180
        call nivelman_decNivel
        ld a, #11
        ld e_y(ix), a
        call rendersys_init
        call hudsys_init
    ret

reposicionar_inicio_nivel:
    call entityman_getEntityArray_IX
    call nivelman_getNivel_A

    cp #2
    jr z, reposicion2
    cp #3
    jr z, reposicion3
    cp #4
    jr z, reposicion4
    cp #5
    jr z, reposicion5
    cp #6
    jr z, reposicion6
    cp #7
    jr z, reposicion7
    cp #8
    jr z, reposicion8
    cp #9
    jr z, reposicion9
    ret	

    reposicion2:
        ld a, #20
        ld e_x(ix), a
        ld a, #130
        ld e_y(ix), a
        ret
    reposicion3:
        ld a, #60
        ld e_x(ix), a
        ld a, #120
        ld e_y(ix), a
        ret
    reposicion4:
        ld a, #52
        ld e_x(ix), a
        ld a, #120
        ld e_y(ix), a
        ret
    reposicion5:
        ld a, #12
        ld e_x(ix), a
        ld a, #130
        ld e_y(ix), a
        ret
    reposicion6:
        ld a, #22
        ld e_x(ix), a
        ld a, #130
        ld e_y(ix), a
        ret
    reposicion7:
        ret
    reposicion8:
        ret
    reposicion9:
        ret

    

;===============================================================================================================================
;;                                  COMPROBANTES COLISIONES OBSTACULOS
;; RETURNS : A
comprobar_colisiones_y_arriba_obs:
    ;; Comprobamos si colisiones por abajo
    ;; if(player.y + player.h >= obs.y)
    ;;              &&
    ;; if(player.y + player.h <= obs.y + obs.h)

    ;; 1º (player.y + player.h) - obs.y >= 0
    ;;              &&
    ;; 2º (player.y + player.h) - obs.y - obs.h <= 0

    ;; (player.y + player.h) - obs.y >= 0
    ld a, e_y(ix)   ;; A = player.y
    add e_h(ix)     ;; A = player.y + player.h
    sub e_y_obs(iy)     ;; A = player.y + player.h - obs.y

    jr c, no_colision_abajo ;; Si da <0, no colisiona

        ;; Se cumple la primera condicion (player.y + player.h) - obs.y >= 0
        ;; Ahora comprobamos la segunda (player.y + player.h) - obs.y - obs.h <= 0
        ld a, e_y(ix)   ;; A = player.y
        add e_h(ix)     ;; A = player.y + player.h
        sub e_y_obs(iy)     ;; A = player.y + player.h - obs.y
        sub e_h_obs(iy)     ;; A = player.y + player.h - obs.y - obs.h
        jr nc, no_colision_abajo    ;; Si da >0, no colisiona

            ;; Colisiona en Y
            ld a, #1
            ret

    no_colision_abajo:
    ld a, #0
    ret   

;; RETURNS: A
comprobar_colisiones_y_abajo_obs: 
    ;; Vamos a comprobar si choca con la cabeza en alguna plataforma para hacer que caiga
    ;; if(player.y <= obs.y + obs.h)
    ;;              &&
    ;; if(player.y + >= obs.y)

    ;; 1º player.y - obs.y - obs.h <= 0
    ;;              &&
    ;; 2º player.y - obs.y >= 0

    ld a, e_y(ix)   ;; A = player.y
    sub e_y_obs(iy)     ;; A = player.y - obs.y
    sub e_h_obs(iy)     ;; A = player.y - obs.y - obs.h
    jr nc, no_colision_arriba

        ;; Se cumple la primera, ahora comprobamos la segunda
        ;; 2º player.y - obs.y >= 0
        ld a, e_y(ix)   ;; A = player.y
        sub e_y_obs(iy)     ;; A = player.y - obs.y
        jr c, no_colision_arriba

            ;; Colisiona en Y
            ld a, #1
            ret

    no_colision_arriba:
    ld a, #0
    ret

comprobar_colision_en_x_obs:
    ;; 1º if(player.x <= obs.x + obs.w)
    ;;              &&
    ;; 2º if(player.x + player.w >= obs.x)

    ;; 0 <= (obs.x + obs.w) - player.x
    ld a, e_x_obs(iy)   ;; A = obs.x
    add e_w_obs(iy)     ;; A = obs.x + obs.w
    sub e_x(ix)     ;; A = (obs.w + obs.x) - player.x
    jr c, no_colisiona_en_x  ;; Si da <0, no colisiona

        ;; Se cumple la 1º, ahora comprobamos la segunda
        ;; (player.x + player.w) - obs.x >= 0
        ld a, e_x(ix)   ;; A = player.x
        add e_w(ix)     ;; A = player.x + player.w
        sub e_x_obs(iy)     ;; A = (player.w + player.x) - obs.x
        jr c, no_colisiona_en_x ;; Si da <0, no colisiona

            ;; Por ultimo si colisiona en X metemos un 1 en A y devolvemos
            ld a, #1
            ret

    no_colisiona_en_x:
        ld a, #0    ;; Devolvemos un 0 si no colisiona
        ret

comprobar_colisiones_y_bala_obs:
    ;; Vamos a comprobar si choca con la cabeza en alguna plataforma para hacer que caiga
    ;; if(player.y + player.h >= obs.y)
    ;;              &&
    ;; if(player.y <= obs.y + obs.h)

    ;; 1º player.y + player.h - obs.h >= 0
    ;;              &&
    ;; 2º obs.y + obs.h - player.y >= 0

    ld a, e_y(ix)   ;; A = player.y
    add e_h(ix)     ;; A = player.y + player.h
    sub e_y_obs(iy)     ;; A = player.y + player.h - obs.y
    jr c, no_colision_bala_obs

        ;; 2º obs.y + obs.h - player.y >= 0
        ld a, e_y_obs(iy)   ;; A = obs.y
        add e_h_obs(iy)     ;; A = obs.y + obs.h
        sub e_y(ix)     ;; A = obs.y + obs.h - player.y
        jr c, no_colision_bala_obs

            ld a, #1
            ret

    no_colision_bala_obs:
    ld a,#0
    ret
;===============================================================================================================================

;===============================================================================================================================
;;                                  COMPROBANTES COLISIONES ENEMIGOS
comprobar_colisiones_y_enemigo:
    ;; Vamos a comprobar si choca con la cabeza en alguna plataforma para hacer que caiga
    ;; if(player.y + player.h >= enemy.y)
    ;;              &&
    ;; if(player.y <= enemy.y + enemy.h)

    ;; 1º player.y + player.h - enemy.h >= 0
    ;;              &&
    ;; 2º enemy.y + enemy.h - player.y >= 0

    ld a, e_y(ix)   ;; A = player.y
    add e_h(ix)     ;; A = player.y + player.h
    sub e_y(iy)     ;; A = player.y + player.h - enemy.y
    jr c, no_colision_enemigo

        ;; 2º enemy.y + enemy.h - player.y >= 0
        ld a, e_y(iy)   ;; A = enemy.y
        add e_h(iy)     ;; A = enemy.y + enemy.h
        sub e_y(ix)     ;; A = enemy.y + enemy.h - player.y
        jr c, no_colision_enemigo

            ld a, #1
            ret

    no_colision_enemigo:
    ld a,#0
    ret

comprobar_colision_en_x_enemigo:
    ;; 1º if(player.x <= obs.x + obs.w)
    ;;              &&
    ;; 2º if(player.x + player.w >= obs.x)

    ;; 0 <= (obs.x + obs.w) - player.x
    ld a, e_x(iy)   ;; A = obs.x
    add e_w(iy)     ;; A = obs.x + obs.w
    sub e_x(ix)     ;; A = (obs.w + obs.x) - player.x
    jr c, no_colisiona_en_x_enemigo  ;; Si da <0, no colisiona

        ;; Se cumple la 1º, ahora comprobamos la segunda
        ;; (player.x + player.w) - obs.x >= 0
        ld a, e_x(ix)   ;; A = player.x
        add e_w(ix)     ;; A = player.x + player.w
        sub e_x(iy)     ;; A = (player.w + player.x) - obs.x
        jr c, no_colisiona_en_x_enemigo ;; Si da <0, no colisiona

            ;; Por ultimo si colisiona en X metemos un 1 en A y devolvemos
            ld a, #1
            ret

    no_colisiona_en_x_enemigo:
        ld a, #0    ;; Devolvemos un 0 si no colisiona
        ret

;===============================================================================================================================


comprobar_colisiones_player_obstacles:

    ;; Ponemos que no esta colisionando por debajo a nada
    ld a, #0
    ld (colisiona_abajo), a

    call entityman_getEntityArray_IX
    call collisionman_getObstaclesNivel_IY      

    call collisionman_getNumObstaclesNivel_A     ;; A = num_obstacles
    ld (numero_obs), a                   ;; numero_obs = num_obstacles
    bucle_obstaculos:
    ;; Tenemos en IX el personaje y en IY el primer elemento de los obstaculos

    
        call comprobar_colisiones_y_arriba_obs ;; Devuelve en A si colisiona o no
        cp #0
        jr z, comprobar_colision_arriba
        ;; Llegados hasta aqui es que colisiona en Y, falta ver si estan en X tambien
        call comprobar_colision_en_x_obs    ;; Devuelve en A si colisiona o no
        cp #0       ;; A - 0
        jr z, comprobar_colision_arriba

            ;; TO-DO: Aqui tendremos que comprobar cuanto se hunde y realizar los calculos pertinentes
            ;;        asi como modificar el salto y demas parametros al colisionar por abajo
            call entityman_getPlayerJump_HL     ;; HL = puntero a player_jumping
            ld a, #-1
            ld (hl), a
            

            ;; Ponemos a 1 la variable de colision abajo
            ld a, #1
            ld (colisiona_abajo), a

            ;; Comprobamos si es un pincho para restar vida
            ld a, e_dan_obs(iy) ;; A = obs.danyo
            or a
            jr z, reposicion_abajo
                ;; Danyo = 1
                ;; Reposicionamos en sitio seguro y restamos vida
               call reposicionar_por_danyo

            reposicion_abajo:
            ;; Ahora vamos a ponerlo justo encima de la plataforma por si se hunde
            call reposicionar_colision_abajo
            jr fin_colision    ;; 

  


    comprobar_colision_arriba:
    
        call comprobar_colisiones_y_abajo_obs ;; Devuelve en A si colisiona o no
        cp #0
        jr z, fin_colision
        ;; Colisiona en Y
        call comprobar_colision_en_x_obs    ;; Devuelve en A si colisiona o no
        cp #0       ;; A - 0
        jr z, fin_colision

            ;; Colisiona en X e Y
            ;; Iniciamos gravedad (poner el indice en el final)
            call entityman_getPlayerJump_HL ;; HL apunta a player_jump
            ld a, #empieza_gravedad
            ld (hl), a
            ;; TODO: Aqui tenemos que hacer la reposicion de colision arriba
            ;; Comprobamos si es un pincho para restar vida
            ld a, e_dan_obs(iy) ;; A = obs.danyo
            or a
            jr z, reposicion_arriba
                ;; Danyo = 1
                ;; Reposicionamos en sitio seguro y restamos vida
                call reposicionar_por_danyo

            reposicion_arriba:
            call reposicionar_colision_arriba

    

    fin_colision:

    ld a, (numero_obs)  
    dec	a
    jr z, comprobamos_gravedad;; No quedan entidades, saltamos a ver si no ha habido colisiones por debajo para activar la gravedad
    
    ld (numero_obs), a
    
    ld bc, #sizeof_e_obs  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
    add iy, bc           ;; Sumamos a IY el tamaño de una entidad para pasar a la siguiente (#sizeof_e)
    jr bucle_obstaculos


    ;; AQUI ACABAMOS EL BUCLE
    comprobamos_gravedad:
    ld a, (colisiona_abajo)
    cp #1
    ret z   ;; Si  colisiona con nada por debajo hacemos ret

    ;; Si no colisiona por abajo activaremos la gravedad
    call entityman_getPlayerJump_HL ;; HL apunta a player_jump
    ld a, (hl)  ;; A = indice de la jump table
    cp #fin_del_salto    ;; Comprobamos que ha llegado al maximo de salto para empezar a caer
    ret c

    ;; Iniciamos gravedad (poner el indice en el final)
    ld a, #empieza_gravedad
    ld (hl), a
    ret

;; INPUTS: IX -> Player
;;         IY -> obstaculo
;; Returns: 1 -> Colisiona en X
;;          0 -> NO colisiona en X

comprobar_salto:
    call entityman_getPlayerJump_HL ;; HL apunta a player_jump
    call entityman_getEntityArray_IX
    ld a, (hl)
    cp #-1 
    ret z ;; Si es -1 no esta saltando

    ;;Valor del salto
    call entityman_getJumpTable_HL
    ld c, a ;; C = player_jump
    ld b, #0
    add hl, bc   ;; HL += BC (Para aumentar la jumpTable a la siguiente posicion)

    ;; Comprobar final del salto
    ld a, (hl) ;; A = jumpTable
    cp #0x80 ;; Comprobamos si esta al final
    jr nz, hacer_salto

        retroceder_salto:
        dec hl
        
    ;; Hacer salto
    hacer_salto:
    ld b, a ;; B = jumpTable
    ld a, e_y(ix) ;; A = player.y
    add b         ;; A += B
    ld e_y(ix), a ;; Actualizamos variable

    ;; Incrementamos player_jump index
    call entityman_getPlayerJump_HL
    ld a, (hl)       ;; A = player_jump
    inc a
    ld (hl), a
    ret	



;; INPUTS: IX -> player
;;         IY -> obstaculo
reposicionar_colision_abajo:
    ;; obs.y - (player.y + player.h)

    ld a, e_y(ix)       ;; A = player.y
    add e_h(ix)         ;; A = player.y + player.h
    ld b, a             ;; B = player.y + player.h
    ld a, e_y_obs(iy)   ;; A = obs.y
    sub b               ;; A = obs.y - (player.y + player.h) || 150 - (145 + 16) = -11

    ;; Ahora en A tenemos lo que le tenemos que quitar a Y de haberse pasado
    add e_y(ix)
    ld e_y(ix), a
    ret

;; INPUTS: IX -> player
;;         IY -> obstaculo
reposicionar_colision_arriba:
    ;; player.y - (obs.y + obs.h)
    ld a, e_y_obs(iy)   ;; A = obs.y
    add e_h_obs(iy)     ;; A = obs.y + obs.h
    ld b, a             ;; B = obs.y + obs.h
    ld a, e_y(ix)       ;; A = player.y
    sub b               ;; A = player.y - (obs.y + obs.h) || 150 - (144 + 8) = -2

    neg 
    add e_y(ix)
    ld e_y(ix), a
    ret

;; INPUTS: IX (bala)
;;         IY (obstaculos)
comprobar_colision_bala_obstacles:
    call man_entity_bala_getNumBala_A
    cp #0
    ret z   ;; Si no hay bala no comprueba colisiones

    ;; Si hay bala comprobamos colisiones
    call man_entity_bala_getPtrIX           ;; IX = bala
    call collisionman_getObstaclesNivel_IY       ;; IY = obstaculos
    call collisionman_getNumObstaclesNivel_A     ;; A = num_obstacles
    ld (numero_obs), a                      ;; numero_obs = num_obstacles
    bucle_obstaculos2:

    ;; Comprobamos colision en X
    call comprobar_colision_en_x_obs    ;; Devuelve 1 o 0 en A
    cp #0
    jr z, siguiente_entidad

        call comprobar_colisiones_y_bala_obs
        cp #0
        jr z, siguiente_entidad

            resetear_bala:
            call man_entity_bala_reset  ;; Reseteamos la bala

    

    siguiente_entidad:
    ld a, (numero_obs)  
    dec	a
    ret z;; No quedan entidades, saltamos a ver si no ha habido colisiones por debajo para activar la gravedad
    
    ld (numero_obs), a
    
    ld bc, #sizeof_e_obs  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
    add iy, bc           ;; Sumamos a IY el tamaño de una entidad para pasar a la siguiente (#sizeof_e)
    jr bucle_obstaculos2
    ret

;; INPUTS: IX (bala)
;;         IY (enemigos)
comprobar_colision_bala_enemigos:
    call man_entity_bala_getNumBala_A
    cp #0
    ret z   ;; Si no hay bala no comprueba colisiones

    ld a, #2
    ld (numero_enemigos), a
    ;; Si hay bala comprobamos colisiones
    call man_entity_bala_getPtrIX           ;; IX = bala
    call entityman_getEnemigosNivel_IY       ;; IY = enemigos

    bucle_bala_enemigos:
    ld a, e_vivo(iy)
    cp #0
    jr z, siguiente_enemigo
    
    ;; Comprobamos colision en X
    call comprobar_colision_en_x_enemigo    ;; Devuelve 1 o 0 en A
    cp #0
    jr z, siguiente_enemigo

        call comprobar_colisiones_y_enemigo
        cp #0
        jr z, siguiente_enemigo

            matar_enemigo:
            call dead_enemy_SFX
            ld a, #0
            ld e_vivo(iy), a
            call rendersys_borrar_enemigo  

    siguiente_enemigo:
    ld a, (numero_enemigos)  
    dec	a
    ret z
    
    ld (numero_enemigos), a
    
    ld bc, #sizeof_e  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
    add iy, bc           ;; Sumamos a IY el tamaño de una entidad para pasar a la siguiente (#sizeof_e)
    jr bucle_bala_enemigos

    ret


comprobar_colision_player_enemigos:

    ld a, #2
    ld (numero_enemigos), a
    call entityman_getEntityArray_IX           ;; IX = player
    call entityman_getEnemigosNivel_IY       ;; IY = enemigos

    bucle_player_enemigos:
    ld a, e_vivo(iy)
    cp #0
    jr z, siguiente_enemigo2
    
    ;; Comprobamos colision en X
    call comprobar_colision_en_x_enemigo    ;; Devuelve 1 o 0 en A
    cp #0
    jr z, siguiente_enemigo2

        call comprobar_colisiones_y_enemigo  ;; Si tiene enemigo por encima
        cp #0
        jr z, siguiente_enemigo2

            ;call nz, reposicionar_por_danyo
            call nz, empezar_push
            jr z, siguiente_enemigo2

    siguiente_enemigo2:
    ld a, (numero_enemigos)  
    dec	a
    ret z
    
    ld (numero_enemigos), a
    
    ld bc, #sizeof_e  ;; Tamaño de una entidad (al ser una constante no se si aqui haria falta parentesis para acceder al dato directamente)
    add iy, bc           ;; Sumamos a IY el tamaño de una entidad para pasar a la siguiente (#sizeof_e)
    jr bucle_player_enemigos

    ret