program sauroneditor;
const
    DIVCOMPAT=0;
    FONDOMENU=1;

    SAURONBASE=100;
    SAURONMAX=4;

    MOUSEBASE=200;
    COPYRIGHT="V 0.1  -  (c) 2020 Julio A. Garcia Lopez";

    NADA=0;
    NUEVOMAPA=1;
    CARGARMAPA=2;
    VERCREDITOS=3;
    SALIR=4;
global
    fpgMenus;
    fpgEdit;
    fpgTerreno;

    fntMenus;
    fntMediana;

    TEXTOSCREDITOS[]=
        "SAURON",
        "Programador: Julio A. Garcia Lopez:",
        "Graficos: Julio A. Garcia Lopez",
        "Agradecimientos especiales:",
        "- Maria",
        "- Citec",
        ""
    ;

    struct mapa[65536]
        terreno;
        unidad;
    end = 65536 dup (1, 0);
    fondo;


begin
    fpgMenus=load_fpg("fpg/sau2menu.fpg");
    fpgEdit=load_fpg("fpg/sau2edit.fpg");
    fpgTerreno=load_fpg("fpg/terrain.fpg");
    fntMenus=load_fnt("fnt/sauron.fnt");
    fntMediana=load_fnt("fnt/sauronm.fnt");
    set_mode(m1024x768);
    set_fps(30,0);
    mouse.file=fpgMenus;
    mouse.graph=200;
    intro();
    mainMenu();
end

/**
   Pone el efecto de fuego de detras de la intro
*/
process fondoIntro()
private
    vx=5;
    vy=3;
begin
    file=fpgMenus;
    graph=2;
    x=512;
    y=384;
    z=10;
    loop
        x+=vx;
        y+=vy;

        if(x>700 or x<300)
            vx*=-1;
        end

        if(y>400 or y<200)
            vy*=-1;
        end

        frame;
    end;
end;

/**
   Pone el logo de la intro
*/
function intro()
private
    fintro;
    time=0;
begin
    file=fpgMenus;
    graph=3;
    x=512;
    y=384;
    z=0;

    fintro=fondoIntro();
    while(time<250 and not key(_enter) and not key(_esc) and not mouse.left)
        time++;
        frame;
    end;
    fade_off();
    while(fading)
        frame;
    end;

    signal(fintro,s_kill);
    frame;
end;

/**
   Men� principal
*/
function mainMenu()
private
    txtCopyright;
    idSauron;
    pulsado=0;
begin
    let_me_alone();
    file = fpgMenus;
    mouse.graph = 200;

    loop
        put_screen(0, FONDOMENU);
        fade_on();
        while(fading)
            frame;
        end;

        idSauron = sauronMenu();
        txtCopyright = write(fntMenus,1020,760,5,COPYRIGHT);
        botonMenu(512, 500, "Nuevo Mapa", NUEVOMAPA, &pulsado);
        botonMenu(512, 570, "Cargar Mapa", CARGARMAPA, &pulsado);
        botonMenu(512, 640, "Ver Creditos", VERCREDITOS, &pulsado);
        botonMenu(512, 710, "Salir", SALIR, &pulsado);

        while(pulsado == 0)
            frame;
        end;

        fade_off();
        while(fading)
            frame;
        end;

        frame(0);
        frame;
        signal(idSauron,s_kill);
        delete_text(txtCopyright);

        switch(pulsado)
            case NUEVOMAPA:
                editor();
            end;
            case VERCREDITOS:
                pantallaTexto(&TEXTOSCREDITOS);
            end;
            case SALIR:
                exit("Gracias por jugar!",0);
            end;
        end

        pulsado=0;
    end
end

/**
  Pone un array de textos en pantalla
*/
function pantallaTexto(pointer arrayTextos)
private
    idTextos[64] = 64 dup (0);
    pulsado=0;
    idx;
    string tmp;
begin
    fade_on();
    botonMenu(512, 720, "Continuar", 1, &pulsado);

    for( idx=0; idx<64, arrayTextos[idx]!=""; idx++)
        /*
        Debido a las sobrecargas de gemix, necesitamos hacer algo para reinterpretar el valor como cadena
        En cambio, operaciones de este tipo en DIV son contraproducentes
        */
        if( DIVCOMPAT==0 )
            idTextos[idx]=write(fntMediana,512,400+(idx*50),4,arrayTextos[idx]);
        end
    end

    while(fading)
        frame;
    end

    while(pulsado==0)
        frame;
    end

    fade_off();
    delete_text(all_text);

    while(fading)
        frame;
    end
end

