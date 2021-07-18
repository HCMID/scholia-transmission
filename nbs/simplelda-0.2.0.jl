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
	
	Pkg.add("DataFrames")
	using DataFrames
	
	
	Pkg.add("Markdown")
	using Markdown
	
	md"""
	Notebook version:  **0.2.0**
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

# ╔═╡ 999e5a15-2104-460e-9429-6390a88d2c62
md"**Number of topics**: $(@bind  k NumberField(3:30; default=10))"

# ╔═╡ 9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
md"**Iterations to train**: $(@bind  iterations NumberField(15:150; default=40))"

# ╔═╡ 15da696a-1fe4-40a4-9a92-88e08a8e49b5
md"**Words to show for each topic**: $(@bind  wordstoshow NumberField(4:30; default=10))"

# ╔═╡ 555bab88-808e-487b-8441-9aa2ad3f4309
md"""
Results of modeling $k topics after $iterations iterations: top $wordstoshow words for each topic
 

"""

# ╔═╡ fd0477cf-3f27-432b-a7ed-366b33c88143
begin
	choices = map(i -> string(i), collect(1:k))
	md"""
Topic to highlight:  $(@bind hltopic Select(choices))
Display top $(@bind doccount NumberField(1:20; default=3)) documents.
"""
end

# ╔═╡ c72fab11-3b8f-49f1-9693-60e8dce883bf
md">Downloadable data"

# ╔═╡ 8dcf39c4-9cb9-446c-8d56-48b410ad1f06
md"> Functions formatting data for download as delimited files"

# ╔═╡ 38cb5b0d-cae5-4b65-bc2b-647eb3cd69ae
function covarcsv(covarvals)
	"here"
end

# ╔═╡ a0e97706-3ef5-4fa6-87b4-1b3f991a581e
function doctopiccsv(themodel)
	lines = []
	for i in 1:length(themodel.corp)
		scores = topicdist(themodel, i)
		withdoc = push!(scores, i)
		push!(lines, join(scores,","))
	end
	
	#=
	for doc in 1:length(gammas)
		line = []
		for tpc in 1:k
			push!(line, gammas[doc][tpc])
		end
		push!(lines, join(line, ","))
	end
	=#
	join(lines, "\n") * "\n"

end


# ╔═╡ 299e325f-3b8c-4823-babb-895c8a422d5a
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

# ╔═╡ 679359f2-5d7e-4cd2-b809-c7a7bbada1c7
md"> Make a queryable DataFrame for doc-topic scores"

# ╔═╡ 3fbe0f4e-2b9f-46e2-86cf-0db411e2b123
# Column beyond last topic indexes the document
docidx = k + 1	

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

# ╔═╡ 8652843f-65eb-4a42-ae81-a9aec0acef49
tmcorp = tmcorpus(tmed)

# ╔═╡ 4b840632-0ef4-490f-a9e8-c95184ca7e59
model = LDA(tmcorp, k)

# ╔═╡ 15088ec6-5be1-4eb5-b01a-81af28322a43
md"""
Modeling corpus with $(length(model.corp.docs)) *documents* containing $(length(model.corp.vocab)) distinct *terms*.
"""

# ╔═╡ 3bd93907-4ab4-4c12-8867-b9f8db27ad4b
train!(model, iter=iterations, tol=0)

# ╔═╡ e232a0ef-5473-4708-b50f-4f1f43ebee33
with_terminal() do
	showtopics(model, cols=k, wordstoshow)
end

# ╔═╡ 4808a47f-c73e-4590-b6ba-db105ed1f8d1
# Ordered list of top vocab items for a given topic
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
- *Topic summaries* $(DownloadButton(summariescsv(), "topics-vocab.csv")). Top $wordstoshow terms for each topic.
- *Topic-vocabulary matrix* $(DownloadButton(topicscsv(model.topics), "topics-vocab.csv")).  Each topic is scored on each vocabulary item (*term*) in the corpus (so here, $k rows with $(length(model.corp.vocab)) columns).
- *Vocabulary index* $(DownloadButton(vocabcsv(model.corp.vocab), "vocab.csv")).  Index of numeric keys to vocabulary item (*term*) (so here, $(length(model.corp.vocab)) number-string pairs).
- *Document-topic matrix*  $(DownloadButton(doctopiccsv(model), "docs-topics.csv")).  Each document is scored on each topic (so here, $(length(model.corp.docs)) rows with $k columns).
- *Covariance matrix*

"""

