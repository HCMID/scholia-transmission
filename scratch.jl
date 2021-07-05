using TopicModelsVB
using TextAnalysis
using CitableText
using CitableCorpus
using Unicode

# Normalize text for topic modelling
function txtforcomments(nodelist)
	txts = map(cn -> Unicode.normalize(cn.text; stripmark=true), nodelist)
	lc = map(t -> lowercase(t), txts)	
	map(s -> replace(s, r"[:;\.\"]" => ""), lc)
end


url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex" 
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

msnodes = begin
	comments = filter(cn -> endswith(cn.urn.urn, "comment"), c.corpus)
	commentnodes = filter(cn -> ! isempty(cn.text), comments)
	catchdeletion = filter(cn -> cn.text != ".", commentnodes)
	#ms == "all" ? catchdeletion : filter(cn -> occursin(string(".",ms,"."), cn.urn.urn), catchdeletion) 
	catchdeletion
end

realsrcdocs = txtforcomments(msnodes)
realdocs = map(s -> StringDocument(s), realsrcdocs)
tacorpus = TextAnalysis.Corpus(realdocs)
lex = begin
	update_inverse_index!(tacorpus)
	update_lexicon!(tacorpus)
	lexicon(tacorpus)
end


sparsedtm = DocumentTermMatrix(tacorpus)
m = dtm(sparsedtm, :dense)


# For each row, get index of non-zero values
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




tmdata = indexnz(m)


function termcolumn(trm) 
	findfirst(t -> t == trm, sparsedtm.terms)
end

lextsv = begin
	lines = []
	for k in keys(lex)
		push!(lines, string(termcolumn(k),"\t", k))
	end
	join(lines,"\n") * "\n"
end


# These are the 2 input files we need to do TM:
tmdocfile = begin
	f = tempname()
	datastrings = map(rowv -> join(rowv,","), tmdata)
	#write(f, join(datastrings,"\n"))
	#f
	write("tmdata2.txt",  join(datastrings,"\n"))
	"tmdata2.txt"
end

lexfile = begin
	vfile = tempname()
	#write(vfile,lextsv)
	#vfile
	write("lexfile2.tsv", lextsv)
	"lexfile2.tsv"
end


using HTTP
stopwordurl = "https://raw.githubusercontent.com/SophiaSarro/Thesis-Material/master/topic-modelling-data/scholia-stopwords.txt"
stopdata = String(HTTP.get(stopwordurl).body)
stoplist = split(stopdata, "\n")

function trimstr(s, stoplist)
	trimmed = []
	for wd in split(s)
		if wd in stoplist
			#skip
		else
			push!(trimmed, wd)
		end
	end
	join(trimmed, " ")
end

tmcorp = readcorp(docfile=tmdocfile, vocabfile=lexfile)
TopicModelsVB.fixcorp!(tmcorp, trim=true, stop=true)
tmcorp.vocab

its = 30
k = 10

model1 = LDA(tmcorp, k)
train!(model1, iter=its, tol=0)


showtopics(model1, cols=k, 20)

