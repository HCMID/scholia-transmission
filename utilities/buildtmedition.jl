using HmtTopicModels
using EditionBuilders
using CitableCorpus

tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "hmttm")
xmlurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-xml.cex"
xmlcorpus = CitableCorpus.fromurl(CitableTextCorpus, xmlurl, "|")
tmfile = "data/topicmodelingedition.cex"

function writeedition(bldr, corpus::CitableTextCorpus, outfile)
    tmeditionraw = edition(bldr, corpus)
    tmnodes = filter(cn -> ! isempty(cn.text), tmeditionraw.corpus) 
    tmedition = CitableTextCorpus(tmnodes)
    tmcex = cex(tmedition)

    open(outfile,"w") do io
        write(io, tmcex)
    end
end

writeedition(tmbldr, xmlcorpus, tmfile)