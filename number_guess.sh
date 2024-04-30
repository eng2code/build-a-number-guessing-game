#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#play number guess game
PLAY () {
  #generate random number
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  echo $SECRET_NUMBER
  echo "Guess the secret number between 1 and 1000:"
  
  while read GUESS
    do
    COUNTER=$[$COUNTER + 1]
    #if guess is not integer
      if [[ ! $GUESS =~ ^[0-9]+$ ]] 
      then
        echo "That is not an integer, guess again:"
  
      #if guess is > SECRET_NUMBER
      elif [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
  
      #if guess is < SECRET_NUMBER
      elif [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"

      #if guess = secret number
      else
        echo "You guessed it in $COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
      fi

    done
}

#enter username
echo "Enter your username:"
read USERNAME
QUERY_USERNAME=$($PSQL "SELECT username FROM user_info WHERE username='$USERNAME'")

#if username does not exist
if [[ -z $QUERY_USERNAME ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  PLAY
  INSERT_NEW_RECORD=$($PSQL "INSERT INTO user_info(username,games_played, best_game) VALUES('$USERNAME',1,$COUNTER)")
else
#if username exists
  GET_USER_INFO=$($PSQL "SELECT * FROM user_info WHERE username='$USERNAME'")
  echo $GET_USER_INFO | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
  PLAY
  #update user info
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_info SET games_played=games_played+1 WHERE username='$USERNAME'")
  SELECT_BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE username='$USERNAME'")
  if [[ $COUNTER -lt $SELECT_BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE user_info SET best_game=$COUNTER WHERE username='$USERNAME'")
  fi
fi