# ╔═╡ 2484def8-c908-4c19-8b14-f4a89279f081
# Create an easily sorted DataFrame for the doc-topic matrix,
# using auto-generated column names
doctopicdf = begin
	 DataFrame(doctopicmatrix(model), :auto)
end


# ╔═╡ eaa66257-7ef0-4482-b922-36416b1c460e
# Sort document-topic matrix by 
sortedscores = sort(doctopicdf, parse(Int64,hltopic), rev = true)

# ╔═╡ a7307747-ce6c-4bd9-ab4d-3d5d682af761
begin
	doctext = []
	for i in 1:doccount

		doc = Int(sortedscores[i, docidx])
		push!(doctext,"1. $doc $(tmed.corpus[doc].text)")
	end
	mdlist = join(doctext,"\n")
	Markdown.parse(mdlist)

end

# ╔═╡ Cell order:
# ╟─7ed58b4c-e646-11eb-1526-4b56470a3b62
# ╟─1876658c-302e-48ad-947e-099a23472e32
# ╟─57134c2e-c646-4ec4-bb15-eb1298ca35da
# ╟─550c4d2d-7c47-4f56-8bc9-f4708ef9aa83
# ╟─999e5a15-2104-460e-9429-6390a88d2c62
# ╟─4b840632-0ef4-490f-a9e8-c95184ca7e59
# ╟─15088ec6-5be1-4eb5-b01a-81af28322a43
# ╟─9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
# ╠═3bd93907-4ab4-4c12-8867-b9f8db27ad4b
# ╠═15da696a-1fe4-40a4-9a92-88e08a8e49b5
# ╟─555bab88-808e-487b-8441-9aa2ad3f4309
# ╟─e232a0ef-5473-4708-b50f-4f1f43ebee33
# ╟─fd0477cf-3f27-432b-a7ed-366b33c88143
# ╟─a7307747-ce6c-4bd9-ab4d-3d5d682af761
# ╟─c72fab11-3b8f-49f1-9693-60e8dce883bf
# ╟─d6968676-c537-482d-a5b8-f3e7c413470a
# ╟─8dcf39c4-9cb9-446c-8d56-48b410ad1f06
# ╟─4808a47f-c73e-4590-b6ba-db105ed1f8d1
# ╟─f7cc2b56-a604-47ac-9d1a-272f50e94415
# ╟─38cb5b0d-cae5-4b65-bc2b-647eb3cd69ae
# ╟─a0e97706-3ef5-4fa6-87b4-1b3f991a581e
# ╟─299e325f-3b8c-4823-babb-895c8a422d5a
# ╟─1e3f6da0-f435-4923-a0e3-203bb378c317
# ╟─679359f2-5d7e-4cd2-b809-c7a7bbada1c7
# ╟─3fbe0f4e-2b9f-46e2-86cf-0db411e2b123
# ╠═eaa66257-7ef0-4482-b922-36416b1c460e
# ╟─2484def8-c908-4c19-8b14-f4a89279f081
# ╟─f39b668c-d883-4425-bf37-25ed23594645
# ╟─4a8ce796-f3ce-4958-9b2c-593c0d370572
# ╟─e6405518-efb3-4911-9ca3-a42c0c36ad90
# ╟─b465f1be-29b8-40f4-96cd-b40c3ab3d326
# ╟─0c26d794-0a06-4ad0-a244-21ff1c520d18
# ╟─8652843f-65eb-4a42-ae81-a9aec0acef49
