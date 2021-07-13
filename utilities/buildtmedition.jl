# Build an edition optimized for topic modelling,
# and write to disk in:
# - CEX format for a CitableTextCorpus
# - delimited text for use with jslda
#
using HmtTopicModels
using EditionBuilders
using CitableCorpus
using CitableText

tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "hmttm")
xmlurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-xml.cex"
xmlcorpus = CitableCorpus.fromurl(CitableTextCorpus, xmlurl, "|")
tmfile = "data/topicmodelingedition.cex"



function writeeditions(bldr, corpus::CitableTextCorpus, outfile)
    tmeditionraw = edition(bldr, corpus)
    tmnodes = filter(cn -> ! isempty(cn.text), tmeditionraw.corpus) 
    tmedition = CitableTextCorpus(tmnodes)
    tmcex = cex(tmedition)

    open(outfile,"w") do io
        write(io, tmcex)
    end


    scholia = filter(cn -> contains(cn.urn.urn, "tlg5026"), tmnodes)
    lines = []
    for sch in scholia
        wk = workcomponent(sch.urn)
        parts = split(wk,".")
        short = string(parts[2],":",passagecomponent(sch.urn))
        push!(lines, string(short,"\tscholion\t", sch.text))
    end
    jslda = join(lines,"\n") * "\n"
    open("data/scholia-jslda.tsv", "w") do io
        write(io, jslda)
    end
end

writeeditions(tmbldr, xmlcorpus, tmfile)