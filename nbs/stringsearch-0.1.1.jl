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

# ╔═╡ 5afb0b90-8be6-4e9b-b528-06f9e37cbda2
begin
	using CitableText
	using CitableCorpus
	using PlutoUI
	using Unicode
	
	md"""
	Notebook version: **0.1.1**
	"""
end

# ╔═╡ d6af67f1-2c5e-4ee4-a2a8-15f5e31b8c70
md"""Features to add:

- download results list
"""

# ╔═╡ 3621f458-e9bb-11eb-0fa3-b5c88b3c3081
md"""> # String search on text of HMT *scholia*
>
> - Search for strings in text of Lysias, ignoring accents and breathings
> - Choose to search full corpus of Lysias, or just Lysias 1.
"""

# ╔═╡ 81042b67-7892-4f2a-ac2d-19b21d47c410
md"""
"""

# ╔═╡ 0d293142-6e83-43be-a7a2-b410d53408ac
md"> Format delimited"

# ╔═╡ 9df7b364-5a92-4520-83d7-76f2ed1b0b8f
md"> Find and format results"

# ╔═╡ cb526052-9191-49c4-bf10-943efd411064
menu = ["all" => "All material in hmt-archive",
"allburney" => "All scholia in Burney 86",
"burney86" => "Main scholia of Burney 86",
"burney86il" => "Interlinear scholia of Burney 86",
"burney86im" => "Intermarginal scholia of Burney 86",
"burney86int" => "Interior scholia of Burney 86",
"allVA" => "All scholia in Venetus A",
"msA" => "Main scholia of Venetus A",
"msAim" => "Intermarginal scholia of Venetus A",
"msAint" => "Interior scholia of Venetus A",
"msAil" => "Interlinear scholia of Venetus A",
"msB" => "Scholia of Venetus B",
"e3" => "Scholia of Escorial, Upsilon 1.1",
]

# ╔═╡ e62b3d65-b836-4cb2-9999-22e677b84316
md"""Search for: $(@bind str TextField()) in $(@bind ms Select(menu))


"""

# ╔═╡ fa5bee63-f2e8-4edd-9333-0a3e3b4ec0c7
function nodesforMs(commentnodes)
	if ms == "all"
		commentnodes
	elseif ms == "allburney"
		filter(cn -> occursin("burney", cn.urn.urn), commentnodes)
	elseif ms == "allVA"
		filter(cn -> occursin("msA", cn.urn.urn), commentnodes)
	else
		filter(cn -> occursin(string(".",ms,"."), cn.urn.urn), commentnodes)
	end
end

# ╔═╡ 1f257171-b2ff-4072-a9f8-6cdc76b63aad
function formatmatch(term, txt)
	wrapped = replace(txt, term => """<span class="hilite">$term</span>""")
	string("<blockquote>", wrapped, "</blockquote>")
end

# ╔═╡ 233f2838-dd3b-4cda-beb1-6b5607c125e6
css = html"""
<style>
.hilite {
	background-color: yellow;
	font-weight: bold;
}
</style>
"""

# ╔═╡ e207f667-94c2-4f10-837b-bd8128941f8d
# Normalize search string for searching
srchstripped = Unicode.normalize(str; stripmark=true)

# ╔═╡ 33d2a232-67e4-49fb-89a0-7e68e5d84cde
md"> Load data"

# ╔═╡ 2b79c908-6b91-4cb4-bf46-4f971edfa061
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex"

# ╔═╡ d535fee1-ab32-404f-9d3f-f372093e772e
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 8c5e30ac-7583-45fd-8b80-2add7a0a3745
scholia = filter(cn -> contains(cn.urn.urn, "comment"), c.corpus)

# ╔═╡ 261b8169-3baa-47d2-be76-46b3a5c26e68
msselection = nodesforMs(scholia)

# ╔═╡ f1e8d031-5f7d-490f-a694-5a77d126c9db
msselection |> length

# ╔═╡ 5a3e200b-4fc1-4c28-bf13-68eaf9ba8854
scholia |> length

# ╔═╡ 3e7e7cc4-0bca-4f06-9222-2bdbdba8648e
stripped = begin
	map(cn -> CitableNode(cn.urn, lowercase(Unicode.normalize(cn.text; stripmark=true))),  msselection)
end

# ╔═╡ 47f10449-6cc2-42f1-a824-98a0e9385f69
# Find stripped nodes that match
rawmatch = begin
	if length(str) < 2
		nothing
		
	#=elseif lys1
		srchcorp = filter(cn -> startswith(workcomponent(cn.urn), "tlg0540.tlg001"), stripped)
		filter(cn -> occursin(srchstripped, cn.text), srchcorp)	
	=#	
	else
		filter(cn -> occursin(srchstripped, cn.text), stripped)	
	end
