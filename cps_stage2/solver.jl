using JuMP, Cbc, NPZ, Tulip

function Solve_func(year, tol)

	println("Solving weights for $year ...\n\n")
	println("DJB using Tulip...\n\n")

	array = npzread(string(year, "_input.npz"))

	A1 = array["A1"]
	A2 = array["A2"]
	b = array["b"]

	# model = Model(Cbc.Optimizer)
	# set_optimizer_attribute(model, "logLevel", 1)
	# set_optimizer_attribute(model, "autoScale", "on")  # djb
	model = Model(Tulip.Optimizer)  # djb
	set_optimizer_attribute(model, "OutputLevel", 1)  # 0=disable output (default), 1=show iterations
	set_optimizer_attribute(model, "Threads", 10)  # 1=default; Tulip is single-threaded but linear algebra back ends may use multiple threads
	JuMP.set_optimizer_attribute(jump_model, "IPM_IterationsLimit", 500)  # default 100

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
	@printf "Objective = %.4f\n" objective_value(model)

	r_vec = value.(r)
	s_vec = value.(s)

	npzwrite(string(year, "_output.npz"), Dict("r" => r_vec, "s" => s_vec))

	println("\n")

end



# year_list = [x for x in 2014:2030]
year_list = [x for x in 2014:2014]
tol = 0.70

# Run solver function for all years and tolerances (in order)
for i in year_list
	Solve_func(i, tol)
end
