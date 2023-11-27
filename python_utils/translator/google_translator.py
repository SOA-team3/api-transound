from googletrans import Translator
import sys

# Split the stdin parameter
para = sys.stdin.read()
TEXT = para.split('\n')[0]
translate_language = para.split('\n')[1]

# Translate the text
def text_translate(text, translate_language):
    translator = Translator()
    trans_lang = translate_language #'en'
    translated_text = translator.translate(text, dest=trans_lang)
    return translated_text.text
output = text_translate(TEXT, translate_language)
print(output)
