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
md"""# Topic modelling in Pluto notebooks using data from a local file


1. Load a citable corpus
2. Convert to a corpus for topic modelling
3. Train a model for `k` topics
4. Model the corpus

"""

# ╔═╡ 2dff3d8a-4d08-4e67-a0f5-6f0155039fd9
url = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/topicmodelingedition.cex"

# ╔═╡ 38ba57d2-2a9c-42f7-b7aa-913dba2a3723
f = string(pwd() |> dirname, "/data/test1.cex")


# ╔═╡ 0388e2b6-8bcc-479b-b48c-4df7fb852d0e
citable = CitableCorpus.fromfile(CitableTextCorpus, f, "|")

# ╔═╡ e7e55450-a8a9-4d7a-ac6f-9a363fb0326e
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), citable.corpus) |> CitableTextCorpus

# ╔═╡ e5544979-814a-4839-9c6c-9ed413b353d6
scholia.corpus |> length

# ╔═╡ f11a8c98-b02c-450d-8d89-e8450a66e62e
md"Convert `CitableTextCorpus` to a `Corpus` for the `TopicModelsVB` module."

# ╔═╡ f8bf613e-51a3-40c0-82d4-82e9046fb911
tmcorp = tmcorpus(scholia)

# ╔═╡ b1810914-4edf-4e0a-9ea2-3c94a4709f1f
model = LDA(tmcorp, 9)

# ╔═╡ Cell order:
# ╠═51afa490-d9ae-430f-bc50-ea9c5be53e79
# ╟─81f739bc-e3e2-11eb-1395-c7b67016f6f1
# ╟─2dff3d8a-4d08-4e67-a0f5-6f0155039fd9
# ╠═38ba57d2-2a9c-42f7-b7aa-913dba2a3723
# ╟─0388e2b6-8bcc-479b-b48c-4df7fb852d0e
# ╠═e7e55450-a8a9-4d7a-ac6f-9a363fb0326e
# ╠═e5544979-814a-4839-9c6c-9ed413b353d6
# ╟─f11a8c98-b02c-450d-8d89-e8450a66e62e
# ╠═f8bf613e-51a3-40c0-82d4-82e9046fb911
# ╠═b1810914-4edf-4e0a-9ea2-3c94a4709f1f