end

# ╔═╡ 255fabac-072c-46d9-95d4-c1f9ac8058d2
function delimited()
	if isnothing(rawmatch)
		""
	else
		lines = ["urn|text"]
		for nd in rawmatch
			push!(lines, string(nd.urn.urn, "|", nd.text))
		end
		join(lines,"\n")
	end
end

# ╔═╡ 318f3c0a-1930-43fd-824b-2354067329ab
begin
	if isnothing(rawmatch)
		md""
	else
		md"""Results:
- Search for *$(srchstripped)* matches **$(length(rawmatch))** "documents" in corpus of **$(length(msselection))**
- *Show passages*: $(@bind showme CheckBox(default=false)) *Save results*:  $(DownloadButton(delimited(), "searchmatches.csv")).
"""
	end
end


# ╔═╡ 040086af-2d82-46b1-a484-edf8f3b96040
# Find fully accented nodes corresponding to rawmatch
function matchingnodes()
	nodelist = []
	if isempty(str)
		
	else
		for nd in rawmatch
			matches = filter(cn -> cn.urn == nd.urn, c.corpus)
			if length(matches) != 1
				@warn("Something went wrong looking for $(cn.urn)")
				push!(nodelist, nothing)
			else
				push!(nodelist, matches[1])
			end
		end
	end
	nodelist
end

# ╔═╡ e5b7f3f0-ec6e-4bce-8cbb-9d485cfabbac
srcnodes = matchingnodes()

# ╔═╡ 4556f682-4783-4e81-a5f1-32ea88c27b27
function labelledpsg(num, nd)
	srcurn = nd.urn
	workparts = split(workcomponent(srcurn), ".")
	wknum = replace(workparts[2], r"tlg[0]+" => "")
	ref = collapsePassageBy(srcurn, 1) |> passagecomponent
#	ref = passagecomponent(srcurn)
		
	string("<p><b>", num, "</b>.  <i>", wknum, ", ", ref, "</i> ", srcnodes[num].text, "</p>\n")
	
end

# ╔═╡ 78bb6c66-fe2f-40db-9574-93fe11530b26
begin
	lines = []

	if isnothing(rawmatch)
		md""
		
	elseif showme
		for i in 1:length(rawmatch)
			push!(lines, labelledpsg(i, srcnodes[i]))		
			push!(lines, formatmatch(srchstripped, rawmatch[i].text))
			push!(lines, "<hr/>")
		end
		HTML(join(lines))
	else
		md""
	end
	
end

