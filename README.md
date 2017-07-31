# Pubmed references dataset
The following data is produced by parsing 270 GB of MEDLINE/PubMed XML publicly available [here](https://www.nlm.nih.gov/databases/download/pubmed_medline.html).
As per [license](https://www.nlm.nih.gov/copyright.html), government information at NLM Web sites is in the public domain. Public domain information may be freely distributed and copied, but it is requested that in any subsequent use the National Library of Medicine (NLM) be given appropriate acknowledgement.

Pubmed XML data contain bibliographic links, i.e. information about article's predecessors. This dataset is exactly those data reverted: directed acyclic graph of the article's ancestors. 12 millions vertices, 97 millions edges.

By the very nature of the academic publication process there's no reason to assume that bibliography lists are complete or properly tagged. So absolute numbers are definitely wrong. But I hope that they are useful as relative amounts.