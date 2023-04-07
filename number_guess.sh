#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=guessing_game --tuples-only -c"

echo "Enter your username:"
read USERNAME

USER_SEARCH=$($PSQL "SELECT games_played, number_of_guesses FROM users WHERE username='$USERNAME'")
echo "$USER_SEARCH" | while read GAMES_PLAYED BAR NUMBER_OF_GUESSES
do
  if [[ -z $USER_SEARCH ]]
    then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users VALUES('$USERNAME',1,1,0)")
    else
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $NUMBER_OF_GUESSES guesses."
  fi
done

echo "Guess the secret number between 1 and 1000:"
  
NUMBER=$((1 + $RANDOM % 1000))
echo $NUMBER
while [[ $USER_GUESS != $NUMBER ]]
do
  read USER_GUESS
  # check input is int
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
  COUNT_GUESS=$(($COUNT_GUESS + 1))

  if [[ $USER_GUESS == $NUMBER ]]
    then
    echo "You guessed it in $COUNT_GUESS tries. The secret number was $NUMBER. Nice job!"
    elif [[ $USER_GUESS > $NUMBER ]]
    then
    echo "It's lower than that, guess again:"
    elif [[ $USER_GUESS < $NUMBER ]]
    then 
    echo "It's higher than that, guess again:"
  fi
done
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
F_GAMES_PLAYED=$(echo $GAMES_PLAYED | sed -E 's/^ *| *$//g')
NUMBER_OF_GUESSES=$($PSQL "SELECT number_of_guesses FROM users WHERE username='$USERNAME'")
F_NUMBER_OF_GUESSES=$(echo $NUMBER_OF_GUESSES | sed -E 's/^ *| *$//g')

if [[ $F_NUMBER_OF_GUESSES == 0 ]]
then
  UPDATE=$($PSQL "UPDATE users SET number_of_guesses = $COUNT_GUESS WHERE username = '$USERNAME'")
elif [[ $F_NUMBER_OF_GUESSES > 0 && $COUNT_GUESS < $F_NUMBER_OF_GUESSES ]]
then
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  UPDATE=$($PSQL "UPDATE users SET number_of_guesses = $COUNT_GUESS, best_game = $(($F_GAMES_PLAYED + 1)), games_played = $(($F_GAMES_PLAYED + 1)) WHERE username = '$USERNAME'")
elif [[ $F_NUMBER_OF_GUESSES > 0 && $COUNT_GUESS > $F_NUMBER_OF_GUESSES ]]
then
  UPDATE=$($PSQL "UPDATE users SET games_played = $(($F_GAMES_PLAYED + 1))  WHERE username = '$USERNAME'")
fi





