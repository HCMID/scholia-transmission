#using Pkg
#Pkg.activate(".")
using TopicModelsVB
using CitableCorpus
using CorpusConverters 

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


tacorp = tacorpus(c)
update_inverse_index!(tacorp

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
#tmcorp = tmcorpus(scholia)
=#