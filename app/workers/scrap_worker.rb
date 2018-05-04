class ScrapWorker
  include Sidekiq::Worker

  def perform(company_id)
    @company = Company.find(company_id)
    scrapContent(@company.id, @company.home_page)
  end

	def scrapContent(company_id, url)
		html = HTTParty.get(url, verify: false, timeout: 45).body
		html = html.encode('UTF-8', invalid: :replace, undef: :replace, replace: '', universal_newline: true).gsub(/\P{ASCII}/, '')
		parser = Nokogiri::HTML(html, nil, Encoding::UTF_8.to_s)
		parser.xpath('//script')&.remove
		parser.xpath('//style')&.remove
		# parse_body(parser)
		# parse_p(parser)
		# parse_a(parser)
		parse_div(parser)
		# parse_h(1, parser)
		# parse_h(2, parser)
		# parse_h(3, parser)
	end

	def parse_body(parser)
		data = parser.xpath('//text()').map(&:text).join(' ').squish
		Content.create(url: @company.home_page,tag: "body", data: data, company_id: @company.id)
	end

	def parse_a(parser) 
		anchors = parser.css('a').map {|a| [a.text.squish, a.attr('href')]} 
		cleaned_anchors = anchors.select {|anchor| anchor.last&.squish.present?} 
		cleaned_anchors.map {|a| a.join(' ')}
		cleaned_anchors.each do |data|
			Content.create(url: @company.home_page,tag: "a", data: data, company_id: @company.id)
		end
	end

	def parse_p(parser)
		paras = parser.css('p').map {|div| div.text.squish}
		paras = paras.reject {|para| para.blank?}
		paras.each do |data|
			Content.create(url: @company.home_page,tag: "p", data: data, company_id: @company.id) if data.length > 30
		end
	end

	def parse_h(tag, parser) 
		headers = parser.css("h#{tag}").map {|div| div.text.squish}
		headers = headers.reject {|para| para.blank?}
		headers.each do |data|
			Content.create(url: @company.home_page,tag: "h#{tag}", data: data, company_id: @company.id)
		end
	end

	def parse_div(parser)
		divs = parser.css('div').map {|div| div.text.squish}
		divs = divs.reject {|para| para.blank?}
		divs.each do |data|
			Content.create(url: @company.home_page,tag: "div", data: data, company_id: @company.id) if data.length > 30
		end
	end
end