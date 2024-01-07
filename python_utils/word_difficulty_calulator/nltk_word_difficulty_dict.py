import nltk
from nltk.stem import WordNetLemmatizer
from nltk.probability import FreqDist
from textblob import Word as TextWord
import string
import sys
import re

class WordDifficulty:
    """Estimate the difficulty level of a given English word.

    This class provides methods to estimate the difficulty level of an English word
    based on its usage frequency in various corpora and other linguistic transformations.

    Attributes:
        stopwords (set): A set of common English stopwords.
        words (set): A set of common English words.
        names (set): A set of common names.
        word_freq (dict): A dictionary containing frequency distributions of words in different corpora.
        lemmatizer (WordNetLemmatizer): An instance of WordNetLemmatizer for lemmatization.
    """

    def __init__(self):
        """Initialize the WordDifficulty class and download required NLTK resources."""
        self.stopwords = set(nltk.corpus.stopwords.words('english'))
        self.words = set(nltk.corpus.words.words())
        self.names = set(nltk.corpus.names.words())

        all_synsets = list(nltk.corpus.wordnet.all_synsets())
        all_wordnet_words = []
        for synset in all_synsets:
            all_wordnet_words.extend(synset.lemma_names())
        self.wordnet_words = set(all_wordnet_words)

        self.word_freq = {
            "words": FreqDist(nltk.corpus.words.words()),
            "wordnet_words": FreqDist(all_wordnet_words),

            "movie_reviews": FreqDist(nltk.corpus.movie_reviews.words()),
            "reuters": FreqDist(nltk.corpus.reuters.words()),
            "brown": FreqDist(nltk.corpus.brown.words()),
            "gutenberg": FreqDist(nltk.corpus.gutenberg.words()),
            "webtext": FreqDist(nltk.corpus.webtext.words()),
            "nps_chat": FreqDist(nltk.corpus.nps_chat.words()),
            "inaugural": FreqDist(nltk.corpus.inaugural.words()),
        }
        self.lemmatizer = WordNetLemmatizer()

    def evaluate_word_difficulty(self, word):
        """Estimate the difficulty level of a word.

       Args:
           word (str): The word to evaluate.

       Returns:
           str: The difficulty level of the word, which can be "easy," "moderate," or "difficult."
       """
        word = word.lower()
        base_form = self.to_base_form(word)
        not_slang_form = self.slang_to_normal(word)

        value = self.score_word_difficulty(word)
        sum_eval = value
        if base_form != word:
            value_base = self.score_word_difficulty(base_form)
            if value_base:
                sum_eval = max(sum_eval, value_base) if sum_eval else value_base
        if not_slang_form != word:
            value_base = self.score_word_difficulty(not_slang_form)
            if value_base:
                sum_eval = max(sum_eval, value_base) if sum_eval else value_base
        if sum_eval is None:
            return "unclassified"
        if sum_eval < 20:
            return "difficult"
        if sum_eval < 110:
            return "moderate"
        return "easy"

    def score_word_difficulty(self, word):
        """Estimate the difficulty of a word based on its usage frequency.

       Args:
           word (str): The word to evaluate.

       Returns:
           int or None: The difficulty score of the word, or None if the word is not found in any corpus.
       """
        word = word.lower()
        if word in self.stopwords:
            return 200  # super easy
        eval_result = self.eval_word(word)
        if not self.is_a_word(word, eval_result):
            return
        sum_eval = sum(eval_result.values())
        return sum_eval

    def eval_word(self, word):
        """Evaluate the word's frequency in various corpora.

        Args:
            word (str): The word to evaluate.

        Returns:
            dict: A dictionary containing the word's frequency in different corpora.
        """
        word = word.lower()
        return {corpus: freq[word] for corpus, freq in self.word_freq.items()}

    def is_a_word(self, word, eval_result=None):
        """Check if a word is a valid English word.

        Args:
            word (str): The word to check.
            eval_result (dict): A pre-evaluated word frequency dictionary (optional).

        Returns:
            bool: True if the word is a valid English word; otherwise, False.
        """
        if any(value in self.stopwords for value in [word, word.title()]):
            return True
        if any(value in self.words for value in [word, word.title()]):
            return True
        if not eval_result:
            eval_result = self.eval_word(word)
        sum_eval = sum(eval_result.values())
        if sum_eval == 0:
            return False
        non_movie_reviews_eval = sum(value for key, value in eval_result.items() if key not in ["movie_reviews"])
        if non_movie_reviews_eval == 0 and word.title() in self.names:
            return False
        return True

    def plural_to_base_form(self, word):
        """Convert a plural noun to its base form.

        Args:
            word (str): The word to convert.

        Returns:
            str: The base form of the word.
        """
        return self.lemmatizer.lemmatize(word.lower(), pos='n')

    def verb_to_present_tense(self, noun):
        """Convert a verb to its present tense form.

        Args:
            noun (str): The verb to convert.

        Returns:
            str: The present tense form of the verb.
            For example: running ==> run.
        """
        word = TextWord(noun.lower())
        return word.lemmatize("v")

    def to_base_form(self, word):
        """Transform a word to its base form using multiple methods.

        Args:
            word (str): The word to transform.

        Returns:
            str: The base form of the word after applying multiple transformations.
        """
        fixed_word = self.plural_to_base_form(word)
        fixed_word = self.verb_to_present_tense(fixed_word)
        return fixed_word

    def slang_to_normal(self, word):
        """Convert slang forms of words into normal forms.

        Args:
            word (str): The word to convert.

        Returns:
            str: The normal form of the word, or the original word if not found in slang.
            For example: flyin ==> flying, runnin ==> running.
        """
        if word.endswith("in") and f"{word}g" in self.words:
            return f"{word}g"
        return word

