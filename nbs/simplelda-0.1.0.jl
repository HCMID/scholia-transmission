### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 7ed58b4c-e646-11eb-1526-4b56470a3b62
begin
	using Pkg
	
	Pkg.add("PlutoUI")
	using PlutoUI
	
	Pkg.add(url="https://github.com/homermultitext/HmtTopicModels.jl")
	using HmtTopicModels
	
		
	Pkg.add(url="https://github.com/neelsmith/CorpusConverters.jl")
	using CorpusConverters
	
	Pkg.add("CitableCorpus")
	using CitableCorpus
	
	Pkg.add("TopicModelsVB")
	using TopicModelsVB
	
	md"""
	Notebook version:  **0.1.0**
	"""
	
end

# ╔═╡ 1876658c-302e-48ad-947e-099a23472e32
md"See Pkg status: $(@bind showpkg CheckBox(default=false))"

# ╔═╡ 57134c2e-c646-4ec4-bb15-eb1298ca35da
# Display package status in Pluto nb:
begin
	if showpkg
		with_terminal() do
			Pkg.status(; io = stdout)
		end
	else
		md""
	end
end

# ╔═╡ 550c4d2d-7c47-4f56-8bc9-f4708ef9aa83
md"""> # Simple topic modeling with Latent Dirichlet Allocation (LDA)

"""

# ╔═╡ c7e2e54a-019d-4f37-a88e-d0158110bc43
k = 18

# ╔═╡ 9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
iterations = 65

# ╔═╡ 15da696a-1fe4-40a4-9a92-88e08a8e49b5
wordstoshow = 6

# ╔═╡ 555bab88-808e-487b-8441-9aa2ad3f4309
md"""
**Results of modeling $k topics after $iterations iterations: top $wordstoshow words for each topic**
"""

# ╔═╡ 4a8ce796-f3ce-4958-9b2c-593c0d370572
md"> Load corpus formatted for topic modelling"

# ╔═╡ e6405518-efb3-4911-9ca3-a42c0c36ad90
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingedition.cex"

# ╔═╡ b465f1be-29b8-40f4-96cd-b40c3ab3d326
tmed = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 0c26d794-0a06-4ad0-a244-21ff1c520d18
tmed.corpus |> length

# ╔═╡ a21a75f9-7059-4b16-8d00-dfcf32c0d642
md"> Create model with `k` topics`"

# ╔═╡ 8652843f-65eb-4a42-ae81-a9aec0acef49
tmcorp = tmcorpus(tmed)

# ╔═╡ 4b840632-0ef4-490f-a9e8-c95184ca7e59
model = LDA(tmcorp, k)

# ╔═╡ 3bd93907-4ab4-4c12-8867-b9f8db27ad4b
train!(model, iter=iterations, tol=0)

# ╔═╡ e232a0ef-5473-4708-b50f-4f1f43ebee33
with_terminal() do
	showtopics(model, cols=k, wordstoshow)
end

# ╔═╡ 2a186432-33af-40be-b5c7-3b5bad87c7c5
#md"Number of topics (`k`) $(@bind k Slider(4:25; default=8, show_value=true))"

# ╔═╡ Cell order:
# ╟─7ed58b4c-e646-11eb-1526-4b56470a3b62
# ╟─1876658c-302e-48ad-947e-099a23472e32
# ╟─57134c2e-c646-4ec4-bb15-eb1298ca35da
# ╟─550c4d2d-7c47-4f56-8bc9-f4708ef9aa83
# ╠═c7e2e54a-019d-4f37-a88e-d0158110bc43
# ╟─4b840632-0ef4-490f-a9e8-c95184ca7e59
# ╠═9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
# ╠═3bd93907-4ab4-4c12-8867-b9f8db27ad4b
# ╟─555bab88-808e-487b-8441-9aa2ad3f4309
# ╠═15da696a-1fe4-40a4-9a92-88e08a8e49b5
# ╟─e232a0ef-5473-4708-b50f-4f1f43ebee33
# ╟─4a8ce796-f3ce-4958-9b2c-593c0d370572
# ╟─e6405518-efb3-4911-9ca3-a42c0c36ad90
# ╟─b465f1be-29b8-40f4-96cd-b40c3ab3d326
# ╟─0c26d794-0a06-4ad0-a244-21ff1c520d18
# ╟─a21a75f9-7059-4b16-8d00-dfcf32c0d642
# ╟─8652843f-65eb-4a42-ae81-a9aec0acef49
# ╟─2a186432-33af-40be-b5c7-3b5bad87c7c5
