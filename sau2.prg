program sauron;
const
    FONDOMENU=1;

    SAURONBASE=100;
    SAURONMAX=4;

    MOUSEBASE=200;
    COPYRIGHT="V 0.1  -  (c) 2020 Julio A. Garcia Lopez";
global
    fpgMenus;
    fntMenus;
    fntMediana;

    struct textos
        creditos[]=
            "SAURON",
            "Programador: Julio A. Garcia Lopez:",
            "Graficos: Julio A. Garcia Lopez",
            "Agradecimientos especiales:",
            "- Citec";
    end;

begin
    fpgMenus=load_fpg("fpg/sau2menu.fpg");
    fntMenus=load_fnt("fnt/sauron.fnt");
    fntMediana=load_fnt("fnt/sauronm.fnt");
    set_mode(m1024x768);
    set_fps(30,0);
    intro();
    mainMenu();
end;

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
        end;

        frame;
    end;
end;

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
    while(time<250 and not key(_enter) and not(key(_esc)))
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

function mainMenu()
private
    txtCopyright;
    idSauron;
    pulsado=0;
begin
    let_me_alone();
    file = fpgMenus;
    mouse.graph = 200;

    while(pulsado != 3)
        put_screen(0, FONDOMENU);
        fade_on();
        while(fading)
            frame;
        end;

        idSauron = sauronMenu();
        txtCopyright = write(fntMenus,1020,760,5,COPYRIGHT);
        botonMenu(512, 500, "Nueva Partida", 1, &pulsado);
        botonMenu(512, 575, "Ver Creditos", 2, &pulsado);
        botonMenu(512, 650, "Salir", 3, &pulsado);

        while(pulsado == 0)
            frame;
        end;

        fade_off();
        while(fading)
            frame;
        end;

        switch(pulsado)
            case 2:
                pantallaTexto(6,&TEXTOSCREDITOS);
                frame(200);
                pulsado=0;
            end;
        end

        signal(idSauron,s_kill);
        delete_text(txtCopyright);
    end

end;

//Pone un array de textos en pantalla
function pantallaTexto(numTextos,pointer arrayTextos)
private
    idTextos[64];
    pulsado=0;
    idx;
    string tmp;
begin
    fade_on();
    botonMenu(512, 720, "Continuar", 1, &pulsado);
    while(fading)
        frame;
    end;


    idx=0;
    if(numTextos>64)
        numTextos=64;
    end;

    for( idx=0; idx<numTextos; idx++)
        idTextos[idx]=write(fntMediana,512,400+(idx*50),4,&arrayTextos[idx]);
    end;

    while(pulsado==0)
        frame;
    end;

    fade_off();
    idx=0;
    while(idx < numTextos)
        delete_text(idTextos[idx]);
        idx++;
    end;

    while(fading)
        frame;
    end;
end;



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
    end;

end;

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
                end;
            end
        else
            graph=300;
        end;

    end;

    delete_text(txtId);
end;
