using CitableCorpus
using CitableText
using CSV
using DataFrames

srctexturl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingsource.cex"
srccorp = CitableCorpus.fromurl(CitableTextCorpus,srctexturl, "|")
function msid(u)
	parts = split(workcomponent(u),".")
	parts[2]
end
msids = map(cn -> msid(cn.urn), srccorp.corpus)


f = string(pwd(), "/data/sampletmdata/docs-topics.csv")
dtmatrix = CSV.File(f; delim=",") |> DataFrame
dtmatrix.ms = msids 

