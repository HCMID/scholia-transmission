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
	
	
	Pkg.add("CitableText")
	using CitableText
	
	Pkg.add("TopicModelsVB")
	using TopicModelsVB
	
	Pkg.add("DataFrames")
	using DataFrames
	
	Pkg.add("HTTP")
	using HTTP
	
	Pkg.add("Markdown")
	using Markdown
	

	md"""
	Notebook version:  **0.4.0**
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

# ╔═╡ dd90da00-a92e-4d1a-a572-d148154d140b
md"> ### Settings"

# ╔═╡ f022ea86-0cc1-4bbb-a1ea-8dd24b5351cf
alarm(text, label) = Markdown.MD(Markdown.Admonition("warn", label, [text]))

# ╔═╡ 9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
md"**Iterations to train**: $(@bind  iterations NumberField(15:150; default=40))"

# ╔═╡ dd87550c-6b02-404a-8c56-dbf80f22d91f
md"> ### Results"

# ╔═╡ 15da696a-1fe4-40a4-9a92-88e08a8e49b5
md"**Words to show for each topic**: $(@bind  wordstoshow NumberField(4:30; default=10))"

# ╔═╡ c72fab11-3b8f-49f1-9693-60e8dce883bf
md">### Downloadable data"

# ╔═╡ 8dcf39c4-9cb9-446c-8d56-48b410ad1f06
md"> Functions formatting data for download as delimited files"

# ╔═╡ a0e97706-3ef5-4fa6-87b4-1b3f991a581e
# Compose document-topic matrix
function doctopiccsv(themodel)
	lines = []
	for i in 1:length(themodel.corp)
		scores = topicdist(themodel, i)
		withdoc = push!(scores, i)
		push!(lines, join(scores,","))
	end
	join(lines, "\n") * "\n"
end


# ╔═╡ 299e325f-3b8c-4823-babb-895c8a422d5a
# Compose dictionary of term IDs to strings
function vocabcsv(vocabdict)
	lines = []
	for k in keys(vocabdict)
		push!(lines, string(k, ",", vocabdict[k]))
	end
	join(lines, "\n") * "\n"
		
end

# ╔═╡ 1e3f6da0-f435-4923-a0e3-203bb378c317
# Format topic-vocabulary matrix as CSV
function topicscsv(tpcs)
	lines = []
	
	for row in 1:length(tpcs)
		cells = []
		for col in 1:length(tpcs[row])
			push!(cells, tpcs[row][col])
		end
		push!(lines, join(cells, ","))
	end
	
	join(lines, "\n") * "\n"
end

# ╔═╡ bf888348-9a5c-435a-a9c1-724fce2b795c
md"> Display topic-term summaries"

# ╔═╡ 679359f2-5d7e-4cd2-b809-c7a7bbada1c7
md"> Make a queryable DataFrame for document-topic scores"

# ╔═╡ f39b668c-d883-4425-bf37-25ed23594645
# Given a model, create a matrix of topic scores for each document
function doctopicmatrix(themodel)
    scores = []
    for i in 1:length(themodel.corp)
        docscores = topicdist(themodel, i)
        push!(docscores, i)
        push!(scores, docscores)
    end

    dim1 = length(scores)
    dim2 = length(scores[1])
    matrixvals = zeros(Float64, dim1, dim2)
    for i in 1:dim1
        for j in 1:dim2
            matrixvals[i,j] = scores[i][j]
        end
    end
    matrixvals
end

# ╔═╡ 4a8ce796-f3ce-4958-9b2c-593c0d370572
md"> Load citable corpus, and convert to model for topic modeling"

# ╔═╡ e6405518-efb3-4911-9ca3-a42c0c36ad90
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingedition.cex"

# ╔═╡ b465f1be-29b8-40f4-96cd-b40c3ab3d326
tmed = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 0c26d794-0a06-4ad0-a244-21ff1c520d18
tmed.corpus |> length

# ╔═╡ 1b0e2cda-7efa-4c92-a274-dad8d43d8e8c
md"> Allow user to select subcorpus by MS"

# ╔═╡ c58eae56-1900-4239-a689-2b78d7c075c0
bklist = ["1-24","8 only","8-10"]

# ╔═╡ 61effa85-7d7e-43a3-a31c-d3e73c7f5bfb
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

# ╔═╡ 999e5a15-2104-460e-9429-6390a88d2c62
md"**Number of topics to model**: $(@bind  k NumberField(3:30; default=10)) **Manuscript**: $(@bind ms Select(menu)) **Books**: $(@bind books Select(bklist))"

# ╔═╡ 555bab88-808e-487b-8441-9aa2ad3f4309
md"""
Results of modeling $k topics after $iterations iterations: top $wordstoshow words for each topic.

 
"""

# ╔═╡ fd0477cf-3f27-432b-a7ed-366b33c88143
begin
	choices = map(i -> string(i), collect(1:k))
	md"""
