#using Pkg
#Pkg.activate(".")
using TopicModelsVB
using CitableCorpus
using CorpusConverters 
using TextAnalysis

k = 10
iters = 25


if length(ARGS) > 1
    k = ARGS[1]
    iters = ARGS[2]
elseif length(ARGS) > 0
    k = ARGS[1]
end
@info "Number of topics: $k, iterations: $iters"

@info "Reading text corpus..."
f = "data/topicmodelingedition.cex"
c = CitableCorpus.fromfile(CitableTextCorpus, f)
@info "Read corpus with $(length(c.corpus)) \"documents\"."
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), c.corpus)  |> CitableTextCorpus
@info "Selected $(length(scholia.corpus)) scholia."
tmcorp = tmcorpus(scholia)



println("Pause here")
#= Debugging work finding bad data.
=#
tascholia = tacorpus(scholia)
update_inverse_index!(tascholia)


badquotes = tascholia["\""]

count = 0
for bad1 in badquotes 
	count = count + 1
	#println(tascholia[bad1].text,"\n")
	println(count, ". ", scholia.corpus[bad1].urn,scholia.corpus[bad1].text,"\n\n")
end

badquotes[1]

scholia.corpus[3677].text
scholia.corpus[3677].urn
update_lexicon!(tacorp)
m = DocumentTermMatrix(tacorp)
term = "\""
termidx = findfirst(t -> t == term, m.terms)
m[termidx]

densely = dtmatrix(scholia)
densely[1,:]
tmdata = CorpusConverters.indexnz(densely)  
datastrings = map(rowv -> join(rowv,","), tmdata)
tmdocfile = "debugdm.csv"
open(tmdocfile,"w") do io
	write(io, join(datastrings,"\n"))
end





tmcorp = tmcorpus(scholia)
=#


println("Pause here")
#=
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


function termcolumn(trm,sparsem) 
	findfirst(t -> t == trm, sparsem.terms)
end


function tmcorpus(c::CitableTextCorpus)
    tacorp = tacorpus(c)
	update_inverse_index!(tacorp)
	update_lexicon!(tacorp)
	lex = 	lexicon(tacorp)
    lexlines = []
    sparsedtm = DocumentTermMatrix(tacorp)
	for k in keys(lex)
		push!(lexlines, string(termcolumn(k, sparsedtm),"\t", k))
	end
	lextsv = join(lexlines,"\n") * "\n"
    lexfile = tempname()
	open(lexfile,"w") do io
		write(io,lextsv)	
	end
	@info "Lexicon file: $lexfile"

	m = dtmatrix(c)
	tmdata = indexnz(m)    	
	tmdocfile = tempname()
	datastrings = map(rowv -> join(rowv,","), tmdata)
	open(tmdocfile,"w") do io
		write(io, join(datastrings,"\n"))
	end
	@info "Document-matrix file $tmdocfile"
	
	tmcorp = readcorp(docfile=tmdocfile, vocabfile=lexfile)
	TopicModelsVB.fixcorp!(tmcorp, trim=true)
	tmcorp
end

tacorp = tacorpus(scholia)
#
=#




