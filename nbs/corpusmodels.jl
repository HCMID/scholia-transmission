### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ def34108-d2ca-4f88-8a48-2ea8c6b70ee5
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

# ╔═╡ 36077ee5-03a6-4257-a3b9-8259e5601813
css = html"""

<style>
.nb {
font-size: smaller;
color: gray;
}
</style>
"""

# ╔═╡ 680efdfc-e318-11eb-390c-d947b6a33e1b
md"""# Models


- simplify
- thereby allow different kinds/scales of analysis

"""

# ╔═╡ f3d5c1dc-4720-4050-a5f2-6467324f598a
md"""# Models for a corpus of text


Some Julia modules:

1. `CitableCorpus` module: series of nodes with `CtsUrn` and text content
2. `TextAnalysis` module: series of strings; can be converted to Document-Term matrix
3. `TopicModelsVB` module: 


JSLDA:

- a series of nodes associating an identifier and classifying label with each "document"

Pipeline:

`CitableCorpus` -> `TextAnalysis.Corpus` -> DT matrix -> TopicModelsVB.Corpus -> topic model


"""

# ╔═╡ 97287db9-c5a0-43d3-aa4f-f35af9116eb2
md"## CitableCorpus"

# ╔═╡ 95bbdbad-50c0-4427-bd62-c8e005050b99
md"Load a corpus with the preformatted topic-modelling edition for every citable unit (\"document\") in HMT. Here's the URL:"

# ╔═╡ f32b30a4-1650-4a30-a3f2-796c360ed214
url = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/topicmodelingedition.cex"

# ╔═╡ 3c56b217-2242-45cc-8d02-5955b578ce72
citable = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 91c5e15a-e110-4494-ba6c-dbbc899c5229
md"""
The corpus has an array of citable nodes called `corpus`.  Let's see how many there are.
"""

# ╔═╡ 1869e008-8cdf-486a-a32c-05f474b59229
length(citable.corpus)

# ╔═╡ 4e495ed0-d228-4325-807a-f9e0cf125230
md"Each citable node has a URN we can use to filter the corpus.  We'll select just those nodes with names ending in `comment`." 

# ╔═╡ ad4f7b4c-e803-4d88-a334-c7c2b7d5a449
scholianodes = filter(cn -> endswith(cn.urn.urn, "comment"),  citable.corpus)

# ╔═╡ 67ee1d49-b1c2-4414-a52d-7df8f0542a00
length(scholianodes)

# ╔═╡ 8461586f-23c9-47d0-95a2-e109a670bde4
scholia = CitableTextCorpus(scholianodes)

# ╔═╡ e8de1fbc-8034-406c-986c-a0a5e237ff18
md"## TextAnalysis"

# ╔═╡ 99ac4a30-cc0f-471c-8df0-4fb4b4b186bc
md"We can directly convert a `CitableCorpus` to the `TextAnalysis` module's model of a corpus."

# ╔═╡ 77b70ebf-7f88-4c5b-b631-57f8fb9e1653
tacorp = tacorpus(scholia)

# ╔═╡ b38306f0-61ea-4aa7-a522-d59e5c63db48
md"## TopicModelsVB"

# ╔═╡ 50e9e7ca-26e8-4447-8778-19d0d3399c4f
md"And maybe even to a TM VB model!"

# ╔═╡ e6d385fb-72fd-4d95-9ec7-7534b9fcf6aa
tmcorp = tmcorpus(scholia)

# ╔═╡ Cell order:
# ╟─def34108-d2ca-4f88-8a48-2ea8c6b70ee5
# ╟─36077ee5-03a6-4257-a3b9-8259e5601813
# ╟─680efdfc-e318-11eb-390c-d947b6a33e1b
# ╟─f3d5c1dc-4720-4050-a5f2-6467324f598a
# ╟─97287db9-c5a0-43d3-aa4f-f35af9116eb2
# ╟─95bbdbad-50c0-4427-bd62-c8e005050b99
# ╟─f32b30a4-1650-4a30-a3f2-796c360ed214
# ╠═3c56b217-2242-45cc-8d02-5955b578ce72
# ╟─91c5e15a-e110-4494-ba6c-dbbc899c5229
# ╠═1869e008-8cdf-486a-a32c-05f474b59229
# ╟─4e495ed0-d228-4325-807a-f9e0cf125230
# ╠═ad4f7b4c-e803-4d88-a334-c7c2b7d5a449
# ╠═67ee1d49-b1c2-4414-a52d-7df8f0542a00
# ╠═8461586f-23c9-47d0-95a2-e109a670bde4
# ╟─e8de1fbc-8034-406c-986c-a0a5e237ff18
# ╟─99ac4a30-cc0f-471c-8df0-4fb4b4b186bc
# ╠═77b70ebf-7f88-4c5b-b631-57f8fb9e1653
# ╟─b38306f0-61ea-4aa7-a522-d59e5c63db48
# ╟─50e9e7ca-26e8-4447-8778-19d0d3399c4f
# ╠═e6d385fb-72fd-4d95-9ec7-7534b9fcf6aa
