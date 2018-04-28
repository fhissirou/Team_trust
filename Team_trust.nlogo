extensions [palette array]

breed [Personnes personne]
breed [Decisions decision]
breed [ Tables table]

Personnes-own [

  pGenre pCatAge pPoidsAge pExperience pDistance_sujet  ;; agent

  pCortisol_Oxytocin pDegre_certitude ;; Confiance biologique_psychologique

  pExpertise_sujet  pDegre_introversion_extraversion ;; Confiance en soi

  pAttributs_physiques_percus pExpertise_sujet_percu ;; Confiance interpersonnelle

  pConfiance pErreur pForce deg_certitude

  pMonChoix pDiff_choix_interet pChoix_individuel pChoix_collectif  deg_introversion_extraversion expertise_prop_soi pMatch pMonVote

]

;; creation des variables globales
globals [
  Senior
  Moyen
  Jeune
  Homme
  Femme
  CoefHomme
  CoefFemme

  Confiance_bio_psycho

  ValeurMu
  ValeurVariation
  Criteres Interet_individuel Interet_collectif
  NBPointsConfiant
  Deg_Confiant Deg_Mefiance
  Liens_cooperation
  choixFinal
  Option
  Confirm
NB-Votants_A
  NB-Votants_B

  Genre_influ_A
  Age_influ_A
  Genre_influ_B
  Age_influ_B
]



;; initalisation global
to Setup
  clear-all
  set-default-shape Personnes "person-trust"
  ask patches [set pcolor black]
  setup-table
  setup-globals
  setup-personnes NB-OF-AGENTS

  cal_Confiance_bio_psycho
  setup-score-distribution

  reset-ticks
end

;; creation d'une table rounde
to setup-table
  set-default-shape Tables "bug"
  let table-x 0
  let table-y 0
  let table-size 25

  ask patch table-x table-y [
    sprout 1 [
      set color brown
      set shape "circle"
      set size table-size
      stamp
      die
    ]
  ]
end

;; initalisation de l'agent personne
to setup-personnes [ number ]
  create-ordered-personnes number [
    rt 180 / number
    jump -14
    rt 180
    set size 2

    set pGenre cal-genre
    set pCatAge cal-cat-age
    set pPoidsAge (cal_poids_age pCatAge)
    set pAttributs_physiques_percus random-float 10
    set pExpertise_sujet_percu random-float 10
    set pDistance_sujet (cal_distance_sujet pPoidsAge)

    ;; initialisation de la confiance biologique/psychologique
    set pCortisol_Oxytocin random-float 10
    set pDegre_certitude random-float 10
    set pDegre_introversion_extraversion random-float 10
    set pConfiance 0


    if(Type-Affichage = "Age")[
      if(pCatAge = Senior)[ set color gray]
      if(pCatAge = Moyen)[ set color orange]
      if(pCatAge = Jeune)[ set color green]
    ]

    if(Type-Affichage = "Genre")[
      if(pGenre = Homme)[ set color blue]
      if(pGenre = Femme)[ set color pink]
    ]

    if(Type-Affichage = "None")[ set color gray]
  ]


end

;; initialisation des variable global
to setup-globals
  set Senior 3
  set Moyen 2
  set Jeune 1
  set Homme 1
  set Femme 2
  set CoefHomme 1.1
  set CoefFemme 0.9

   set Genre_influ_A "NaN"
  set Age_influ_A "NaN"
  set Genre_influ_B "NaN"
  set Age_influ_B "NaN"

end


