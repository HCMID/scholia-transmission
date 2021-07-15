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

# ╔═╡ 38ba57d2-2a9c-42f7-b7aa-913dba2a3723
# Or load from a local file:
begin
#f = string(pwd() |> dirname, "/data/topicmodelingedition.cex")
#citable = CitableCorpus.fromfile(CitableTextCorpus, f, "|")
#
end


# ╔═╡ 81f739bc-e3e2-11eb-1395-c7b67016f6f1
md"""# Topic modelling in Pluto notebooks using data from a local file


"""

# ╔═╡ 7f818257-633c-4b39-9a26-d8810fca6fd7
md"Compute model for `k` topics using `iterations` iterations"

# ╔═╡ b1810914-4edf-4e0a-9ea2-3c94a4709f1f
k = 9

# ╔═╡ 8ce0d7a2-6237-46e5-8118-2a7474434747
iterations = 40

# ╔═╡ c7344839-9301-46ea-a4e1-7dae4a6a2c7b
md"""> ## Under the hood
>
> ALl the preparatory steps:
>
> 1. Load a citable corpus
> 2. Convert it to a corpus for topic modelling
> 3. Train a model for `k` topics in the corpus

"""

# ╔═╡ d45f5ef2-6f1e-4484-a886-ba6285bb5c18
md"**1.** Load a citable corpus from a URL"

# ╔═╡ 2dff3d8a-4d08-4e67-a0f5-6f0155039fd9
url = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/topicmodelingedition.cex"

# ╔═╡ 0388e2b6-8bcc-479b-b48c-4df7fb852d0e
citable = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ e5544979-814a-4839-9c6c-9ed413b353d6
citable.corpus |> length

# ╔═╡ f11a8c98-b02c-450d-8d89-e8450a66e62e
md"**2** Convert `CitableTextCorpus` to a `Corpus` for the `TopicModelsVB` module."

# ╔═╡ f8bf613e-51a3-40c0-82d4-82e9046fb911
tmcorp = tmcorpus(citable)

# ╔═╡ 05741137-f9ea-4162-b872-81598180cfbf
md"**3**. Train a model for `k` topics"

# ╔═╡ 1a19a00a-43e6-4185-9686-0ab732a4e98e
model = LDA(tmcorp, k)

# ╔═╡ f86b3cc6-4b23-43b2-8909-8215c965454a
train!(model, iter=iterations, tol=0)

# ╔═╡ de130eb2-c5a1-4e61-9f04-1e4e3cf37ec5
showtopics(model, k)

# ╔═╡ Cell order:
# ╟─38ba57d2-2a9c-42f7-b7aa-913dba2a3723
# ╟─51afa490-d9ae-430f-bc50-ea9c5be53e79
# ╟─81f739bc-e3e2-11eb-1395-c7b67016f6f1
# ╟─7f818257-633c-4b39-9a26-d8810fca6fd7
# ╟─b1810914-4edf-4e0a-9ea2-3c94a4709f1f
# ╟─8ce0d7a2-6237-46e5-8118-2a7474434747
# ╠═f86b3cc6-4b23-43b2-8909-8215c965454a
# ╠═de130eb2-c5a1-4e61-9f04-1e4e3cf37ec5
# ╟─c7344839-9301-46ea-a4e1-7dae4a6a2c7b
# ╟─d45f5ef2-6f1e-4484-a886-ba6285bb5c18
# ╟─2dff3d8a-4d08-4e67-a0f5-6f0155039fd9
# ╠═0388e2b6-8bcc-479b-b48c-4df7fb852d0e
# ╠═e5544979-814a-4839-9c6c-9ed413b353d6
# ╟─f11a8c98-b02c-450d-8d89-e8450a66e62e
# ╠═f8bf613e-51a3-40c0-82d4-82e9046fb911
# ╟─05741137-f9ea-4162-b872-81598180cfbf
# ╠═1a19a00a-43e6-4185-9686-0ab732a4e98e
