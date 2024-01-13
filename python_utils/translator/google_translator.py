# Googletrans 3.1.0a0 requires httpx==0.13.3, but we having httpx 0.26.0 for openAI which causes incompatible issue.
from googletrans import Translator
import sys

# Split the stdin parameter
para = sys.stdin.read()
TEXT = para.split('\n')[0]
translate_language = para.split('\n')[1]
# TEXT = "These Tiny Pollinators Can Travel Surprisingly Huge Distances."
# translate_language = "zh-tw"

# Translate the text by googletrans
def googletrans_text_translate(text, translate_language):
    translator = Translator()
    trans_lang = translate_language #'en'
    translated_text = translator.translate(text, dest=trans_lang)
    return translated_text.text
output = googletrans_text_translate(TEXT, translate_language)

