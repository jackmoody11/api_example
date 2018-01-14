# this is kind of hacky but it's really not that bad.
# PROPERTIES are keys of the hash we pass to this object
# that we care about.
#
# attr_reader allows us to access instance variables without
# writing an explicit getter. it's syntactic sugar.
class ListingResult
  PROPERTIES = [:title, :author, :url, :new_trade_in, :new_price, :new_price_low, :used_price_low, :all_offers_url, :isbn]
  PROPERTIES.each { |prop| attr_reader prop }

  # loop through the PROPERTIES and set an instance variable
  # for each of them, and assign it to the value of the hash
  # we pass in
  def initialize(opts = {})
    PROPERTIES.each do |prop|
      instance_variable_set("@#{prop}", opts[prop])
    end
  end

end

class ListingLookup

  # shorthand
  def self.query(isbn)
    new.query(isbn)
  end

  # call if fake == true, return a mock response. it's lazy.
  def initialize(fake = false)
    @fake = fake
    @client = Vacuum.new('US')
    @client.configure(
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      associate_tag: ENV['AWS_ASSOCIATE_TAG']
    )
  end

  # this is where the good stuff happens.
  # explicit return on the ListingResult if fake
  # so we don't need an else
  def query(isbn)
    if @fake
      return ListingResult.new(
        title: "title #{SecureRandom.hex}",
        author: "author #{SecureRandom.hex}",
        url: "url #{SecureRandom.hex}",
        new_trade_in: "newTradeIn #{SecureRandom.hex}",
        new_price: "newPrice #{SecureRandom.hex}",
        new_price_low: "newPriceLow #{SecureRandom.hex}",
        used_price_low: "usedPriceLow #{SecureRandom.hex}",
        all_offers_url: "allOffersUrl #{SecureRandom.hex}",
        isbn: isbn
      )
    end
    response = @client.item_lookup(
      query: {
        'ItemId' => isbn,
        'SearchIndex' => 'Books',
        'IdType' => 'ISBN',
        'ResponseGroup' => 'ItemAttributes, Offers',
      },
      persistent: true
    )
    extract_result(response)
  end

  private

  # extract the result.
  # it's a private method because it's not public-facing,
  # and nobody knows that it exists but this object.
  #
  # for the sake of good habits, stick to the ruby style guide
  # we don't like to camelCase things here. we snake_case.
  def extract_result(response)
    full_response = response.to_h #returns full response in form of hash
    author = full_response.dig("ItemLookupResponse","Items","Item","ItemAttributes","Author")
    title = full_response.dig("ItemLookupResponse","Items","Item","ItemAttributes","Title")
    url = full_response.dig("ItemLookupResponse","Items","Item","ItemLinks","ItemLink",6,"URL")
    # Amount times 100
    new_price = full_response.dig("ItemLookupResponse", "Items","Item", "ItemAttributes", "ListPrice", "Amount").to_f
    new_trade_in = full_response.dig("ItemLookupResponse", "Items","Item", "ItemAttributes", "TradeInValue", "Amount").to_f
    new_price_low = full_response.dig("ItemLookupResponse", "Items","Item", "OfferSummary", "LowestNewPrice", "Amount").to_f
    used_price_low = full_response.dig("ItemLookupResponse", "Items","Item", "OfferSummary", "LowestUsedPrice", "Amount").to_f
    # URLs
    all_offers_url = full_response.dig("ItemLookupResponse", "Items", "Item", "Offers", "MoreOffersUrl")
    # Proper float value
    new_trade_in = new_trade_in ? new_trade_in / 100 : nil
    new_price  = new_price ? new_price / 100 : nil
    new_price_low = new_price_low ? new_price_low / 100 : nil
    used_price_low = used_price_low ? used_price_low / 100 : nil
    ListingResult.new(
      title: title,
      author: author,
      url: url,
      new_trade_in: new_trade_in,
      new_price: new_price,
      new_price_low: new_price_low,
      used_price_low: used_price_low,
      all_offers_url: all_offers_url,
      isbn: "1234"
    ) # i don't know how the response object looks
  end
end