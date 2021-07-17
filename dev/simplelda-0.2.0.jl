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

# ╔═╡ c7e2e54a-019d-4f37-a88e-d0158110bc43
k = 6

# ╔═╡ 9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
iterations = 100

# ╔═╡ 15da696a-1fe4-40a4-9a92-88e08a8e49b5
wordstoshow = 8

# ╔═╡ 555bab88-808e-487b-8441-9aa2ad3f4309
md"""
**Results of modeling $k topics after $iterations iterations: top $wordstoshow words for each topic**
 

"""

# ╔═╡ c72fab11-3b8f-49f1-9693-60e8dce883bf
md"Downloadable data"

# ╔═╡ 8dcf39c4-9cb9-446c-8d56-48b410ad1f06
md"> Format data for download as delimited files"

# ╔═╡ 38cb5b0d-cae5-4b65-bc2b-647eb3cd69ae
function covarcsv(covarvals)
	"here"
end

# ╔═╡ a0e97706-3ef5-4fa6-87b4-1b3f991a581e
function doctopiccsv(gammas)
	lines = []
	for doc in 1:length(gammas)
		line = []
		for tpc in 1:k
			push!(line, gammas[doc][tpc])
		end
		push!(lines, join(line, ","))
	end
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

# ╔═╡ 4a8ce796-f3ce-4958-9b2c-593c0d370572
md"> Load corpus formatted for topic modelling"

# ╔═╡ e6405518-efb3-4911-9ca3-a42c0c36ad90
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingedition.cex"

# ╔═╡ b465f1be-29b8-40f4-96cd-b40c3ab3d326
fulltmed = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 079dda6c-6eca-49e3-a230-c36b8600868f
tmed = fulltmed.corpus[1:100] |> CitableTextCorpus

# ╔═╡ 0c26d794-0a06-4ad0-a244-21ff1c520d18
tmed.corpus |> length

# ╔═╡ a21a75f9-7059-4b16-8d00-dfcf32c0d642
md"> Create model with `k` topics`"

# ╔═╡ 8652843f-65eb-4a42-ae81-a9aec0acef49
tmcorp = tmcorpus(tmed)

# ╔═╡ 4b840632-0ef4-490f-a9e8-c95184ca7e59
model = LDA(tmcorp, k)
#model = fCTM(tmcorp, k)


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
- *Document-topic matrix*  $(DownloadButton(doctopiccsv(model.gamma), "docs-topics.csv")).  Each document is scored on each topic (so here, $(length(model.corp.docs)) rows with $k columns).
- *Covariance matrix*

"""

# ╔═╡ Cell order:
# ╟─7ed58b4c-e646-11eb-1526-4b56470a3b62
# ╟─1876658c-302e-48ad-947e-099a23472e32
# ╟─57134c2e-c646-4ec4-bb15-eb1298ca35da
# ╟─550c4d2d-7c47-4f56-8bc9-f4708ef9aa83
# ╠═c7e2e54a-019d-4f37-a88e-d0158110bc43
# ╟─4b840632-0ef4-490f-a9e8-c95184ca7e59
# ╟─15088ec6-5be1-4eb5-b01a-81af28322a43
# ╠═9867e9cd-4ed3-45b9-8ccf-f0e2074d9f83
# ╠═3bd93907-4ab4-4c12-8867-b9f8db27ad4b
# ╟─555bab88-808e-487b-8441-9aa2ad3f4309
# ╠═15da696a-1fe4-40a4-9a92-88e08a8e49b5
# ╟─e232a0ef-5473-4708-b50f-4f1f43ebee33
# ╟─c72fab11-3b8f-49f1-9693-60e8dce883bf
# ╟─d6968676-c537-482d-a5b8-f3e7c413470a
# ╟─8dcf39c4-9cb9-446c-8d56-48b410ad1f06
# ╟─4808a47f-c73e-4590-b6ba-db105ed1f8d1
# ╟─f7cc2b56-a604-47ac-9d1a-272f50e94415
# ╟─38cb5b0d-cae5-4b65-bc2b-647eb3cd69ae
# ╟─a0e97706-3ef5-4fa6-87b4-1b3f991a581e
# ╟─299e325f-3b8c-4823-babb-895c8a422d5a
# ╟─1e3f6da0-f435-4923-a0e3-203bb378c317
# ╟─4a8ce796-f3ce-4958-9b2c-593c0d370572
# ╟─e6405518-efb3-4911-9ca3-a42c0c36ad90
# ╠═b465f1be-29b8-40f4-96cd-b40c3ab3d326
# ╠═079dda6c-6eca-49e3-a230-c36b8600868f
# ╟─0c26d794-0a06-4ad0-a244-21ff1c520d18
# ╟─a21a75f9-7059-4b16-8d00-dfcf32c0d642
# ╟─8652843f-65eb-4a42-ae81-a9aec0acef49
