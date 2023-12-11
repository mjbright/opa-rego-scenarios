
package play

import future.keywords.contains
import future.keywords.if

fruit := {
    "pineapple": { "colors": ["blue"]},
    "orange":    { "colors": ["blue"]},
}

fruit.pineapple.colors contains x if x := "blue"     # multi-value rule
#fruit.pineapple.colors contains x if x := "yellow"     # multi-value rule

#fruit.orange.color(x) = true if x == "orange"          # function