Topic to highlight:  $(@bind hltopic Select(choices))
Display top $(@bind doccount NumberField(1:20; default=0)) documents.
"""
end

# ╔═╡ 3fbe0f4e-2b9f-46e2-86cf-0db411e2b123
# Column beyond last topic indexes the document
docidx = k + 1	

# ╔═╡ 5b0c26d2-29ff-42d2-a7f7-82ee46b1ec8f
function nodesforBooks(commentnodes)
	if books == "1-24"
		commentnodes
	elseif books == "8 only"
		filter(cn -> startswith(passagecomponent(cn.urn), "8"), commentnodes)
	elseif books == "8-10"
		filter(cn -> startswith(passagecomponent(cn.urn), r"[89]|10"), commentnodes)
	end
end

# ╔═╡ f4978ab6-76c6-4dc3-bf30-41f065bdbee2
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

# ╔═╡ ac59e282-1cf6-457d-89a3-175a4cba6fbb
msselection =  begin
	msnodelist = nodesforMs(tmed.corpus)
	nodesforBooks(msnodelist) |> CitableTextCorpus
end


# ╔═╡ 8652843f-65eb-4a42-ae81-a9aec0acef49
tmcorp = tmcorpus(msselection)

# ╔═╡ 4b840632-0ef4-490f-a9e8-c95184ca7e59
model = LDA(tmcorp, k)

# ╔═╡ 3bd93907-4ab4-4c12-8867-b9f8db27ad4b
train!(model, iter=iterations, tol=0)

# ╔═╡ 4808a47f-c73e-4590-b6ba-db105ed1f8d1
# Compose ordered list of top vocab items for a given topic
function topvocab(topicno)
	tpc = model.topics[topicno]
	toplist = []
	for i in 1:wordstoshow
		wdix = model.topics[topicno][i]
		#push!(toplist, model.corp.vocab[model.topics[topicno][tpc[i]])
		push!(toplist, model.corp.vocab[wdix])
	end
	toplist	
end

# ╔═╡ f7cc2b56-a604-47ac-9d1a-272f50e94415
# Compose CSV summary of topics with top terms
function summariescsv()
	lines = []
	for i in 1:k
		vocablist = string(i, ",", join(topvocab(i),","))
		push!(lines, vocablist)
	end
	join(lines,"\n") * "\n"
end

# ╔═╡ d6968676-c537-482d-a5b8-f3e7c413470a
md"""
- *Topic summaries* $(DownloadButton(summariescsv(), "topics-vocab.csv")). Top terms for each topic (so here $wordstoshow terms per topic).
- *Topic-vocabulary matrix* $(DownloadButton(topicscsv(model.topics), "topics-vocab.csv")).  Each topic is scored on each vocabulary item (*term*) in the corpus (so here, $k rows with $(length(model.corp.vocab)) columns).
- *Vocabulary index* $(DownloadButton(vocabcsv(model.corp.vocab), "vocab.csv")).  Index of numeric keys to vocabulary item (*term*) (so here, $(length(model.corp.vocab)) number-string pairs).
- *Document-topic matrix*  $(DownloadButton(doctopiccsv(model), "docs-topics.csv")).  Each document is scored on each topic (so here, $(length(model.corp.docs)) rows with $k columns).


