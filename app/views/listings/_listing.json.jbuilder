json.extract! listing, :id, :isbn, :title, :author, :price, :created_at, :updated_at
json.url listing_url(listing, format: :json)
