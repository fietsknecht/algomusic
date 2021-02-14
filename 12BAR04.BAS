'12 bar blues
' bass - bass drum - snare drum - hihat
' organ

LIBRARY "bios"
DEFINT a-z
DIM SHARED impro(8)

PRINT "Press any key to start Atari Onions..."
DO LOOP UNTIL INKEY$<>""

'port=1   ' serial
port=3   ' MIDI
mykey=62 'it's in D
tempo!=0.6
round=0

LOCATE 2,1
PRINT "Booker TT & the ST's play a twelve bar blues in five rounds"

' 12 bar pattern
DO
round=round+1

LOCATE 4,1
PRINT "This is round";STR$(round)
LOCATE 5,1
PRINT "Start off with the theme..."
IF round = 2 THEN
  LOCATE 6,1
  PRINT "Now the organ starts improvising..."
END IF
IF round = 3 THEN
  LOCATE 7,1
  PRINT "it plays every other bar so it can breathe..."
END IF
IF round = 4 THEN
  LOCATE 8,1
  PRINT "eight notes to the bar, randomly picked from five, or a silence..."
END IF
IF round = 5 THEN
  LOCATE 9,1
  PRINT "And back to the theme..."
END IF

' I
bassnote=mykey-24
FOR i = 1 TO 4
  CALL play(bassnote)
NEXT i
' IV
bassnote=mykey-19
FOR i = 1 TO 2
  CALL play(bassnote)
NEXT i
' I
bassnote=mykey-24
FOR i = 1 TO 2
  CALL play(bassnote)
NEXT i
' V
bassnote=mykey-17
CALL play(bassnote)
' IV
bassnote=mykey-19
CALL play(bassnote)
' I
bassnote=mykey-24
FOR i = 1 TO 2
  CALL play(bassnote)
NEXT i
LOOP UNTIL round=5

x%=bconout%(port,145): x%=bconout%(port,oldnote): x%=bconout%(port,0)      'bass off
'x%=bconout%(port,147): x%=bconout%(port,gitnoteold): x%=bconout%(port,0)   'git off
x%=bconout%(port,146): x%=bconout%(port,oldnote): x%=bconout%(port,0)      'organ off

PRINT "That's all folks!"
END


SUB play(note)
    SHARED port,newnote,oldnote,tempo!,old,new,mykey,gitnote,gitnoteold,round
    LOCAL start!,waittime!,t!,j!,ion,ioff,q
    t!=0: j!=0: ion=1: ioff=0: q=0
    CALL improvise
    start!=TIMER
    DO 
        SWAP ion,ioff 
        IF TIMER-start! >= t!+(tempo!/2) THEN
            t!=t!+(tempo!/2)
            j!=j!+0.5
            q=q+1
            IF (j!>=1 AND j!<2) AND (round=1 OR round=5) THEN
              new=mykey 
              organ
              old=new
            END IF
            IF j!>=1 THEN 
              hihat
              IF ion=1 AND impro(q)<>0 AND (round>1 AND round<5) THEN 
                new=impro(q)
                organ
                old=new
              END IF
            END IF
            IF j! = 1 THEN 
              newnote = note
              gitnote=mykey
              'guitar
              bass
              bassdrum
            END IF
            IF j! = 2 THEN 
              x%=bconout%(port,146): x%=bconout%(port,new): x%=bconout%(port,0)
              newnote = note-2
              gitnote=mykey
              'guitar
              bass
              snaredrum
            END IF
            IF j! = 3 THEN 
              newnote = note-5
              gitnote=mykey+3
              'guitar
              bass
              bassdrum
            END IF
            IF j! = 4 THEN
              newnote = note-2
              gitnote=mykey+5
              'guitar
              bass
              snaredrum
            END IF
            oldnote=newnote
            gitnote=gitnoteold
        END IF
        IF INKEY$=CHR$(27) THEN EXIT LOOP
    LOOP UNTIL j!=4
END SUB


SUB bass
    SHARED port,oldnote,newnote
    LOCAL x%
    x%=bconout%(port,193): x%=bconout%(port,33)                              ' fingered bass 
    x%=bconout%(port,145): x%=bconout%(port,oldnote): x%=bconout%(port,0)
    x%=bconout%(port,145): x%=bconout%(port,newnote): x%=bconout%(port,80)
END SUB

SUB bassdrum
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,35): x%=bconout%(port,0)
    x%=bconout%(port,201): x%=bconout%(port,35) 
    x%=bconout%(port,153): x%=bconout%(port,35): x%=bconout%(port,80)
END SUB

SUB snaredrum
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,37): x%=bconout%(port,0) 
    x%=bconout%(port,201): x%=bconout%(port,37) 
    x%=bconout%(port,153): x%=bconout%(port,37): x%=bconout%(port,80)
END SUB

SUB hihat
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,42): x%=bconout%(port,0) 
    x%=bconout%(port,201): x%=bconout%(port,42) 
    x%=bconout%(port,153): x%=bconout%(port,42): x%=bconout%(port,80)
END SUB

SUB organ
    SHARED port,old,new
    LOCAL x%
    x%=bconout%(port,146): x%=bconout%(port,old): x%=bconout%(port,0) 
    x%=bconout%(port,194): x%=bconout%(port,18) 
    x%=bconout%(port,146): x%=bconout%(port,new): x%=bconout%(port,80)
END SUB

SUB guitar
    SHARED port,gitnote,gitnoteold
    LOCAL x%
    x%=bconout%(port,147): x%=bconout%(port,gitnoteold): x%=bconout%(port,0) 
    x%=bconout%(port,195): x%=bconout%(port,29) 
    x%=bconout%(port,147): x%=bconout%(port,gitnote): x%=bconout%(port,80)
END SUB

SUB improvise
    SHARED mykey
    LOCAL i,x
    RANDOMIZE TIMER
    FOR i = 1 TO 8
        x=INT(RND*6)+1
        IF x=1 THEN impro(i)=mykey
        IF x=2 THEN impro(i)=mykey+3
        IF x=3 THEN impro(i)=mykey+5
        IF x=4 THEN impro(i)=mykey+7
        IF x=5 THEN impro(i)=mykey+10
        IF x=6 THEN impro(i)=0
    NEXT i
END SUB
