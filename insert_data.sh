#!/bin/bash

# Set up the PSQL variable to execute queries
PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Clear existing data to prevent duplicate entries
echo "$($PSQL "TRUNCATE games, teams RESTART IDENTITY")"

# Read the games.csv file and insert data (skip the first line)
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]  # Skip the first line
  then
    # Insert the winner team if not already in the table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]; then
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Insert the opponent team if not already in the table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]; then
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insert game data
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
  fi
done
