mahout seq2sparse -i file://$(pwd)/bookreview_seq \
	-o file://$(pwd)/bookreview_sparse \
	-ow --weight tfidf --maxDFPercent 85 --namedVector