to Go
  if ticks = NB-ROUNDS [
  ask max-one-of Personnes [ deg_certitude] [
    let a xcor
    let b ycor
    let val deg_certitude
    ask patch-ahead 2
    [
      ask patch a b [
        sprout 1 [
            set color green ;;palette:scale-gradient [[255 0 0] [0 0 255]] pxcor min-pxcor val
          ;;set color palette:scale-gradient palette:scheme-colors "Divergent"  "RdBu" (Confiance-Interpersonnelle + 1) val (-1 * Confiance-Interpersonnelle) Confiance-Interpersonnelle
          set shape "star"
          set size 4
          stamp
          die
        ]
      ]
    ]

      if(pCatAge = Senior)[ set Age_influ_A "Senior"]
      if(pCatAge = Moyen)[ set Age_influ_A "intermédiaire"]
      if(pCatAge = Jeune)[ set Age_influ_A "Jeune"]
      if(pGenre = Homme)[ set Genre_influ_A "Homme"]
      if(pGenre = Femme)[ set Genre_influ_A "Femme"]

    ]

   ask min-one-of Personnes [ deg_certitude] [
    let a2 xcor
    let b2 ycor
    let val2 deg_certitude
    ask patch-ahead 2
    [
      ask patch a2 b2 [
        sprout 1 [
            set color red ;;palette:scale-gradient [[255 0 0] [0 0 255]] pxcor val2 max-pxcor
          ;;set color palette:scale-gradient palette:scheme-colors "Divergent"  "RdBu" (Confiance-Interpersonnelle + 1) val2 (-1 * Confiance-Interpersonnelle) Confiance-Interpersonnelle
          set shape "star"
          set size 4
          stamp
          die
        ]
      ]
    ]

      if(pCatAge = Senior)[ set Age_influ_B "Senior"]
      if(pCatAge = Moyen)[ set Age_influ_B "intermédiaire"]
      if(pCatAge = Jeune)[ set Age_influ_B "Jeune"]
      if(pGenre = Homme)[ set Genre_influ_B "Homme"]
      if(pGenre = Femme)[ set Genre_influ_B "Femme"]
  ]

  stop ]

  ask decisions [ die ]

  choisir-options

  set Confirm 0

  ask Personnes [
   if pMonChoix = Option [
      set Confirm Confirm + 1
    ]

  ]
  ask Personnes
  [ ask patch-ahead 1
      [ set pcolor red ] ]


  urnes-votes
  estimation
  prise-decision
amelioreation
  tick
end

to cal_Confiance_bio_psycho
   let Cortisol_Oxytocin array:from-list [ 0.50 0.842 0.587 0.826 0.628 0.819 0.652
     0.815 0.669 0.813 0.681 0.812 0.691 0.811 0.698 0.810 0.704 0.809
     0.710 0.809 0.714 0.808 0.719 0.808 0.722 0.808 0.725 0.808 0.728]
   set Confiance_bio_psycho ( array:item Cortisol_Oxytocin (NB-OF-AGENTS - 2))
end



to-report cal-genre
  let val random-float 1

  if(val >= 0.5)[report Homme]

  report Femme

end
;; calcul du temps de prise de decision
to-report temps_prise_decision []
   report  2 * NB-OF-AGENTS * NB-ROUNDS
end

;; initialisation du categorie d'age
to-report cal-cat-age
  report 1 + random (4 - 1)
end

;; calcul du poids de l'age en fonction des categories d'ages
to-report cal_poids_age [cat_age]
  if(cat_age = Senior)[ report ( 7.0 + random-float 2.9)]
  if(cat_age = Moyen)[ report (3.1 + random-float 2.8) ]
  report (1.0 + random-float 2.9)
end

;; calcul de la distance du sujet
to-report cal_distance_sujet [poids_age]
  report abs(10 - poids_age)
end

;; confiance interpersonnelle
to-report cal_confiance_interpo [attributs_physiques expertise_sujet]
  report (attributs_physiques + expertise_sujet) / 2
end

;; calul de la confiance
to-report cal_confiance [conf_bio_psy conf_interperso conf_soi]
  report (conf_bio_psy + conf_interperso + conf_soi) / 3
end

;; calcul de l'influence
to-report cal_influenceur [conf_inter_perso  conf_en_soi]
   ;;(conf_inter_perso + conf_en_soi) / 2 ;;; pour chaque turle ensuite le max
end





