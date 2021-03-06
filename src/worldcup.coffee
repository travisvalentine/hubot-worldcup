# Description:
#   A way to get basic info and updates on the 2014 World Cup
#
# Commands:
#   hubot wc today                  - Returns a list of World Cup matches today
#   hubot wc tomorrow               - Returns a list of World Cup matches tomorrow
#   hubot wc teams                  - Returns a list of teams in the World Cup
#   hubot wc score                  - Returns score of current game
#   hubot wc recap                  - Returns a score summary from the previous day's matches
#   hubot wc group <letter>         - Returns a group's standings
#   hubot wc more <team acronym>    - Returns a link to FIFA to see news, rosters, etc. for a given team
#   hubot wc <red or yellow> <name> - Give someone a red/yellow card

module.exports = (robot) ->
  robot.respond /(worldcup|wc)( today)( [\w \(\&\)]+)?/i, (msg) ->
    timezone = if msg.match[3]
      msg.match[3].trim()
    else
      ""

    url = "http://worldcup2014bot.herokuapp.com/matches?timezone=#{timezone}"

    msg.http(url)
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches
        if matches.length > 0
          matches_array = matches.map (match) ->
            match.short_description

          formatted_matches = matches_array.join("\n")

          msg.send formatted_matches
        else
          msg.send "There are no matches today"

  robot.respond /(worldcup|wc)( tomorrow)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/matches/tomorrow")
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches
        if matches.length > 0
          matches_array = matches.map (match) ->
            match.short_description

          formatted_matches = matches_array.join("\n")

          msg.send formatted_matches
        else
          msg.send "There are no matches tomorrow :("

  robot.respond /(worldcup|wc)( teams)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/teams")
      .get() (err, res, body) ->
        teams = JSON.parse(body).teams
        if teams.length > 0
          team_names = teams.map (team) ->
            team.combined_name

          # add a quasi header to explain the output
          team_names.unshift("Team Acronym - Team Name")

          formatted_teams = team_names.join("\n")

          msg.send formatted_teams
        else
          msg.send "We had trouble finding the teams"

  robot.respond /(worldcup|wc)( more)( .*)/i, (msg) ->
    team_acronym = msg.match[3]

    msg.http("http://worldcup2014bot.herokuapp.com/links/#{team_acronym}")
      .get() (err, res, body) ->
        msg.send body

  robot.respond /(who).*(win).*(world).*(cup)/i, (msg) ->
    msg.send "BRASIL!!!"

  robot.respond /(worldcup|wc).*(yellow|red)( .*)/i, (msg) ->
    color = msg.match[2]
    person = msg.match[3].trim()

    if color == "yellow"
      msg.send "http://www.transpoplanner.com/wp-content/uploads/2014/01/b809cfee40_yellow-card1.jpg"
      msg.send "#{person}: one more and you're out"
    else if color == "red"
      msg.send "http://img.thesun.co.uk/aidemitlum/archive/01689/red_main_1689473a.jpg"
      msg.send "#{person}: you're out"

  robot.respond /(worldcup|wc)( recap)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/scores/recap")
      .get() (err, res, body) ->
        scores = JSON.parse(body).scores
        if scores.length > 0
          scores_array = scores.map (score) ->
            score.score_summary

          formatted_scores = scores_array.join("\n")

          msg.send formatted_scores
        else
          msg.send "There were no matches yesterday :("

  robot.respond /(worldcup|wc)( score)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/scores/now")
      .get() (err, res, body) ->
        score = JSON.parse(body).score
        if score
          msg.send score.score_summary
        else
          msg.send "There is no game right now :("

  robot.respond /(worldcup|wc)( group)( .*)/i, (msg) ->
    group_letter = msg.match[3].trim().toUpperCase()

    msg.http("http://worldcup2014bot.herokuapp.com/groups/#{group_letter}")
      .get() (err, res, body) ->
        standings = JSON.parse(body).groups

        if standings.length > 0
          scores_array = standings.map (gs) ->
            "#{gs.team.name} - #{gs.games_played}GP #{gs.wins}W #{gs.draws}D #{gs.losses}L #{gs.goals_for}GF #{gs.goals_against}GA #{gs.points}PTS"

          scores_array.unshift("Group #{group_letter} standings")

          formatted_standings = scores_array.join("\n")

          msg.send formatted_standings
        else
          msg.send "We couldn't find standings for that group. Please make sure the letter is valid and try again."
