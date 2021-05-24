using JuMP, Cbc, NPZ, Tulip, Clp
# using COSMO, OSQP
using Statistics
using Printf
using LinearAlgebra

# year = 2012
# tol = 0.4

function Solve_func(year, tol)

	println("Solving weights for $year ...\n\n")
	println("Using Tulip as LP solver...\n")

	# array = npzread(string(year, "_input.npz"))

	ddir = "/home/donboyd/Documents/python_projects/taxdata/puf_stage2/"
	array = npzread(string(ddir, year, "_input.npz"))

	A1 = array["A1"]
	A2 = array["A2"]
	b = array["b"]

	N = size(A1)[2]

    # scale
    # scale(A) = (A .- mean(A,dims=1)) ./ std(A,dims=1)
	# sums of absolute values
	scale = N ./ sum(abs.(A1), dims=2)

    A1s = scale .* A1
	A2s = scale .* A2
	# sum(abs.(A1s), dims=2)
	# sum(abs.(A2s), dims=2)
	bs = scale .* b

	model = Model(Cbc.Optimizer)
	set_optimizer_attribute(model, "logLevel", 1)

	# model = Model(Clp.Optimizer)
	# set_optimizer_attribute(model, "LogLevel", 1) # note case different from Cbc
	# set_optimizer_attribute(model, "MaximumIterations", 50000)

	model = Model(Tulip.Optimizer)
	set_optimizer_attribute(model, "OutputLevel", 1)  # 0=disable output (default), 1=show iterations
	set_optimizer_attribute(model, "IPM_IterationsLimit", 100)  # default 100


	# @variable(model, r[1:N] >= 0)
	# @variable(model, s[1:N] >= 0)

	@variable(model, 0 <= r[1:N] <= tol)
	@variable(model, 0 <= s[1:N] <= tol)

	@objective(model, Min, sum(r[i] + s[i] for i in 1:N))

	# bound on top by tolerance
	# @constraint(model, [i in 1:N], r[i] + s[i] <= tol)

	# Ax = b
	# @constraint(model, [i in 1:length(b)], sum(A1[i,j] * r[j] + A2[i,j] * s[j]
	# 	                          for j in 1:N) == b[i])

	@constraint(model, [i in 1:length(bs)], sum(A1s[i,j] * r[j] + A2s[i,j] * s[j]
		                          for j in 1:N) == bs[i])


	optimize!(model)
	termination_status(model)

	# add these 2 lines to see termination status and objective function
	st = termination_status(model)
	println("Termination status: $st")
	@printf "Objective = %.4f\n" objective_value(model)

	r_vec = value.(r)
	s_vec = value.(s)

	# npzwrite(string(year, "_output.npz"), Dict("r" => r_vec, "s" => s_vec))

	println("\n")

	# return x
	x = 1.0 .+ r_vec - s_vec  # note the .+
	x
end



# year_list = [x for x in 2012:2030]
# year_list = [x for x in 2012:2012]
# tol_list = [0.40, 0.38, 0.35, 0.33, 0.30, 0.45, 0.45,
# 			0.45, 0.45, 0.45, 0.45, 0.45, 0.45, 0.45,
# 			0.45, 0.45, 0.45, 0.45, 0.45]

# Run solver function for all years and tolerances (in order)
# for i in zip(year_list, tol_list)
# 	Solve_func(i[1], i[2])
# end

x = Solve_func(2030, 0.45)

quantile!(x, [0.0, .1, .25, .5, .75, 1])

sum(A1[i,j] * [j] + A2s[i,j] * s[j] for j in 1:N) == bs[i]

start = sum(A1, dims=2)
x2 = x .- 1.0
chk = sum(x2' .* A1, dims=2)
b

chk2 = vec(chk ./ b)
quantile!(chk2, (0, .1, .25, .5, .75, .9, 1))

dot(A1, x)
size(A1)
size(x)
dot(x, A1')

A1 * x

b
bs

x

sum(x' .* A1s, dims=2)

