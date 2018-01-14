class Listing < ApplicationRecord

  def self.amazon_lookup(val)
      request = Vacuum.new('US')
      request.configure(
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      associate_tag: ENV['AWS_ASSOCIATE_TAG']
      )
      response = request.item_lookup(
        query: {
          'ItemId' => val,
          'SearchIndex' => 'Books',
          'IdType' => 'ISBN',
          'ResponseGroup' => 'ItemAttributes, Offers',
        },
        persistent: true
      )
      fr = response.to_h #returns full response in form of hash
      author = fr.dig("ItemLookupResponse","Items","Item","ItemAttributes","Author")
      title = fr.dig("ItemLookupResponse","Items","Item","ItemAttributes","Title")
      url = fr.dig("ItemLookupResponse","Items","Item","ItemLinks","ItemLink",6,"URL")
      # Amount times 100
      newPrice = fr.dig("ItemLookupResponse", "Items","Item", "ItemAttributes", "ListPrice", "Amount").to_f
      newTradeIn = fr.dig("ItemLookupResponse", "Items","Item", "ItemAttributes", "TradeInValue", "Amount").to_f
      newPriceLow = fr.dig("ItemLookupResponse", "Items","Item", "OfferSummary", "LowestNewPrice", "Amount").to_f
      usedPriceLow = fr.dig("ItemLookupResponse", "Items","Item", "OfferSummary", "LowestUsedPrice", "Amount").to_f
      # URLs
      allOffersUrl = fr.dig("ItemLookupResponse", "Items", "Item", "Offers", "MoreOffersUrl")
      # Proper float value
      newTradeIn = newTradeIn ? newTradeIn / 100 : nil
      newPrice = newPrice ? newPrice / 100 : nil
      newPriceLow = newPriceLow ? newPriceLow / 100 : nil
      usedPriceLow = usedPriceLow ? usedPriceLow / 100 : nil
      return {title: title, author: author,
              url: url, newTradeIn: newTradeIn,
              newPrice: newPrice, newPriceLow: newPriceLow, usedPriceLow: usedPriceLow,
              allOffersUrl: allOffersUrl, isbn: val}
    end

end
