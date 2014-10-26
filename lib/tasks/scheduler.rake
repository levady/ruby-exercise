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

  desc 'Post and reply tweets simultaneously to conserve heroku dyno'
  task :post_and_reply_tweets => :environment do
    Rake::Task['bot:post_random_tweet'].execute
    Rake::Task['bot:reply_tweets'].execute
  end
end
