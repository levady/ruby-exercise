class TwitterBot

  ACTIONS = [
    :anagrams,
    # :haiku,
    # :lyrics,
    :text_to_speech,
    :image_from_hex,
    :random_word,
    :battleship
  ]

  def initialize
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def post_random_tweet
    send(ACTIONS.sample(random: 1))
  end

  def reply_tweets
    twitter_id = TwitterMentionsTracker.last.try(:id)

    tweets = if twitter_id
      @twitter_client.mentions_timeline(since_id: twitter_id)
    else
      @twitter_client.mentions_timeline
    end

    unless tweets.empty?
      tweets.each do |tweet|
        @twitter_client.update("@#{tweet.user.screen_name} Hi, thanks for mentioning me =)")
      end

      TwitterMentionsTracker.create(twitter_id: tweets.first.id)
    end
  end

private

  def anagrams
    tweet = find_random_tweet
    if tweet
      find_three_words = tweet.split(' ').sample(3, random: 1).join(' ')
      conn = Faraday.new('http://www.anagramica.com')
      response = JSON.parse(conn.get("/best/#{URI.encode(find_three_words)}").body)

      if !response["best"].empty?
        anagrams = response["best"].join(', ')
        @twitter_client.update("#{anagrams} is an anagram from these '#{find_three_words}' words")
      end
    end
  end

  def text_to_speech
    tweet = find_random_tweet
    if tweet
      tts_url = "http://translate.google.com/translate_tts?ie=UTF-8&tl=en&q=#{URI.encode(tweet[0, 100])}"
      @twitter_client.update("Random text to speech: #{tts_url}")
    end
  end

  def image_from_hex
    random_color = "%06x" % rand(0..0xffffff)
    sample_image_url = "http://www.colorhexa.com/#{random_color}.png"
    @twitter_client.update("hex color ##{random_color} - #{sample_image_url}")
  end

  def random_word
    conn = Faraday.new('http://randomword.setgetgo.com')
    @twitter_client.update("Some random word: #{conn.get('/get.php').body.gsub("\r\n", "")}")
  end

  def battleship
    conn  = Faraday.new('https://ajax.googleapis.com')
    query = ['Starwars Spaceship', 'Spaceship', 'World war 2 battleship'].sample(random: 1)
    response = JSON.parse(conn.get("/ajax/services/search/images?v=1.0&q=#{URI.encode(query)}").body)

    data = response["responseData"]["results"]
    if !data.empty?
      image_url = data.collect { |image| image["url"] }.sample(random: 1)
      @twitter_client.update("#{query} #{image_url}")
    end
  end

  def find_random_tweet
    tweets = @twitter_client.search("*", :result_type => "mixed", lang: 'eu').take(100)
    tweets.collect do |tweet|
      tweet.text if tweet.text.gsub('\n\r', '').language == :english
    end.compact.sample(random: 1)
  end

end