/**
   Ojo ardiente de los menus
*/
process sauronMenu()
private
    animacion=0;
begin
    file=fpgMenus;
    graph=SAURONBASE;

    x=512;
    y=200;

    loop
        animacion = (animacion + 1) mod SAURONMAX;
        graph=SAURONBASE+animacion;
        frame(200);
    end

end

/**
   Pone un boton en pantalla
   Parametros:
       x,y: Coordenadas
       texto: Texto a poner
       tag: Id del boton
       dst: Puntero a la variable donde volcar el Id cuando el boton se pulse
   Notas:
       Cuando el boton es pulsado, se pone en dst el valor de tag.
       Si en dst, en cualquier momento se pone cualquier valor distinto de 0, el bot�n finalizar� su ejecuci�n
*/
process botonMenu(x,y,texto,tag,pointer dst)
private
    status=0;
    txtId;
begin
    file=fpgMenus;
    graph=300;
    txtId=write(fntMenus,x,y,4,texto);

    while(*dst == 0)
        frame;
        if(collision(type mouse))
            if(mouse.left)
                graph = 301;
            else
                if( graph==301 )
                    graph = 300;
                    *dst=tag;
                    frame;
                end
            end
        else
            graph=300;
        end

    end

    delete_text(txtId);
end


/**
    Actualiza el mapa mostrado
    Parametros:
        x:
        y:
*/
function putTiles(x,y)
private
    i;
    j;
begin
    from i = 0 to 16; // Filas
        from j = 0 to 16; // Columnas
            map_put(fpgTerreno, 99, mapa[(y+i)*256+(x+j)].terreno, j*64, i*64);
        end
    end
    refresh_scroll(0);
    //put_screen(fpgTerreno,99);
end

/**
    Pone un terreno en el mapa
*/
function putTerrain(x,y,terrain)
begin
    mapa [ y*256+x ].terreno = terrain;
end

/**
Pinta el area de los controles, por lo demas no hace nada
*/
process areaControles()
begin
    file=fpgMenus;
    graph=4;
    x=512;
    y=384;
    z=-90;

    while(not key(_esc))
        frame;
    end

end

/**
   Proceso principal del editor
*/
function editor()
private
    tx=0;
    ty=0;
    tmp;
    txtX;
    txtY;
    update=false;
    terrenoPoner=3;

begin
    putTiles(0,0);
    areaControles();


    txtX=write_int(fntMenus,15,750,3,&tx);
    txtY=write_int(fntMenus,65,750,3,&ty);

    define_region(1,0,0,1024,600);
    start_scroll(0,fpgTerreno,98,99,1,0);

    file=fpgEdit;
    graph=1;
    //ctype=c_scroll;


    botonTerreno(64,690,1,&terrenoPoner);
    botonTerreno(128,690,2,&terrenoPoner);
    botonTerreno(192,690,3,&terrenoPoner);
    botonTerreno(256,690,11,&terrenoPoner);

    fade_on();
    while(not key(_esc))
        if(key(_right) and scroll.x0<15360)
            scroll[0].x0 += 64;
            update=true;            
            frame(300);            
        end

        if(key(_left) and scroll.x0>0 )
            scroll[0].x0 -= 64;
            update=true;
            frame(300);
        end

        if(key(_down) and scroll.y0<15360)
            scroll[0].y0 += 64;
            update=true;
            frame(300);
        end

        if(key(_up) and scroll.y0>0 )
            scroll[0].y0 -= 64;
            update=true;
            frame(300);
        end

        if(mouse.y<600)
            tmp = mouse.x;
            x= tmp - (tmp mod 64);
            tmp = mouse.y;
            y= tmp - (tmp mod 64);

            tx=(x+scroll.x0)/64;
            ty=(y+scroll.y0)/64;

            if(mouse.left)
                frame(300);
                putTerrain(tx,ty,terrenoPoner);
                update=true;
            end
        end

        if(update)
            putTiles(scroll.x0/64,scroll.y0/64);
            update=false;
            frame;
        end

        frame;
    end

    fade_off();
    delete_text(txtX);
    delete_text(txtY);
    stop_scroll(0);
    signal(type botonTerreno,s_kill);
    signal(type areaControles,s_kill);
end

/**
Selecciona el terreno a poner en el mapa
*/
process botonTerreno(x,y,graph,pointer terrenoPoner)
begin
    file=fpgTerreno;
    z=-91;

    loop
        if(*terrenoPOner!=graph)
            flags=4;
        else
            flags=0;
        end
        if(collision(type mouse) and mouse.left)
            *terrenoPoner=graph;
        end
        frame;
    end
end


