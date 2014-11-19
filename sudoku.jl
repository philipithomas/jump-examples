module sudoku

#=
Let's solve a sudoku problem.

Credit for approach and some logig, incl printing: https://github.com/JuliaOpt/JuMP.jl/blob/master/examples/sudoku.jl
=#

using JuMP
using Cbc # Open source solver. Must support integer programming.

m = Model(solver=CbcSolver())

# Define our input sudoku
# Zero = unknown

grid = [
    [6 0 0  5 0 2  0 7 0],
    [0 0 0  4 0 0  0 0 0],
    [5 0 0  0 6 0  3 0 0],

    [7 0 1  0 0 0  8 0 0],
    [0 8 2  6 0 4  7 5 0],
    [0 0 5  0 0 0  6 0 2],

    [0 0 7  0 8 0  0 0 9],
    [0 0 0  0 0 3  0 0 0],
    [0 5 0  2 0 7  0 0 6],
] # source: DailySudoku.com

# Build a 9x9x9 binary matrix:
# i = row in sudoku
# j = column in sudoku
# k = every possible value at that location (1 -> 9)
#
#
# The binary value at each location is whether that sudoku cell has that value
@defVar(m, x[1:9, 1:9, 1:9], Bin)

# Constraint 1: Each cell can only have one value
for i in 1:9 # Row
    for j in 1:9 # Column
        # only one binary can be switched to "true"
        @addConstraint(m, sum(x[i, j, :]) == 1)
    end
end

# Constraint 2: Each value appears once per column
for j in 1:9 # Row
    for k in 1:9 # Number
        # only one binary can be switched to "true"
        @addConstraint(m, sum(x[:, j, k]) == 1)
    end
end

# Constraint 3: Each value appears once per row
for i in 1:9 # Row
    for k in 1:9 # Number
        # only one binary can be switched to "true"
        @addConstraint(m, sum(x[i, :, k]) == 1)
    end
end

# Constraint 4: Each value appears once per subgrid
# 3x3 subgrid
for i in 1:3:7 # subgrid row start index
    for j in 1:3:7 # subgrid column start index
        for k in 1:9
            # "Each number appears once per subgrid"
            @addConstraint(m, sum(x[i:i+2, j:j+2, k]) == 1)
        end
    end
end



# Now we actually load in the input grid!
for i in 1:9
    for j in 1:9
        if grid[i, j] != 0
            @addConstraint(m, x[i, j, grid[i,j]] == 1)
        end
    end
end

# Solve it
status = solve(m)

# Check solution
if status == :Infeasible
    error("No solution found!")
else
    # Solver returns floats. Convert to int.
    out = getValue(x)
    sol = zeros(Int,9,9)
    for i in 1:9, j in 1:9, k in 1:9
        if out[i, j, k] >= 0.9
            sol[i, j] = k
        end
    end
end

# Display solution
println("Solution:")
println("[-----------------------]")
for i in 1:9
    print("[ ")
    for j in 1:9
        print("$(sol[i,j]) ")
        if j % 3 == 0 && j < 9
            print("| ")
        end
    end
    println("]")
    if i % 3 == 0
        println("[-----------------------]")
    end
end


end#module
