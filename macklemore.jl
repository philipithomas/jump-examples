module macklemore

#=
We are going to the thrift store and need 99 cents. What is the least amount of
weight we need to carry?

i.e. a knapsack problem

We specify that you need at least 99 cents - does the answer change if you need exact change?
=#

using JuMP
using Cbc # Open source solver. Must support integer programming.

m = Model(solver=CbcSolver())

# Variables represent how many of each coin we want to carry
@defVar(m, pennies >= 0, Int)
@defVar(m, nickels >= 0, Int)
@defVar(m, dimes >= 0, Int)
@defVar(m, quarters >= 0, Int)

# We need at least 99 cents
@addConstraint(m, 1 * pennies + 5 * nickels + 10 * dimes + 25 * quarters >= 99)

# Minimize mass (Grams)
# (source: US Mint)
@setObjective(m, Min, 2.5 * pennies + 5 * nickels + 2.268 * dimes + 5.670 * quarters)

# Solve
status = solve(m)

println("Minimum weight: ", getObjectiveValue(m), " grams")
println("using:")
println(round(getValue(pennies)), " pennies") # "round" to cast as integer
println(round(getValue(nickels)), " nickels")
println(round(getValue(dimes)), " dimes")
println(round(getValue(quarters)), " quarters")

end # end the module - not traditional to indent
