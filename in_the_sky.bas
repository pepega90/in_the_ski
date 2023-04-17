CONST SWIDTH = 480
CONST SHEIGHT = 600

CONST FALSE = 0, TRUE = NOT FALSE

CONST WHITE = _RGB32(255, 250, 250)
CONST BLACK = _RGB32(0, 0, 0)
CONST YELLOW = _RGB32(255, 255, 0)
CONST GREEN = _RGB32(0, 255, 0)
CONST RED = _RGB32(255, 0, 0)

TYPE vec2
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Player
    pos AS vec2
    vel AS vec2
    acc AS vec2
    img AS LONG
END TYPE

TYPE Bendera
    pos AS vec2
    yDir AS INTEGER
    img AS LONG
    active AS INTEGER
END TYPE

TYPE Pohon
    pos AS vec2
    yDir AS INTEGER
    img AS LONG
    active AS INTEGER
END TYPE

'load assets
DIM treeImg&
DIM benderaImg&
DIM playerImg&
DIM right&
DIM left&
DIM fullRight&
DIM fullLeft&

treeImg& = _LOADIMAGE("./assets/tree.png", 32)
benderaImg& = _LOADIMAGE("./assets/flag.png", 32)
playerImg& = _LOADIMAGE("./assets/skier_forward.png", 32)
right& = _LOADIMAGE("./assets/skier_right1.png", 32)
left& = _LOADIMAGE("./assets/skier_left1.png", 32)
fullRight& = _LOADIMAGE("./assets/skier_right2.png", 32)
fullLeft& = _LOADIMAGE("./assets/skier_left2.png", 32)

DIM SHARED imgs(4) AS LONG
imgs(0) = fullLeft&
imgs(1) = left&
imgs(2) = playerImg&
imgs(3) = right&
imgs(4) = fullRight&

DIM SHARED idx AS INTEGER
idx = 2

'player
DIM player AS Player
player.pos.x = SWIDTH / 2 - 20
player.pos.y = 25
player.img = imgs(idx)

'array pohon
DIM listPohon(2) AS Pohon

'init array pohon
FOR c = 0 TO 2
    RANDOMIZE TIMER
    listPohon(c).pos.x = INT(RND * (SWIDTH - _WIDTH(treeImg&)))
    listPohon(c).pos.y = INT(RND * SHEIGHT) + SHEIGHT + 30
    listPohon(c).img = treeImg&
    listPohon(c).yDir = 3
    listPohon(c).active = TRUE
NEXT c

'array bendera
DIM listFlag(2) AS Bendera

'init array bendera
FOR i = 0 TO 2
    RANDOMIZE TIMER
    listFlag(i).pos.x = INT(RND * (SWIDTH - _WIDTH(benderaImg&)))
    listFlag(i).pos.y = INT(RND * SHEsIGHT) + SHEIGHT + 30
    listFlag(i).img = benderaImg&
    listFlag(i).yDir = 3
    listFlag(i).active = TRUE
NEXT i

'window option
_TITLE "In The Ski"
SCREEN _NEWIMAGE(SWIDTH, SHEIGHT, 32)
_SCREENMOVE _MIDDLE

'game variabel
DIM score AS INTEGER
DIM SHARED keypress AS STRING
DIM highlight AS INTEGER
DIM selected AS INTEGER
DIM count AS INTEGER
' 0 menu
' 1 game
' 2 game over
DIM SHARED scene AS INTEGER
scene = 0

highlight = 1
selected = 0

