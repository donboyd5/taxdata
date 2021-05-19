using JuMP, Cbc, NPZ, Tulip
using Printf

function Solve_func(year, tol)

	println("Solving weights for $year ...\n\n")
	println("Using Tulip as LP solver...\n")

	array = npzread(string(year, "_input.npz"))

	A1 = array["A1"]
	A2 = array["A2"]
	b = array["b"]

	# model = Model(Cbc.Optimizer)
	# set_optimizer_attribute(model, "logLevel", 1)
	model = Model(Tulip.Optimizer)
	set_optimizer_attribute(model, "OutputLevel", 1)  # 0=disable output (default), 1=show iterations
	set_optimizer_attribute(model, "IPM_IterationsLimit", 100)  # default 100


	N = size(A1)[2]

	@variable(model, r[1:N] >= 0)
	@variable(model, s[1:N] >= 0)

	@objective(model, Min, sum(r[i] + s[i] for i in 1:N))

	# bound on top by tolerance
	@constraint(model, [i in 1:N], r[i] + s[i] <= tol)

	# Ax = b
	@constraint(model, [i in 1:length(b)], sum(A1[i,j] * r[j] + A2[i,j] * s[j]
		                          for j in 1:N) == b[i])


	optimize!(model)
	termination_status(model)

	# add these 2 lines to see termination status and objective function
	st = termination_status(model)
	println("Termination status: $st")
	@printf "Objective = %.4f\n" objective_value(model)



	r_vec = value.(r)
	s_vec = value.(s)

	npzwrite(string(year, "_output.npz"), Dict("r" => r_vec, "s" => s_vec))

	println("\n")

end



year_list = [x for x in 2012:2030]
tol_list = [0.40, 0.38, 0.35, 0.33, 0.30, 0.45, 0.45,
			0.45, 0.45, 0.45, 0.45, 0.45, 0.45, 0.45,
			0.45, 0.45, 0.45, 0.45, 0.45]

# Run solver function for all years and tolerances (in order)
for i in zip(year_list, tol_list)
	Solve_func(i[1], i[2])
end
