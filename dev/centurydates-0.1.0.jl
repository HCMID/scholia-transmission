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
	Pkg.add("PlutoUI")
	Pkg.add(url="https://github.com/homermultitext/HmtTopicModels.jl")
	using CitableCorpus
	using CitableObject
	using CitableText
	using CSV
	using DataFrames
	using HTTP
	using PlutoUI
	using HmtTopicModels
	
	md"""
Notebook version: unreleased	
"""	
end

# ╔═╡ 9335f874-c317-4f7f-a715-9c0847186d59
md"""> # Compute latest century date (TPQ) for each *scholion*
>
> Find datable personal names in each scholion, and select most recent date.
>
> Labelled sections of this notebook:
> 1. Load personal name data, and convert URNs to the short form used in our topic modelling edition
> 2. Load the topic modelling text corpus, and throw away all text except datable personal names
"""

# ╔═╡ 9c567c6f-92f2-4d2a-8ced-93e63c0059e4
md"Look at scholia and choose latest date."

# ╔═╡ 0c5d4d9c-5118-45c0-a366-383335679e35
md">Compute integer value for century"

# ╔═╡ 7e0a2d7f-4e42-4f04-8c88-3984cc3bcf49
md"Debug: here are the key names downloaded our dates list."

# ╔═╡ 93e8cbe9-a613-479d-b837-1a32b71b61e0
md"> Load personal name authority list"

# ╔═╡ dd8fec7d-2e11-4134-9b52-f34fa794a227
md"Load data from URL into a DataFrame"

# ╔═╡ be2fab10-1382-4396-8004-93296394d0c0
pnids = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/pnvalues.txt"

# ╔═╡ b87ea60c-72af-43f6-813c-189481dd8499
authlist = persname_df()

# ╔═╡ 0dbef444-de8e-411b-975e-21675a43dabe
md"> Load data for century assigned to datable persons"

# ╔═╡ d24dcb7b-4306-4ec4-a497-92cbd23d4096
datablepeople = CSV.File(HTTP.get(pnids).body) |> DataFrame

# ╔═╡ ccc10a45-835b-40dd-9a75-bf9c96c50a14
# Compose a dictionary of abbreivated person IDs to centuries (integers)
datesdictionary = begin
	urndict = Dict()
	for r in eachrow(datablepeople)
		u = Cite2Urn(r.urn)
		abbr = labelledshortform(u, authlist)
		urndict[abbr] = r.century
	end
	urndict
end


# ╔═╡ 655ca69d-4337-4333-9438-48dd1e7f727e
function mostrecent(nameslist)
	centuries = map(n -> datesdictionary[n], nameslist)
	maximum(centuries)
end

# ╔═╡ fc91b59d-5179-4527-b8bd-1e3f6ee72c5b
keys(datesdictionary)

# ╔═╡ 6cceeb4d-11a6-4d5b-b420-ba60edc95fce
md"Convert strings to `Cite2Urn`s, then convert those to the abbreviated form used in our topic modeling corpus"

# ╔═╡ ee0e3581-9852-4c79-9327-9e7c390d3baa
urnlist = map(s -> Cite2Urn(s), datablepeople[:,:urn])

# ╔═╡ 43513298-06c1-445e-94c9-7f4cba9f4573
abbrlist = map(u -> labelledshortform(u,authlist), urnlist)

# ╔═╡ a8fd66d0-2771-42c0-99e2-f6c0c97bfd52
md"> Load text corpus and reduced text to include only datable personal names"

# ╔═╡ 21963719-fd70-46a0-a6dd-b46b64dc86d6
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingedition.cex"

# ╔═╡ 7ef40010-3cdc-4699-8c2a-dc13a366bdb5
tmed = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 5581f9fb-dc37-45b7-b307-6a949c4c731e
# Comment nodes from all HMT scholia
tmscholia = filter(cn -> occursin("comment", cn.urn.urn),  tmed.corpus)

# ╔═╡ a2e77b01-3416-479f-ac4a-110e962fba38
peopleperscholion = begin
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

# ╔═╡ 166fa299-bd62-4f5d-9639-f13b1d2fd6cf
datesperscholion = begin
	tpqlist = []
	for sch in peopleperscholion
		if isnothing(sch)
			push!(tpqlist, nothing)
		else
			
			push!(tpqlist, mostrecent(sch))
		end
	end
	tpqlist
end

# ╔═╡ 8c5c9c53-209e-4c66-a648-cf5ff37f6172
begin
	numdated = filter(sch -> ! isnothing(sch), peopleperscholion) |> length
	allseen = length(datesperscholion) == length(tmscholia)
	numscholia = length(tmscholia)
	md"""(We evaluted $numscholia scholia. Did we compute a date value for every scholion in our corpus?  $allseen)

We found **$numdated** scholia with datable personal names out of **$numscholia** scholia.
"""	
end

# ╔═╡ ad4e1207-89d0-49a2-b868-55c98244b8e3
md"""Download: $(DownloadButton(join(datesperscholion,"\n"), "centuries.txt"))
"""

# ╔═╡ Cell order:
# ╟─e14c020a-eb47-11eb-0383-d50478d76115
# ╟─9335f874-c317-4f7f-a715-9c0847186d59
# ╟─8c5c9c53-209e-4c66-a648-cf5ff37f6172
# ╟─9c567c6f-92f2-4d2a-8ced-93e63c0059e4
# ╟─0c5d4d9c-5118-45c0-a366-383335679e35
# ╟─ad4e1207-89d0-49a2-b868-55c98244b8e3
# ╟─166fa299-bd62-4f5d-9639-f13b1d2fd6cf
# ╟─655ca69d-4337-4333-9438-48dd1e7f727e
# ╟─7e0a2d7f-4e42-4f04-8c88-3984cc3bcf49
# ╟─fc91b59d-5179-4527-b8bd-1e3f6ee72c5b
# ╟─93e8cbe9-a613-479d-b837-1a32b71b61e0
# ╟─dd8fec7d-2e11-4134-9b52-f34fa794a227
# ╟─be2fab10-1382-4396-8004-93296394d0c0
# ╟─b87ea60c-72af-43f6-813c-189481dd8499
# ╟─0dbef444-de8e-411b-975e-21675a43dabe
# ╟─d24dcb7b-4306-4ec4-a497-92cbd23d4096
# ╟─ccc10a45-835b-40dd-9a75-bf9c96c50a14
# ╟─6cceeb4d-11a6-4d5b-b420-ba60edc95fce
# ╠═ee0e3581-9852-4c79-9327-9e7c390d3baa
# ╠═43513298-06c1-445e-94c9-7f4cba9f4573
# ╟─a8fd66d0-2771-42c0-99e2-f6c0c97bfd52
# ╟─21963719-fd70-46a0-a6dd-b46b64dc86d6
# ╟─7ef40010-3cdc-4699-8c2a-dc13a366bdb5
# ╟─5581f9fb-dc37-45b7-b307-6a949c4c731e
# ╟─a2e77b01-3416-479f-ac4a-110e962fba38