'game loop
DO
    CLS , WHITE
    COLOR BLACK, WHITE
    _LIMIT 60
    SELECT CASE scene
        CASE 0
            LOCATE 10, 25
            PRINT "IN THE SKI"
            _PUTIMAGE (218, 220), playerImg&
            LOCATE 37, 2
            PRINT "created by aji mustofa @pepega90"

            FOR count = 1 TO 3
                LOCATE count + 22, 25
                IF highlight = count THEN
                    COLOR GREEN, WHITE
                ELSE
                    COLOR BLACK, WHITE
                END IF
                IF count = 1 THEN
                    PRINT "New Game"
                ELSEIF count = 2 THEN
                    PRINT "Option"
                ELSE
                    PRINT "Exit"
                END IF
            NEXT count
            DO
                keypress = INKEY$
                _LIMIT 30
            LOOP UNTIL keypress <> ""
            IF keypress = CHR$(13) THEN
                selected = highlight
                IF selected = 1 THEN
                    scene = 1
                ELSEIF selected = 3 THEN
                    SYSTEM
                END IF
            ELSEIF keypress = CHR$(0) + "H" THEN
                IF highlight <> 1 THEN
                    highlight = highlight - 1
                END IF
            ELSEIF keypress = CHR$(0) + "P" THEN
                IF highlight <> 3 THEN
                    highlight = highlight + 1
                END IF
            END IF
        CASE 1
            updatePlayer

            'update bendera
            FOR i = 0 TO UBOUND(listFlag)
                IF listFlag(i).pos.y < -_HEIGHT(benderaImg&) OR listFlag(i).active = FALSE THEN
                    RANDOMIZE TIMER
                    listFlag(i).pos.x = INT(RND * (SWIDTH - _WIDTH(benderaImg&)))
                    listFlag(i).pos.y = INT(RND * SHEIGHT) + SHEIGHT + 30
                    listFlag(i).active = TRUE
                END IF
                IF idx = 1 OR idx = 3 THEN
                    listFlag(i).yDir = 2
                ELSEIF idx = 0 OR idx = 4 THEN
                    listFlag(i).yDir = 1
                ELSE
                    listFlag(i).yDir = 3
                END IF
                listFlag(i).pos.y = listFlag(i).pos.y - listFlag(i).yDir
            NEXT i

            'check collision antara bendera dengan player
            FOR i = 0 TO UBOUND(listFlag)
                collisionToFlag player, listFlag(i)
            NEXT i

            'check collision antara bendera dengan player
            FOR i = 0 TO UBOUND(listPohon)
                collisionToPohon player, listPohon(i)
            NEXT i


            'update pohon
            FOR i = 0 TO UBOUND(listPohon)
                IF listPohon(i).pos.y < -_HEIGHT(treeImg&) OR listPohon(i).active = FALSE THEN
                    RANDOMIZE TIMER
                    listPohon(i).pos.x = INT(RND * (SWIDTH - _WIDTH(treeImg&)))
                    listPohon(i).pos.y = INT(RND * SHEIGHT) + SHEIGHT + 30
                    listPohon(i).active = TRUE
                END IF
                IF idx = 1 OR idx = 3 THEN
                    listPohon(i).yDir = 2
                ELSEIF idx = 0 OR idx = 4 THEN
                    listPohon(i).yDir = 1
                ELSE
                    listPohon(i).yDir = 3
                END IF
                listPohon(i).pos.y = listPohon(i).pos.y - listPohon(i).yDir
            NEXT i

            'draw score
            LOCATE 2, 2
            PRINT "Score: "; score

            'draw player
            _PUTIMAGE (player.pos.x, player.pos.y), player.img

            'draw bendera
            FOR i = 0 TO UBOUND(listFlag)
                _PUTIMAGE (listFlag(i).pos.x, listFlag(i).pos.y), listFlag(i).img
            NEXT i

            'draw pohon
            FOR i = 0 TO UBOUND(listPohon)
                _PUTIMAGE (listPohon(i).pos.x, listPohon(i).pos.y), listPohon(i).img
            NEXT i
        CASE 2
            COLOR RED, WHITE
            LOCATE 10, 27
            PRINT "GAME OVER"
            COLOR BLACK, WHITE
            LOCATE 15, 25
            PRINT "Score Kamu :"; score
            LOCATE 20, 21
            PRINT "Tekan "; "R"; " untuk restart"
            IF _KEYDOWN(114) THEN
                FOR i = 0 TO UBOUND(listPohon)
                    listPohon(i).active = FALSE
                NEXT i
                FOR i = 0 TO UBOUND(listFlag)
                    listFlag(i).active = FALSE
                NEXT i
                score = 0
                player.pos.x = SWIDTH / 2 - 20
                player.pos.y = 25
                idx = 2
                scene = 1
            END IF
    END SELECT
    _DISPLAY
LOOP UNTIL _KEYDOWN(27)
SYSTEM

'release assets
_FREEIMAGE playerImg&
_FREEIMAGE treeImg&
_FREEIMAGE benderaImg&
_FREEIMAGE right&
_FREEIMAGE left&
_FREEIMAGE fullRight&
_FREEIMAGE fullLeft&

SUB movePlayer ()
    SHARED player AS Player
    keypress = INKEY$

    IF keypress = CHR$(0) + CHR$(77) AND player.pos.x < SWIDTH - _WIDTH(player.img) THEN
        player.vel.x = player.vel.x + 1
        IF idx < 4 THEN
            idx = idx + 1
        END IF
    END IF

    IF keypress = CHR$(0) + CHR$(75) AND player.pos.x > _WIDTH(player.img) THEN
        player.vel.x = player.vel.x - 1
        IF idx > 0 THEN
            idx = idx - 1
        END IF
    END IF

END SUB

SUB updatePlayer ()
    SHARED player AS Player
    movePlayer
    player.acc.x = -player.vel.x * 0.05
    player.vel.x = player.vel.x + player.acc.x
    player.pos.x = player.pos.x + player.vel.x
    player.img = imgs(idx)
END SUB

SUB collisionToFlag (p AS Player, b AS Bendera)
    SHARED score AS INTEGER

    pw = _WIDTH(p.img)
    ph = _HEIGHT(p.img)

    bw = _WIDTH(b.img)
    bh = _HEIGHT(b.img)

    IF p.pos.x + ph >= b.pos.x AND _
       p.pos.x <= b.pos.x + bw AND _
       p.pos.y + ph >= b.pos.y AND _
       p.pos.y <= b.pos.y + bh THEN
        score = score + 1
        b.active = FALSE
    END IF
END SUB

SUB collisionToPohon (p AS Player, b AS Pohon)
    SHARED scene AS INTEGER

    pw = _WIDTH(p.img)
    ph = _HEIGHT(p.img)

    bw = _WIDTH(b.img)
    bh = _HEIGHT(b.img)

    IF p.pos.x + ph >= b.pos.x AND _
       p.pos.x <= b.pos.x + bw AND _
       p.pos.y + ph >= b.pos.y AND _
       p.pos.y <= b.pos.y + bh THEN
        scene = 2
    END IF
END SUB
