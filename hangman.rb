require 'json'

# Read the file
file_path = 'google-10000-english-no-swears.txt'
words = File.readlines(file_path).map(&:chomp)

# Filter words that are between 5 and 12 characters long
filtered_words = words.select { |word| word.length.between?(5, 12) }

# Pick a random word from the filtered list
secret_word = filtered_words.sample

word_length = secret_word.length

tries = word_length * 2

# Create a string with "_" repeated `number` times
line = "_" * word_length

# Show the initial hidden word (with underscores and spaces for clarity)
puts line.chars.join(' ') # Prints _ _ _ _ _ _ _

# Print the random word
puts "Random word: #{secret_word}  Length: #{word_length}"

invalid_letters = []

# Function to save the game state to a JSON file
def save_game(secret_word, tries, line, invalid_letters)
  game_state = {
    secret_word: secret_word,
    tries: tries,
    line: line,
    invalid_letters: invalid_letters
  }

  # Write the game state to a JSON file
  File.open("game_save.json", "w") do |file|
    file.write(JSON.pretty_generate(game_state))
  end

  puts "Game has been saved."
end

def load_game
  if File.exist?("game_save.json")
    file = File.read("game_save.json")
    game_state = JSON.parse(file)
    puts "Game loaded."
    return game_state
  else
    puts "No saved game found."
    return nil
  end
end

while line.include?("_") and tries != 0
  puts "------ You have #{tries} tries left ----"
    # Ask for a letter input
  print "Enter a letter to check: "
  input_letter = gets.chomp.downcase

  if input_letter == "load"
    game_state = load_game
    if game_state
      secret_word = game_state["secret_word"]
      tries = game_state["tries"] + 1
      line = game_state["line"]
      invalid_letters = game_state["invalid_letters"]
    end
  end

  # Flag to track if the letter is found
  letter_found = false

  # Handle the "save" command
  if input_letter == "save"
    save_game(secret_word, tries, line, invalid_letters)
    tries += 1
    next
  end

  # Find positions of the letter in the secret word and reveal them in 'line'
  secret_word.chars.each_with_index do |char, index|
    if char.downcase == input_letter
      # Replace the underscore with the correct letter in 'line'
      line[index] = char.downcase
      letter_found = true
    end
  end

  if !letter_found
    invalid_letters << input_letter
  end

  puts "Invalid letters: #{invalid_letters.join(', ')}"
  # Print the updated 'line' with guessed letters revealed (with spaces for clarity)
  puts line.chars.join(' ')
  tries -= 1

end

if tries == 0
  puts "You lost"
else
  puts "You won"
end
