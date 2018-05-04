class ScrapWorker
  include Sidekiq::Worker
  
  MAX_DEPTH = 1
  def perform(company_id)
    @company = Company.find(company_id)
    scrapContent(@company.home_page,0)
  end

	def scrapContent(url,depth)
		return if depth > MAX_DEPTH
		depth+=1
		return if skip?(url)
		html = HTTParty.get(url, verify: false, timeout: 45).body
		html = html.encode('UTF-8', invalid: :replace, undef: :replace, replace: '', universal_newline: true).gsub(/\P{ASCII}/, '')
		parser = Nokogiri::HTML(html, nil, Encoding::UTF_8.to_s)
		parser.xpath('//script')&.remove
		parser.xpath('//style')&.remove
		parse_div(parser, url)
		page = MetaInspector.new(url, allow_non_html_content: false)
		if page.content_type == "text/html"
			links = page.links.internal 
			links.each do |link| 
				scrapContent(link, depth)	
			end
		end
		# parse_body(parser, url)
		# parse_p(parser, url)
		# parse_a(parser, url)
		# parse_h(1, parser, url)
		# parse_h(2, parser, url)
		# parse_h(3, parser, url)
	end

	def parse_body(parser, url)
		data = parser.xpath('//text()').map(&:text).join(' ').squish
		Content.create(url: url,tag: "body", data: data, company_id: @company.id)
	end

	def parse_a(parser, url) 
		anchors = parser.css('a').map {|a| [a.text.squish, a.attr('href')]} 
		cleaned_anchors = anchors.select {|anchor| anchor.last&.squish.present?} 
		cleaned_anchors.map {|a| a.join(' ')}
		cleaned_anchors.uniq.each do |data|
			Content.create(url: url,tag: "a", data: data, company_id: @company.id)
		end
	end

	def parse_p(parser, url)
		paras = parser.css('p').map {|div| div.text.squish}
		paras = paras.reject {|para| para.blank?}
		paras.uniq.each do |data|
			Content.create(url: url,tag: "p", data: data, company_id: @company.id) if data.length.between?(30,2000)
		end
	end

	def parse_h(tag, parser, url) 
		headers = parser.css("h#{tag}").map {|div| div.text.squish}
		headers = headers.reject {|para| para.blank?}
		headers.uniq.each do |data|
			Content.create(url: url,tag: "h#{tag}", data: data, company_id: @company.id) if data.length.between?(30,2000)
		end
	end

	def parse_div(parser, url)
		divs = parser.css('div').map {|div| div.text.squish}
		divs = divs.reject {|para| para.blank?}
		divs.uniq.each do |data|
			Content.create(url: url,tag: "div", data: data, company_id: @company.id) if data.length.between?(30,2000)
		end
	end

	def skip?(url) 
		return true if url =~ /\.pdf.*$/i 
		return true if url =~ /\.mp4.*$/i 
		return true if url =~ /\.mp3.*$/i 
		return true if url =~ /\.zip.*$/i 
		return true if url =~ /\/download\//i 
		return true if url =~ /blog\./i 
		return true if url =~ /\/blog/i
	end
end