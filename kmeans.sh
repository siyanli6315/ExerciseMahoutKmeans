mahout kmeans -i file://$(pwd)/bookreview_sparse/tfidf-vectors \
	-c file://$(pwd)/bookreview_kmeans_clusters \
	-o file://$(pwd)/bookreview_kmeans \
	-k 3 -dm \
	org.apache.mahout.common.distance.CosineDistanceMeasure \
	-x 200 -ow --clustering