"""

# ╔═╡ 2adb833d-1cc4-45b1-82cc-78a329ac73fe
function htmlrow(termlist)
	cells = []
	for t in termlist
		push!(cells, string("<td>",model.corp.vocab[t],"</td>"))
	end
	string(join(cells))
end

# ╔═╡ 87701aa4-e99f-402d-b0de-8f51de2ee431
begin
	
	hdg = ["<th>-</th>"]
	for wdcount in 1:wordstoshow
		push!(hdg, string("<th>word ", wdcount, "</th>"))
	end
	hdgrow = string("<tr>", join(hdg), "</tr>")
	

	rows = [hdgrow]
	for i in 1:length(model.topics)
		row = []
		for j in 1:wordstoshow
			wdidx = model.topics[i][j]
			push!(row, htmlrow(wdidx))
		end
		push!(rows, string("<tr>", "<th> Topic ", i, "</th>", join(row), "</tr>"))
	end
	join(rows)
	HTML(string("<table>", join(rows), "</table>"))
end

# ╔═╡ 7142097c-3cfd-4281-a668-5df7419b2cbd
# Look up weight of given document
function docwt(docid)
	wts = topicdist(model, docid)
	wts[parse(Int64,hltopic)]
end

# ╔═╡ 2484def8-c908-4c19-8b14-f4a89279f081
# Create an easily sorted DataFrame for the doc-topic matrix,
# using auto-generated column names
doctopicdf = begin
	 DataFrame(doctopicmatrix(model), :auto)
end


# ╔═╡ eaa66257-7ef0-4482-b922-36416b1c460e
# Sort document-topic matrix by 
sortedscores = sort(doctopicdf, parse(Int64,hltopic), rev = true)

# ╔═╡ f90e24b7-6d41-4cec-afbc-8d87b263cf21
nrow(doctopicdf)

# ╔═╡ b6bba209-c5a6-405d-acf3-d075438680a6
md"> Load normalized text to display for easier reading"

# ╔═╡ 82d5e94d-af0a-4cf7-8969-144dbada012a
md"This is the parallel normalized texts (accents, breathings, no stop words eliminated).  We can use that to display a more legible passage when we want to evaluate what documents scored high or low for particular topics."

# ╔═╡ 0aa818b4-b007-4c83-a267-b67b6caaa32a
srctexturl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingsource.cex"

# ╔═╡ 3df43298-5112-4325-af5c-9a7e6e0afdef
srccorp = CitableCorpus.fromurl(CitableTextCorpus,srctexturl, "|")

# ╔═╡ d15fe2c1-9ef9-45db-85fb-12c9b89d4f1c
srcselection =  begin
	srcnodelist = nodesforMs(srccorp.corpus)
	nodesforBooks(srcnodelist) |> CitableTextCorpus
end

# ╔═╡ 15088ec6-5be1-4eb5-b01a-81af28322a43
begin
	if length(model.corp.docs) != length(srcselection.corpus)
	md"""
Modeling corpus with $(length(model.corp.docs)) *documents* containing $(length(model.corp.vocab)) distinct *terms*.

(**!! Parallel corpus of source texts has $(length(srcselection.corpus)) documents**.)"""
	
else
md"""
Modeling corpus with $(length(model.corp.docs)) *documents* containing $(length(model.corp.vocab)) distinct *terms*.