# Initialize the WordDifficulty class
word_difficulty = WordDifficulty()

# Long running task (2.5 seconds analysis for each word)
# Get the input transcript from Ruby script

def create_filtered_word_list(transcript):
    # Remain punctuations including 「'」 and 「-」 and Replace all the other punctuations into blank space
    text_without_punctuation = re.sub(r"[^\w\s'-]", ' ', transcript)
    # Lowercase all the text
    text_lowercased = text_without_punctuation.lower()
    # Split text into a list of words
    words = text_lowercased.split()
    # print("create_filtered_word_list:",words)
    return words

def create_word_difficulty_dict(words):
    word_difficulty_dict = {}
    for word in words:
        if word not in word_difficulty_dict:
            word_difficulty_dict[word] = word_difficulty.evaluate_word_difficulty(word)
    return word_difficulty_dict

def dict_filter(dict):
    stopwords = word_difficulty.stopwords
    translator = str.maketrans("", "", string.punctuation.replace("-", ""))
    cleaned_dict = {key: value for key, value in dict.items() if key.translate(translator).isalpha() or "-" in key}
    cleaned_dict = {key: value for key, value in cleaned_dict.items() if key.isalnum() and key.lower() not in word_difficulty.stopwords}
    return cleaned_dict

ruby_input = sys.stdin.read()
# lines = ruby_input.split('\n')[0]
lines = ruby_input.strip()  # Remove leading/trailing whitespace

# lines = """I've got a big family, cos I had older brothers and sisters, and they all had loads of kids, and their kids have had loads of kids, and their kids have had loads of kids, cos we're chavs, basically.
#           There's a new baby every Christmas.
#           It's one of those families.
#           I go home, it's crowded.
#           I go, oh, oh, who's this?
#           Oh, yours?
#           Oh, well done.
#           I don't know him, I don't know her.
#           You know what I mean?
#           It's like... But what I've done over the last couple of years, I've got them each individually, right, in private, and I've told them that I'm leaving my entire fortune to just them, right?
#           But to keep it secret.
#           So they all love me, right?
#           And I'm not doing a will, so my funeral is going to be a fucking bloodbath."""

if lines:
    transcript = lines
    words = create_filtered_word_list(transcript)
    word_difficulty_dict = create_word_difficulty_dict(words)

    output_file_path = 'app/domain/podcast_difficulty/lib/temp_word_difficulty_dict.yml'
    with open(output_file_path, 'w') as file:
        yaml.dump(word_difficulty_dict, file)

    print(dict_filter(word_difficulty_dict))
else:
    print('Create word_difficulty_dict ERROR')
