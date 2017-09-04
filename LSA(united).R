
topic <- 3  #ã�Ƴ� ���鿡�� �� ���� ������ �̾Ƴ���
m <- 10  #�� ��� ����
n <- 3  #������ ���� ���� ���� � �̾Ƴ�����

#---------1. LSA�� ������ ���鿡�� ���� ���� topic���� �̽� �̾Ƴ�--------------------------------------

setwd('C:/Users/DK/summarization')
label <- c('title', 'newdescp', 'url')

news = read.csv("News4.csv", header = F, col.names = label, stringsAsFactors = F)

library(tm)
tdm = TermDocumentMatrix(Corpus(VectorSource(news$newdescp)),
                         control = list(removeNumbers = T,
                                        removePunctuation = T,
                                        stopwords = T))

library(slam)
word.count = as.array(rollup(tdm, 2))
word.order = order(word.count, decreasing = T)
fre.qword = word.order[1:(dim(tdm)[1])/3]
#row.names(tdm[freq.word,])
#n���� �ܾ� �� ���� n/3���� �ܾ�

library(lsa)
news.lsa = lsa(tdm,topic)
#n���� ��� -> topic���� ����(����)�� ����

library(GPArotation)
tk = Varimax(news.lsa$tk)$loadings

#for(i in 1:3){
#  print(i)
#  importance = order(abs(tk[, i]), decreasing = T) # ù��° ���� +���� -���� ���� abs 
#  #print(tk[importance[1:10], i])
#  print(names(tk[importance[1:10], i]))
#}
# i��° �������� �þ��/�پ�� �ܾ�
# ��簡 ���� �� �ȿ� ����� ������ ��簡 ������ ������ � ������ ���ϴ��� �� ��Ȯ�ϰ� ��Ÿ����



#---------2. �̾Ƴ� �� ������ ���� ������ ���� ��� n���� ���----------------------------------------

library(KoNLP)

for(i in 1:topic){
  cat("topic #", i, "")
  importance = order(abs(tk[, i]), decreasing = T) # ù��° ���� +���� -���� ���� abs 
  query <- names(tk[importance[1:10], i])
  
  docs <- news$newdescp
  
  for(j in 1:10){
    docs[11] <- paste(quer,query[j])
  }
  docs.corp <- Corpus(VectorSource(docs))
  
  #���ξ� �����Լ� 
  konlp_tokenizer <- function(doc){
    extractNoun(doc)
  }
  
  # weightTfIdf �Լ� ���� �ٸ� ���� �Լ����� �����Ǵµ� ���� �޴����� �����ϱ� �ٶ���. 
  tdmat <- TermDocumentMatrix(docs.corp, control=list(tokenize=konlp_tokenizer,
                                                      weighting = function(x) weightTfIdf(x, TRUE),
                                                      wordLengths=c(1,Inf)))
  
  tdmatmat <- as.matrix(tdmat)
  
  # ������ norm�� 1�� �ǵ��� ����ȭ 
  norm_vec <- function(x) {x/sqrt(sum(x^2))}
  tdmatmat <- apply(tdmatmat, 2, norm_vec)
  
  # ���� ���絵 ��� 
  docord <- t(tdmatmat[,m+1]) %*% tdmatmat[,1:m]
  
  #�˻� ��� ������ 
  orders <- data.frame(docs=docs[-m],scores=t(docord) ,stringsAsFactors=FALSE)
  orders[order(docord, decreasing=T),]
  
  print(order(docord, decreasing=T)[1:n])
}
