#using Pkg
#Pkg.activate(".")
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

