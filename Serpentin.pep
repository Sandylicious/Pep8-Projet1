;******* Pep/8 Serpentin, 2021/05/07
; 
; Ce programme represente un jeu de serpent. L'objectif est de pouvoir retracer le parcours
; d'un ou de plusieurs morceaux de sepent a partir de la case A5 jusqu'a la case R5. Pour ce 
; faire, le joueur doit saisir des caracteres valides afin de tracer le parcours de chaque 
; morceau de serpent ([A] a [R] pour les colonnes, [1] a [9] pour les rangees, [-] pour 
; continuer tout droit, [g] pour tourner a gauche et [d] pour tourner a droit). Et des qu'il
; y a une connection entre A5 et R5, le programme affiche le score et s'arrete.
; 
; Authors: Fang, Xin Ran
;          Ah-Lan, Steven Chia
;
;********************* PARTIE 1 SUR 3 : INITIALISATION DE L'ESPACE DU JEU ET AFFICHAGE DU JEU
main:    LDA     0,i
         LDX     0,i         
         LDA     1,i
         STA     rangNbr,d   ; Initialiser le nombre qui sera affiche dans la colonne gauche a 1                
;
;******* Preparer l'espace du jeu
prep_esp:LDA     posit1R1,d  ; posit1R1 est initialise a 0 
         CPA     161,i       
         BRGT    aff_msgW 
         LDX     posit1R1,d       
         LDBYTEA '\x20',i    ; \x20 = space 
         STBYTEA r1,x      
         ADDX    1,i  
         STX     posit1R1,d  ; posit1R1 += 1
         BR      prep_esp 
;
;******* Afficher le jeu
aff_msgW:STRO    msgWelc,d
aff_alph:CHARO   '\n',i
         STRO    alphabet,d
aff_nbr: DECO    rangNbr,d   ; rangNbr est initialise a 1
         LDA     rangNbr,d   
         ADDA    1,i
         STA     rangNbr,d   ; rangNbr += 1
         BR      aff_jeu 
aff_jeu: LDA     carCompt,d  ; carCompt est initialise a 0 
         CPA     18,i        ; Si carCompt = 18 
         BREQ    aff_ligV       
         LDX     posit2R1,d  ; posit2R1 est initialise a 0 
         CHARO   r1,x          
         ADDX    1,i         
         STX     posit2R1,d  ; posit2R1 += 1 
         LDA     carCompt,d 
         ADDA    1,i
         STA     carCompt,d  ; carCompt += 1
         BR      aff_jeu      
aff_tirt:STRO    tirets,d    ; Etape finale de l'affichage du tableau               
         BR      play_ing   
aff_ligV:CHARO   ligVerti,d 
         CHARO   '\n',i      
         LDA     0,i 
         STA     carCompt,d  ; Reinitialiser carCompt a 0 
         LDA     rangNbr,d
         CPA     9,i 
         BRGT    aff_tirt
         BR      aff_nbr                  
