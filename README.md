# datamining_course_project
Final_report.pdf:the report of our project

predata.m:geneate 'metadata' and 'reviewContent'

featureExtraction.m: generate users,products and  review feature

	if matlab cannot call python function( suggestion: run the python codes separately):
	
		WordCount_reviews.py output_wordcount.txt: counting words
		
		biGram.py reviewContent output_biGram.txt: extract bigrams 
		
		allCapitalCount.py reviewContent output_AllCapital.csv :PCW feature
		
		countCapital.py reviewContent output_PC.csv: PC feature
		
		ratioPPwordCount.py reviewContent output_PP1.csv: PP1 feature
		
		excSentenceCount.py reviewContent output_RES.csv: RES feature
		
		uniGram.py reviewContent output_uniGram.txt: DL_u feature DL_b features
		
		codeTable.py output_uniGram.txt output_DL_u.csv dict_uniGram.csv: DL_u features
		
		codeTable.py output_biGram.txt output_DL_b.csv dict_biGram.csv :DL_b features
		
	then run featureExtraction.m for other features, normalization(call normalize.m)
	
	finally generate 'train.txt' and 'test.txt'
	
	(example:ETF.m,WRD.m are feature calculation files, more details in the report)

DAEGMM_train.py: train our model --input is 'train.txt'-- generate model parameter files in /model...

DAEGMM_test.py: test our model --input is 'test.txt' -- output are 'scores.txt' and 'gt.txt'


classifiy.m: Select the appropriate size of the training set and test set to train Naive Bayes and linear SVM, then output precision recall and F1scores

eval_PRF1.m: evaluate our result through precision recall and F1scores
