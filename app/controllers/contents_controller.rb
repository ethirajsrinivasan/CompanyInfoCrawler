class ContentsController < ApplicationController

	def index
	end

	def search
		@contents = Content.search params["query"], where: {company_id: params[:company_id].to_i}
		@contents = @contents.map(&:data).uniq
	end
end