to setup-score-distribution

  set ValeurMu median(n-values Confiance-Interpersonnelle [i -> i + 1])
  set ValeurVariation 2 * (Confiance-Interpersonnelle / 10) ^ 2

  ask Personnes [
  if Type-Distribution = "Normale" [
      set pForce round(random-normal ValeurMu ValeurVariation)
      if pForce > Confiance-Interpersonnelle [ set pForce Confiance-Interpersonnelle ]
      if pForce < 1 [ set pForce 1 ]
  ]

  if Type-Distribution = "Uniforme" [
      set pForce ( random Confiance-Interpersonnelle ) + 1
    ]

  if Type-Distribution = "Constante" [
      set pForce round(Confiance-Interpersonnelle / 2)
    ]

  set size sqrt pForce
  ]

  ;;ask Personnes [
   ;; create-links-to other personnes with[ pForce >= [ pForce ] of myself ]
 ;; ]
end


to choisir-options
    set NB-Votants_A 0
  set NB-Votants_B 0
    ask Personnes [
      set pChoix_individuel random-float 10
      set pChoix_collectif  random-float 10
      set pDiff_choix_interet pChoix_individuel - pChoix_collectif
      ifelse pDiff_choix_interet > 0
      [ set pMonChoix "A"
    set NB-Votants_A (NB-Votants_A + 1)
    ]
      [ set pMonChoix "B"
            set NB-Votants_B (NB-Votants_B + 1)
    ]
    ]

    ifelse sum [ pDiff_choix_interet ] of Personnes >  0
    [ set Option "A"
  ]
    [ set Option "B"
  ]
end



to estimation
  ask Personnes [
    let x 3.5 ;;error_factor ; error runs between -x and x
    set pErreur ( -1 * x + random-float( 2 * x ) )
    let weighted_utility false
    ifelse weighted_utility = true ;; not a true weighed average since we're only interested in the sign, same perception error added to each linked utility
    [ set deg_introversion_extraversion pDiff_choix_interet * pForce + sum [ ([ pErreur ] of myself + pDiff_choix_interet) * (max list (pForce - [ pForce ] of myself + 1)  1) ] of out-link-neighbors ]
    [ set deg_introversion_extraversion pDiff_choix_interet * pForce + sum [ [ pErreur ] of myself + pDiff_choix_interet ] of other Personnes ]

    ifelse deg_introversion_extraversion < 0
    [ set expertise_prop_soi "B" ]
    [ set expertise_prop_soi "A" ]
  ]
end

to prise-decision
  set Confirm 0


  ask Personnes [
    ifelse pMonChoix = Option
      [ set pMatch 1
    ]
      [ set pMatch 0
    ]

    ifelse pMonVote = 0
    [if expertise_prop_soi = Option
      [ set Confirm Confirm + 1 ]
    ]
    [ if pMonChoix = Option
      [ set Confirm Confirm + 1 ]
        set pMonVote 0
      ]
  ]
end

to urnes-votes

  ask Personnes [
    ifelse pMonChoix = "A"
      [ set Interet_individuel Interet_individuel + 1 ]
      [ set Interet_collectif Interet_collectif + 1 ] ]
    set Criteres NB-OF-AGENTS / 2
    create-Decisions 1 [
    if Confirm > Criteres
    [ set color green
      set choixFinal 1
      set Deg_Confiant Deg_Confiant + 1 ]
    if Confirm = Criteres
    [ set color yellow
      set choixFinal 0
      set Liens_cooperation  Liens_cooperation  + 1]
    if Confirm < Criteres
    [ set color red
      set choixFinal -1
      set Deg_Mefiance Deg_Mefiance + 1 ]
      set size 4
     set shape "circle"
    ]
  set NBPointsConfiant (Deg_Confiant) / (Deg_Confiant + Deg_Mefiance + Liens_cooperation ) * 100

end





