class Content < ApplicationRecord
	belongs_to :company
	searchkick
end
