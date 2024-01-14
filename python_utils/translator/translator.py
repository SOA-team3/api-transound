from translate import Translator
import sys

# Split the stdin parameter
para = sys.stdin.read()
TEXT = para.split('\n')[0]
translate_language = para.split('\n')[1]

# Translate the text by translate
def text_translate(text, translate_language):
    translator = Translator(to_lang = translate_language)
    translated_text = translator.translate(text)
    return translated_text
output = text_translate(TEXT, translate_language)
print(output)