;
;******* Reinitialiser les varibles et demander au joueur d'entrer son choix
play_ing:LDA     isCorrct,d
         CPA     1,i
         BRNE    aff_mort    ; 0 = false, 1 = true  
         CALL    CHECK_AR    ; Verifier si A5 et R5 peuvent etre lies ensemble
         LDA     0,i 
         STA     carCompt,d  ; carCompt = 0
         STA     posit1R1,d  ; posit1R1 = 0
         STA     posit2R1,d  ; posit2R1 = 0
         LDA     2,i 
         STA     bufCompt,d  ; bufCompt = 2
         CALL    REINIT      ; Reinitialiser le tampon   
         LDX     0,i
         LDA     0,i 
         STA     inpCompt,d  ; inpCompt = 0          
         LDA     1,i
         STA     rangNbr,d   ; rangNbr = 1         
         LDA     buffer,i
         LDX     size,i 
         STRO    msgSoll,d   ; Afficher le message de sollcitation
         CALL    STRI        ; Demander au joueur de jouer                     
         CALL    VALID_AL    ; Valider la lettre entree (1er charactere)
         LDA     inpCompt,d
         SUBA    1,i
         STA     inpCompt,d  ; inpCompt -= 1 (pour savoir combien de characteres qu'il reste a valider)
         CALL    VALID_NB    ; Valider le chiffre entre (2e charactere)        
         LDA     inpCompt,d
         SUBA    1,i
         STA     inpCompt,d  ; inpCompt -= 1      
         LDA     inpCompt,d
         LDX     bufCompt,d       
         CALL    VALID_BF    ; Valider tous les characteres suivis des deux premiers        
         CALL    INIT_POS    ; Ajouter la position initiale dans le tableau
val_loop:CALL    VALID_CH    ; Verifier si les morceaux du serpent restent a l'interieur de l'espace du jeu      
         BR      val_loop
;
;******* Afficher le message qui declare la mort du serpent et arrete le programme         
aff_mort:STRO    msgMort,d
         STOP
;
;******* Afficher le mssage d'erreur et recommence le jeu
aff_err: CALL    REINIT 
         STRO    msgErr,d         
         LDA     aff_alph,i 
         STA     0,s
         RET0
;
;******* Modifier la valeur de isCorrct a 0, pour que le programme affiche le tableau sans recommencer le jeu
fin_over:LDA     0,i
         STA     isCorrct,d
         BR      aff_alph
;
;******* Afficher le score          
fin_win: STRO    msgFin,d
         DECO    score,d
         STOP
;
;******* Initialisation des variables 
rangNbr: .BLOCK  2           ; Nombre qui sera affiche dans la colonne droite (1 a 9)
carCompt:.WORD   0           ; Nombre qui verifie si les 18 characteres d'une rangee sont tous affiches (lorsque colCompt = 18)
posit1R1:.WORD   0           ; 1re nombre qui sera utilise pour localiser le charactere dans le tableau r1     
posit2R1:.WORD   0           ; 2e nombre qui sera utilise pour localiser le charactere dans le tableau r1 
                             ; (avant pouvoir reinitialiser posit1R1 a 0)
inpCompt:.WORD   0           ; Compteur du nombre total de characteres saisis par l'utilisateur 
                             ; (sera decremente d'un apres chaque validation du charactere, lorsque inpCompt < 1 -> afficher le resultat)
initColn:.WORD   0           ; La colonne selectionnee par l'utilisateur (A = 0, B = 1, C = 2, D = 3 ...)
initRang:.WORD   0           ; La ranege selectionnee par l'utilisateur (peut etre parmi 1 et 9)
posSelct:.WORD   0           ; Nombre qui sert a obtenir le charactere dans le tableau r1 
score:   .WORD   0           ; Score accumule
isCorrct:.WORD   1           ; 0 = false, 1 = true  
bufCompt:.WORD   2           ; Compteur du nombre total de characteres saisis par l'utilisateur 
                             ; (pour obtenir la position du nouveau charactere dans buffer)
buffer:  .BLOCK  162         ; Tampon pour l'entree du joueur (18 colonnes x 9 rangees x 1 BLOCK)
size:    .WORD   162         ; Nombre d'octets libres dans le tampon
;
;******* Pointeurs vers le debut de chaque rangee
vecteur: .ADDRSS r1
         .ADDRSS r2
         .ADDRSS r3
         .ADDRSS r4
         .ADDRSS r5
         .ADDRSS r6
         .ADDRSS r7
         .ADDRSS r8
         .ADDRSS r9   
;
;******* Espace du jeu: 18 colonnes par rangee
r1:      .BLOCK  18
r2:      .BLOCK  18
r3:      .BLOCK  18
r4:      .BLOCK  18
r5:      .BLOCK  18
r6:      .BLOCK  18
r7:      .BLOCK  18
r8:      .BLOCK  18
r9:      .BLOCK  18
;
;******* Chaines de caracteres
msgWelc: .ASCII  "Bienvenue au serpentin!\n\x00"
alphabet:.ASCII  " ABCDEFGHIJKLMNOPQR\n\x00"
espace:  .BYTE   '\x20'                         ; une espace
tirets:  .ASCII  " ------------------ \n\x00"   ; 18 tirets 
ligVerti:.ASCII  "\x7C\n\x00"                   ; une ligne verticale \x7C = |
msgSoll: .ASCII  "\nEntrer un serpent qui part vers l'est:\n"
         .ASCII  "{position initiale et parcours}\n"
         .ASCII  "avec [-] (tout droit), [g] (virage à gauche),\n"
         .ASCII  "[d] (virage à droite)\n\x00"
msgErr:  .ASCII  "\nErreur d'entrée. Veuillez recommencer.\n\x00"
msgMort: .ASCII  "\nLe serpent est mort! Fin du jeu.\n\x00"
msgFin:  .ASCII  "Fin! Score: \x00"                
;
;******* 
;
; STRI: Sous-programme qui lit dans un tampon.
;
; IN:    A = Adresse du tampon
;        X = Taille du tampon en octet
; OUT:   A = Adresse du tampon (inchange)
;        X = Nombre de caractere lu
; ERR:   Avorte si le tampon n'est pas assez grand pour stocker les characteres saisis par l'utilisateur
;    
;********************* PARTIE 2 SUR 3 : LECTURE DES CHARACTERES SAISIS PAR LE JOUEUR     
striPtr: .BLOCK  2           ; Adresse de debut du tampon
striPtr2:.BLOCK  2           ; Adresse de fin de tampon      
striMsgE:.ASCII  "Erreur: Débordement de capacité.\n\x00"
;
STRI:    STA     striPtr,d   ; striPtr = adresse du tampon (debut)
         ADDX    striPtr,d
         STX     striPtr2,d  ; striPtr2 = adresse du tampon (fin)         
         LDX     striPtr,d   ; X = striPtr = adresse du tampon (debut) 
str_loop:CPX     striPtr2,d  ; while (striPtr2 < X) {
         BRGE    stri_err    ;    if (striPtr2 >= X) new Error(); 
         CHARI   0,x         ;        *X = getChar();
         LDA     0,i
         LDBYTEA 0,x       
         CPA     '\n',i
         BREQ    str_fin 
         CPA     '\x00',i
         BREQ    str_fin 
         ADDX    1,i
         LDA     inpCompt,d  ; inpCompt est initialise a 0 
         ADDA    1,i
         STA     inpCompt,d
         BR      str_loop   
str_fin: LDBYTEA 0,i
         STBYTEA 0,x
         SUBX    striPtr,d
         LDBYTEA striPtr,d
         RET0
stri_err:STRO    striMsgE,d 
         LDA     aff_alph,i 
         STA     0,s
         RET0    
;
;*******
;
; VALID_AL: Sous-programme qui s'assure que le premier charactere saisi par le joueur soit 
; une lettre majuscule parmi A et R. 
;
;********************* PARTIE 3 SUR 3 : VALIDATION     
VALID_AL:LDX     0,i      
         LDBYTEA buffer,x
         CPA     'A',i           
         BRLT    aff_err          ; Si registre A > A        
         CPA     'R',i
         BRGT    aff_err          ; Si registre A < R
         SUBA    'A',i
         STA     initColn,d       ; initColn = registre A - A
         RET0 
;            
;******* 
;
; VALID_NB: Sous-programme qui s'assure que le deuxieme charactere saisi par le joueur soit 
; un chiffre entre 1 et 9. 
;
;******* 
VALID_NB:LDX     1,i
         LDBYTEA buffer,x
         CPA     '1',i
         BRLT    aff_err          ; Si registre A > 1 
         CPA     '9',i
         BRGT    aff_err          ; Si registre A < 9
         SUBA    '1',i
         STA     initRang,d       ; initRang = registre A - 1
         RET0
;
;******* 
;
; VALID_BF: Sous-programme qui verifie si tous les characteres du tampon sont valides, excepte les deux premiers 
; qui sont deja valides (lettre et numero).
;
; IN:    A = inpCount 
;        X = buffIter 
;
;*******   
inpCount:.BLOCK  2                ; Compteur du nombre total de characteres saisis par l'utilisateur 
                                  ; (pour savoir quand afficher le resultat)
buffIter:.BLOCK  2                ; Compteur du nombre total de characteres saisis par l'utilisateur 
;                                 ; (pour obtenir la position du nouveau charactere dans buffer)
VALID_BF:STA     inpCount,d
         STX     buffIter,d         
bf_loop: LDA     inpCount,d
         CPA     0,i
         BREQ    bf_fin           ; Si inpCount != 0       
         SUBA    1,i
         STA     inpCount,d       ; inpCount -= 1 (pour savoir combien de chars qui restent a valider) 
         LDX     buffIter,d      
         LDBYTEA buffer,x
         ADDX    1,i
         STX     buffIter,d
         CPA     '\x2D',i         ; \x2D = - 
         BREQ    bf_loop
         CPA     '\x64',i         ; \x64 = d
         BREQ    bf_loop
         CPA     '\x67',i         ; \x67 = g  
         BREQ    bf_loop
         BR      aff_err
bf_fin:  RET0
;
;******* 
;
; INIT_POS: Sous-programme qui installe la position initiale, c'est-a-dire la queue du serpent, dans le tableau. 
;   
;*******  
INIT_POS:LDA     0,i
         LDX     0,i
         LDX     initRang,d
         ASLX
         LDA     vecteur,x        ; Trouver la rangee selectionnee
         ADDA    initColn,d
         SUBA    r1,i
         STA     posSelct,d    
         CALL    VERF_POS
         LDX     posSelct,d        
         LDBYTEA '\x3E',i         ; \x3E = >     
         STBYTEA r1,x
         RET0                  
;     
;******* 
;
; VERF_POS: Sous-programme qui verifie si la position selectionnee a deja ete utilisee. 
;
;******* 
VERF_POS:LDA     0,i
         LDX     0,i         
         LDX     posSelct,d       
         LDBYTEA r1,x         
         CPA     '\x3E',i         ; \x3E = >  
         BREQ    fin_over          
         CPA     '\x76',i         ; \x76 = v
         BREQ    fin_over         
         CPA     '\x5E',i         ; \x5E = ^
         BREQ    fin_over         
         CPA     '\x3C',i         ; \x3C = <
         BREQ    fin_over         
         CPA     '\x20',i         ; \x20 = space          
         BRNE    fin_over          
         RET0      
;       
;******* 
;
; VALID_CH: Sous-programme qui verifie si un morceau de serpent depasse l'espace du jeu.
;
;******* 
loopComp:.WORD   0                ; Compteur du nombre de repetition du loop
;
VALID_CH:LDA     0,i
         STA     loopComp,d       ; Reinitialiser loopComp a 0
         LDX     0,i
         LDA     inpCompt,d       
         CPA     1,i
         BRLT    val_fin          ; si inpCompt < 1 (il ne reste plus de chars a valider dans buffer)      
         LDX     bufCompt,d 
         LDA     inpCompt,d        
         SUBA    1,i
         STA     inpCompt,d       ; inpCompt -= 1 (sera utilise pour le prochain char)         
         LDBYTEA buffer,x         ; Obtenir le charactere a valider du tampon
         CPA     '\n',i
         BREQ    val_fin        
         CPA     '\x00',i         
         BREQ    val_fin  
         BR      verf_cor                     
val_fin: LDA     aff_alph,i 
         STA     0,s
         RET0
;        
; Verifier si la derniere position se situe dans un coin (le char actuel est un tiret)
verf_cor:LDX     posSelct,d              
         CPX     0,i
         BRLE    A1          
         CPX     17,i
         BREQ    R1 
         CPX     144,i
         BREQ    A9
         CPX     161,i
         BRGE    R9
;
; Verifier si la derniere position se situe a la colonne A ou R
verf_col:LDA     loopComp,d      
         CPA     9,i
         BRGE    verf_ran    
         SUBX    18,i             ; Verifier si la derniere position se situe a la colonne R   
         CPX     -1,i
         BREQ    boutR 
         CPX     0,i              ; Verifier si la derniere position se situe a la colonne A
         BREQ    boutA
         ADDA    1,i
         STA     loopComp,d
         BR      verf_col  
;
; Verifier si la derniere position se situe a la rangee 1 ou 9
verf_ran:LDX     posSelct,d
         SUBX    17,i
         CPX     0,i
         BRLE    boutUn
         LDX     posSelct,d
         SUBX    143,i
         CPX     0,i
         BRGE    boutNeuf          
;
; Enregistrer la nouvelle direction dans l'espace du jeu
go_set:  LDX     bufCompt,d 
         LDBYTEA buffer,x 
         CPA     '\x2D',i         ; \x2D = - 
         BREQ    set_tir
         CPA     '\x64',i         ; \x64 = d
         BREQ    set_d 
         CPA     '\x67',i         ; \x67 = g  
         BREQ    set_g   
         BR      val_fin     
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu 
; quand la dernier position se situe a A1
A1:      LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^, verifier le dernier char ajoute dans r1
         BREQ    onlyD                     
         CPA     '\x3C',i         ; \x3C = <
         BREQ    onlyG
         CPA     '\x76',i         ; \x76 = v
         BREQ    avoidD
         CPA     '\x3E',i         ; \x3E = >
         BREQ    avoidG
         BR      val_fin  
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu en se basant 
; sur le char precedent qui se situe a R1               
R1:      LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^, verifier le dernier char ajoute dans r1
         BREQ    onlyG         
         CPA     '\x3C',i         ; \x3C = <
         BREQ    avoidD
         CPA     '\x76',i         ; \x76 = v
         BREQ    avoidG
         CPA     '\x3E',i         ; \x3E = >
         BREQ    onlyD
         BR      val_fin
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu en se basant 
; sur le char precedent qui se situe a A9
A9:      LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^, verifier le dernier char ajoute dans r1
         BREQ    avoidG         
         CPA     '\x3C',i         ; \x3C = <
         BREQ    onlyD
         CPA     '\x76',i         ; \x76 = v
         BREQ    onlyG
         CPA     '\x3E',i         ; \x3E = >
         BREQ    avoidD
         BR      val_fin 
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu en se basant 
; sur le char precedent qui se situe a R9
R9:      LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^
         BREQ    avoidD         
         CPA     '\x3C',i         ; \x3C = <
         BREQ    avoidG
         CPA     '\x76',i         ; \x76 = v
         BREQ    onlyD
         CPA     '\x3E',i         ; \x3E = >
         BREQ    onlyG
         BR      val_fin
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu en se basant 
; sur le char precedent qui se situe dans la colonne R  
boutR:   LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^, verifier le dernier char ajoute dans r1
         BREQ    avoidD
         CPA     '\x3E',i         ; \x3E = >
         BREQ    avoidTir
         CPA     '\x76',i         ; \x76 = v
         BREQ    avoidG
         BR      go_set      
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu 
; quand la derniere position se situe a la colonne A  
boutA:   LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^, verifier le dernier char ajoute dans r1
         BREQ    avoidG
         CPA     '\x3C',i         ; \x3C = <
         BREQ    avoidTir
         CPA     '\x76',i         ; \x76 = v
         BREQ    avoidD
         BR      go_set   
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu 
; quand la derniere position se situe a la rangee 1
boutUn:  LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x5E',i         ; \x5E = ^, verifier le dernier char ajoute dans r1
         BREQ    avoidTir
         CPA     '\x3C',i         ; \x3C = <
         BREQ    avoidD
         CPA     '\x3E',i         ; \x3E = >  
         BREQ    avoidG
         BR      go_set        
;
; Verifier si le prochain morceau de serpent va depasser l'espace du jeu 
; quand la derniere position se situe a la rangee 9
boutNeuf:LDX     posSelct,d
         LDBYTEA r1,x 
         CPA     '\x76',i         ; \x76 = v, verifier le dernier char ajoute dans r1
         BREQ    avoidTir
         CPA     '\x3C',i         ; \x3C = <
         BREQ    avoidG
         CPA     '\x3E',i         ; \x3E = >  
         BREQ    avoidD
         BR      go_set    
;
; d est la seule occasion possible
onlyD:   LDX     bufCompt,d 
         LDBYTEA buffer,x 
         CPA     '\x64',i         ; \x64 = d
         BREQ    set_d
         BR      fin_over
;
; d est le seul cas ou l'espace sera depasse
avoidD:  LDX     bufCompt,d 
         LDBYTEA buffer,x 
         CPA     '\x64',i         ; \x64 = d
         BREQ    fin_over
         BR      go_set
;
; g est la seule occasion possible                 
onlyG:   LDX     bufCompt,d 
         LDBYTEA buffer,x 
         CPA     '\x67',i         ; \x67 = g 
         BREQ    set_g
         BR      fin_over
;
; g est le seul cas ou l'espace sera depasse
avoidG:  LDX     bufCompt,d 
         LDBYTEA buffer,x 
         CPA     '\x67',i         ; \x67 = g      
         BREQ    fin_over         
         BR      go_set
;
; L'espace sera depasse lorsque le prochain caractere du tampon est un tiret
avoidTir:LDX     bufCompt,d 
         LDBYTEA buffer,x         ; Obtenir le charactere a valider du tampon        
         CPA     '\x2D',i         ; \x2D = -
         BREQ    fin_over 
         BR      go_set       
;
; Enregistrer le morceau du serpent dans l'espace du jeu quand le prochain charactere est un tiret
set_tir: LDA     0,i
         LDX     0,i
         LDX     posSelct,d
         LDBYTEA r1,x
         CPA     '\x3E',i         ; \x3E = >  
         BREQ    tirPls1          ; Pls1 veut dire posSelct + 1  
         CPA     '\x76',i         ; \x76 = v
         BREQ    tirPls18         ; Pls1 veut dire posSelct + 18
         CPA     '\x5E',i         ; \x5E = ^
         BREQ    tirMin18         ; Min18 veut dire posSelct - 18
         CPA     '\x3C',i         ; \x3C = <
         BREQ    tirMin1          ; Min1 veut dire posSelct - 1        
tirPls1: LDX     posSelct,d       ; Le dernier char dans r1 est \x3E = >, posSelct doit +1
         ADDX    1,i      
         STX     posSelct,d       ; posSelct += 1 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x3E',i         ; \x3E = >     
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                    
tirPls18:LDX     posSelct,d       ; Le dernier char dans r1 est \x76 = v, posSelct doit +18
         ADDX    18,i      
         STX     posSelct,d       ; posSelct += 18 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x76',i         ; \x76 = v    
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                   
tirMin18:LDX     posSelct,d       ; Le dernier char dans r1 est \x5E = ^, posSelct doit -18
         SUBX    18,i      
         STX     posSelct,d       ; posSelct -= 18 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x5E',i         ; \x5E = ^
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                              
tirMin1: LDX     posSelct,d       ; Le dernier char dans r1 est \x3C = <, posSelct doit -1
         SUBX    1,i      
         STX     posSelct,d       ; posSelct -= 1 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x3C',i         ; \x3C = <
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                    
;
; Enregistrer le morceau du serpent dans l'espace du jeu quand le prochain charactere est un d
set_d:   LDA     0,i
         LDX     0,i 
         LDX     posSelct,d       ; Verifier quel est le dernier char dans r1
         LDBYTEA r1,x
         CPA     '\x3E',i         ; \x3E = >, nouveau char dans r1 sera \x76 = v 
         BREQ    dPls18         
         CPA     '\x76',i         ; \x76 = v, nouveau char dans r1 sera \x3C = <
         BREQ    dMin1        
         CPA     '\x5E',i         ; \x5E = ^, nouveau char dans r1 sera \x3E = >
         BREQ    dPls1         
         CPA     '\x3C',i         ; \x3C = <, nouveau char dans r1 sera \x5E = ^
         BREQ    dMin18           
dPls18:  LDX     posSelct,d
         ADDX    18,i             ; le dernier char dans r1 est \x3E = >, posSelct doit +18
         STX     posSelct,d       ; posSelct += 18 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x76',i         ; \x76 = v
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                     
dMin1:   LDX     posSelct,d       ; Le dernier char dans r1 est \x76 = v, posSelct doit -1
         SUBX    1,i      
         STX     posSelct,d       ; posSelct -= 1 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x3C',i         ; \x3C = < 
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                    
dPls1:   LDX     posSelct,d       ; Le dernier char dans r1 est \x5E = ^, posSelct doit +1
         ADDX    1,i      
         STX     posSelct,d       ; posSelct += 1 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x3E',i         ; \x3E = >     
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                 
dMin18:  LDX     posSelct,d       ; Le dernier char dans r1 est \x3C = <, posSelct doit -18
         SUBX    18,i      
         STX     posSelct,d       ; posSelct -= 18 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x5E',i         ; \x5E = ^  
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0              
;
; Enregistrer le morceau du serpent dans l'espace du jeu quand le prochain charactere est un g
set_g:   LDA     0,i
         LDX     0,i
         LDX     posSelct,d
         LDBYTEA r1,x
         CPA     '\x3E',i         ; \x3E = >, nouveau char dans r1 sera \x5E = ^
         BREQ    gMin18            
         CPA     '\x76',i         ; \x76 = v, nouveau char dans r1 sera \x3E = >
         BREQ    gPls1        
         CPA     '\x5E',i         ; \x5E = ^, nouveau char dans r1 sera \x3C = <
         BREQ    gMin1         
         CPA     '\x3C',i         ; \x3C = <, nouveau char dans r1 sera \x76 = v
         BREQ    gPls18             
gMin18:  LDX     posSelct,d       ; Le dernier char dans r1 est \x3E = >, posSelct doit -18
         SUBX    18,i      
         STX     posSelct,d       ; posSelct -= 18 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x5E',i         ; \x5E = ^
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                     
gPls1:   LDX     posSelct,d       ; Le dernier char dans r1 est \x76 = v, posSelct doit +1
         ADDX    1,i      
         STX     posSelct,d       ; posSelct += 1 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x3E',i         ; \x3E = >
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                    
gMin1:   LDX     posSelct,d       ; Le dernier char dans r1 est \x5E = ^, posSelct doit -1
         SUBX    1,i     
         STX     posSelct,d       ; posSelct -= 1 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x3C',i         ; \x3C = <
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                    
gPls18:  LDX     posSelct,d       ; Le dernier char dans r1 est \x3C = <, posSelct doit +18
         ADDX    18,i      
         STX     posSelct,d       ; posSelct += 18 (char actuel)
         CALL    VERF_POS         
         LDX     posSelct,d
         LDBYTEA '\x76',i         ; \x76 = v
         STBYTEA r1,x
         LDA     0,i
         LDX     0,i
         LDX     bufCompt,d       
         ADDX    1,i
         STX     bufCompt,d 
         RET0                  
;
;******* 
;
; CHECK_AR: Sous-programme qui calcule le score et verifie si A5 et R5 peuvent etre lies ensemble 
; en commencant avec R5. 
;   
;*******  
positA5:.WORD    72               ; Position de A5 (4 * 18 = 72)
positR5:.WORD    89               ; Position de R5 (5 * 18 - 1)  
newPosi:.BLOCK   2   
;
CHECK_AR:LDA     0,i
         STA     score,d          ; Reinitialiser score a 0 pour effacer le dernier comptage         
         LDX     positA5,d        ; Position de A5 (4 * 18 = 72)
         LDBYTEA r1,x
         CPA     '\x20',i         ; \x20 = space 
         BREQ    rest_fin         ; Il ne faut pas que A5 soit vide 
         LDX     positR5,d        ; Position de R5 (5 * 18 - 1)
         LDBYTEA r1,x
         CPA     '\x20',i         ; \x20 = space 
         BREQ    rest_fin         ; Il ne faut pas que R5 soit vide 
         STX     newPosi,d
         CPA     '\x3E',i         ; \x3E = >
         BREQ    x3E_set
         CPA     '\x76',i         ; \x76 = v
         BREQ    x76_set         
         CPA     '\x5E',i         ; \x5E = ^    
         BREQ    x5E_set        
         BR      rest_fin         ; Il est impossible que R5 soit autre chose
;
; Verifier si le caractere qui precede \x76 = v peut etre lie avec ce dernier
x76_next:LDA     score,d          
         ADDA    1,i
         STA     score,d          ; score += 1
         LDX     newPosi,d
         CPX     positA5,d
         BREQ    aff_scor           
         SUBX    18,i 
         LDBYTEA r1,x
         CPA     '\x76',i         ; \x76 = v
         BREQ    x76_set
         CPA     '\x3E',i         ; \x3E = >
         BREQ    x3E_set
         CPA     '\x3C',i         ; \x3C = <
         BREQ    x3C_set      
         BR      rest_fin 
;
; Verifier si le caractere qui precede \x5E = ^ peut etre lie avec ce dernier
x5E_next:LDA     score,d          
         ADDA    1,i
         STA     score,d          ; score += 1
         LDX     newPosi,d
         CPX     positA5,d
         BREQ    aff_scor  
         LDX     newPosi,d
         ADDX    18,i 
         LDBYTEA r1,x
         CPA     '\x5E',i         ; \x5E = ^
         BREQ    x5E_set         
         CPA     '\x3E',i         ; \x3E = >
         BREQ    x3E_set 
         CPA     '\x3C',i         ; \x3C = <
         BREQ    x3C_set      
         BR      rest_fin 
;
; Verifier si le caractere qui precede \x3E = > peut etre lie avec ce dernier
x3E_next:LDA     score,d          
         ADDA    1,i
         STA     score,d          ; score += 1
         LDX     newPosi,d
         CPX     positA5,d
         BREQ    aff_scor  
         LDX     newPosi,d
         SUBX    1,i
         LDBYTEA r1,x
         CPA     '\x3E',i         ; \x3E = >
         BREQ    x3E_set
         CPA     '\x5E',i         ; \x5E = ^
         BREQ    x5E_set
         CPA     '\x76',i         ; \x76 = v
         BREQ    x76_set
         BR      rest_fin 
;
; Verifier si le caractere qui precede \x3C = < peut etre lie avec ce dernier
x3C_next:LDA     score,d          
         ADDA    1,i
         STA     score,d          ; score += 1
         LDX     newPosi,d 
         CPX     positA5,d
         BREQ    aff_scor  
         LDX     newPosi,d
         ADDX    1,i
         LDBYTEA r1,x
         CPA     '\x3C',i         ; \x3C = <
         BREQ    x3C_set  
         CPA     '\x5E',i         ; \x5E = ^
         BREQ    x5E_set
         CPA     '\x76',i         ; \x76 = v
         BREQ    x76_set
         BR      rest_fin 
;
; Enregistrer la position actuelle et continuer la validation
x76_set: STX     newPosi,d
         BR      x76_next
x5E_set: STX     newPosi,d
         BR      x5E_next
x3E_set: STX     newPosi,d
         BR      x3E_next
x3C_set: STX     newPosi,d
         BR      x3C_next
;
; A5 et R5 peuvent etre lies ensemble, afficher l'espace du jeu et le score
aff_scor:LDA     fin_win,i 
         STA     0,s
;
; A5 et R5 ne peuvent etre lies ensemble, continuer le programme
rest_fin:RET0       
;     
;******* 
;
; REINIT: Sous-programme qui reinitialise le tampon (buffer).
;   
;******* 
REINIT:  LDX     0,i
         LDA     0,i 
rei_loop:CPX     162,i            
         BRGT    rei_fin                  
         LDBYTEA '\x00',i
         STBYTEA buffer,x
         ADDX    1,i        
         BR      rei_loop 
rei_fin: RET0
;
         .END
