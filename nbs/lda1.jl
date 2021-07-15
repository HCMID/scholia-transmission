### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 51afa490-d9ae-430f-bc50-ea9c5be53e79
begin
	using Pkg
	Pkg.add("TextAnalysis")
	Pkg.add("CitableText")
	Pkg.add("CitableCorpus")
	Pkg.add("TopicModelsVB")
	Pkg.add("CitableText")
	Pkg.add(url="https://github.com/neelsmith/CorpusConverters.jl")
	
	using TextAnalysis
	using CitableText
	using CitableCorpus
	using TopicModelsVB
	using CorpusConverters

	 
	
	html"""
	<div class="nb">
	<ul>
	<li>Notebook version: <b>0.1.0</b></li>
	<li>Requires: Pluto (any version)</li>
	</ul>
	</div>
	"""
end

# ╔═╡ 81f739bc-e3e2-11eb-1395-c7b67016f6f1
md"# Topic modelling in Pluto notebooks"

# ╔═╡ 2dff3d8a-4d08-4e67-a0f5-6f0155039fd9
url = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/topicmodelingedition.cex"

# ╔═╡ 0388e2b6-8bcc-479b-b48c-4df7fb852d0e
citable = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ e7e55450-a8a9-4d7a-ac6f-9a363fb0326e
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), citable.corpus) |> CitableTextCorpus

# ╔═╡ e5544979-814a-4839-9c6c-9ed413b353d6
scholia.corpus |> length

# ╔═╡ f8bf613e-51a3-40c0-82d4-82e9046fb911
tmcorp = tmcorpus(scholia)

# ╔═╡ Cell order:
# ╟─51afa490-d9ae-430f-bc50-ea9c5be53e79
# ╟─81f739bc-e3e2-11eb-1395-c7b67016f6f1
# ╟─2dff3d8a-4d08-4e67-a0f5-6f0155039fd9
# ╠═0388e2b6-8bcc-479b-b48c-4df7fb852d0e
# ╠═e7e55450-a8a9-4d7a-ac6f-9a363fb0326e
# ╠═e5544979-814a-4839-9c6c-9ed413b353d6
# ╠═f8bf613e-51a3-40c0-82d4-82e9046fb911
