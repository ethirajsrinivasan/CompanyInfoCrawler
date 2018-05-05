require 'matrix'
require 'tf-idf-similarity'
class ContentsController < ApplicationController

	def index
	end

	def search
		@contents = Content.search params["query"], where: {company_id: params[:company_id].to_i}
		@contents = @contents.map(&:data).uniq
		return if @contents == []
		corpus = Lda::Corpus.new
		@contents.each do |content|
			corpus.add_document(Lda::TextDocument.new(corpus, content))
		end
		lda = Lda::Lda.new(corpus)
		lda.verbose = false
		lda.num_topics = (2)
		lda.em('random')
		topics = lda.top_words(20)
		@topics = topics.values.flatten.select { |word| word.length > 2}
		if params[:method_id].to_i == 0
			carrot2 = Carrot2.new
			clusters = carrot2.cluster(@contents)["clusters"]
			doc_clusters = clusters.to_a.map { |val| val["documents"] }
			@clustered_documents_map = doc_clusters.map do |cluster|
				get_mean_documents(cluster.map(&:to_i))			
			end
			@clustered_documents = @clustered_documents_map.each_with_index.map do |cluster,i|
				cluster.map do |doc|
					doc_clusters[i][doc].to_i
				end
			end
			@clustered_documents =  @clustered_documents[0].zip(*@clustered_documents[1..-1]).flatten.uniq.compact	
			@contents = @clustered_documents.map do |doc|
				@contents[doc]
			end
		end
		respond_to do |format|
	      format.html
	      format.csv { send_data Content.to_csv(@contents,params[:query]), filename: "#{Company.find(params[:company_id]).name} #{params[:query]}.csv" }
		end
	end


	def get_mean_documents(doc)
		corpus = doc.map { |content| TfIdfSimilarity::Document.new(@contents[content])}
		model = TfIdfSimilarity::TfIdfModel.new(corpus)
		model.similarity_matrix
			.row_vectors()
			.map(&:to_a)
			.each_with_index
			.map { |x,i| [i,x.sum] }
			.sort_by(&:last).reverse.map(&:first)[0..1]
	end

	def download
		puts params
	end
end
