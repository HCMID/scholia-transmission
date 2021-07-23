### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ e14c020a-eb47-11eb-0383-d50478d76115
begin
	using Pkg
	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")
	Pkg.add("CitableObject")
	Pkg.add("CSV")
	Pkg.add("DataFrames")
	Pkg.add("HTTP")
	Pkg.add(url="https://github.com/homermultitext/HmtTopicModels.jl")
	using CitableCorpus
	using CitableObject
	using CitableText
	using CSV
	using DataFrames
	using HTTP
	using HmtTopicModels
	
	md"""
Notebook version: unreleased	
"""	
end

# ╔═╡ 9335f874-c317-4f7f-a715-9c0847186d59
md"> # Compute latest century date (TPQ) for each *scholion*"

# ╔═╡ 93e8cbe9-a613-479d-b837-1a32b71b61e0
md"> Load personal name data"

# ╔═╡ be2fab10-1382-4396-8004-93296394d0c0
pnids = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/pnvalues.txt"

# ╔═╡ b87ea60c-72af-43f6-813c-189481dd8499
authlist = persname_df()

# ╔═╡ d24dcb7b-4306-4ec4-a497-92cbd23d4096
pns_df = CSV.File(HTTP.get(pnids).body) |> DataFrame

# ╔═╡ ee0e3581-9852-4c79-9327-9e7c390d3baa
urnlist = map(s -> Cite2Urn(s), pns_df[:,:urn])

# ╔═╡ 43513298-06c1-445e-94c9-7f4cba9f4573
abbrlist = map(u -> labelledshortform(u,authlist), urnlist)

# ╔═╡ a8fd66d0-2771-42c0-99e2-f6c0c97bfd52
md"> Load text corpus"

# ╔═╡ 21963719-fd70-46a0-a6dd-b46b64dc86d6
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingedition.cex"

# ╔═╡ 7ef40010-3cdc-4699-8c2a-dc13a366bdb5
tmed = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 5581f9fb-dc37-45b7-b307-6a949c4c731e
# Comment nodes from all HMT scholia
tmscholia = filter(cn -> occursin("comment", cn.urn.urn),  tmed.corpus)

# ╔═╡ a2e77b01-3416-479f-ac4a-110e962fba38
begin
	pns = []
	for cn in tmscholia
		wds = split(cn.text)
		pnids = filter(wd -> wd in abbrlist, wds)
		if isempty(pnids)
			push!(pns, nothing)
		else
			push!(pns, pnids)
		end
	end
	pns
end

# ╔═╡ cb3d4cfd-158a-4204-8138-5b9b8c04ef0f
pnlist = begin
	pnmap = []
	for cn in tmscholia
		wds = split(cn.text)
		pns = filter(w -> startswith(w, "perspers"), wds)
		if isempty(pns)
			push!(pnmap, (cn.urn, nothing))
		else
			push!(pnmap, (cn.urn, pns))
		end
	end
	pnmap
end

# ╔═╡ Cell order:
# ╟─e14c020a-eb47-11eb-0383-d50478d76115
# ╟─9335f874-c317-4f7f-a715-9c0847186d59
# ╠═a2e77b01-3416-479f-ac4a-110e962fba38
# ╟─93e8cbe9-a613-479d-b837-1a32b71b61e0
# ╟─cb3d4cfd-158a-4204-8138-5b9b8c04ef0f
# ╠═ee0e3581-9852-4c79-9327-9e7c390d3baa
# ╠═43513298-06c1-445e-94c9-7f4cba9f4573
# ╟─be2fab10-1382-4396-8004-93296394d0c0
# ╠═b87ea60c-72af-43f6-813c-189481dd8499
# ╟─d24dcb7b-4306-4ec4-a497-92cbd23d4096
# ╠═a8fd66d0-2771-42c0-99e2-f6c0c97bfd52
# ╟─21963719-fd70-46a0-a6dd-b46b64dc86d6
# ╟─7ef40010-3cdc-4699-8c2a-dc13a366bdb5
# ╟─5581f9fb-dc37-45b7-b307-6a949c4c731e
