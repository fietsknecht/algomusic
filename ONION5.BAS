'sof

'** Algo Green Onions
'** last edit 15-02-2021 - Rob 


LIBRARY "bios"
DEFINT a-z
DIM SHARED impro(16)

'***** SETTINGS *****
'port=1     ' serial
port=3     ' MIDI
mykey=62   ' it's in D
bpm=120    ' beats per minute
'**

tempo!=60/bpm    'time between beats
round=0

'***** MAIN PRG *****

PRINT "Press any key to start Atari Onions..."
WHILE LEN(INKEY$)=0:WEND

LOCATE 2,1
PRINT "Booker TT & the ST's play a twelve bar blues in five rounds"

DO

INCR round

LOCATE 4,1
PRINT "This is round";STR$(round)
SELECT CASE round 
=1:LOCATE 5,1
   PRINT "Start off with the theme..."
=2:LOCATE 6,1
   PRINT "Now the organ starts improvising..."
=3:LOCATE 7,1
   PRINT "one octave up..."
=4:LOCATE 8,1
   PRINT "and down again..."
=5:LOCATE 9,1
   PRINT "and back to the theme..."
END SELECT

'Patch Change 
x%=bconout%(port,193): x%=bconout%(port,33) 'bass 
x%=bconout%(port,194): x%=bconout%(port,18) 'organ                     
x%=bconout%(port,195): x%=bconout%(port,28) 'guitar
x%=bconout%(port,201): x%=bconout%(port,25) 'drums 

' I
bnote=mykey-24
gnote=mykey-12
FOR i = 1 TO 4
  CALL playbar(bnote,gnote)
NEXT i

' IV
bnote=mykey-19
gnote=mykey-7
FOR i = 1 TO 2
  CALL playbar(bnote,gnote)
NEXT i

' I
bnote=mykey-24
gnote=mykey-12
FOR i = 1 TO 2
  CALL playbar(bnote,gnote)
NEXT i

' V
bnote=mykey-17
gnote=mykey-5
CALL playbar(bnote,gnote)

' IV
bnote=mykey-19
gnote=mykey-7
CALL playbar(bnote,gnote)

' I
bnote=mykey-24
gnote=mykey-12
FOR i = 1 TO 2
  CALL playbar(bnote,gnote)
NEXT i

LOOP UNTIL round=5

'all midi channels off
allnotesoff

PRINT "That's all folks!"

END

'***** SUB/FUNC *****

SUB playbar(bnote,gnote)
    SHARED port,mykey,newnote,oldnote,tempo!,old,new,gitnote,gitnoteold,round
    LOCAL start!,t!,j!,ion,ioff,q,s0,s1

    t!=0: j!=0: ion=1: ioff=0: q=0: s0=1: s1=0
    CALL improvise

    start!=TIMER
    DO 
        SWAP ion,ioff 
        IF TIMER-start! >= t!+(tempo!/4) THEN
            t!=t!+(tempo!/4)
            j!=j!+0.25
            INCR q

            'organ as rythm inst    
            IF (j!=1 OR j!=1.5) AND (round=1 OR round=5) THEN
              new=mykey 
              organ
              old=new
            END IF

            ' syncopation
            IF q=11 THEN gitnote=gnote: CALL guitar  
            IF q=11 THEN CALL hihat
            IF q=12 THEN CALL hihatopen 

            ' organ improvisation
            IF j!>=1 THEN
              SWAP s0,s1 
              IF s1=1 AND ion=1 AND impro(q)<>0 AND (round>1 AND round<5) THEN 
                new=impro(q)
				IF round=3 THEN new=new+12
                organ
                old=new
              END IF
            END IF

          ' on the beat
          SELECT CASE j!
           =1:newnote = bnote
              gitnote=gnote
              guitar
              bass
              hihat
              bassdrum
           =2:x%=bconout%(port,146)
              x%=bconout%(port,new)
              x%=bconout%(port,0)
              newnote = bnote-2
              gitnote=gnote
              guitar
              bass
              hihat
              snaredrum
           =3:newnote = bnote-5
              gitnote=gnote+3
              guitar
              bass
              ' no hihat here, see syncopation
              bassdrum
           =4:newnote = bnote-2
              gitnote=gnote+5
              guitar
              bass
              hihat
              snaredrum
          END SELECT
          
          oldnote=newnote
          gitnoteold=gitnote

        END IF

        IF INKEY$=CHR$(27) THEN EXIT LOOP
    LOOP UNTIL j!=4
END SUB

SUB improvise
    SHARED mykey
    LOCAL i,x
RANDOMIZE TIMER
    FOR i = 1 TO 16
        x=INT(RND*6)+1
      SELECT CASE x 
       =1: impro(i)=mykey
       =2: impro(i)=mykey+3
       =3: impro(i)=mykey+5
       =4: impro(i)=mykey+7
       =5: impro(i)=mykey+10
       =6: impro(i)=0
      END SELECT
    NEXT i
END SUB


SUB allnotesoff
    SHARED port
    LOCAL x%,xx%
    FOR xx%=0 TO 15
     x%=bconout%(port,176+xx%)
     x%=bconout%(port,123)
     x%=bconout%(port,0) 
    NEXT xx%
END SUB


SUB bassdrum
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,35): x%=bconout%(port,0)
    x%=bconout%(port,153): x%=bconout%(port,35): x%=bconout%(port,80)
END SUB

SUB snaredrum
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,37): x%=bconout%(port,0) 
    x%=bconout%(port,153): x%=bconout%(port,37): x%=bconout%(port,80)
END SUB

SUB hihat
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,42): x%=bconout%(port,0) 
    x%=bconout%(port,153): x%=bconout%(port,42): x%=bconout%(port,80)
END SUB

SUB hihatopen
    SHARED port
    LOCAL x%
    x%=bconout%(port,153): x%=bconout%(port,46): x%=bconout%(port,0) 
    x%=bconout%(port,153): x%=bconout%(port,46): x%=bconout%(port,80)
END SUB

SUB bass
    SHARED port,oldnote,newnote
    LOCAL x%
    x%=bconout%(port,145): x%=bconout%(port,oldnote): x%=bconout%(port,0)
    x%=bconout%(port,145): x%=bconout%(port,newnote): x%=bconout%(port,80)
END SUB

SUB organ
    SHARED port,old,new
    LOCAL x%
    x%=bconout%(port,146): x%=bconout%(port,old): x%=bconout%(port,0) 
    x%=bconout%(port,146): x%=bconout%(port,new): x%=bconout%(port,80)
END SUB

SUB guitar
    SHARED port,gitnote,gitnoteold
    LOCAL x%
    x%=bconout%(port,147): x%=bconout%(port,gitnoteold): x%=bconout%(port,0) 
    x%=bconout%(port,147): x%=bconout%(port,gitnote): x%=bconout%(port,40)
END SUB


'eof