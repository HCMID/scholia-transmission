using TopicModelsVB
using CitableCorpus
using CorpusConverters

#= Topic modelling.  Set params:
=#
k = 9
iterations = 25
wordstodisplay = 10


if length(ARGS) > 1
    k = ARGS[1]
    iterations = ARGS[2]
elseif length(ARGS) > 0
    k = ARGS[1]
end


@info "Number of topics: $k, iterations: $iterations"
@info "Please be patient: reading text corpus..."

# Download citable corpus for topic modelling:
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/topicmodelingedition.cex"
tmed = CitableCorpus.fromurl(CitableTextCorpus, url, "|")
@info "Read corpus with $(length(tmed.corpus)) \"documents\"."


# Build Corpus type for topic modelling, and create model
tmcorp = tmcorpus(tmed)
model = LDA(tmcorp, k)

# Run model, look at results:
train!(model, iter=iterations, tol=0)
showtopics(model, cols=k, wordstodisplay)


function sortablescores(themodel)
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
queryablescores

function sortbytopic(m, topicnum)
    sort(m, lt=(x,y)->isless(x[topicnum],y[topicnum]), rev=true, dims = 2)
end


queryablescores = sortablescores(model)


using DataFrames
scoresdf = DataFrame(queryablescores, :auto)

docidx = k + 1
scoresdf[1, docidx]

doc = scoresdf[1,docidx]
showdocs(model, Int(doc))

t7 = sort(scoresdf, 7, rev = true)
topdoc7 = t7[1,docidx]
showdocs(model, Int(topdoc7))

m