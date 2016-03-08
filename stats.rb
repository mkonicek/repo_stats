gem 'octokit'
gem 'httparty'

require 'octokit'
require 'httparty'

PAGE_SIZE = 50

access_token = ENV['STATS_GITHUB_ACCESS_TOKEN']

unless access_token
  puts "Need an access token. See README.md"
  exit 1
end

unless ARGV[0]
  puts "Usage: ruby stats.rb your_org/your_repo"
  exit 1
end
repo = ARGV[0]

page = 1
client = Octokit::Client.new(
  :access_token     => access_token,
)

all_commenters = Hash.new(0)

# Get all the issues and PRs in the repo
loop do
  begin
    # Get 100 issues / PRs
    issues = client.issues(repo, per_page: PAGE_SIZE, page: page, state: 'all')

    # For each issue / PR parse all comments
    issues.each do |issue|
      response = HTTParty.get(issue.comments_url + "?access_token=#{access_token}")
      comments = JSON.parse(response.body)
      commenters = comments.
        map { |response| response['user']['login'] }

      # Increment count for the issue creator
      all_commenters[issue[:user][:login]] += 1

      # Increment count for each commenter
      commenters.each do |commenter|
        all_commenters[commenter] += 1
      end

      # Just log it so I can watch progress

      puts "##{issue[:number]}: #{issue[:title]} (page: #{page})"

      # Sleep to prevent rate limiting:
      # - 5000 request per hour limit
      # - One request per issue
      sleep 1
    end

    puts "Top 50 for most recent #{page*PAGE_SIZE} issues:"
    sorted_n_comments = Hash[all_commenters.sort_by{|k, v| v}.reverse[0..50]]
    puts JSON.pretty_generate(sorted_n_comments)

    page = page + 1
  rescue Exception => e
    print e.message + "\n " + e.backtrace.join("\n ")
  end
end
