using TopicModelsVB
using TextAnalysis
using CitableText
using CitableCorpus
using Unicode
using HTTP

# Remove all words in stoplist from s
function trimstr(s, stoplist,  thresh=1)
	trimmed = []
	for wd in split(s)
		if wd in stoplist
			#skip if in stop list
		elseif length(wd) > thresh
			# skip if too short
			push!(trimmed, wd)
		end
	end
	join(trimmed, " ")
end

# Normalize text for topic modelling
function txtforcomment(comment, stoplist, threshhold)
	lc = Unicode.normalize(comment; stripmark=true) |> lowercase
	nopunct = replace(lc, r"[⁑':;,\.\"]" => "")
	trimstr(nopunct, stoplist, threshhold)
end

# For each row in document-term, get index of non-zero values
function indexnz(mtrx)
	allrows = []
    #rcount = 0
	for r in eachrow(mtrx)
        #rcount = rcount + 1
		rowindices = []
		for c = 1:length(r)
			if r[c] != 0
                #println(rcount, "/", c,": ", r[c])
				push!(rowindices,c)
            else
                #println("0 val")
			end
		end
		#push!(allrows, join(rowindices,","))
		push!(allrows, rowindices)
	end
	allrows
end

# Find column index for given term
function termcolumn(trm,sparsem) 
	findfirst(t -> t == trm, sparsem.terms)
end


stopwordurl = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/stops.txt"
stopdata = String(HTTP.get(stopwordurl).body)
stoplist = split(stopdata, "\n")

url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex" 
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# Prepare list of nodes for TM analysis
function filterForTm(c::CitableTextCorpus, stopwords, threshhold=1)
	comments = filter(cn -> endswith(cn.urn.urn, "comment"), c.corpus)
	commentnodes = map(cn -> CitableNode(cn.urn, txtforcomment(cn.text, stopwords, threshhold)), comments)
	filter(cn -> ! isempty(cn.text), commentnodes)
end

#= Toy experiment
xcomments = filter(cn -> endswith(cn.urn.urn, "comment"), c.corpus)
tiny = xcomments[1:100]
tinyc = CitableTextCorpus(tiny)
filteredtiny = filterForTm(tinyc, stoplist)

tinyc.corpus[5].text
filteredtiny[5].text

#println(filteredtiny[3].text)
=#

function tmcorpus(msnodes)
	srcdocs =  map(cn -> cn.text, msnodes)
	tadocs = map(s -> StringDocument(s), srcdocs)
	tacorpus = TextAnalysis.Corpus(tadocs)
	update_inverse_index!(tacorpus)
	update_lexicon!(tacorpus)
	lex = 	lexicon(tacorpus)
	sparsedtm = DocumentTermMatrix(tacorpus)
	m = dtm(sparsedtm, :dense)
	tmdata = indexnz(m)


	lines = []
	for k in keys(lex)
		push!(lines, string(termcolumn(k, sparsedtm),"\t", k))
	end
	lextsv = join(lines,"\n") * "\n"
	

	
	tmdocfile = tempname()
	datastrings = map(rowv -> join(rowv,","), tmdata)
	open(tmdocfile,"w") do io
		write(io, join(datastrings,"\n"))
	end
	println("TM DOC FILE ", tmdocfile)
	lexfile = tempname()
	open(lexfile,"w") do io
		write(io,lextsv)	
	end
	println("LEX FILE ", lexfile)

	tmcorp = readcorp(docfile=tmdocfile, vocabfile=lexfile)
	TopicModelsVB.fixcorp!(tmcorp, trim=true)
	tmcorp
end


msnodes = filterForTm(c, stoplist)
tmcorp = tmcorpus(msnodes)


msnodes[1].text





its = 15
k = 10

model1 = LDA(tmcorp, k)
train!(model1, iter=its, tol=0)

showtopics(model1, cols=k, 20)
model1.beta

# This is the distribution of vocabulary for a topic
model1.beta[1,:]

# This is the distribution of topics for a document
topicdist(model1,1)

