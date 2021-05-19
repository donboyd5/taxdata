using JuMP, Cbc, NPZ, Tulip  # add Tulip
using Printf

function Solve_func(year, tol)

	println("Solving weights for $year ...\n\n")
	println("DJB using Tulip 750...\n\n")

	array = npzread(string(year, "_input.npz"))

	A1 = array["A1"]
	A2 = array["A2"]
	b = array["b"]


	# Replace these next 2 lines with these 3 lines
	# model = Model(Cbc.Optimizer)
	# set_optimizer_attribute(model, "logLevel", 1)
	model = Model(Tulip.Optimizer)  # djb
	set_optimizer_attribute(model, "OutputLevel", 1)  # 0=disable output (default), 1=show iterations
	set_optimizer_attribute(model, "IPM_IterationsLimit", 750)  # default 100

    # set_optimizer_attribute(model, "Threads", 10)  # 1=default; Tulip is single-threaded but linear algebra back ends may use multiple threads

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
	# solution_summary(model, verbose=true)
	@printf "Objective = %.4f\n" objective_value(model)

	# add these 2 lines to see final objective function
	st = termination_status(model)
	println("Termination status: $st")

	r_vec = value.(r)
	s_vec = value.(s)

	npzwrite(string(year, "_output.npz"), Dict("r" => r_vec, "s" => s_vec))

	println("\n")

end



year_list = [x for x in 2014:2030]
# year_list = [x for x in 2014:2014]
tol = 0.70

# Run solver function for all years and tolerances (in order)
for i in year_list
	Solve_func(i, tol)
end