to amelioreation

  ask Personnes [
    ask my-out-links [die]

    ; + + scenario
    if choixFinal > 0 and pMonChoix = Option [
      if ( (pForce - deg_certitude) > 1 ) [ set deg_certitude deg_certitude + 1 ]
      ask patch-ahead 1
      [ set pcolor green]
    ]
    ; + - scenario
    if choixFinal > 0 and pMonChoix != Option [
      if ( deg_certitude > 0 ) [ set deg_certitude deg_certitude - 1 ]
      Let val deg_certitude
      ask patch-ahead 1
      [ set pcolor red]
    ]
    ; - + scenario
    if choixFinal < 0 and pMonChoix = Option [ ; - + scenario
      if ( (pForce - deg_certitude) > 1 ) [ set deg_certitude deg_certitude + 1 ]
      Let val deg_certitude
            ask patch-ahead 1
      [ set pcolor green]
    ]
    ; - - scenario
    if choixFinal < 0 and pMonChoix != Option [
       set deg_certitude -1 * pForce
            ask patch-ahead 1
      [ set pcolor red]
    ]

    create-links-to other Personnes with [ pForce >= [ pForce - deg_certitude ] of myself ]
    Let val deg_certitude

  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
755
10
1270
526
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-19
19
-19
19
0
0
1
ticks
30.0

BUTTON
39
12
113
45
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
172
10
235
43
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
53
186
86
NB-OF-AGENTS
NB-OF-AGENTS
3
30
25.0
1
1
NIL
HORIZONTAL

SLIDER
9
91
181
124
NB-ROUNDS
NB-ROUNDS
3
300
134.0
1
1
NIL
HORIZONTAL

CHOOSER
13
129
151
174
Type-Affichage
Type-Affichage
"None" "Genre" "Age"
2

PLOT
6
219
318
512
Moyen confiance / nb-rounds
nb-rounds
moyenne-confiance
0.0
1.0
-2.0
2.0
true
false
"" ""
PENS
"normal-confiance" 1.0 0 -14454117 true "" "ifelse ticks < 1\n[ stop ]\n[ plot ( ( ( Deg_Confiant / ( Deg_Confiant + Deg_Mefiance + Liens_cooperation ) ) -  Confiance_bio_psycho ) * 100 ) ]"
"line-zero" 1.0 0 -5298144 true "" "plot(0)"

CHOOSER
205
64
360
109
Type-Distribution
Type-Distribution
"Normale" "Uniforme" "Constante"
0

SLIDER
7
179
258
212
Confiance-Interpersonnelle
Confiance-Interpersonnelle
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
190
133
376
166
cortisol_ocytocine
cortisol_ocytocine
1
10
5.0
1
1
NIL
HORIZONTAL

PLOT
321
177
749
510
nb-votant / nb-rounds
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"NB-Votants_A" 1.0 1 -11085214 true "" "plot NB-Votants_A"
"NB-Votants_B" 1.0 1 -2674135 true "" "plot NB-Votants_B "

MONITOR
378
15
526
60
Genre_influenceur_A
Genre_influ_A
17
1
11

MONITOR
561
10
710
55
Genre_influenceur_B
Genre_influ_B
17
1
11

MONITOR
377
71
538
116
Cat_age_influenceur_A
Age_influ_A
17
1
11

MONITOR
565
71
724
116
cat_age_influenceur_B
Age_influ_B
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person-trust
true
15
Polygon -7500403 true false 120 135 105 135
Polygon -6459832 false false 45 105
Polygon -7500403 true false 60 165
Polygon -16777216 true false 135 135
Circle -955883 true false 150 210 0
Rectangle -1 true true 75 150 225 285
Polygon -1 true true 60 195 30 195 30 120 270 120 270 195 240 195 240 150 60 150 60 195
Polygon -13345367 true false 105 120 150 195 195 120 105 120
Polygon -2674135 true false 135 120
Polygon -2674135 true false 120 120
Polygon -2674135 true false 120 120 150 195
Polygon -2674135 true false 120 120
Polygon -2674135 true false 135 120 150 195 165 120 135 120
Circle -1184463 true false 88 13 122
Circle -1 true true 105 45 30
Circle -1 true true 165 45 30
Polygon -1 true true 150 60 135 90 150 90 150 60
Polygon -1 true true 120 120
Polygon -1 true true 135 105
Polygon -1 true true 120 105 135 120 165 120 180 105 120 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

table_trust
true
0
Circle -7500403 true true 45 45 210

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
