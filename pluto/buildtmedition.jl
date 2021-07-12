### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 136264c0-6f70-42bf-af25-1e3e733eae2d
begin
	using Pkg
	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")
	Pkg.add("EditionBuilders")
	Pkg.add(url="https://github.com/homermultitext/HmtTopicModels.jl")
	
	
	using CitableCorpus
	using CitableText
	using EditionBuilders
	using HmtTopicModels
	html"""
	<div class="nb">
	<ul>
	<li>Notebook version: <b>0.1.0</b></li>
	<li>Requires: Pluto (any version)</li>
	</ul>
	</div>
	"""
end

# ╔═╡ db87a2a8-27bf-489f-973c-82f27496c265
css = html"""

<style>
.nb {
font-size: smaller;
color: gray;
}
</style>
"""

# ╔═╡ 99b0f286-e348-11eb-0fa1-9bb0070569b5
md"# Build HMT topic modelling edition"

# ╔═╡ 0ffb9d97-7bf6-424f-821b-d5321264a53a
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-xml.cex"

# ╔═╡ 8e4febdb-3595-4fa4-bb5a-ffa67054d9ea
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 257bfd78-b457-4218-944a-3438cf54daca
tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "tm")

# ╔═╡ fee7a78b-b083-4f88-87de-01a1969f2768
ed = edition(tmbldr,c)

# ╔═╡ 2e77cc2b-1867-4415-85fa-e6982bbc2ffc
tmed = tmclean(ed, stops)

# ╔═╡ Cell order:
# ╟─136264c0-6f70-42bf-af25-1e3e733eae2d
# ╟─db87a2a8-27bf-489f-973c-82f27496c265
# ╟─99b0f286-e348-11eb-0fa1-9bb0070569b5
# ╟─0ffb9d97-7bf6-424f-821b-d5321264a53a
# ╠═8e4febdb-3595-4fa4-bb5a-ffa67054d9ea
# ╠═257bfd78-b457-4218-944a-3438cf54daca
# ╠═fee7a78b-b083-4f88-87de-01a1969f2768
# ╠═2e77cc2b-1867-4415-85fa-e6982bbc2ffc