# ╔═╡ ee22e94e-3faa-4a6a-8853-fcb1c0ad1eb4
stripped |> length

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Unicode = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[compat]
CitableCorpus = "~0.3.0"
CitableText = "~0.9.0"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "9e62e66db34540a0c919d72172cc2f642ac71260"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "0.5.0"

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[CitableBase]]
deps = ["DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "e1edbddb151b18f8290b8f19e4310c369b01c049"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "1.2.2"

[[CitableCorpus]]
deps = ["CSV", "CitableText", "DataFrames", "DocStringExtensions", "Documenter", "HTTP", "Test", "TextAnalysis"]
git-tree-sha1 = "a0adc4d10424fa4e884cfaecdb4ee9f8a019fdcd"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.3.0"

[[CitableText]]
deps = ["BenchmarkTools", "CitableBase", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "3d95c0ceea520fae5248a6842026b99d6ca23356"
uuid = "41e66566-473b-49d4-85b7-da83b66615d8"
version = "0.9.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataDeps]]
deps = ["BinaryProvider", "HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "4f0e41ff461d42cfc62ff0de4f1cd44c6e6b3771"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.7"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "a19645616f37a2c2c3077a44bc0d3e73e13441d7"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.1"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Documenter]]
deps = ["Base64", "Dates", "DocStringExtensions", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "REPL", "Test", "Unicode"]
git-tree-sha1 = "3ebb967819b284dc1e3c0422229b58a40a255649"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.26.3"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[HTML_Entities]]
deps = ["StrTables"]
git-tree-sha1 = "c4144ed3bc5f67f595622ad03c0e39fa6c70ccc7"
uuid = "7693890a-d069-55fe-a829-b4a6d304f0ee"
version = "1.0.1"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "c6a1fff2fd4b1da29d3dccaffb1e1001244d844e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.12"

[[IOCapture]]
deps = ["Logging"]
git-tree-sha1 = "377252859f740c217b936cebcd918a44f9b53b59"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.1.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[Languages]]
deps = ["InteractiveUtils", "JSON"]
git-tree-sha1 = "b1a564061268ccc3f3397ac0982983a657d4dcb8"
uuid = "8ef0a80b-9436-5d2c-a485-80b904378c43"
version = "0.4.3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ffae887d0f0222a19c406a11c3831776d1383e3d"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.3"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Snowball]]
deps = ["Languages", "Snowball_jll", "WordTokenizers"]
git-tree-sha1 = "d38c1ff8a2fca7b1c65a51457dabebef28052399"
uuid = "fb8f903a-0164-4e73-9ffe-431110250c3b"
version = "0.1.0"

[[Snowball_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "35031519df40fbf0d4a6d2faae4f00e117b0ad11"
uuid = "88f46535-a3c0-54f4-998e-4320a1339f51"
version = "2.0.0+0"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2f6792d523d7448bbe2fec99eca9218f06cc746d"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.8"

[[StrTables]]
deps = ["Dates"]
git-tree-sha1 = "5998faae8c6308acc25c25896562a1e66a3bb038"
uuid = "9700d1a9-a7c8-5760-9816-a99fda30bb8f"
version = "1.0.1"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "8ed4a3ea724dac32670b062be3ef1c1de6773ae8"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.4.4"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TextAnalysis]]
deps = ["DataStructures", "DelimitedFiles", "JSON", "Languages", "LinearAlgebra", "Printf", "ProgressMeter", "Random", "Serialization", "Snowball", "SparseArrays", "Statistics", "StatsBase", "Tables", "WordTokenizers"]
git-tree-sha1 = "bc85e54209c30e69e1925460ec0257a916683f59"
uuid = "a2db99b7-8b79-58f8-94bf-bbc811eef33d"
version = "0.7.3"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[WordTokenizers]]
deps = ["DataDeps", "HTML_Entities", "StrTables", "Unicode"]
git-tree-sha1 = "01dd4068c638da2431269f49a5964bf42ff6c9d2"
uuid = "796a5d58-b03d-544a-977e-18100b691f6e"
version = "0.5.6"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─5afb0b90-8be6-4e9b-b528-06f9e37cbda2
# ╟─d6af67f1-2c5e-4ee4-a2a8-15f5e31b8c70
# ╟─3621f458-e9bb-11eb-0fa3-b5c88b3c3081
# ╟─e62b3d65-b836-4cb2-9999-22e677b84316
# ╟─318f3c0a-1930-43fd-824b-2354067329ab
# ╟─81042b67-7892-4f2a-ac2d-19b21d47c410
# ╟─78bb6c66-fe2f-40db-9574-93fe11530b26
# ╟─0d293142-6e83-43be-a7a2-b410d53408ac
# ╟─255fabac-072c-46d9-95d4-c1f9ac8058d2
# ╟─9df7b364-5a92-4520-83d7-76f2ed1b0b8f
# ╟─cb526052-9191-49c4-bf10-943efd411064
# ╟─261b8169-3baa-47d2-be76-46b3a5c26e68
# ╟─f1e8d031-5f7d-490f-a694-5a77d126c9db
# ╟─fa5bee63-f2e8-4edd-9333-0a3e3b4ec0c7
# ╟─1f257171-b2ff-4072-a9f8-6cdc76b63aad
# ╟─4556f682-4783-4e81-a5f1-32ea88c27b27
# ╟─233f2838-dd3b-4cda-beb1-6b5607c125e6
# ╟─e207f667-94c2-4f10-837b-bd8128941f8d
# ╟─040086af-2d82-46b1-a484-edf8f3b96040
# ╟─e5b7f3f0-ec6e-4bce-8cbb-9d485cfabbac
# ╟─47f10449-6cc2-42f1-a824-98a0e9385f69
# ╟─33d2a232-67e4-49fb-89a0-7e68e5d84cde
# ╟─2b79c908-6b91-4cb4-bf46-4f971edfa061
# ╟─d535fee1-ab32-404f-9d3f-f372093e772e
# ╟─8c5e30ac-7583-45fd-8b80-2add7a0a3745
# ╟─5a3e200b-4fc1-4c28-bf13-68eaf9ba8854
# ╟─3e7e7cc4-0bca-4f06-9222-2bdbdba8648e
# ╟─ee22e94e-3faa-4a6a-8853-fcb1c0ad1eb4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
