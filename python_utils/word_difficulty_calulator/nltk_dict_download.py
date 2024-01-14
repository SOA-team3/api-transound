import nltk

def download_corpora():
    """ Download essential NLTK corpora for natural language processing tasks.

    This function downloads the following NLTK corpora:
    - 'stopwords': Common stopwords in English.
    - 'words': A list of common English words.
    - 'reuters': Reuters news corpus.
    - 'brown': Brown corpus, a general corpus of American English.
    - 'gutenberg': Gutenberg corpus containing public domain books.
    - 'names': A list of names.
    - 'webtext': Web text corpus, a collection of text from web pages.
    - 'nps_chat': Chat logs from the NPS Chat corpus.
    - 'inaugural': Inaugural addresses of U.S. presidents

    Usage:
    download_corpora()
    """
    # 添加您的 Heroku 應用程序目錄到 nltk.data.path
    nltk.data.path.append("/app/.heroku/python/nltk_data")
    
    nltk.download('stopwords')
    nltk.download('words')
    nltk.download('reuters')
    nltk.download('brown')
    nltk.download('gutenberg')
    nltk.download('names')
    nltk.download('webtext')
    nltk.download('nps_chat')
    nltk.download('inaugural')
    nltk.download('wordnet')
    nltk.download('movie_reviews')

download_corpora()