"""
end
end

# ╔═╡ 8bc57e73-244c-4ea0-b41b-a013fcda6baf
begin
	if length(model.corp.docs) != length(srcselection.corpus)
		
	alarm(md"""Discrepancies between topic modelling edition  and source text passages""","Error")
		
	else
		md""
	end
end

# ╔═╡ a7307747-ce6c-4bd9-ab4d-3d5d682af761
begin
	doctext = []
	for i in 1:doccount

		doc = Int(sortedscores[i, docidx])
		u = srcselection.corpus[doc].urn
		wkparts  = split(workcomponent(u),".")
		push!(doctext,"\n**$i** document `$doc` weight $(docwt(doc)) `$(msselection.corpus[doc].text)` \n\n   **$(wkparts[2]) $(passagecomponent(u))** $(srcselection.corpus[doc].text) \n\n---\n\n")
		#push!(doctext,"1. `$doc` $(sourcelines[doc])")
	end
	mdlist = join(doctext,"\n")
	Markdown.parse(mdlist)

end

# ╔═╡ 946c2ffb-c2fe-4279-9e86-18ce3654db5f
md"Debug topics display"

# ╔═╡ e232a0ef-5473-4708-b50f-4f1f43ebee33
with_terminal() do
	#showtopics(model, cols=k, wordstoshow)
end

# ╔═╡ Cell order:
# ╟─7ed58b4c-e646-11eb-1526-4b56470a3b62
# ╟─1876658c-302e-48ad-947e-099a23472e32
# ╟─57134c2e-c646-4ec4-bb15-eb1298ca35da
# ╟─550c4d2d-7c47-4f56-8bc9-f4708ef9aa83
# ╟─dd90da00-a92e-4d1a-a572-d148154d140b
# ╟─999e5a15-2104-460e-9429-6390a88d2c62
# ╟─4b840632-0ef4-490f-a9e8-c95184ca7e59
# ╟─15088ec6-5be1-4eb5-b01a-81af28322a43
# ╟─8bc57e73-244c-4ea0-b41b-a013fcda6baf
# ╠═f022ea86-0cc1-4bbb-a1ea-8dd24b5351cf
# ╟─9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
# ╠═3bd93907-4ab4-4c12-8867-b9f8db27ad4b
# ╟─dd87550c-6b02-404a-8c56-dbf80f22d91f
# ╟─15da696a-1fe4-40a4-9a92-88e08a8e49b5
# ╟─555bab88-808e-487b-8441-9aa2ad3f4309
# ╟─87701aa4-e99f-402d-b0de-8f51de2ee431
# ╟─fd0477cf-3f27-432b-a7ed-366b33c88143
# ╟─a7307747-ce6c-4bd9-ab4d-3d5d682af761
# ╟─c72fab11-3b8f-49f1-9693-60e8dce883bf
# ╟─d6968676-c537-482d-a5b8-f3e7c413470a
# ╟─8dcf39c4-9cb9-446c-8d56-48b410ad1f06
# ╟─4808a47f-c73e-4590-b6ba-db105ed1f8d1
# ╟─f7cc2b56-a604-47ac-9d1a-272f50e94415
# ╟─a0e97706-3ef5-4fa6-87b4-1b3f991a581e
# ╟─299e325f-3b8c-4823-babb-895c8a422d5a
# ╟─1e3f6da0-f435-4923-a0e3-203bb378c317
# ╟─bf888348-9a5c-435a-a9c1-724fce2b795c
# ╟─2adb833d-1cc4-45b1-82cc-78a329ac73fe
# ╟─679359f2-5d7e-4cd2-b809-c7a7bbada1c7
# ╟─7142097c-3cfd-4281-a668-5df7419b2cbd
# ╟─3fbe0f4e-2b9f-46e2-86cf-0db411e2b123
# ╟─eaa66257-7ef0-4482-b922-36416b1c460e
# ╟─f90e24b7-6d41-4cec-afbc-8d87b263cf21
# ╟─2484def8-c908-4c19-8b14-f4a89279f081
# ╟─f39b668c-d883-4425-bf37-25ed23594645
# ╟─4a8ce796-f3ce-4958-9b2c-593c0d370572
# ╟─e6405518-efb3-4911-9ca3-a42c0c36ad90
# ╟─b465f1be-29b8-40f4-96cd-b40c3ab3d326
# ╟─0c26d794-0a06-4ad0-a244-21ff1c520d18
# ╠═8652843f-65eb-4a42-ae81-a9aec0acef49
# ╟─1b0e2cda-7efa-4c92-a274-dad8d43d8e8c
# ╟─ac59e282-1cf6-457d-89a3-175a4cba6fbb
# ╟─5b0c26d2-29ff-42d2-a7f7-82ee46b1ec8f
# ╟─f4978ab6-76c6-4dc3-bf30-41f065bdbee2
# ╟─c58eae56-1900-4239-a689-2b78d7c075c0
# ╟─61effa85-7d7e-43a3-a31c-d3e73c7f5bfb
# ╟─b6bba209-c5a6-405d-acf3-d075438680a6
# ╟─82d5e94d-af0a-4cf7-8969-144dbada012a
# ╟─0aa818b4-b007-4c83-a267-b67b6caaa32a
# ╠═3df43298-5112-4325-af5c-9a7e6e0afdef
# ╟─d15fe2c1-9ef9-45db-85fb-12c9b89d4f1c
# ╟─946c2ffb-c2fe-4279-9e86-18ce3654db5f
# ╟─e232a0ef-5473-4708-b50f-4f1f43ebee33
