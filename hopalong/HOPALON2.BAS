'######################################################
'#                     Musical Hopalong
'#
'#   version 31-01-2021
'#  
'# - generate notes from the Hopalong fractal algorithm
'#   (taken from HUEPFEL.BAS by Wolfgang Stroh)
'# - displays fractal in 16 colours and plays the notes
'# - output via MIDI or serial
'# Changes:
'# - window now drawn via HGT
'######################################################


DEFINT a-z

' To access MIDI or serial port
LIBRARY "bios"

' These are NOT remarks but compiler directives!
'----------------------------------------------------
' Include parts of the HiSoft-Basic GEM Toolbox (HGT)
REM $include toolbox.bas
REM $include menu.bas
REM $include dialog.bas
REM $include window.bas
REM $include textwind.bas
' use only 50k
REM $option y,k50
' load resource info
REM $include e:\hbasic\hopalong.bh                         ' check path!
'-----------------------------------------------------

' Main program with required loop for hgt

startprogram "e:\hbasic\hopalong.rsc",menu,mnquit          ' check path!

InitTextWindows 1,1
whandle=OpenTextWindow("Musical Hopalong",win_all-win_info)

hgtloop
stopprogram

'----------------------------------------------------

' Subroutines

SUB processusermenus (VAL wind,VAL item,VAL title)
    SHARED Finished_Flag,MyWindow,whandel,port%
    STATIC dum,but,okb
    SELECT CASE item
      CASE mnabout
        selecttree about
        dum=handledialog(0)
      CASE mnport
        selecttree settings
        okb=handledialog(0)
        but=getbutton(0)
        IF but=4 AND okb=2 THEN port%=1   ' radio button <serial> selected and <OK> pressed 
      CASE mnopen
        IF port%=0 THEN port%=3           ' default to midi 
        init
    END SELECT
END SUB


SUB init
    SHARED whandle,a!,b!,c!,s!,ao!,bo!,co!,so!,xo!,yo!,x_old!,y_old!,wx,wy,ww,wh,wm!,hm!,wwm!,whm!
    LOCAL dum
    dum = wind_get(whandle,7,wx,wy,ww,wh)
    'WINDOW GET 2,1,wx,wy,ww,wh
    IF ww > 640 THEN
    ' leave some space for a menu bar at the bottom of large screens
        wh = wh-19
        CALL redraw(whandle,wx,wy,ww,wh)
    END IF
' init hopalong
    a! = 4000
    b! = 4000
    c! = 3000
    s! = 30
    b! = b!/10000
    s! = s!/100
' init x,y coordinates    
    x_old! = 0
    y_old! = 0
    ao! = a!
    bo! = b!
    co! = c!
    so! = s!
    xo! = wx + ww/2      'xo/yo is the centre of our window
    yo! = (wy + wh/2)-19 'correction for the window's title bar
' init via modulo to fit the screen
    wm! = (ww-wx)/2
    hm! = (wh-wy)/2
    wwm! = wm! * 100
    whm! = hm! * 100
    gaugespeed
    calculate
END SUB


SUB calculate
    SHARED a!,b!,c!,s!,ao!,bo!,co!,so!,xo!,yo!,x_old!,y_old!,note_new,note_old,ww,wh,wwm!,whm!,port%,delay!
    STATIC start!,x!,y!,z!,l!,t!,i!,xp!,yp!,pcolor
    start!=TIMER
    z!=0
    pcolor=0
    'PRINT "Hopalong algorithm: ("+STR$(a!)+" /"+STR$(b!)+" /"+STR$(c!)+") 
    LOCATE 1,1
    PRINT "         - Output port:"; STR$(port%); " - Click mouse to stop"
    DO
        INCR i!
        ' Hopalong algo
        x! = y_old! - SGN(x_old!) * ((b! * x_old! - c!)) MOD wwm!
        y! = a! - x_old! MOD whm!
        xp! = FIX(xo! + x!/100)
        yp! = FIX(yo! + y!/100)
        pcolor = pcolor + 1
        
        ' slow it down for faster systems
        IF delay! > 0 THEN delay (delay!)
        
        PSET (xp!,yp!),pcolor
        IF pcolor = 15 THEN pcolor =0
        IF TIMER-start! >= z! * s! THEN                  ' play note by time interval <s!>
	        l! = ((x!-xo!)^2+(y!-yo!)^2)^(1/2)           ' Wolfgang's secret formula line 1
	        t! = INT(l!/400)                             ' line 2
	        note_new=36+t!                               ' line 3
	        IF note_old <> note_new AND note_new < 108 THEN
	            LOCATE 1,1
	            PRINT "Note:";note_new
	            CALL playnote (port%, note_old, note_new)
	            note_old=note_new	            
	        END IF
	        z!=z!+1
        END IF
        x_old! = x!
        y_old! = y!
    LOOP UNTIL INKEY$=CHR$(27) OR MOUSE(2) = 1
    PRINT "Number of iterations: ";STR$(i!)
END SUB


SUB playnote (port%, note_old, note_new)
   STATIC x%
   x% = bconout%(port%,128): x% = bconout%(port%,note_old): x% = bconout%(port%,0)   'note_old off
   x% = bconout%(port%,144): x% = bconout%(port%,note_new): x% = bconout%(port%,64)  'note_new on
END SUB


SUB gaugespeed
    SHARED delay!
    STATIC strt!, i!
    PRINT "Checking your system...";
    strt! = TIMER
    DO
        INCR i!
    LOOP UNTIL TIMER - strt! >= 1
    IF i! < 3000 THEN
        ' if it takes less than 3000 loops for a second we're on a basic ST so no delay 
        delay! = 0
    ELSE
        ' otherwise we need a delay based on the speed of the machine we're on
        delay! = (i!/3000)/3000
    END IF
END SUB


SUB delay(delay!)
    STATIC strt!
    strt!=TIMER
    DO
    LOOP UNTIL TIMER - strt! >= delay!    
END SUB


'# EOF #
