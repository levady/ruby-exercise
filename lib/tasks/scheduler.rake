namespace :bot do
  desc 'Post a random tweet'
  task :post_random_tweet => :environment do
    puts 'Posting random tweet..'
    TwitterBot.new.post_random_tweet
    puts 'done.'
  end

  desc 'Reply a tweet to gecko bot'
  task :reply_tweets => :environment do
    puts 'Replying tweets..'
    TwitterBot.new.reply_tweets
    puts 'done.'
  end
end
