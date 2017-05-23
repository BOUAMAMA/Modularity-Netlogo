globals [
modular-patch trap-patch Number-of-descentralized-firms outsourcing-value industry-patches Modularity-occurence? temp]
extensions [nw]
;; we make a bunch of agents as conponents, squares
breed [components component]
;; we make a bunch of agents as producers, hito
breed [Suppliers supplier]
;; we make a bunch of agents as assemblers, company
breed [Firms firm]
;; we create an agentset for the producers producing the same module
breed [concurrents concurrent]

;; we assign a variable value to each component
components-own [component-value supplied-to  preModular-value checked? integral-module? supplied-to-firm-k?]
;; we assign to each assembler the variables : product and its value
suppliers-own [prod-product Suppliers-product-value preModular-value component-value producing? supplying?]
;; we assign to each assembler the variables: product and its value
firms-own [PreModular-value outsourcing?  number-outsourcing-firms number-of-suppliers decentralized-organization? trap?]
;; we assign the same variable of producers to corencurrents
concurrents-own [prod-product producers-product-value  component-value producing?]


;;;;;;;;;;;;;;;;;;;;;;
;;;; Hajimemashoo ;;;;
;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  ;; we create the components patches where the components will be
  let components-patches patches with [pxcor > 0 and pycor > 0]
  ask components-patches [set pcolor white]

  ;; we make a kind of cool environment
  ;; first we create the market patches where the assemblers will be
  let market-patches patches with [pycor < 0]
  ask market-patches [set pcolor blue
  set plabel ""
  ]

  ;; we create the industry patches where the producers will be
  set industry-patches patches with [pxcor < 0 and pycor > 0 ]
  ask industry-patches [set pcolor white]

  ;;Define patches where we will indicate the word modularity
  ask patch (0.5 * max-pxcor) (- 0.5 * max-pycor) [
    set modular-patch self
    set plabel-color black
    ]
  ask patch (-0.1 * max-pxcor) (0.5 * max-pycor) [
    set trap-patch self
    set plabel-color black
    ]
  ;; we make the producers in the shape of a person
  create-suppliers Suppliers-number [set shape "person"
  ;; for the suppliers here I dont care what they are producing, I just want to simplfy and link each supplier to one component
    set producing? false
    set supplying? false
    set color red
    move-to one-of market-patches]

  ;; create assemblers and move them to the industry patches
  create-firms 20 [set shape "house two story"
    set color red
    move-to one-of industry-patches
    set number-outsourcing-firms 0
    set outsourcing? false
    set number-of-suppliers 0
    set decentralized-organization? false
    set trap? false
  ]
set Number-of-descentralized-firms 0
set Modularity-occurence? false
  ;; create components and move them to the components patches
  create-components Number-of-components [set shape "square"
     set supplied-to 0
     set integral-module? false
     set supplied-to-firm-k? false
     set color pink
     move-to one-of components-patches
    ]
  ;; we randmize the value of components
  ask components [randomize
    set checked? false
    ]
  ;;ask
nw:set-context components links
  ;; we set the value of the assemblers-product to the mean of the components values
  ask firms [set preModular-value mean [ component-value ] of components ];; let Product-Value mean [ component-value ] of components
  ;; intialize the value producers prodyct to 0 'empty product'
  ask suppliers [set Suppliers-product-value 0]

  reset-ticks
end


;;;;;;;;;;;;
;;;; go ;;;;
;;;;;;;;;;;;

