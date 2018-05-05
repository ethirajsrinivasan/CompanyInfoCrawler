class Content < ApplicationRecord
	belongs_to :company
	searchkick synonyms: [["Location", "Offices"], ["Offices","Market Presence"],
["Products", "Services"], ["Solutions", "Technologies"], ["Business Offerings", "Business Lines"],
["About","Company Description"],
["Website", "Homepage URL"],
["News", "Blog"], ["Press", "Press Release"],
["Investors", "Seed"], ["Series A", "Series B"], ["Series C", "Investment"], ["Capital Raised", "Fund Raised"], ["Fund Raised","Revenue"],
["Partners", "Partnership"], ["Collaboration", "Partnered"], ["Channels", "Partnered"],
["Contact", "Support"], ["Support", "Call"],
["Customers", "Consumers"],["Clients", "Users"],
["Award", "Accolade"], ["Accolade","Win"],
["Sector", "Vertical"],["Vertical","Industries"]]
	
	def self.to_csv(content,query)
		CSV.generate do |csv|
	      csv << ["Query",query]
	      content.each do |data|
	        csv << [data]
	      end
	    end
	end
end
