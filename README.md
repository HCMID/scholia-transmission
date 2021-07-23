# Transmission of Homeric *scholia*


Modeling transmission of scholia in Homeric manuscripts.

Content: current coverage of *scholia* in manuscripts edited by the Homer Multitext project


Features to model:

- thematic content (using topic modeling)
- chronology (using latest reference to datable figures)
- formal features:
    - class of introductory phrase
    - other key terms or phrases like ζηνόδοτος γράφει ?
- non-linguistic features:
    - critical signs in Venetus A
    - simile numbers



## Some useful Pluto notebooks

The following Pluto notebooks can be found in the `nbs` directory with names including a semantic version number.



### Exploring the corpus

- `termsearch`: see passages with term (anywhere in corpus). Includles TF-IDF measure of term's salience.
- `stringsearch`: search for strings of characters in *scholia*. Includes option to download results as delimited-text file.
- `initial-ngrams`: see distribution of initial n-grams in corpus.
- `simplelda`: build topic models using LDA
- `analyzetm`: load document-term data from delimited file and visualize distribution of topics by MS
- `vocabfrequency`: view frequency of most common terms. Includes option to download list of terms.

### Calculating features for our model


- `centurydates`: compute an integer representing the century of the lates datable person mentioned in each scholion.
- `scholia-size`: compute number of "words" per scholion.