to go
  ask modular-patch [set plabel ""]
  ask trap-patch [set plabel ""]
  ;; we need to first ask the conponents to check if the ticks are at 0 or at 100t then randomize
  ;; ask components [if (ticks = 100 * t) or (ticks = 0) [randomize] ]
  ;; before starting to pick components
  ;; hatch every component and move the hatched one to the industry patches
  ;; create a product between the components : randomize the links between them : have a look into the influenceables model
  ;; calculate the coupling index of the product


  ask turtles [
  while [any? components with [checked? = false] and any? suppliers with [supplying? = false]]
  [let supplier-j one-of suppliers with [supplying? = false]
  ;; pick one of components and store its value in the variable component-i-value
  let component-i one-of components
  let component-i-value [component-value] of component-i
  ask component-i [if checked? = false [
      let market-patches patches with [pcolor = blue]
      move-to one-of market-patches
      move-to supplier-j
      set checked? true
      ask supplier-j [set supplying? true]]]]

let firm-k one-of firms
    let component-m one-of components
let component-m-value [component-value] of component-m
let p-outsourcing-value (1 / Number-of-components) *(preModular-value * Number-of-components - component-m-value)
      set outsourcing-value ( p-outsourcing-value + component-m-value ) / 2
 ask firm-k [if outsourcing-value > preModular-value [
    let market-patches patches with [pcolor = blue]
    move-to one-of market-patches
    create-link-with component-m
    ask component-m [set supplied-to supplied-to + 1]
    set outsourcing? true
    set number-of-suppliers number-of-suppliers + 1
    set number-outsourcing-firms number-outsourcing-firms + 1]]

    ask components [if any? components with [supplied-to > 2] and Number-of-descentralized-firms > 10 [
    set Modularity-occurence? true
    ask modular-patch [set plabel "MODULARITY" ]]]


let firm-n one-of firms
  let number-of-suppliers-n [number-of-suppliers] of firm-n
  ask firm-n [if number-of-suppliers-n > 2 [
    set decentralized-organization? true
      set number-of-descentralized-firms count firms with [decentralized-organization? = true ]]]

if Modularity-occurence? = true [
      ask components [Force-integral-innovation]]



ask firms [check-for-the-trap]
  ]
  tick
end




to randomize
  ask components [set component-value random-float 1]
end

to Force-integral-innovation
let component-i one-of components
  ask component-i [create-link-with one-of other components
  set integral-module? true ]
end
to check-for-the-trap
 if modularity-occurence? = true and ticks > 10 [
 let firm-m one-of firms
 ask firm-m [if decentralized-organization? = true and any? link-neighbors with [integral-module? = true]
    [set trap? true
      move-to one-of industry-patches
        ask link-neighbors [die]]
    ask trap-patch [set plabel "MODULARITY TRAP" ]
  ]]

end
@#$#@#$#@
GRAPHICS-WINDOW
243
10
732
500
-1
-1
19.242424242424242
1
25
1
1
1
0
0
0
1
-12
12
-12
12
0
0
1
ticks
30.0

BUTTON
27
78
92
112
NIL
setup
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
97
78
161
112
NIL
go
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
26
226
216
259
Number-of-components
Number-of-components
0
100
13.0
1
1
NIL
HORIZONTAL

BUTTON
51
120
143
153
NIL
randomize
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
30
264
202
297
Suppliers-number
Suppliers-number
0
40
13.0
1
1
NIL
HORIZONTAL

PLOT
15
355
215
505
Value of modular product
ticks
outsourcing-value
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot outsourcing-value"

MONITOR
23
304
210
349
NIL
Number-of-descentralized-firms
17
1
11

@#$#@#$#@
## WHAT IS IT?

Modelling the modularity trap

## HOW IT WORKS

We have 2 sets of agents: producers and assemblers.
Modularity arises when producers make different set of components.
The producers start with an empty product. Then they will try the components, and calculate the value of their product. If the value increases, they will keep the component, if not they will throw it away.
THe assemblers, start making all the components "integrated system", then when modularity arises, they will compare the value of the the modular product with the value of the product they were making, if this value increases they will adopt modularity.
when assemblers adopt modularity, we will check for the coupling index of the integrated system before and after,
If this value increases, then we can say that we have modularity trap.

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

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

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
NetLogo 6.0.1
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
