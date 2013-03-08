# https://github.com/gregstallingsuw/craigslist
require 'craigslist'
# https://github.com/yohasebe/engtagger
require 'engtagger'
require 'digest/md5'
require 'redis'
require 'json'

@tagger = EngTagger.new
@redis = Redis.new

cities = Craigslist.cities

cities.each do |city|
 Craigslist.send(city).for_sale.last(30).each do |item|
 	title = item['text'].downcase
  puts Digest::MD5.hexdigest(title)
  puts item['href']
 
  tagged = @tagger.add_tags(title)
  @tagger.get_nouns(tagged).each do |noun|
		@redis.incr(noun[0])
  end

 end
end

File.open("data.json","w") do |f|
	f.write('{"name": "new_york","children": [')
	@index = 0
	@redis.keys.each do |key|
		  @index = @index + 1
	    f.write(JSON.pretty_generate({"name" => key, "size" => @redis[key]}))
	    f.write(",") if @index < @redis.keys.count
	end
	f.write(" ]}")
end