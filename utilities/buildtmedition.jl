# Build an edition optimized for topic modelling,
# and write to disk in:
# - CEX format for a CitableTextCorpus
# - delimited text for use with jslda
#
using HmtTopicModels
using EditionBuilders
using CitableCorpus
using CitableText
using CitableObject

tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "hmttm")
xmlurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-xml.cex"
xmlcorpus = CitableCorpus.fromurl(CitableTextCorpus, xmlurl, "|")
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), xmlcorpus.corpus) |> CitableTextCorpus
tmfile = "data/topicmodelingedition.cex"
tmcorp = tmcorpus(xmlcorpus)

#=
function tidyurns(s)
    tkns = split(s)
    tidier = []
    for t in tkns
        if startswith(t, "urn:cite2:hmt:pers")
            u = Cite2Urn(t)
            rawnumeral = replace(objectcomponent(u), "pers" => "")
            #=
            shorter = string("pers_", objectcomponent(u))
            push!(tidier, shorter)
            =#
            push!(tidier, rawnumeral)
        else
            push!(tidier, t)
        end
    end
    join(tidier," ")
end

function writeeditions(bldr, corpus::CitableTextCorpus, outfile)
    tmeditionraw = edition(bldr, corpus)
    tmnodes = filter(cn -> ! isempty(cn.text), tmeditionraw.corpus) 
    tmedition = CitableTextCorpus(tmnodes)
    tmcex = cex(tmedition)

    open(outfile,"w") do io
        write(io, tmcex)
    end


    scholia = filter(cn -> contains(passagecomponent(cn.urn), "comment"), tmnodes)
    lines = []
    for sch in scholia
        wk = workcomponent(sch.urn)
        parts = split(wk,".")
        short = string(parts[2],":",passagecomponent(sch.urn))
        push!(lines, string(short,"\tscholion\t", tidyurns(sch.text)))
    end
    jslda = join(lines,"\n") * "\n"
    open("data/scholia-jslda.tsv", "w") do io
        write(io, jslda)
    end
end

writeeditions(tmbldr, xmlcorpus, tmfile)
=#