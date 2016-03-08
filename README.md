Find the most active people on a given GitHub repo. The way this works is that it fetches all the issues and pull requests via the GitHub API and all comments for each of them, and counts how many times each person commented. The script can take quite a long time to finish.

To use this script, simply run:

    ruby stats.rb facebook/react-native

Note that you'll almost immediately get blocked because of exceeding the API rate limit. To check the limit (the numbers are **per hour**), run:

    curl -i https://api.github.com/users/whatever

To get a higher limit you need to use authenticated requests. Luckily, you can simply generate access an access token for command line use. **Important:** Do this with a user that doesn't have push access or anything in case you leak the token. If you have push access to the repo just register a new dummy GitHub user and get the token for that user.

- Go to https://github.com/settings/tokens/new
- Generate the token, set an env variable: `export STATS_GITHUB_ACCESS_TOKEN=YOUR_TOKEN`. This is the last time you've seen the token.

Check that the token works:

    curl -i https://api.github.com/users/whatever?access_token=your_token

You should see a limit of 5000 request per hour.
